//
//  MotionController.h
//  DinoLasers
//
//  Created by Paul Mans on 11/30/12.
//  Copyright (c) 2012 DinoLasers. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEFAULT_UPDATE_INTERVAL 1.0 / 3.0 //1.0/100.0


@interface MotionController : NSObject

@property (nonatomic, assign) float updateInterval;
@property (nonatomic, strong) NSString *markerString;

- (void) enableMotionTracking;

- (NSString *)currentMotionString;

- (void)saveReferenceAttitude;

@end
