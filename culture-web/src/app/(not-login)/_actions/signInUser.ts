"use server";

import { signIn } from "@/auth";

export async function signInUser(formData: FormData) {
	try {
		await signIn("credentials", formData, { redirectTo: "/myfeed" });
	} catch (error) {
		throw new Error("Sign-in failed: " + (error as Error).message);
	}
}
