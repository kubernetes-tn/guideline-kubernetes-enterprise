# Get k3s local env
- create vm `multipass launch --name k3s --mem 4G --disk 40G`
    validate `multipass ls`
- IF NEEDED, mount host folders: `multipass mount ~/test/k8s k3s:~/k8s`
- Install k3s
```sh
$ multipass shell k3s
ubuntu@k3s:~$ curl -sfL https://get.k3s.io | sh -

ubuntu@k3s:~$ sudo chmod a+r /etc/rancher/k3s/k3s.yaml
ubuntu@k3s:~$ exit
```
- Connect to it:

```sh
# download kubeconfig
multipass transfer k3s:/etc/rancher/k3s/k3s.yaml local.kubeconfig

# point to vm IP instead of localhost
vm_ip=$(multipass info k3s --format json | jq -r '.info.k3s.ipv4[0]');
sed -i '' "s@127.0.0.1@${vm_ip}@g" local.kubeconfig
```
