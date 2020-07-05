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
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    // Some filesystems hate colons
    NSString *dateString = [[dateFormatter stringFromDate:[NSDate date]] stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    // I hate spaces
    dateString = [dateString stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    // Nobody can stand forward slashes
    dateString = [dateString stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    
    NSString *fileName = [NSString stringWithFormat:@"%@_%@", self.fileNamePrefix, dateString];
    
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
