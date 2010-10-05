//
//  LineReaderAppDelegate.h
//	LineReader
//
//  Created by Tobias Preuss on 05.10.10.
//  Copyright 2010 Tobias Preuss. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LineReaderAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow*				window;
	IBOutlet NSTextField*	m_sourcePath;
	IBOutlet NSTableView*	m_tableView;
	NSArray*				m_directoryListing;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)sourcePathChanged:(id)sender;

@end
