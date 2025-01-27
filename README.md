# Purpose
Establish a 'standard', common environment for my C++ Projects.  I may want to modularize this slightly to handle things like CMake vs Meson.

# Features
Provide a set of tools, variables and scripts to aide in building and testing a C++ project, while attempting to maintain and demonstrate best practices.

This of course reflects my own idioms and patterns as well.

## Tools
- GCC
- CMake
- Ninja
- Conan
- gitlab-ci-local
- Doxygen
- MkDocs
- MkDoxy
- cloc

## Environment Variables
- PROFILE_DIR: .devbox/virtenv/CPP_TEST/profiles
Directory of core set of profiles
- SCRIPT_DIR: .devbox/virtenv/CPP_TEST/scripts
Directory of core set of scripts

# Scripts
## Argument Forwarding
Some of the available scripts will forward unused arguments to the underlying implementations.  Here are the scripts, with the tool it's being forwarded to.
- build: conan build
- line-report: cloc
- ci: gitlab-ci-local
- purge: rm
- reset: rm
## Functions
- build
  Uses conan to build the project.  Accepts 3 arguments, and forwards the rest provided.  Here's the list of arguments and possible values:
  - build type: Debug, Release
  - Compiler: GCC, Clang
  - Compiler Version: GCC14, GCC13, Clang18, Clang19
- test
> [note] UNIMPLEMENTED
  Run all available tests.
  - Unit
  - Regression
  - Fuzzing
  - Mutation
- line-report
  Use cloc to report source line numbers by file type, but only those checked into git.
- ci
  Run the GitLab CI pipeline locally, using gitlab-ci-local.  Assums a docker volume called `personal_conan_cache` exists containing a conan2 cache with any necessary packages that can't be retrieved by remote.  Makes plugins from this plugin available in the container in `/profiles`.
- purge
  Remove all non-source files, except for environment files
- reset
  Removes all non-source files, including environment files like .devbox and .venv

# TODO
- [ ] docs
- [ ] CI
- [ ] devcontainer
- [ ] modularize for different toolchains
  - [ ] CMake/Meson
  - [ ] Documentation toolchains (RST? AsciiDoc?)
  - [ ] Others?
- [ ] setup private conan remote

# Contributing
If you have any ideas, you can create an issue.
If you have suggested code changes, create a pull request.

## Contributors
At this time I am the only contributor. Feel free to provide a PR or issue with ideas or changes!

# Copyright
© 2024 Chris Samuelson. All rights reserved.

# [Licensing](https://choosealicense.com/licenses/gpl-3.0/)
This project is licensed under the [GPLv3](https://www.gnu.org/licenses/gpl-3.0-standalone.html).

If you are interested in using this code under a different license agreement, please feel free to reach out to me; I am
open to discussing alternative agreements on a case-by-case basis.

[LGPL](https://choosealicense.com/licenses/lgpl-3.0/), [MIT](https://choosealicense.com/licenses/mit/),
and [Apache2.0](https://choosealicense.com/licenses/apache-2.0/) licenses are reasonable alternatives, but must be
negotiated with me directly.

