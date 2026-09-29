# Pricing 4,400 recipes once instead of on every page view

**Area:** workflow automation · database · performance

## Symptom
Importing about 4,400 recipes from two supermarket recipe sites into the household deals site would have made the recipe page price every recipe against today's offers **on every visit**: about 6 s of CPU and ~20 MB of HTML per page view on a small automation host.

## Investigation
- Pricing is deterministic for a given day's product list, so it only needs to run when prices or recipes change.
- A profiling run with real data put the full pricing at ~7 s of CPU and ~76 MB of memory - fine a few times a day, not per request.

## Fix
- A scheduled job prices every recipe into a table (cost per portion, completeness, calories/macros, the products each recipe can use), and a saved recipe is re-priced on its own in about a second.
- The page reads 24 recipes at a time with SQL filters and sorting; all page queries run in 2–70 ms.
- A later database check showed the job rewriting ~20 MB of recipe cards every run - about 0.5–1 GB of writes a day on SSDs that had already caused trouble. Cards are now rewritten only when they changed, and the job runs three times a day instead of hourly.

## Lesson
Move work to when the data changes, not when someone looks - and after moving it, measure the writes as well as the CPU.
