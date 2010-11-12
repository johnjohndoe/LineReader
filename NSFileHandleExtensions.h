//
//  NSFileHandleExtensions.h
//  LineReader
//
//  Created by Joe Yang on 08.11.10.
//  Copyright 2010 Joe Yang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSFileHandle (Readline)

- (NSString*)readLine;
- (NSString*)readLineBackwards;

@end