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

check_dependencies() {
	local missing_deps=()

	if ! command -v gcc >/dev/null 2>&1; then
		missing_deps+=("gcc")
	fi

	if ! command -v make >/dev/null 2>&1; then
		missing_deps+=("make")
	fi

	if ! command -v pkg-config >/dev/null 2>&1; then
		missing_deps+=("pkg-config")
	fi

	if ! pkg-config --exists libevent 2>/dev/null && ! [ -f /usr/include/event.h ] && ! [ -f /usr/local/include/event.h ]; then
		missing_deps+=("libevent-dev")
	fi

	if ! pkg-config --exists ncurses 2>/dev/null && ! [ -f /usr/include/ncurses.h ] && ! [ -f /usr/local/include/ncurses.h ]; then
		missing_deps+=("libncurses-dev")
	fi

	if [[ "$OSTYPE" == "darwin"* ]] && ! pkg-config --exists libutf8proc 2>/dev/null && ! [ -f /usr/local/include/utf8proc.h ] && ! [ -f /opt/homebrew/include/utf8proc.h ]; then
		missing_deps+=("utf8proc")
	fi

	if [ ${#missing_deps[@]} -ne 0 ]; then
		echo "Error: Missing required dependencies for building tmux:"
		printf " - %s\n" "${missing_deps[@]}"
		echo
		echo "Please install the missing dependencies:"
		echo
		echo "On Debian/Ubuntu:"
		echo "  sudo apt-get update"
		echo "  sudo apt-get install build-essential libevent-dev libncurses5-dev pkg-config"
		echo
		echo "On macOS with Homebrew:"
		echo "  brew install libevent ncurses pkg-config utf8proc"
		echo
		echo "On CentOS/RHEL/Fedora:"
		echo "  sudo yum install gcc make libevent-devel ncurses-devel pkgconfig"
		echo "  sudo dnf install gcc make libevent-devel ncurses-devel pkgconfig"
		echo
		return 1
	fi

	echo "✓ All required dependencies are available"
	return 0
}

cleanup_temp_files() {
	local temp_dir="$1"
	if [ -d "$temp_dir" ]; then
		echo "* Cleaning up temporary files..."
		rm -rf "$temp_dir"
	fi
}

compile_source() {
	local source_dir="$1"
	local install_path="$2"
	local temp_build_dir

	temp_build_dir=$(mktemp -d)

	echo "* Configuring tmux build..."
	# On macOS, tmux requires explicit UTF-8 configuration
	if [[ "$OSTYPE" == "darwin"* ]]; then
		if ! (cd "$source_dir" && ./configure --prefix="$install_path" --enable-utf8proc); then
			cleanup_temp_files "$temp_build_dir"
			fail "Failed to configure tmux build"
		fi
	else
		if ! (cd "$source_dir" && ./configure --prefix="$install_path"); then
			cleanup_temp_files "$temp_build_dir"
			fail "Failed to configure tmux build"
		fi
	fi

	echo "* Compiling tmux (this may take a few minutes)..."
	if ! (cd "$source_dir" && make); then
		cleanup_temp_files "$temp_build_dir"
		fail "Failed to compile tmux"
	fi

	echo "* Installing tmux to $install_path..."
	if ! (cd "$source_dir" && make install); then
		cleanup_temp_files "$temp_build_dir"
		fail "Failed to install tmux"
	fi

	cleanup_temp_files "$temp_build_dir"
	echo "✓ tmux compilation and installation completed successfully"
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

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	# Check dependencies before attempting to build
	echo "* Checking build dependencies..."
	check_dependencies || fail "Dependencies check failed"

	# Create install directory
	mkdir -p "$install_path"

	# Compile and install tmux from source
	(
		compile_source "$ASDF_DOWNLOAD_PATH" "$install_path"

		# Verify tmux executable was installed correctly
		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/bin/$tool_cmd" || fail "Expected $install_path/bin/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
