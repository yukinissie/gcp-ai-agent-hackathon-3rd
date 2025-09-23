import { Mastra } from "@mastra/core/mastra";
import { PinoLogger } from "@mastra/loggers";

import { getStorage } from "./lib/storage";
import { newsCurationAgent } from "./agents/news-curation-agent";

export const mastra = new Mastra({
	agents: { newsCurationAgent },
	storage: await getStorage(),
	logger: new PinoLogger({
		name: "Mastra",
		level: "debug",
	}),
});
