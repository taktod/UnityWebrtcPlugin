//
//  TakWebsocket.hpp
//  UnityWebrtcPlugin
//
//  Created by taktod on 2018/07/08.
//  Copyright © 2018年 taktod. All rights reserved.
//

#ifndef TakWebsocket_hpp
#define TakWebsocket_hpp

#include <iostream>
#import <Foundation/Foundation.h>
#import "SocketRocket/SRWebSocket.h"

using namespace std;

@interface WebSocketBase : NSObject<SRWebSocketDelegate>
@end

namespace takWebrtc {
    class TakWebsocket {
    public:
        TakWebsocket(string address) : _address(address){}
        void connect();
        void send(string data);
        function<void()> onConnect;
        function<void(string)> onMessage;
        function<void(string)> onClose;
        function<void(string)> onError;
    private:
        string _address;
        WebSocketBase *_base;
    };
}

#endif /* TakWebsocket_hpp */
