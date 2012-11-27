//
//  LogConnection.m
//  DinoLasers
//
//  Created by Paul Mans on 11/27/12.
//  Copyright (c) 2012 DinoLasers. All rights reserved.
//

#import "LogConnection.h"
#import "AppDelegate.h"

@interface LogConnection ()

@property (nonatomic, strong) NSFileHandle *fileHandle;

@end

@implementation LogConnection
@synthesize fileNamePrefix;
@synthesize fileHandle;

- (id)init {
    if ((self = [super init])) {
        
    }
    return self;
}

- (void)dealloc {
    [self.fileHandle closeFile];
}

- (void)beginNewFile {
    NSString *docsDirectory = [((AppDelegate *)[[UIApplication sharedApplication] delegate]) applicationDocumentsDirectory];
    
    NSDate *date = [NSDate date];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@", self.fileNamePrefix, [date description]];
    
    NSString *filePath = [docsDirectory stringByAppendingPathComponent:fileName];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }

    self.fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
}

- (void)printToLog:(NSString *)message {
    if (!self.fileHandle) {
        [self beginNewFile];
    }
    [self.fileHandle seekToEndOfFile];
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    [self.fileHandle writeData:data];
}

- (void)printLineToLog:(NSString *)message {
    NSString *newLineMessage = [message stringByAppendingString:@"\n"];
    [self printToLog:newLineMessage];
}


@end
