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

	# URL format for tmux releases
	url="$GH_REPO/releases/download/${version}/tmux-${version}.tar.gz"

	echo "* Downloading $TOOL_NAME release $version..."
	curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
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

		# Create bin directory
		mkdir -p "$bin_path"

		cd "$build_path"

		# Verificar se estamos no macOS
		if [[ "$(uname -s)" == "Darwin" ]]; then
			# No macOS, habilitar utf8proc para melhor suporte a Unicode
			echo "* Detected macOS, enabling utf8proc support..."

			# Verificar se utf8proc está instalado
			if ! pkg-config --exists utf8proc; then
				echo "* Warning: utf8proc not found. You may need to install it with: brew install utf8proc"
				echo "* Continuing with --disable-utf8proc option..."
				./configure --prefix="$install_path" --disable-utf8proc || fail "Could not configure $TOOL_NAME $version"
			else
				echo "* utf8proc found, configuring with --enable-utf8proc..."
				./configure --prefix="$install_path" --enable-utf8proc || fail "Could not configure $TOOL_NAME $version"
			fi
		else
			# Em outros sistemas, usar configuração padrão
			./configure --prefix="$install_path" || fail "Could not configure $TOOL_NAME $version"
		fi

		# Build tmux
		echo "* Running make..."
		make || fail "Could not build $TOOL_NAME $version"

		# Install tmux
		echo "* Running make install..."
		make install || fail "Could not install $TOOL_NAME $version"

		# Test installation
		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/bin/$tool_cmd" || fail "Expected $install_path/bin/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
