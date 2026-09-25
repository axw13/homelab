# Three distinct bugs behind one "timeout" symptom

**Area:** AI inference gateway · workflow automation

## Symptom
After a burst of automated testing, several workflows that depend on an internal AI-inference gateway were failing with vague timeout/unavailable errors.

## Root causes (three separate bugs)
1. **Quota counted on acceptance.** The gateway's shared rate limit counts a request as soon as it is *accepted*, not when it finishes. A few oversized, slow calls used up the hourly budget for everything else long before any of them actually failed.
2. **Mismatched timeouts.** The caller's timeout was shorter than the gateway's, so a caller could give up and move on while the gateway kept processing (and billing) the abandoned request. Found by comparing the two configured values directly instead of assuming they matched.
3. **Stale scheduler timer.** A workflow scheduler's short-interval trigger kept firing on an old interval through several reconfigurations. The cause was an in-memory timer that normal start/stop didn't clear; only a full process restart did. Confirmed by cross-referencing execution timestamps against the process's own restart time.

## Fix
Each bug was fixed at its own cause.

## Lesson
One symptom can hide several unrelated bugs. Keep investigating after the first plausible cause.
