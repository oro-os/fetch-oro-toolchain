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
	
	# Try to find the first artifact that was unpacked;
	# there should be only one folder with the name 'oro-rust-toolchain-*';
	# find it and re-export the path variable, or error if there are none/more than 1.
	paths="$(find "${ORO_TOOLCHAIN_PATH}" -maxdepth 1 -type d -name 'oro-rust-toolchain-*')"
	if [ -z "${paths}" ]; then
		die "no extracted toolchain directory found in: ${ORO_TOOLCHAIN_PATH}"
	fi

	if [ "$(echo "${paths}" | wc -l)" -ne 1 ]; then
		die "multiple extracted toolchain directories found in: ${ORO_TOOLCHAIN_PATH}"
	fi

	export ORO_TOOLCHAIN_PATH="${paths}"
	
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
	find "${ORO_TOOLCHAIN_PATH}/bin" -type f -print0 | xargs -0 chmod +x
	rustup toolchain link "${ORO_TOOLCHAIN_NAME}" "${ORO_TOOLCHAIN_PATH}"
	rustc "+${ORO_TOOLCHAIN_NAME}" --version --verbose
endgroup