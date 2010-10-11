//
//  LineReaderAppDelegate.h
//	LineReader
//
//  Created by Tobias Preuss on 05.10.10.
//  Copyright 2010 Tobias Preuss. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LineReaderAppDelegate : NSObject <NSApplicationDelegate> {

    NSWindow*				m_window;				/**< Application window. */
	IBOutlet NSTextField*	m_sourcePath;			/**< Source path. */
	NSNumber*				m_maxNumLines;			/**< Maximum number of lines. */
	NSNumber*				m_searchBackwards;		/**< Search backwards if value is 1. */
	NSArray*				m_directoryListing;		/**< Collection of file paths. */
}

@property (assign) IBOutlet NSWindow* window;				/**< Property for the application window. */
@property (readwrite, assign) NSString* sourcePath;			/**< Property for the source path. */
@property (readwrite, assign) NSNumber* maxNumLines;		/**< Property for the maximum number of lines. */
@property (readwrite, assign) NSNumber* searchBackwards;	/**< Property for switch to search backwards. */

- (IBAction)sourcePathChanged:(id)sender;

@end
