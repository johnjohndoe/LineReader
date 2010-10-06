//
//  NSDataExtensionsTest.m
//  LineReader
//
//  Created by Tobias Preuss on 06.10.10.
//  Copyright 2010 Tobias Preuss. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FileReader.h"


int main()

{
	NSString* contents = @"one\ntwo\nthree\none\ntwo\nthree";
	NSString* delim = @"o\n";
	
	// -----------------------------------------------------------------------------
	// Test using NSString objects.
	// -----------------------------------------------------------------------------
	
	NSRange r1 = [contents rangeOfString:delim];
	NSLog(@"NSString forwards: \t%3.d (%d)", r1.location, r1.length); /* DEBUG LOG */
	NSRange r2 = [contents rangeOfString:delim options:NSBackwardsSearch];
	NSLog(@"NSString backwards: \t%3.d (%d)", r2.location, r2.length); /* DEBUG LOG */
	
	
	// -----------------------------------------------------------------------------
	// Test using NSData objects.
	// -----------------------------------------------------------------------------
	
	NSData* delimData = [delim dataUsingEncoding:NSUTF8StringEncoding];
	NSData* contentsData = [contents dataUsingEncoding:NSUTF8StringEncoding];
	
	NSRange r3 = [contentsData rangeOfData:delimData];
	NSLog(@"NSData forwards: \t%3.d (%d)", r3.location, r3.length); /* DEBUG LOG */

	NSRange r4 = [contentsData rangeOfDataBackwardsSearch:delimData];
	NSLog(@"NSData backwards: \t%3.d (%d)", r4.location, r4.length); /* DEBUG LOG */
}
