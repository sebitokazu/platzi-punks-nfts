//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";//Delete on deployment to reduce file size TODO: optimize code
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Base64.sol";
import "./ADNBase.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract PlatziPunks is ERC721, ERC721Enumerable, ADNBase, VRFConsumerBase {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIdCounter;
    uint256 public maxSupply;
    mapping(uint256 => uint256) public tokenDNA;
    mapping(bytes32 => uint256) private tokenRandomnessResult;
    mapping(uint256 => address) private tokenMinter;

    bytes32 private _keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
    uint256 private _oracleFee = 0.1 * 10 ** 18; // 0.1 LINK


    constructor(uint256 _maxSupply) 
    ERC721("PlatziPunks", "PLPKS") 
    VRFConsumerBase(0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, 0x01BE23585060835E02B77ef475b0Cc51aA1e0709) {
        maxSupply = _maxSupply;
    }

    function mint() public {
        uint256 tokenId = _tokenIdCounter.current();
        require(tokenId < maxSupply, "All PlatziPunks are minted.");
        bytes32 requestId = getRandomNumber();
        tokenRandomnessResult[requestId] = tokenId;
        tokenMinter[tokenId] = msg.sender;
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
                    "&hairColor=",
                    getHairColor(_dna),
                    "&hatColor=",
                    getHatColor(_dna)
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

     /** 
     * Requests randomness 
     */
    function getRandomNumber() internal returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= _oracleFee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(_keyHash, _oracleFee);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        uint256 tokenId = tokenRandomnessResult[requestId];
        tokenDNA[tokenId] = getDNA(tokenId, tokenMinter[tokenId], randomness);
    }
}
