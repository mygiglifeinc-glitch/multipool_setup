#!/usr/bin/env bash
#########################################################
# Created by cryptopool.builders for crypto use...
#
# Shared by the bootstraps for components that are still pulled from the
# original cryptopool-builders repositories at their last release. Those
# components have not been updated for current Ubuntu releases.
#   multipool_legacy_component <name> <repo> <dest dir> <tag> <entry script>
#########################################################

function multipool_legacy_component {
	local name=$1 repo=$2 dest=$3 tag=$4 entry=$5
	if ! dialog --title "Legacy Component" --defaultno --yesno \
		"${name} has not been updated for Ubuntu ${MULTIPOOL_SUPPORTED_RELEASES// / \/ } and is installed from its last release (${tag}) at https://github.com/cryptopool-builders/${repo}.\n\nIt may fail or install outdated software. Continue anyway?" 12 70; then
		clear
		return 0
	fi
	clear
	multipool_fetch_repo "https://github.com/cryptopool-builders/${repo}" "$dest" "$tag" || exit 1
	cd "$dest" || exit 1
	source "$entry"
}
