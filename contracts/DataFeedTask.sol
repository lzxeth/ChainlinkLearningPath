// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.7;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/*
 * 任务 1：
 * 通过 Chainlink Data Feed 获得 link，eth 和 btc 的 usd 价格
 * 参考视频教程：https://www.bilibili.com/video/BV1ed4y1N7Uv?p=3
 *
 * 任务 1 完成标志：
 * 1. 通过命令 "yarn hardhat test" 使得单元测试 1-7 通过
 * 2. 通过 Remix 在 goerli 测试网部署，并且测试执行是否如预期
 */

contract DataFeedTask {
    AggregatorV3Interface internal linkPriceFeed;
    AggregatorV3Interface internal btcPriceFeed;
    AggregatorV3Interface internal ethPriceFeed;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * 步骤 1 - 在构造这里初始化 3 个 Aggregator
     *
     * 注意：
     * 通过 Remix 部署在非本地环境中时
     * 查看 aggregator 的地址 https://docs.chain.link/docs/ethereum-addresses/#Goerli%20Testnet，获得 Aggregator 合约地址
     * 本地环境中相关参数已经在测试脚本中配置
     *  */
    constructor(
        address _linkPriceFeed,
        address _btcPriceFeed,
        address _ethPriceFeed
    ) {
        owner = msg.sender;

        //修改以下 solidity 代码
        // 0x48731cF7e84dc94C5f84577882c14Be11a5B7456
        // 0xA39434A63A52E749F02807ae27335515BA4b07F7
        // 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
        linkPriceFeed = AggregatorV3Interface(_linkPriceFeed);
        btcPriceFeed = AggregatorV3Interface(_btcPriceFeed);
        ethPriceFeed = AggregatorV3Interface(_ethPriceFeed);
    }

    /**
     * 步骤 2 - 完成 getLinkLatestPrice 函数
     * 获得 link/usd 的价格数据
     */
    function getLinkLatestPrice() public pure returns (int256) {
        //在此添加并且修改 solidity 代码
        return 100000000000000000000;
    }

    /**
     * 步骤 3 - 完成 getBtcLatestPrice 函数
     * 获得 btc/usd 的价格数据
     */
    function getBtcLatestPrice() public pure returns (int256) {
        //在此添加并且修改 solidity 代码
        return 200000000000000000000;
    }

    /**
     * 步骤 4 - 完成 getEthLatestPrice 函数
     * 获得 eth/usd 的价格数据
     */
    function getEthLatestPrice() public pure returns (int256) {
        //在此添加并且修改 solidity 代码
        return 300000000000000000000;
    }

    /**
     * 步骤 5 - 通过 Remix 将合约部署合约（使用 goerli 网络）
     *
     * 任务成功标志：
     * 合约部署成功
     * 获取 link/usd, btc/usd, eth/usd 价格
     *
     * Goerli合约地址：0x9C7C042e15b874F09df41bB69B9fa6d9dcc7060e
     */

    function getLinkPriceFeed() public view returns (int256) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = linkPriceFeed.latestRoundData();
        return price;
    }

    function getBtcPriceFeed() public view returns (int256) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = btcPriceFeed.latestRoundData();
        return price;
    }

    function getEthPriceFeed() public view returns (int256) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = ethPriceFeed.latestRoundData();
        return price;
    }
}
