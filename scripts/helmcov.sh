#!/bin/bash
set -e
set -o pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHART_PATH="${CHART_PATH:-charts/clickstack}"
TESTS_PATH="${TESTS_PATH:-charts/clickstack/tests}"
HELMCOV_IMAGE="${HELMCOV_IMAGE:-ghcr.io/jordan-simonovski/helmcov:v0.3.2}"
COVERAGE_OUT="${COVERAGE_OUT:-coverage.out}"
COVERAGE_XML="${COVERAGE_XML:-coverage.xml}"
THRESHOLD="${THRESHOLD:-25}"
MAX_SCENARIOS="${MAX_SCENARIOS:-20}"
SEED="${SEED:-42}"
VERBOSE="${VERBOSE:-}"

if ! command -v docker >/dev/null; then
  echo "docker is required for helmcov; install Docker and retry." >&2
  exit 1
fi

chart_abs="${ROOT_DIR}/${CHART_PATH}"
tests_abs="${ROOT_DIR}/${TESTS_PATH}"

if [[ ! -f "${chart_abs}/Chart.yaml" ]]; then
  echo "Chart not found: ${chart_abs}/Chart.yaml" >&2
  exit 1
fi
if ! compgen -G "${tests_abs}/*_test.yaml" >/dev/null; then
  echo "No helm-unittest suites found in ${tests_abs}" >&2
  exit 1
fi

helmcov_args=(
  --chart "/work/${CHART_PATH}"
  --tests "/work/${TESTS_PATH}"
  --format go
  --format cobertura
  --go-coverprofile "/work/${COVERAGE_OUT}"
  --cobertura-file "/work/${COVERAGE_XML}"
  --max-scenarios "${MAX_SCENARIOS}"
  --seed "${SEED}"
)

if [[ "${THRESHOLD}" != "0" ]]; then
  helmcov_args+=(--threshold "${THRESHOLD}")
fi
if [[ "${VERBOSE}" == "1" ]]; then
  helmcov_args+=(--verbose)
fi

docker run --rm \
  --platform linux/amd64 \
  -v "${ROOT_DIR}:/work" \
  -w /work \
  "${HELMCOV_IMAGE}" \
  "${helmcov_args[@]}"
