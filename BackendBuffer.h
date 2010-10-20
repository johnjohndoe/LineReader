//
//  BackendBuffer.h
//  LineReader
//
//  Created by Tobias Preuss on 20.10.10.
//  Copyright 2010 Tobias Preuss. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BackendBuffer : NSObject {

	NSMutableArray*		m_dates;	
}

- (void)addValues:(NSArray*)values;

@end
