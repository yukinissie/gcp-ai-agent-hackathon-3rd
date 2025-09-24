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
					const result = await response.json();
					return {
						id: result.id?.toString() || result.data?.user?.id?.toString(),
						humanId: result.human_id || result.data?.user?.human_id,
						email: result.email || result.data?.user?.email,
						jwtToken: result.data?.token,
						...result,
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
				token.jwtToken = user.jwtToken;
			}
			return token;
		},
		session: async ({ session, token }) => {
			if (token.userId) {
				session.user.id = token.userId as string;
			}
			if (token.jwtToken) {
				session.user.jwtToken = token.jwtToken as string;
			}
			return session;
		},
	},
});
