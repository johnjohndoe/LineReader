//
//  NSDataExtensionsTest.m
//  LineReader
//
//  Created by Tobias Preuss on 06.10.10.
//  Copyright 2010 Tobias Preuss. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSDataExtensions.h"


/**
	Test for NSData rangeOfDataBackwardsSearch:
	@param contents Contents string data.
	@param delimiter Delimiter string data.
 */
void testSearch(NSString* contents, NSString* delimiter) {

	
	NSLog(@"\n\nTEST SEARCH"); /* DEBUG LOG */
	
	NSLog(@"Contents length: %d", [contents length]); /* DEBUG LOG */
	NSLog(@"Delimiter length: %d", [delimiter length]); /* DEBUG LOG */
	
	// -----------------------------------------------------------------------------
	// Test using NSString objects.
	// -----------------------------------------------------------------------------
	
	NSRange r1 = [contents rangeOfString:delimiter];
	NSLog(@"NSString forwards: \t%3.d (%d)", r1.location, r1.length); /* DEBUG LOG */
	NSRange r2 = [contents rangeOfString:delimiter options:NSBackwardsSearch];
	NSLog(@"NSString backwards: \t%3.d (%d)", r2.location, r2.length); /* DEBUG LOG */
	
	
	// -----------------------------------------------------------------------------
	// Test using NSData objects.
	// -----------------------------------------------------------------------------
	
	NSData* delimData = [delimiter dataUsingEncoding:NSUTF8StringEncoding];
	NSData* contentsData = [contents dataUsingEncoding:NSUTF8StringEncoding];
	
	NSRange r3 = [contentsData rangeOfData:delimData];
	NSLog(@"NSData forwards: \t%3.d (%d)", r3.location, r3.length); /* DEBUG LOG */
	
	NSRange r4 = [contentsData rangeOfDataBackwardsSearch:delimData];
	NSLog(@"NSData backwards: \t%3.d (%d)", r4.location, r4.length); /* DEBUG LOG */
}


/**
	Test for NSMutableData insertAtFront:
	@param s1 First string data.
	@param s2 Second string data.
 */
void testInsert(NSString* s1, NSString* s2) {


	NSLog(@"\n\nTEST INSERT"); /* DEBUG LOG */
	
	NSMutableData* d1 = [NSMutableData dataWithData:[s1 dataUsingEncoding:NSUTF8StringEncoding]];
	NSData* d2 = [s2 dataUsingEncoding:NSUTF8StringEncoding];
	NSLog(@"Before = %@", [d1 stringValueWithEncoding:NSUTF8StringEncoding]); /* DEBUG LOG */	
	[d1 prepend:d2];
	NSLog(@"After = %@", [d1 stringValueWithEncoding:NSUTF8StringEncoding]); /* DEBUG LOG */
	
}


/**
	Main.
	@returns Exit code.
 */
int main() {

	
	testSearch(@"onetwothree", @"\n");
	testSearch(@"one\ntwo\nthree", @"\n");
	testInsert(@"front", @"end");
}








