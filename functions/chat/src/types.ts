import { Context } from 'aws-lambda';
import { Bot } from 'grammy';

// BotContext is filled by Middy middleware
interface BotContext extends Context {
  botToken: string;
  openAIToken: string;
  bot: Bot;
}

export type { BotContext };
