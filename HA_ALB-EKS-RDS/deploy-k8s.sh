#!/bin/bash

# Variables
AWS_REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
RDS_ENDPOINT=$(aws cloudformation describe-stacks \
    --stack-name rds-stack \
    --query 'Stacks[0].Outputs[?OutputKey==`DBInstanceEndpoint`].OutputValue' \
    --output text)
DB_PASSWORD="TuPasswordSeguro123"

echo "🚀 Desplegando aplicación en EKS..."
echo "📝 Account ID: $ACCOUNT_ID"
echo "📝 RDS Endpoint: $RDS_ENDPOINT"

# Configurar kubectl
aws eks update-kubeconfig --name eks-fargate-lab-cluster --region $AWS_REGION

# Reemplazar variables en deployment.yaml
sed -e "s/\${ACCOUNT_ID}/$ACCOUNT_ID/g" \
    -e "s/\${RDS_ENDPOINT}/$RDS_ENDPOINT/g" \
    -e "s/\${DB_PASSWORD}/$DB_PASSWORD/g" \
    deployment.yaml > deployment-final.yaml

# Aplicar manifests
echo "📦 Aplicando Deployment..."
kubectl apply -f deployment-final.yaml

echo "📦 Aplicando Service..."
kubectl apply -f service.yaml

echo "📦 Aplicando HPA..."
kubectl apply -f hpa.yaml

# Esperar a que los pods estén listos
echo "⏳ Esperando a que los pods estén listos..."
kubectl wait --for=condition=ready pod -l app=aws-eks-webapp --timeout=300s

# Mostrar estado
echo ""
echo "✅ Despliegue completado!"
echo ""
echo "📊 Estado de los recursos:"
kubectl get deployments
kubectl get pods
kubectl get svc
kubectl get hpa

# Limpiar archivo temporal
rm -f deployment-final.yaml
