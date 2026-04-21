// main.bal
// Entry point — runs the agent for each connector SEQUENTIALLY, one at a time.
//
// Paths (relative to the dependabot/ working directory):
//   Output file  : ../openapi_specs.json  (repo root)
//   OpenAPI dir  : ../openapi             (repo root)
//   Summary file : ../UPDATE_SUMMARY.txt  (repo root, picked up by workflow)
//
// Frequency logic:
//   Each entry in openapi_specs.json has a "frequency" field.
//   Allowed values: "daily", "weekly", "monthly", "quarterly", null.
//   null → always process (development / override mode).
//   When a non-null frequency is set, the connector is skipped if it was
//   checked within the corresponding window.
//
// Override via env vars:
//   OUTPUT=./custom.json    — alternative output path
//   OPENAPI_DIR=../openapi  — alternative openapi folder path
//   MAX_CONNECTOR_SECONDS=180 — per-connector wall-clock budget

import ballerina/io;
import ballerina/lang.runtime;
import ballerina/log;
import ballerina/os;
import ballerina/time;
import ballerina/file;

configurable string outputFile = "../openapi_specs.json";
configurable string openApiDir = "../openapi";

const string BAR  = "================================================================";
const string DASH = "----------------------------------------------------------------";

const decimal DEFAULT_MAX_CONNECTOR_SECONDS = 600.0;

