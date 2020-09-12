# Overview

- Are you running production in Kubernetes while running locally somewhere else ?

- Do you want to have similar dev environment to production environment including ingress SSL termination and other features ?

Then, this docs is for your.

# 0. General Setup

1. Increase Shell productivity with [ZSH](https://github.com/ohmyzsh/ohmyzsh) :

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

2. Install ZSH plugins namely:

* git plugin
* dotenv plugin
* [kube-ps1](https://github.com/jonmosco/kube-ps1)

3. Be aware of existing alias :

```sh
grep -F "alias " ~/.oh-my-zsh/
grep -F "alias " ~/.zshrc
```

4. Instead of (2) and (3) , you can Use [My ZSH config file](.files/.zshrc) and put/place it in `~/.zshrc`.



# 1. Kubernetes Cluster locally

There are lot of options:

1 - minikube

2 - docker-for-desktop + kubernetes enabled ✅

3 - KinD

For the time being, (2) is recommended for some reasons, namely a service with type LoadBalancer will resolve to localhost.

Now validate: 
Running kubectl get nodes should give you the following:


```
(⎈ |docker-desktop:default)➜  ~ k get nodes
NAME             STATUS   ROLES    AGE   VERSION
docker-desktop   Ready    master   60d   v1.16.6-beta.0
```

# 2. Wilcard Certificate locally

> We will configure the wilcard domain `*.docker.internal` with your local environment.


## MacOS

**1. install `dnsmasq`**

```sh
brew install dnsmasq
# Create config folder if it doesn’t already exist
mkdir -pv $(brew --prefix)/etc/

```

**2. Configure `dnsmasq`**

- Open up `/usr/local/etc/dnsmasq.conf` and append this line to it:

```sh
address=/docker.internal/127.0.0.1
echo 'address=/docker.internal/127.0.0.1' >> $(brew --prefix)/etc/dnsmasq.conf
```

- Configure the port for macOS High Sierra

```sh
echo 'port=53' >> $(brew --prefix)/etc/dnsmasq.conf
```

- Restart dnsmasq

```sh
sudo brew services start dnsmasq

```

- create a new resolver to handle all of those queries:

```sh
sudo mkdir -p /etc/resolver
sudo cat > /etc/resolver/dev <<EOF
nameserver 127.0.0.1
server=1.1.1.1
EOF
```

- Set your DNS to 127.0.0.1 in System Preferences > Network > Advanced > DNS. 

![dns](./.images/sys-prefs-network-advanced-dns.png)

- Flush your DNS for good measure:

```sh
sudo killall -HUP mDNSResponder
```
- Validate dnsmasq configuration :

```sh
dig docker.internal @127.0.0.1

```

## Linux
TODO

## Windows

TODO

# 3. SSL certificate For local env

## MacOS

> Using mkcert to create a local certificate authority

- Install `mkcert`

```sh
brew install mkcert
```

- Install the CA (the trusted Certificate Authority:)

```sh
mkcert --install
```

- provision a wildcard certificate for our new local domain:

```sh
mkcert '*.docker.internal'
```

> This will create two files: `_wildcard.docker.internal-key.pem ` and `_wildcard.docker.internal.pem`.

- Store certifcates in the for Ingress usage later on :

```sh
kubectl -n kube-system create secret tls ingress-tls-cert \
  --key=_wildcard.docker.internal-key.pem \
  --cert=_wildcard.docker.internal.pem
# kube-system or in general the namespace 
# # where to install ingress controller
```

## Linux
TODO

## Windows

TODO

# 4. Install Ingress Controller

- Configure it with the local SSL Certificate

```sh
# add repo
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

# install it
helm -n kube-system install \
  ingress ingress-nginx/ingress-nginx \
  --set extraArgs.default-ssl-certificate="kube-system/ingress-tls-cert"

```