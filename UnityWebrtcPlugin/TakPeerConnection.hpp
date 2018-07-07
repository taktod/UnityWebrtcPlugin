//
//  TakPeerConnection.hpp
//  UnityWebrtcPlugin
//
//  Created by taktod on 2018/07/07.
//  Copyright © 2018年 taktod. All rights reserved.
//

#ifndef TakPeerConnection_hpp
#define TakPeerConnection_hpp

#include <iostream>
#include <api/peerconnectioninterface.h>
#include "TakConstraint.hpp"
#include "TakIceServer.hpp"
#include "TakMediaStream.hpp"

using namespace std;
using namespace webrtc;

namespace takWebrtc {
    class TakPeerConnectionFactory;
    class TakMediaStream;
    class SetSdpObserver : public SetSessionDescriptionObserver {
    public:
        void OnSuccess() {}
        void OnFailure(const string& msg) {}
    };
    class CreateSdpObserver : public CreateSessionDescriptionObserver {
    public:
        CreateSdpObserver() {}
        virtual ~CreateSdpObserver() {}
        virtual void OnSuccess(SessionDescriptionInterface* desc);
        virtual void OnFailure(const std::string& error) {}
        function<void(SessionDescriptionInterface *)> _func;
    private:
    };
    class TakPeerConnection : public PeerConnectionObserver {
    public:
        TakPeerConnection(TakPeerConnectionFactory *factory, TakIceServer **servers, int serversLength);
        ~TakPeerConnection();
        void OnSignalingChange(PeerConnectionInterface::SignalingState new_state) {}
        void OnAddStream(rtc::scoped_refptr<MediaStreamInterface> stream);
        void OnRemoveStream(rtc::scoped_refptr<MediaStreamInterface> stream);
        void OnDataChannel(rtc::scoped_refptr<DataChannelInterface> data_channel);
        void OnRenegotiationNeeded() {}
        void OnIceConnectionChange(PeerConnectionInterface::IceConnectionState new_state) {}
        void OnIceGatheringChange(PeerConnectionInterface::IceGatheringState new_state) {}
        void OnIceCandidate(const IceCandidateInterface* candidate);
        void OnIceCandidatesRemoved(const std::vector<cricket::Candidate>& candidates) {}
        void OnIceConnectionReceivingChange(bool receiving) {}
        void OnAddTrack(
                        rtc::scoped_refptr<RtpReceiverInterface> receiver,
                        const std::vector<rtc::scoped_refptr<MediaStreamInterface>>& streams) {}
        void OnRemoveTrack(rtc::scoped_refptr<RtpReceiverInterface> receiver) {}
        bool addStream(TakMediaStream *stream);
        rtc::scoped_refptr<PeerConnectionInterface> refNativeConnection() {
            return _nativeConnection;
        }
        void createOffer(TakConstraint *constraint, function<void(SessionDescriptionInterface *)> func);
        void createAnswer(TakConstraint *constraint, function<void(SessionDescriptionInterface *)> func);
        void setLocalDescription(SessionDescriptionInterface *sdp);
        void setRemoteDescription(string type, string value);
        void addIceCandidate(string candidate, string sdpMid, int sdpMLineIndex);

        function<void(const IceCandidateInterface *candidate)> onIceCandidate;
    private:
        TakPeerConnectionFactory *_factory;
        PeerConnectionInterface::IceServers _iceServers;
        rtc::scoped_refptr<PeerConnectionInterface> _nativeConnection;
        rtc::scoped_refptr<SetSdpObserver> _setSdpObserver;
//        TaksDataChannel *_channel;
        string _sdpType;
        string _sdpValue;
        map<string, TakMediaStream *> _streams;
    };
}

#endif /* TakPeerConnection_hpp */
