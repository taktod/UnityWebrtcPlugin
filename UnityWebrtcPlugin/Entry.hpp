//
//  Entry.hpp
//  UnityWebrtcPlugin
//
//  Created by taktod on 2018/07/07.
//  Copyright © 2018年 taktod. All rights reserved.
//

#ifndef Entry_hpp
#define Entry_hpp

#include <iostream>
#include <rtc_base/ssladapter.h>
#include <rtc_base/scoped_ref_ptr.h>
#include <rtc_base/ptr_util.h>
#include <rtc_base/thread.h>

namespace takWebrtc {
    class TakWebrtc {
    public:
        static void initialize();
        static void terminate();
    };
}

#endif /* Entry_hpp */
