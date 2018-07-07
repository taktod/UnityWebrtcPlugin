//
//  TakIceServer.hpp
//  UnityWebrtcPlugin
//
//  Created by taktod on 2018/07/07.
//  Copyright © 2018年 taktod. All rights reserved.
//

#ifndef TakIceServer_hpp
#define TakIceServer_hpp

#include <iostream>

using namespace std;

namespace takWebrtc {
    class TakIceServer {
    public:
        TakIceServer(string uri, string username, string password) : _uri(uri), _username(username), _password(password) {}
        string getUri() {
            return _uri;
        }
        string getUserName() {
            return _username;
        }
        string getPassword() {
            return _password;
        }
    private:
        string _uri;
        string _username;
        string _password;
    };
}

#endif /* TakIceServer_hpp */
