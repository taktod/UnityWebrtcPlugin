//
//  TakWebsocket.cpp
//  UnityWebrtcPlugin
//
//  Created by taktod on 2018/07/08.
//  Copyright © 2018年 taktod. All rights reserved.
//

#include "TakWebsocket.hpp"

using namespace takWebrtc;

@interface WebSocketBase() {
    TakWebsocket *_socket;
    SRWebSocket *_websocket;
}

@end

@implementation WebSocketBase
- (instancetype)init:(string) address socket:(TakWebsocket *)socket{
    _websocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithUTF8String:address.c_str()]]]];
    _socket = socket;
    [_websocket setDelegate:self];
    [_websocket open];
    return self;
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    if(_socket->onConnect != nullptr) {
        _socket->onConnect();
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    if(_socket->onError != nullptr) {
        _socket->onError([[error localizedDescription] UTF8String]);
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(nullable NSString *)reason wasClean:(BOOL)wasClean {
    if(_socket->onClose != nullptr) {
        _socket->onClose([reason UTF8String]);
    }
}
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    if(_socket->onMessage != nullptr) {
        _socket->onMessage([message UTF8String]);
    }
    
}

- (void)send:(NSString *) data {
    NSError *error;
    [_websocket sendString:data error:&error];
}

@end


void TakWebsocket::connect() {
    _base = [[WebSocketBase alloc] init:_address socket:this];
}

void TakWebsocket::send(string data) {
//    cout << "wsSend:" << data << endl;
    [_base send:@(data.c_str())];
}
