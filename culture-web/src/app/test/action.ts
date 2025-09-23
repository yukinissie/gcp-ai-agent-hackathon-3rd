"use server";

import { mastra } from "../../mastra";

export async function getWeatherInfo(formData: FormData) {
	const city = formData.get("city")?.toString();

	// Await the mastra instance since it's now a Promise
	const mastraInstance = await mastra;
	const agent = mastraInstance.getAgent("weatherAgent");

	const result = await agent.generateVNext(`What's the weather like in ${city}?`);

	return result.text;
}
