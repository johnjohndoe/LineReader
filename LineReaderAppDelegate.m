//
//  LineReaderAppDelegate.m
//  LineReader
//
//  Created by Tobias Preuss on 05.10.10.
//  Copyright 2010 Tobias Preuss. All rights reserved.
//

#import "LineReaderAppDelegate.h"
#import "DirectoryReader.h"
#import "FileReader.h"


/**
	Application delegate.
 */
@implementation LineReaderAppDelegate


/**
	Initializes an application delegate object.
	@returns An initialized LineReaderAppDelegate object or nil if the object could not be created.
 */
- (id)init {

	self = [super init];
	if (self != nil) {
		m_maxNumLines = [NSNumber numberWithInt:3];
		[self setSourcePath:[NSString stringWithFormat:@"/tmp/"]];
	}
	return self;
}


@synthesize window = m_window;
@synthesize maxNumLines = m_maxNumLines;
@dynamic sourcePath;

- (NSString*)sourcePath {
	return [m_sourcePath stringValue];
}

- (void)setSourcePath:(NSString*)sourcePath {
	m_sourcePath = [[NSTextField alloc] init];	
	if (!sourcePath || [sourcePath length] <= 0) {
		[m_sourcePath setStringValue:@""];
		return;
	}	
	[m_sourcePath setStringValue:sourcePath];
}

/**
	Sent by the default notification center after the application 
	has been launched and initialized but before it has received 
	its first event.
	@param aNotification A notification named NSApplicationDidFinishLaunchingNotification.
 */
- (void)applicationDidFinishLaunching:(NSNotification*)aNotification {
}



/**
	Is called when the source path changes.
	@param sender The object calling this method.
 */
- (IBAction)sourcePathChanged:(id)sender {
	
	DirectoryReader* directoryReader = [[DirectoryReader alloc] initWithPath:[m_sourcePath stringValue]];
	if (!directoryReader) {
		return;
	}

	if ([directoryReader readDirectory:&m_directoryListing]) {

		for (NSString* path in m_directoryListing) {
			NSLog(@"File: %@", path); /* DEBUG LOG */
			int numLine = 0;
			FileReader* fileReader = [[FileReader alloc] initWithFilePath:path];
			if (!fileReader) {
				return;
			}
			
			NSString* line = nil;
			while (line = [fileReader readLine]) {
				numLine++;
				NSLog(@"------------------ %2.d: %@", numLine, line); /* DEBUG LOG */
				if (numLine >= [m_maxNumLines intValue]) {
					break;
				}
			}
		}		
	}
}

@end
