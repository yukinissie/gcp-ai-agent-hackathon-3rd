"use server";

import { signOut } from "@/auth";

export async function signOutUser() {
	try {
		await signOut();
	} catch (error) {
		throw new Error("Sign-out failed");
	}
}
