#! /bin/bash

# Copyright (C) 2020 Google Inc.
#
# This file has been licensed under Apache 2.0 license.  Please see the LICENSE
# file at the root of the repository.

set -e

# Bad: this is guessing the path of this binary.
readonly _gotopt2_runfiles_path="rules_multitool++multitool+multitool/tools/gotopt2/gotopt2"

# This magic was copied from runfiles by consulting:
#   https://stackoverflow.com/questions/53472993/how-do-i-make-a-bazel-sh-binary-target-depend-on-other-binary-targets

# --- begin runfiles.bash initialization ---
# Copy-pasted from Bazel's Bash runfiles library (tools/bash/runfiles/runfiles.bash).
set -eo pipefail
if [[ ! -d "${RUNFILES_DIR:-/dev/null}" && ! -f "${RUNFILES_MANIFEST_FILE:-/dev/null}" ]]; then
  if [[ -f "$0.runfiles_manifest" ]]; then
    export RUNFILES_MANIFEST_FILE="$0.runfiles_manifest"
  elif [[ -f "$0.runfiles/MANIFEST" ]]; then
    export RUNFILES_MANIFEST_FILE="$0.runfiles/MANIFEST"
  elif [[ -f "$0.runfiles/bazel_tools/tools/bash/runfiles/runfiles.bash" ]]; then
    export RUNFILES_DIR="$0.runfiles"
  fi
fi
if [[ -f "${RUNFILES_DIR:-/dev/null}/bazel_tools/tools/bash/runfiles/runfiles.bash" ]]; then
  source "${RUNFILES_DIR}/bazel_tools/tools/bash/runfiles/runfiles.bash"
elif [[ -f "${RUNFILES_MANIFEST_FILE:-/dev/null}" ]]; then
  source "$(grep -m1 "^bazel_tools/tools/bash/runfiles/runfiles.bash " \
            "$RUNFILES_MANIFEST_FILE" | cut -d ' ' -f 2-)"
else
  echo >&2 "ERROR: cannot find @bazel_tools//tools/bash/runfiles:runfiles.bash"
  exit 1
fi
# --- end runfiles.bash initialization ---

readonly _gotopt_binary="$(rlocation ${_gotopt2_runfiles_path})"

# Exit quickly if the binary isn't found. This may happen if the binary location
# moves internally in bazel.
if [ -x "$(command -v ${_gotopt2_binary})" ]; then
  echo "gotopt2 binary not found"
  exit 240
fi

GOTOPT2_OUTPUT=$($_gotopt_binary "${@}" <<EOF
flags:
- name: "vhdl-standard"
  type: string
  default: "2002"
  help: "the VHDL language standard to use"
- name: "cmd"
  type: string
  default: "-e"
  help: "the NVC command to use (e.g. -e=elaborate)"
- name: "nvc-binary-path"
  type: string
  help: "The path to the NVC binary"
- name: "entity"
  type: string
  help: "The name of the entity to elaborate"
- name: "library-paths"
  type: string
  help: "A long string (including spaces) containing the library mappings"
- name: "stdlib-dir"
  type: string
  help: "The directory where the standard VHDL library resides"
- name: "library-name"
  type: string
  help: "The library name to elaborate into"
- name: "library-dir-in-path"
  type: string
  help: "The path to the library directory"
- name: "library-dir-out-path"
  type: string
  help: "The path to the library directory"
EOF
)
if [[ "$?" == "11" ]]; then
  # When --help option is used, gotopt2 exits with code 11.
  exit 1
fi

# Evaluate the output of the call to gotopt2, shell vars assignment is here.
eval "${GOTOPT2_OUTPUT}"

# Exit if required parameters are not present.
if [[ "${gotopt2_nvc_binary_path}" == "" ]]; then
  echo "--nvc-binary-path flag is required"
  exit 1
fi

if [[ "${gotopt2_library_name}" == "" ]]; then
  echo "--library-name flag is required"
  exit 1
fi

if [[ "${gotopt2_entity}" == "" ]]; then
  echo "--entity flag is required"
  exit 1
fi

if [[ "${gotopt2_stdlib_dir}" == "" ]]; then
  echo "--stdlib-dir flag is required"
  exit 1
fi

if [[ "${gotopt2_library_dir_in_path}" == "" ]]; then
  echo "--library-dir-in-path flag is required"
  exit 1
fi

if [[ "${gotopt2_library_dir_out_path}" == "" ]]; then
  echo "--library-dir-out-path flag is required"
  exit 1
fi


# NVC really wants to write to library directories.  Bazel does not allow that,
# so the middle ground is to make a copy. That's horrible but here we are.
if [[ "${gotopt2_library_dir_in_path}" \
      != "${gotopt2_library_dir_out_path}" ]]; then
  cp --recursive --dereference \
    "${gotopt2_library_dir_in_path}" \
    "${gotopt2_library_dir_out_path}"
  chmod a+rw --recursive "${gotopt2_library_dir_out_path}"
fi

# The NVC conventions around directory naming don't interact
# well with bazel
readonly _nvc_lib_path="${gotopt2_library_dir_out_path}/${gotopt2_library_name}/${gotopt2_library_name}"

"${gotopt2_nvc_binary_path}" \
  --std="${gotopt2_vhdl_standard}" \
  -L "${gotopt2_stdlib_dir}/nvc" \
  ${gotopt2_library_paths} \
  --work="${gotopt2_library_name}:${_nvc_lib_path}" \
  "${gotopt2_cmd}" "${gotopt2_entity}" \
  ${gotopt2_args__[@]}

