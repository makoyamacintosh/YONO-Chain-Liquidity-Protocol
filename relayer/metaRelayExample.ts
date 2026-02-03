import { ethers } from "ethers";

/**
 * Example: relay a user's signed payload to the TrustedForwarder.
 * The user first signs the payload (EIP-191/EIP-712 UI) off-chain.
 * For simplicity this example assumes the user supplied `user` address and we have `data` ready.
 */

async function relay(providerUrl: string, forwarderAddress: string, targetAddress: string, data: string, userAddress: string, relayerPrivateKey: string) {
  const provider = new ethers.providers.JsonRpcProvider(providerUrl);
  const relayerWallet = new ethers.Wallet(relayerPrivateKey, provider);
  const forwarderAbi = ["function forward(address target, bytes calldata data, address user) external"];
  const forwarder = new ethers.Contract(forwarderAddress, forwarderAbi, relayerWallet);
  const tx = await forwarder.forward(targetAddress, data, userAddress, { gasLimit: 800000 });
  console.log("Relayed tx:", tx.hash);
  await tx.wait();
  console.log("Executed");
}
