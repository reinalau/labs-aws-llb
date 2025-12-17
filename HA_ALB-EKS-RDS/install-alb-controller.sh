#!/bin/bash

CLUSTER_NAME="eks-fargate-lab-cluster"
AWS_REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "🔧 Instalando AWS Load Balancer Controller..."

# 1. Crear IAM policy
echo "Descargando política IAM..."
curl -k -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json

echo "Creando política IAM..."
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam-policy.json \
    2>/dev/null || echo "Policy ya existe"

# 1.5. Asociar OIDC provider
echo "Asociando OIDC provider..."
eksctl utils associate-iam-oidc-provider \
    --region $AWS_REGION \
    --cluster $CLUSTER_NAME \
    --approve 2>/dev/null || echo "OIDC provider ya existe"

eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster=eks-fargate-lab-cluster --approve


# 2. Crear service account
eksctl create iamserviceaccount \
    --cluster=$CLUSTER_NAME \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --attach-policy-arn=arn:aws:iam::$ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
    --override-existing-serviceaccounts \
    --region $AWS_REGION \
    --approve \
    --cfn-disable-rollback

# 3. Instalar con Helm
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=$CLUSTER_NAME \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller \
    --set region=$AWS_REGION \
    --set vpcId=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.resourcesVpcConfig.vpcId" --output text)

echo "✅ AWS Load Balancer Controller instalado!"

# Verificar
kubectl get deployment -n kube-system aws-load-balancer-controller

rm -f iam-policy.json
