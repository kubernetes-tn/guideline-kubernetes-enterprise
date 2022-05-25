echo "WARNING: Run this script from within a Node or a Master of the k8s cluster"
echo "WARNING: The script works only for node/master of OS Ubuntu 20.x >"
export NAME=registry

helm repo add gmelillo https://helm.melillo.me/
helm -n $NAME upgrade $NAME gmelillo/docker-registry --version 1.9.9 --install --create-namespace

REGISTRY_ENDPOINT=$(kubectl -n $NAME get svc -l "app=docker-registry,release=$NAME" -o jsonpath="{.items[0].spec.clusterIP}"):5000


echo ## INSTALL SKOPEO ###
if [ ! command -v skopeo &> /dev/null ];then 
  snap install skopeo --edge --devmode;
fi

echo ### Initializing the registry by some images from Dockerhub ###

for img in nginx:alpine abdennour/sample-app:green abdennour/sample-app:blue ;do
  echo copying $img to $REGISTRY_ENDPOINT
  skopeo --insecure-policy copy docker://docker.io/${img} docker://${REGISTRY_ENDPOINT}/$img --dest-tls-verify=false
done


# https://github.com/k3s-io/k3s/issues/145#issuecomment-565691227

cat >>  /etc/rancher/k3s/registries.yaml <<EOF

mirrors:
  "${REGISTRY_ENDPOINT}":
    endpoint:
      - "http://${REGISTRY_ENDPOINT}"
EOF

systemctl restart k3s

echo "DISTRIBUTE /etc/rancher/k3s/registries.yaml (with the following content) to all nodes under same path, then-restart with systemctl restart k3s-agent"
echo "------------------"
cat /etc/rancher/k3s/registries.yaml 
echo "--------------"
echo ### Example: A pod using the new registry  ###






