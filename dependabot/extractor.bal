// extractor.bal
// Extracts title and apiVersion from a spec's content (JSON or YAML).
// Primary path: proper YAML/JSON parsing via ballerina/data.yaml and data.jsondata.
// Fallback path: line-by-line regex scan when parsing fails.

import ballerina/data.jsondata;
import ballerina/data.yaml;
import ballerina/log;

// Extracts [title, apiVersion] from spec content.
// Either value may be nil if extraction fails.
function extractSpecMetadata(string content) returns [string?, string?] {
    string? title = ();
    string? apiVersion = ();

    do {
        string trimmedContent = content.trim();
        boolean isJson = trimmedContent.startsWith("{") || trimmedContent.startsWith("[");

        json parsedData = {};

        if isJson {
            json|error jsonResult = jsondata:parseString(content);
            if jsonResult is error {
                log:printDebug(string `  [extract] JSON parsing failed: ${jsonResult.message()}, falling back to regex`);
                string|error ver = extractApiVersionWithRegex(content);
                if ver is string { apiVersion = ver; }
                return [title, apiVersion];
            }
            parsedData = jsonResult;
        } else {
            json|error yamlResult = yaml:parseString(content);
            if yamlResult is error {
                log:printDebug(string `  [extract] YAML parsing failed: ${yamlResult.message()}, falling back to regex`);
                string|error ver = extractApiVersionWithRegex(content);
                if ver is string { apiVersion = ver; }
                return [title, apiVersion];
            }
            parsedData = yamlResult;
        }

        if parsedData is map<json> {
            json? infoField = parsedData["info"];
            if infoField is map<json> {
                json? titleField = infoField["title"];
                if titleField is string { title = titleField; }

                json? versionField = infoField["version"];
                if versionField is string {
                    apiVersion = versionField;
                } else if versionField is int {
                    apiVersion = versionField.toString();
                } else if versionField is decimal {
                    apiVersion = versionField.toString();
                } else if versionField is float {
                    apiVersion = versionField.toString();
                }
            }
        }
    } on fail error e {
        log:printDebug(string `  [extract] metadata extraction failed: ${e.message()}`);
    }

    return [title, apiVersion];
}

// Fallback: regex-based line-by-line scan for version.
function extractApiVersionWithRegex(string content) returns string|error {
    string[] lines = re `\n`.split(content);
    boolean inInfoSection = false;

    foreach string line in lines {
        string trimmedLine = line.trim();

        // JSON format: "version": "1.0"
        if trimmedLine.startsWith("\"version\":") || trimmedLine.startsWith("'version':") {
            string[] parts = re `:`.split(trimmedLine);
            if parts.length() >= 2 {
                string versionValue = parts[1].trim();
                versionValue = removeQuotes(versionValue);
                versionValue = re `,`.replaceAll(versionValue, "").trim();
                if versionValue.length() > 0 {
                    return versionValue;
                }
            }
        }

        // YAML format: inside info: block
        if trimmedLine == "info:" {
            inInfoSection = true;
            continue;
        }

        if inInfoSection {
            // Exit info section if we hit a top-level key
            if !line.startsWith(" ") && !line.startsWith("\t") && trimmedLine != "" && !trimmedLine.startsWith("#") {
                break;
            }

            if trimmedLine.startsWith("version:") {
                string[] parts = re `:`.split(trimmedLine);
                if parts.length() >= 2 {
                    string versionValue = parts[1].trim();
                    versionValue = removeQuotes(versionValue);
                    return versionValue;
                }
            }
        }
    }

    return error("Could not extract API version from spec using regex");
}

isolated function removeQuotes(string s) returns string {
    string trimmed = s.trim();
    if trimmed.length() >= 2 {
        if (trimmed.startsWith("\"") && trimmed.endsWith("\"")) ||
           (trimmed.startsWith("'") && trimmed.endsWith("'")) {
            return trimmed.substring(1, trimmed.length() - 1).trim();
        }
    }
    return trimmed;
}
