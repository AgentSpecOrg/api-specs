// downloader.bal
// Downloads a verified spec from its URL and saves it to the correct openapi/ folder.
//
// Folder layout: {openApiDir}/{vendor}/{apiId}/{versionFolder}/openapi.{ext}
//                {openApiDir}/{vendor}/{apiId}/{versionFolder}/.metadata.json
//
// Version folder logic:
//   - If the version folder already exists and the file exists:
//       compare hashes — overwrite only if content changed.
//   - If the version folder does not exist:
//       create it, write the spec and a minimal .metadata.json.
//   - A version folder name that doesn't start with "v" and begins with a digit
//       gets a "v" prefix (e.g., "3.0" → "v3.0").
//   - If apiVersion is nil or empty, "latest" is used as the folder name.

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
    string? title,
    string? apiVersion,
    string vendor,
    string apiId,
    string openApiDir,
    string? existingHash
) returns [boolean, string]|error {

    string versionFolder = normalizeVersion(apiVersion ?: "");
    string fileName = format == "json" ? "openapi.json" : "openapi.yaml";

    string specDir    = string `${openApiDir}/${vendor}/${apiId}`;
    string versionDir = string `${specDir}/${versionFolder}`;
    string specFile   = string `${versionDir}/${fileName}`;
    string metaFile   = string `${versionDir}/.metadata.json`;

    log:printInfo(string `  [download] fetching: ${specUrl}`);
    string|error content = httpGetBodyFull(specUrl);
    if content is error {
        return error(string `Failed to download ${specUrl}: ${content.message()}`);
    }

    string newHash = calculateHash(content);

    boolean versionDirExists = check file:test(versionDir, file:EXISTS);

    if versionDirExists {
        boolean fileExists = check file:test(specFile, file:EXISTS);
        if fileExists {
            if !hasContentChanged(existingHash, newHash) {
                log:printInfo(string `  [download] no change: ${vendor}/${apiId}@${versionFolder}`);
                return [false, newHash];
            }
            log:printInfo(string `  [download] content changed — overwriting: ${specFile}`);
        } else {
            log:printInfo(string `  [download] new file in existing version dir: ${specFile}`);
        }
    } else {
        log:printInfo(string `  [download] creating version dir: ${versionDir}`);
        check file:createDir(versionDir, file:RECURSIVE);
        check io:fileWriteString(metaFile, buildMetadataJson(title ?: apiId, specUrl));
    }

    check io:fileWriteString(specFile, content);
    log:printInfo(string `  [download] saved: ${specFile}`);

    return [true, newHash];
}

// Calculates SHA-256 hash of content as lowercase hex.
function calculateHash(string content) returns string {
    byte[] contentBytes = content.toBytes();
    byte[] hashBytes = crypto:hashSha256(contentBytes);
    return hashBytes.toBase16();
}

// Returns true when content hash has changed (or no previous hash exists).
isolated function hasContentChanged(string? oldHash, string newHash) returns boolean {
    if oldHash is () || oldHash == "" {
        return true;
    }
    return oldHash != newHash;
}

// Normalises an apiVersion string into a safe folder name.
isolated function normalizeVersion(string version) returns string {
    string v = version.trim();
    if v.length() == 0 { return "latest"; }
    // Prepend "v" when version starts with a digit
    if v[0] >= "0" && v[0] <= "9" {
        return "v" + v;
    }
    return v;
}

// Derives a vendor slug from a connector display name (first word, lowercase).
isolated function deriveVendor(string connectorName) returns string {
    string[] parts = re ` `.split(connectorName);
    if parts.length() > 0 {
        return parts[0].toLowerAscii();
    }
    return connectorName.toLowerAscii();
}

// Derives an API id from a connector display name
// (all words after the first, dot-joined and lowercased).
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

// Builds a minimal .metadata.json for a newly created spec folder.
function buildMetadataJson(string name, string specUrl) returns string {
    return string `{
    "name": "${jsonEsc(name)}",
    "specUrl": "${jsonEsc(specUrl)}"
}`;
}
