# A third-party Docker image with a broken dependency tree

**Area:** containers · debugging

## Symptom
The container started cleanly: login worked and registration with its upstream API worked. It then went into a crash loop on an internal null-reference error.

## Investigation
- Checked the root-cause theory with a targeted debug patch rather than guessing.
- Ruled out permissions with a raw API call that bypassed the client library entirely.

## Root cause
Two conflicting versions of the same internal library were installed side by side in the image.

## Fix
Built a corrected image from source with the dependency tree pinned to a single consistent version.

## Lesson
A clean startup doesn't mean the build is sound. Confirm a theory with a small, targeted experiment before rebuilding anything.
