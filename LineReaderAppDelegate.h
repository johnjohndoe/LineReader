//
//  LineReaderAppDelegate.h
//	LineReader
//
//  Created by Tobias Preuss on 05.10.10.
//  Copyright 2010 Tobias Preuss. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LineReaderAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow*				m_window;
	IBOutlet NSTextField*	m_sourcePath;
	NSNumber*				m_maxNumLines;
	NSArray*				m_directoryListing;
}

@property (assign) IBOutlet NSWindow* window;
@property (readwrite, assign) NSString* sourcePath;
@property (readwrite, assign) NSNumber* maxNumLines;

- (IBAction)sourcePathChanged:(id)sender;

@end
