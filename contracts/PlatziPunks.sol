//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Base64.sol";
import "./ADNBase.sol";


contract PlatziPunks is ERC721, ERC721Enumerable{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    uint256 public maxSupply;

    constructor(uint256 _maxSupply) ERC721("PlatziPunks","PLPKS"){
        maxSupply = _maxSupply;
    }

    function mint() public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        require (tokenId <= maxSupply, "All PlatziPunks are minted.");
        _safeMint(msg.sender, tokenId);
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory){
        require(
            _exists(_tokenId),
            "ERC721 Metadata: URI query for non-existent query"
            );
        
        string memory jsonURI = Base64.encode(
            abi.encodePacked(
                '{ "name": "PlatziPunks #',
                _tokenId,
                '", "description": "Platzi Avatars from Intro to Dapp development @ platzi.com",',
                '"image":"',
                //TODO: get image url,
                '", "background-color":"6f6eb4", "youtube_url":"https://www.youtube.com/watch?v=dQw4w9WgXcQ"},',
                '"attributes": [',
                '{"display_type":"date","trait_type":"birthday","value":',
                block.timestamp,
                '},',
                '{"trait_type":"Accessories","value":""},{"trait_type":"Clothe Color","value":""},{"trait_type":"Clothe Type","value":""},{"trait_type":"Eye Type","value":""},{"trait_type":"Eyebrow Type","value":""},{"trait_type":"Facial Hair Color","value":""},{"trait_type":"Facial Hair Type","value":""},{"trait_type":"Hair Color","value":""},{"trait_type":"Hat Color","value":""},{"trait_type":"Graphic Type","value":""},{"trait_type":"Mouth Type","value":""},{"trait_type":"Skin Color","value":""},{"trait_type":"Top Type","value":""}',
                ']'
                )
            );

        return string(abi.encodePacked("data:application/json;base64,",jsonURI));
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}