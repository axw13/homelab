# Adding Codex alongside Claude

The homelab automation now supports both Codex and Claude without duplicating
scheduled jobs. Existing maintenance policies, scoped Vault authentication,
locks, workflow identifiers, and schedules remain in place.

The maintenance wrappers use a provider adapter. It passes the existing CLI
arguments through to Claude, or runs Codex and converts its event stream into
the same result and token-usage contract. A provider switch affects future
runs; the selected provider is pinned for each maintenance run.

For workflow automation, a separate Codex text bridge runs alongside the
existing Claude bridge in the isolated application container. It uses an
unprivileged service account, has no fleet SSH keys or Vault role, and disables
shell tools, patching, apps, subagents, and web search. Requests have bounded
concurrency, an hourly call limit, and a timeout that terminates the process
group. Authentication uses a Vault-managed bearer credential.

The provider command verifies a harmless authenticated generation from the
workflow engine's actual network path before changing any workflow URLs.
It snapshots the previous definitions privately, preserves activation states,
re-registers triggers, and verifies the resulting live definitions. Four
additional reusable Codex workflows offer explicit decision and summarization
choices without adding schedules or public webhooks.

Codex uses the operator's ChatGPT subscription. No API billing fallback is
configured. Token counts are recorded with the actual model; dollar cost is
unknown and stored as null. Report usage and data provenance follow the model
that actually produced the result instead of a hardcoded provider label.

Validation included 12 regression tests, a live application-compatible webhook,
both original and added reusable decision/summarization workflows, maintenance
credential inheritance, and actual token rows in the existing usage database.
A switch-back check also surfaced an existing Claude organization access
restriction; the unavailable provider was left intact and the working Codex
provider remained selected.

The implementation was checked against the installed CLI and the official
[non-interactive documentation](https://learn.chatgpt.com/docs/non-interactive-mode)
and [configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference).
