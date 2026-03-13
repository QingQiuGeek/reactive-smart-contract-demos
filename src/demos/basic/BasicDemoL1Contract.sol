// SPDX-License-Identifier: GPL-2.0-or-later

// 源链合约

pragma solidity >=0.8.0;

contract BasicDemoL1Contract {
    event Received(
        address indexed origin,
        address indexed sender,
        uint256 indexed value
    );

/*
用户向该合约发送 ETH，触发 receive()，发出 Received 事件（这就是 Reactive Contract订阅的事件），
立即把收到的 ETH 退还给 tx.origin
*/
    receive() external payable {
        emit Received(
            tx.origin,//交易链的最初发起者，永远是 EOA（外部账户），不是该合约地址
            msg.sender,//当前合约地址
            msg.value
        );
        // payable(tx.origin).transfer(msg.value);
        (bool success, ) = payable(tx.origin).call{value: msg.value}("");
        require(success, "ETH transfer failed");
    }
}

/**
 * 用户发送 ETH → BasicDemoL1Contract
                        ↓
                  emit Received(...)   ← Reactive 网络监听此事件
                        ↓
            Reactive 合约检测到 value ≥ 0.001 ETH
                        ↓
            触发回调到 BasicDemoL1Callback
 */