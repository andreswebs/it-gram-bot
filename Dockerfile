# Dependencies
FROM node:18-buster-slim AS deps
WORKDIR /app
ENV NODE_ENV=production
COPY package.json package-lock.json /app/
RUN \
  npm ci --only=production

# Build
FROM node:18-buster-slim AS build
WORKDIR /app
COPY package.json package-lock.json tsconfig.json /app/
COPY ./src /app/src
RUN \
  npm install && \
  npm run build

# Release
FROM public.ecr.aws/lambda/nodejs:18

# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Lambda-Insights-Getting-Started-docker.html
RUN curl -O https://lambda-insights-extension.s3-ap-northeast-1.amazonaws.com/amazon_linux/lambda-insights-extension.rpm && \
    rpm -U lambda-insights-extension.rpm && \
    rm -f lambda-insights-extension.rpm

ENV NODE_ENV=production
COPY --from=deps /app/node_modules "${LAMBDA_TASK_ROOT}/node_modules"
COPY --from=build /app/dist/ "${LAMBDA_TASK_ROOT}/"
CMD ["app.handler"]
