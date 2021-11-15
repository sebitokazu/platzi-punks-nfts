async function deploy() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contract with the address: ", deployer.address);

  const PlatziPunks = await ethers.getContractFactory("PlatziPunks");
  const deployedContract = await PlatziPunks.deploy();

  console.log("Platzi Punks is deployed at: ", deployedContract.address);
}

deploy()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
