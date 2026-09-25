# Dry-running the disaster-recovery procedure

**Area:** backup · disaster recovery

## Problem
Having backups doesn't prove a restore works. The only way to know was to write the recovery procedure and actually run it.

## What happened
Wrote a step-by-step DR runbook that assumes the reader has no prior context, then dry-ran it end to end. It surfaced real problems that only appear during an actual restore:
- a stale process lock
- orphaned backup data left behind by an interrupted run

## Fix
Documented both gotchas and their resolution in the runbook.

## Lesson
Trust the restore, not the fact that backups exist. Problems like stale locks and leftovers from interrupted runs only show up when you actually restore.
