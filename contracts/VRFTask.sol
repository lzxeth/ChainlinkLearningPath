// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

/*
 * 任务 2：
 * 通过 requestRandomWords 函数，从 Chainlink VRF 获得随机数
 * 通过 fulfillRandomWords 函数给 s_randomness[] 填入 5 个随机数
 * 保证 5 个随机数为 5 以内，并且不重复
 * 参考视频教程： https://www.bilibili.com/video/BV1ed4y1N7Uv
 *
 * 任务 2 完成标志：
 * 1. 通过命令 "yarn hardhat test" 使得单元测试 8-10 通过
 * 2. 通过 Remix 在 goerli 测试网部署，并且测试执行是否如预期
 */

contract VRFTask is VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface public immutable COORDINATOR;

    /*
     * 步骤 1 - 获得 VRFCoordinator 合约的地址和所对应的 keyHash
     * 修改变量
     *   CALL_BACK_LIMIT：回调函数最大 gas 数量
     *   REQUEST_CONFIRMATIONS：最小确认区块数
     *   NUM_WORDS：单次申请随机数的数量
     *
     * 注意：
     * 通过 Remix 部署在非本地环境时，相关参数请查看
     * https://docs.chain.link/docs/vrf/v2/supported-networks/，获取 keyHash 的指和 vrfCoordinator 的地址
     * 本地环境在测试脚本中已经自动配置
     *
     */

    // Chainlink VRF 在接收到请求后，会通过 fulfillRandomWords 将数据写回到用户合约，此过程需要消耗 gas
    // CALL_BACK_LIMIT 是回调函数可以消耗的最大 gas，根据回调函数的逻辑适当调整 CALL_BACK_LIMIT
    // 详情请查看：https://docs.chain.link/vrf/v2/subscription/examples/get-a-random-number#analyzing-the-contract
    //
    // **********************************************
    // 第一次设置错误200，合约部署后执行requestRandomWords函数需要消耗0.5左右的gas，这就是异常了，
    // 执行几次都最后都失败了，并且vrf.chain.link内看不到请求记录
    // **********************************************
    uint32 constant CALL_BACK_LIMIT = 200000;

    // Chainlink VRF 在返回随机数之前应该等待的 Confirmation，值越大，返回的值越安全
    // 最小是3
    uint16 constant REQUEST_CONFIRMATIONS = 3;

    // Chainlink VRF 在每次请求后返回的随机数数量
    uint32 constant NUM_WORDS = 5;

    // 非本地环境部署，构造函数需要对 s_subscriptionId 和 s_keyHash 赋值（本地测试时不需要配置）
    // s_subscriptionId 是 VRF subscription ID（订阅 ID）
    // 在这里创建并且获得 subscription id https://vrf.chain.link/
    uint64 public immutable s_subscriptionId;
    // s_keyHash 是 VRF 的 gas Lane，决定回调时所使用的 gas price
    // 在这里查看  https://docs.chain.link/vrf/v2/subscription/supported-networks
    bytes32 public immutable s_keyHash;

    uint256[] public s_randomWords;
    uint256[] public fulfillSrcRandomWords; // fulfill src randomwords
    uint256 public s_requestId;

    address s_owner;

    event ReturnedRandomness(uint256[] randomWords);

    modifier onlyOwner() {
        require(msg.sender == s_owner);
        _;
    }

    /**
     * 步骤 2 - 在构造函数中，初始化相关变量
     * COORDINATOR，s_subscriptionId 和 s_keyHash
     *
     * COORDINATOR: 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D
     * keyHash : 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15
     * */
    constructor(
        uint64 _subscriptionId,
        address vrfCoordinator,
        bytes32 _keyHash
    ) VRFConsumerBaseV2(vrfCoordinator) {
        s_owner = msg.sender;

        //修改以下 solidity 代码
        s_subscriptionId = _subscriptionId;
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_keyHash = _keyHash;
    }

    /**
     * 步骤 3 - 发送随机数请求
     * bytes32 _keyHash,
     * uint64 _subId,
     * uint16 _minimumRequestConfirmations,
     * uint32 _callbackGasLimit,
     * uint32 _numWords
     * */
    function requestRandomWords() external onlyOwner {
        //在此添加并且修改 solidity 代码
        s_requestId = COORDINATOR.requestRandomWords(
            s_keyHash,
            s_subscriptionId,
            REQUEST_CONFIRMATIONS,
            CALL_BACK_LIMIT,
            NUM_WORDS
        );
    }

    /**
     * 步骤 4 - 接受随机数，完成逻辑获取 5 个 5 以内**不重复**的随机数
     * 关于如何使得获取的随机数不重复，清参考以下代码
     * https://gist.github.com/cleanunicorn/d27484a2488e0eecec8ce23a0ad4f20b
     *
     * Goerli合约地址: 0x973773e36E56595144Dfed0cb7b1c430EC337536
     *  */
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory _randomWords
    ) internal override {
        //在此添加 solidity 代码
        fulfillSrcRandomWords = _randomWords;
        s_randomWords = shuffle(5, fulfillSrcRandomWords[0]);

        emit ReturnedRandomness(s_randomWords);
    }

    /**
     * @dev 返回随机数
     * @param size 输出数组的大小
     * @param entropy 初始化时使用的随机数
     * @return 返回一个长度为 size 的无符号整数数组，其中包含数字1到 size 的随机排列。
     */
    function shuffle(
        uint size,
        uint entropy
    ) public pure returns (uint[] memory) {
        uint[] memory result = new uint[](size);

        // Initialize array.
        for (uint i = 0; i < size; i++) {
            result[i] = i + 1;
        }

        // Set the initial randomness based on the provided entropy.
        bytes32 random = keccak256(abi.encodePacked(entropy));

        // Set the last item of the array which will be swapped.
        uint last_item = size - 1;

        // We need to do `size - 1` iterations to completely shuffle the array.
        for (uint i = 1; i < size - 1; i++) {
            // Select a number based on the randomness.
            uint selected_item = uint(random) % last_item;

            // Swap items `selected_item <> last_item`.
            uint aux = result[last_item];
            result[last_item] = result[selected_item];
            result[selected_item] = aux;

            // Decrease the size of the possible shuffle
            // to preserve the already shuffled items.
            // The already shuffled items are at the end of the array.
            last_item--;

            // Generate new randomness.
            random = keccak256(abi.encodePacked(random));
        }

        return result;
    }
}
