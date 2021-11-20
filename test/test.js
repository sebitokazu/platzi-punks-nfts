const { expect } = require("chai");

describe('Platzi Punks', () => {

    const setup = async({ maxSupply = 1000 }) =>{
        const [owner] = await ethers.getSigners();
        const PlatziPunks = await ethers.getContractFactory("PlatziPunks");
        const deployedContract = await PlatziPunks.deploy(maxSupply);

        return {
            owner,
            deployedContract
        };
    }

    describe('Deployment', () =>{
        it('Sets max supply through constructor param', async () =>{
            const maxSupply = 100;

            const { deployedContract } = await setup({maxSupply});

            const returnedMaxSupply = await deployedContract.maxSupply();

            expect(returnedMaxSupply).to.be.equal(maxSupply, "Max supply is not being set correctly");
        });
    })

    describe('Minting', () =>{
        it('Mints new token and assigns it to owner', async() =>{
            const { owner, deployedContract } = await setup({});

            await deployedContract.mint();

            const ownerOfMinted = await deployedContract.ownerOf(0);
            
            expect(ownerOfMinted).to.be.equal(owner.address, "Minted token is not assigned to minter address");
        });

        it('Minting limit reached', async() =>{
            const maxSupply = 2;
            const { deployedContract } = await setup({maxSupply});

            await Promise.all([deployedContract.mint(), deployedContract.mint()]);

            await expect(deployedContract.mint()).to.be.revertedWith("All PlatziPunks are minted.");
        })
    });

    describe('Token URI', () => {
        it("Returns valid metadata", async() =>{
            const { deployedContract } = await setup({});

            await deployedContract.mint();

            const tokenURI = await deployedContract.tokenURI(0);
            const stringifiedTokenUri = await tokenURI.toString();
            const [,base64Json] = stringifiedTokenUri.split("data:application/json;base64,");
            const stringifiedMetadata = await Buffer.from(base64Json, "base64").toString("ascii");

            const metadata = JSON.parse(stringifiedMetadata);

            expect(metadata).to.have.all.keys("name", "description", "image", "background-color", "youtube_url","attributes");
            expect(metadata.attributes).to.have.lengthOf(13);
        });
    });

});