// connectors.bal

//public final Connector[] & readonly ALL_CONNECTORS = [
    // ── Twilio ──────────────────────────────────────────────────────────────
    // ballerinax/twilio  →  Twilio REST API
    //{name: "Twilio",                        docsUrl: "https://www.twilio.com/docs/usage/api",                                                                          targetTitle: ()},

    // ── Google Sheets ────────────────────────────────────────────────────────
    // ballerinax/googleapis.sheets  →  Google Sheets API v4
    //{name: "GoogleAPIs Sheets",             docsUrl: "https://developers.google.com/sheets/api/reference/rest",                                                        targetTitle: ()},

    // ── Twitter ──────────────────────────────────────────────────────────────
    // ballerinax/twitter  →  Twitter v2 API (OpenAPI spec lives in xdevplatform)
    //{name: "Twitter",                       docsUrl: "https://github.com/xdevplatform",                                                                                targetTitle: ()},

    // ── Java JDBC ────────────────────────────────────────────────────────────
    // ballerinax/java.jdbc  →  Jakarta EE JDBC specification (no vendor OpenAPI;
    // JDBC is a Java API, not a REST API with an OpenAPI spec)
    //{name: "Java JDBC",                     docsUrl: "https://docs.oracle.com/en/java/jakarta/specifications/jdbc/",                                                   targetTitle: ()},

    // ── Salesforce ───────────────────────────────────────────────────────────
    // ballerinax/salesforce  →  Salesforce REST API
    //{name: "Salesforce",                    docsUrl: "https://developer.salesforce.com/docs/apis",                                                                     targetTitle: ()},

    // ── MySQL ────────────────────────────────────────────────────────────────
    // ballerinax/mysql  →  MySQL Connector/J (JDBC driver; SQL protocol, no OpenAPI)
    //{name: "MySQL",                         docsUrl: "https://dev.mysql.com/doc/connector-j/en/",                                                                      targetTitle: ()},

    // ── Kafka ────────────────────────────────────────────────────────────────
    // ballerinax/kafka  →  Apache Kafka (binary protocol, not REST/OpenAPI)
    //{name: "Kafka",                         docsUrl: "https://kafka.apache.org/documentation/",                                                                        targetTitle: ()},

    // ── Redis ────────────────────────────────────────────────────────────────
    // ballerinax/redis  →  Redis command reference (RESP protocol, no OpenAPI)
    //{name: "Redis",                         docsUrl: "https://redis.io/docs/latest/commands/",                                                                         targetTitle: ()},

    // ── PostgreSQL ───────────────────────────────────────────────────────────
    // ballerinax/postgresql  →  PostgreSQL docs (JDBC/SQL protocol, no OpenAPI)
    //{name: "PostgreSQL",                    docsUrl: "https://www.postgresql.org/docs/current/",                                                                       targetTitle: ()},

    // ── SAP ──────────────────────────────────────────────────────────────────
    // ballerinax/sap  →  SAP Business Accelerator Hub (OpenAPI specs per service)
    //{name: "SAP",                           docsUrl: "https://api.sap.com/",                                                                                           targetTitle: ()},

    // ── MSSQL ────────────────────────────────────────────────────────────────
    // ballerinax/mssql  →  Microsoft JDBC Driver for SQL Server
    //{name: "MSSQL",                         docsUrl: "https://learn.microsoft.com/en-us/sql/connect/jdbc/microsoft-jdbc-driver-for-sql-server",                        targetTitle: ()},

    // ── Confluent Schema Registry ────────────────────────────────────────────
    // ballerinax/confluent.schemaregistry  →  Schema Registry REST API reference
    //{name: "Confluent Schema Registry",     docsUrl: "https://github.com/confluentinc/schema-registry",                                    targetTitle: ()}

    // ── CDC (Change Data Capture) ────────────────────────────────────────────
    // ballerinax/cdc  →  Debezium documentation (the underlying CDC engine)
    //{name: "CDC",                           docsUrl: "https://debezium.io/documentation/reference/stable/",                                                            targetTitle: ()},

    // ── Confluent Avro SerDes ────────────────────────────────────────────────
    // ballerinax/confluent.cavroserdes  →  Avro SerDes for Confluent Schema Registry
    //{name: "Confluent Avro SerDes",         docsUrl: "https://docs.confluent.io/platform/current/schema-registry/fundamentals/serdes-develop/serdes-avro.html",        targetTitle: ()},

    // ── OpenAI Chat ──────────────────────────────────────────────────────────
    // ballerinax/openai.chat  →  OpenAI Chat Completions API reference
    //{name: "OpenAI Chat",                   docsUrl: "https://platform.openai.com/docs/api-reference/chat",                                                            targetTitle: ()},

    // ── RabbitMQ ─────────────────────────────────────────────────────────────
    // ballerinax/rabbitmq  →  RabbitMQ Management HTTP API
    //{name: "RabbitMQ",                      docsUrl: "https://www.rabbitmq.com/docs/management",                                                                       targetTitle: ()}

    // ── Snowflake ────────────────────────────────────────────────────────────
    // ballerinax/snowflake  →  Snowflake SQL REST API reference
    //{name: "Snowflake",                     docsUrl: "https://docs.snowflake.com/en/developer-guide/sql-api/reference",                                                targetTitle: ()},

    // ── Oracle DB ────────────────────────────────────────────────────────────
    // ballerinax/oracledb  →  Oracle REST Data Services (ORDS) developer guide
    //{name: "Oracle DB",                     docsUrl: "https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/latest/orddg/index.html",                   targetTitle: ()},

    // ── MongoDB ──────────────────────────────────────────────────────────────
    // ballerinax/mongodb  →  MongoDB Atlas Data API resources
    //{name: "MongoDB",                       docsUrl: "https://www.mongodb.com/docs/atlas/api/data-api-resources/",                                                     targetTitle: ()},

    // ── Azure Storage Service ────────────────────────────────────────────────
    // ballerinax/azure_storage_service  →  Azure Storage REST API reference
    //{name: "Azure Storage Service",         docsUrl: "https://learn.microsoft.com/en-us/rest/api/storageservices/",                                                    targetTitle: ()},

    // ── AI OpenAI ────────────────────────────────────────────────────────────
    // ballerinax/ai.openai  →  OpenAI platform API reference
    //{name: "AI OpenAI",                     docsUrl: "https://platform.openai.com/docs/api-reference/introduction",                                                    targetTitle: ()},

    // ── AI Pinecone ──────────────────────────────────────────────────────────
    // ballerinax/ai.pinecone  →  Pinecone Vector Database API reference
    //{name: "AI Pinecone",                   docsUrl: "https://docs.pinecone.io/reference/api/introduction",                                                            targetTitle: ()},

    // ── FHIR ─────────────────────────────────────────────────────────────────
    // ballerinax/health.clients.fhir  →  HL7 FHIR R4 RESTful API specification
    //{name: "FHIR",                          docsUrl: "https://hl7.org/fhir/R4/http.html",                                                                              targetTitle: ()}

    // ── AI Anthropic ─────────────────────────────────────────────────────────
    // ballerinax/ai.anthropic  →  Anthropic Messages API
    //{name: "AI Anthropic",                  docsUrl: "https://docs.anthropic.com/en/api/getting-started",                                                              targetTitle: ()},

    // ── AI Azure ─────────────────────────────────────────────────────────────
    // ballerinax/ai.azure  →  Azure OpenAI Service REST API reference
    //{name: "AI Azure",                      docsUrl: "https://learn.microsoft.com/en-us/azure/ai-services/openai/reference",                                           targetTitle: ()},

    // ── AI Ollama ────────────────────────────────────────────────────────────
    // ballerinax/ai.ollama  →  Ollama REST API docs (GitHub)
    //{name: "AI Ollama",                     docsUrl: "https://github.com/ollama/ollama/blob/main/docs/api.md",                                                         targetTitle: ()},

    // ── AI Mistral ───────────────────────────────────────────────────────────
    // ballerinax/ai.mistral  →  Mistral AI API reference
    //{name: "AI Mistral",                    docsUrl: "https://docs.mistral.ai/api/",                                                                                   targetTitle: ()},

    // ── DeepSeek AI Connector ────────────────────────────────────────────────
    // ballerinax/ai.deepseek  →  DeepSeek API reference
    //{name: "DeepSeek AI Connector",         docsUrl: "https://api-docs.deepseek.com/",                                                                                 targetTitle: ()},

    // ── Stripe ───────────────────────────────────────────────────────────────
    // ballerinax/stripe  →  Stripe API reference
    //{name: "Stripe",                        docsUrl: "https://github.com/stripe/openapi",                                                                                    targetTitle: ()},

    // ── Slack ────────────────────────────────────────────────────────────────
    // ballerinax/slack  →  Slack Web API (OpenAPI spec in slackapi/slack-api-specs)
    //{name: "Slack",                         docsUrl: "https://github.com/slackapi/slack-api-specs",                                                                    targetTitle: ("Slack Web API")}
