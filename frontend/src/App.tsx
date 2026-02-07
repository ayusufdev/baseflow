import WalletConnect from "./components/WalletConnect";
import CreateEscrow from "./components/CreateEscrow";

export default function App() {
  return (
    <div style={{ padding: 20 }}>
      <h1>BaseFlow</h1>
      <WalletConnect />
      <CreateEscrow />
    </div>
  );
}
