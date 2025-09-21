import { Flex, Heading, Text } from "@radix-ui/themes";
import Image from "next/image";

export default function Home() {
  return (
    <Flex
      direction="column"
      gap="8"
      align="center"
      justify="center"
      style={{ height: "100vh", backgroundColor: "var(--teal-9)" }}
    >
      <Heading size={"7"}>Culture へようこそ！👋</Heading>
      <Flex direction={"column"} gap="4" align="center">
        <Image src="/culture.png" alt="Culture" width={150} height={150} />
        <Text size={"5"} weight={"bold"} color="gray">
          ここは始まりの村だよ！
        </Text>
      </Flex>
    </Flex>
  );
}