//];
// connectors.bal
//public final Connector[] & readonly ALL_CONNECTORS = [
    // ✅ Official spec in mistralai/platform-docs-public GitHub repo
    //{name: "Mistral",                docsUrl: "https://github.com/mistralai/platform-docs-public",                                                                              targetTitle: ()},

    // ⚠️  NATS uses a binary/pub-sub protocol — no REST OpenAPI spec exists.
    //     Best available: JSON Schema registry at nats.io/schemas/
    //     Using the official NATS docs page as the closest reference.
    //{name: "NATS",                   docsUrl: "https://docs.nats.io/reference/reference-protocols/nats_api_reference",                                                                                            targetTitle: ()},

    // ✅ Official spec in AWS SDK repo (converted from Smithy/JSON to OpenAPI by APIs-guru/aws2openapi)
    //    SNS uses a query-over-HTTP protocol; best available OpenAPI spec is via APIs-guru
    //{name: "AWS SNS",                docsUrl: "https://docs.aws.amazon.com/sns/latest/api/welcome.html",                                               targetTitle: ()},

    // ✅ Official spec via APIs-guru (converted from AWS SDK Smithy model)
    //{name: "AWS SQS",                docsUrl: "https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-working-with-apis.html",                                               targetTitle: ()},

    // ✅ Official Weaviate OpenAPI spec (schema.json in the main repo)
    //{name: "AI Weaviate",            docsUrl: "https://docs.weaviate.io/weaviate/model-providers/openai",                                                                               targetTitle: ()},

    // ✅ OneDrive is part of Microsoft Graph API — official OpenAPI spec from msgraph-metadata
    //{name: "Microsoft OneDrive",     docsUrl: "https://learn.microsoft.com/en-us/onedrive/developer/rest-api/getting-started/?view=odsp-graph-online",                                                              targetTitle: ()},

    // ✅ Official Trello OpenAPI spec published by Atlassian
    //{name: "Trello",                 docsUrl: "https://developer.atlassian.com/cloud/trello/rest/api-group-actions/",                                                                                                     targetTitle: ()},

    // ✅ Official spec via APIs-guru (converted from AWS SDK Smithy model — Redshift Data API)
    //{name: "AWS Redshift",           docsUrl: "https://docs.aws.amazon.com/redshift/latest/mgmt/data-api.html",                                     targetTitle: ()},

    // ✅ Official Solace PubSub+ Cloud Mission Control OpenAPI spec
    //{name: "Solace",                 docsUrl: "https://api.solace.dev/cloud/page/openapi-specifications",                                                                                                         targetTitle: ()},

    // ✅ Official Asana OpenAPI spec from the Asana/openapi GitHub repo
    //{name: "Asana",                  docsUrl: "https://github.com/Asana/openapi",                                                                                       targetTitle: ()},

    // ⚠️  SCIM 2.0 is an IETF protocol standard (RFC 7643/7644), not a single vendor's API.
    //     No single canonical OpenAPI spec — using Okta's SCIM 2.0 spec as the most widely
    //     adopted reference implementation.
    //{name: "SCIM",                   docsUrl: "https://developer.okta.com/docs/api/openapi/okta-scim/guides/scim-20",                                                                                             targetTitle: ()},

    // ✅ Official PayPal Orders v2 OpenAPI spec from paypal/paypal-rest-api-specifications
   // {name: "PayPal Orders",          docsUrl: "https://developer.paypal.com/docs/api/orders/v2/",                                                     targetTitle: ()},

    // ⚠️  IBM MQ REST API spec is served at runtime by the MQ web server (Liberty/WLP).
    //     No static publicly downloadable file — using the official IBM Cloud docs as reference.
    //{name: "IBM MQ",                 docsUrl: "https://www.ibm.com/docs/en/ibm-mq/latest?topic=api-rest-reference",                                                                                               targetTitle: ()},

    // ✅ Official spec via APIs-guru (converted from AWS SDK Smithy model)
    //{name: "AWS Secret Manager",     docsUrl: "https://aws.amazon.com/secrets-manager/",                                    targetTitle: ()}
