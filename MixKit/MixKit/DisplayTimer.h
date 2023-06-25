//
//  DisplayTimer.h
//  MixKit
//
//  Created by Lachlan Bell on 25/11/19.
//  Copyright © 2019 Lachlan Bell. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreVideo;

NS_ASSUME_NONNULL_BEGIN

@protocol DisplayTimerDelegate
- (void)drawFrameForTime:(const CVTimeStamp*)outputTime;
@end

@interface DisplayTimer : NSObject

@property (nonatomic) CVDisplayLinkRef displayLink;
@property (nonatomic) id<DisplayTimerDelegate> delegate;

- (id)init;

- (void)callDelegate:(const CVTimeStamp*)outputTime;

- (void)dealloc;

@end

NS_ASSUME_NONNULL_END
