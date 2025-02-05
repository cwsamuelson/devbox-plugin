#! /usr/bin/env bash

# build docs

PLUGIN_ROOT=${CPP_TEST_DIR:-${DEVBOX_PROJECT_ROOT:-.}}
PROJECT_ROOT=${DEVBOX_PROJECT_ROOT:-.}

if [ ! -z "$1" -a "$#" -eq 1 -a "$1" == "docker" ]; then
  docker build -f ${PLUGIN_ROOT}/docker/Dockerfile.builder -t base-builder ${PLUGIN_ROOT}/docker
  #docker build -f ${PLUGIN_ROOT}/docker/Dockerfile.runtime -t base-runtime ${PLUGIN_ROOT}/docker
  exit
fi

if [ ! -z "$1" -a "$#" -eq 1 -a "$1" == "docs" ]; then
  mkdocs build --no-directory-urls -f $PROJECT_ROOT/mkdocs.yml
  exit
fi

typeofvar () {
    local type_signature=$(declare -p "$1" 2>/dev/null)

    if [[ "$type_signature" =~ "declare --" ]]; then
        printf "string"
    elif [[ "$type_signature" =~ "declare -a" ]]; then
        printf "array"
    elif [[ "$type_signature" =~ "declare -A" ]]; then
        printf "map"
    else
        printf "none"
    fi
}

#! @TODO validate the combinatorics of all these..
# probably by writing a build_all script?

# 4 primary arguments:
# build 'kind': build/create
# build type
# compiler
# compiler version
# their position doesn't matter, and they are all optional
# declare possible values, and their defaults
build_kinds=("build" "create")
build_types=("Debug" "Release" "Fuzz" "Python")
#! @TODO MSVC
compilers=("gcc" "clang")
gcc_versions=("14" "13")
clang_versions=("19" "18")

default_kind=${build_kinds[0]}
default_build=${build_types[0]}
default_compiler=${compilers[0]}
# default version calculated later, once chosen compiler is determined

args=("$@")

# For each optional argument, we must sort the arrays and pass them to `comm` to find common values
# Then the result of `comm` is used to determine if there was an argument match.  if there was, we shift it off the arg list

# this one is sorta required
# Parse for build kind
comm_result=`comm -12 <(echo "${args[@]}" | tr '[:upper:]' '[:lower:]' | tr ' ' '\n' | sort) <(echo "${build_kinds[@]}" | tr '[:upper:]' '[:lower:]' | tr ' ' '\n' | sort)`
build_kind=${comm_result:-$default_kind}

if [ ! -z "$comm_result" ]; then
  shift 1
fi

# Parse for build type
comm_result=`comm -12 <(echo "${args[@]}" | tr '[:upper:]' '[:lower:]' | tr ' ' '\n' | sort) <(echo "${build_types[@]}" | tr '[:upper:]' '[:lower:]' | tr ' ' '\n' | sort)`
build_type=${comm_result:-$default_build}

if [ ! -z "$comm_result" ]; then
  shift 1
fi

# Parse for compiler
comm_result=`comm -12 <(echo "${args[@]}" | tr '[:upper:]' '[:lower:]' | tr ' ' '\n' | sort) <(echo "${compilers[@]}" | tr '[:upper:]' '[:lower:]' | tr ' ' '\n' | sort)`
compiler=${comm_result:-$default_compiler}

if [ ! -z "$comm_result" ]; then
  shift 1
fi

# Parse for compiler version
array_name=${compiler}_versions
# use inderiction to grab the array we want to reference
# don't forget that eval is an opportunity for code injection
# I, naively, believe the risk is minimal in this case
version_array=($(eval echo \${$array_name[*]}))
default_version=${version_array[0]}
comm_result=`comm -12 <(echo "${args[@]}" | tr '[:upper:]' '[:lower:]' | tr ' ' '\n' | sort) <(echo "${version_array[@]}" | tr '[:upper:]' '[:lower:]' | tr ' ' '\n' | sort)`
version=${comm_result:-$default_version}

if [ ! -z "$comm_result" ]; then
  shift 1
fi


# Build profile path to build with
profile_path="${PLUGIN_ROOT}/profiles/${build_type^}-${compiler}-${version}"
echo looking for $profile_path
if [[ ! -f $profile_path ]]; then
  echo $profile_path not found
  exit 1
fi

# Build
conan $build_kind -pr:a $profile_path $@ .

