# Este script elimina el stack de CloudFormation "movies-api" desplegado anteriormente.
# Asegurarse de tener las credenciales de AWS configuradas.

aws cloudformation delete-stack --stack-name movies-api --region us-east-1
