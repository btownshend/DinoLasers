//
//  FlipsideViewController.m
//  DinoLasers
//
//  Created by Paul Mans on 11/19/12.
//  Copyright (c) 2012 DinoLasers. All rights reserved.
//

#import "FlipsideViewController.h"
#import "DinoLaserSettings.h"

@interface FlipsideViewController ()

@end

@implementation FlipsideViewController
@synthesize dinoLaserSettings;
@synthesize logEnabledSwitch;
@synthesize udpEnabledSwitch;
@synthesize hostIPTextField;

- (id)initWithDinoLaserSettings:(DinoLaserSettings *)settings {
    if ((self = [super initWithNibName:@"FlipsideViewController" bundle:nil])) {
        self.dinoLaserSettings = settings;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Settings";
    
    [self.logEnabledSwitch setOn:self.dinoLaserSettings.persistenceModes & PersistenceModeLogFile ? YES : NO];
    [self.udpEnabledSwitch setOn:self.dinoLaserSettings.persistenceModes & PersistenceModeUDP ? YES : NO];
    self.hostIPTextField.text = self.dinoLaserSettings.hostIP;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

- (IBAction)valueChanged:(id)sender {
    
    [self.hostIPTextField resignFirstResponder];
    
    PersistenceMode newMode = PersistenceModeNone;
    if (self.udpEnabledSwitch.isOn) {
        newMode |= PersistenceModeUDP;
    }
    if (self.logEnabledSwitch.isOn) {
        newMode |= PersistenceModeLogFile;
    }
    self.dinoLaserSettings.persistenceModes = newMode;
    self.dinoLaserSettings.hostIP = self.hostIPTextField.text;
    
    [self.delegate flipsideViewController:self didUpdateSettings:self.dinoLaserSettings];
}

@end
