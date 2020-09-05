# AWS EKS Guidelines for Software Developers


## 1. Thou Shalt setup local environment

- Docker (19 or later)
- Docker-compose (1.26 or later)
- Helm (v3.3 or later)
- kubectl (according to your clusters)
- AWS CLI (v2.x)

## 2. Authenticate to EKS from AWS User Account

> Scenario: SysOps Admin create an AWS user for you with this name "ahmed@example.com"

0. Getting Access Key ID and Secret Access Key from AWS Console.

1. Configure the user in your machine

```sh
aws configure --profile ahmed-at-example-dot-com
# AWS Access Key ID [None]: AKJKLAS42R6LF123456
# AWS Secret Access Key [None]: xxx...xx
# Default region name [None]: ap-southeast-1
# Default output format [None]: 

```

2. Get EKS cluster name, AWS region where the EKS cluster is running, then Generate KUBECONFIG:


```ssh
export AWS_PROFILE=ahmed-at-example-dot-com
region=ap-southeast-1
cluster=awesome
export KUBECONFIG=kubeconfig-awesome

aws eks update-kubeconfig \
  --name ${cluster} \
  --kubeconfig ${KUBECONFIG} \
  --region ap-southeast-1 \
  --profile ${AWS_PROFILE}

```

Test/validate now what access you have by running some commands :

```sh
export KUBECONFIG=kubeconfig-awesome
kubectl -n development get pods
# so on ...
```