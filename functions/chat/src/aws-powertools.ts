import { Logger } from '@aws-lambda-powertools/logger';
import { Metrics } from '@aws-lambda-powertools/metrics';
import { Tracer } from '@aws-lambda-powertools/tracer';

import { serviceName, region, executionEnv } from './constants';

const defaultValues = {
  region,
  executionEnv,
};

const logger = new Logger({
  serviceName,
  persistentLogAttributes: {
    ...defaultValues,
  },
});

const metrics = new Metrics({
  serviceName,
  namespace: serviceName,
  defaultDimensions: defaultValues,
});

const tracer = new Tracer({
  serviceName,
});

tracer.provider.setLogger(logger);

export { logger, metrics, tracer };
