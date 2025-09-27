"use server";

import { revalidatePath } from "next/cache";

export async function postPing(
  formData: FormData,
) {
  await fetch(
    `${process.env.RAILS_API_HOST}/api/v1/ping`,
    {
      method:
        "POST",
      headers:
        {
          "Content-Type":
            "application/json",
        },
      body: JSON.stringify(
        {
          message:
            formData.get(
              "message",
            ),
        },
      ),
    },
  );
  revalidatePath(
    "/ping",
  );
}
