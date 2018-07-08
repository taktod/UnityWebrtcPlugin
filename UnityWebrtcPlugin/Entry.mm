//
//  Entry.cpp
//  UnityWebrtcPlugin
//
//  Created by taktod on 2018/07/07.
//  Copyright © 2018年 taktod. All rights reserved.
//

#include "Entry.hpp"
#include <iostream>
#import <Foundation/Foundation.h>
#include "TakPeerConnectionFactory.hpp"
#include "TakPeerConnection.hpp"
#include "TakIceServer.hpp"
#include "TakWebsocket.hpp"
#include "TakDataChannel.hpp"

using namespace std;

using namespace takWebrtc;

namespace takWebrtc {
    rtc::Thread _signalingThread;
    rtc::Thread _workerThread;
    TakPeerConnectionFactory *_factory;
    TakWebsocket *_socket;
    TakMediaStream *_stream;
    TakPeerConnection *_conn;
    string myId = "";
}

void TakWebrtc::initialize() {
    rtc::InitializeSSL();
    _signalingThread.Start();
    _workerThread.Start();
    _factory = new TakPeerConnectionFactory();
}

void TakWebrtc::terminate() {
    delete _factory;
    _signalingThread.Stop();
    _workerThread.Stop();
    rtc::CleanupSSL();
}

TakWebrtc *_webrtc;

