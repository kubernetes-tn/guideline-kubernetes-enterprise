# AWS EKS Guidelines for Operators


## 1. Thou Shalt Setup your environment

- kubectl
- Docker 19 or later
- terraform CLI (v0.13 or later)
- Helm (v3.3 or later)
- AWS CLI (v2.x)


## 2. Thou Shalt Codify your Operations:

- **terraform** - to provision the EKS cluster

- **helm** - to deploy applications on top the cluster


## 3. Thou Shalt Not reinvent the Wheel

- Reuse [**Terraform Module**](https://github.com/terraform-aws-modules/terraform-aws-eks) to install the EKS cluster

- Reuse [**Helm Charts**](https://github.com/helm/charts/tree/master/stable) to install the ecosystem of the Cluster ( metrics-server, prometheus, ingress, fluentd,... so on)


## 4. Single Sign on when User Access Management

- Authenticate with AWS IAM

- Authorize with Kubernetes RBAC


### Steps to authenticate new User to the EKS Cluster

> Senario: User "ahmed@example.com" needs full access to "development" namespace.

1. Create AWS IAM Group "development" in AWS and add to it the following policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "eks:ListUpdates",
                "eks:DescribeUpdate",
                "eks:DescribeCluster",
                "eks:ListClusters"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```


2. Create the AWS IAM User with name `ahmed@example.com` with programtical access . Add him to the group "development".

> arn is generated : `arn:aws:iam::123456789012:user/ahmed@example.com`



3. Bind the User ARN to an RBAC group (aws:development) in `aws-auth` configMap

```yaml
# Using terraform module mentioned above
variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type        =   list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn = "arn:aws:iam::123456789012:user/ahmed@example.com"
      username = "ahmed-at-example-dot-com"
      groups    = ["aws:development"]
    }
  ]
}

# Or Using directly kubectl
#kubectl -n kube-system edit cm aws-auth -o yaml

```

3. Grant the right access to the "aws:development" group

```sh
namespace=development
group="aws:development"

helm repo add tn http://charts.kubernetes.tn
# grant group full-access to namespace "deveelopment' 
helm -n ${namespace} install \
  group-development \
  tn/group-access-namespace \
  --set group="${group}"
```

The group has the full-access to development namespace.
As consequence, all members of this group has access.
"ahmed@example.com" has the right access

## 4. Thou Shalt Choose the Right Nodes

**Check Availability of Node Type in the region**

```sh
region=XXX # .i.e ap-southeast-1
instance_type=m5.large # i.e r6g.large
aws ec2 describe-instance-type-offerings \
  --location-type availability-zone  \
  --filters Name=instance-type,Values=${instance_type} \
  --region ${region} \
  --output table
```

**Computing-optimized or memory-optimized ?**

TODO
