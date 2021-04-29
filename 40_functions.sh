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
_jq_get_server_ip_by_name(){
  echo $(jq --raw-output "select(.server_name == \"$2\") | .ips[0]" <<< "$1")
}


_jq_get_running_servers(){
  echo $(jq '.[] | .[0] | select(.[2] =="running") | {"server_name": .[0]|.[0], "ips": .[5]}' <<< "$1")
}

_jq_get_first_server_ip(){
  servers=$(_jq_get_running_servers "$1")
  echo $(jq --raw-output --slurp '[.[0].ips | .[] | select(startswith("100."))][0] ' <<< "$servers")
}

aws_get_component(){
  echo Getting info for Service: $1 1>&2
  aws ec2 describe-instances --filter Name=tag:Service,Values=$1 --query 'Reservations[*].Instances[*].[Tags[?Key==`Service`].Value, Tags[?Key==`Component`].Value, State.Name, InstanceId, PrivateIpAddress, NetworkInterfaces[*].PrivateIpAddress]'
}

aws_get_server(){
  aws ec2 describe-instances --filter Name=tag:Name,Values=$1 --query 'Reservations[*].Instances[*].[Tags[?Key==`Service`].Value, Tags[?Key==`Component`].Value, State.Name, InstanceId, PrivateIpAddress, NetworkInterfaces[*].PrivateIpAddress]'
}

_ak_update_etc_hosts(){
  echo "Updating /etc/hosts with $1 $2"
  sudo sed -i "/$2/ s/.*/$1\t$2/g" /etc/hosts
}

aws_update_etc_hosts_f5(){
  result=$(aws_get_component "f5_bigip_*")
  echo Got results:
  echo $result | jq .
  # f5=$(jq '.[] | .[0] | select(.[2] =="running") | {"server_name": .[0]|.[0], "ip": .[5]|.[0]}' <<< "$result")
  f5_servers=$(_jq_get_running_servers "$result")
  
  # f5_mt_ip=$(jq --raw-output 'select(.server_name == "f5_bigip_mt") | .ip' <<< "$f5_servers")
  # f5_labe2esi_ip=$(jq --raw-output 'select(.server_name == "f5_bigip_labe2esi") | .ip' <<< "$f5_servers")
  f5_mt_ip=$(_jq_get_server_ip_by_name "$f5_servers" f5_bigip_mt)
  f5_labe2esi_ip=$(_jq_get_server_ip_by_name "$f5_servers" f5_bigip_labe2esi)
  _ak_update_etc_hosts $f5_mt_ip f5-bigip-mt
  _ak_update_etc_hosts $f5_labe2esi_ip f5-bigip-labe2esi
}

aws_update_etc_hosts_acs(){
  result=$(aws_get_component "ACS_SB")
  acs_ip=$(_jq_get_first_server_ip "$result")
  _ak_update_etc_hosts $acs_ip axiros
}

aws_update_etc_hosts_mqtt(){
  result=$(aws_get_component "MQTT_Message_Broker")
  acs_ip=$(_jq_get_first_server_ip "$result")
  _ak_update_etc_hosts $acs_ip mqtt_host
}

aws_get_acs_s(){
  aws_get_component "ACS_SB"
}

aws_get_acs_n(){
  aws_get_component "ACS_NB"
}