//];
// connectors.bal
// Connector registry for the updated set of 15 connectors.
//
// docsUrl = the official API / spec documentation page for that connector.
//           This is what the agent fetches to discover the spec URL.
//
// targetTitle = only set for multi-spec pages where one docs URL
//               hosts several different specs.
//
// Notes on challenging connectors:
//   Java JMS         — JMS is a Java messaging standard (javax.jms / jakarta.jms),
//                      not a REST API. There is no public OpenAPI/REST spec. The
//                      closest authoritative reference is the Jakarta EE JMS spec page.
//                      LLM strategy must generate or approximate a connector from the
//                      spec rather than fetching a ready-made OpenAPI document.
//   HL7              — HL7's REST-capable standard is FHIR. docsUrl points to the
//                      canonical FHIR RESTful API reference on hl7.org.
//   OpenRouter AI Gateway — "AI Gateway" variant refers to Cloudflare's AI Gateway
//                      proxy for OpenRouter; "OpenRouter" is the direct OpenRouter API.
//   WSO2 API Manager Catalog — targets the Service Catalog v1 sub-API within APIM.

//public final Connector[] & readonly ALL_CONNECTORS = [

    // ── Messaging (non-REST standard) ─────────────────────────────────────────
    // NOTE: Java JMS has no public OpenAPI/REST spec; the docsUrl below points
    // to the Jakarta Messaging 3.1 specification. LLM strategy must synthesize
    // the connector from the spec rather than fetching an OpenAPI document.
    //{name: "Java JMS", docsUrl: "https://jakarta.ee/specifications/messaging/3.1/", targetTitle: ()},

    // ── Azure AI Search ───────────────────────────────────────────────────────
    // "Azure AI Search Index" covers the data-plane (index / query) operations.
    // "Azure AI Search" covers the management-plane (service administration) API.
    //{name: "Azure AI Search Index", docsUrl: "https://learn.microsoft.com/en-us/rest/api/searchservice/",    targetTitle: ()},
    //{name: "Azure AI Search",       docsUrl: "https://learn.microsoft.com/en-us/rest/api/searchmanagement/", targetTitle: ()},

    // ── AI Routing ────────────────────────────────────────────────────────────
    // "OpenRouter AI Gateway" = Cloudflare AI Gateway proxy in front of OpenRouter.
    // "OpenRouter" = the direct OpenRouter unified-LLM API.
    //{name: "OpenRouter AI Gateway", docsUrl: "https://developers.cloudflare.com/ai-gateway/usage/providers/openrouter/", targetTitle: ()},
    //{name: "OpenRouter",            docsUrl: "https://openrouter.ai/docs/api/reference/overview",                        targetTitle: ()},

    // ── WSO2 API Manager ──────────────────────────────────────────────────────
    // "WSO2 API Manager Catalog" targets the Service Catalog v1 REST API.
    //{name: "WSO2 API Manager Catalog", docsUrl: "https://apim.docs.wso2.com/en/latest/reference/product-apis/service-catalog-apis/service-catalog-v1/service-catalog-v1/", targetTitle: ()},

    // ── Google Cloud Messaging ────────────────────────────────────────────────
    //{name: "Google Cloud Pub/Sub", docsUrl: "https://cloud.google.com/pubsub/docs/reference/rest", targetTitle: ()},

    // ── Healthcare Interoperability ───────────────────────────────────────────
    // NOTE: HL7 FHIR is the REST standard published by HL7. The docsUrl below
    // is the canonical FHIR RESTful API interaction reference (R5, current release).
   // {name: "HL7", docsUrl: "https://www.hl7.org/fhir/http.html", targetTitle: ()},

    // ── Project Management ────────────────────────────────────────────────────
    //{name: "Jira", docsUrl: "https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/", targetTitle: ()},

    // ── AI / Google Cloud ─────────────────────────────────────────────────────
    //{name: "AI GoogleAPIs Vertex", docsUrl: "https://cloud.google.com/vertex-ai/docs/reference/rest", targetTitle: ()},

    // ── Nonprofit Data ────────────────────────────────────────────────────────
    // Candid hosts multiple specs under one docs URL; targetTitle selects the right one.
    //{name: "Candid", docsUrl: "https://developer.candid.org/reference/openapi", targetTitle: ()},

    // ── Document Signing ──────────────────────────────────────────────────────
    //{name: "DocuSign eSign API", docsUrl: "https://developers.docusign.com/docs/esign-rest-api/", targetTitle: ()},

    // ── AI / OpenAI ───────────────────────────────────────────────────────────
    // "OpenAI Audio" covers the /audio/* endpoints (speech, transcription, translation).
    //{name: "OpenAI Audio", docsUrl: "https://platform.openai.com/docs/api-reference/audio", targetTitle: ()},

    // ── Email Marketing ───────────────────────────────────────────────────────
    //{name: "Mailchimp Transactional", docsUrl: "https://mailchimp.com/developer/transactional/api/", targetTitle: ()},

    // ── HubSpot CRM ───────────────────────────────────────────────────────────
    // "HubSpot CRM Associations" covers both v3 and v4 association detail endpoints.
    //{name: "HubSpot CRM Associations", docsUrl: "https://developers.hubspot.com/docs/api/crm/associations", targetTitle: ()}
