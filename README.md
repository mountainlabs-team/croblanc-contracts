# Croblanc

CROBLANC is a DeFi Yield aggregator exclusively available on Cronos that comes on top of the most famous platforms such as VVSFinance, CronaSwap and Crodex, offering various types of pools:

- Stochastic yield: the emission speed of CROBLANC tokens depends on its market price, in order to keep it sustainable
- Classic pools, offering a dual yield CROBLANC + VVS/CRONA/CRX
- Autocompound pools, offering an auto compounding similar to Autofarm but with extra CROBLANC yield
- Autoswap pools, offering an innovative way to farm A-tier tokens such as BTC, ETH, CRO with stablecoins deposits.

CROBLANC also offers to its hodlers dividends paid in $CROBLANC that comes from a small performance fee that is charged on the generated yield. The supply is limited to 100 million tokens.

### Disclosed source code

CROBLANC is not entirely open-source. However, we publish the core Smart Contracts source code here.

Furthermore, to keep all our users safe, Farms contracts will be entirely disclosed after we finish the auditing process.

### Deployed Contracts (Cronos mainnet)

| Contract | Address |
| ----------- | ----------- |
| CroblancToken | [`0xD3ceCBE5639D05Aed446Da11F08D495CA6bF359F`](https://cronos.crypto.org/explorer/address/0xD3ceCBE5639D05Aed446Da11F08D495CA6bF359F) |
| CroblancTreasury | [`0xb20234c33337537111f4ab6f5EcaD400134aC143`](https://cronos.crypto.org/explorer/address/0xb20234c33337537111f4ab6f5EcaD400134aC143) |
| CroblancTimelock | [`0x47eC5085c8D544a42Baf966ee97cC54a7503b996`](https://cronos.crypto.org/explorer/address/0x47eC5085c8D544a42Baf966ee97cC54a7503b996) |
| CroblancDividends | [`0x20f2F2eb16fDca2fA53EaDc8A471a3F19E5923CA`](https://cronos.crypto.org/explorer/address/0x20f2F2eb16fDca2fA53EaDc8A471a3F19E5923CA) |
| CroblancPrivateSale | [`0x687Ffc1327dB761791d7A7fE8e4310004292E0a1`](https://cronos.crypto.org/explorer/address/0x687Ffc1327dB761791d7A7fE8e4310004292E0a1) |
| CroblancPublicSale | [`0x2615cB937901F904A4f550E30fD010EdCD8F0420`](https://cronos.crypto.org/explorer/address/0x2615cB937901F904A4f550E30fD010EdCD8F0420) |
| CroblancAlpha | [`0x52a87ef19e4a0E8cc70aE69D22bc8254bc6fa0F9`](https://cronos.crypto.org/explorer/address/0x52a87ef19e4a0E8cc70aE69D22bc8254bc6fa0F9) |

Active farms (v3):

| Pair | Platform | Address |
| ----------- | ----------- | -----------
| WCRO-CROBLANC | Cronaswap | [`0x4c1EC4Bf75CdFAF9b172e94cc85b7a8eA647F267`](https://cronos.crypto.org/explorer/address/0x4c1EC4Bf75CdFAF9b172e94cc85b7a8eA647F267) |
| USDC-CRONA | Cronaswap | [`0x1E767e41f2613685397055fe072e7D5B18E40aaB`](https://cronos.crypto.org/explorer/address/0x1E767e41f2613685397055fe072e7D5B18E40aaB) |
| USDC-USDT | Cronaswap | [`0xCC63ddc9c71c8d29A45520ccb64DF0E167d961A2`](https://cronos.crypto.org/explorer/address/0xCC63ddc9c71c8d29A45520ccb64DF0E167d961A2) |
| WCRO-CRONA | Cronaswap | [`0xC9dF9b25EC434334Ad0d5bA1F79dB7bab30E3c31`](https://cronos.crypto.org/explorer/address/0xC9dF9b25EC434334Ad0d5bA1F79dB7bab30E3c31) |
| USDT-BUSD | Cronaswap | [`0x7cF8AAdA8366dF57a78817Cb326bc67caa8576dc`](https://cronos.crypto.org/explorer/address/0x7cF8AAdA8366dF57a78817Cb326bc67caa8576dc) |
| WETH-WBTC | Cronaswap | [`0x701C1B1092B0925dCE16AB8129f8F6973E734638`](https://cronos.crypto.org/explorer/address/0x701C1B1092B0925dCE16AB8129f8F6973E734638) |
| WCRO-VVS | VVS Finance | [`0x28Ebd5E0C0d2a495EeAD97bfF3bBd44C571D14B4`](https://cronos.crypto.org/explorer/address/0x28Ebd5E0C0d2a495EeAD97bfF3bBd44C571D14B4) |
| WCRO-WETH | VVS Finance | [`0xB71efeF52F4926a1f2A96D318bb58D3e49bF8BEE`](https://cronos.crypto.org/explorer/address/0xB71efeF52F4926a1f2A96D318bb58D3e49bF8BEE) |
| WCRO-WBTC | VVS Finance | [`0x71f8c0c91dc53092C373a4faF27BDA8B4407e94b`](https://cronos.crypto.org/explorer/address/0x71f8c0c91dc53092C373a4faF27BDA8B4407e94b) |
| WCRO-USDC | VVS Finance | [`0xBd372D44b9C3C6671E86260853aA09232768991F`](https://cronos.crypto.org/explorer/address/0xBd372D44b9C3C6671E86260853aA09232768991F) |
| USDC-VVS | VVS Finance | [`0xd31742d3AC6C131567c405750290c6C322B26f58`](https://cronos.crypto.org/explorer/address/0xd31742d3AC6C131567c405750290c6C322B26f58) |
| USDC-USDT | VVS Finance | [`0x3F75EDdf8233BC83A38C1232192c80a216f112B2`](https://cronos.crypto.org/explorer/address/0x3F75EDdf8233BC83A38C1232192c80a216f112B2) |
| USDC-CROW | CrowFi | [`0xfB2a3bf98A2e87169f61A1FE73D45bFEdCE11061`](https://cronos.crypto.org/explorer/address/0xfB2a3bf98A2e87169f61A1FE73D45bFEdCE11061) |
| CRO-CROW | CrowFi | [`0x65783610B767465fB31A1c407Cbe8a089Bbf3B06`](https://cronos.crypto.org/explorer/address/0x65783610B767465fB31A1c407Cbe8a089Bbf3B06) |
| CRO-USDC | CrowFi | [`0x31Cfb30bd56De31252cF759Ad31E1786ef4a19Dd`](https://cronos.crypto.org/explorer/address/0x31Cfb30bd56De31252cF759Ad31E1786ef4a19Dd) |

Deprecated farms:

| Pair | Platform | Address |
| ----------- | ----------- | -----------
| USDC-USDT old v2 | Cronaswap | [`0x0Bd9bE31d9cFa74E89311721eaF87AeEF34127B2`](https://cronos.crypto.org/explorer/address/0x0Bd9bE31d9cFa74E89311721eaF87AeEF34127B2) |
| WCRO-CRONA old v2 | Cronaswap | [`0xEdFE592F5b7e4e44e4Fd6Bc3A703F36350505213`](https://cronos.crypto.org/explorer/address/0xEdFE592F5b7e4e44e4Fd6Bc3A703F36350505213) |
| USDT-BUSD old v2 | Cronaswap | [`0x81E8ab5e873EDE607fCF1baCa88d8Bb234403397`](https://cronos.crypto.org/explorer/address/0x81E8ab5e873EDE607fCF1baCa88d8Bb234403397) |
| WETH-WBTC old v2 | Cronaswap | [`0xe60E7Cc547b029eF1D46357259784C688328C5c0`](https://cronos.crypto.org/explorer/address/0xe60E7Cc547b029eF1D46357259784C688328C5c0) |
| WCRO-VVS old v2 | VVS Finance | [`0x559685a13FC831341bb6d68C00b4994604232344`](https://cronos.crypto.org/explorer/address/0x559685a13FC831341bb6d68C00b4994604232344) |
| WCRO-WETH old v2 | VVS Finance | [`0xc179d291f693a7A0F59E3B5D269C637565E2f67f`](https://cronos.crypto.org/explorer/address/0xc179d291f693a7A0F59E3B5D269C637565E2f67f) |
| WCRO-WBTC old v2 | VVS Finance | [`0x42CB5845Aca6ed2AD718EB1Ea96b06FD9c90b639`](https://cronos.crypto.org/explorer/address/0x42CB5845Aca6ed2AD718EB1Ea96b06FD9c90b639) |
| WCRO-USDC old v2 | VVS Finance | [`0xcbddF46D4A3e8fc4b7cD3335A33F6B267CaBE0e1`](https://cronos.crypto.org/explorer/address/0xcbddF46D4A3e8fc4b7cD3335A33F6B267CaBE0e1) |
| USDC-VVS old v2 | VVS Finance | [`0x12b11b712579C87a54Dcd31012F47caA431DA1E4`](https://cronos.crypto.org/explorer/address/0x12b11b712579C87a54Dcd31012F47caA431DA1E4) |
| USDC-USDT old v2 | VVS Finance | [`0x16750E6eC910aF944B7F194e8c1BC6DDB9e19E52`](https://cronos.crypto.org/explorer/address/0x16750E6eC910aF944B7F194e8c1BC6DDB9e19E52) |
| USDC-USDT old v1 | Cronaswap | [`0xf654280AbBEaed6192AEA26d422487b0AD666Fce`](https://cronos.crypto.org/explorer/address/0xf654280AbBEaed6192AEA26d422487b0AD666Fce) |
| WCRO-CRONA old v1 | Cronaswap | [`0x267f568Cfd7035E801509CeE19A7FEb2c62f62f3`](https://cronos.crypto.org/explorer/address/0x267f568Cfd7035E801509CeE19A7FEb2c62f62f3) |
| USDT-BUSD old v1 | Cronaswap | [`0x7d53Ad113BEE7163Ea2B14A50fC98F2E246b5079`](https://cronos.crypto.org/explorer/address/0x7d53Ad113BEE7163Ea2B14A50fC98F2E246b5079) |
| WETH-WBTC old v1 | Cronaswap | [`0x7F0E67768c122DA76b4438f7a7fABfD834bDBa2C`](https://cronos.crypto.org/explorer/address/0x7F0E67768c122DA76b4438f7a7fABfD834bDBa2C) |


### Join the community

Twitter: https://twitter.com/croblancdotcom
Telegram Community group: https://t.me/croblanc_cm
Telegram Announcements channel: https://t.me/croblancdotcom
