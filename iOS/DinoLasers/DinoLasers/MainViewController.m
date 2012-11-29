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
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, strong) NSString *logString;
@property (nonatomic, assign) long tag;
@property (nonatomic, strong) NSTimer *timer;

- (NSString *)currentMotionString;

@end

@implementation MainViewController
@synthesize markerStringTextField;
@synthesize motionManager;
@synthesize referenceAttitude;
@synthesize markerString;
@synthesize udpConnection;
@synthesize logConnection;
@synthesize isRecording;
@synthesize logString;
@synthesize tag;
@synthesize timer;



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isRecording = NO;
    
    [self enableMotionTracking];
    
    [self updatePersistenceConnections];
    
    // begin timer
    double timeInterval = 1.0/60.0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    
    
    // Make view adjustments
    // ...    
    [self updateToggleRecordingButton];
    
    self.logString = @"";
    self.logTextView.text = nil;
    self.logTextView.layer.cornerRadius = 4;
    self.logTextView.backgroundColor = [UIColor grayColor];
    
}

- (void)updateToggleRecordingButton {
    NSString *text = isRecording ? @"Pause" : @"Play";
    
    [self.toggleLoggingButton setTitle:text forState:UIControlStateNormal];
}

// Timer callback
-(void)timerFired:(NSTimer *)theTimer {
    if (isRecording) {
        [self processMotionData];
    }
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

#define LOG_BUFFER_SIZE 300

- (void)appendToLog:(NSString *)suffix {
    logString = [logString stringByAppendingString:suffix];
    if (logString.length >= LOG_BUFFER_SIZE) {
        logString = [logString substringFromIndex:logString.length - LOG_BUFFER_SIZE];
    }
    
    self.logTextView.text = logString;
    
    NSRange range = NSMakeRange(self.logTextView.text.length - 1, 1);
    [self.logTextView scrollRangeToVisible:range];
}


#pragma mark - IBActions

- (IBAction)toggleRecording:(id)sender {
    isRecording = !isRecording;
    
    [self updateToggleRecordingButton];
    
    NSLog(@"Updating recording state: %@", isRecording ? @"YES" : @"NO");
}

- (IBAction)showInfo:(id)sender {
    FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)markString:(id)sender {
    if ([self.markerStringTextField.text isEqualToString:@""]) {
        self.markerString = nil;
    } else {
        self. markerString = self.markerStringTextField.text;
    }
    NSLog(@"Updated Marker String to: %@", markerString);
    [self.markerStringTextField resignFirstResponder];
}


#pragma mark - CoreMotion

- (void)processMotionData {
    NSString *motionString = [self currentMotionString];
    
    NSLog(@"motionString: %@", motionString);
    [self appendToLog:motionString];
    
    // pass update to udpConnection if it exists
    [self.udpConnection sendMessage:motionString withTag:tag];
    
    // pass update to logConnection if it exists
    [self.logConnection printLineToLog:motionString];
    
    // increment the tag
    self.tag++;
}


-(void) enableMotionTracking {
    self.tag = 001;
    
    self.motionManager = [[CMMotionManager alloc] init];
    
    self.motionManager.deviceMotionUpdateInterval = 0.01;   // 100 Hz
    self.motionManager.accelerometerUpdateInterval = 0.01;  // 100 Hz
    self.motionManager.gyroUpdateInterval = 0.01;           // 100 Hz
    
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical];
    
    CMDeviceMotion *deviceMotion = motionManager.deviceMotion;
    self.referenceAttitude = deviceMotion.attitude;
    
    [motionManager startGyroUpdates];
    [motionManager startAccelerometerUpdates];
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

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
