//
//  MainViewController.m
//  DinoLasers
//
//  Created by Paul Mans on 11/19/12.
//  Copyright (c) 2012 DinoLasers. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "MainViewController.h"
#import "GCDAsyncUdpSocket.h"
#import "UDPConnection.h"

@interface MainViewController () {
    
}

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) CMAttitude *referenceAttitude;

@end

@implementation MainViewController
@synthesize sendButton;
@synthesize motionManager;
@synthesize referenceAttitude;
@synthesize udpConnection;



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
    
    
    CMDeviceMotion *deviceMotion = self.motionManager.deviceMotion;
    
    CMAcceleration acceleration = deviceMotion.userAcceleration;
    CMRotationRate rotationRate = deviceMotion.rotationRate;
    
    NSString *motionString = [NSString stringWithFormat:@"%f,%f,%f,%f,%f,%f", acceleration.x, acceleration.y, acceleration.z, rotationRate.x, rotationRate.y, rotationRate.z];
    
    NSLog(@"motionString: %@", motionString);
    
    long tag = 001;
    [self.udpConnection sendMessage:motionString withTag:tag];
    
}


@end
