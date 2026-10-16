# Security telemetry and incident routing review

A read-only audit examined live SIEM configuration, security and vulnerability indices, enrolled agents, scheduled maintenance scripts, availability monitoring and 61 workflow definitions.

Default SSH brute-force rules, file integrity, rootcheck, security configuration assessment and package vulnerability detection were enabled. Security data was actively indexed. However, policy documents describing broad security review did not match the actual scheduled pipeline, which primarily processed availability incidents. No dependable scheduled SIEM security/CVE-to-incident notification route was found. A reachable dashboard also did not independently establish manager health.

Coverage gaps included missing endpoint enrollments, threat-indicator lookup lists not loading (causing some rules to be skipped), repetitive noisy events and no configured automatic response. Comprehensive application and firewall security-log coverage was not demonstrated. A home-automation PC companion is not an endpoint security agent. Vulnerability records need vendor, package and exposure validation; raw host/package counts are not successful exploits or unique exploitable CVEs.

Priorities: independently monitor security-stack health and expected agent coverage; build deterministic incident routing with deduplication and retries; add daily vulnerability/coverage review; repair indicator rules and validate with offline synthetic logs; expand relevant security-log collection; investigate and tune noise. Automatic blocking should follow separate allowlist and recovery planning.

No detection, firewall or notification configuration was changed by this audit. Historical documentation was corrected to distinguish configured collection from verified operational alerting.

References: [Vulnerability detection](https://documentation.wazuh.com/current/user-manual/capabilities/vulnerability-detection/how-it-works.html), [Active response](https://documentation.wazuh.com/current/user-manual/capabilities/active-response/), [Security configuration assessment](https://documentation.wazuh.com/current/user-manual/capabilities/sec-config-assessment/index.html).
