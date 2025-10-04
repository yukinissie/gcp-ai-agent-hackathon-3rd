import Image from 'next/image'
import Link from 'next/link'
import { Box, Container, Flex, Text, Heading } from '@radix-ui/themes'
import { ThemeToggle } from '../../_components/ThemeToggle'
import styles from './PublicHeader.module.css'

export function PublicHeader() {
  return (
    <Box
      asChild
      style={{
        borderBottom: '1px solid var(--gray-6)',
        backgroundColor: 'var(--color-background)',
      }}
    >
      <header>
        <Container size="4">
          <Flex
            justify="between"
            align="center"
            py="3"
            px={{ initial: '3', sm: '4' }}
          >
            {/* Logo and Site Name */}
            <Link
              href="/"
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '0.5rem',
                textDecoration: 'none',
                color: 'inherit',
                minWidth: 0,
                flexShrink: 1,
              }}
              className={styles.logoLink}
            >
              <Image
                src="/culture.png"
                alt="Culture"
                width={32}
                height={32}
                style={{ flexShrink: 0 }}
              />
              <Flex direction="column" style={{ minWidth: 0 }}>
                <Heading
                  size={{ initial: '4', sm: '5' }}
                  weight="bold"
                  style={{ whiteSpace: 'nowrap' }}
                >
                  Culture
                </Heading>
                <Text
                  size="1"
                  color="gray"
                  style={{
                    display: 'none',
                    whiteSpace: 'nowrap',
                  }}
                  className={styles.desktopOnly}
                >
                  AI Agent によるパーソナライズドニュースメディア
                </Text>
              </Flex>
            </Link>

            {/* Navigation and Theme Toggle */}
            <Flex
              align="center"
              gap={{ initial: '2', sm: '4' }}
              style={{ flexShrink: 0 }}
            >
              {/* Desktop Navigation */}
              <Flex
                asChild
                gap="4"
                style={{
                  display: 'none',
                }}
                className={styles.desktopNav}
              >
                <nav>
                  <Link
                    href="/about"
                    style={{
                      textDecoration: 'none',
                      color: 'var(--gray-11)',
                      fontWeight: 500,
                      whiteSpace: 'nowrap',
                    }}
                  >
                    About
                  </Link>
                  <Link
                    href="/privacy"
                    style={{
                      textDecoration: 'none',
                      color: 'var(--gray-11)',
                      fontWeight: 500,
                      whiteSpace: 'nowrap',
                    }}
                  >
                    プライバシー
                  </Link>
                  <Link
                    href="/terms"
                    style={{
                      textDecoration: 'none',
                      color: 'var(--gray-11)',
                      fontWeight: 500,
                      whiteSpace: 'nowrap',
                    }}
                  >
                    利用規約
                  </Link>
                  <Link
                    href="/signup"
                    style={{
                      textDecoration: 'none',
                      color: 'var(--gray-11)',
                      fontWeight: 500,
                      whiteSpace: 'nowrap',
                    }}
                  >
                    新規登録
                  </Link>
                </nav>
              </Flex>

              {/* Mobile Navigation - Compact */}
              <Flex
                asChild
                gap={{ initial: '2', sm: '3' }}
                style={{
                  display: 'flex',
                }}
                className={styles.mobileNav}
              >
                <nav>
                  <Link
                    href="/about"
                    style={{
                      textDecoration: 'none',
                      color: 'var(--gray-11)',
                      fontWeight: 500,
                      fontSize: '0.875rem',
                      whiteSpace: 'nowrap',
                    }}
                  >
                    About
                  </Link>
                  <Link
                    href="/signup"
                    style={{
                      textDecoration: 'none',
                      color: 'var(--gray-11)',
                      fontWeight: 500,
                      fontSize: '0.875rem',
                      whiteSpace: 'nowrap',
                    }}
                  >
                    新規登録
                  </Link>
                </nav>
              </Flex>

              <ThemeToggle />
            </Flex>
          </Flex>
        </Container>
      </header>
    </Box>
  )
}