extern "C" {
    void test() {
        cout << "test is called." << endl;
    }
    void sendOffer(string targetId) {
        // peerConnectionをつくって相手におくる。
        TakIceServer server = TakIceServer("stun:stun.l.google.com:19302", "", "");
        TakIceServer *lps = &server;
        
        _conn = new TakPeerConnection(_factory, &lps, 1);
        _conn->onIceCandidate = [targetId](const IceCandidateInterface *candidate) {
            // candidateの応答
            string str;
            candidate->ToString(&str);
            NSDictionary *dic
             = @{
                 @"target":@(targetId.c_str()),
                 @"from":@(myId.c_str()),
                 @"type":@"candidate",
                 @"candidate":@(str.c_str()),
                 @"sdpMid":@(candidate->sdp_mid().c_str()),
                 @"sdpMLineIndex": @(candidate->sdp_mline_index())
                 };
            NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
            NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            _socket->send([message UTF8String]);
        };
        _conn->addStream(_stream);
        TakConstraint constraint;
        constraint.AddMandatory("OfferToReceiveAudio", true);
        constraint.AddMandatory("OfferToReceiveVideo", false);
        _conn->createOffer(&constraint, [targetId](SessionDescriptionInterface *sdp) {
            _conn->setLocalDescription(sdp);
            string str;
            sdp->ToString(&str);
            NSDictionary *dic
             = @{
                 @"target" : @(targetId.c_str()),
                 @"from" : @(myId.c_str()),
                 @"type" : @"sdp",
                 @"value" : @{
                         @"type": @(sdp->type().c_str()),
                         @"sdp": @(str.c_str())
                         }
                 };
            NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
            NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            _socket->send([message UTF8String]);
        });
    }
    void sendAnswer(string targetId, string type, string sdp) {
        TakIceServer server = TakIceServer("stun:stun.l.google.com:19302", "", "");
        TakIceServer *lps = &server;
        
        _conn = new TakPeerConnection(_factory, &lps, 1);
        _conn->onIceCandidate = [targetId](const IceCandidateInterface *candidate) {
            // candidateの応答
            string str;
            candidate->ToString(&str);
            NSDictionary *dic
            = @{
                @"target":@(targetId.c_str()),
                @"from":@(myId.c_str()),
                @"type":@"candidate",
                @"candidate":@(str.c_str()),
                @"sdpMid":@(candidate->sdp_mid().c_str()),
                @"sdpMLineIndex": @(candidate->sdp_mline_index())
                };
            NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
            NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            _socket->send([message UTF8String]);
        };
        _conn->addStream(_stream);
        _conn->setRemoteDescription(type, sdp);
        TakConstraint constraint;
        constraint.AddMandatory("OfferToReceiveAudio", true);
        constraint.AddMandatory("OfferToReceiveVideo", false);
        _conn->createAnswer(&constraint, [targetId](SessionDescriptionInterface *sdp) {
            _conn->setLocalDescription(sdp);
            string str;
            sdp->ToString(&str);
            NSDictionary *dic
            = @{
                @"target" : @(targetId.c_str()),
                @"from" : @(myId.c_str()),
                @"type" : @"sdpAnswer",
                @"value" : @{
                        @"type": @(sdp->type().c_str()),
                        @"sdp": @(str.c_str())
                        }
                };
            NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
            NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            _socket->send([message UTF8String]);
        });
    }
    void takWebrtc_make() {
        cout << "make is called" << endl;
        // 初期化
        TakWebrtc::initialize();
        // websocketでsignalingを実施する。
        /*
         自作signalingの仕様メモ
         接続したら{ids:[id, id...], self:id}がくる
         sdp: {target:id,from:id,type:"sdp",value:SdpSession情報}
         sdpAnswer: sdpのtypeがsdpAnswerになる
         candidate: {target:id,from:id,type:"candidate",candidate:...,"sdpMid":...,"sdpMLineIndex":...}
         という形でやりとりする形にしてある。
         */
        _stream = new TakMediaStream(_factory, "test", "", "audioId");
        _socket = new TakWebsocket("ws://192.168.0.18:8080/");
        _socket->onMessage = [](string message) {
            // 初接続時
            // [ids:array(), self:number];で応答がくる。
            // このidsのそれぞれにofferを出す必要がある。
            @try {
                string (^toString)(NSObject *) = ^(id target) {
                    string output = "";
                    if([[target className] isEqualToString:@"__NSCFNumber"]) {
                        output = string([[target stringValue] UTF8String]);
                    }
                    if([[target className] isEqualToString:@"NSTaggedPointerString"]) {
                        output = string([(NSString *)target UTF8String]);
                    }
                    return output;
                };
                NSData *data = [@(message.c_str()) dataUsingEncoding:NSUTF8StringEncoding];
                // ここか・・・c_strが途中できれてるようにみえるわけですか・・・なるほど・・・
                NSDictionary *jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                if(myId == "") {
                    // {ids:[], self:number}でデータがきてるはず
                    myId = toString(jsonObj[@"self"]);
                    if([jsonObj[@"ids"] count] > 0) {
                        // なんかあるので、そこにofferを出す
                        sendOffer(toString(jsonObj[@"ids"][0]));
                    }
                }
                else {
                    NSDictionary *dic
                     = @{
                         @"sdp": ^(){
                             cout << "sdp取得" << endl;
                             // 情報を分解しておく
/*                             jsonObj[@"from"];
                             jsonObj[@"value"][@"type"];
                             jsonObj[@"value"][@"sdp"];*/
                             sendAnswer(toString(jsonObj[@"from"]), [jsonObj[@"value"][@"type"] UTF8String], [jsonObj[@"value"][@"sdp"] UTF8String]);
                         },
                         @"sdpAnswer": ^(){
                             cout << "sdpAnswer取得" << endl;
                             _conn->setRemoteDescription([jsonObj[@"value"][@"type"] UTF8String], [jsonObj[@"value"][@"sdp"] UTF8String]);
                         },
                         @"candidate": ^(){
                             cout << "candidate取得" << endl;
                             _conn->addIceCandidate(toString(jsonObj[@"candidate"]), toString(jsonObj[@"sdpMid"]), [jsonObj[@"sdpMLineIndex"] intValue]);
                         }
                         };
                    void (^exec)() = dic[jsonObj[@"type"]];
                    if(exec != nil) {
                        exec();
                    }
                }
            }@catch(NSException *e){
                NSLog(@"%@", e);
            }
        };
        _socket->connect();
    }
    void takWebrtc_clean() {
        cout << "clean is called" << endl;
        TakWebrtc::terminate();
    }
    void takWebrtc_dispatchMain() {
        dispatch_main();
    }
}
