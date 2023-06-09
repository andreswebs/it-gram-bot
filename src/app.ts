import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';

import middy from '@middy/core';
import errorLogger from '@middy/error-logger';
import httpErrorHandler from '@middy/http-error-handler';
import httpHeaderNormalizer from '@middy/http-header-normalizer';
import httpJsonBodyParser from '@middy/http-json-body-parser';
import ssm from '@middy/ssm';

import { logMetrics } from '@aws-lambda-powertools/metrics';
import { injectLambdaContext } from '@aws-lambda-powertools/logger';
import { captureLambdaHandler } from '@aws-lambda-powertools/tracer';
import { logger, tracer, metrics } from './aws-powertools';

import { STATUS_CODES } from 'node:http';

import { botTokenParam, healthcheckPath } from './constants';
import type { BotContext } from './types';

import { Bot } from 'grammy';
import { Update } from 'grammy/types';

let bot: Bot; // cache

async function botWebhook(
  event: APIGatewayProxyEvent,
  context: BotContext
): Promise<APIGatewayProxyResult> {
  tracer.putAnnotation('awsRequestId', context.awsRequestId);
  metrics.addMetadata('awsRequestId', context.awsRequestId);
  logger.appendKeys({
    awsRequestId: context.awsRequestId,
  });

  const { path, body } = event;
  const { bot } = context;

  if (path === healthcheckPath) {
    try {
      const botInfo = await bot.api.getMe();
      logger.info({ message: 'healthcheck', botInfo });
      return {
        statusCode: 200,
        body: JSON.stringify({ message: 'healthy' }),
      };
    } catch (error) {
      tracer.addErrorAsMetadata(error as Error);
      logger.error(error);
      return {
        statusCode: 500,
        body: JSON.stringify({ error: 'bot failed to initialize' }),
      };
    }
  }

  // TODO: actual typing and validation
  const update = body as unknown as Update;

  logger.info({ message: 'update received', update: body });

  // TODO: forward message to queue for handling

  await bot.api.sendDice(update.message.chat.id, '🎲');
  await bot.api.sendDice(update.message.chat.id, '🎲');
  await bot.api.sendDice(update.message.chat.id, '🎲');

  return {
    statusCode: 200,
    body: JSON.stringify({ message: STATUS_CODES[200] }),
  };
}

const handler = middy(botWebhook);

handler
  .use(logMetrics(metrics))
  .use(injectLambdaContext(logger, { logEvent: false }))
  .use(captureLambdaHandler(tracer, { captureResponse: false })) // by default the tracer would add the response as metadata on the segment, but there is a chance to hit the 64kb segment size limit. Therefore set captureResponse: false
  .use(
    errorLogger({
      logger: (err: Error) => {
        logger.error(err.message, err);
      },
    })
  )
  .use(httpHeaderNormalizer())
  .use(httpErrorHandler())
  .use(httpJsonBodyParser())
  .use(
    ssm({
      fetchData: {
        botToken: botTokenParam,
      },
      setToContext: true,
    })
  )
  .before(async (request) => {
    const { botToken: token } = request.context;
    if (!bot && token) {
      bot = new Bot(token);
      bot.init();
    }
    // cache
    Object.assign(request.context, { bot });
  });

export { handler };
