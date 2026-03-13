// SPDX-License-Identifier: GPL-2.0-or-later

// 目的链合约

pragma solidity >=0.8.0;

import '../../../lib/reactive-lib/src/abstract-base/AbstractCallback.sol';

contract BasicDemoL1Callback is AbstractCallback {

    //定义接受回调的事件
    event CallbackReceived(
        address indexed origin,
        address indexed sender,
        address indexed reactive_sender
    );

    constructor(address _callback_sender) AbstractCallback(_callback_sender) payable {}

    function callback(address sender)
        external
        authorizedSenderOnly//msg.sender 必须在授权列表里。确保只有这个 proxy 地址能调用回调，防止恶意调用。
        rvmIdOnly(sender)//sender 必须等于初始化记录的 rvm_id
    {
        emit CallbackReceived(
            tx.origin,
            msg.sender,//BasicDemoL1Callback 合于自己的地址
            sender
        );
    }
}
