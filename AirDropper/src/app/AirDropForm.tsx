"use client"

import { useState, useMemo } from "react"
import { useAccount, useChainId, useConfig } from "wagmi"
import { readContract, writeContract, waitForTransactionReceipt } from "@wagmi/core"
import { parseUnits, formatUnits } from "viem"
import { chainsToTsSender, erc20Abi, tsenderAbi } from "@/constants"

interface InputFieldProps {
  label: string
  placeholder: string
  value: string
  type?: string
  large?: boolean
  onChange: (value: string) => void
}

function InputField({ label, placeholder, value, type = "text", large, onChange }: InputFieldProps) {
  const inputStyle: React.CSSProperties = {
    padding: "10px 14px",
    borderRadius: "8px",
    border: "1px solid #2e2e2e",
    fontSize: "14px",
    outline: "none",
    width: "100%",
    backgroundColor: "#111111",
    color: "#ffffff",
    fontFamily: "inherit",
    boxSizing: "border-box",
  }

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "6px" }}>
      <label style={{ fontSize: "13px", fontWeight: 600, color: "#a1a1aa", textTransform: "uppercase", letterSpacing: "0.05em" }}>
        {label}
      </label>
      {large ? (
        <textarea
          placeholder={placeholder}
          value={value}
          onChange={(e) => onChange(e.target.value)}
          rows={5}
          style={{ ...inputStyle, resize: "vertical" }}
        />
      ) : (
        <input
          type={type}
          placeholder={placeholder}
          value={value}
          onChange={(e) => onChange(e.target.value)}
          style={inputStyle}
        />
      )}
    </div>
  )
}

type Status = "idle" | "checking" | "approving" | "waiting-approval" | "sending" | "waiting-airdrop" | "success" | "error"

const statusMessages: Record<Status, string> = {
  idle: "",
  checking: "Checking allowance...",
  approving: "Requesting approval in wallet...",
  "waiting-approval": "Waiting for approval confirmation...",
  sending: "Sending airdrop in wallet...",
  "waiting-airdrop": "Waiting for airdrop confirmation...",
  success: "Airdrop sent successfully!",
  error: "",
}

function parseRecipients(raw: string): string[] {
  return raw.split("\n").map(r => r.trim()).filter(r => r.length > 0)
}

function parseAmounts(raw: string, recipientCount: number): string[] {
  const lines = raw.split("\n").map(a => a.trim()).filter(a => a.length > 0)
  if (lines.length === 1 && recipientCount > 1) {
    return Array(recipientCount).fill(lines[0])
  }
  return lines
}

