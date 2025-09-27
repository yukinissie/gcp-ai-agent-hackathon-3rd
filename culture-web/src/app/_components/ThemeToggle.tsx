"use client";

import { useTheme } from "next-themes";
import {
  useEffect,
  useState,
} from "react";
import { Button } from "@radix-ui/themes";
import {
  MoonIcon,
  SunIcon,
} from "@radix-ui/react-icons";

export function ThemeToggle() {
  const [
    mounted,
    setMounted,
  ] =
    useState(
      false,
    );
  const {
    theme,
    setTheme,
  } =
    useTheme();

  useEffect(() => {
    setMounted(
      true,
    );
  }, []);

  if (
    !mounted
  ) {
    return (
      <Button
        variant="ghost"
        size="2"
      >
        <SunIcon
          width="16"
          height="16"
        />
      </Button>
    );
  }

  return (
    <Button
      variant="ghost"
      size="2"
      onClick={() =>
        setTheme(
          theme ===
            "dark"
            ? "light"
            : "dark",
        )
      }
    >
      {theme ===
      "dark" ? (
        <MoonIcon
          width="16"
          height="16"
        />
      ) : (
        <SunIcon
          width="16"
          height="16"
        />
      )}
    </Button>
  );
}