//];

// connectors.bal
// Connector registry for the updated set of 15 connectors.
//
// docsUrl = the official API / spec documentation page for that connector.
//           This is what the agent fetches to discover the spec URL.
//
// targetTitle = only set for multi-spec pages where one docs URL
//               hosts several different specs.
//
// Notes on challenging connectors:
//   AWS Marketplace MPE  — "MPE" = AWS Marketplace Metering and Entitlement API
//                          (Metering Service, used by sellers to submit usage data).
//   AWS Marketplace MPM  — "MPM" = AWS Marketplace Management Portal / Catalog API
//                          (management-plane for managing products and offers).
//   Guidewire InsNow     — The InsuranceNow API reference requires a Guidewire
//                          partner/customer account for full access. The docsUrl
//                          points to the public Guidewire developer API page for
//                          InsuranceNow; the LLM strategy must authenticate or
//                          approximate from the public-facing spec.
//   Salesforce MC        — "Salesforce Marketingcloud" maps to Salesforce Marketing
//                          Cloud Engagement REST API on developer.salesforce.com.

//public final Connector[] & readonly ALL_CONNECTORS = [

    // ── HubSpot CRM ───────────────────────────────────────────────────────────
    // "HubSpot CRM Obj Contacts" covers the v3 CRM Contacts object endpoints.
    //{name: "HubSpot CRM Obj Contacts", docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()},

    // ── AWS Marketplace ───────────────────────────────────────────────────────
    // "AWS Marketplace MPE" = Metering and Entitlement (Metering Service API).
    // "AWS Marketplace MPM" = Management Portal / Catalog API (seller management plane).
    //{name: "AWS Marketplace MPE", docsUrl: "https://docs.aws.amazon.com/marketplace/latest/APIReference/API_Operations_AWSMarketplace_Metering.html", targetTitle: ()},
    //{name: "AWS Marketplace MPM", docsUrl: "https://docs.aws.amazon.com/marketplace/latest/APIReference/welcome.html",                                 targetTitle: ()},

    // ── Content Management ────────────────────────────────────────────────────
    //{name: "Alfresco", docsUrl: "https://docs.alfresco.com/content-services/latest/develop/rest-api-guide/", targetTitle: ()},

    // ── AI / OpenAI ───────────────────────────────────────────────────────────
    // "OpenAI Fine-Tunes" covers the /v1/fine_tuning/* endpoints (fine-tuning jobs).
    // "OpenAI" covers the full OpenAI REST API reference (all endpoints).
    //{name: "OpenAI Fine-Tunes", docsUrl: "https://platform.openai.com/docs/api-reference/fine-tuning", targetTitle: ()},
    //{name: "OpenAI",            docsUrl: "https://platform.openai.com/docs/api-reference/introduction", targetTitle: ()},

    // ── Messaging / Community ─────────────────────────────────────────────────
    //{name: "Discord", docsUrl: "https://discord.com/developers/docs/reference", targetTitle: ()},

    // ── Document Signing ──────────────────────────────────────────────────────
    // "DocuSign Click" covers the Click API (elastic template / clickwrap consent).
    //{name: "DocuSign Click", docsUrl: "https://developers.docusign.com/docs/click-api/", targetTitle: ()},

    // ── HubSpot Marketing ─────────────────────────────────────────────────────
    //{name: "HubSpot Marketing Emails",       docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection",      targetTitle: ()},
    //{name: "HubSpot Marketing Forms",        docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection",                     targetTitle: ()},
    //{name: "HubSpot Marketing Transactional",docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection",  targetTitle: ()},

    // ── HubSpot CRM ───────────────────────────────────────────────────────────
    // "HubSpot CRM Import" covers the CRM Imports v3 endpoints.
    //{name: "HubSpot CRM Import", docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()}

    // ── Payments ──────────────────────────────────────────────────────────────
    // "PayPal Payments" covers the Payments v2 REST API (authorize, capture, refund).
    //{name: "PayPal Payments", docsUrl: "https://developer.paypal.com/docs/api/payments/v2/", targetTitle: ()},

    // ── Insurance Platform ────────────────────────────────────────────────────
    // NOTE: Guidewire InsuranceNow API access requires a Guidewire partner or
    // customer account. The docsUrl points to the public InsuranceNow API page.
    // LLM strategy should consult the public reference and authenticate as needed.
    //{name: "Guidewire Insnow", docsUrl: "https://www.guidewire.com/Developers/APIs/InsuranceNow-APIs", targetTitle: ()},

    // ── Marketing Automation ──────────────────────────────────────────────────
    // "Salesforce Marketingcloud" targets the Marketing Cloud Engagement REST API.
    //{name: "Salesforce Marketingcloud", docsUrl: "https://developer.salesforce.com/docs/marketing/marketing-cloud/guide/rest-api-overview.html", targetTitle: ()}