export default function AirDropForm() {
  const [tokenAddress, setTokenAddress] = useState("")
  const [recipients, setRecipients] = useState("")
  const [amounts, setAmounts] = useState("")
  const [status, setStatus] = useState<Status>("idle")
  const [errorMsg, setErrorMsg] = useState("")
  const [txHash, setTxHash] = useState("")

  const account = useAccount()
  const chainId = useChainId()
  const config = useConfig()

  // For display only
  const displayRecipients = useMemo(() => parseRecipients(recipients), [recipients])
  const displayAmounts = useMemo(() => parseAmounts(amounts, displayRecipients.length), [amounts, displayRecipients.length])
  const displayTotal = useMemo(() => {
    try {
      if (displayAmounts.length === 0) return 0n
      return displayAmounts.reduce((sum, a) => sum + parseUnits(a, 18), 0n)
    } catch {
      return 0n
    }
  }, [displayAmounts])

  async function getApprovedAmount(
    spenderAddress: `0x${string}`,
    erc20TokenAddress: `0x${string}`,
    ownerAddress: `0x${string}`
  ): Promise<bigint> {
    const allowance = await readContract(config, {
      abi: erc20Abi,
      address: erc20TokenAddress,
      functionName: "allowance",
      args: [ownerAddress, spenderAddress],
    })
    console.log("Current allowance:", allowance)
    return allowance as bigint
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setErrorMsg("")
    setTxHash("")
    setStatus("idle")

    // --- Validate wallet ---
    if (!account.address) {
      setErrorMsg("Please connect your wallet.")
      return
    }

    // --- Validate network ---
    const tSenderAddress = chainsToTsSender[chainId]?.tsender
    if (!tSenderAddress) {
      setErrorMsg("TSender contract not found for this network. Switch to Anvil (31337) or zkSync.")
      return
    }

    // --- Validate token address ---
    if (!tokenAddress || !/^0x[a-fA-F0-9]{40}$/.test(tokenAddress)) {
      setErrorMsg("Enter a valid ERC20 token address.")
      return
    }

    // --- Parse inputs fresh inside handler (avoids stale closure issues) ---
    const recList = parseRecipients(recipients)
    const amtList = parseAmounts(amounts, recList.length)

    if (recList.length === 0) {
      setErrorMsg("Add at least one recipient.")
      return
    }

    for (const addr of recList) {
      if (!/^0x[a-fA-F0-9]{40}$/.test(addr)) {
        setErrorMsg(`Invalid recipient address: ${addr}`)
        return
      }
    }

    if (amtList.length !== recList.length) {
      setErrorMsg(`Amounts (${amtList.length}) must match recipients (${recList.length}). Or enter one amount to apply to all.`)
      return
    }

    let calcTotal: bigint
    try {
      calcTotal = amtList.reduce((sum, a) => sum + parseUnits(a, 18), 0n)
    } catch {
      setErrorMsg("Invalid amount — use numbers only (e.g. 100).")
      return
    }

    if (calcTotal === 0n) {
      setErrorMsg("Total amount must be greater than 0.")
      return
    }

    console.log("Recipients:", recList)
    console.log("Amounts:", amtList)
    console.log("Total (wei):", calcTotal.toString())

    try {
      // Step 1 — Check current allowance
      setStatus("checking")
      const approvedAmount = await getApprovedAmount(
        tSenderAddress as `0x${string}`,
        tokenAddress as `0x${string}`,
        account.address
      )

      // Step 2 — Approve if needed
      if (approvedAmount < calcTotal) {
        console.log(`Allowance ${approvedAmount} < needed ${calcTotal}, requesting approve...`)
        setStatus("approving")
        const approveHash = await writeContract(config, {
          abi: erc20Abi,
          address: tokenAddress as `0x${string}`,
          functionName: "approve",
          args: [tSenderAddress as `0x${string}`, calcTotal],
        })
        setStatus("waiting-approval")
        console.log("Approve tx hash:", approveHash)
        await waitForTransactionReceipt(config, { hash: approveHash })
        console.log("Approval confirmed ✓")
      } else {
        console.log(`Allowance ${approvedAmount} is sufficient, skipping approve`)
      }

      // Step 3 — Send airdrop
      setStatus("sending")
      const airdropHash = await writeContract(config, {
        abi: tsenderAbi,
        address: tSenderAddress as `0x${string}`,
        functionName: "airdropERC20",
        args: [
          tokenAddress as `0x${string}`,
          recList as `0x${string}`[],
          amtList.map(a => parseUnits(a, 18)),
          calcTotal,
        ],
      })
      setStatus("waiting-airdrop")
      console.log("Airdrop tx hash:", airdropHash)
      await waitForTransactionReceipt(config, { hash: airdropHash })
      setTxHash(airdropHash)
      setStatus("success")

    } catch (error: unknown) {
      console.error(error)
      const msg = error instanceof Error ? error.message : "Unknown error"
      setErrorMsg(msg.slice(0, 300))
      setStatus("error")
    }
  }

  const loading = !["idle", "success", "error"].includes(status)

  return (
    <div style={{
      padding: "32px",
      borderRadius: "12px",
      border: "1px solid #2e2e2e",
      backgroundColor: "#1a1a1a",
    }}>
      <h2 style={{ fontSize: "20px", fontWeight: 700, marginBottom: "8px", color: "#ffffff" }}>
        Airdrop Tokens
      </h2>
      <p style={{ fontSize: "14px", color: "#a1a1aa", marginBottom: "28px" }}>
        Send ERC20 tokens to multiple recipients in one transaction.
      </p>

      <form onSubmit={handleSubmit} style={{ display: "flex", flexDirection: "column", gap: "20px" }}>

        <InputField
          label="Token Address"
          placeholder="0x..."
          value={tokenAddress}
          onChange={setTokenAddress}
        />

        <InputField
          label="Recipients — one address per line"
          placeholder={"0xAddress1\n0xAddress2\n0xAddress3"}
          value={recipients}
          large
          onChange={setRecipients}
        />

        <InputField
          label="Amounts — one per line (or single amount for all)"
          placeholder={"100\n200\n300"}
          value={amounts}
          large
          onChange={setAmounts}
        />

        {/* Summary box */}
        <div style={{
          padding: "14px 16px",
          borderRadius: "8px",
          backgroundColor: "#111111",
          border: "1px solid #2e2e2e",
          display: "flex",
          flexDirection: "column",
          gap: "8px",
        }}>
          <div style={{ display: "flex", justifyContent: "space-between", fontSize: "13px" }}>
            <span style={{ color: "#a1a1aa" }}>Recipients</span>
            <span style={{ color: "#ffffff", fontWeight: 600 }}>{displayRecipients.length}</span>
          </div>
          <div style={{ display: "flex", justifyContent: "space-between", fontSize: "13px" }}>
            <span style={{ color: "#a1a1aa" }}>Total to send</span>
            <span style={{ color: "#ffffff", fontWeight: 600 }}>
              {displayTotal > 0n ? formatUnits(displayTotal, 18) : "—"}
            </span>
          </div>
          <div style={{ display: "flex", justifyContent: "space-between", fontSize: "13px" }}>
            <span style={{ color: "#a1a1aa" }}>Network</span>
            <span style={{ color: "#ffffff", fontWeight: 600 }}>
              {chainId === 31337 ? "Anvil (local)" : chainId === 324 ? "zkSync" : `Chain ${chainId}`}
            </span>
          </div>
        </div>

        {/* Status bar */}
        {status !== "idle" && status !== "error" && (
          <div style={{
            padding: "12px 16px",
            borderRadius: "8px",
            backgroundColor: status === "success" ? "#052e16" : "#0f172a",
            border: `1px solid ${status === "success" ? "#16a34a" : "#1e3a5f"}`,
            fontSize: "14px",
            color: status === "success" ? "#4ade80" : "#7dd3fc",
            display: "flex",
            alignItems: "center",
            gap: "10px",
            flexWrap: "wrap",
          }}>
            {loading && (
              <span style={{
                width: "14px", height: "14px", borderRadius: "50%",
                border: "2px solid #7dd3fc", borderTopColor: "transparent",
                display: "inline-block", animation: "spin 0.7s linear infinite",
                flexShrink: 0,
              }} />
            )}
            <span>{statusMessages[status]}</span>
            {txHash && (
              <span style={{ fontSize: "12px", color: "#a1a1aa" }}>
                Tx: {txHash.slice(0, 22)}...
              </span>
            )}
          </div>
        )}

        {/* Error box */}
        {errorMsg && (
          <div style={{
            padding: "12px 16px",
            borderRadius: "8px",
            backgroundColor: "#1c0a0a",
            border: "1px solid #7f1d1d",
            fontSize: "13px",
            color: "#f87171",
            wordBreak: "break-word",
          }}>
            {errorMsg}
          </div>
        )}

        <button
          type="submit"
          disabled={loading}
          style={{
            marginTop: "4px",
            padding: "13px",
            borderRadius: "8px",
            border: "none",
            backgroundColor: loading ? "#3f3f46" : "#ffffff",
            color: loading ? "#71717a" : "#0f0f0f",
            fontSize: "15px",
            fontWeight: 700,
            cursor: loading ? "not-allowed" : "pointer",
            width: "100%",
            letterSpacing: "-0.01em",
            transition: "background 0.2s, color 0.2s",
          }}
        >
          {loading ? statusMessages[status] : "Send Airdrop"}
        </button>

      </form>

      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
    </div>
  )
}