public function main() returns error? {
    string apiKey    = os:getEnv("ANTHROPIC_API_KEY");
    string filterStr = os:getEnv("FILTER").toLowerAscii();
    boolean dryRun   = os:getEnv("DRY_RUN").toLowerAscii() == "true";
    string outFile   = os:getEnv("OUTPUT").length() > 0 ? os:getEnv("OUTPUT") : outputFile;
    string ghToken   = os:getEnv("GITHUB_TOKEN");
    string model     = os:getEnv("CLAUDE_MODEL").length() > 0 ? os:getEnv("CLAUDE_MODEL") : "claude-sonnet-4-6";
    string specDir   = os:getEnv("OPENAPI_DIR").length() > 0 ? os:getEnv("OPENAPI_DIR") : openApiDir;

    decimal maxConnectorSecs = DEFAULT_MAX_CONNECTOR_SECONDS;
    string envBudget = os:getEnv("MAX_CONNECTOR_SECONDS");
    if envBudget.length() > 0 {
        decimal|error parsed = decimal:fromString(envBudget);
        if parsed is decimal {
            maxConnectorSecs = parsed;
        }
    }

    // openapi_specs.json is the single source of truth — load it first so we
    // can both filter the run list and carry forward existing state.
    ResultEntry[] results = loadResults(outFile);
    ResultEntry[] connectors = filterStr.length() > 0
        ? results.filter(r => r.name.toLowerAscii().includes(filterStr))
        : results;

    // ── Dry run ───────────────────────────────────────────────────────────────
    if dryRun {
        io:println(BAR);
        io:println(string `  OpenAPI Spec Finder — ${connectors.length()} connector(s)`);
        io:println(DASH);
        int i = 1;
        foreach ResultEntry r in connectors {
            string t = r.targetTitle is string ? string ` [${r.targetTitle ?: ""}]` : "";
            io:println(string `  ${lp(i.toString(), 3)}. ${pad(r.name, 32)} ${r.sourceUrl}${t}`);
            i += 1;
        }
        io:println(BAR);
        return;
    }

    if apiKey.length() == 0 {
        io:println("ERROR: set ANTHROPIC_API_KEY");
        return;
    }

    io:println(BAR);
    io:println("  OpenAPI Spec Finder");
    io:println(string `  Model    : ${model}`);
    io:println(string `  GitHub   : ${ghToken.length() > 0 ? "token set" : "no token (rate limit: 60/hr)"}`);
    io:println(string `  Output   : ${outFile}`);
    io:println(string `  OpenAPI  : ${specDir}`);
    io:println(string `  APIs     : ${connectors.length()}`);
    io:println(string `  Mode     : sequential (one at a time)`);
    io:println(string `  Max/conn : ${maxConnectorSecs}s (override via MAX_CONNECTOR_SECONDS)`);
    io:println(string `  Debug    : run with --log-level=DEBUG for verbose fetch/timing logs`);
    io:println(BAR);
    io:println("");

    // ── Index for O(1) lookup and in-place updates ────────────────────────────
    map<int> existingIdx = {};
    int ei = 0;
    foreach ResultEntry r in results {
        existingIdx[r.name] = ei;
        ei += 1;
    }

    time:Utc runStart = time:utcNow();
    int found = 0;
    int notFound = 0;
    int skipped = 0;
    int total = connectors.length();
    string[] updateLines = [];

    // ── Sequential loop ───────────────────────────────────────────────────────
    int idx = 0;
    foreach ResultEntry r in connectors {
        idx += 1;
        string progress = string `[${idx}/${total}]`;

        Connector c = {name: r.name, sourceUrl: r.sourceUrl, targetTitle: r.targetTitle};

        string? knownUrl  = r.specUrl;
        string? knownRepo = r.specRepo;
        string? prevHash  = r.contentHash;
        string? prevFreq  = r.frequency;

        // ── Frequency skip check ──────────────────────────────────────────────
        if shouldSkipDueToFrequency(r) {
            skipped += 1;
            io:println(DASH);
            io:println(string `${progress} SKIP   ${r.name}  [frequency: ${r.frequency ?: "null"}, last checked: ${r.checkedAt}]`);
            continue;
        }

        io:println(DASH);
        string label = c.targetTitle is string
            ? string `${c.name} / ${c.targetTitle ?: ""}`
            : c.name;

        if knownUrl is string {
            io:println(string `${progress} START  ${label}`);
            log:printInfo(string `${progress} known url: ${knownUrl}`);
        } else {
            io:println(string `${progress} START  ${label}  (no previous URL)`);
        }

        // ── Run with a hard wall-clock budget ─────────────────────────────────
        ResultEntry entry = runConnectorWithBudget(c, knownUrl, knownRepo, apiKey, progress, maxConnectorSecs);

        // Preserve frequency from the existing entry
        entry.frequency = prevFreq;

        if entry.status == "found" {
            found += 1;
            io:println(string `${progress} PASS   ${label}`);
            io:println(string `         => ${entry.specUrl ?: ""}`);
            io:println(string `            format=${entry.format ?: "?"} | version=${entry.apiVersion ?: "?"} | ${entry.elapsedSeconds}s`);

            // ── Download spec to openapi/ folder ─────────────────────────────
            string vendor = deriveVendor(c.name);
            string apiId  = deriveApiId(c.name);
            string specUrl  = entry.specUrl ?: "";
            string fmt      = entry.format ?: "json";

            [boolean, string]|error downloadResult = downloadAndSaveSpec(
                specUrl, fmt, entry.apiVersion, vendor, apiId, specDir, prevHash, c.name, c.sourceUrl
            );

            if downloadResult is [boolean, string] {
                entry.contentHash = downloadResult[1];
                if downloadResult[0] {
                    string versionLabel = entry.apiVersion is string
                        ? normalizeVersion(entry.apiVersion ?: "")
                        : "latest";
                    string updateLine = string `${vendor}/${apiId}@${versionLabel}: updated spec`;
                    updateLines.push(updateLine);
                    io:println(string `         => downloaded to openapi/${vendor}/${apiId}/${versionLabel}/`);
                } else {
                    io:println(string `         => no content change (hash match)`);
                }
            } else {
                log:printWarn(string `${progress} download failed: ${downloadResult.message()}`);
            }
        } else {
            notFound += 1;
            io:println(string `${progress} FAIL   ${label}  [${entry.elapsedSeconds}s]`);
            log:printWarn(string `${progress} NOT FOUND: ${label} | docs=${c.sourceUrl}`);
        }

        if existingIdx.hasKey(entry.name) {
            results[existingIdx.get(entry.name)] = entry;
        }

        error? saveErr = saveResults(results, outFile);
        if saveErr is error {
            log:printError(string `${progress} save failed: ${saveErr.message()}`);
        }

        io:println("");
    }

    decimal elapsed = rd(time:utcDiffSeconds(time:utcNow(), runStart));
    io:println(BAR);
    io:println(string `  Done in ${<int>elapsed}s`);
    io:println(string `  found=${found}  not_found=${notFound}  skipped=${skipped}  total=${total}`);
    io:println(string `  Saved to ${outFile}`);
    io:println(BAR);

    // ── Write UPDATE_SUMMARY.txt ──────────────────────────────────────────────
    if updateLines.length() > 0 {
        string summaryPath = "../UPDATE_SUMMARY.txt";
        string summaryContent = "";
        foreach string line in updateLines {
            summaryContent += line + "\n";
        }
        error? writeErr = io:fileWriteString(summaryPath, summaryContent);
        if writeErr is error {
            log:printError(string `Failed to write UPDATE_SUMMARY.txt: ${writeErr.message()}`);
        } else {
            io:println(string `  Update summary written to ${summaryPath}`);
            io:println(string `  ${updateLines.length()} spec(s) updated`);
        }
    } else {
        // Remove stale UPDATE_SUMMARY.txt if it exists
        boolean exists = check file:test("../UPDATE_SUMMARY.txt", file:EXISTS);
        if exists {
            check file:remove("../UPDATE_SUMMARY.txt");
        }
        io:println("  No spec updates — UPDATE_SUMMARY.txt removed (if present)");
    }
}

