//
//  YOVcardGeneratorProtocol.h
//  YOVcardLibrary
//
//  Created by Edward Chen on 11/10/13.
//  Copyright (c) 2013 Edward Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^YOVcardGeneratorLineBlock) ();

typedef NSInteger YOVcardVersion;
enum
{
    YOVcardVersion2_1 = 1,
    YOVcardVersion3_0 = 2,
    YOVcardVersion2_1QRCode = 3,
};

@protocol YOVcardGeneratorProtocol<NSObject>

- (NSString *) vcardRepresentation;

- (void) beginVcard;

- (void) endVcard;

- (void) beginLine;
- (void) addLineWithBlock:(YOVcardGeneratorLineBlock) lineBlock;
- (void) addLineWithString:(NSString *) lineString;

- (void) addType:(NSString *) type;
- (void) addTypes:(NSArray *) types;
// value for dictionary should be NSArray or NSString.
- (void) addAttributes:(NSDictionary *) attributes;

- (void) setEncoding:(NSString *) encoding;
- (void) setCharacterSet:(NSString *) characterSet;

- (void) setStringValue:(NSString *) stringValue;
- (void) setStringValues:(NSArray *) stringValues;
- (void) setDoubleValue:(double) doubleValue;
- (void) setFloatValue:(float) floatValue;
- (void) setIntegerValue:(NSInteger) integerValue;
- (void) setDataValue:(NSData *) dataValue;
- (void) setDateValue:(NSDate *) dateValue;

- (void) endLine;

@end
