//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Base64.sol";
import "./ADNBase.sol";

contract PlatziPunks is ERC721, ERC721Enumerable, ADNBase {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIdCounter;
    uint256 public maxSupply;
    mapping(uint256 => uint256) public tokenDNA;

    constructor(uint256 _maxSupply) ERC721("PlatziPunks", "PLPKS") {
        maxSupply = _maxSupply;
    }

    function mint() public {
        uint256 tokenId = _tokenIdCounter.current();
        require(tokenId < maxSupply, "All PlatziPunks are minted.");
        tokenDNA[tokenId] = getDNA(tokenId, msg.sender, block.number);
        _safeMint(msg.sender, tokenId);
        _tokenIdCounter.increment();
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://avataaars.io/";
    }

    function _paramsURI(uint256 _dna) internal view returns (string memory) {
        string memory params;
        {
            params = string(
                abi.encodePacked(
                    "accessoriesType=",
                    getAccessoriesType(_dna),
                    "&clotheColor=",
                    getClotheColor(_dna),
                    "&clotheType=",
                    getClotheType(_dna),
                    "&eyeType=",
                    getEyeType(_dna),
                    "&eyebrowType=",
                    getEyeBrowType(_dna),
                    "&facialHairColor=",
                    getFacialHairColor(_dna),
                    "&facialHairType=",
                    getFacialHairType(_dna),
                    "&hairColor=",
                    getHairColor(_dna),
                    "&hatColor=",
                    getHatColor(_dna),
                    "&graphicType=",
                    getGraphicType(_dna)
                )
            );
        }

        return
            string(
                abi.encodePacked(
                    params,
                    "&mouthType=",
                    getMouthType(_dna),
                    "&skinColor=",
                    getSkinColor(_dna),
                    "&topType=",
                    getTopType(_dna)
                )
            );
    }

    function _getFullUri(uint256 _dna) public view returns (string memory) {
        return string(abi.encodePacked(_baseURI(), "?", _paramsURI(_dna)));
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721 Metadata: URI query for non-existent query"
        );
        uint256 dna = tokenDNA[_tokenId];

        string memory imgUrl;
        {
            imgUrl = _getFullUri(dna);
        }
        string memory jsonURI;
        string memory attrMetadataPartA;
        string memory attrMetadataPartB;
        {
            jsonURI = string(
                abi.encodePacked(
                    '{ "name": "PlatziPunks #',
                    _tokenId.toString(),
                    '", "description": "Platzi Avatars from Intro to Dapp development @ platzi.com",',
                    '"image":"',
                    imgUrl,
                    '", "background-color":"6f6eb4",',
                    '"attributes": ['
                )
            );
        }
        {
            attrMetadataPartA = string(
                abi.encodePacked(
                    '{"trait_type":"Accessories","value":"',
                    getAccessoriesType(dna),
                    '"},{"trait_type":"Clothe Color","value":"',
                    getClotheColor(dna),
                    '"},{"trait_type":"Clothe Type","value":"',
                    getClotheType(dna),
                    '"},{"trait_type":"Eye Type","value":"',
                    getEyeType(dna),
                    '"},{"trait_type":"Eyebrow Type","value":"',
                    getEyeBrowType(dna),
                    '"},{"trait_type":"Facial Hair Color","value":"',
                    getFacialHairColor(dna),
                    '"},{"trait_type":"Facial Hair Type","value":"',
                    getFacialHairType(dna),
                    '"}'
                )
            );
        }
        {
            attrMetadataPartB = string(
                abi.encodePacked(
                    '{"trait_type":"Hair Color","value":"',
                    getHairColor(dna),
                    '"},{"trait_type":"Hat Color","value":"',
                    getHatColor(dna),
                    '"},{"trait_type":"Graphic Type","value":"',
                    getGraphicType(dna),
                    '"},{"trait_type":"Mouth Type","value":"',
                    getMouthType(dna),
                    '"},{"trait_type":"Skin Color","value":"',
                    getSkinColor(dna),
                    '"},{"trait_type":"Top Type","value":"',
                    getTopType(dna),
                    '"}'
                )
            );
        }

        {
            jsonURI = Base64.encode(
                abi.encodePacked(
                    jsonURI,
                    attrMetadataPartA,
                    ",",
                    attrMetadataPartB,
                    "]}"
                )
            );
        }

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    jsonURI
                )
            );
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
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
