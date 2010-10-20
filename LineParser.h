//
//  LineParser.h
//  LineReader
//
//  Created by Tobias Preuss on 20.10.10.
//  Copyright 2010 Tobias Preuss. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LineParser : NSThread {
	
	id			m_originator;	// Main thread
	SEL			m_selector;		// Selector of the synchronize function in the main thread.
	NSArray*	m_lines;		// Collection of lines.

}

- (id)initWithOriginator:(id)originator andSelector:(SEL)selector andLines:(NSArray*)lines;
- (id)initWithOriginator:(id)originator andSelector:(SEL)selector andLine:(NSString*)line;

@end
