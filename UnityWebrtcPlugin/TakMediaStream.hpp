//
//  TakMediaStream.hpp
//  UnityWebrtcPlugin
//
//  Created by taktod on 2018/07/07.
//  Copyright © 2018年 taktod. All rights reserved.
//

#ifndef TakMediaStream_hpp
#define TakMediaStream_hpp

#include <stdio.h>
#include <api/peerconnectioninterface.h>
#include <modules/video_capture/video_capture_factory.h>
#include <media/engine/webrtcvideocapturerfactory.h>

using namespace std;
using namespace webrtc;

namespace takWebrtc {
    class TakPeerConnectionFactory;
    class TakMediaStream : rtc::VideoSinkInterface<VideoFrame> {
    public:
        TakMediaStream(
                       TakPeerConnectionFactory *factory,
                       string name,
                       string videoId,
                       string audioId);
        TakMediaStream(
                       TakPeerConnectionFactory *factory,
                       rtc::scoped_refptr<MediaStreamInterface> nativeStream);
        ~TakMediaStream();
        rtc::scoped_refptr<MediaStreamInterface> refNativeStream() {
            return _nativeStream;
        }
        void OnFrame(const VideoFrame& frame);
    private:
        bool _isLocal; // ローカルのstreamかどうか
        string _name; // streamの名前
        TakPeerConnectionFactory *_factory;
        rtc::scoped_refptr<MediaStreamInterface> _nativeStream;
    };
}

#endif /* TakMediaStream_hpp */
