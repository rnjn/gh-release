#!/bin/bash

export COMMIT_HASH="$GO_REVISION"
export RELEASE_NAME="0.1-$GO_PIPELINE_COUNTER"
export BINARY_FILE_NAME="$BINARY_NAME-0.1-$GO_PIPELINE_COUNTER.noarch.rpm"
export IS_PRERELEASE=true
export BINARY_FILE_PATH="/var/lib/go-agent/pipelines/$GO_PIPELINE_NAME/installers/$BINARY_FILE_NAME"
export GH_REPO_OWNER=sharedhealth
#export GH_REPO_NAME=
#export GH_AUTH_TOKEN=

info() {
    echo $1
}
fail() {
    echo "$1";
    exit 1;

}

export_id_to_env_var() {
    set -e;
    local json="$1";
    local id=$(echo "$json" | jq ".id");
    export ASSET_RELEASE_ID=$id;
}


create_release() {
    local token="$1";
    local owner="$2";
    local repo="$3";
    local tag_name="$4";
    local release_name="$4";
    local prerelease="$5";
    local release_commit="$6";

    curl -s -S -X POST https://api.github.com/repos/$owner/$repo/releases \
	 -H "Authorization: token $token" \
	 -H "Content-Type: application/json" \
	 -d '{"tag_name": "'"$tag_name"'", "name" : "'"$release_name"'", "prerelease": "'"$prerelease"'", "target_commitish": "'"$release_commit"'" }';
}

upload_asset() {
    set -e;

    local token="$1";
    local owner="$2";
    local repo="$3";
    local name="$4";
    local content_type="$5";
    local file="$6";
    local id="$7";

    curl -s -S -X POST https://uploads.github.com/repos/$owner/$repo/releases/$id/assets?name=$name \
	 -H "Accept: application/vnd.github.v3+json" \
	 -H "Authorization: token $token" \
	 -H "Content-Type: $content_type" \
	 --data-binary @"$file";
}

main() {
    set -e

    # Assign global variables to local variables
    local token="$GH_AUTH_TOKEN";
    local release_name="$RELEASE_NAME";
    local is_prerelease="$IS_PRERELEASE";
    local file="$BINARY_FILE_PATH";
    local name="$BINARY_FILE_NAME";
    local owner="$GH_REPO_OWNER";
    local repo="$GH_REPO_NAME";
    local content_type="application/octet-stream"
    local release_commit="$COMMIT_HASH";

    # Validate variables
    if [ -z "$token" ]; then
	fail "Token not specified; ";
    fi

    if [ -z "$release_commit" ]; then
	info "Release commit not specified; choosing 'master' ";
	release_commit="master";
    fi

    if [ -z "$file" ]; then
	fail "File parameter not specified; ";
    fi

    if [ ! -f "$file" ]; then
	fail "The file does not exists; $file";
    fi

    if [ -z "$release_name" ]; then
	fail "no release name was supplied; ";
    fi

    if [ -z "$is_prerelease" ]; then
	is_prerelease = true;
	info "is prerelease was not supplied; choosing prerelease ";
    fi


    if [ -z "$name" ]; then
	info "no name was supplied; ";
    fi

    if [ -z "$owner" ]; then
	info "no GitHub owner was supplied";
    fi

    if [ -z "$repo" ]; then
	info "no GitHub repository was supplied; ";
    fi

    if [ -z "$content_type" ]; then
	content_type=$(file --mime-type -b "$file");
	info "no content-type was supplied, using 'file' to get the content-type: $content_type";
    fi

    CREATE_RESPONSE=$(create_release \
			  "$token" \
			  "$owner" \
			  "$repo" \
			  "$release_name" \
			  "$is_prerelease" \
			  "$release_commit"
		   );
    info "$CREATE_RESPONSE"

    export_id_to_env_var "$CREATE_RESPONSE";

    local release_id="$ASSET_RELEASE_ID";

    if [ -z "$release_id" ]; then
	info "no release id was supplied";
    fi

    # Upload asset and save the output from curl
    UPLOAD_RESPONSE=$(upload_asset \
			  "$token" \
			  "$owner" \
			  "$repo" \
			  "$name" \
			  "$content_type" \
			  "$file" \
			  "$release_id");
    info "$UPLOAD_RESPONSE"

}

main;
