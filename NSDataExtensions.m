//
//  NSDataExtensions.m
//  LineReader
//
//  Created by Tobias Preuss on 08.10.10.
//  Copyright 2010 Tobias Preuss. All rights reserved.
//

#import "NSDataExtensions.h"


/**
 Extension of the NSData class.
 @param Additions Additions.
 @returns An initialized NSData object or nil if the object could not be created.
 */
@implementation NSData (Additions)


/**
 Returns a range of data.
 @param dataToFind Data object specifying the delimiter and encoding.
 @returns A range.
 */
- (NSRange)rangeOfData:(NSData*)dataToFind {
	
	const void* bytes = [self bytes];
	NSUInteger length = [self length];
	const void* searchBytes = [dataToFind bytes];
	NSUInteger searchLength = [dataToFind length];
	NSUInteger searchIndex = 0;
	
	NSRange foundRange = {NSNotFound, searchLength};
	for (NSUInteger index = 0; index < length; index++) {
		// The current character matches.
		if (((char*)bytes)[index] == ((char*)searchBytes)[searchIndex]) {
			// Store found location if not done earlier.
			if (foundRange.location == NSNotFound) {
				foundRange.location = index;
			}
			// Increment search character index to check for match.
			searchIndex++;
			// All search character match.
			// Break search routine and return found position.
			if (searchIndex >= searchLength) {
				return foundRange;
			}
		}
		// Match does not continue.
		// Return to the first search character.
		// Discard former found location.
		else {
			searchIndex = 0;
			foundRange.location = NSNotFound;
		}
	}
	return foundRange;
}


- (NSRange)rangeOfDataBackwardsSearch:(NSData*)dataToFind {
	
	const void* bytes = [self bytes];
	NSUInteger length = [self length];
	const void* searchBytes = [dataToFind bytes];
	NSUInteger searchLength = [dataToFind length];
	NSUInteger searchIndex = 0;
	
	NSRange foundRange = {NSNotFound, searchLength};
	if (length < searchLength) {
		return foundRange;
	}
	for (NSUInteger index = length - searchLength; index >= 0;) {
//		NSLog(@"%c == %c", ((char*)bytes)[index], ((char*)searchBytes)[searchIndex]); /* DEBUG LOG */
		if (((char*)bytes)[index] == ((char*)searchBytes)[searchIndex]) {
			// The current character matches.
			if (foundRange.location == NSNotFound) {
				foundRange.location = index;
			}
			index++;
			searchIndex++;
			if (searchIndex >= searchLength) {
				return foundRange;
			}
		}
		else {
			// Decrement to search backwards.
			if (foundRange.location == NSNotFound) {
				index--;
			}
			// Jump over the former found location
			// to avoid endless loop.
			else {
				index = index - 2;
			}
			searchIndex = 0;
			foundRange.location = NSNotFound;
		}
	}
	return foundRange;
}

- (NSString*)stringValueWithEncoding:(NSStringEncoding)encoding {
	return [[NSString alloc] initWithData:self encoding:encoding];
}

@end