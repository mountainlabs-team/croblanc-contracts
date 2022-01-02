// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./CroblancToken.sol";

//----------------------------------------------------------------------------------------------------------------------
//        _
//       / \      _-'
//     _/|  \-''- _ /
//__-' { |          \      *** CroblancAirdropPriority ***
//    /             \
//    /       "O.  |O }
//    |            \ ;
//                  ',
//       \_         __\
//         ''-_    \.//
//           / '-____'
//          /
//        _'
//      _-'
//----------------------------------------------------------------------------------------------------------------------
contract CroblancAirdropPriority is Ownable {

    CroblancToken public croblanc;
    bool public isAirdropSent;

    constructor () public {
        croblanc = CroblancToken(0xD3ceCBE5639D05Aed446Da11F08D495CA6bF359F);
        isAirdropSent = false;
    }

    function airdrop() external onlyOwner {
        require(!isAirdropSent);

        // Commented lines already received their airdrop manually
        
        croblanc.mint(0x06C4bb82D8Dd291e9A642FE5cFA92408A4A7aD20, 10722e16);
        //croblanc.mint(0x0810818C20C456C429CE9139a0Dde0946a8c7D0D, 10722e16);
        croblanc.mint(0x0d2A70B0A88E2E067920851Ed2CCc12a3eD2Cd60, 10722e16);
        croblanc.mint(0x0f4703D991f9E81AaCafcd6752b0F68cE4a894D3, 10722e16);
        croblanc.mint(0x21234195BEAE86d7dcf4A5EDDbdE675919fF5978, 10722e16);
        croblanc.mint(0x26461826Ae1D61666E3E01ee1DD0AF4359380018, 10722e16);
        //croblanc.mint(0x2831CD2f426b2139979DBB23990453fdfF6baA12, 10722e16);
        croblanc.mint(0x2aDdE568bbCab1ad53b5A339544BC8eD6B21C1F3, 10722e16);
        croblanc.mint(0x2E49e9780C241A0e2255A122004FBf9B0E9503A1, 10722e16);
        croblanc.mint(0x2f06372aed1e343E095e86Fd2101F716d71f9D1F, 10722e16);
        croblanc.mint(0x2F32389a57e33c4eaD593929B920a25acE20641D, 10722e16);
        //croblanc.mint(0x31f68DB5F17360E28799723C3077CbabA20d9BD3, 10722e16);
        croblanc.mint(0x383AF578a7746CD150D6aF69f8Dc2F99Cfccf275, 10722e16);
        croblanc.mint(0x493d449Be6D7Cdd17A34AC69f854912404aB16E5, 10722e16);
        croblanc.mint(0x500b9002430aA941060c9b1B6423FBF6208F7b50, 10722e16);
        croblanc.mint(0x5b427789c374b07b39ed079F30EF594841AFe1E9, 10722e16);
        croblanc.mint(0x5E60aBcFBaf22Eb8a193a7926b54a2FA740BAB51, 10722e16);
        croblanc.mint(0x6223B014eBe343b386a57b83202A70a5B364bcD1, 10722e16);
        croblanc.mint(0x6522808D21CcBD1E3dA6b276859c177Bf5Cb9d13, 10722e16);
        croblanc.mint(0x6B236d9a01A5Aa4435eEE9AB5BCBFEB3c977FE56, 10722e16);
        croblanc.mint(0x6D2d4b25AF931919c494dC8bf9cD708b53592e0f, 10722e16);
        croblanc.mint(0x7890517fd57Dc7de2580a5e0C4F44F13eDF50A3e, 10722e16);
        croblanc.mint(0x7B18B64a91ad258573dCf8dfcDe8F8c6cCE3230C, 10722e16);
        //croblanc.mint(0x7Ce15aa51831De822783c6Fbd8956bA56fCA944B, 10722e16);
        croblanc.mint(0x87456e2541B0C8A7Fc63c6145a05c2bCbf6015D5, 10722e16);
        croblanc.mint(0x88C569099768baf39c199BF0940156D10ffb53F0, 10722e16);
        croblanc.mint(0x8cfe1Aded44BdcA81B6D2d657bBaE43D701521F3, 10722e16);
        croblanc.mint(0x932BA6448cB682e62c74B72370c0C63579119ad6, 10722e16);
        croblanc.mint(0x960d3d2eeaA43A0c645c759286c7919e5Fc78B04, 10722e16);
        croblanc.mint(0x9886E819BCBE453451Fd15Bfa26d09E7177BcE4f, 10722e16);
        croblanc.mint(0x994DC09b18c2826e98e695830322805938222888, 10722e16);
        croblanc.mint(0x9A91E36D4933e61e5351852cb954b8275694A08C, 10722e16);
        croblanc.mint(0xa2b4c41451943E4Aa8d668eb4643e587acE61209, 10722e16);
        croblanc.mint(0xA8a0d398A05523FB5271B9970E5D0B280F12E098, 10722e16);
        croblanc.mint(0xa9B66EEA9C5d4f08c389CBF1e5142009F07996cD, 10722e16);
        croblanc.mint(0xadA4921CD5Ef8B39494532F1cB7A181f51fA3976, 10722e16);
        //croblanc.mint(0xb01335C776C661427BF71b84628a2B050b2c7772, 10722e16);
        //croblanc.mint(0xB1882f606758c5362d094CE3c3f0542b9ABfCfA7, 10722e16);
        croblanc.mint(0xB32E85e03a33e18452288A54aBCd7d52561CcA3d, 10722e16);
        //croblanc.mint(0xBb22964b8519FB17B60543CBda117207474deF8c, 10722e16);
        croblanc.mint(0xc13eDD7ceBe2af622F4291C9CEAfA71d7357341C, 10722e16);
        croblanc.mint(0xC39f531F8a1d841016816e93b3310727500790C4, 10722e16);
        croblanc.mint(0xcdaa7494c029833781C5957229243b3E4Ea5072D, 10722e16);
        //croblanc.mint(0xD26849f36B1d263A2974c5A141ff30e38C925636, 10722e16);
        croblanc.mint(0xD654717b1D686446A7C62613bE29852991cf9462, 10722e16);
        croblanc.mint(0xda38ce0505Eb1B91bF190C620fF1e7183f3C0d89, 10722e16);
        croblanc.mint(0xdd3Fb1acB6d176852e70aA736E9Ef11Ec6D2B251, 10722e16);
        croblanc.mint(0xdf7bF8629f44A99A0eA35829AAA3748a08d74734, 10722e16);
        croblanc.mint(0xe4611eAD167DcF3aa72acB9dc24E5A0aCB4E6de4, 10722e16);
        croblanc.mint(0xE6976e89a739221744FF34A2eD6A9Fb5B4674b15, 10722e16);
        croblanc.mint(0xe70f9f5292bD64Ca47446132f5bbc41C98E950ae, 10722e16);
        croblanc.mint(0xf533FF8b1d662219aE950b8b6E6f2201cCA427b0, 10722e16);
        croblanc.mint(0xF86e5b09ee6F06127Fec9632EDE93175E7cf2684, 10722e16);
        croblanc.mint(0xf8B961b0356169b27F810C137f8FE95a871ED19A, 10722e16);
        //croblanc.mint(0xf8f5C3FA26De6b576Ade16216963d16963c8Fd92, 10722e16);
        croblanc.mint(0xFaAb5615d353691Fbe9B3d973fe89E20E20FDFfb, 10722e16);
        croblanc.mint(0xfE20b09a7291BD0832724ea0Bc9B00539C661E02, 10722e16);

        isAirdropSent = true;
    }
}
