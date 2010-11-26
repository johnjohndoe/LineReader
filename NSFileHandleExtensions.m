//
//  NSFileHandleExtensions.m
//  LineReader
//
//  Created by Joe Yang on 08.11.10.
//  Copyright 2010 Joe Yang. All rights reserved.
//

#import "NSFileHandleExtensions.h"
#import "NSDataExtensions.h"


/**
	Extension on the NSFileHandle class.
	@category NSFileHandle(Readline)
	@abstract A category on NSFileHandle.
 */
@implementation NSFileHandle(Readline)


/**
	Reads data from the receiver from the front to the end.
	@returns The data available through the receiver.
 */
- (NSString*)readLine {

	
    NSString * _lineDelimiter = @"\n";
	
    NSData* newLineData = [_lineDelimiter dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData* currentData = [[NSMutableData alloc] init];
    BOOL shouldReadMore = YES;
	
    NSUInteger _chunkSize = 10;
	
    while (shouldReadMore) {
        NSData* chunk = [self readDataOfLength:_chunkSize]; // always length = 10
		//NSLog(@"%@", [chunk stringValueWithEncoding:NSUTF8StringEncoding]); /* DEBUG LOG */
		
        if ([chunk length] == 0) {
            break;
        }
		
        // Find the location and length of the next line delimiter.
        NSRange newLineRange = [chunk rangeOfData:newLineData];
        if (newLineRange.location != NSNotFound) {
            // Include the length so we can include the delimiter in the string.
            NSRange subDataRange = NSMakeRange(0, newLineRange.location + [newLineData length]);
            unsigned long long newOffset = [self offsetInFile] - [chunk length] + newLineRange.location + [newLineData length];
            [self seekToFileOffset:newOffset];
            chunk = [chunk subdataWithRange:subDataRange];
			//NSLog(@"%@", [chunk stringValueWithEncoding:NSUTF8StringEncoding]); /* DEBUG LOG */
            shouldReadMore = NO;
        }
        [currentData appendData:chunk];
    }
	
    NSString* line = [currentData stringValueWithEncoding:NSUTF8StringEncoding];
    return line;
}

/**
	Reads data from the receiver from the end to the front.
	@returns The data available through the receiver.
 */
- (NSString*)readLineBackwards {
	
    NSString * _lineDelimiter = @"\n";
	
    NSData* newLineData = [_lineDelimiter dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger _chunkSize = 10;
	
    NSMutableData* currentData = [[NSMutableData alloc] init];
    BOOL shouldReadMore = YES;
	
	NSLog(@"offsetInFile: %qu", [self offsetInFile]); /* DEBUG LOG */
	
    while (shouldReadMore) {
		
        unsigned long long offset;
		
        NSUInteger currentChunkSize = _chunkSize;
		
        if ([self offsetInFile] <= _chunkSize) {
            offset = 0;
            currentChunkSize = [self offsetInFile];
            shouldReadMore = NO;
        } else {
            offset = [self offsetInFile] - _chunkSize;
        }
		
        NSLog(@"seek to offset %qu, offset in file is %qu", offset, [self offsetInFile]);
		
        [self seekToFileOffset:offset];
		
        NSData* chunk = [self readDataOfLength:currentChunkSize];
		NSLog(@"offset: %qu", offset); /* DEBUG LOG */
		NSLog(@"chunk: %@", [chunk stringValueWithEncoding:NSUTF8StringEncoding]); /* DEBUG LOG */
		
        NSRange newLineRange = [chunk rangeOfDataBackwardsSearch:newLineData];
		
        if (newLineRange.location == NSNotFound) {
            [self seekToFileOffset:offset];
        }
		
        if (newLineRange.location != NSNotFound) {
            NSUInteger subDataLoc = newLineRange.location;
            NSUInteger subDataLen = currentChunkSize - subDataLoc;
            chunk = [chunk subdataWithRange:NSMakeRange(subDataLoc, subDataLen)];
            NSLog(@"got chunk data %@", [chunk stringValueWithEncoding:NSUTF8StringEncoding]);
            shouldReadMore = NO;
            [self seekToFileOffset:offset + newLineRange.location];
        }
        [currentData prepend:chunk];
    }
	
    NSString* line = [[NSString alloc] initWithData:currentData encoding:NSUTF8StringEncoding];
    return [line autorelease];
}

@end

