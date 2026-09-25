# An "invalid auth" error that wasn't about credentials

**Area:** home automation · integrations

## Symptom
A camera integration that had just been migrated to the new network kept failing intermittently with "invalid auth".

## Investigation
The credentials were correct. Looked at device-level settings outside the account/password.

## Root cause
A device-level "third-party API compatibility" toggle had been silently switched back off when the device rejoined the network. It's a separate setting from the account and device password.

## Fix
Turned the toggle back on.

## Lesson
"Authentication failed" doesn't always mean the credentials are wrong.
