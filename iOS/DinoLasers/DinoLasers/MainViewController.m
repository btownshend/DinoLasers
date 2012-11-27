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
#import "LogConnection.h"

@interface MainViewController () {
    
}

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) CMAttitude *referenceAttitude;
@property (nonatomic, strong) NSString *markerString;
@property (nonatomic, strong) UDPConnection *udpConnection;
@property (nonatomic, strong) LogConnection *logConnection;
@property (nonatomic, assign) long tag;

- (NSString *)currentMotionString;

@end

@implementation MainViewController
@synthesize sendButton;
@synthesize motionManager;
@synthesize referenceAttitude;
@synthesize markerString;
@synthesize udpConnection;
@synthesize logConnection;
@synthesize tag;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self enableMotionTracking];
    
    [self updatePersistenceConnections];
}

-(void) enableMotionTracking {
    self.tag = 001;
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
    
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical];
    
    CMDeviceMotion *deviceMotion = motionManager.deviceMotion;
    self.referenceAttitude = deviceMotion.attitude;
    
    [motionManager startGyroUpdates];
    [motionManager startAccelerometerUpdates];
}

- (void)updatePersistenceConnections {
    PersistenceMode currPersistenceMode = [[NSUserDefaults standardUserDefaults] integerForKey:PERSISTENCE_MODES_SETTINGS_KEY];
    
    if (currPersistenceMode == PersistenceModeNone) {
        currPersistenceMode = PersistenceModeUDP | PersistenceModeLogFile;
    }
    
    // setup UDPConnection if enabled
    if (currPersistenceMode & PersistenceModeUDP) {
        if (!self.udpConnection) {
            self.udpConnection = [[UDPConnection alloc] init];
            [self.udpConnection setupSocket];
        }
    }
    
    // setup LogConnection if enabled
    if (currPersistenceMode & PersistenceModeLogFile) {
        if (!self.logConnection) {
            self.logConnection = [[LogConnection alloc] init];
        }
    }
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
    
    // pass update to udpConnection if it exists
    [self.udpConnection sendMessage:motionString withTag:tag];
    
    // pass update to logConnection if it exists
    [self.logConnection printLineToLog:motionString];
    
    // increment the tag
    self.tag++;
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
