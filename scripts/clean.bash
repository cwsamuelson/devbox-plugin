#!/usr/bin/env bash
# clean.bash - Script to perform different levels of project cleanup.

# Exit immediately if a command exits with a non-zero status.
set -e

# Array to hold additional targets for cleanup based on mode.
special_targets=()

# Process any leading mode arguments ("ci", "purge", "reset").
while [[ $# -gt 0 ]]; do
  case "$1" in
    clean)
      # When "clean" mode is provided, add build-specific cleanup targets.
      special_targets+=("build" "cmake-*" "site")
      shift
      ;;
    ci)
      # When "ci" mode is provided, add CI-specific cleanup targets.
      special_targets+=(".gitlab-ci-local" "Marksman" "Marksman.tgz" "Marksman.run" "*.gcov" "coverage.*")
      shift
      ;;
    purge)
      # When "purge" mode is provided, add targets to completely remove dependencies/build artifacts.
      special_targets+=(".gitlab-ci-local" "CMakeUserPresets.json" "conan_provider.cmake" "output_final")
      shift
      ;;
    reset)
      # When "reset" mode is provided, add even more aggressive cleanup targets.
      special_targets+=(".venv" ".devbox")
      shift
      ;;
    *)
      # Stop processing mode arguments once a non-mode argument is encountered.
      break
      ;;
  esac
done

# Remaining arguments (if any) are user-specified targets.
user_targets=("$@")

# Combine user targets with the special targets.
actual_targets=("${user_targets[@]}" "${special_targets[@]}")

if [ ${#actual_targets[@]} -eq 0 ]; then
  echo "No clean targets given."
  exit 1
fi

echo "Cleaning the following targets:"
printf "  %s\n" "${actual_targets[@]}"

# Execute the cleanup.
rm -rf "${actual_targets[@]}"

echo "Cleanup complete."

