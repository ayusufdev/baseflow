import { useConnect, useAccount } from "wagmi";
import { InjectedConnector } from "wagmi/connectors/injected";

export default function WalletConnect() {
  const { connect } = useConnect({
    connector: new InjectedConnector(),
  });
  const { isConnected, address } = useAccount();

  return isConnected ? (
    <p>Connected: {address?.slice(0, 6)}...</p>
  ) : (
    <button onClick={() => connect()}>Connect Wallet</button>
  );
}
