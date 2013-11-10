//
//  YOVcardParserDelegate.h
//  YOVcardLibrary
//
//  Created by Edward Chen on 11/10/13.
//  Copyright (c) 2013 Edward Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const NoneEncoding;
extern NSString * const FailedDecoding;
extern NSString * const QuotedPrintableEncoding;
extern NSString * const Base64Encoding;

// You can write your own custom version parser 
// which implements following protocl methods.
@protocol YOVcardParserProtocol<NSObject>

@required
- (void) parseVCardRepresentation:(NSString *) vcardRepresentation;
- (NSString *) version;
- (BOOL) isAtEnd;
- (NSString *) vcardRepresentation;
- (NSUInteger) currentLocation;
- (NSString *) scannedLabelFromCurrentLocation;
- (NSString *) scannedValueFromCurrentLocation;
- (id) valueForName:(NSString *) vcardKeyName;
- (NSRange) valueRangeForName:(NSString *) vcardKeyName;
- (NSArray *) labelComponentsSeparatedBySemicolon:(NSString *) label;
- (NSDictionary *) labelInfoSeparatedBySemicolon:(NSString *) string;
- (NSArray *) valueComponentsSeparatedBySemicolon:(NSString *) value;

@optional
- (NSString *) scannedQuoutedPrintableValue;
- (NSString *) scannedBase64Value;

@end

// Client class instance need to implement following methods
// to receive parsed events and values.
@protocol YOVcardParserDelegate<NSObject>

@optional
// This method will be invoked when parser encountered a vcard version string.
- (void) parserDidStartVCard:(id<YOVcardParserProtocol>) parser;
// This method will be invoked when parser encountered "VCARD:END" string.
- (void) parserDidEndVCard:(id<YOVcardParserProtocol>) parser;
// This method will be invoded when parser encountered "VERSION:x.x" string.
- (void) parser:(id<YOVcardParserProtocol>) parser didGetVersion:(NSString *) version;
// This method will be invoked when parser encountered a label before ":" string.
- (void) parser:(id<YOVcardParserProtocol>) parser foundLabel:(NSString *) label;
// This method will be invoked when parser encountered a value after ":" but before another label.
- (void) parser:(id<YOVcardParserProtocol>) parser foundValue:(NSString *) value;
// This method will be invoked when parser pared a label and decoded value object. (Quoted-printable/Base64)
// attributes value is a NSArray.
- (void) parser:(id<YOVcardParserProtocol>) parser
      parsedKey:(NSString *) key
          types:(NSArray *) types
     attributes:(NSDictionary *) attributes
unknownTypesAndAttributes:(NSString *) unknown
    parsedLabel:(NSString *) parsedLabel
    parsedValue:(id) parsedValue
       encoding:(NSString *) encodingName;

@end
