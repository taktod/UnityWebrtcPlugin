//
//  TakMediaStream.cpp
//  UnityWebrtcPlugin
//
//  Created by taktod on 2018/07/07.
//  Copyright © 2018年 taktod. All rights reserved.
//

#include "TakMediaStream.hpp"
#include "TakPeerConnectionFactory.hpp"

using namespace takWebrtc;

TakMediaStream::TakMediaStream(
                               TakPeerConnectionFactory *factory,
                               string name,
                               string videoId,
                               string audioId) : _isLocal(true), _factory(factory), _name(name) {
    _nativeStream = factory->refNativeFactory()->CreateLocalMediaStream(name);
    if(videoId != "") {
        // とりあえずlocalから映像を送って共有するつもりはないのでここは放置
    }
    if(audioId != "") {
        rtc::scoped_refptr<AudioTrackInterface> audio_track(
                                                            factory->refNativeFactory()->CreateAudioTrack(
                                                                                                          audioId,
                                                                                                          factory->refNativeFactory()->CreateAudioSource(nullptr)));
        _nativeStream->AddTrack(audio_track);
    }
}

TakMediaStream::TakMediaStream(
                               TakPeerConnectionFactory *factory,
                               rtc::scoped_refptr<MediaStreamInterface> nativeStream) {
    // リモートからの接続はあとでつくる。
}
TakMediaStream::~TakMediaStream() {
    if(_nativeStream->GetVideoTracks().size() > 0) {
        _nativeStream->GetVideoTracks()[0]->RemoveSink(this);
    }
}
void TakMediaStream::OnFrame(const VideoFrame& frame) {
    // フレームを取得した時の動作
}
