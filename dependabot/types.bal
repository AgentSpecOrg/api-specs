public type Connector record {|
    string name;
    string docsUrl;
    string? targetTitle;
|};

public type SpecResult record {|
    string specUrl;
    string? specRepo;
    string? title;
    string? apiVersion;
    string format;
|};

public type ResultEntry record {|
    string name;
    string docsUrl;
    string? targetTitle;
    string? specUrl;
    string? specRepo;
    string? title;
    string? apiVersion;
    string? format;
    string status;
    string checkedAt;
    decimal elapsedSeconds;
|};

// NEW: output of the discovery step
public type DiscoveryResult record {|
    string[] candidateUrls;   // raw downloadable URLs to try
    string? specRepo;         // github owner/repo if found
    string discoveryMethod;   // "known_url_valid" | "github" | "direct" | "none"
|};

// NEW: output of the verification step
public type VerifyResult record {|
    string specUrl;
    string? specRepo;
    string format;
    string openApiVersion;    // e.g. "3.0.3"
    string apiVersion;        // from info.version
|};
