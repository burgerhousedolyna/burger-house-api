import { createEnvVars, getEnvVars } from '../../utils/env.utils';

export const envVars = createEnvVars({
  DB_HOST: 'DB_HOST',
  DB_PORT: 'DB_PORT',
  DB_USERNAME: 'DB_USERNAME',
  DB_PASSWORD: 'DB_PASSWORD',
  DB_DATABASE: 'DB_DATABASE',
  APP_PORT: 'APP_PORT',
  CIPER_SALT: 'CIPER_SALT',
  PASSWORD_PEPPER: 'PASSWORD_PEPPER',
  JWT_SECRET_KEY: 'JWT_SECRET_KEY',
  NODE_ENV: 'NODE_ENV',
  MAILER_SEND_TOKEN: 'MAILER_SEND_TOKEN',
  GOOGLE_MAPS_KEY: 'GOOGLE_MAPS_KEY',
  PHONE_SALT: 'PHONE_SALT',
  DOMAIN_ADMIN: 'DOMAIN_ADMIN',
  DOMAIN_CLIENT: 'DOMAIN_CLIENT',
  DOMAIN_API: 'DOMAIN_API',
  TELEGRAM_BOT_KEY: 'TELEGRAM_BOT_KEY',
  TELEGRAM_CHAT_ID: 'TELEGRAM_CHAT_ID',
  MAILER_SEND_DOMEN: 'MAILER_SEND_DOMEN',
});
const NODE_ENV = getEnvVars(envVars.NODE_ENV);
export const envVarValue = {
  // [envVars.NODE_ENV]: getEnvVars(envVars.NODE_ENV),
  NODE_ENV,
  [envVars.APP_PORT]: Number(getEnvVars(envVars.APP_PORT)),
  [envVars.DB_HOST]: getEnvVars(envVars.DB_HOST),
  [envVars.DB_PORT]: Number(getEnvVars(envVars.DB_PORT)),
  [envVars.DB_USERNAME]: getEnvVars(envVars.DB_USERNAME),
  [envVars.DB_PASSWORD]:
    NODE_ENV !== 'development' ? getEnvVars(envVars.DB_PASSWORD) : undefined,
  [envVars.DB_DATABASE]: getEnvVars(envVars.DB_DATABASE),
  [envVars.PASSWORD_PEPPER]: getEnvVars(envVars.PASSWORD_PEPPER),
  [envVars.CIPER_SALT]: getEnvVars(envVars.CIPER_SALT),
  [envVars.JWT_SECRET_KEY]: getEnvVars(envVars.JWT_SECRET_KEY),
  [envVars.MAILER_SEND_TOKEN]: getEnvVars(envVars.MAILER_SEND_TOKEN),
  [envVars.GOOGLE_MAPS_KEY]: getEnvVars(envVars.GOOGLE_MAPS_KEY),
  [envVars.PHONE_SALT]: getEnvVars(envVars.PHONE_SALT),
  [envVars.TELEGRAM_BOT_KEY]: getEnvVars(envVars.TELEGRAM_BOT_KEY),
  [envVars.TELEGRAM_CHAT_ID]: getEnvVars(envVars.TELEGRAM_CHAT_ID),
  [envVars.MAILER_SEND_DOMEN]: getEnvVars(envVars.MAILER_SEND_DOMEN),
};
