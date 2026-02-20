import { useState } from "react";

const OWNER = "0xYourOwnerAddress";

const mockTxHash = () => "0x" + Math.random().toString(16).slice(2, 18) + "...";

export default function FundMe() {
  const [wallet, setWallet] = useState(null);
  const [amount, setAmount] = useState("");
  const [log, setLog] = useState([]);
  const [loading, setLoading] = useState(false);
  const [contractBal, setContractBal] = useState("0.42");

  const push = (msg, type = "ok") =>
    setLog((l) => [{ msg, type, id: Date.now() }, ...l.slice(0, 6)]);

  const connect = async () => {
    if (!window.ethereum) return push("MetaMask not found", "err");
    const [addr] = await window.ethereum.request({ method: "eth_requestAccounts" });
    setWallet(addr);
    push(`Connected: ${addr.slice(0, 6)}...${addr.slice(-4)}`);
  };

  const simulate = async (label, action) => {
    if (!wallet) return push("Connect wallet first", "err");
    setLoading(true);
    await new Promise((r) => setTimeout(r, 1200));
    action();
    push(`${label} — tx: ${mockTxHash()}`);
    setLoading(false);
  };

  const fund = () =>
    simulate("Funded", () => {
      if (!amount || isNaN(amount) || +amount <= 0)
        return push("Enter valid ETH amount", "err");
      setContractBal((b) => (+b + +amount).toFixed(4));
      setAmount("");
    });

  const withdraw = () =>
    simulate("Withdrawn", () => {
      setContractBal("0.0000");
    });

  const isOwner = wallet?.toLowerCase() === OWNER.toLowerCase();

  return (
    <div style={s.root}>
      <style>{css}</style>

      {/* Header */}
      <div style={s.header}>
        <span style={s.logo}>⬡ FundMe</span>
        <button style={s.connectBtn} onClick={connect}>
          {wallet ? `${wallet.slice(0, 6)}...${wallet.slice(-4)}` : "Connect Wallet"}
        </button>
      </div>

      {/* Balance Card */}
      <div style={s.card}>
        <p style={s.label}>CONTRACT BALANCE</p>
        <p style={s.balance}>{contractBal} <span style={s.unit}>ETH</span></p>
        <p style={s.sub}>≈ ${(+contractBal * 3200).toFixed(2)} USD</p>
      </div>

      {/* Fund */}
      <div style={s.card}>
        <p style={s.label}>FUND CONTRACT</p>
        <div style={s.row}>
          <input
            style={s.input}
            type="number"
            placeholder="0.1"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
          />
          <button
            style={{ ...s.btn, ...s.green }}
            onClick={fund}
            disabled={loading}
            className="btn"
          >
            {loading ? "..." : "Fund ↑"}
          </button>
        </div>
        <p style={s.hint}>Minimum: 5 USD worth of ETH</p>
      </div>

      {/* Withdraw (owner only) */}
      <div style={{ ...s.card, opacity: isOwner ? 1 : 0.4 }}>
        <p style={s.label}>WITHDRAW {!isOwner && <span style={s.tag}>OWNER ONLY</span>}</p>
        <button
          style={{ ...s.btn, ...s.red, width: "100%" }}
          onClick={withdraw}
          disabled={loading || !isOwner}
          className="btn"
        >
          {loading ? "..." : "Withdraw All ↓"}
        </button>
      </div>

      {/* Log */}
      {log.length > 0 && (
        <div style={s.logBox}>
          {log.map((l) => (
            <p key={l.id} style={{ ...s.logLine, color: l.type === "err" ? "#f87171" : "#86efac" }}>
              › {l.msg}
            </p>
          ))}
        </div>
      )}

      <p style={s.footer}>Sepolia Testnet · FundMe.sol</p>
    </div>
  );
}

const s = {
  root: {
    minHeight: "100vh",
    background: "#0a0a0a",
    color: "#e4e4e7",
    fontFamily: "'Courier New', monospace",
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    padding: "40px 16px",
    gap: "16px",
  },
  header: {
    width: "100%",
    maxWidth: 420,
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 8,
  },
  logo: { fontSize: 20, fontWeight: "bold", letterSpacing: 2, color: "#a3e635" },
  connectBtn: {
    background: "transparent",
    border: "1px solid #3f3f46",
    color: "#e4e4e7",
    padding: "6px 14px",
    borderRadius: 6,
    cursor: "pointer",
    fontFamily: "inherit",
    fontSize: 12,
    letterSpacing: 1,
  },
  card: {
    width: "100%",
    maxWidth: 420,
    background: "#111113",
    border: "1px solid #27272a",
    borderRadius: 12,
    padding: "24px",
  },
  label: { fontSize: 10, letterSpacing: 3, color: "#71717a", margin: "0 0 12px" },
  balance: { fontSize: 42, fontWeight: "bold", margin: "0 0 4px", color: "#a3e635" },
  unit: { fontSize: 20, color: "#71717a" },
  sub: { fontSize: 13, color: "#52525b", margin: 0 },
  row: { display: "flex", gap: 10 },
  input: {
    flex: 1,
    background: "#18181b",
    border: "1px solid #3f3f46",
    borderRadius: 8,
    padding: "10px 14px",
    color: "#e4e4e7",
    fontFamily: "inherit",
    fontSize: 16,
    outline: "none",
  },
  btn: {
    padding: "10px 20px",
    borderRadius: 8,
    border: "none",
    cursor: "pointer",
    fontFamily: "inherit",
    fontWeight: "bold",
    fontSize: 14,
    letterSpacing: 1,
    transition: "opacity 0.15s",
  },
  green: { background: "#a3e635", color: "#0a0a0a" },
  red: { background: "#ef4444", color: "#fff" },
  hint: { fontSize: 11, color: "#52525b", margin: "10px 0 0", letterSpacing: 1 },
  tag: {
    background: "#27272a",
    color: "#71717a",
    fontSize: 9,
    padding: "2px 6px",
    borderRadius: 4,
    marginLeft: 8,
    letterSpacing: 2,
  },
  logBox: {
    width: "100%",
    maxWidth: 420,
    background: "#0d0d0f",
    border: "1px solid #1c1c1e",
    borderRadius: 10,
    padding: "14px 18px",
  },
  logLine: { margin: "2px 0", fontSize: 12, letterSpacing: 0.5 },
  footer: { fontSize: 10, color: "#3f3f46", letterSpacing: 2, marginTop: 8 },
};

const css = `
  * { box-sizing: border-box; }
  body { margin: 0; }
  .btn:hover:not(:disabled) { opacity: 0.85; }
  .btn:disabled { opacity: 0.4; cursor: not-allowed; }
  input:focus { border-color: #a3e635 !important; }
  input[type=number]::-webkit-inner-spin-button { -webkit-appearance: none; }
`;
