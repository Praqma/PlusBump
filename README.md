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

```
PlusBump 1.3

Usage:
  ./plusbump.rb --latest=<tag-glob> [<semver_version_string>] [options]
  ./plusbump.rb <ref>               [<semver_version_string>] [options]
  ./plusbump.rb -h|--help

Options:
  -h --help        Show this screen.
  -t --tag-commit  Actually tag HEAD with the version number computed.

  -l --latest=<tag-glob>

    Specify a glob pattern to search for last matching tag instead of
    providing a specific ref.
    Will attempt to use everything after <tag-glob> as the version string
    so be sure to provide _entire_ prefix.
    E.g. use "R_" if your versions are "R_1.2.3"

  -p --prefix=<prefix>

    Specify a prefix to add before the resulting version string

  -s --special=<postfix>

    Specify the "special" part of the resulting version string.
    This is any  part of the version string that comes after the dash,
    e.g. in 1.3.4-SNAPSHOT it is the string "SNAPSHOT".
    Note this is for the "output" side.
    PlusBump will accept any special string on the input and preserve it,
    unless you specify `--special=""` or something else.

  -a --majorpattern=<major_pattern>

    Specify an alternative (regex) pattern that indicates a major version bump.
    E.g. --majorpattern='\+major'

  -i --minorpattern=<minor_pattern>

    Specify an alternative (regex) pattern that indicates a minor version bump.
    E.g. --minorpattern='\+minor'
```


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
