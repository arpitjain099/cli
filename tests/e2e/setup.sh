#!/bin/bash

set -euo pipefail

TEST_NAME="setup file"
TEST_CONFIG_DIR="./temp-config-dir"
DOPPLER_PROJECT=""
DOPPLER_CONFIG=""

cleanup() {
  exit_code=$?
  if [ "$exit_code" -ne 0 ]; then
    echo "ERROR: '$TEST_NAME' tests failed during execution"
    afterAll || echo "ERROR: Cleanup failed"
  fi

  exit "$exit_code"
}
trap cleanup EXIT

beforeAll() {
  echo "INFO: Executing '$TEST_NAME' tests"
  mv doppler.yaml doppler.yaml.bak
}

beforeEach() {
  header
  rm -rf $TEST_CONFIG_DIR
  rm -f doppler.yaml
  cat << EOF > doppler.yaml
setup:
  - project: cli
    config: dev
    path: .
  - project: example
    config: stg
    path: example/
EOF
}

afterEach() {
  footer
}

afterAll() {
  echo "INFO: Completed '$TEST_NAME' tests"
  rm -rf $TEST_CONFIG_DIR
  rm -f doppler.yaml
  mv doppler.yaml.bak doppler.yaml
}

header() {
  echo "========================================="
  echo "EXECUTING: $name"
}

footer() {
  echo "========================================="
}

error() {
  message=$1
  echo "$message"
  exit 1
}

######################################################################

beforeAll

######################################################################
#

name="test legacy doppler.yaml setup file"

beforeEach

# confirm that no projects or configs are set before loading the setup file
actual="$("$DOPPLER_BINARY" configure get project --plain --config-dir=$TEST_CONFIG_DIR)"
expected=""
[[ "$actual" == "$expected" ]] || error "ERROR: unexpected project at scope. expected '$expected', actual '$actual'"

actual="$("$DOPPLER_BINARY" configure get config --plain --config-dir=$TEST_CONFIG_DIR)"
expected=""
[[ "$actual" == "$expected" ]] || error "ERROR: unexpected config at scope. expected '$expected', actual '$actual'"

# test setup using legacy doppler.yaml
cat << EOF > doppler.yaml
setup:
  project: cli
  config: dev
EOF
actual="$("$DOPPLER_BINARY" setup --config-dir=$TEST_CONFIG_DIR --no-interactive)"
[[ "$actual" != "Unable to parse doppler repo config file" ]] || error "ERROR: setup file not parseable"

# confirm correct projects and configs are setup for appropriate scopes
actual="$("$DOPPLER_BINARY" configure get project --plain --config-dir=$TEST_CONFIG_DIR)"
expected="cli"
[[ "$actual" == "$expected" ]] || error "ERROR: unexpected project at scope. expected '$expected', actual '$actual'"

actual="$("$DOPPLER_BINARY" configure get config --plain --config-dir=$TEST_CONFIG_DIR)"
expected="dev"
[[ "$actual" == "$expected" ]] || error "ERROR: unexpected config at scope. expected '$expected', actual '$actual'"

actual="$("$DOPPLER_BINARY" configure get project --plain --scope=./example --config-dir=$TEST_CONFIG_DIR)"
expected="cli"
[[ "$actual" == "$expected" ]] || error "ERROR: unexpected project at scope. expected '$expected', actual '$actual'"

actual="$("$DOPPLER_BINARY" configure get config --plain --scope=./example --config-dir=$TEST_CONFIG_DIR)"
expected="dev"
[[ "$actual" == "$expected" ]] || error "ERROR: unexpected config at scope. expected '$expected', actual '$actual'"

afterEach

######################################################################
#

name="test doppler.yaml setup file with multiple projects & configs"

beforeEach

# confirm that no projects or configs are set before loading the setup file
actual="$("$DOPPLER_BINARY" configure get project --plain --config-dir=$TEST_CONFIG_DIR)"
expected=""
[[ "$actual" == "$expected" ]] || error "ERROR: unexpected project at scope. expected '$expected', actual '$actual'"

