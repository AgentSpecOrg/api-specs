public type Connector record {|
    string name;
    string sourceUrl;
    string? targetTitle;
    string? vendor = ();
    string? apiId = ();
|};

public type SpecResult record {|
    string specUrl;
    string? specRepo;
    string? apiVersion;
    string format;
|};

public type ResultEntry record {|
    string name;
    string sourceUrl;
    string? targetTitle;
    string? specUrl;
    string? specRepo;
    string? apiVersion;
    string? format;
    string? frequency;
    string status;
    string checkedAt;
    decimal elapsedSeconds;
    string? contentHash;
|};

// Output of the discovery step
public type DiscoveryResult record {|
    string[] candidateUrls;   // raw downloadable URLs to try
    string? specRepo;         // github owner/repo if found
    string discoveryMethod;   // "known_url_valid" | "github" | "direct" | "none"
|};

// Output of the verification step
public type VerifyResult record {|
    string specUrl;
    string? specRepo;
    string format;
    string openApiVersion;    // e.g. "3.0.3"
    string apiVersion;        // from info.version
|};