// ─── Frequency skip logic ─────────────────────────────────────────────────────
//
// Returns true when the connector should be skipped based on its frequency
// setting and the time since it was last successfully checked.
// null frequency means "always process" (development override mode).

function shouldSkipDueToFrequency(ResultEntry prev) returns boolean {
    string? freq = prev.frequency;

    // null → never skip (dev override mode)
    if freq is () {
        return false;
    }

    time:Utc|error checkedTime = time:utcFromString(prev.checkedAt);
    if checkedTime is error {
        return false;
    }

    decimal secondsSince = time:utcDiffSeconds(time:utcNow(), checkedTime);

    if freq == "daily"     { return secondsSince < 86400.0d; }
    if freq == "weekly"    { return secondsSince < 604800.0d; }
    if freq == "monthly"   { return secondsSince < 2592000.0d; }
    if freq == "quarterly" { return secondsSince < 7776000.0d; }

    return false;
}

// ─── Budget-enforced connector runner ─────────────────────────────────────────

function runConnectorWithBudget(
    Connector c,
    string? knownUrl,
    string? knownRepo,
    string apiKey,
    string progress,
    decimal budgetSecs
) returns ResultEntry {

    time:Utc t0 = time:utcNow();

    worker processor returns ResultEntry {
        return processConnector(c, knownUrl, knownRepo, apiKey, progress);
    }
    worker timer returns ResultEntry {
        runtime:sleep(budgetSecs);
        decimal elapsed = rd(time:utcDiffSeconds(time:utcNow(), t0));
        log:printError(string `${progress} BUDGET EXCEEDED after ${elapsed}s — abandoning connector`);
        return {
            name:           c.name,
            sourceUrl:      c.sourceUrl,
            targetTitle:    c.targetTitle,
            specUrl:        (),
            specRepo:       (),
            apiVersion:     (),
            format:         (),
            frequency:      (),
            status:         "not_found",
            checkedAt:      time:utcToString(time:utcNow()),
            elapsedSeconds: elapsed,
            contentHash:    ()
        };
    }
    ResultEntry result = wait processor | timer;
    return result;
}

// ─── Per-connector work ───────────────────────────────────────────────────────

function processConnector(
    Connector c,
    string? knownUrl,
    string? knownRepo,
    string apiKey,
    string progress
) returns ResultEntry {

    time:Utc t0 = time:utcNow();
    SpecResult? finalResult = ();

    if knownUrl is string {
        if !knownUrl.includes("raw.githubusercontent.com") {
            log:printInfo(string `${progress} path=stable-version-check`);
            SpecResult?|string stableResult = stepQuickVerify(knownUrl, knownRepo, c.sourceUrl, apiKey);

            if stableResult is SpecResult {
                log:printInfo(string `${progress} stable-version-check => confirmed`);
                finalResult = stableResult;
            } else if stableResult is string {
                log:printWarn(string `${progress} stable URL is DEAD — re-discovering`);
                DiscoveryResult disc = stepDiscovery(c.sourceUrl, c.name, c.targetTitle, apiKey, knownRepo);
                log:printInfo(string `${progress} discovery found ${disc.candidateUrls.length()} candidate(s)`);
                finalResult = stepContentVerify(disc);
            } else {
                log:printWarn(string `${progress} stable-version-check inconclusive — trying direct verify of known URL`);
                finalResult = directVerifyKnownUrl(knownUrl, knownRepo);
                if finalResult is () {
                    log:printWarn(string `${progress} direct verify failed — re-discovering with known URL as hint`);
                    DiscoveryResult disc = stepDiscovery(c.sourceUrl, c.name, c.targetTitle, apiKey, knownRepo, knownUrl);
                    log:printInfo(string `${progress} discovery found ${disc.candidateUrls.length()} candidate(s)`);
                    finalResult = stepContentVerify(disc);
                } else {
                    log:printInfo(string `${progress} direct verify succeeded — using known URL`);
                }
            }
        } else {
            log:printInfo(string `${progress} path=github-version-check`);
            SpecResult?|string checkResult = stepGithubVersionCheck(knownUrl, knownRepo, c.sourceUrl, apiKey);

            if checkResult is SpecResult {
                log:printInfo(string `${progress} github-version-check => confirmed`);
                finalResult = checkResult;
            } else if checkResult is string {
                log:printWarn(string `${progress} GitHub URL is DEAD — re-discovering`);
                DiscoveryResult disc = stepDiscovery(c.sourceUrl, c.name, c.targetTitle, apiKey, knownRepo);
                log:printInfo(string `${progress} discovery found ${disc.candidateUrls.length()} candidate(s)`);
                finalResult = stepContentVerify(disc);
            } else {
                log:printWarn(string `${progress} github-version-check inconclusive — trying direct verify of known URL`);
                finalResult = directVerifyKnownUrl(knownUrl, knownRepo);
                if finalResult is () {
                    log:printWarn(string `${progress} direct verify failed — re-discovering with known URL as hint`);
                    DiscoveryResult disc = stepDiscovery(c.sourceUrl, c.name, c.targetTitle, apiKey, knownRepo, knownUrl);
                    log:printInfo(string `${progress} discovery found ${disc.candidateUrls.length()} candidate(s)`);
                    finalResult = stepContentVerify(disc);
                } else {
                    log:printInfo(string `${progress} direct verify succeeded — using known URL`);
                }
            }
        }
    } else {
        log:printInfo(string `${progress} path=full-discovery`);
        DiscoveryResult disc = stepDiscovery(c.sourceUrl, c.name, c.targetTitle, apiKey, knownRepo);
        log:printInfo(string `${progress} discovery found ${disc.candidateUrls.length()} candidate(s)`);
        finalResult = stepContentVerify(disc);
    }

    decimal elapsed = rd(time:utcDiffSeconds(time:utcNow(), t0));

    if finalResult is SpecResult {
        return {
            name:           c.name,
            sourceUrl:      c.sourceUrl,
            targetTitle:    c.targetTitle,
            specUrl:        finalResult.specUrl,
            specRepo:       finalResult.specRepo,
            apiVersion:     finalResult.apiVersion,
            format:         finalResult.format,
            frequency:      (),      // set by caller after return
            status:         "found",
            checkedAt:      time:utcToString(time:utcNow()),
            elapsedSeconds: elapsed,
            contentHash:    ()       // set by caller after download
        };
    } else {
        return {
            name:           c.name,
            sourceUrl:      c.sourceUrl,
            targetTitle:    c.targetTitle,
            specUrl:        (),
            specRepo:       (),
            apiVersion:     (),
            format:         (),
            frequency:      (),
            status:         "not_found",
            checkedAt:      time:utcToString(time:utcNow()),
            elapsedSeconds: elapsed,
            contentHash:    ()
        };
    }
}