//];

// connectors.bal
// Connector registry for the updated set of 15 connectors.
//
// docsUrl = the official API / spec documentation page for that connector.
//           This is what the agent fetches to discover the spec URL.
//
// targetTitle = only set for multi-spec pages where one docs URL
//               hosts several different specs.
//
// Notes on HubSpot connectors:
//   All HubSpot connectors use the HubSpot public API spec collection on GitHub
//   as their docsUrl, since individual reference pages are generated from these
//   OpenAPI specs:
//     https://github.com/HubSpot/HubSpot-public-api-spec-collection
//
// Notes on Zoom Scheduler:
//   Uses the official Zoom Developer Docs REST API reference for the
//   Scheduler product:
//     https://developers.zoom.us/docs/api/rest/zoom-scheduler-api/

//public final Connector[] & readonly ALL_CONNECTORS = [

    // ── HubSpot CRM Extensions ────────────────────────────────────────────────
    // "HubSpot CRM Extensions Timelines" covers the CRM Timeline Extensions API
    // (custom timeline events on CRM records).
    //{name: "HubSpot CRM Extensions Timelines", docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()},

    // ── HubSpot Marketing ─────────────────────────────────────────────────────
    //{name: "HubSpot Marketing Events",       docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()},
    //{name: "HubSpot Marketing Campaigns",    docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()},
    //{name: "HubSpot Marketing Subscriptions",docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()},

    // ── HubSpot CRM Engagements ───────────────────────────────────────────────
    //{name: "HubSpot CRM Engagements Email", docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()},
    //{name: "HubSpot CRM Engagement Notes",  docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()},

    // ── HubSpot CRM Lists ─────────────────────────────────────────────────────
    //{name: "HubSpot CRM Lists", docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()},

    // ── HubSpot CRM Commerce ──────────────────────────────────────────────────
    //{name: "HubSpot CRM Commerce Carts",     docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()},
    //{name: "HubSpot CRM Commerce Discounts", docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()},

    // ── HubSpot CRM Properties ────────────────────────────────────────────────
    //{name: "HubSpot CRM Properties", docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()},

    // ── HubSpot CRM Objects ───────────────────────────────────────────────────
    //{name: "HubSpot CRM Obj Companies", docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()},
    //{name: "HubSpot CRM Obj Deals",     docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()},
    //{name: "HubSpot CRM Obj Feedback",  docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()},
    //{name: "HubSpot CRM Obj Tickets",   docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()},

    // ── Video Conferencing / Scheduling ───────────────────────────────────────
    // "Zoom Scheduler" covers the Zoom Scheduler REST API (scheduling links,
    // event types, and appointments integrated with Zoom Meetings and calendars).
    //{name: "Zoom Scheduler", docsUrl: "https://developers.zoom.us/docs/api/rest/zoom-scheduler-api/", targetTitle: ()}
