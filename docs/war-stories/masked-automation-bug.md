# An automation bug hidden by a lenient error handler

**Area:** Ansible · secrets management

## Symptom
A role that writes a generated credential into the secrets manager failed, but only at a later step, and that step didn't point at the real problem.

## Investigation
Compared the role with the equivalent roles elsewhere in the codebase. An earlier check step in the same role had a permissive error-tolerance flag. It had silently absorbed the same underlying connectivity failure and reported success.

## Root cause
The role was missing the "run this on the controller, not the target host" directive that every equivalent role had. The target host can't reach the secrets manager.

## Fix
Added the missing directive, matching the other roles. (The pattern is shown in [`examples/ansible/roles/vault_secret`](../../examples/ansible/roles/vault_secret/tasks/main.yml).)

## Lesson
A deliberately lenient error handler on one step can hide a real problem that only shows up further down.
