import styles from "./index.module.css";

export default function Home() {
  return (
    <main>
      <h1 className={styles.title}>こんにちは!👋</h1>
      <p className={styles.description}>ここは始まりの村だよ！</p>
    </main>
  );
}
