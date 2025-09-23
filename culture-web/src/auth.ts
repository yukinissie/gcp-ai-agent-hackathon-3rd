import NextAuth from "next-auth";
import Credentials from "next-auth/providers/credentials";
import { signInSchema } from "./lib/zod";

export const { handlers, signIn, signOut, auth } = NextAuth({
	providers: [
		Credentials({
			credentials: {
				email: {
					label: "Email",
					type: "email",
					placeholder: "Enter your email",
				},
				password: {
					label: "Password",
					type: "password",
					placeholder: "Enter your password",
				},
				passwordConfirmation: {
					label: "Password Confirmation",
					type: "password",
					placeholder: "Enter your password again",
				},
			},
			authorize: async (credentials) => {
				if (!credentials) return null;

				const { email, password, passwordConfirmation } =
					await signInSchema.parseAsync(credentials);

				const isRegistering = !!passwordConfirmation;
				const endpoint = isRegistering ? "/api/v1/users" : "/api/v1/sessions";
				const payload = isRegistering
					? {
							user: {
								email_address: email,
								password,
								password_confirmation: passwordConfirmation,
							},
						}
					: { email_address: email, password };

				try {
					const response = await fetch(
						`${process.env.RAILS_API_HOST}${endpoint}`,
						{
							method: "POST",
							headers: {
								"Content-Type": "application/json",
							},
							body: JSON.stringify(payload),
						},
					);
					if (!response.ok) {
						throw new Error("Authentication failed");
					}
					const user = await response.json();
					return {
						id: user.id?.toString() || user.user?.id?.toString(),
						humanId: user.human_id || user.user?.human_id,
						email: user.email || user.user?.email,
						...user,
					};
				} catch (error) {
					console.error("Error during authentication:", error);
					return null;
				}
			},
		}),
	],
	callbacks: {
		jwt: async ({ token, user }) => {
			if (user) {
				token.userId = user.id;
			}
			return token;
		},
		session: async ({ session, token }) => {
			if (token.userId) {
				session.user.id = token.userId as string;
			}
			return session;
		},
	},
});