//];

// connectors.bal
// Connector registry for the updated set of 15 connectors.
//
// docsUrl = the official API / spec documentation page for that connector.
//           This is what the agent fetches to discover the spec URL.
//
// targetTitle = only set for multi-spec pages where one docs URL
//               hosts several different specs.
//
// Notes on HubSpot connectors:
//   All HubSpot connectors use the HubSpot public API spec collection on GitHub
//   as their docsUrl, since individual reference pages are generated from these
//   OpenAPI specs:
//     https://github.com/HubSpot/HubSpot-public-api-spec-collection
//
// Notes on other connectors:
//   SAP Commerce Webservices — Uses the SAP Business Accelerator Hub API
//                              reference for Commerce Webservices (OCC v2).
//   Zoom Meetings            — Uses the official Zoom Developer Docs REST API
//                              reference for the Meetings product.
//   Mailchimp Marketing      — Uses the official Mailchimp Developer API
//                              reference for the Marketing API v3.

//public final Connector[] & readonly ALL_CONNECTORS = [

    // ── HubSpot CRM Objects ───────────────────────────────────────────────────
    //{name: "HubSpot CRM Obj Products",  docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()},
    //{name: "HubSpot CRM Obj Schemas",   docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()},
    //{name: "HubSpot CRM Obj Lineitems", docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()},
    //{name: "HubSpot CRM Obj Leads",     docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()},

    // ── SAP Commerce ──────────────────────────────────────────────────────────
    // "SAP Commerce Webservices" covers the OCC (Omni Commerce Connect) v2
    // REST API on the SAP Business Accelerator Hub.
    //{name: "SAP Commerce Webservices", docsUrl: "https://api.sap.com/api/commerce_services/resource", targetTitle: ()},

    // ── HubSpot CRM Pipelines ─────────────────────────────────────────────────
    //{name: "HubSpot CRM Pipelines", docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()},

    // ── Video Conferencing ────────────────────────────────────────────────────
    // "Zoom Meetings" covers the Zoom Meetings REST API endpoints (create,
    // update, list, and manage meetings and their settings).
    //{name: "Zoom Meetings", docsUrl: "https://developers.zoom.us/docs/api/meetings/", targetTitle: ()},

    // ── HubSpot CRM Commerce ──────────────────────────────────────────────────
    //{name: "HubSpot CRM Commerce Quotes", docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()},
    //{name: "HubSpot CRM Commerce Orders", docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()},
    //{name: "HubSpot CRM Commerce Taxes",  docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()},

    // ── HubSpot CRM Engagements ───────────────────────────────────────────────
    //{name: "HubSpot CRM Engagements Communications", docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()},

    // ── Email Marketing ───────────────────────────────────────────────────────
    // "Mailchimp Marketing" covers the Mailchimp Marketing API v3 (audiences,
    // campaigns, automations, reports, and related resources).
    //{name: "Mailchimp Marketing", docsUrl: "https://mailchimp.com/developer/marketing/api/", targetTitle: ()},

    // ── HubSpot CRM Associations ──────────────────────────────────────────────
    //{name: "HubSpot CRM Associations Schema", docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()},

    // ── HubSpot CRM Engagements ───────────────────────────────────────────────
    //{name: "HubSpot CRM Engagements Tasks", docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()},

    // ── HubSpot CRM ───────────────────────────────────────────────────────────
    //{name: "HubSpot CRM Owners", docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()}
