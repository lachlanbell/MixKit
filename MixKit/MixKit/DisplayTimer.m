//
//  DisplayTimer.m
//  MixKit
//
//  Created by Lachlan Bell on 25/11/19.
//  Copyright © 2019 Lachlan Bell.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "DisplayTimer.h"
@import CoreVideo;

@implementation DisplayTimer

- (id)init {
    if(self = [super init]) {
        CVDisplayLinkRef displayLink = NULL;
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
        CVDisplayLinkSetOutputCallback(displayLink, &displayLinkCallback, (__bridge void*)self);

        CVDisplayLinkStart(displayLink);

        self.displayLink = displayLink;
    }
    return self;
}

- (void)dealloc {
    CVDisplayLinkRelease(self.displayLink);
}

- (void)callDelegate:(const CVTimeStamp*)outputTime {
    [_delegate drawFrameForTime:outputTime];
}

static CVReturn displayLinkCallback(
      CVDisplayLinkRef displayLink,
      const CVTimeStamp* now,
      const CVTimeStamp* outputTime,
      CVOptionFlags flagsIn,
      CVOptionFlags* flagsOut,
      void* displayLinkContext
) {

    DisplayTimer *timer = (__bridge DisplayTimer*)displayLinkContext;

    @autoreleasepool {
        [timer callDelegate:outputTime];
    }

    return kCVReturnSuccess;
}

@end
