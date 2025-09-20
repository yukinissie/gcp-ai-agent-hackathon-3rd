import { postPing } from "./_actions/postPing";
import { fetchPing } from "./_drivers/fetchPing";

export default async function Ping() {
  const { data: ping, error } = await fetchPing();

  return (
    <>
      <form action={postPing}>
        <input type="text" name="message" />
        <button type="submit">Post Ping</button>
      </form>
      <div>{ping?.message}</div>
      {error && <div>Error: {error}</div>}
    </>
  );
}
