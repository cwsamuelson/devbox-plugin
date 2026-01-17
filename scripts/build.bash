#! /usr/bin/env bash

ROOT=${CPP_TEST_DIR:-${DEVBOX_PROJECT_ROOT:-${DEVENV_PROJECT_ROOT:-pwd}}}

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

# 3 primary arguments:
# build type
# compiler
# compiler version
# their position doesn't matter, and they are all optional
# declare possible values, and their defaults
build_types=("Debug" "Release" "Fuzz" "Python")
#! @TODO MSVC
compilers=("gcc" "clang")
gcc_versions=("16" "15" "14" "13")
clang_versions=("21" "20" "19" "18")
msvc_versions=( "26" "22" "19" )

default_build=${build_types[0]}
default_compiler=${compilers[0]}
# default version set once chosen compiler is determined

args=("$@")

# For each optional argument, we must sort the arrays and pass them to `comm` to find common values
# Then the result of `comm` is used to determine if there was an argument match.  if there was, we shift it off the arg list

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
profile_name=${build_type^}-$compiler-$version
echo "Searching for profile ($profile_name)"
echo "Checking $ROOT/profiles"
if [[ ! -f $profile_path ]]; then
  conan_home=$(conan config home)
  echo "Checking $conan_home"

  if [[ ! -f $conan_home/profiles/$profile_name ]]; then
    echo $profile_name not found
    exit 1
  else
    # when it's in the conan home profile list, the whole path isn't necessary
    profile_path="$profile_name"
  fi
else
  profile_path="$ROOT/profiles/$profile_name"
fi

# Build
conan build -pr:a $profile_path $@ .