aws_get_crs(){  
  result=$(aws_get_component "CPE_Redirect_Service")
  crs_ip=$(_jq_get_first_server_ip "$result")
  _ak_update_etc_hosts $crs_ip crs
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

aws_get_kafka(){
  result=$(aws_get_component "Kubernetes_Kafka")
  server_ip=$(_jq_get_first_server_ip "$result")
  _ak_update_etc_hosts $server_ip "kafka"
}

aws_get_mqtt(){
  result=$(aws_get_component "MQTT_Message_Broker")
  server_ip=$(_jq_get_first_server_ip "$result")
  _ak_update_etc_hosts $server_ip "mqtt"
}

aws_download_kube_cfg(){
  # s3_key_config kube_local_name
  s3_key_config=${1:-admin_obo.conf}
  kube_local_name=${2:-config}
  aws s3 cp s3://warehouse-lgi-red/spark/$s3_key_config ~/.kube/$kube_local_name
}

aws_download_kube_cfg_prod(){
  # s3_key_config kube_local_name
  s3_key_config=${1:-admin_mt.conf}
  kube_local_name=${2:-config}
  aws s3 cp s3://warehouse-prod-lgi-red/spark/$s3_key_config ~/.kube/$kube_local_name
}

aws_get_crs(){
  aws_get_component "CPE_Redirect_Service"
}

aws_get_dns(){
  aws_get_component "*DNS*"
}

aws_get_pools_seachange(){
  echo OBO_SEACHANGE_PRODIS_PA: 21
  echo OBO_SEACHANGE_PRODIS_PA_8081: 8081
  aws_get_server "5A_tst_prodispa_01"
  echo =============
  echo OBO_SEACHANGE_STAGIS: 9090
  aws_get_server "5A_tst_stagis_01"
  echo =============
  echo OBO_SEACHANGE_TRAXIS_FE_BE: 80
  aws_get_server "5A_tst_traxisbe_01"
  echo =============
  echo OBO_SEACHANGE_TRAXIS_WEB: 80
  aws_get_server "5A_tst_traxisweb_01"
  echo =============
  echo OBO_SEACHANGE_TRAXIS_WEB_NONPERSONAL: 80
  aws_get_server "5A_tst_traxisweb_be_01"
}

aws_get_pools_acs(){
  echo ACS_SB_DTV: 	9675
  echo ACS_SB_INT:	80
  aws_get_server "5A_tst_acs_sb_st_01"
  echo =============
  echo ACS_NB_UI:	80
  echo ACS_NB:		9677
  aws_get_server "5A_tst_acs_nb_st_01"
}

_aws_ssh_server(){
  result=$(aws_get_server "$1")
  ip=$(_jq_get_first_server_ip "$result")
  echo executing "ssh $ip"
  ssh $ip
}

_aws_rdp_server(){
  # server_name port bastion_tenant
  result=$(aws_get_server "$1")
  ip=$(_jq_get_first_server_ip "$result")
  echo ssh -L 0.0.0.0:$2:$ip:3389 bastion-$3  
  ssh -L 0.0.0.0:$2:$ip:3389 bastion-$3
}

aws_ssh_dns(){
  _aws_ssh_server "*dns_pinpoint_001"
}

aws_ssh_crs(){
  _aws_ssh_server "*tst_Redirect_Service_0${1:-1}"  
}

aws_ssh_msproxy(){
  _aws_ssh_server "*MicroSrvcProxy_0${1:-1}"
}

# aws_ssh_kafka(){
#   server_name="*tst_Kubernetes_Kafka_0${1:-1}"
#   result=$(aws_get_server "$server_name")
#   ip=$(_jq_get_first_server_ip "$result")
#   jq --raw-output --slurp .[0] <<< $ip
#   # echo executing "ssh $ip"
#   # ssh $ip
# }

aws_rdp_traxis(){
  _aws_rdp_server "*tst_traxisbe_0${1:-1}" "9007" "mt"
}

aws_rdp_stagis(){
  _aws_rdp_server "*tst_stagis_0${1:-1}" "9008" "mt"
}

aws_rdp_traxis_web_be(){
  _aws_rdp_server "*tst_traxisweb_be_0${1:-1}" "9010" "labe2esi"
}

aws_rdp_prodispa(){
  _aws_rdp_server "*tst_prodispa_0${1:-1}" "9011" "labe2esi"
}

lkube_service_log(){
  l-kube logs -f -l app=$1-service
}

lkube_service_exec(){
  # service_name cmd
  cmd=${2:-bash}
  l-kube exec -it deploy/$1-service $cmd
}
