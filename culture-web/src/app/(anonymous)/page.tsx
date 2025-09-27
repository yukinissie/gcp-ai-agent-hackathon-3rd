import {
  Flex,
  Heading,
  Text,
  Box,
} from "@radix-ui/themes";
import { LoginSection } from "./_components/LoginSection";
import { RegisterSection } from "./_components/RegisterSection";
import { ThemeToggle } from "../_components/ThemeToggle";
import Image from "next/image";

export default function PocPage() {
  return (
    <Box
      position="relative"
      height="100vh"
    >
      <Box
        position="absolute"
        top="4"
        right="4"
      >
        <ThemeToggle />
      </Box>
      <Flex
        justify="center"
        align="center"
        height="100vh"
        direction="column"
        gap="6"
      >
        <Heading
          size={
            "7"
          }
        >
          ようこそ
          Culture
          へ！👋
        </Heading>
        <Flex
          direction={
            "column"
          }
          gap="2"
          align="center"
        >
          <Image
            src="/culture.png"
            alt="Culture"
            width={
              150
            }
            height={
              150
            }
          />
          <Text
            size={
              "5"
            }
            weight={
              "bold"
            }
            color="gray"
          >
            ここは始まりの村だよ！
          </Text>
        </Flex>
        <Flex gap="2">
          <LoginSection />
          <RegisterSection />
        </Flex>
      </Flex>
    </Box>
  );
}
