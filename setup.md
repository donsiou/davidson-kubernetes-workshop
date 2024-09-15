# Local host setup for this formation

## Pre-requests

- [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions)
- [Install Kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)

### Configure AWS CLI access

```bash
aws configure
# AWS Access Key ID : (Will be given to you in teams chat)
# AWS Secret Access Key : (Will be given to you in teams chat)
# Default region name : us-east-1
# Default output format : (Let empty and press enter)

aws sts get-caller-identity
# # Expected output
# {
#     "UserId": "AIDAW7EEDBPFIQMH3WCTZ",
#     "Account": "479165877194",
#     "Arn": "arn:aws:iam::479165877194:user/user"
# }

```

### Configure Kubernetes Access
  
```bash

# Configure kubectl to access davidson-eks-cluster
aws eks --region us-east-1 update-kubeconfig \
    --name davidson-eks-cluster

# Check if cluster has been added succefully
kubectl config current-context
# # Expected output
# arn:aws:eks:us-east-1:479165877194:cluster/davidson-eks-cluster

# Try random kubectl command to check if it works
kubectl get namespace default
# # Expected output
# NAME      STATUS   AGE
# default   Active   26m
```

### Clone the github repository

```bash

```