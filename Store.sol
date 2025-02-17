// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Store is Ownable {

    /// @notice buyer => product_id => quantity
    mapping(address => mapping(uint256 => uint256)) public userPurchase;
    /// @notice product_id => quantity
    mapping(uint256 => uint256) public productsPurchase;

    struct Product {
        string name;
        uint256 id;
        uint256 stock;
        uint256 price;
    }

    Product[] private products;

    event Purchase(address buyer, uint256 id, uint256 quantity);

    error IdAlreadyExist();
    error IdDoesNotExist();
    error OutOfStock();
    error NotEnoughtFunds();
    error QuantityCantBeZero();

    constructor() Ownable(msg.sender) {}

    function buy(uint256 _id, uint256 _quantity) payable external {
        require(_quantity>0, QuantityCantBeZero());
        require(getStock(_id) >= _quantity, OutOfStock());

        uint256 totalPrice = getPrice(_id)*_quantity;
        require(msg.value >= totalPrice, NotEnoughtFunds());

        //buy
        _buyProcess(msg.sender,_id,_quantity);
        
        if(msg.value > totalPrice) {
            payable(msg.sender).transfer(msg.value - totalPrice);
        }
    }

    function batchBuy(uint256[] calldata _ids, uint256[] calldata _quantitys) payable external {
        require(_ids.length == _quantitys.length, "arrays lenghts mismatch");

        uint256 totalPrice = 0;

        for(uint i = 0; i < _ids.length; i++) {
            uint256 q = _quantitys[i];
            uint256 id = _ids[i];

            require(q>0, QuantityCantBeZero());
            require(getStock(id) >= q, OutOfStock());

            totalPrice += getPrice(id)*q;
        }

        require(msg.value >= totalPrice, NotEnoughtFunds());

        for(uint i = 0; i < _ids.length; i++) {
            uint256 q = _quantitys[i];
            uint256 id = _ids[i];

            _buyProcess(msg.sender,id,q);
        }

        if(msg.value > totalPrice) {
            payable(msg.sender).transfer(msg.value - totalPrice);
        }
    }

    function _buyProcess(address buyer, uint256 _id, uint256 _quantity) internal {
        Product storage product = findProduct(_id);
        product.stock -= _quantity;

        userPurchase[buyer][_id] += _quantity;
        productsPurchase[_id] += _quantity;

        emit Purchase(buyer,_id,_quantity);
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Not enought money");

        payable(owner()).transfer(balance);
    }

    function addProduct(string calldata _name, uint256 _id, uint256 _stock, uint256 _price) external onlyOwner {
        require(!isIdExist(_id), IdAlreadyExist());
        products.push(Product(_name,_id,_stock,_price));
    }

    function deleteProduct(uint256 _id) external onlyOwner {
        (bool status, uint256 index) = findIndexById(_id);
        require(status,IdDoesNotExist());

        products[index] = products[products.length-1];
        products.pop();
    }

    function updatePrice(uint256 _id, uint256 _price) external onlyOwner {
        Product storage product = findProduct(_id);
        product.price = _price;
    }

    function updateStock(uint256 _id, uint256 _stock) external onlyOwner {
        Product storage product = findProduct(_id);
        product.stock = _stock;
    }

    function getProducts() public view returns(Product[] memory) {
        return products;
    }

    function getPrice(uint256 _id) public view returns(uint256) {
        Product storage product = findProduct(_id);
        return product.price;
    }

    function getStock(uint256 _id) public view returns(uint256) {
        Product storage product = findProduct(_id);
        return product.stock;
    }


    function findProduct(uint256 _id) internal view returns(Product storage product) {
        for(uint i = 0; i < products.length; i++) {
            if (products[i].id == _id) {
                return products[i];
            }
        }
        revert IdDoesNotExist();
    }

    function isIdExist(uint256 _id) internal view returns(bool) {
        for(uint i = 0; i < products.length; i++) {
            if(products[i].id == _id) {
                return true;
            }
        }
        return false;
    }

    function findIndexById(uint256 _id) internal view returns(bool, uint256) {
        for(uint i = 0; i < products.length; i++) {
            if(products[i].id == _id) {
                return (true, i);
            }
        }
        return (false, 0);
    }

    //HOMEWORK
    // Add refund() function
    // Add topSellingProducts() function
    // Add getTotalRevenue() function

    // Add getUserPurchase(address) function

    // Add DISCOUNT_CODES functionality

    // Add Struct Purchase (if you want to)
}