// ─── Persistence ──────────────────────────────────────────────────────────────

function loadResults(string path) returns ResultEntry[] {
    do {
        boolean exists = check file:test(path, file:EXISTS);
        if !exists { return []; }
        string content = check io:fileReadString(path);
        ResultEntry[]|error parsed = content.fromJsonStringWithType();
        if parsed is ResultEntry[] { return parsed; }
    } on fail { }
    return [];
}

function saveResults(ResultEntry[] results, string path) returns error? {
    string formatted = prettyPrintJson(results.toJson(), 0) + "\n";
    check io:fileWriteString(path, formatted);
}

// ─── JSON pretty-printer ──────────────────────────────────────────────────────
// Produces 4-space indented JSON with a blank line between top-level array items.

function prettyPrintJson(json val, int indentLevel) returns string {
    string indent = buildIndent(indentLevel);
    string childIndent = buildIndent(indentLevel + 1);

    if val is map<json> {
        map<json> obj = val;
        string[] keys = obj.keys();
        if keys.length() == 0 { return "{}"; }
        string result = "{\n";
        boolean first = true;
        foreach string key in keys {
            if !first { result += ",\n"; }
            result += childIndent + "\"" + jsonEsc(key) + "\": " + prettyPrintJson(obj.get(key), indentLevel + 1);
            first = false;
        }
        result += "\n" + indent + "}";
        return result;
    } else if val is json[] {
        json[] arr = val;
        if arr.length() == 0 { return "[]"; }
        string result = "[\n";
        boolean first = true;
        foreach json item in arr {
            // blank line between top-level array items (indentLevel == 0)
            if !first { result += indentLevel == 0 ? ",\n\n" : ",\n"; }
            result += childIndent + prettyPrintJson(item, indentLevel + 1);
            first = false;
        }
        result += "\n" + indent + "]";
        return result;
    } else if val is string {
        return "\"" + jsonEsc(val) + "\"";
    } else if val is () {
        return "null";
    } else {
        return val.toString();
    }
}

isolated function buildIndent(int level) returns string {
    string result = "";
    int i = 0;
    while i < level { result += "    "; i += 1; }
    return result;
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

isolated function pad(string s, int w) returns string {
    string r = s;
    int i = s.length();
    while i < w { r += " "; i += 1; }
    return r;
}

isolated function lp(string s, int w) returns string {
    string r = "";
    int i = s.length();
    while i < w { r += " "; i += 1; }
    return r + s;
}
