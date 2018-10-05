---
maintainer: jkrag
---
# Automatic version bumping

### Initial "requirement" description

Look at all commits between <ref> and HEAD.

Look for commit-message mentions of +major or +minor (unless different patterns where specified ). +patch is implicit as the default if none of the others where specified.

If a version string was specified, bump the provided semver string correctly.
I.e. increase the highest bumped level, and reset those below to 0.

Currently, the bump leaves any part of semver after `-` intact (e.g. 1.3.14-alpha3+as34df32), but I reserve the right to change my mind on this :-D

If no version string was specified bump the version 0.0.0, i.e. return either 1.0.0, 0.1.0 or 0.0.1

### Other features
The tool already supports a few more features:

### Helping users
If you decide to require bumps on every commit (e.g. instead of assuming +patch as default), then it can be very helpful to users set up a push hook (pre-receive on Git) that rejects commits without a bump.

I have successfully done this on BitBucket using the "Jira Hooks for BitBucket" plugin (that we were using anyway), and used the following regex:
```
(^|(.|\n)*\s)\+(major|minor|patch)($|\s(.|\n)*)
```

This RegEx should also be quite usable in other plugins or handwritten hooks as it does not require multiline or other switches to be supported.
It allows the `+bump` message to appear anywhere in the commit message as long as it is not adjacent to other text. (i.e. `my+patch` and `+patching` will be rejected.


## CodeScene analysis
[![](https://codescene.io/projects/2928/status.svg) Get more details at **codescene.io**.](https://codescene.io/projects/2928/jobs/latest-successful/results)
=======
### Developer guide

#### How to test

Simply run `rake` for the simple test without output, and `rake doc` for the more verbose output. Test are located in the `spec` folder. 

