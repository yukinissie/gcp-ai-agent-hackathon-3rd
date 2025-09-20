import styles from "./index.module.css";
import Image from "next/image";

export default function Home() {
  return (
    <main
      style={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        height: "100vh",
        gap: "1rem",
        backgroundColor: "#f4fac0ff",
      }}
    >
      <h1 className={styles.title}>Culture へようこそ!👋</h1>
      <Image src="/culture.png" alt="Culture" width={150} height={150} />
      <p className={styles.description}>ここは始まりの村だよ！</p>
    </main>
  );
}
