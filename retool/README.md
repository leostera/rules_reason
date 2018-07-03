# retool

```
retool(1)                        Retool Manual                       retool(1)



NAME
       retool - a monorepo tool for Bazel and ML

SYNOPSIS
       retool COMMAND ...

COMMANDS
       sync
           synchronize dependencies in this workspace

COMMON OPTIONS
       These options are common to all commands.

       --debug
           Give only debug output.

       --help[=FMT] (default=auto)
           Show this help in format FMT. The value FMT must be one of `auto',
           `pager', `groff' or `plain'. With `auto', the format is `pager` or
           `plain' whenever the TERM env var is `dumb' or undefined.

       -q, --quiet
           Suppress informational output.

       -v, --verbose
           Give verbose output.

       --version
           Show version information.

MORE HELP
       Use `retool COMMAND --help' for help on a single command.
EXIT STATUS
       retool exits with the following status:

       0   on success.

       124 on command line parsing errors.

       125 on unexpected internal errors (bugs).

BUGS
       Check bug reports at https://github.com/ostera/rules_reason.



Retool v0.0.1                                                        retool(1)
(END)
```

## retool sync

```
retool-sync(1)                   Retool Manual                  retool-sync(1)



NAME
       retool-sync - synchronize dependencies in this workspace

SYNOPSIS
       retool sync [OPTION]...

 ESCRIPTION
       Synchronizes dependencies in this workspace by looking into
       3rdparty/package.json and 3rdparty/package.opam, downloading the
       necessary files, and verifying the integrity of all the packages.
       Additional BUILD files will be created if needed.

       By passing in the --verify flag, the program will only verify the
       SHA256 in the lock files against the downloaded packages and exit.

OPTIONS
       --verify
           Verify integrity (no synchronization)

       -w DIR, --workdir=DIR (absent=.)
           Run the program in workspace directory DIR.

COMMON OPTIONS
       These options are common to all commands.

       --debug
           Give only debug output.

       --help[=FMT] (default=auto)
           Show this help in format FMT. The value FMT must be one of `auto',
           `pager', `groff' or `plain'. With `auto', the format is `pager` or
           `plain' whenever the TERM env var is `dumb' or undefined.

       -q, --quiet
           Suppress informational output.

       -v, --verbose
           Give verbose output.

       --version
           Show version information.

MORE HELP
       Use `retool COMMAND --help' for help on a single command.
EXIT STATUS
       sync exits with the following status:

       0   on success.

       124 on command line parsing errors.

       125 on unexpected internal errors (bugs).

BUGS
       Check bug reports at https://github.com/ostera/rules_reason.



Retool v0.0.1                                                   retool-sync(1)
(END)
```
