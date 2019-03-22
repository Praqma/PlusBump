module PlusBump
  DOCOPT  = <<DOCOPT
PlusBump - the tool for all your version bumping needs.
It uses the SemVer gem for parsing existing versions, and uses Rugged/Libgit2 for the git operations.

Usage:
  plusbump -h|--help
  plusbump --version
  plusbump --from-ref <ref> --base-version=<semver> [options]
  plusbump --from-tag <glob> --base-version=<semver> [--new-prefix=<new-prefix>] [--create-tag] [options]
  plusbump --from-tag <glob> --base-version-from-tag=<strip-prefix> [--new-prefix=<new-prefix>] [--create-tag] [options]

Options:
  -h --help                               Show this screen.
  --version                               Shows current version of PlusBump
  -d --debug                              Debug flag

  --from-ref <ref>                        Specify a git ref (tree'ish) to use as start of commit interval.
                                          PlusBump will search for bump declarations from HEAD back to, but not including this ref.

  --from-tag <glob>                       Specify a glob pattern (same as git tag -l <pattern>). PlusBump will find the latest tag matching this pattern
                                          and use as the start of commit interval to analyse.

  --base-version=<semver>                 Take semver version as argument and use as base for computed new version
  --base-version-from-tag=<strip-prefix>  Find semver base version from the found tag. Optionally strip a prefix (e.g. "R_"). [default: ""]


  --new-prefix=<new-prefix>               Optionally specify a prefix for the output computed SemVer. (e.g. "R_", or "WOULD_BE_").

  --create-tag                            PlusBump tags the HEAD commit with the computed new SemVer (incl. optional prefix). This will not do a "git push".

  --patch-pattern=<pattern>               Specify regex pattern for bumping patch version
  --minor-pattern=<pattern>               Specify regex pattern for bumping minor version
  --major-pattern=<pattern>               Specify regex pattern for bumping major version
DOCOPT

end