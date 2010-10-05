//
//  FileReader.m
//  LineReader
//
//  Created by Tobias Preuss on 05.10.10.
//  Copyright 2010 Tobias Preuss. All rights reserved.
//
//	Source: Dave DeLong, http://stackoverflow.com/questions/3707427#3711079


#import "FileReader.h"



// -----------------------------------------------------------------------------
// NSData extension.
// -----------------------------------------------------------------------------


@interface NSData (Additions)

- (NSRange)rangeOfData:(NSData*)dataToFind;

@end



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
		if (((char*)bytes)[index] == ((char*)searchBytes)[searchIndex]) {
			// The current character matches.
			if (foundRange.location == NSNotFound) {
				foundRange.location = index;
			}
			searchIndex++;
			if (searchIndex >= searchLength) {
				return foundRange;
			}
		}
		else {
			searchIndex = 0;
			foundRange.location = NSNotFound;
		}
	}
	return foundRange;
}

@end




// -----------------------------------------------------------------------------
// FileReader class.
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
		m_fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
		if (m_fileHandle == nil) {
			return nil;
		}
		m_lineDelimiter = [[NSString alloc] initWithString:@"\n"];
		m_filePath = filePath;
		m_currentOffset = 0ULL;
		m_chunkSize = 10;
		[m_fileHandle seekToEndOfFile];
		m_totalFileLength = [m_fileHandle offsetInFile];
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
		NSData* chunk = [m_fileHandle readDataOfLength:m_chunkSize];
		NSRange newLineRange = [chunk rangeOfData:newLineData];
		if (newLineRange.location != NSNotFound) {
			// Include the length so we can include the delimiter in the string.
			chunk = [chunk subdataWithRange:NSMakeRange(0, newLineRange.location + [newLineData length])];
			shouldReadMore = NO;
		}
		[currentData appendData:chunk];
		m_currentOffset += [chunk length];
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
