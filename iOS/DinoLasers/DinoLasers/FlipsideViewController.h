//
//  FlipsideViewController.h
//  DinoLasers
//
//  Created by Paul Mans on 11/19/12.
//  Copyright (c) 2012 DinoLasers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlipsideViewController;
@class DinoLaserSettings;

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;

- (void)flipsideViewController:(FlipsideViewController *)controller didUpdateSettings:(DinoLaserSettings *)settings;
@end

@interface FlipsideViewController : UIViewController

@property (nonatomic, strong) DinoLaserSettings *dinoLaserSettings;
@property (weak, nonatomic) id <FlipsideViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet UISwitch *udpEnabledSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *logEnabledSwitch;
@property (nonatomic, strong) IBOutlet UITextField *hostIPTextField;

- (id)initWithDinoLaserSettings:(DinoLaserSettings *)settings;

- (IBAction)done:(id)sender;

- (IBAction)valueChanged:(id)sender;

@end
