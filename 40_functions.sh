#!/usr/bin/env bash

echo "Setting functions..."

function function_list() {
  declare -F | grep -v -E "^declare -f _.*$"
}

# function dns_fix() {
#   systemctl restart systemd-resolved.service
# }

# function yadm_push() {
#   yadm add -u && yadm commit -m "w" && yadm push
# }

# libg_obo_lab_ecx_linux_proxy() {
#   echo "Connecting LAB-ECX proxy"
#   ssh oboadm@172.16.128.18 -D "0.0.0.0:10115" -o ProxyCommand="/bin/nc -x 127.0.0.1:10100 %h %p"
# }

# libg_obo_lab_ecx_prodis_db_rdp_proxy() {
#   echo "Connecting Prodis PA DB"
#   ssh oboadm@172.16.128.17 -L 0.0.0.0:11101:172.23.66.190:3389 -o ProxyCommand="/bin/nc -x 127.0.0.1:10100 %h %p"
# }
# libg_obo_lab_ecx_prodis_rep_db_rdp_proxy() {
#   echo "Connecting Prodis Rep DB"
#   ssh oboadm@172.16.128.17 -L 0.0.0.0:11102:172.23.66.184:3389 -o ProxyCommand="/bin/nc -x 127.0.0.1:10100 %h %p"
# }
# libg_obo_lab_ecx_stagis_db_rdp_proxy() {
#   echo "Connecting Stagis DB"
#   ssh oboadm@172.16.128.17 -L 0.0.0.0:11103:172.23.66.186:3389 -o ProxyCommand="/bin/nc -x 127.0.0.1:10100 %h %p"
# }

# git_all() {
#   for GIT_WORK_TREE in */; do
#     echo ">>>  $GIT_WORK_TREE"
#     git --work-tree="$GIT_WORK_TREE" --git-dir="$GIT_WORK_TREE.git/" "$@"
#   done
# }

# aws_mfa() {
#   echo "MFA code: $1!"
#   response=$(aws sts get-session-token --serial-number "$AWS_MFA_ARN" --token-code "$1" --output json)
#   echo "$response"
#   access_key_id=$(echo "$response" | python -c "import sys, json; print(json.load(sys.stdin)['Credentials']['AccessKeyId'])")
#   secret_access_key=$(echo "$response" | python -c "import sys, json; print(json.load(sys.stdin)['Credentials']['SecretAccessKey'])")
#   session_token=$(echo "$response" | python -c "import sys, json; print(json.load(sys.stdin)['Credentials']['SessionToken'])")
#   export AWS_SESSION_TOKEN=$session_token
#   export AWS_ACCESS_KEY_ID=$access_key_id
#   export AWS_SECRET_ACCESS_KEY=$secret_access_key
# }

# pip_upgrade_all() {
#   pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install -U
#   pip freeze > "$HOME"/.config/yadm/pip-packages.txt
# }


aws_get_component(){
  echo Getting info for Service: $1 1>&2
  aws ec2 describe-instances --filter Name=tag:Service,Values=$1 --query 'Reservations[*].Instances[*].[Tags[?Key==`Service`].Value, Tags[?Key==`Component`].Value, State.Name, InstanceId, PrivateIpAddress, NetworkInterfaces[*].PrivateIpAddress]'
}

ak_update_etc_hosts(){
  echo "Updating /etc/hosts with $1 $2"
  sudo sed -i "/$2/ s/.*/$1\t$2/g" /etc/hosts
}

aws_get_f5(){
  result=$(aws_get_component "f5_bigip_*")
  echo $result | jq .
  f5=$(jq '.[] | .[0] | select(.[2] =="running") | {"server_name": .[0]|.[0], "ip": .[5]|.[0]}' <<< "$result")
  
  f5_mt_ip=$(jq --raw-output 'select(.server_name == "f5_bigip_mt") | .ip' <<< "$f5")
  f5_labe2esi_ip=$(jq --raw-output 'select(.server_name == "f5_bigip_labe2esi") | .ip' <<< "$f5")
  ak_update_etc_hosts $f5_mt_ip f5-bigip-mt
  ak_update_etc_hosts $f5_labe2esi_ip f5-bigip-labe2esi

}

ak_update_acs(){
  result=$(aws_get_component "ACS_Southbound")
  acs=$(jq '.[] | .[0] | select(.[2] =="running") | {"server_name": .[0]|.[0], "ips": .[5]}' <<< "$result")
  acs_ip=$(jq --raw-output --slurp '.[0].ips | .[] | select(startswith("100."))' <<< "$acs")
  ak_update_etc_hosts $acs_ip axiros
}

aws_get_acs_s(){
  aws_get_component "ACS_Southbound"
}

aws_get_acs_n(){
  aws_get_component "ACS_Northbound"
}

aws_get_crs(){
  aws_get_component "CPE_Redirect_Service"
}


aws_get_msproxy(){
  aws_get_component "Microservices_Proxy"
}

aws_get_traxis(){
  aws_get_component "Traxis_BE"
}


aws_get_stagis(){
  aws_get_component "Stagis"
}


aws_download_kube_cfg(){
  aws s3 cp s3://warehouse-lgi-red/spark/admin_obo.conf ~/.kube/config

}

aws_get_crs(){
  aws_get_component "CPE_Redirect_Service"
}

aws_get_dns(){
  aws_get_component "*DNS*"
}

ak_update_etc_hosts(){
  echo "Updating /etc/hosts with $1 $2"
  sudo sed -i "/$2/ s/.*/$1\t$2/g" /etc/hosts
}


