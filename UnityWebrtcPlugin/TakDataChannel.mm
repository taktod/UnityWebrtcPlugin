//
//  TakDataChannel.cpp
//  UnityWebrtcPlugin
//
//  Created by taktod on 2018/07/07.
//  Copyright © 2018年 taktod. All rights reserved.
//

#include "TakDataChannel.hpp"
#include "TakPeerConnection.hpp"

using namespace takWebrtc;

// 自分からDataChannelをつくって送る場合
TakDataChannel::TakDataChannel(
                               TakPeerConnection *conn,
                               string label,
                               bool isOrdered,
                               bool isReliable) {
    struct DataChannelInit init;
    init.ordered = isOrdered;
    init.reliable = isReliable;
    if(conn->refNativeConnection() != nullptr && conn->refNativeConnection().get() != nullptr) {
        _dataChannel = conn->refNativeConnection()->CreateDataChannel(label, &init);
        if(_dataChannel.get() == nullptr) {
            
        }
        else {
            _dataChannel->RegisterObserver(this);
        }
    }
}

// 相手からDataChannelがきてる場合
TakDataChannel::TakDataChannel(rtc::scoped_refptr<DataChannelInterface> dataChannel) {
    _dataChannel = dataChannel;
    _dataChannel->RegisterObserver(this);
}

TakDataChannel::~TakDataChannel() {
    _dataChannel->UnregisterObserver();
}

void TakDataChannel::send(string message) {
    DataBuffer buffer(message);
    _dataChannel->Send(buffer);
}
DataChannelInterface::DataState TakDataChannel::refState() {
    return _dataChannel->state();
}
void TakDataChannel::OnMessage(const DataBuffer& buffer) {
    if(onMessage != nullptr) {
        onMessage(string((const char *)buffer.data.data(), (size_t)buffer.data.size()));
    }
}
void TakDataChannel::OnStateChange() {
    if(onStateChange != nullptr) {
        onStateChange();
    }
}
