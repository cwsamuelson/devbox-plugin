#!/usr/bin/env bash
#
# build.bash - Data-driven script to select a Conan profile based on provided
# compiler, version, and build type, with default values and support for docker build.
#
# Supported compilers: gcc (default), clang, msvc.
# Default versions: gcc: 14, clang: 19, msvc: 142.
# Supported build types: Release (default), Debug.
#
# Usage examples:
#   ./scripts/build.bash gcc             -> Release-gcc-14
#   ./scripts/build.bash gcc 13          -> Release-gcc-13
#   ./scripts/build.bash 13 gcc          -> Release-gcc-13
#   ./scripts/build.bash debug clang 18  -> Debug-clang-18
#   ./scripts/build.bash 13              -> Defaults to gcc, i.e. Release-gcc-13
#   ./scripts/build.bash docker ...      -> Runs docker build with forwarded args.

# Configurable variables:

# Valid compilers and default.
valid_compilers=("gcc" "clang" "msvc")
default_compiler="gcc"

# Valid versions for each compiler.
declare -A valid_versions
valid_versions["gcc"]="14 13"
valid_versions["clang"]="19 18"
valid_versions["msvc"]="142"

# Default version for each compiler.
declare -A default_versions
default_versions["gcc"]="14"
default_versions["clang"]="19"
default_versions["msvc"]="142"

# Valid build types and default.
valid_build_types=("release" "debug")
default_build_type="debug"

special_builds=("docker" "docs")

# End of configuration.

set -e

# Initialize variables.
compiler=""
version=""
build_type="$default_build_type"
special_build=false
special_type=""
other_args=()

# Helper function: check if string is a number.
is_number() {
  [[ $1 =~ ^[0-9]+$ ]]
}

# Helper function: check if an element is in an array.
in_array() {
  local needle="$1"
  shift
  for element in "$@"; do
    if [[ "$element" == "$needle" ]]; then
      return 0
    fi
  done
  return 1
}

# Process each argument.
while [[ $# -gt 0 ]]; do
  arg="$1"
  # Check for special docker command.
  if in_array "$arg" "${special_builds[@]}"; then
    special_build=true
    special_type=$arg
  # Check if argument is a valid compiler.
  elif in_array "$arg" "${valid_compilers[@]}"; then
    if [[ -n "$compiler" && "$compiler" != "$arg" ]]; then
      echo "Error: Multiple compilers specified: '$compiler' and '$arg'"
      exit 1
    fi
    compiler="$arg"
  # Check if argument is a valid build type (case insensitive).
  elif in_array "${arg,,}" "${valid_build_types[@]}"; then
    # Convert to proper case.
    arg=${arg,,}
    build_type=${arg}
  # Check if argument is a number (i.e. a version).
  elif is_number "$arg"; then
    if [[ -n "$version" && "$version" != "$arg" ]]; then
      echo "Error: Multiple versions specified: '$version' and '$arg'"
      exit 1
    fi
    version="$arg"
  else
    other_args+=( "$arg" )
  fi
  shift
done

# If docker build is requested, run docker build with any remaining arguments.
if $special_build; then
  if [[ $special_type == "docker" ]]; then
    echo "Running Docker build with arguments: ${other_args[*]}"
    docker build -f docker/Dockerfile.builder -t base-builder docker . "${other_args[@]}"
    exit 0
  elif [[ $special_type == "docs" ]]; then
    echo "Running documentation build with arguments: ${other_args[*]}"
    echo Docs build not implemented
    exit 1
  fi
fi

# Default to default_compiler if no compiler was specified.
if [[ -z "$compiler" ]]; then
  compiler="$default_compiler"
fi

# Set default version if not provided.
if [[ -z "$version" ]]; then
  version="${default_versions[$compiler]}"
fi

# Validate that the specified version is allowed for the chosen compiler.
valid_version_found=false
for ver in ${valid_versions[$compiler]}; do
  if [[ "$ver" == "$version" ]]; then
    valid_version_found=true
    break
  fi
done

if ! $valid_version_found; then
  echo "Error: Unsupported $compiler version '$version'. Supported versions: ${valid_versions[$compiler]}"
  exit 1
fi

# Construct the profile name.
profile="${build_type^}-${compiler}-${version}"
echo "Using Conan profile: $profile"

# Build profile path to build with
profile_path="profiles/$profile"
echo Looking for $profile_path
if [[ ! -f $profile_path ]]; then
  echo $profile_path not found
  exit 1
fi

# Run conan build with the constructed profile and forward any additional arguments.
conan build . -pr:a "$profile_path" "${other_args[@]}"

