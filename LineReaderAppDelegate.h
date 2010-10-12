//
//  LineReaderAppDelegate.h
//	LineReader
//
//  Created by Tobias Preuss on 05.10.10.
//  Copyright 2010 Tobias Preuss. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
	Enum for the selected read mode. Defined values are FORWARDS = 0 and BACKWARDS = 1.
 */
typedef enum { FORWARDS = 0, BACKWARDS = 1 } READ_MODE;



@interface LineReaderAppDelegate : NSObject <NSApplicationDelegate> {

    NSWindow*		m_window;				/**< Application window. */
	NSString*		m_sourcePath;			/**< Source path. */
	NSNumber*		m_maxNumLines;			/**< Maximum number of lines. */
	NSNumber*		m_selectedReadMode;		/**< Selected read mode. See READ_MODE enum. */
	NSNumber*		m_printLines;			/**< Option to print lines to the console. */
	NSString*		m_status;				/**< Program status. */
	NSArray*		m_directoryListing;		/**< Collection of file paths. */
}

@property (assign) IBOutlet NSWindow* window;				/**< Property for the application window. */
@property (readwrite, assign) NSString* sourcePath;			/**< Property for the source path. */
@property (readwrite, assign) NSNumber* maxNumLines;		/**< Property for the maximum number of lines. */
@property (readwrite, assign) NSNumber* selectedReadMode;	/**< Property for the selected read mode. */
@property (readwrite, assign) NSNumber* printLines;			/**< Property for the print lines option. */
@property (readwrite, assign) NSString* status;				/**< Property for the program status. */

- (IBAction)readLinesRequested:(id)sender;

// -----------------------------------------------------------------------------
// Private functions.
// -----------------------------------------------------------------------------

- (void)processSource;

@end
