//
//  FileReader.h
//  LineReader
//
//  Created by Tobias Preuss on 05.10.10.
//  Copyright 2010 Tobias Preuss. All rights reserved.
//
//  Originally written by Dave DeLong, 
//  Source: http://stackoverflow.com/questions/3707427#3711079

#import <Cocoa/Cocoa.h>


@interface FileReader : NSObject {
	
	NSString*			m_filePath;
	NSFileHandle*		m_fileHandle;
	unsigned long long	m_currentOffset;
	unsigned long long	m_totalFileLength;
	NSString*			m_lineDelimiter;
	NSUInteger			m_chunkSize;
}

@property (nonatomic, copy) NSString* lineDelimiter;
@property (nonatomic) NSUInteger chunkSize;

- (id)initWithFilePath:(NSString*)filePath;
- (NSString*)readLine;
- (NSString*)readLineBackwards;
- (NSString*)readTrimmedLine;

#if NS_BLOCKS_AVAILABLE
- (void)enumerateLinesUsingBlock:(void(^)(NSString*, BOOL*))block;
#endif

@end