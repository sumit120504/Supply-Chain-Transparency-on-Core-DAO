// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SupplyChainTracker {
    enum Stage { Manufactured, Shipped, Received, Sold }

    struct Product {
        string name;
        uint256 timestamp;
        address currentOwner;
        Stage currentStage;
    }

    mapping(uint256 => Product) public products;
    uint256 public productCounter;

    event ProductAdded(uint256 indexed productId, string name, address owner);
    event StageUpdated(uint256 indexed productId, Stage newStage, address updatedBy);

    modifier onlyOwner(uint256 _productId) {
        require(products[_productId].currentOwner == msg.sender, "Not product owner");
        _;
    }

    function addProduct(string memory _name) external returns (uint256) {
        productCounter++;
        products[productCounter] = Product({
            name: _name,
            timestamp: block.timestamp,
            currentOwner: msg.sender,
            currentStage: Stage.Manufactured
        });

        emit ProductAdded(productCounter, _name, msg.sender);
        return productCounter;
    }

    function updateStage(uint256 _productId, Stage _newStage, address _newOwner) external onlyOwner(_productId) {
        require(uint8(_newStage) > uint8(products[_productId].currentStage), "Invalid stage update");

        products[_productId].currentStage = _newStage;
        products[_productId].timestamp = block.timestamp;
        products[_productId].currentOwner = _newOwner;

        emit StageUpdated(_productId, _newStage, msg.sender);
    }

    function getProduct(uint256 _productId) external view returns (
        string memory name,
        uint256 timestamp,
        address owner,
        Stage stage
    ) {
        Product memory p = products[_productId];
        return (p.name, p.timestamp, p.currentOwner, p.currentStage);
    }
}
