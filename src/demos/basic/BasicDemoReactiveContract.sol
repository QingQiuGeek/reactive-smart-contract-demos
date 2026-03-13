// SPDX-License-Identifier: UNLICENSED

//响应式合约，监听源链合约，也就是BasicDemoL1Contract合约的事件

pragma solidity >=0.8.0;

import '../../../lib/reactive-lib/src/interfaces/IReactive.sol';
import '../../../lib/reactive-lib/src/abstract-base/AbstractReactive.sol';
import '../../../lib/reactive-lib/src/interfaces/ISystemContract.sol';

contract BasicDemoReactiveContract is IReactive, AbstractReactive {

    uint256 public originChainId;
    uint256 public destinationChainId;
    uint64 private constant GAS_LIMIT = 1000000;

    address private callback;//目的链上回调合约地址（BasicDemoL1Callback）

    // 构造函数部署时通过命令行或环境变量传入
    constructor(
        address _service,// 系统合约地址
        uint256 _originChainId,
        uint256 _destinationChainId,
        address _contract,// 源链上被监听的合约（BasicDemoL1Contract）
        uint256 _topic_0,// 要监听的事件签名
        address _callback
    ) payable {
        service = ISystemContract(payable(_service));

        originChainId = _originChainId;
        destinationChainId = _destinationChainId;
        callback = _callback;

        if (!vm) {
            service.subscribe(
                originChainId,
                _contract,
                _topic_0,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE
            );
        }
    }

/**
 *
vmOnly：只能由 RVM（Reactive 虚拟机）调用
log：捕获到的源链事件日志

实现IReactive接口的react函数，当Reactive Network检测到符合条件的事件时，会自动调用这个函数，并传入事件日志信息。

检查 log.topic_3 >= 0.001 ether（即转账金额 ≥ 0.001 ETH）
条件满足时，构造 callback(address) 的调用数据
发出 Callback 事件，告诉 Reactive Network 向目的链发送回调
 */
    function react(LogRecord calldata log) external vmOnly {

        if (log.topic_3 >= 0.001 ether) {
            // 函数签名，会被哈希取前 4 字节作为 selector，当 Reactive Network 收到 Callback 事件后，
            // 会用这个 payload 去调用目的链上的 BasicDemoL1Callback.callback(address(0))
            // address(0) 是一个占位符
            bytes memory payload = abi.encodeWithSignature("callback(address)", address(0));
            emit Callback(destinationChainId, callback, GAS_LIMIT, payload);
        }
    }
}