//
//  MainViewController.h
//  DinoLasers
//
//  Created by Paul Mans on 11/19/12.
//  Copyright (c) 2012 DinoLasers. All rights reserved.
//

#import "FlipsideViewController.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate> {

}

@property (strong, nonatomic) IBOutlet UIButton *toggleLoggingButton;
@property (nonatomic, strong) IBOutlet UITextField *markerStringTextField;
@property (strong, nonatomic) IBOutlet UITextView *logTextView;


@end