//];

// connectors.bal
// Connector registry for the updated set of 9 connectors.
//
// docsUrl = the official API / spec documentation page for that connector.
//           This is what the agent fetches to discover the spec URL.
//
// targetTitle = only set for multi-spec pages where one docs URL
//               hosts several different specs.
//
// Notes on HubSpot connectors:
//   All HubSpot connectors use the HubSpot public API spec collection on GitHub
//   as their docsUrl, since individual reference pages are generated from these
//   OpenAPI specs:
//     https://github.com/HubSpot/HubSpot-public-api-spec-collection
//
// Notes on other connectors:
//   Smartsheet          — Uses the official Smartsheet Developer Portal API
//                         reference at developers.smartsheet.com/api.
//   PayPal Invoices     — Uses the PayPal Developer Docs REST API reference
//                         for the Invoicing v2 API.
//   PayPal Subscriptions— Uses the PayPal Developer Docs REST API reference
//                         for the Subscriptions v1 API.
//   Elastic Cloud       — Uses the official Elastic docs page for the
//                         Elastic Cloud REST API (hosted/ESS).
//   Epic FHIR           — Uses the Epic on FHIR developer portal at fhir.epic.com,
//                         which hosts all FHIR R4 API specifications.
//   Cerner FHIR         — Uses the official Oracle Health Millennium Platform
//                         FHIR R4 API reference documentation.
//   AthenaHealth FHIR   — Uses the official athenahealth Developer Portal
//                         FHIR APIs documentation page.

