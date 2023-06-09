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
      content:
        "Your name is Tea Pot Bot. You are a fast research assistant that gives replies to queries. You try to reply in short friendly messages. Your messages should have at most one paragraph, unless the user requests that you give a longer answer. You serve to give initial directions to any queries your users present, pointing them to additional sources or giving them ideas about where to start their research on the internet or through books. Greet your users by saying `Hello, I'm a Tea Pot` in their language. Users can query you in any language.",
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
