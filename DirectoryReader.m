//
//  DirectoryReader.m
//  LineReader
//
//  Created by Tobias Preuss on 05.10.10.
//  Copyright 2010 Tobias Preuss. All rights reserved.
//

#import "DirectoryReader.h"


/**
	A directory reader.
 */
@implementation DirectoryReader


/**
	Initializes a directory reader.
	@param path A directory path.
	@returns An initialized DirectoryReader object or nil if the object could not be created.
 */
- (id)initWithPath:(NSString*)path {

	self = [super init];
	if (self != nil) {
		if (!path || [path length] <= 0) {
			return nil;
		}
		// Remove trailing slash if appended.
		NSMutableString* mutablePath = [NSMutableString stringWithString:path];
		[mutablePath replaceOccurrencesOfString:@"/" withString:@"" options:NSBackwardsSearch range:NSMakeRange([path length] - 1, 1)];
		m_path = mutablePath;
	}
	return self;
}

/**
	Reads the content of a directory.
	@param files Container for the listing.
	@returns YES if the directory was read otherwise NO.
 */
- (BOOL)readDirectory:(NSArray**)files {

	BOOL success = false;
	
	NSArray* fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:m_path error:nil];
	
	if (!fileNames || [fileNames count] <= 0) {
		return success;
	}
	
	NSMutableArray* fullNames = [NSMutableArray arrayWithCapacity:[fileNames count]];
	for (NSString* fileName in fileNames) {
		NSString* fullPath = [m_path stringByAppendingString:[NSString stringWithFormat:@"/%@", fileName]];
		[fullNames addObject:fullPath];
	}
	
	if (fullNames && [fullNames count] > 0 && files) {
		*files = fullNames;
		success = YES;
	}
	return success;
}


@end
