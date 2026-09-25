# Designing patch automation that respects IaC

**Area:** automation · configuration management

## Problem
Patching live systems can quietly drift from what the code says. A future rebuild would then redeploy the old version and undo the patch.

## Analysis
- Most services don't pin a version in their Ansible config. Patching them live and re-running the role later gives the same result: no drift.
- A few services **do** pin an exact version tag. Patching those live without updating and committing the pinned value creates silent drift.

## Fix
The patching automation checks which case applies before it decides how to apply an update, instead of patching everything the same way.

## Lesson
The code, not the running fleet, is the source of truth. Automation that changes the fleet has to know when it also needs to change the code.
