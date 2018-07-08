//
//  TakPeerConnection.cpp
//  UnityWebrtcPlugin
//
//  Created by taktod on 2018/07/07.
//  Copyright © 2018年 taktod. All rights reserved.
//

#include "TakPeerConnection.hpp"
#import <Foundation/Foundation.h>
#include "TakPeerConnectionFactory.hpp"

using namespace takWebrtc;

void CreateSdpObserver::OnSuccess(SessionDescriptionInterface* desc) {
    string str;
    desc->ToString(&str);
    if(_func != nullptr) {
        _func(desc);
    }
}

TakPeerConnection::TakPeerConnection(
                                     TakPeerConnectionFactory *factory,
                                     TakIceServer **servers,
                                     int length) : _factory(factory) {
    // iceServersからiceServersを作らなければならないわけか・・・
    _nativeConnection = nullptr;
    for(int i = 0;i < length; ++ i) {
        PeerConnectionInterface::IceServer iceServer;
        iceServer.password = servers[i]->getPassword();
        iceServer.uri = servers[i]->getUri();
        iceServer.username = servers[i]->getUserName();
        _iceServers.push_back(iceServer);
    }
    _sdpType = std::string();
    _sdpValue = std::string();
    _setSdpObserver = new rtc::RefCountedObject<SetSdpObserver>();
    TakConstraint constraint;
    constraint.AddMandatory("DtlsSrtpKeyAgreement", "true");
    PeerConnectionInterface::RTCConfiguration config;
    config.servers = _iceServers;
    _nativeConnection = _factory->refNativeFactory()->CreatePeerConnection(config, &constraint, nullptr, nullptr, this);
}

TakPeerConnection::~TakPeerConnection() {
    // 作成Channelとstreamを消さないといけない
}

void TakPeerConnection::OnDataChannel(rtc::scoped_refptr<DataChannelInterface> data_channel) {
    cout << "remoteからdataChannelきた" << endl;
}

void TakPeerConnection::OnAddStream(rtc::scoped_refptr<MediaStreamInterface> istream) {
//    cout << "remoteからaddStreamきた" << endl;
}

void TakPeerConnection::OnRemoveStream(rtc::scoped_refptr<MediaStreamInterface> istream) {
}

void TakPeerConnection::OnIceCandidate(const IceCandidateInterface* candidate) {
    if(onIceCandidate != nullptr) {
        onIceCandidate(candidate);
    }
}

bool TakPeerConnection::addStream(TakMediaStream *stream) {
    if(stream == nullptr) {
        return false;
    }
    // streamを追加する
    return _nativeConnection->AddStream(stream->refNativeStream());
}
void TakPeerConnection::createOffer(TakConstraint *constraint, function<void(SessionDescriptionInterface *)> func) {
    rtc::RefCountedObject<CreateSdpObserver> *obs = new rtc::RefCountedObject<CreateSdpObserver>();
    obs->_func = func;
    _nativeConnection->CreateOffer(obs, constraint);
}

void TakPeerConnection::createAnswer(TakConstraint *constraint, function<void(SessionDescriptionInterface *)> func) {
    rtc::RefCountedObject<CreateSdpObserver> *obs = new rtc::RefCountedObject<CreateSdpObserver>();
    obs->_func = func;
    _nativeConnection->CreateAnswer(obs, constraint);
}
void TakPeerConnection::setLocalDescription(SessionDescriptionInterface *sdp) {
    _nativeConnection->SetLocalDescription(_setSdpObserver, sdp);
}
void TakPeerConnection::setRemoteDescription(string type, string value) {
    SdpParseError error;
    SessionDescriptionInterface *sdp = CreateSessionDescription(type, value, &error);
    if(error.line != "" || error.description != "") {
        cout << error.line << endl;
        cout << error.description << endl;
    }
    _nativeConnection->SetRemoteDescription(_setSdpObserver, sdp);
}
void TakPeerConnection::addIceCandidate(string candidate, string sdpMid, int sdpMLineIndex) {
    SdpParseError error;
    IceCandidateInterface *nativeCandidate = CreateIceCandidate(
                                                                sdpMid,
                                                                sdpMLineIndex,
                                                                candidate,
                                                                &error);
    _nativeConnection->AddIceCandidate(nativeCandidate);
}
