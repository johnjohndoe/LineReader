//
//  BackendBuffer.m
//  LineReader
//
//  Created by Tobias Preuss on 20.10.10.
//  Copyright 2010 Tobias Preuss. All rights reserved.
//

#import "BackendBuffer.h"


@implementation BackendBuffer

- (id)init {
	self = [super init];
	if (self != nil) {
		m_dates = [NSMutableArray array];
	}
	return self;
}

- (void)addValues:(NSArray*)values {
	
	@synchronized(self) {

		// Add dates.
		[m_dates addObjectsFromArray:values];
		
		// Prepare date formatter.
		static NSDateFormatter* dateFormatter = nil;
		if (!dateFormatter) {
			dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setDateFormat:@"yyyyMMdd HH:mm:ss.SSS"];
		}
		
		// Print dates to console.
		for (NSNumber* timeInterval in m_dates) {
			NSDate* date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:[timeInterval doubleValue]];
			NSLog(@"%@", [dateFormatter stringFromDate:date]); /* DEBUG LOG */
		}
	}
	NSLog(@"---"); /* DEBUG LOG */
}

@end
