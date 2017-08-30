### SOURCE THIS FILE WHEN RUNNING kube-create.sh

NS="testing"
NODENAME="kubernetes-minion-group-b2s6"
SLEEP_INTERVAL="1m"

## TODO Move these definitions into examples/ so this is kube generic.
CREATE_FILE_1="examples/hub/kubernetes-pre-db.yml.template"
CREATE_FILE_1_PODS="2"
CREATE_FILE_2="examples/hub/kubernetes-post-db.yml.template"
CREATE_FILE_2_PODS="8" 

kubectl label --overwrite nodes $NODENAME blackduck.hub.postgres=true --namespace=$NS
 
### sould we be doing this ??
# sudo rm -rf /var/lib/hub-postgresql
# sudo mkdir -p /var/lib/hub-postgresql/data 
# sudo chmod -R 775 /var/lib/hub-postgresql/data
 
