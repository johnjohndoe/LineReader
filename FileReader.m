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



// -----------------------------------------------------------------------------
// NSData extensions declaration.
// -----------------------------------------------------------------------------


@interface NSData (Additions)

- (NSRange)rangeOfData:(NSData*)dataToFind;
- (NSRange)rangeOfDataBackwardsSearch:(NSData*)dataToFind;
- (NSString*)stringValueWithEncoding:(NSStringEncoding)encoding;

@end


// -----------------------------------------------------------------------------
// NSData extensions implementation.
// -----------------------------------------------------------------------------



/**
 Extension of the NSData class.
 @param Additions Additions.
 @returns An initialized NSData object or nil if the object could not be created.
 */
@implementation NSData (Additions)


/**
 Returns a range of data.
 @param dataToFind Data object specifying the delimiter and encoding.
 @returns A range.
 */
- (NSRange)rangeOfData:(NSData*)dataToFind {
	
	const void* bytes = [self bytes];
	NSUInteger length = [self length];
	const void* searchBytes = [dataToFind bytes];
	NSUInteger searchLength = [dataToFind length];
	NSUInteger searchIndex = 0;
	
	NSRange foundRange = {NSNotFound, searchLength};
	for (NSUInteger index = 0; index < length; index++) {
		// The current character matches.
		if (((char*)bytes)[index] == ((char*)searchBytes)[searchIndex]) {
			// Store found location if not done earlier.
			if (foundRange.location == NSNotFound) {
				foundRange.location = index;
			}
			// Increment search character index to check for match.
			searchIndex++;
			// All search character match.
			// Break search routine and return found position.
			if (searchIndex >= searchLength) {
				return foundRange;
			}
		}
		// Match does not continue.
		// Return to the first search character.
		// Discard former found location.
		else {
			searchIndex = 0;
			foundRange.location = NSNotFound;
		}
	}
	return foundRange;
}


- (NSRange)rangeOfDataBackwardsSearch:(NSData*)dataToFind {
	
	const void* bytes = [self bytes];
	NSUInteger length = [self length];
	const void* searchBytes = [dataToFind bytes];
	NSUInteger searchLength = [dataToFind length];
	NSUInteger searchIndex = 0;
	
	NSRange foundRange = {NSNotFound, searchLength};
	for (NSUInteger index = length - searchLength; index >= 0;) {
		if (((char*)bytes)[index] == ((char*)searchBytes)[searchIndex]) {
			// The current character matches.
			if (foundRange.location == NSNotFound) {
				foundRange.location = index;
			}
			index++;
			searchIndex++;
			if (searchIndex >= searchLength) {
				return foundRange;
			}
		}
		else {
			// Decrement to search backwards.
			if (foundRange.location == NSNotFound) {
				index--;
			}
			// Jump over the former found location
			// to avoid endless loop.
			else {
				index = index - 2;
			}
			searchIndex = 0;
			foundRange.location = NSNotFound;
		}
	}
	return foundRange;
}

- (NSString*)stringValueWithEncoding:(NSStringEncoding)encoding {
	return [[NSString alloc] initWithData:self encoding:encoding];
}

@end





// -----------------------------------------------------------------------------
// FileReader implementation.
// -----------------------------------------------------------------------------




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
		// Find the location and length of the next line delimiter.
		NSRange newLineRange = [chunk rangeOfData:newLineData];
		NSLog(@"\t\t  newLineRange: %d (%d)", newLineRange.location, newLineRange.length); /* DEBUG LOG */
		if (newLineRange.location != NSNotFound) {
			// Include the length so we can include the delimiter in the string.
			NSRange subDataRange = NSMakeRange(0, newLineRange.location + [newLineData length]);
			NSLog(@"\t\t  subDataRange: %d (%d)", subDataRange.location, subDataRange.length); /* DEBUG LOG */
			chunk = [chunk subdataWithRange:subDataRange];
			NSLog(@"\t\t\t\t chunk: %@", [chunk stringValueWithEncoding:NSUTF8StringEncoding]); /* DEBUG LOG */
			shouldReadMore = NO;
		}
		[currentData appendData:chunk];
		NSLog(@"\t\t   currentData: %@", [currentData stringValueWithEncoding:NSUTF8StringEncoding]); /* DEBUG LOG */
		m_currentOffset += [chunk length];
	}
	
	NSString* line = [currentData stringValueWithEncoding:NSUTF8StringEncoding];
	return line;
}




- (NSString*)readLineBackwards {
	
	if (m_currentOffset >= m_totalFileLength) {
		return nil;
	}
	
	NSData* newLineData = [m_lineDelimiter dataUsingEncoding:NSUTF8StringEncoding];	
	m_currentOffset = m_totalFileLength - m_chunkSize;
	[m_fileHandle seekToFileOffset:m_currentOffset];
	NSMutableData* currentData = [[NSMutableData alloc] init];
	BOOL shouldReadMore = YES;
	
	while (shouldReadMore) {
//		if (m_currentOffset >= m_totalFileLength) {
//			break;
//		}
		NSLog(@"\t   m_currentOffset: %qu", m_currentOffset); /* DEBUG LOG */
		if (m_currentOffset <= 0ULL) {
			break;
		}
		NSData* chunk = [m_fileHandle readDataOfLength:m_chunkSize];
		NSLog(@"chunk: %@", [chunk stringValueWithEncoding:NSUTF8StringEncoding]); /* DEBUG LOG */
		// Find the location and length of the next line delimiter.
		NSRange newLineRange = [chunk rangeOfDataBackwardsSearch:newLineData];
		NSLog(@"\t\t  newLineRange: %d (%d)", newLineRange.location, newLineRange.length); /* DEBUG LOG */
		if (newLineRange.location != NSNotFound) {
			// Include the length so we can include the delimiter in the string.
			NSUInteger chunkLength = newLineRange.location - [newLineData length];
			chunk = [chunk subdataWithRange:NSMakeRange(m_currentOffset - chunkLength, chunkLength)];
			shouldReadMore = NO;
		}
		[currentData appendData:chunk];
		m_currentOffset -= [chunk length];
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

