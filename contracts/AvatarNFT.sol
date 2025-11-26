// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title AvatarNFT
 * @dev ERC721 NFT 合约 
 */
contract AvatarNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    // 铸造权限管理
    mapping(address => bool) public minters;

    // 事件
    event NFTMinted(address indexed to, uint256 indexed tokenId, string tokenURI);
    event MinterAdded(address indexed minter);
    event MinterRemoved(address indexed minter);

    //OZ 4.x 的 Ownable 构造函数是无参的
    constructor() ERC721("AvatarNFT", "AVATAR") Ownable() {
        // 默认让部署者成为 minter
        minters[msg.sender] = true;
    }

    /**
     * @dev 设置铸造权限
     * @param minter 铸造者地址
     * @param status 是否允许铸造
     */
    function setMinter(address minter, bool status) external onlyOwner {
        minters[minter] = status;
        if (status) {
            emit MinterAdded(minter);
        } else {
            emit MinterRemoved(minter);
        }
    }

    /**
     * @dev 铸造单个 NFT
     * @param to 接收者地址
     * @param tokenURI_ 元数据 URI (ipfs://...)
     * @return newTokenId 新铸造的 tokenId
     */
    function mint(address to, string memory tokenURI_) 
        public 
        returns (uint256) 
    {
        require(minters[msg.sender], "AvatarNFT: caller is not a minter");
        
        _tokenIdCounter.increment();
        uint256 newTokenId = _tokenIdCounter.current();

        _safeMint(to, newTokenId);
        _setTokenURI(newTokenId, tokenURI_);

        emit NFTMinted(to, newTokenId, tokenURI_);

        return newTokenId;
    }

    /**
     * @dev 批量铸造 NFT
     * @param to 接收者地址
     * @param tokenURIs 元数据 URI 数组
     * @return tokenIds 新铸造的 tokenId 数组
     */
    function batchMint(address to, string[] memory tokenURIs) 
        external 
        returns (uint256[] memory) 
    {
        require(minters[msg.sender], "AvatarNFT: caller is not a minter");
        
        uint256[] memory tokenIds = new uint256[](tokenURIs.length);

        for (uint256 i = 0; i < tokenURIs.length; i++) {
            _tokenIdCounter.increment();
            uint256 newTokenId = _tokenIdCounter.current();

            _safeMint(to, newTokenId);
            _setTokenURI(newTokenId, tokenURIs[i]);

            tokenIds[i] = newTokenId;
            emit NFTMinted(to, newTokenId, tokenURIs[i]);
        }

        return tokenIds;
    }

    /**
     * @dev 获取总供应量
     */
    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter.current();
    }

    /**
     * @dev 批量获取某个地址拥有的所有 tokenId
     * @param owner 地址
     * @return tokenIds tokenId 数组
     */
    function tokensOfOwner(address owner) 
        external 
        view 
        returns (uint256[] memory) 
    {
        uint256 tokenCount = balanceOf(owner);
        uint256[] memory tokenIds = new uint256[](tokenCount);
        
        uint256 index = 0;
        for (uint256 tokenId = 1; tokenId <= _tokenIdCounter.current(); tokenId++) {
            if (ownerOf(tokenId) == owner) {
                tokenIds[index] = tokenId;
                index++;
            }
        }
        
        return tokenIds;
    }
}











