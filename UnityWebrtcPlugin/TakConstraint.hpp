//
//  TakConstraint.hpp
//  UnityWebrtcPlugin
//
//  Created by taktod on 2018/07/07.
//  Copyright © 2018年 taktod. All rights reserved.
//

#ifndef TakConstraint_hpp
#define TakConstraint_hpp

#include <stdio.h>
#include <api/mediaconstraintsinterface.h>

using namespace std;
using namespace webrtc;

namespace takWebrtc {
    class TakConstraint : public MediaConstraintsInterface {
    public:
        TakConstraint() {};
        virtual ~TakConstraint() {};
        virtual const Constraints& GetMandatory() const {return _mandatory;}
        virtual const Constraints& GetOptional() const {return _optional;}
        template<class T>
        void AddMandatory(const string &key, const T &value) {
            _mandatory.push_back(Constraint(key, rtc::ToString<T>(value)));
        }
        
        template<class T>
        void SetMandatory(const string &key, const T &value);
        
        template<class T>
        void AddOptional(const string &key, const T &value);
    private:
        template<class T>
        void add(Constraints& target, const string& key, const T &value) {
            target.push_back(Constraint(key, rtc::ToString<T>(value)));
        }
        Constraints _mandatory;
        Constraints _optional;
    };
}

#endif /* TakConstraint_hpp */
