//
//  MainViewController.h
//  DinoLasers
//
//  Created by Paul Mans on 11/19/12.
//  Copyright (c) 2012 DinoLasers. All rights reserved.
//

#import "FlipsideViewController.h"

@class UDPConnection;

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate> {

}

@property (nonatomic, strong) IBOutlet UIButton *sendButton;
@property (nonatomic, strong) UDPConnection *udpConnection;

- (IBAction)showInfo:(id)sender;

- (IBAction)send:(id)sender;

@end
