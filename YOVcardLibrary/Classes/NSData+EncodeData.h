//
//  NSData+EncodeData.h
//  YOVcardLibrary
//
//  Created by Edward Chen on 11/10/13.
//  Copyright (c) 2013 Edward Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (DDData)

- (NSData *) md5Digest;
- (NSString *) md5String;

- (NSData *) sha1Digest;

- (NSString *) hexStringValue;

- (NSString *) base64Encoded;
- (NSData *) base64Decoded;

@end
