# shellcheck disable=SC2148
# NOTE: this file to be sourced, with the repo root as the working directory

# Binaries vendored as git submodules
function install_submodule_bins {
	mkdir -p ~/bin
	install -m 755 submodules/diff-so-fancy/diff-so-fancy ~/bin/diff-so-fancy
	cp -r submodules/diff-so-fancy/lib ~/bin/
	install -m 755 submodules/git-log-compact/git-log-compact ~/bin/git-log-compact
	install -m 755 submodules/tldr-sh-client/tldr ~/bin/tldr
}

# Pull the latest upstream commit for each submodule that provides a ~/bin
# binary, then reinstall. No-op unless the bundle is already installed, so an
# update pass never adds a tool the machine didn't have.
function refresh_submodule_bins {
	if [ ! -e ~/bin/diff-so-fancy ] && [ ! -e ~/bin/git-log-compact ] && [ ! -e ~/bin/tldr ]; then
		return 0
	fi

	echo "==> Updating submodule-provided ~/bin binaries..."
	git submodule update --init --remote -- \
		submodules/diff-so-fancy \
		submodules/git-log-compact \
		submodules/tldr-sh-client || return 1
	install_submodule_bins
	echo "    (submodule pointers may have moved; commit them to keep the bump)"
}

# Downloads an executable to ~/bin, leaving any existing copy untouched if the
# transfer fails. $1 is the ~/bin filename, $2 the URL.
function download_bin {
	local TMP STATUS
	mkdir -p ~/bin
	TMP=$(mktemp)
	if curl -fL "$2" -o "$TMP"; then
		install -m 755 "$TMP" ~/bin/"$1"
		STATUS=0
	else
		echo "$1 download failed; keeping existing ~/bin/$1" >&2
		STATUS=1
	fi
	rm -f "$TMP"
	return $STATUS
}
