//
//  LineParser.m
//  LineReader
//
//  Created by Tobias Preuss on 20.10.10.
//  Copyright 2010 Tobias Preuss. All rights reserved.
//

#import "LineParser.h"


@implementation LineParser

- (id)initWithOriginator:(id)originator andSelector:(SEL)selector andLines:(NSArray*)lines {
	self = [super init];
	if (self != nil) {
		m_originator = originator;
		m_selector = selector;
		m_lines = lines;
	}
	return self;
}

- (id)initWithOriginator:(id)originator andSelector:(SEL)selector andLine:(NSString*)line {
	return [self initWithOriginator:originator andSelector:selector andLines:[NSArray arrayWithObject:line]];
}



- (void)main {
	
	assert(m_originator);
	assert(m_selector);
	assert(m_lines);

	// Container to store parsed data in.
	NSMutableArray* dates = [NSMutableArray arrayWithCapacity:[m_lines count]];

	// Prepare date formatter.
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyyMMdd HH:mm:ss.SSS"];
	
	for (NSString* line in m_lines) {

		if ([self isCancelled]) {
			return;
		}
		
		// Remove trailing slash if appended.
		NSMutableString* mutableLine = [NSMutableString stringWithString:line];
		[mutableLine replaceOccurrencesOfString:@"\n" withString:@"" options:NSBackwardsSearch range:NSMakeRange([line length] - 1, 1)];
		
		// Convert string to double.
		NSDate* date = [dateFormatter dateFromString:mutableLine];
		NSTimeInterval timeInterval = [date timeIntervalSinceReferenceDate];
		[dates addObject:[NSNumber numberWithDouble:timeInterval]];
	}
	
	if (![self isCancelled]) {
		[m_originator performSelectorOnMainThread:m_selector withObject:dates waitUntilDone:NO];
	}
}

@end
