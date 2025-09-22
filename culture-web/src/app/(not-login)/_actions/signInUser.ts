"use server";

import { signIn } from "@/auth";
import { AuthError } from "next-auth";
import { isRedirectError } from "next/dist/client/components/redirect-error";

export async function signInUser(formData: FormData) {
	const credentials = Object.fromEntries(formData);
	try {
		await signIn("credentials", {
			...Object.fromEntries(
				Object.entries(credentials).map(([key, value]) => [
					key,
					value?.toString(),
				]),
			),
			redirectTo: "/myfeed",
		});
	} catch (error) {
		if (error instanceof AuthError) {
			throw new Error("Sign-in failed: " + error.message);
		}
		if (isRedirectError(error)) {
			throw error;
		}
		const errorMessage =
			error instanceof Error ? error.message : "An unknown error occurred";
		return { errorMessage };
	}
}
