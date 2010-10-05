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


@synthesize window;



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

	DirectoryReader* dr = [[DirectoryReader	alloc] initWithPath:[m_sourcePath stringValue]];
	if ([dr readDirectory:&m_directoryListing]) {
		NSLog(@"%@",m_directoryListing); /* DEBUG LOG */
		
		for (NSString* path in m_directoryListing) {
			
			int numLines = 0;
			
			FileReader* fr = [[FileReader alloc] initWithFilePath:path];
			NSString* line = nil;
			while (numLines <= 5 && (line = [fr readTrimmedLine])) {
				NSLog(@"%@",line); /* DEBUG LOG */
				numLines++;
			}
		}			
	}
}

@end
