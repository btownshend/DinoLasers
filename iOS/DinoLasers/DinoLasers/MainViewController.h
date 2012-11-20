//
//  MainViewController.h
//  DinoLasers
//
//  Created by Paul Mans on 11/19/12.
//  Copyright (c) 2012 DinoLasers. All rights reserved.
//

#import "FlipsideViewController.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate> {
    UIButton *sendButton;
}

@property (nonatomic, strong) IBOutlet UIButton *sendButton;

- (IBAction)showInfo:(id)sender;

- (IBAction)send:(id)sender;

@end
