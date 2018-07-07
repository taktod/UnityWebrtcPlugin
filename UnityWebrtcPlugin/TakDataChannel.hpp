//
//  TakDataChannel.hpp
//  UnityWebrtcPlugin
//
//  Created by taktod on 2018/07/07.
//  Copyright © 2018年 taktod. All rights reserved.
//

#ifndef TakDataChannel_hpp
#define TakDataChannel_hpp

#include <iostream>
#include <api/peerconnectioninterface.h>

using namespace std;
using namespace webrtc;

namespace takWebrtc {
    class TakPeerConnection;
    class TakDataChannel : public DataChannelObserver {
    public:
        TakDataChannel(
                       TakPeerConnection *conn,
                       string label,
                       bool isOrdered,
                       bool isReliable);
        TakDataChannel(rtc::scoped_refptr<DataChannelInterface> dataChannel);
        ~TakDataChannel();
        void send(string message);
        DataChannelInterface::DataState refState();
        
        void OnStateChange();
        void OnMessage(const DataBuffer& buffer);
        void OnBufferedAmountChange(uint64_t previous_amount) {}
        function<void(string message)>onMessage;
        function<void()>onStateChange;
    private:
        rtc::scoped_refptr<DataChannelInterface> _dataChannel;
    };
}

#endif /* TakDataChannel_hpp */
