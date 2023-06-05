import { Context } from 'aws-lambda';
import { Bot } from 'grammy';

interface BotContext extends Context {
  botToken: string;
  bot: Bot;
}

export type { BotContext };
