//
//  FileReader.m
//  LineReader
//
//  Created by Tobias Preuss on 05.10.10.
//  Copyright 2010 Tobias Preuss. All rights reserved.
//
//  Originally written by Dave DeLong, 
//  Source: http://stackoverflow.com/questions/3707427#3711079


#import "FileReader.h"
#import "NSDataExtensions.h"


/**
	A file reader.
 */
@implementation FileReader


@synthesize lineDelimiter = m_lineDelimiter;
@synthesize chunkSize = m_chunkSize;


/**
	Initialized a file reader object.
	@param filePath A file path.
	@returns An initialized FileReader object or nil if the object could not be created.
 */
- (id)initWithFilePath:(NSString*)filePath {

	self = [super init];
	if (self != nil) {
		if (!filePath || [filePath length] <= 0) {
			return nil;
		}
		m_fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
		if (m_fileHandle == nil) {
			return nil;
		}
		// TODO: How can I use NSLineSeparatorCharacter instead of \n here?
		m_lineDelimiter = [[NSString alloc] initWithString:@"\n"];
		m_filePath = filePath;
		m_currentOffset = 0ULL;
		m_chunkSize = 10;
		[m_fileHandle seekToEndOfFile];
		m_totalFileLength = [m_fileHandle offsetInFile];
		// TODO Only needed for backwards reading.
		m_currentOffset = m_totalFileLength;
		NSLog(@"%qu characters in %@", m_totalFileLength, [filePath lastPathComponent]); /* DEBUG LOG */
		// We do not need to seek back since readLine will do that.
	}
	return self;
}



/**
	Reads the file forwards.
	@returns Another single line on each call or nil if the file end has been reached.
 */
- (NSString*)readLine {

	if (m_currentOffset >= m_totalFileLength) {
		return nil;
	}
	
	NSData* newLineData = [m_lineDelimiter dataUsingEncoding:NSUTF8StringEncoding];
	[m_fileHandle seekToFileOffset:m_currentOffset];
	NSMutableData* currentData = [[NSMutableData alloc] init];
	BOOL shouldReadMore = YES;
	
	while (shouldReadMore) {
		if (m_currentOffset >= m_totalFileLength) {
			break;
		}
		NSLog(@"\t   m_currentOffset: %qu", m_currentOffset); /* DEBUG LOG */
		NSData* chunk = [m_fileHandle readDataOfLength:m_chunkSize]; // always length = 10
		NSLog(@"\t\t\t\t chunk: %@", [chunk stringValueWithEncoding:NSUTF8StringEncoding]); /* DEBUG LOG */
		// Find the location and length of the next line delimiter.
		NSRange newLineRange = [chunk rangeOfData:newLineData];
		NSLog(@"\t\t  newLineRange: %d (%d)", newLineRange.location, newLineRange.length); /* DEBUG LOG */
		if (newLineRange.location != NSNotFound) {
			// Include the length so we can include the delimiter in the string.
			NSRange subDataRange = NSMakeRange(0, newLineRange.location + [newLineData length]);
			NSLog(@"\t\t  subDataRange: %d (%d)", subDataRange.location, subDataRange.length); /* DEBUG LOG */
			chunk = [chunk subdataWithRange:subDataRange];
//			NSLog(@"\t\t\t\t chunk: %@", [chunk stringValueWithEncoding:NSUTF8StringEncoding]); /* DEBUG LOG */
			shouldReadMore = NO;
		}
		[currentData appendData:chunk];
//		NSLog(@"\t\t   currentData: %@", [currentData stringValueWithEncoding:NSUTF8StringEncoding]); /* DEBUG LOG */
		m_currentOffset += [chunk length];
	}
	
	NSString* line = [currentData stringValueWithEncoding:NSUTF8StringEncoding];
	return line;
}




- (NSString*)readLineBackwards {

	if (m_currentOffset < 0ULL) {
		NSLog(@"RETURN NIL"); /* DEBUG LOG */
		return nil;
	}
	NSData* newLineData = [m_lineDelimiter dataUsingEncoding:NSUTF8StringEncoding];
	// Initialially shift backwards.
	if (m_currentOffset == m_totalFileLength) {
		m_currentOffset -= m_chunkSize;
	}
	[m_fileHandle seekToFileOffset:m_currentOffset];
	NSMutableData* currentData = [[NSMutableData alloc] init];
	BOOL shouldReadMore = YES;
	
	while (shouldReadMore) {
		
//		if (m_currentOffset <= 0ULL) {
//			NSLog(@"BREAK"); /* DEBUG LOG */
//			break;
//		}
		//m_currentOffset -= m_chunkSize;
		NSUInteger currentChunkSize = m_chunkSize;
		if (m_currentOffset < 0ULL) {
			do {
				m_currentOffset++;
				currentChunkSize--;
			} while (m_currentOffset <= 0ULL);
		}
		else {
			NSLog(@"else"); /* DEBUG LOG */
		}

		NSData* chunk = [m_fileHandle readDataOfLength:currentChunkSize];
		NSLog(@"chunk: %@", [chunk stringValueWithEncoding:NSUTF8StringEncoding]); /* DEBUG LOG */
		
		
		NSString* bar = @"\ntwo\nthree";
		NSData* baz = [bar dataUsingEncoding:NSUTF8StringEncoding];
		NSRange newLineRange2 = [baz rangeOfDataBackwardsSearch:newLineData];
		NSLog(@"TEST: %d %d", newLineRange2.location, newLineRange2.length); /* DEBUG LOG */
		
		
		NSRange newLineRange = [chunk rangeOfDataBackwardsSearch:newLineData];
		if (newLineRange.location != NSNotFound) {
			NSUInteger subDataLoc = newLineRange.location + [newLineData length];
			NSUInteger subDataLen = currentChunkSize - subDataLoc;			
			chunk = [chunk subdataWithRange:NSMakeRange(subDataLoc, subDataLen)];
			NSLog(@"chunk: %@", [chunk stringValueWithEncoding:NSUTF8StringEncoding]); /* DEBUG LOG */
			shouldReadMore = NO;
		}
		[currentData appendData:chunk];
		int foo = m_currentOffset - m_chunkSize;
		if (foo < 0) {
			m_currentOffset = 0ULL;
		}
		else {
			m_currentOffset = foo;
		}
	}
	NSString* line = [[NSString alloc] initWithData:currentData encoding:NSUTF8StringEncoding];
	return line;
}




/**
	Reads the file forwards while trimming white spaces.
	@returns Another single line on each call or nil if the file end has been reached.
 */
- (NSString*)readTrimmedLine {
	
	return [[self readLine] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}



#if NS_BLOCKS_AVAILABLE
/**
	Reads the file forwards using a block object.
	@param block
 */
- (void)enumerateLinesUsingBlock:(void(^)(NSString*, BOOL*))block {
	NSString* line = nil;
	BOOL stop = NO;
	while (stop == NO && (line = [self readLine])) {
		block(line, &stop);
	}
}
#endif



@end

