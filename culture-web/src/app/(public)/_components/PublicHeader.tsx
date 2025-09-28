import Image from 'next/image'
import Link from 'next/link'
import { ThemeToggle } from '../../_components/ThemeToggle'
import styles from './PublicHeader.module.css'

export function PublicHeader() {
  return (
    <header className={styles.header}>
      <div className={styles.container}>
        <div className={styles.headerContent}>
          {/* Logo and Site Name */}
          <Link href="/" className={styles.logo}>
            <Image src="/culture.png" alt="Culture" width={32} height={32} />
            <div className={styles.logoInfo}>
              <h1 className={styles.siteName}>Culture</h1>
              <p className={styles.tagline}>
                AI Agent によるパーソナライズドニュースメディア
              </p>
            </div>
          </Link>

          {/* Navigation and Theme Toggle */}
          <div className={styles.navigation}>
            {/* Desktop Navigation */}
            <nav className={styles.desktopNav}>
              <Link href="/about" className={styles.navLink}>
                About
              </Link>
              <Link href="/privacy" className={styles.navLink}>
                プライバシー
              </Link>
              <Link href="/terms" className={styles.navLink}>
                利用規約
              </Link>
            </nav>

            {/* Mobile Navigation - Compact */}
            <nav className={styles.mobileNav}>
              <Link href="/about" className={styles.navLink}>
                About
              </Link>
            </nav>

            <ThemeToggle />
          </div>
        </div>
      </div>
    </header>
  )
}
