//
//  LogConnection.h
//  DinoLasers
//
//  Created by Paul Mans on 11/27/12.
//  Copyright (c) 2012 DinoLasers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogConnection : NSObject

@property (nonatomic, strong) NSString *fileNamePrefix;

- (void)beginNewFile;
- (void)printToLog:(NSString *)message;
- (void)printLineToLog:(NSString *)message;

@end
