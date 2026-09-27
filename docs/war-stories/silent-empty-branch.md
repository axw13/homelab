# A "stuck" job that had quietly finished

**Area:** workflow automation · AI inference gateway

## Symptom
Meal-plan generations on the household deals site sat at "running" indefinitely. It looked like the AI inference gateway behind it was hanging, and that gateway had shown real timeouts earlier the same day.

## Investigation
- The workflow engine was responsive (other requests were served normally during the "hang"), its database had no long-running or blocked queries, and the engine's process was idle - so nothing was actually waiting.
- The gateway was given per-request logging *on arrival* (previously it logged only on completion or error). With that in place, a fresh reproduction showed the request **never reached the gateway at all**.
- Running the workflow's generated candidate-product SQL by hand returned zero rows in about a second.

## Root cause
A profile preference meaning "all stores" was being passed into the query as a literal store name, filtering out every product. The workflow engine doesn't run the next step of a branch when a step outputs zero items, so the job simply ended - after the web request had already been answered and the job recorded as "running". Nothing ever marked it finished.

## Fix
- The "all stores" value now means no store filter.
- An explicit empty-result branch fails the job with a message telling the user to widen their filters.
- A watchdog marks any job still "running" after 10 minutes as failed.
- The gateway keeps its arrival logging, gained a status endpoint listing in-flight requests, and now allows two concurrent requests instead of one.

## Lesson
"Stuck" and "silently finished" look identical from outside. Log at the point a request is *received*, not only when it completes, so you can tell which side of a boundary a job died on - and treat an empty result as a state to handle, not an impossibility.
