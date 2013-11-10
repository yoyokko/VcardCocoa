//
//  NSString+QuotedPrintableEncodeDecode.h
//  YOVcardLibrary
//
//  Created by Edward Chen on 11/10/13.
//  Copyright (c) 2013 Edward Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSString_QuotedPrintableEncodeDecode)

- (NSString *) quotedPrintableEncoded;
- (NSString *) quotedPrintableDecoded;

@end
