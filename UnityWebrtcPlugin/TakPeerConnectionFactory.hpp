//
//  TakPeerConnectionFactory.hpp
//  UnityWebrtcPlugin
//
//  Created by taktod on 2018/07/07.
//  Copyright © 2018年 taktod. All rights reserved.
//

#ifndef TakPeerConnectionFactory_hpp
#define TakPeerConnectionFactory_hpp

#include <iostream>
#include <rtc_base/scoped_ref_ptr.h>
#include <rtc_base/ptr_util.h>
#include <api/peerconnectioninterface.h>
#include <api/audio_codecs/builtin_audio_decoder_factory.h>
#include <api/audio_codecs/builtin_audio_encoder_factory.h>

using namespace webrtc;

namespace takWebrtc {
    extern rtc::Thread _signalingThread;
    extern rtc::Thread _workerThread;
    class TakPeerConnectionFactory {
    public:
        TakPeerConnectionFactory() {
            _nativeFactory = CreatePeerConnectionFactory(
                                                         &_workerThread,
                                                         &_workerThread,
                                                         &_signalingThread,
                                                         nullptr,
                                                         CreateBuiltinAudioEncoderFactory(),
                                                         CreateBuiltinAudioDecoderFactory(),
                                                         nullptr, nullptr);
        }
        ~TakPeerConnectionFactory() {
        }
        rtc::scoped_refptr<PeerConnectionFactoryInterface> refNativeFactory() {
            return _nativeFactory;
        }
    private:
        rtc::scoped_refptr<PeerConnectionFactoryInterface> _nativeFactory;
    };
}


#endif /* TakPeerConnectionFactory_hpp */
