### A shell script to upload releases to github (as part of a GoCD server job) - ###

Does 2 things -

	* Marks and tags a particular commit as a release
	* Uploads binaries to github for the release created above

Currently depends on the GoCD server to set a few environment vars -
	
	* GH_AUTH_TOKEN - for command line usage of github api, more [here](https://help.github.com/articles/creating-an-access-token-for-command-line-use/)
	* GH_REPO_NAME - name of the repository to tag and upload the build to
	* GO_REVISION - commit hash to be releases
	* GO_PIPELINE_NAME - to pick up binaries from
	* GO_PIPELINE_COUNTER - to pick the particular build number from GoCD

apart from this, there are some hard coded variables that I use on @ my current work.

Dependencies - 
	
	* jq - [https://github.com/stedolan/jq](https://github.com/stedolan/jq) to be availble to the use that uploads

To do -

	* Currently has to be run on the Go server. Should be easy enough to use the GoCD api to fetch a binary to update
	* Uploads only one file. Zip/tarball a folder and upload may be a better option
	* Versioning is hard coded - may be better to depend on env var
	
Attributions - copied uploading script from wercker's [step-github-upload-asset](https://github.com/wercker/step-github-upload-asset/blob/master/run.sh)


	
