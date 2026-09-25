# A silently ignored API filter during a forward-auth rollout

**Area:** SSO · Authentik · automation

## Symptom
While rolling forward-auth out to more than a dozen services, the first service provisioned fine. Later ones failed several steps on with a confusing conflict error that seemed unrelated.

## Investigation
Treated the vague earlier error as a symptom to trace back to its source, not something to retry past.

## Root cause
An API endpoint accepted a filter parameter identical to one on a sibling endpoint, but silently ignored it and returned the whole unfiltered list instead of an error. Every service after the first "found" the first service's config and reused it instead of creating its own.

## Fix
Switched to the parameter that actually filters on that endpoint.

## Lesson
An API that silently ignores a parameter is worse than one that errors on it. When a later step fails in a confusing way, check what the earlier steps actually returned.
