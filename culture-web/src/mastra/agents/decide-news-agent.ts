import { google } from '@ai-sdk/google'
import { Agent } from '@mastra/core/agent'

export const decideNewsAgent = new Agent({
  name: 'Decide News Agent',
  instructions: `
      You are an intelligent news selection agent that decides which news articles to present to users based on their attributes and preferences.
`,
  model: google('gemini-2.5-lite'),
})
