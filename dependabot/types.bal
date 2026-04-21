public type Connector record {|
    string name;
    string sourceUrl;
    string? targetTitle;
|};

public type SpecResult record {|
    string specUrl;
    string? specRepo;
    string? apiVersion;
    string format;
|};

// All fields except name and sourceUrl have defaults so that a user can add a
// new entry to openapi_specs.json with just {"name":"…","sourceUrl":"…"}.
public type ResultEntry record {|
    string name;
    string sourceUrl;
    string? targetTitle = ();
    string? specUrl = ();
    string? specRepo = ();
    string? apiVersion = ();
    string? format = ();
    string? frequency = "daily";
    string status = "pending";
    string checkedAt = "";
    decimal elapsedSeconds = 0.0d;
    string? contentHash = ();
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