public final Connector[] & readonly ALL_CONNECTORS = [

    // ── HubSpot CRM Engagements ───────────────────────────────────────────────
    // "HubSpot CRM Engagements Calls" covers the Calls engagement object endpoints.
    //{name: "HubSpot CRM Engagements Calls", docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()},

    // ── Project Management ────────────────────────────────────────────────────
    // "Smartsheet" covers the full Smartsheet REST API v2 (sheets, rows,
    // columns, reports, users, and more).
    //{name: "Smartsheet", docsUrl: "https://developers.smartsheet.com/api/smartsheet/introduction", targetTitle: ()}

    // ── HubSpot CRM Extensions ────────────────────────────────────────────────
    // "HubSpot CRM Extensions Videoconferencing" covers the Video Conferencing
    // Extension API for embedding video links in CRM meetings.
    //{name: "HubSpot CRM Extensions Videoconferencing", docsUrl: "https://github.com/HubSpot/HubSpot-public-api-spec-collection", targetTitle: ()},

    // ── Payments ──────────────────────────────────────────────────────────────
    // "PayPal Invoices" covers the Invoicing v2 REST API (create, send, track
    // and manage invoices and payment records).
    // "PayPal Subscriptions" covers the Subscriptions v1 REST API (plans,
    // subscriptions, billing cycles, and trial periods).
    //{name: "PayPal Invoices",       docsUrl: "https://developer.paypal.com/docs/api/invoicing/v2/",     targetTitle: ()},
    //{name: "PayPal Subscriptions",  docsUrl: "https://developer.paypal.com/docs/api/subscriptions/v1/", targetTitle: ()},

    // ── Search / Observability ────────────────────────────────────────────────
    // "Elastic Cloud" covers the Elastic Cloud REST API (hosted Elasticsearch
    // Service): create/manage deployments, traffic filters, extensions, etc.
    //{name: "Elastic Cloud", docsUrl: "https://www.elastic.co/docs/api/doc/cloud/", targetTitle: ()},

    // ── Healthcare / FHIR ─────────────────────────────────────────────────────
    // "Epic FHIR" covers the Epic on FHIR R4 API specifications available at
    // the official Epic developer portal (fhir.epic.com).
    // "Cerner FHIR" covers the Oracle Health Millennium Platform FHIR R4 APIs
    // (formerly Cerner Ignite APIs).
    // "AthenaHealth FHIR" covers the athenahealth FHIR R4 APIs available via
    // the athenahealth Developer Portal.
    //{name: "Epic FHIR",        docsUrl: "https://fhir.epic.com/Specifications",        targetTitle: ()},
    //{name: "Cerner FHIR",      docsUrl: "https://docs.oracle.com/en/industries/health/millennium-platform-apis/mfrap/r4_overview.html", targetTitle: ()},
    //{name: "AthenaHealth FHIR",docsUrl: "https://docs.athenahealth.com/api/docs/fhir-apis", targetTitle: ()}
    {name: "Stripe", docsUrl: "https://stripe.com/docs/api", targetTitle: ()},
    {name: "Salesforce Marketing Cloud", docsUrl: "https://developer.salesforce.com/docs/marketing/marketing-cloud/guide/apis-overview?utm_source", targetTitle: ()}

];
