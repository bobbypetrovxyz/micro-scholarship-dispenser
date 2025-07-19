const { StandardMerkleTree } = require("@openzeppelin/merkle-tree");
const fs = require("fs");

const students = [
    ["0x38234f5C88F0d1CcC5b85D4Da6805E6E243a8cBc", 500],
    ["0xF38EAC99B2eB75d39De3886001D9a453934F8a01", 500]
];

const tree = StandardMerkleTree.of(students, ["address", "uint256"]);

const studentWithProof = students.map((student, index) => {
    return {
        address: student[0],
        amount: student[1],
        proof: tree.getProof(index)
    };
});

const merkleData = {
    root: tree.root,
    students: studentWithProof
};
fs.writeFileSync("merkle_data.json", JSON.stringify(merkleData));

const ethers = require("ethers");

// ethers.AbiCoder is a constructor in CommonJS
const abiCoder = new ethers.AbiCoder();

const { keccak256 } = ethers;
const student = "0x38234f5C88F0d1CcC5b85D4Da6805E6E243a8cBc";
const amount = 500;

const encoded = abiCoder.encode(["address", "uint256"], [student, amount]);
const leaf = keccak256(encoded);

console.log("Leaf:", leaf);

const root = tree.root;
const proof = tree.getProof(0);

const isValid = StandardMerkleTree.verify(root, leaf, proof);
console.log("Off-chain Merkle proof valid:", isValid);