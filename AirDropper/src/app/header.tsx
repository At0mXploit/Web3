"use client"

import { ConnectButton } from "@rainbow-me/rainbowkit"

export default function Header() {
  return (
    <header style={{
      position: "fixed",
      top: 0,
      left: 0,
      right: 0,
      height: "64px",
      zIndex: 50,
      backgroundColor: "#0f0f0f",
      borderBottom: "1px solid #2e2e2e",
      display: "flex",
      alignItems: "center",
    }}>
      <div style={{
        maxWidth: "1152px",
        margin: "0 auto",
        width: "100%",
        padding: "0 24px",
        display: "flex",
        alignItems: "center",
        justifyContent: "space-between",
      }}>

        {/* Logo + Title */}
        <div style={{ display: "flex", alignItems: "center", gap: "10px", color: "#ffffff" }}>
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <path d="M12 2L2 7l10 5 10-5-10-5z"/>
            <path d="M2 17l10 5 10-5"/>
            <path d="M2 12l10 5 10-5"/>
          </svg>
          <span style={{ fontSize: "17px", fontWeight: 700, letterSpacing: "-0.02em", color: "#ffffff" }}>
            AirDropper
          </span>
        </div>

        {/* Right: Connect + GitHub */}
        <div style={{ display: "flex", alignItems: "center", gap: "16px" }}>
          <ConnectButton />
          <a
            href="https://github.com"
            target="_blank"
            rel="noopener noreferrer"
            aria-label="GitHub"
            style={{ color: "#a1a1aa", display: "flex", alignItems: "center", transition: "color 0.2s" }}
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 0C5.37 0 0 5.37 0 12c0 5.3 3.438 9.8 8.205 11.387.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23A11.509 11.509 0 0112 5.803c1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222 0 1.606-.015 2.896-.015 3.286 0 .322.216.694.825.576C20.565 21.795 24 17.298 24 12c0-6.63-5.37-12-12-12z"/>
            </svg>
          </a>
        </div>

      </div>
    </header>
  )
}
