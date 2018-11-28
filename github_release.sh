#!/bin/bash

CHECKSUM=""
GH_ASSET=""
WHITE='\033[0;37m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

if [ "" = "$GITHUB_TOKEN" ]
then
  echo -e "${RED}GITHUB_TOKEN not found in environment variables.${NC}"
  exit
fi

if [ "" = "$VERSION" ]
then
  echo -e "${RED}VERSION not found in environment variables.${NC}"
  exit
fi

buildSha256Sum(){
    for file in dist/*; do
      if [[ ${file} == *.zip ]]
        then
          # echo "$(basename "$file")"
          fileSum=`sha256sum $file | sed "s/dist\\///"`
          CHECKSUM+="\n${fileSum}"
        fi
    done
}

buildSha256Sum

createRelease(){
    body="To run awesome-movies, download the appropriate executable for your platform, unzip the zip, and include the resulting binary somewhere on your PATH environment variable.\n\nSHA 256 SUMS\n\n \`\`\`${CHECKSUM}\n\`\`\`"
    API_JSON=$(printf '{"tag_name": "v%s","target_commitish": "master","name": "v%s","body": "%s","draft": true,"prerelease": false}' $VERSION $VERSION "$body")
    # echo "$API_JSON"
    resp=`curl --silent --data "$API_JSON" \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    https://api.github.com/repos/anbuksv/awesome-movies/releases`
    GH_ASSET=`echo $resp | jq .upload_url -r| sed "s/{?name,label}//"`
    echo "$GH_ASSET"
}

uploadAsset(){
    FILE_PATH=$1
    FILE_NAME=$2
    UPLOAD_URL="$GH_ASSET?name=$FILE_NAME"
    echo -e "\nUploading ${WHITE}$UPLOAD_URL${NC}"
    RESP=`curl --progress-bar --data-binary @$FILE_PATH \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "Content-Type: application/zip" \
    $UPLOAD_URL`
}

updateRelease(){
    for file in dist/*; do
      if [[ ${file} == *.zip ]]
        then
          uploadAsset $file `echo "$(basename "$file")"`
        fi
    done
}


createRelease
updateRelease