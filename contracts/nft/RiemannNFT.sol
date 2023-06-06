// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract RiemannNFT is ERC721Enumerable, EIP712 {
  address public admin;

  string private _contractURI;
  string private _baseTokenURI;

  mapping(uint256 => uint256) private _nonceTokenIds;

  bytes32 private immutable MINT_TYPEHASH = keccak256("Mint(address recipient,uint256 nonce)");
  bytes32 private immutable CHANGE_ADMIN_TYPEHASH = keccak256("ChangeAdmin(address newAdmin)");

  modifier onlyAdmin() {
    require(msg.sender == admin, "RiemannNFT: not admin");
    _;
  }

  constructor(address _admin) ERC721("RiemannNFT", "RiemannNFT") EIP712("RiemannNFT", "1") {
    admin = _admin;
  }

  function mint(address recipient, uint256 nonce, uint8 v, bytes32 r, bytes32 s) external {
    bytes32 structHash = keccak256(abi.encode(MINT_TYPEHASH, recipient, nonce));
    _verifySiganture(structHash, v, r, s);

    _mintTo(recipient, nonce);
  }

  function adminMint(address recipient, uint256 nonce) external onlyAdmin {
    _mintTo(recipient, nonce);
  }

  function changeAdmin(address newAdmin, uint8 v, bytes32 r, bytes32 s) external {
    bytes32 structHash = keccak256(abi.encode(CHANGE_ADMIN_TYPEHASH, newAdmin));
    _verifySiganture(structHash, v, r, s);
    
    admin = newAdmin;
  }

  function setBaseURI(string memory baseURI_) external onlyAdmin {
    _baseTokenURI = baseURI_;
  }

  function setContractURI(string memory contractURI_) external onlyAdmin {
    _contractURI = contractURI_;
  }

  function baseURI() external view returns (string memory) {
    return _baseURI();
  }

  function contractURI() external view returns (string memory) {
    return _contractURI;
  }

  function exists(uint256 tokenId) external view returns (bool) {
    return _exists(tokenId);
  }

  function getTokenId(uint256 nonce) external view returns (uint256) {
    return _nonceTokenIds[nonce];
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return _baseTokenURI;
  }

  function _mintTo(address recipient, uint256 nonce) private {
    require(_nonceTokenIds[nonce] == 0, "RiemannNFT: minted");

    // 2 ** 31 - 1 = 2147483647 = 0b1111111111111111111111111111111
    uint256 tokenId = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, recipient, nonce))) & 2147483647;
    _nonceTokenIds[nonce] = tokenId;

    _mint(recipient, tokenId);
  }

  function _verifySiganture(bytes32 structHash, uint8 v, bytes32 r, bytes32 s) private view {
    require(ECDSA.recover(_hashTypedDataV4(structHash), v, r, s) == admin, "RiemannNFT: invalid sig");
  }
}