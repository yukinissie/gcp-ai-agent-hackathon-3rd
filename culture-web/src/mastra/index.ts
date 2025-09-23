import { Mastra } from "@mastra/core/mastra";
import { PinoLogger } from "@mastra/loggers";
import { LibSQLStore } from "@mastra/libsql";

import { weatherAgent } from "./agents/weather-agent";

// Use PostgreSQL for production, memory storage for development
export async function getStorage() {
	console.log("NODE_ENV:", process.env.NODE_ENV);
	if (process.env.NODE_ENV === "production") {
		try {
			// Dynamic import to avoid initialization issues
			const { PostgresStore } = await import("@mastra/pg");

			const connectionString =
				process.env.DATABASE_URL ||
				`postgresql://${process.env.DATABASE_USER || "postgres"}:${process.env.DATABASE_PASSWORD || "password"}@${process.env.DATABASE_HOST || "localhost"}:5432/${process.env.DATABASE_NAME || "culture_rails_development"}`;

			console.log("Using PostgresStore with connection string");
			return new PostgresStore({
				connectionString,
			});
		} catch (error) {
			console.error(
				"Failed to initialize PostgresStore, falling back to LibSQL:",
				error,
			);
			// Fallback to memory storage if PostgreSQL fails
			return new LibSQLStore({
				url: ":memory:",
			});
		}
	}

	console.log("Using LibSQLStore with in-memory database");

	// Development: use memory storage
	return new LibSQLStore({
		url: ":memory:",
	});
}

// Create async factory function
async function createMastra() {
	const storage = await getStorage();

	return new Mastra({
		agents: { weatherAgent },
		storage,
		logger: new PinoLogger({
			name: "Mastra",
			level: "debug",
		}),
	});
}

// Export promise-based instance
export const mastra = createMastra();
