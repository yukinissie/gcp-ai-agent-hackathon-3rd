import { auth } from "@/auth";
import { Chat } from "./_components/Chat";

export default async function Page() {
  const session =
    await auth();

  if (
    !session ||
    !session.user ||
    !session
      .user
      .id
  ) {
    return (
      <>
        <h1>
          Test
          News
          Agent
        </h1>
        <p>
          ユーザー情報を取得できませんでした。
        </p>
      </>
    );
  }

  return (
    <>
      <h1>
        Test
        News
        Agent
      </h1>
      <Chat
        userId={
          session
            .user
            .id
        }
      />
    </>
  );
}
