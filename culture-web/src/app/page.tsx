import styles from "./index.module.css";
import Image from "next/image";

export default function Home() {
  return (
    <main>
      <h1 className={styles.title}>こんにちは!👋</h1>
      <p className={styles.description}>ここは始まりの村だよ！</p>
      <Image src="/culture.png" alt="Culture" width={200} height={200} />
    </main>
  );
}
