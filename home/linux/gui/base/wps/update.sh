#! /usr/bin/env nix-shell
#! nix-shell -i bash --pure --keep GITHUB_TOKEN -p nix curl cacert nix-prefetch-git jq

download_json=$(curl 'https://plus.wps.cn/ops/opsd/api/v2/policy' --compressed -X POST -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:127.0) Gecko/20100101 Firefox/127.0' -H 'Accept: application/json' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate, br, zstd' -H 'Content-Type: application/json;charset=utf-8' -H 'Origin: https://365.wps.cn' -H 'DNT: 1' -H 'Connection: keep-alive' -H 'Referer: https://365.wps.cn/' -H 'Sec-Fetch-Dest: empty' -H 'Sec-Fetch-Mode: cors' -H 'Sec-Fetch-Site: same-site' -H 'TE: trailers' --data-raw '{"entity_param":[{"window_key":"wps365_download_pc_muti"}]}')
arm64_url=$(echo $download_json | jq '.windows[0].data[3].value | fromjson | .[5].links[0].packageList[0].link' | sed 's/"//g')
amd64_url=$(echo $download_json | jq '.windows[0].data[3].value | fromjson | .[5].links[1].packageList[0].link' | sed 's/"//g')
version=$(echo $amd64_url | awk -F'[_]' '{print $2}' | awk -F'[AK]' '{print $1}' | sed -E 's/(.*)./\1/')
arm64_hash=$(nix hash to-sri --type sha256 "$(nix-prefetch-url $arm64_url)")
amd64_hash=$(nix hash to-sri --type sha256 "$(nix-prefetch-url $amd64_url)")

cat > sources.nix <<EOF
# Generated by ./update.sh - do not update manually!
# Last updated: $(date +%F)
{
  version = "$version";
  pro_arm64_url = "$arm64_url";
  pro_amd64_url = "$amd64_url";
  pro_arm64_hash = "$arm64_hash";
  pro_amd64_hash = "$amd64_hash";
}
EOF