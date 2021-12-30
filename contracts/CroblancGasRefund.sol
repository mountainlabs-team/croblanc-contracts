// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

//----------------------------------------------------------------------------------------------------------------------
//        _
//       / \      _-'
//     _/|  \-''- _ /
//__-' { |          \       *** CroblancGasRefund ***
//    /             \
//    /       "O.  |O }     Gas refund snapshot on 30/12/2021 14:40 UTC.
//    |            \ ;      For eligible addresses who withdrawn from an old farm and deposited again into a v3 farm.
//                  ',
//       \_         __\
//         ''-_    \.//
//           / '-____'
//          /
//        _'
//      _-'
//----------------------------------------------------------------------------------------------------------------------
contract CroblancGasRefund {

    constructor () public {
    }

    function sendRefunds() external payable {
        require(msg.value == 861e18);
        payable(0xadA4921CD5Ef8B39494532F1cB7A181f51fA3976).transfer(10 * 7e18);
        payable(0xC89721A64703e4a1830Ea3b71e20dF9eAD5b19e9).transfer(1 * 7e18);
        payable(0xda38ce0505Eb1B91bF190C620fF1e7183f3C0d89).transfer(1 * 7e18);
        payable(0x3EB1686b9D0001F1703717E2362EeB3553A64060).transfer(1 * 7e18);
        payable(0xD5038a4e2478aa3C9E51445FeB7A9508B879916b).transfer(1 * 7e18);
        payable(0x88d629f774e9fe4a0712fa9F2C120e4854DEA2d4).transfer(1 * 7e18);
        payable(0x6B236d9a01A5Aa4435eEE9AB5BCBFEB3c977FE56).transfer(1 * 7e18);
        payable(0x8C96B0f76E5b31D62FbB4C3e0866b76D692d1048).transfer(1 * 7e18);
        payable(0x5353928D701147A981020613f95e8246ed262580).transfer(1 * 7e18);
        payable(0x8f144A2EA4f21B0e5c2D440b9c56b4EDFD53b057).transfer(4 * 7e18);
        payable(0x0810818C20C456C429CE9139a0Dde0946a8c7D0D).transfer(1 * 7e18);
        payable(0xeB31b91dDed47a8c9b177C3957DdFE73206b2653).transfer(1 * 7e18);
        payable(0x55d7cA091cE87e3eD5082D6fC89275DD7F321CA3).transfer(1 * 7e18);
        payable(0x63Bd961414548499dDB9358566daa0a9eD967428).transfer(1 * 7e18);
        payable(0xbfd603006fbbf0065915d6107e5E99fcA3b90af4).transfer(1 * 7e18);
        payable(0x230D6A1d1C454c634E81A7b725500b67bA3ACA18).transfer(1 * 7e18);
        payable(0xf308406173Ee51e10e33e19759BCa30844574E92).transfer(1 * 7e18);
        payable(0x5EeDe1C45E4401d7D95E55446dAd71B511328534).transfer(1 * 7e18);
        payable(0x6630E360439dF7be3f1E0EDd217EB0a2eE8Fa9b8).transfer(1 * 7e18);
        payable(0x793646171f7Fa0440429B3e8b25C2e12Cc397477).transfer(1 * 7e18);
        payable(0xC39f531F8a1d841016816e93b3310727500790C4).transfer(1 * 7e18);
        payable(0xEB1B7C571ACBd461db3386eE6A3FBe4D375788E9).transfer(3 * 7e18);
        payable(0x872edaa66681780EdbBCbdF25b8139D44817C789).transfer(2 * 7e18);
        payable(0xC031E96afA8130Be8859a6FD3fe368eE8069B60F).transfer(1 * 7e18);
        payable(0x960d3d2eeaA43A0c645c759286c7919e5Fc78B04).transfer(1 * 7e18);
        payable(0x649C92A98B8c163de6bba53EFfD55ad2d89553B7).transfer(1 * 7e18);
        payable(0x4A35a54B1E50511cc994AEf82366e133F5ca2e1C).transfer(5 * 7e18);
        payable(0xA8a0d398A05523FB5271B9970E5D0B280F12E098).transfer(1 * 7e18);
        payable(0x41a2aD7d05e38317feAfb81033727d191cdb0d68).transfer(1 * 7e18);
        payable(0x195FBf587364850Da9bb16E7bb04f52126a7fCB9).transfer(1 * 7e18);
        payable(0xA9e02210053575BA837380E271dcB1a935Db9617).transfer(1 * 7e18);
        payable(0x6223B014eBe343b386a57b83202A70a5B364bcD1).transfer(3 * 7e18);
        payable(0x5D4f1254a46D1488C8347089CF73F86C802bc33C).transfer(2 * 7e18);
        payable(0x2229E597d82869BFf1B6F0Ea372f502F6B1E9A1A).transfer(2 * 7e18);
        payable(0x97DC80d42a316D8B5CbF319D5e1e53D8Dfa99De2).transfer(1 * 7e18);
        payable(0x7fFA8901be4777D9fD78F9A00D98DFCDBD833671).transfer(3 * 7e18);
        payable(0x6AB2E1e918820534EaD428D118D9c0d2C9F7fe01).transfer(1 * 7e18);
        payable(0xCCFb8fAd678dEDfa19aD21fD5Fc37Fe8885d1f28).transfer(2 * 7e18);
        payable(0x7aF07403BC2007D68e8f9D518528860cFD040C8A).transfer(1 * 7e18);
        payable(0xB05C1B31E090DFD930b7a1489DaF609132E89a4e).transfer(1 * 7e18);
        payable(0xb1DEa70adC1A87E53e7500D7a0e5D757FAF0dFE8).transfer(1 * 7e18);
        payable(0x7F6d7475fBa09db1fd75b4EB692766e2B157ADB6).transfer(2 * 7e18);
        payable(0x73A5DE038136e9A45B6D01B6e3D9673241b3e6d6).transfer(1 * 7e18);
        payable(0xAD496F76E303E945fabE03aB981654565EDFF952).transfer(1 * 7e18);
        payable(0xC56ca215B42417679eBfE99978215200AA5De8A2).transfer(1 * 7e18);
        payable(0xe2Ad14f95a07652C8113719334c5E244343CD7BD).transfer(1 * 7e18);
        payable(0x240b8F925353E9103cDa3908A013dfC604D15265).transfer(2 * 7e18);
        payable(0x83B7295dEab040bC6a66fAb3BC559E8575EBba6f).transfer(2 * 7e18);
        payable(0x1C2F6f21392a726356504be44CE68698DA1C19E1).transfer(1 * 7e18);
        payable(0xC7a64e98cC0Fc0297438F12d1449450D5f26438b).transfer(1 * 7e18);
        payable(0xEC9C104Db3A97d1504138797384a80740125B190).transfer(1 * 7e18);
        payable(0x9DB7A8f0C6bACC2cc79888D5257aB854604E7909).transfer(1 * 7e18);
        payable(0x21395B1a940F574b7c6231eB1291a094707bF9d8).transfer(1 * 7e18);
        payable(0xbfe31B6820ae6657F8b85d9fA6e50667264deFC6).transfer(1 * 7e18);
        payable(0x0085a2926F3167EC2ECB4d3E41a7e9c881f3ABfb).transfer(1 * 7e18);
        payable(0x9ACCAE40845818A0447A565baa8F089cECA31f7c).transfer(1 * 7e18);
        payable(0xa03F8Fd2B2F89A254D752cEa7723fc6613716b69).transfer(1 * 7e18);
        payable(0x7c5ab0b970d7DC33Eabe2426B32ac86C23109602).transfer(1 * 7e18);
        payable(0x802af7baC3B5194fe0982C4B0E81e8bc995D911F).transfer(1 * 7e18);
        payable(0x5a21E8089483757f9D1B944B1B45DC91Db6da15d).transfer(1 * 7e18);
        payable(0xc64d769eB79d35246b45813365A99c8e92C694a3).transfer(1 * 7e18);
        payable(0x1107602d51193953cFe4cb8a4B01d846e7E426ab).transfer(1 * 7e18);
        payable(0x46B243248e623165497aaD9aBdd73651824897bC).transfer(1 * 7e18);
        payable(0xB0ba884C6AFDE895c2F8Bb08E08E5E9F2829e1C7).transfer(1 * 7e18);
        payable(0x1804c7DEef27F775F2905bAF42a0f3360672DaA1).transfer(1 * 7e18);
        payable(0xfC3bC5c1a6Af3544B67834E13f11BD125dBa03EB).transfer(1 * 7e18);
        payable(0x02b05D206260A39968dEBd4F4F250A33820712ec).transfer(1 * 7e18);
        payable(0xfBB8164ab258CC48288F751b66108910E99b49AD).transfer(1 * 7e18);
        payable(0xed0F5C184146a1d7987E419a5B1399200ba65962).transfer(1 * 7e18);
        payable(0x695eEE934d5cac8E1F754752D06031200Be93038).transfer(1 * 7e18);
        payable(0xa1331a32abC61239f3ddd63eeCc4b0246a2230e6).transfer(1 * 7e18);
        payable(0x3d723C7DD30BB0F8094D0aad40a8143153f166aA).transfer(2 * 7e18);
        payable(0x1950DD9De895035D8ad6Ebd603d9F5669127ccA9).transfer(2 * 7e18);
        payable(0xa2b4c41451943E4Aa8d668eb4643e587acE61209).transfer(1 * 7e18);
        payable(0x83484257aF94d2740EDcb2f9B034D5B5FA61d2ba).transfer(1 * 7e18);
        payable(0xe4611eAD167DcF3aa72acB9dc24E5A0aCB4E6de4).transfer(1 * 7e18);
        payable(0xdd3Fb1acB6d176852e70aA736E9Ef11Ec6D2B251).transfer(1 * 7e18);
        payable(0xFffAc7807747aB8BAe5A384d5b2D053DB4C743f2).transfer(1 * 7e18);
        payable(0x294C3c4F59b7A422230e59700BC0ae11020Aa1c8).transfer(1 * 7e18);
        payable(0x8970129F120560300a20ac2D41963C88471D720D).transfer(1 * 7e18);
        payable(0x62B9A389Be789718dF35440bEAACBD8EB0B7e4d3).transfer(1 * 7e18);
        payable(0xB1BAF0bC8af7D4594450Cf5fbbDbC38C7438F978).transfer(1 * 7e18);
        payable(0x052bB01bA8A4d749E8B14F6c7b208Ee60410cd07).transfer(1 * 7e18);
        payable(0x500b9002430aA941060c9b1B6423FBF6208F7b50).transfer(1 * 7e18);
        payable(0x383AF578a7746CD150D6aF69f8Dc2F99Cfccf275).transfer(1 * 7e18);
        payable(0x5d55C7213E282674400A5e8a4e0b33375590568B).transfer(1 * 7e18);
        payable(0xa45761b4B7E86268dde2F705e96dcaC98AaCFe77).transfer(1 * 7e18);
        payable(0xafBfb8146b4B35d45883643647D66aeb5608cbb4).transfer(1 * 7e18);
        payable(0xb01335C776C661427BF71b84628a2B050b2c7772).transfer(1 * 7e18);
        payable(0x07f2F886B3547B98BD50636306D2836c6C8bE2d9).transfer(1 * 7e18);
        payable(0x65E54A09ed01Fc65EBfC001aB790F3A1bD8e8992).transfer(1 * 7e18);
        payable(0x486A47BbD9c3da9a884761130b1baba46D40B6DC).transfer(1 * 7e18);
    }
}
