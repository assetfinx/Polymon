/**
 *Submitted for verification at polygonscan.com on 2022-01-13
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface INFT{
    function mint(address account, uint256 id, uint256 amount, bytes memory data, string memory newuri) external;
}

contract polymonNFT is Ownable {

    uint256 public price;
    INFT public NFTAddress;
    address public signerAddress;

    event buyEvent(address indexed _buyer, uint256 _tokenID);

    constructor(INFT _NFTAddress,address _signerAddress){
        NFTAddress = _NFTAddress;
        signerAddress = _signerAddress;
    }

    receive() external payable{}

    function setPrice(uint256 _price)public onlyOwner{
        price = _price; 
    }

    function setNFTAddress(INFT _NFTAddress)public onlyOwner{
        NFTAddress = _NFTAddress;
    }

    function setSignerAddress(address _signer)public onlyOwner{
        signerAddress = _signer;
    }

   struct Sig {
        /* v parameter */
        uint8 v;
        /* r parameter */
        bytes32 r;
        /* s parameter */
        bytes32 s;
    }

    function buy(address to,uint _id,uint _amount,bytes memory _data,string memory _newuri,Sig memory sig)external payable{
        validateSignature(_msgSender(),_id,_amount,_data,_newuri,sig);
        require(price == msg.value && price > 0 ,"Invalid Legendary Price");
        INFT(NFTAddress).mint(to,_id,_amount,_data,_newuri);
        emit buyEvent(to,_id);

    }


    function validateSignature(address _to,uint _id,uint _amount,bytes memory _data,string memory _newuri, Sig memory sig) public {
         bytes32 hash = prepareHash(_to, _id, _amount, _data, _newuri);
         require(ecrecover(hash, sig.v, sig.r, sig.s) == signerAddress , "Invalid Signature");
    }

    function prepareHash(address _to,uint _id,uint _amount,bytes memory _data,string memory _newuri)public  pure returns(bytes32){
        bytes32 hash = keccak256(abi.encodePacked(_to,_id,_amount,_data,_newuri));
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

}
