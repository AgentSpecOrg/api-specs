// downloader.bal
// Downloads a verified spec from its URL and saves it to the correct openapi/ folder.
//
// Folder layout: {openApiDir}/{vendor}/{apiId}/{versionFolder}/openapi.{ext}
//                {openApiDir}/{vendor}/{apiId}/{versionFolder}/.metadata.json
//
// .metadata.json is only created when a NEW version folder is created for the
// first time. It is never modified when an existing spec file is replaced.
//
// Version folder naming:
//   - Version strings starting with a digit get a "v" prefix (e.g. "3.0" → "v3.0").
//   - nil or empty apiVersion → "latest" is used as the folder name.

import ballerina/crypto;
import ballerina/file;
import ballerina/io;
import ballerina/log;

// Downloads a spec and saves it to the appropriate folder.
// Returns [changed, newContentHash]:
//   changed=true  → file was added or updated
//   changed=false → file already existed with identical content
function downloadAndSaveSpec(
    string specUrl,
    string format,
    string? apiVersion,
    string vendor,
    string apiId,
    string openApiDir,
    string connectorName,
    string sourceUrl
) returns [boolean, string]|error {

    string versionFolder = normalizeVersion(apiVersion ?: "");
    string fileName = format == "json" ? "openapi.json" : "openapi.yaml";

    string specDir    = string `${openApiDir}/${vendor}/${apiId}`;
    string versionDir = string `${specDir}/${versionFolder}`;
    string specFile   = string `${versionDir}/${fileName}`;
    string otherFileName = format == "json" ? "openapi.yaml" : "openapi.json";
    string otherFile = string `${versionDir}/${otherFileName}`;
    string metaFile   = string `${versionDir}/.metadata.json`;

    log:printInfo(string `  [download] --- BEGIN ${vendor}/${apiId}@${versionFolder} ---`);
    log:printInfo(string `  [download] openApiDir  : ${openApiDir}`);
    log:printInfo(string `  [download] versionDir  : ${versionDir}`);
    log:printInfo(string `  [download] specFile    : ${specFile}`);
    log:printInfo(string `  [download] otherFile   : ${otherFile}`);
    log:printInfo(string `  [download] metaFile    : ${metaFile}`);
    log:printInfo(string `  [download] fetching    : ${specUrl}`);

    string|error content = httpGetBodyFull(specUrl);
    if content is error {
        return error(string `Failed to download ${specUrl}: ${content.message()}`);
    }
    log:printInfo(string `  [download] fetched ${content.length()} bytes`);

    string newHash = calculateHash(content);
    log:printInfo(string `  [download] newHash     : ${newHash.substring(0, 16)}...`);

    boolean versionDirExists = check file:test(versionDir, file:IS_DIR);
    log:printInfo(string `  [download] IS_DIR(versionDir) = ${versionDirExists}`);

    if versionDirExists {
        boolean targetExists = check file:test(specFile, file:EXISTS);
        boolean otherExists  = check file:test(otherFile, file:EXISTS);
        boolean metaExistsNow = check file:test(metaFile, file:EXISTS);
        log:printInfo(string `  [download] EXISTS(${fileName})       = ${targetExists}`);
        log:printInfo(string `  [download] EXISTS(${otherFileName})  = ${otherExists}`);
        log:printInfo(string `  [download] EXISTS(.metadata.json)    = ${metaExistsNow}`);

        string? oldHash = ();
        if targetExists {
            string existingContent = check io:fileReadString(specFile);
            oldHash = calculateHash(existingContent);
            log:printInfo(string `  [download] oldHash(${fileName})  : ${(<string>oldHash).substring(0, 16)}...`);
        } else if otherExists {
            string existingContent = check io:fileReadString(otherFile);
            oldHash = calculateHash(existingContent);
            log:printInfo(string `  [download] oldHash(${otherFileName}): ${(<string>oldHash).substring(0, 16)}...`);
        } else {
            log:printInfo(string `  [download] no existing spec file found in version dir`);
        }

        if oldHash is string && !hasContentChanged(oldHash, newHash) {
            log:printInfo(string `  [download] SKIP — content unchanged for ${vendor}/${apiId}@${versionFolder}`);
            return [false, newHash];
        }
        log:printInfo(string `  [download] content changed (or no prior file) — will replace`);

        if targetExists {
            log:printInfo(string `  [download] removing: ${specFile}`);
            check file:remove(specFile);
            log:printInfo(string `  [download] removed ${fileName}`);
        }
        if otherExists {
            log:printInfo(string `  [download] removing: ${otherFile}`);
            check file:remove(otherFile);
            log:printInfo(string `  [download] removed stale ${otherFileName}`);
        }

        log:printInfo(string `  [download] writing new spec (metadata WILL NOT be touched)`);
    } else {
        log:printInfo(string `  [download] version dir does not exist — creating: ${versionDir}`);
        check file:createDir(versionDir, file:RECURSIVE);
        log:printInfo(string `  [download] created dir: ${versionDir}`);

        boolean metaExists = check file:test(metaFile, file:EXISTS);
        log:printInfo(string `  [download] EXISTS(.metadata.json) after createDir = ${metaExists}`);
        if !metaExists {
            log:printInfo(string `  [download] creating .metadata.json`);
            string? baseUrl     = extractSpecBaseUrl(content);
            string? description = extractSpecDescription(content);
            string[] tags       = deriveTags(connectorName, vendor);
            check io:fileWriteString(metaFile, buildMetadataJson(connectorName, baseUrl, sourceUrl, description, tags));
            log:printInfo(string `  [download] created .metadata.json`);
        } else {
            log:printInfo(string `  [download] .metadata.json already exists — skipping creation`);
        }
    }

    log:printInfo(string `  [download] writing spec: ${specFile}`);
    check io:fileWriteString(specFile, content);
    log:printInfo(string `  [download] saved: ${specFile}`);

    return [true, newHash];
}

