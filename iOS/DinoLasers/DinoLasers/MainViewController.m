//
//  MainViewController.m
//  DinoLasers
//
//  Created by Paul Mans on 11/19/12.
//  Copyright (c) 2012 DinoLasers. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import <QuartzCore/QuartzCore.h>
#import "MainViewController.h"
#import "GCDAsyncUdpSocket.h"
#import "UDPConnection.h"

@interface MainViewController () {
    
}

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) CMAttitude *referenceAttitude;
@property (nonatomic, strong) NSString *markerString;

- (NSString *)currentMotionString;

@end

@implementation MainViewController
@synthesize sendButton;
@synthesize motionManager;
@synthesize referenceAttitude;
@synthesize udpConnection;
@synthesize markerString;


-(void) enableMotionTracking {
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
    
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical];
    
    CMDeviceMotion *deviceMotion = motionManager.deviceMotion;
    self.referenceAttitude = deviceMotion.attitude;
    
    [motionManager startGyroUpdates];
    [motionManager startAccelerometerUpdates];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.udpConnection = [[UDPConnection alloc] init];
    [self.udpConnection setupSocket];
    
    [self enableMotionTracking];
}


#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showInfo:(id)sender {    
    FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)send:(id)sender {
    
    NSString *motionString = [self currentMotionString];

    NSLog(@"motionString: %@", motionString);
    
    long tag = 001;
    [self.udpConnection sendMessage:motionString withTag:tag];
    
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
    CMDeviceMotion *deviceMotion = self.motionManager.deviceMotion;
    
    CMAcceleration acceleration = deviceMotion.userAcceleration;
    CMRotationRate rotationRate = deviceMotion.rotationRate;
    
    double millis = CACurrentMediaTime();
    
    NSString *motionString = [NSString stringWithFormat:@"%f,%f,%f,%f,%f,%f,%f,%@", millis, acceleration.x, acceleration.y, acceleration.z, rotationRate.x, rotationRate.y, rotationRate.z, self.markerString];
    
    return motionString;
}

@end
