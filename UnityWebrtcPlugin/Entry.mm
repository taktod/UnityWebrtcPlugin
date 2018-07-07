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

using namespace std;

using namespace takWebrtc;

namespace takWebrtc {
    rtc::Thread _signalingThread;
    rtc::Thread _workerThread;
    TakPeerConnectionFactory *_factory;
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
    void takWebrtc_make() {
        cout << "make is called" << endl;
        TakWebrtc::initialize();
    }
    void takWebrtc_clean() {
        cout << "clean is called" << endl;
        TakWebrtc::terminate();
    }
    void takWebrtc_dispatchMain() {
        dispatch_main();
    }
}
