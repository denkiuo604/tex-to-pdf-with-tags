#!/bin/bash
set -eux

# build pdf (change if necessary)
ptex2pdf -l -ot -kanji=utf8 main.tex

# create release
res=`curl -H "Authorization: token $GITHUB_TOKEN" -X POST https://api.github.com/repos/$GITHUB_REPOSITORY/releases \
-d "
{
  \"tag_name\": \"$(echo ${GITHUB_REF:10})\",
  \"target_commitish\": \"$GITHUB_SHA\",
  \"name\": \"main.pdf $(echo ${GITHUB_REF:10})\",
  \"draft\": false,
  \"prerelease\": false
}"`

# extract release id
rel_id=`echo ${res} | python3 -c 'import json,sys;print(json.load(sys.stdin)["id"])'`

# upload built pdf
curl -H "Authorization: token $GITHUB_TOKEN" -X POST https://uploads.github.com/repos/$GITHUB_REPOSITORY/releases/${rel_id}/assets?name=main.pdf\
  --header 'Content-Type: application/pdf'\
  --upload-file main.pdf
