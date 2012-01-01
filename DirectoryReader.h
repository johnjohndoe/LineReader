//
//  DirectoryReader.h
//  LineReader
//
//  Created by Tobias Preuss on 05.10.10.
//  Copyright 2010 Tobias Preuss. All rights reserved.
//



@interface DirectoryReader : NSObject {

	NSString*	m_path;		/**< File path. */
}

- (id)initWithPath:(NSString*)path;
- (BOOL)readDirectory:(NSArray**)files;

/**
 Returns array of string paths for each file in the directory, sorted by file modification date, descending
 @param files output parameter containing the file paths
 @returns BOOL indicating whether the directory file list could be read
 */
- (BOOL)readDirectoryByFileModificationDateDesc:(NSArray**)files;
@end
