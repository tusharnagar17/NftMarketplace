const { expect, assert.equal } = require("chai")
const { developmentChains } = require("./../../helper-hardhat-config")
const { network } = require("hardhat")

!developmentChains.includes(network.name)
    ? describe.skip
    : describe("BasicNft test", () => {
          let basicNft, deployer

          beforeEach(async () => {
              accounts = await ethers.getSigners()
              deployer = accounts[0]
              await deployments.fixture(["basicNft"])
              basicNft = await ethers.getContract("BasicNft")
          })

          describe("Constructor test", () => {
              it("it initialise the contract correctly", async () => {
                  const name = await basicNft.name()
                  const symbol = await basicNft.symbol()
                  const tokenCounter = await basicNft.getTokenCounter()

                  assert.equal(name.toString(), "Doggie")
                  assert.equal(symbol.toString(), "DOG")
                  assert.equal(tokenCounter.toString(), "0")
              })
          })

          describe("Mint NFT", () => {
              beforeEach(async () => {
                  const txResponse = await basicNft.mintNft()
                  await txResponse.wait(1)
              })
              it("Allows users to mint NFT and changes accordingly", async () => {
                  const tokenCounter = await basicNft.getTokenCounter()
                  const tokenURI = await basicNft.tokenURI(0)

                  assert.equal(tokenCounter.toString(), "1")
                  assert.equal(tokenURI, await basicNft.tokenURI())
              })
              it("Show the current balance and owner of the NFT", async () => {
                  const deployerAddress = deployer.address
                  const deployerBalance = await basicNft.balanceOf(deployerAddress)
                  const owner = await basicNft.ownerOf("0")

                  assert.equal(deployerBalance.toString(), "1")
                  assert.equal(deployerAddress, owner)
              })
          })
      })
