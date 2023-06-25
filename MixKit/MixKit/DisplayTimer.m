//
//  DisplayTimer.m
//  MixKit
//
//  Created by Lachlan Bell on 25/11/19.
//  Copyright © 2019 Lachlan Bell. All rights reserved.
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
