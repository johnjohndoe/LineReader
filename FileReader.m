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
	Files can be read forwards or backwards by calling the 
	corresponding function multiple times.
 */
@implementation FileReader

- (void)dealloc{
    [m_fileHandle release], m_fileHandle = nil;
    [super dealloc];
}

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
		m_fileHandle = [[NSFileHandle fileHandleForReadingAtPath:filePath] retain];
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
		m_currentInset = m_totalFileLength;						
		m_prevDelimiterRange = NSMakeRange(m_currentInset, 1);			
		
		NSLog(@"%qu characters in %@", m_totalFileLength, [filePath lastPathComponent]); /* DEBUG LOG */
	}
	return self;
}



/**
	Reads the file forwards.
	Empty lines are not returned.
	@returns Another single line on each call or nil if the file end has been reached.
 */
- (NSString*)readLine {

	if (m_totalFileLength == 0 || m_currentOffset >= m_totalFileLength) {
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
		NSData* chunk = [m_fileHandle readDataOfLength:m_chunkSize]; // always length = 10
		// Find the location and length of the next line delimiter.
		NSRange newLineRange = [chunk rangeOfData:newLineData];
		if (newLineRange.location != NSNotFound) {
			// Include the length so we can include the delimiter in the string.
			NSRange subDataRange = NSMakeRange(0, newLineRange.location + [newLineData length]);
			chunk = [chunk subdataWithRange:subDataRange];
			shouldReadMore = NO;
		}
		[currentData appendData:chunk];
		m_currentOffset += [chunk length];
	}

	NSString* line = [currentData stringValueWithEncoding:NSUTF8StringEncoding];
    // finished with data
    [currentData release], currentData = nil;
	return line;
}




/**
	Reads the file backwards.
	Empty lines are returned as well.
	@returns Another single line on each call or nil if the file end has been reached.
 */
- (NSString*)readLineBackwards {

	if (m_totalFileLength == 0 || (m_currentInset == 0 && m_chunkSize == 0)) {
		return nil;
	}
	
	NSData* newLineData = [m_lineDelimiter dataUsingEncoding:NSUTF8StringEncoding];
	NSUInteger currentChunkSize = m_chunkSize;
	
	
	// Process block smaller than standard chunk size.
	// Shrink current chunk size.
	// Shift inset to zero.
	if (m_currentInset < m_chunkSize) {
		currentChunkSize = m_currentInset;
		m_currentInset -= currentChunkSize;
	}
	// Process blocks of chunk size.
	// Shift inset by standard chunk size.
	if (m_currentInset >= m_chunkSize && m_currentInset <= m_totalFileLength) {
		m_currentInset -= m_chunkSize;
	}
	[m_fileHandle seekToFileOffset:m_currentInset];

	
	NSMutableData* currentData = [[NSMutableData alloc] init];
	BOOL shouldReadMore = YES;
	
	while (shouldReadMore) {
		
		if (m_currentInset == NSNotFound) {
			break;
		}
		
		NSData* chunk = [m_fileHandle readDataOfLength:currentChunkSize];
		NSRange newLineRange = [chunk rangeOfDataBackwardsSearch:newLineData];
		m_prevDelimiterRange = NSMakeRange(m_currentInset + newLineRange.location, newLineRange.length);
		if (newLineRange.location == NSNotFound) {
			m_prevDelimiterRange = NSMakeRange(NSNotFound, 0);
		}
		if (newLineRange.location != NSNotFound) {
			NSUInteger subDataLoc = newLineRange.location + [newLineData length];
			NSUInteger subDataLen = currentChunkSize - subDataLoc;			
			chunk = [chunk subdataWithRange:NSMakeRange(subDataLoc, subDataLen)];
			shouldReadMore = NO;
		}
		[currentData prepend:chunk];
		
		
		
		if (m_prevDelimiterRange.location == NSNotFound) {
			// Process block smaller than standard chunk size.
			// Shrink current chunk size.
			// Shift inset to zero.
			// Break while loop if front has been reached.
			if (m_currentInset < currentChunkSize) {				
				currentChunkSize = m_currentInset;
				m_currentInset -= currentChunkSize;				
				if (currentChunkSize == 0 && m_currentInset == 0) {
					m_chunkSize = 0;
					break;
				}
			}
			// Process blocks of chunk size.
			// Shift inset by standard chunk size.
			else {
				currentChunkSize = m_chunkSize;
				m_currentInset -= currentChunkSize;
			}			
			[m_fileHandle seekToFileOffset:m_currentInset];
		}
		// Shift inset to last found position.
		else {			
			m_currentInset = m_prevDelimiterRange.location;
		}
		
	} // End if while.
	
	NSString* line = [[NSString alloc] initWithData:currentData encoding:NSUTF8StringEncoding];
    // finished with data
    [currentData release], currentData = nil;
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

