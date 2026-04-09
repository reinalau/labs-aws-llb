// ============================================================
// aws-config.ts — Configuración de servicios AWS
// ============================================================
// Valores obtenidos de los outputs de Terraform tras el deploy.
// Para actualizar: reemplazar con los valores del nuevo terraform apply.
// ============================================================

export const awsConfig = {
  // Cognito
  cognito: {
    userPoolId: 'us-east-us-east-1_TU_USER_POOL_ID',
    clientId: 'TU_CLIENT_ID',
    region: 'us-east-1',
  },

  // API Gateway
  apiUrl: 'https://TU_API_ID.execute-api.us-east-1.amazonaws.com/dev',

  // CloudFront (base para imágenes subidas por usuarios)
  cloudfrontUrl: 'https://TU_CLOUDFRONT_ID.cloudfront.net',
};
