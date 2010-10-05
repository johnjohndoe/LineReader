//
//  DirectoryReader.h
//  LineReader
//
//  Created by Tobias Preuss on 05.10.10.
//  Copyright 2010 Tobias Preuss. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DirectoryReader : NSObject {

	NSString*	m_path;	
}

- (BOOL)readDirectory:(NSArray**)files;

@end
