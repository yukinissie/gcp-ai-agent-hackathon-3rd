"use server";

import { mastra } from "@/mastra";

export async function getWeatherInfo(formData: FormData) {
	const city = formData.get("city")?.toString();

	const agent = mastra.getAgent("weatherAgent");

	const result = await agent.generateVNext(
		`What's the weather like in ${city}?`,
	);

	return result.text;
}
