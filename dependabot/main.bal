// main.bal
// Entry point — runs the agent for each connector SEQUENTIALLY, one at a time.
//
// FIX (2026-04-17): `processConnector` is now wrapped in a hard wall-clock
// budget (MAX_CONNECTOR_SECONDS, default 600 s).  Previously this constant
// was defined but never actually enforced — one stuck HTTP call could freeze
// the whole run.  The budget is enforced by racing the work against a timer
// worker, same pattern as withTimeout() in agent.bal.
//
// Override the budget via env var:
//   MAX_CONNECTOR_SECONDS=180 bal run .

import ballerina/io;
import ballerina/lang.runtime;
import ballerina/log;
import ballerina/os;
import ballerina/time;
import ballerina/file;

configurable string outputFile = "openapi_specs.json";

const string BAR  = "================================================================";
const string DASH = "----------------------------------------------------------------";

// Hard wall-clock ceiling for a single connector, all steps combined.
const decimal DEFAULT_MAX_CONNECTOR_SECONDS = 600.0;

public function main() returns error? {
    string apiKey    = os:getEnv("ANTHROPIC_API_KEY");
    string filterStr = os:getEnv("FILTER").toLowerAscii();
    boolean dryRun   = os:getEnv("DRY_RUN").toLowerAscii() == "true";
    string outFile   = os:getEnv("OUTPUT").length() > 0 ? os:getEnv("OUTPUT") : outputFile;
    string ghToken   = os:getEnv("GITHUB_TOKEN");
    string model     = os:getEnv("CLAUDE_MODEL").length() > 0 ? os:getEnv("CLAUDE_MODEL") : "claude-sonnet-4-6";

    // Resolve per-connector budget from env
    decimal maxConnectorSecs = DEFAULT_MAX_CONNECTOR_SECONDS;
    string envBudget = os:getEnv("MAX_CONNECTOR_SECONDS");
    if envBudget.length() > 0 {
        decimal|error parsed = decimal:fromString(envBudget);
        if parsed is decimal {
            maxConnectorSecs = parsed;
        }
    }

    Connector[] connectors = filterStr.length() > 0
        ? ALL_CONNECTORS.filter(c => c.name.toLowerAscii().includes(filterStr))
        : ALL_CONNECTORS;

    // ── Dry run ───────────────────────────────────────────────────────────────
    if dryRun {
        io:println(BAR);
        io:println(string `  OpenAPI Spec Finder — ${connectors.length()} connector(s)`);
        io:println(DASH);
        int i = 1;
        foreach Connector c in connectors {
            string t = c.targetTitle is string ? string ` [${c.targetTitle ?: ""}]` : "";
            io:println(string `  ${lp(i.toString(), 3)}. ${pad(c.name, 32)} ${c.docsUrl}${t}`);
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
    io:println(string `  APIs     : ${connectors.length()}`);
    io:println(string `  Mode     : sequential (one at a time)`);
    io:println(string `  Max/conn : ${maxConnectorSecs}s (override via MAX_CONNECTOR_SECONDS)`);
    io:println(string `  Debug    : run with --log-level=DEBUG for verbose fetch/timing logs`);
    io:println(BAR);
    io:println("");

    // ── Load existing results to merge into ───────────────────────────────────
    ResultEntry[] existing = loadResults(outFile);
    map<int> existingIdx = {};
    int ei = 0;
    foreach ResultEntry r in existing {
        existingIdx[r.name] = ei;
        ei += 1;
    }

    ResultEntry[] results = existing;
    time:Utc runStart = time:utcNow();
    int found = 0;
    int notFound = 0;
    int total = connectors.length();

    // ── Sequential loop ───────────────────────────────────────────────────────
    int idx = 0;
    foreach Connector c in connectors {
        idx += 1;
        string progress = string `[${idx}/${total}]`;

        string? knownUrl  = ();
        string? knownRepo = ();
        if existingIdx.hasKey(c.name) {
            ResultEntry prev = results[existingIdx.get(c.name)];
            knownUrl  = prev.specUrl;
            knownRepo = prev.specRepo;
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

        if entry.status == "found" {
            found += 1;
            io:println(string `${progress} PASS   ${label}`);
            io:println(string `         => ${entry.specUrl ?: ""}`);
            io:println(string `            format=${entry.format ?: "?"} | ${entry.elapsedSeconds}s`);
        } else {
            notFound += 1;
            io:println(string `${progress} FAIL   ${label}  [${entry.elapsedSeconds}s]`);
            log:printWarn(string `${progress} NOT FOUND: ${label} | docs=${c.docsUrl}`);
        }

        if existingIdx.hasKey(entry.name) {
            results[existingIdx.get(entry.name)] = entry;
        } else {
            existingIdx[entry.name] = results.length();
            results.push(entry);
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
    io:println(string `  found=${found}  not_found=${notFound}  total=${total}`);
    io:println(string `  Saved to ${outFile}`);
    io:println(BAR);
}

// ─── Budget-enforced connector runner ─────────────────────────────────────────
//
// Races processConnector against a sleep.  If the sleep wins, we mark the
// connector as not_found with a clear "budget exceeded" reason.  The still-
// running worker will be abandoned — Ballerina does not give us a way to
// cancel a worker from outside, but since the main loop moves on and the
// process keeps going, this is acceptable.  The hung worker will complete
// eventually (or not) and its result will be discarded.

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
            docsUrl:        c.docsUrl,
            targetTitle:    c.targetTitle,
            specUrl:        (),
            specRepo:       (),
            title:          (),
            apiVersion:     (),
            format:         (),
            status:         "not_found",
            checkedAt:      time:utcToString(time:utcNow()),
            elapsedSeconds: elapsed
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
            SpecResult?|string stableResult = stepQuickVerify(knownUrl, knownRepo, c.docsUrl, apiKey);

            if stableResult is SpecResult {
                log:printInfo(string `${progress} stable-version-check => confirmed`);
                finalResult = stableResult;
            } else if stableResult is string {
                log:printWarn(string `${progress} stable URL is DEAD — re-discovering`);
                DiscoveryResult disc = stepDiscovery(c.docsUrl, c.name, c.targetTitle, apiKey, knownRepo);
                log:printInfo(string `${progress} discovery found ${disc.candidateUrls.length()} candidate(s)`);
                finalResult = stepContentVerify(disc);
            } else {
                log:printWarn(string `${progress} stable-version-check inconclusive — trying direct verify of known URL`);
                finalResult = directVerifyKnownUrl(knownUrl, knownRepo);
                if finalResult is () {
                    log:printWarn(string `${progress} direct verify failed — re-discovering with known URL as hint`);
                    DiscoveryResult disc = stepDiscovery(c.docsUrl, c.name, c.targetTitle, apiKey, knownRepo, knownUrl);
                    log:printInfo(string `${progress} discovery found ${disc.candidateUrls.length()} candidate(s)`);
                    finalResult = stepContentVerify(disc);
                } else {
                    log:printInfo(string `${progress} direct verify succeeded — using known URL`);
                }
            }
        } else {
            log:printInfo(string `${progress} path=github-version-check`);
            SpecResult?|string checkResult = stepGithubVersionCheck(knownUrl, knownRepo, c.docsUrl, apiKey);

            if checkResult is SpecResult {
                log:printInfo(string `${progress} github-version-check => confirmed`);
                finalResult = checkResult;
            } else if checkResult is string {
                log:printWarn(string `${progress} GitHub URL is DEAD — re-discovering`);
                DiscoveryResult disc = stepDiscovery(c.docsUrl, c.name, c.targetTitle, apiKey, knownRepo);
                log:printInfo(string `${progress} discovery found ${disc.candidateUrls.length()} candidate(s)`);
                finalResult = stepContentVerify(disc);
            } else {
                log:printWarn(string `${progress} github-version-check inconclusive — trying direct verify of known URL`);
                finalResult = directVerifyKnownUrl(knownUrl, knownRepo);
                if finalResult is () {
                    log:printWarn(string `${progress} direct verify failed — re-discovering with known URL as hint`);
                    DiscoveryResult disc = stepDiscovery(c.docsUrl, c.name, c.targetTitle, apiKey, knownRepo, knownUrl);
                    log:printInfo(string `${progress} discovery found ${disc.candidateUrls.length()} candidate(s)`);
                    finalResult = stepContentVerify(disc);
                } else {
                    log:printInfo(string `${progress} direct verify succeeded — using known URL`);
                }
            }
        }
    } else {
        log:printInfo(string `${progress} path=full-discovery`);
        DiscoveryResult disc = stepDiscovery(c.docsUrl, c.name, c.targetTitle, apiKey, knownRepo);
        log:printInfo(string `${progress} discovery found ${disc.candidateUrls.length()} candidate(s)`);
        finalResult = stepContentVerify(disc);
    }

    decimal elapsed = rd(time:utcDiffSeconds(time:utcNow(), t0));

    if finalResult is SpecResult {
        return {
            name:           c.name,
            docsUrl:        c.docsUrl,
            targetTitle:    c.targetTitle,
            specUrl:        finalResult.specUrl,
            specRepo:       finalResult.specRepo,
            title:          finalResult.title,
            apiVersion:     finalResult.apiVersion,
            format:         finalResult.format,
            status:         "found",
            checkedAt:      time:utcToString(time:utcNow()),
            elapsedSeconds: elapsed
        };
    } else {
        return {
            name:           c.name,
            docsUrl:        c.docsUrl,
            targetTitle:    c.targetTitle,
            specUrl:        (),
            specRepo:       (),
            title:          (),
            apiVersion:     (),
            format:         (),
            status:         "not_found",
            checkedAt:      time:utcToString(time:utcNow()),
            elapsedSeconds: elapsed
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
    check io:fileWriteString(path, results.toJson().toJsonString());
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
