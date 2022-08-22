const collection = artifacts.require("MariaCollection"); //Get Smart Contract
const { assert } = require("chai");

contract("Collection", accounts => {
    it("Contract Test", async() => {
        //Checking contract owner
        const contract = await collection.deployed()
        const owner = await contract.owner.call()
        console.log("The contract owner is: ", owner)

        //Minting
        await contract.mint(accounts[2], 1, {from: accounts[0]})
        var balance = await contract.balanceOf.call(accounts[2])
        assert.equal(1, balance)
        console.log("NFT added correctly")

        //Selling token
        await contract.buyToken(1, 1, {value: 1000000000000000000, from: accounts[3]})

    });
})