actual="$("$DOPPLER_BINARY" configure get config --plain --config-dir=$TEST_CONFIG_DIR)"
expected=""
[[ "$actual" == "$expected" ]] || error "ERROR: unexpected config at scope. expected '$expected', actual '$actual'"

actual="$("$DOPPLER_BINARY" configure get project --plain --scope=./example --config-dir=$TEST_CONFIG_DIR)"
expected=""
[[ "$actual" == "$expected" ]] || error "ERROR: unexpected project at scope. expected '$expected', actual '$actual'"

actual="$("$DOPPLER_BINARY" configure get config --plain --scope=./example --config-dir=$TEST_CONFIG_DIR)"
expected=""
[[ "$actual" == "$expected" ]] || error "ERROR: unexpected config at scope. expected '$expected', actual '$actual'"

# test setup using doppler.yaml with multiple projects and configs
actual="$("$DOPPLER_BINARY" setup --config-dir=$TEST_CONFIG_DIR --no-interactive)"
[[ $(echo "$actual" | grep -c "Auto-selecting project from repo config file") == "2" ]] || error "ERROR: unexpected number of project setups loaded"
[[ $(echo "$actual" | grep -c "Auto-selecting config from repo config file") == "2" ]] || error "ERROR: unexpected number of config setups loaded"
[[ "$actual" != "Unable to parse doppler repo config file" ]] || error "ERROR: setup file not parseable"

# confirm correct projects and configs are setup for appropriate scopes
actual="$("$DOPPLER_BINARY" configure get project --plain --config-dir=$TEST_CONFIG_DIR)"
expected="cli"
[[ "$actual" == "$expected" ]] || error "ERROR: unexpected project at scope. expected '$expected', actual '$actual'"

actual="$("$DOPPLER_BINARY" configure get config --plain --config-dir=$TEST_CONFIG_DIR)"
expected="dev"
[[ "$actual" == "$expected" ]] || error "ERROR: unexpected config at scope. expected '$expected', actual '$actual'"

actual="$("$DOPPLER_BINARY" configure get project --plain --scope=./example --config-dir=$TEST_CONFIG_DIR)"
expected="example"
[[ "$actual" == "$expected" ]] || error "ERROR: unexpected project at scope. expected '$expected', actual '$actual'"

actual="$("$DOPPLER_BINARY" configure get config --plain --scope=./example --config-dir=$TEST_CONFIG_DIR)"
expected="stg"
[[ "$actual" == "$expected" ]] || error "ERROR: unexpected config at scope. expected '$expected', actual '$actual'"

afterEach

######################################################################

name="ensure error displayed if multiple entries are specified without paths"

beforeEach

# test setup file with multiple entries that don't have paths specified
cat << EOF > doppler.yaml
setup:
  - project: cli
    config: dev
  - project: example
    config: dev
EOF
# we disable pipefail specifically inside the subshell since we expect this command to fail
actual="$(set +o pipefail; "$DOPPLER_BINARY" setup --config-dir=$TEST_CONFIG_DIR --no-interactive 2>&1 || true)"
expected="Doppler Error: a path must be specified for all repos when more than one exists in the repo config file (doppler.yaml)"
[[ "$actual" == *"$expected"* ]] || error "ERROR: setup not erroring when paths omitted for multiple entries. expected '$expected', actual '$actual'"

afterEach

######################################################################

name="ensure error displayed if multiple entries use the same path"

beforeEach

# test setup file with multiple entries that don't have paths specified
cat << EOF > doppler.yaml
setup:
  - project: cli
    config: dev
    path: .
  - project: example
    config: dev
    path: .
EOF
# we disable pipefail specifically inside the subshell since we expect this command to fail
actual="$(set +o pipefail; "$DOPPLER_BINARY" setup --config-dir=$TEST_CONFIG_DIR --no-interactive 2>&1 || true)"
expected="Doppler Error: the following path(s) are being used more than once in the repo config file (doppler.yaml):"
[[ "$actual" == *"$expected"* ]] || error "ERROR: setup not erroring when a path is used multiple times. expected '$expected', actual '$actual'"

afterEach

######################################################################

afterAll