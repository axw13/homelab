# Retiring an unused application completely

The operator permanently retired the unused Mealie service on 7 October 2026.
Its deployment instructions were replaced with a retirement record, and the
active overview, service list, network documentation and agent onboarding were
updated. Historical incident records remain historical records.

The reviewed, saved Terraform plan deleted only the retired application module:
the container, its generated passwords and its Vault secret resource. The apply
created or changed no other resources. The container, datasets, snapshots and
application-specific backup archives were verified absent afterwards. Shared
historical backups and Git history were retained.

The application was removed from the declared infrastructure inventory, Ansible
role and playbook, exporter targets, proxy sites, DNS records, SSO declarations
and active recovery runbooks. This prevents routine deployment or recovery from
recreating the retired service.

Live cleanup removed its proxy route, DNS record, SSO application/provider and
outpost membership, uptime and synthetic checks, monitoring host, security agent,
asset inventory and all versions of its application-specific Vault secrets.
Changes to shared services were checked against the original configuration so
unrelated records, providers and monitors remained intact. No dashboard entry
existed for this application.

Verification included Terraform validation, affected Ansible syntax checks,
proxy configuration validation before reload, API read-back of deletions, DNS
checks and a real HTTPS request to an unrelated application. All 35 remaining
guests were running. The outage incident was resolved as an intentional service
retirement rather than a recovered outage. Firewall configuration remains
operator-managed; any obsolete alias membership is a separate manual step.

Agent onboarding also now reports the actual fleet size and distinguishes
Vault-backed read-only firewall access from the human-only configuration policy.
