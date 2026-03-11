import "./globals.css"
import { Providers } from "./providers"
import Header from "./header"
import type { Metadata } from "next"

export const metadata: Metadata = {
  title: "AirDropper",
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html suppressHydrationWarning>
      <body style={{ margin: 0, minHeight: "100vh", backgroundColor: "#f9fafb" }}>
        <Providers>
          <Header />
          <main style={{ maxWidth: "680px", margin: "0 auto", padding: "96px 24px 40px" }}>
            {children}
          </main>
        </Providers>
      </body>
    </html>
  )
}
