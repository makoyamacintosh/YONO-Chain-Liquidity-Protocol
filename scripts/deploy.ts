import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying with", deployer.address);

  // Helper to deploy ERC20 tokens
  async function deployERC20(name: string, symbol: string, supply: string) {
    const ERC20 = await ethers.getContractFactory("ERC20Mock");
    const token = await ERC20.deploy(name, symbol, 18, ethers.utils.parseEther(supply));
    await token.deployed();
    return token;
  }

  // Deploy tokens in parallel
  const [tokenA, tokenB] = await Promise.all([
    deployERC20("Token A", "TKA", "1000000"),
    deployERC20("Token B", "TKB", "1000000")
  ]);
  console.log("Tokens deployed:", tokenA.address, tokenB.address);

  // Deploy factory (independent, can be parallel with paymaster)
  const factoryPromise = (async () => {
    const Factory = await ethers.getContractFactory("YonoFactory");
    const f = await Factory.deploy();
    await f.deployed();
    return f;
  })();

  // Deploy paymaster (independent) and then feeCollector (dependent)
  const paymasterFactory = await ethers.getContractFactory("Paymaster");
  const paymaster = await paymasterFactory.deploy();
  await paymaster.deployed();

  const feeCollectorFactory = await ethers.getContractFactory("FeeCollector");
  const feeCollector = await feeCollectorFactory.deploy(paymaster.address);
  await feeCollector.deployed();

  const factory = await factoryPromise;

  console.log("Factory deployed:", factory.address);
  console.log("Paymaster deployed:", paymaster.address);
  console.log("FeeCollector deployed:", feeCollector.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
