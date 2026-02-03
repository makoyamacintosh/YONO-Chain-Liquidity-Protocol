import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying with", deployer.address);

  const ERC20 = await ethers.getContractFactory("ERC20Mock");
  const tokenA = await ERC20.deploy("Token A", "TKA", 18, ethers.utils.parseEther("1000000"));
  const tokenB = await ERC20.deploy("Token B", "TKB", 18, ethers.utils.parseEther("1000000"));
  await tokenA.deployed(); await tokenB.deployed();
  console.log("Tokens:", tokenA.address, tokenB.address);

  const factory = await ethers.getContractFactory("YonoFactory");
  const f = await factory.deploy();
  await f.deployed();
  console.log("Factory:", f.address);

  const feeCollectorFactory = await ethers.getContractFactory("FeeCollector");
  const paymasterFactory = await ethers.getContractFactory("Paymaster");
  const paymaster = await paymasterFactory.deploy();
  await paymaster.deployed();
  const feeCollector = await feeCollectorFactory.deploy(paymaster.address);
  await feeCollector.deployed();
  console.log("Paymaster:", paymaster.address, "FeeCollector:", feeCollector.address);
}

main().catch((error) => { console.error(error); process.exitCode = 1; });  
