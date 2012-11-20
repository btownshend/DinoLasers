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

@interface MainViewController () {
    
}

@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
@property (nonatomic, strong) NSString *socketHost;
@property (nonatomic, assign) int socketPort;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) CMAttitude *referenceAttitude;

@end

@implementation MainViewController
@synthesize udpSocket;
@synthesize socketHost;
@synthesize socketPort;
@synthesize sendButton;
@synthesize motionManager;
@synthesize referenceAttitude;

- (void)setupSocket
{
	// Setup our socket.
	// The socket will invoke our delegate methods using the usual delegate paradigm.
	// However, it will invoke the delegate methods on a specified GCD delegate dispatch queue.
	//
	// Now we can configure the delegate dispatch queues however we want.
	// We could simply use the main dispatc queue, so the delegate methods are invoked on the main thread.
	// Or we could use a dedicated dispatch queue, which could be helpful if we were doing a lot of processing.
	//
	// The best approach for your application will depend upon convenience, requirements and performance.
	//
	// For this simple example, we're just going to use the main thread.
	
	udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
	
	NSError *error = nil;
	
	if (![udpSocket bindToPort:0 error:&error])
	{
		//[self logError:FORMAT(@"Error binding: %@", error)];
		return;
	}
	if (![udpSocket beginReceiving:&error])
	{
		//[self logError:FORMAT(@"Error receiving: %@", error)];
		return;
	}
    
    self.socketHost = @"localhost";
    self.socketPort = 10552;
    
}

-(void) enableMotionTracking {
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
    
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical];
    
    CMDeviceMotion *deviceMotion = motionManager.deviceMotion;
    self.referenceAttitude = deviceMotion.attitude;
    
    [motionManager startGyroUpdates];
    [motionManager startAccelerometerUpdates];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupSocket];
    [self enableMotionTracking];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showInfo:(id)sender
{    
    FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)send:(id)sender
{
    long tag = 001;
    
    CMDeviceMotion *deviceMotion = self.motionManager.deviceMotion;
    
    CMAcceleration acceleration = deviceMotion.userAcceleration;
    CMRotationRate rotationRate = deviceMotion.rotationRate;
    
    NSString *motionString = [NSString stringWithFormat:@"%f,%f,%f,%f,%f,%f", acceleration.x, acceleration.y, acceleration.z, rotationRate.x, rotationRate.y, rotationRate.z];
    
    NSLog(@"motionString: %@", motionString);
    
	//NSString *msg = @"0.000000,0.016000,-0.005000,-0.985000";
	NSData *data = [motionString dataUsingEncoding:NSUTF8StringEncoding];
	[udpSocket sendData:data toHost:self.socketHost port:self.socketPort withTimeout:-1 tag:tag];
	
	//[self logMessage:FORMAT(@"SENT (%i): %@", (int)tag, msg)];
	//tag++;
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
	// You could add checks here
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
	// You could add checks here
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
	NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if (msg)
	{
		//[self logMessage:FORMAT(@"RECV: %@", msg)];
	}
	else
	{
		NSString *host = nil;
		uint16_t port = 0;
		[GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
		
		//[self logInfo:FORMAT(@"RECV: Unknown message from: %@:%hu", host, port)];
	}
}


@end
