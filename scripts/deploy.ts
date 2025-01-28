async function main() {
    const [deployer] = await ethers.getSigners();
    
    // Deploy FeeManager
    const FeeManager = await ethers.getContractFactory("FeeManager");
    const feeManager = await FeeManager.deploy(deployer.address);
    
    // Deploy Marketplace
    const Marketplace = await ethers.getContractFactory("Marketplace");
    const marketplace = await Marketplace.deploy(feeManager.address);
  
    console.log("FeeManager deployed to:", feeManager.address);
    console.log("Marketplace deployed to:", marketplace.address);
  }