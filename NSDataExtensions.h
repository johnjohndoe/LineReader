//
//  NSDataExtensions.h
//  LineReader
//
//  Created by Tobias Preuss on 08.10.10.
//  Copyright 2010 Tobias Preuss. All rights reserved.
//



// -----------------------------------------------------------------------------
// NSData additions.
// -----------------------------------------------------------------------------

@interface NSData (Additions)

- (NSRange)rangeOfData:(NSData*)dataToFind;
- (NSRange)rangeOfDataBackwardsSearch:(NSData*)dataToFind;
- (NSString*)stringValueWithEncoding:(NSStringEncoding)encoding;

@end


// -----------------------------------------------------------------------------
// NSMutableData additions.
// -----------------------------------------------------------------------------

@interface NSMutableData (Additions)

- (void)prepend:(NSData*)data;

@end