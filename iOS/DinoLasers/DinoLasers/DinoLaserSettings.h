//
//  DinoLaserSettings.h
//  DinoLasers
//
//  Created by Paul Mans on 11/30/12.
//  Copyright (c) 2012 DinoLasers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonTypes.h"

@interface DinoLaserSettings : NSObject

@property (nonatomic, assign) PersistenceMode persistenceModes;
@property (nonatomic, strong) NSString *hostIP;

@end
