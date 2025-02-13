#!/usr/bin/env bash
set -euo pipefail

function group {
	echo "::group::$*"
}

function endgroup {
	echo "::endgroup::"
}

function die {
	echo "::error::$*"
	exit 1	
}

group Check config and dependencies
	if [ -z "${ORO_TOOLCHAIN_PATH-}" ]; then
		die "ORO_TOOLCHAIN_PATH is not set"
	fi
	if [ ! -d "${ORO_TOOLCHAIN_PATH}" ]; then
		die "directory not found: ${ORO_TOOLCHAIN_PATH}"
	fi
	
	if [ ! -d "${ORO_TOOLCHAIN_PATH}/bin" ] || [ ! -d "${ORO_TOOLCHAIN_PATH}/lib" ]; then
		set -x
		ls -la "${ORO_TOOLCHAIN_PATH}"
		set +x
		die "invalid toolchain directory: ${ORO_TOOLCHAIN_PATH}"
	fi

	echo "found toolchain at: ${ORO_TOOLCHAIN_PATH}"

	export ORO_TOOLCHAIN_NAME="${ORO_TOOLCHAIN_NAME-oro-dev}"

	rustup --version
endgroup

group Install toolchain as "+${ORO_TOOLCHAIN_NAME}"
	rustup toolchain link "${ORO_TOOLCHAIN_NAME}" "${ORO_TOOLCHAIN_PATH}"
endgroup

group Check installation
	rustc "+${ORO_TOOLCHAIN_NAME}" --version --verbose
endgroup