const region =
  process.env.AWS_DEFAULT_REGION || process.env.AWS_REGION || 'us-east-1';

const executionEnv = process.env.AWS_EXECUTION_ENV || 'N/A';

const serviceName = process.env.SERVICE_NAME || 'telegram-bot';

const healthcheckPath = process.env.HEALTHCHECK_PATH || '/health';

const botTokenParam = process.env.SSM_PARAM_TELEGRAM_BOT_TOKEN;

if (!botTokenParam) {
  throw new Error('missing env var: SSM_PARAM_TELEGRAM_BOT_TOKEN}');
}

const openAITokenParam = process.env.SSM_PARAM_OPENAI_TOKEN;

if (!openAITokenParam) {
  throw new Error('missing env var: SSM_PARAM_OPENAI_TOKEN}');
}

export {
  serviceName,
  region,
  executionEnv,
  botTokenParam,
  openAITokenParam,
  healthcheckPath,
};