// ─── Hash helpers ─────────────────────────────────────────────────────────────

function calculateHash(string content) returns string {
    byte[] contentBytes = content.toBytes();
    byte[] hashBytes = crypto:hashSha256(contentBytes);
    return hashBytes.toBase16();
}

isolated function hasContentChanged(string? oldHash, string newHash) returns boolean {
    if oldHash is () || oldHash == "" {
        return true;
    }
    return oldHash != newHash;
}

// ─── Version / path helpers ───────────────────────────────────────────────────

isolated function normalizeVersion(string version) returns string {
    string v = version.trim();
    if v.length() == 0 { return "latest"; }
    if v[0] >= "0" && v[0] <= "9" {
        return "v" + v;
    }
    return v;
}

isolated function deriveVendor(string connectorName) returns string {
    string[] parts = re ` `.split(connectorName);
    if parts.length() > 0 {
        return parts[0].toLowerAscii();
    }
    return connectorName.toLowerAscii();
}

isolated function deriveApiId(string connectorName) returns string {
    string[] parts = re ` `.split(connectorName);
    if parts.length() > 1 {
        string result = "";
        boolean first = true;
        foreach int i in 1 ..< parts.length() {
            if !first { result += "."; }
            result += parts[i].toLowerAscii();
            first = false;
        }
        return result;
    }
    return connectorName.toLowerAscii();
}

// Derives tags from the connector display name (lowercase meaningful words).
isolated function deriveTags(string connectorName, string vendor) returns string[] {
    string[] stopwords = ["api", "rest", "the", "a", "an", "of", "for", "and", "or", "with"];
    string[] tags = [];
    map<boolean> seen = {};

    foreach string word in re ` `.split(connectorName.toLowerAscii()) {
        if word.length() <= 1 { continue; }
        boolean stop = false;
        foreach string sw in stopwords {
            if word == sw { stop = true; break; }
        }
        if !stop && !seen.hasKey(word) {
            seen[word] = true;
            tags.push(word);
        }
    }

    string vendorLower = vendor.toLowerAscii();
    if !seen.hasKey(vendorLower) {
        tags.push(vendorLower);
    }
    return tags;
}

// ─── Metadata generation ──────────────────────────────────────────────────────

function buildMetadataJson(
    string connectorName,
    string? baseUrl,
    string sourceUrl,
    string? description,
    string[] tags
) returns string {
    string tagsJson = buildTagsJson(tags);
    return string `{
    "name": "${jsonEsc(connectorName)}",
    "baseUrl": "${jsonEsc(baseUrl ?: "")}",
    "documentationUrl": "${jsonEsc(sourceUrl)}",
    "description": "${jsonEsc(description ?: "")}",
    "tags": ${tagsJson}
}`;
}

isolated function buildTagsJson(string[] tags) returns string {
    if tags.length() == 0 { return "[]"; }
    string result = "[";
    boolean first = true;
    foreach string tag in tags {
        if !first { result += ", "; }
        result += "\"" + jsonEsc(tag) + "\"";
        first = false;
    }
    return result + "]";
}
