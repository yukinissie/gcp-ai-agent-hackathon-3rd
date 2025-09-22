"use server";

import { signOut } from "@/auth";
import { isRedirectError } from "next/dist/client/components/redirect-error";

export async function signOutUser() {
	try {
		await signOut({ redirectTo: "/" });
	} catch (error) {
		if (isRedirectError(error)) {
			throw error;
		}
		const errorMessage =
			error instanceof Error ? error.message : "An unknown error occurred";
		return { errorMessage };
	}
}
