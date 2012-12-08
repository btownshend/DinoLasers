//
//  MotionController.m
//  DinoLasers
//
//  Created by Paul Mans on 11/30/12.
//  Copyright (c) 2012 DinoLasers. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "MotionController.h"

@interface MotionController ()

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) CMAttitude *referenceAttitude;

@end

@implementation MotionController
@synthesize motionManager;
@synthesize referenceAttitude;
@synthesize markerString;
@synthesize updateInterval;

- (id)init {
    if ((self = [super init])) {
        self.updateInterval = DEFAULT_UPDATE_INTERVAL;
    }
    return self;
}

-(void) enableMotionTracking {
    
    // quit all ongoing updates
    if (self.motionManager) {
        [self.motionManager stopDeviceMotionUpdates];
        [self.motionManager stopAccelerometerUpdates];
        [self.motionManager stopGyroUpdates];
        [self.motionManager stopMagnetometerUpdates];
    }
    
    self.motionManager = [[CMMotionManager alloc] init];
    
    self.motionManager.deviceMotionUpdateInterval = self.updateInterval;
    self.motionManager.accelerometerUpdateInterval = self.updateInterval;
    self.motionManager.gyroUpdateInterval = self.updateInterval;
    
    [self.motionManager startDeviceMotionUpdates];
    
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical];
    
    
    // capture the reference attitude as the initial position
    //[self saveReferenceAttitude];

}

/**
 *  Motion string with the current acceleration and rotation values.
 *  Format: "timestamp, accelX, accelY, accelZ, rotationX, rotationY, rotationZ, markerString"
 *
 *  timestamp:      milliseconds
 *  accel vals:     doubles
 *  rotation vals:  doubles
 *  markerString:   used to mark a sequence of values
 */
- (NSString *)currentMotionString {
    
    if (!self.motionManager.deviceMotionActive) {
        NSLog(@"Device motion not active");
    }
    
    CMDeviceMotion *deviceMotion = self.motionManager.deviceMotion;
    
    CMAcceleration acceleration = deviceMotion.userAcceleration;
    CMRotationRate rotationRate = deviceMotion.rotationRate;
    
    double millis = CACurrentMediaTime();
    
    NSString *motionString = [NSString stringWithFormat:@"%f,%f,%f,%f,%f,%f,%f,%@", millis, acceleration.x, acceleration.y, acceleration.z, rotationRate.x, rotationRate.y, rotationRate.z, self.markerString];
    
    return motionString;
}

- (void)saveReferenceAttitude {
    
    CMDeviceMotion *deviceMotion = self.motionManager.deviceMotion;
    self.referenceAttitude = deviceMotion.attitude;
    
}

@end
