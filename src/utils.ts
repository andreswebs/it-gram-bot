import { Configuration, OpenAIApi, ChatCompletionRequestMessage } from 'openai';

function createPrompt(apiKey: string) {
  const config = new Configuration({
    apiKey,
  });

  const openai = new OpenAIApi(config);

  async function prompt(content: string) {
    const model = 'gpt-3.5-turbo';
    const temperature = 0;

    const systemMsg: ChatCompletionRequestMessage = {
      role: 'system',
      content: 'You are a research assistant.',
    };

    const userMsg: ChatCompletionRequestMessage = {
      role: 'user',
      content,
    };

    const messages: ChatCompletionRequestMessage[] = [systemMsg, userMsg];

    const completion = await openai.createChatCompletion({
      model,
      temperature,
      messages,
    });

    return completion.data.choices[0].message.content;
  }

  return prompt;
}

export { createPrompt };
