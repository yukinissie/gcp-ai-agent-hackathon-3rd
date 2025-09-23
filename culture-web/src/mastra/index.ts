import { Mastra } from "@mastra/core/mastra";
import { PinoLogger } from "@mastra/loggers";

import { weatherAgent } from "./agents/weather-agent";
import { getStorage } from "./lib/storage";

export const mastra = new Mastra({
	agents: { weatherAgent },
	storage: await getStorage(),
	logger: new PinoLogger({
		name: "Mastra",
		level: "debug",
	}),
});
