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
    boolean malformed = false;
    string? validationError = ();
|};

// All fields except name and sourceUrl have defaults so that a user can add a
// new entry to openapi_specs.json with just {"name":"…","sourceUrl":"…","connectorRepo":"…"}.
public type ResultEntry record {|
    string name;
    string sourceUrl;
    string? connectorRepo = ();
    string? targetTitle = ();
    string? specUrl = ();
    string? specRepo = ();
    string? apiVersion = ();
    string? format = ();
    string? frequency = "monthly";
    string status = "pending";
    string checkedAt = "";
    decimal elapsedSeconds = 0.0d;
    string? contentHash = ();
    string? validationError = ();
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
