#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/tmux/tmux"
TOOL_NAME="tmux"
TOOL_TEST="tmux -V"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		sed 's/^v//'
}

list_all_versions() {
	list_github_tags
}

download_release() {
	local version filename url
	version="$1"
	filename="$2"

	url="$GH_REPO/releases/download/${version}/tmux-${version}.tar.gz"

	echo "* Downloading $TOOL_NAME release $version..."
	curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

check_libevent_dependency() {
	if ! pkg-config --exists libevent || ! pkg-config --exists libevent_core; then
		fail "Missing dependency: libevent. Please install libevent development package."
	fi
}

install_dependencies() {
	local os_name
	os_name="$(uname -s)"

	# Linux systems
	if [[ "$os_name" == "Linux" ]]; then
		# Debian/Ubuntu based distributions
		if [[ -f /etc/debian_version ]] || [[ -f /etc/lsb-release && $(grep -q "Ubuntu\|Debian" /etc/lsb-release) ]]; then
			echo "* Detected Debian/Ubuntu-based system"

			if command -v sudo >/dev/null 2>&1; then
				echo "* Installing dependencies using sudo..."
				sudo apt-get update -q
				sudo apt-get install -y libevent-dev libncurses-dev build-essential bison pkg-config autoconf automake
				echo "* Dependencies installed successfully"
				return 0
			fi

			echo "* sudo not available, checking if dependencies are already installed"
			check_libevent_dependency
			return 0
		fi

		echo "* Non-Debian/Ubuntu Linux detected"
		echo "* Checking if dependencies are already installed"
		check_libevent_dependency
		return 0
	fi

	# macOS systems
	if [[ "$os_name" == "Darwin" ]]; then
		echo "* Detected macOS"

		if command -v brew >/dev/null 2>&1; then
			echo "* Installing dependencies using Homebrew..."
			brew install libevent ncurses automake pkg-config utf8proc
			echo "* Dependencies installed successfully"
			return 0
		fi

		echo "* Homebrew not detected, checking if dependencies are already installed"
		check_libevent_dependency
		return 0
	fi

	# Unsupported OS
	echo "* Unsupported operating system: $os_name"
	echo "* Checking if dependencies are already installed"
	check_libevent_dependency
}

configure_tmux() {
	local install_path="$1"
	local version="$2"
	local os_name
	os_name="$(uname -s)"

	if [[ "$os_name" == "Darwin" ]]; then
		echo "* Configuring tmux on macOS with Unicode support..."

		if pkg-config --exists utf8proc; then
			echo "* Enabling utf8proc support"
			./configure --prefix="$install_path" --enable-utf8proc || fail "Could not configure $TOOL_NAME $version"
			return 0
		fi

		echo "* utf8proc not found, disabling utf8proc support"
		./configure --prefix="$install_path" --disable-utf8proc || fail "Could not configure $TOOL_NAME $version"
		return 0
	fi

	# Default configuration for non-macOS systems
	echo "* Configuring tmux..."
	./configure --prefix="$install_path" || fail "Could not configure $TOOL_NAME $version"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="$3"
	local bin_path="${install_path}/bin"
	local build_path="${ASDF_DOWNLOAD_PATH}"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		echo "* Installing $TOOL_NAME $version..."
		mkdir -p "$bin_path"
		install_dependencies
		cd "$build_path"
		configure_tmux "$install_path" "$version"

		echo "* Building tmux..."
		make || fail "Could not build $TOOL_NAME $version"

		echo "* Installing tmux..."
		make install || fail "Could not install $TOOL_NAME $version"

		# Verify installation
		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/bin/$tool_cmd" || fail "Expected $install_path/bin/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
