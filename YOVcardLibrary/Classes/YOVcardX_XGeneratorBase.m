//
//  YOVcardX_XGeneratorBase.m
//  YOVcardLibrary
//
//  Created by Edward Chen on 11/10/13.
//  Copyright (c) 2013 Edward Chen. All rights reserved.
//

#import "YOVcardX_XGeneratorBase.h"
#import "NSString+QuotedPrintableEncodeDecode.h"
#import "NSData+EncodeData.h"

extern NSString * const vN;
extern NSString * const vFN;
extern NSString * const vPHOTO;
extern NSString * const vADR;
extern NSString * const vTEL;
extern NSString * const vEMAIL;
extern NSString * const vNICKNAME;
extern NSString * const vTITLE;
extern NSString * const vORG;
extern NSString * const vNOTE;
extern NSString * const vURL;
extern NSString * const vBDAY;
extern NSString * const vPREF;
extern NSString * const vXAUTHOR;

@interface YOVcardX_XGeneratorBase ()

@property (nonatomic, retain) NSMutableString *privateVcardRepresentation;
@property (nonatomic, retain) NSCharacterSet *needTransformedCharacterSet;
@property (nonatomic, retain) NSArray *knownLabelArray;

@end

@implementation YOVcardX_XGeneratorBase

@synthesize privateVcardRepresentation = vcardRepresentation_;
@synthesize needTransformedCharacterSet = needTransformedCharacterSet_;
@synthesize typesString = typesString_;
@synthesize valueString = valueString_;
@synthesize encoding = encoding_;
@synthesize characterSet = characterSet_;
@synthesize knownLabelArray = knownLabelArray_;

- (void) dealloc
{
    [vcardRepresentation_ release];
    [needTransformedCharacterSet_ release];
    
    [typesString_ release];
    [valueString_ release];
    [encoding_ release];
    [characterSet_ release];
    
    [knownLabelArray_ release];
    
    [super dealloc];
}

- (id) init
{
    self = [super init];
    if (self)
    {
        vcardRepresentation_ = [[NSMutableString alloc] init];
        needTransformedCharacterSet_ = [[NSCharacterSet characterSetWithCharactersInString:@"\\;"] retain];
        
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"VCardLabel" ofType:@"plist"];
        knownLabelArray_ = [[NSArray alloc] initWithContentsOfFile:plistPath];
        if (knownLabelArray_ == nil)
        {
            knownLabelArray_ = [[NSArray arrayWithObjects:vN, vFN, vPHOTO, vADR, vTEL, vEMAIL, vNICKNAME, vTITLE, vORG, vNOTE, vURL, vBDAY, vPREF, @"CHARSET", @"ENCODING", nil] retain];
        }
    }
    return self;
}

- (NSString *) transformedString:(NSString *) string
{
    return [self transformedString:string forCharacters:needTransformedCharacterSet_];
}

- (NSString *) transformedString:(NSString *) string forCharacters:(NSCharacterSet *) needTransformedCharacterSet
{
    NSMutableString *tempString = [NSMutableString string];
    
    for (int i = 0; i < [string length]; i ++)
    {
        unichar character = [string characterAtIndex:i];
        if ([needTransformedCharacterSet characterIsMember:character])
        {
            [tempString appendFormat:@"\\%C", character];
        }
        else
        {
            [tempString appendFormat:@"%C", character];
        }
    }

    return [NSString stringWithString:tempString];
}

- (BOOL) isStringNeedQTEncoding:(NSString *) string
{
    return [string rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]].location != NSNotFound;
}

- (NSString *) vcardRepresentation
{
    return [NSString stringWithFormat:@"%@", self.privateVcardRepresentation];
}

- (void) beginVcard
{
    [self doesNotRecognizeSelector:_cmd];
}
 
- (void) beginLine
{
    self.typesString = [NSMutableString string];
    self.stringValue = nil;
    self.encoding = nil;
    self.characterSet = nil;
}

- (void) addLineWithBlock:(YOVcardGeneratorLineBlock) lineBlock
{
    if (lineBlock == NULL)
    {
        return;
    }
    
    [self beginLine];
    
    lineBlock();
    
    [self endLine];
}

- (void) addLineWithString:(NSString *) lineString
{
    if ([lineString length] == 0)
    {
        return;
    }
    
    [self.privateVcardRepresentation appendString:lineString];
    
    if (![[lineString substringFromIndex:[lineString length] - 5] isEqualToString:@"\r\n"])
    {
        [self.privateVcardRepresentation appendString:@"\r\n"];
    }
}

- (void) addType:(NSString *) type
{
    if ([type length] == 0)
    {
        return;
    }
    
    [self addTypes:[NSArray arrayWithObject:type]];
}

- (NSString *) updateType:(NSString *) type
{
    /*
    // add x- for unkown type
    if ([type rangeOfString:@"="].location != NSNotFound)
    {
        // it's a attribute. do not update
        return type;
    }
    
    if ([type rangeOfString:@","].location != NSNotFound)
    {
        // it contains multi type. do not update
        return type;
    }
    
    BOOL isKnownLabel = NO;
    for (NSString *knowLabel in self.knownLabelArray)
    {
        if ([knowLabel caseInsensitiveCompare:type] == NSOrderedSame)
        {
            isKnownLabel = YES;
            break;
        }
    }
    if (!isKnownLabel)
    {
        if (![type hasPrefix:@"X-"])
        {
            return [NSString stringWithFormat:@"X-%@", type];
        }
    }
    */
    return type;
}

- (void) addTypes:(NSArray *) types
{
    if ([types count] == 0)
    {
        return;
    }
    
    BOOL isFirstType = [self.typesString length] == 0;
    if (!isFirstType)
    {
        [self.typesString appendString:@";"];
    }
    
    if (isFirstType)
    {
        [self.typesString appendString:[types objectAtIndex:0]];
    }
    else
    {
        [self.typesString appendString:[self updateType:[types objectAtIndex:0]]];
    }
    
    for (int i = 1; i < [types count]; i++)
    {
        NSString *type = [types objectAtIndex:i];
        type = [self updateType:type];
        [self.typesString appendFormat:@";%@", type];
    }
}

- (void) addAttributes:(NSDictionary *) attributes
{
    if ([[attributes allKeys] count] == 0)
    {
        return;
    }

    
    if ([self.typesString length] != 0)
    {
        [self.typesString appendString:@";"];
    }
    
    NSArray *attributeKeys = [attributes allKeys];
    
    BOOL addedOneAttribute = NO;
    for (NSString *key in attributeKeys)
    {
        id value = [attributes valueForKey:key];
        if ([value isKindOfClass:[NSArray class]])
        {
            for (NSString *stringValue in value)
            {
                if (!addedOneAttribute)
                {
                    [self.typesString appendFormat:@"%@=%@", key, stringValue];
                    addedOneAttribute = YES;
                }
                else
                {
                    [self.typesString appendFormat:@";%@=%@", key, stringValue];
                }
            }
        }
        else if ([value isKindOfClass:[NSString class]])
        {
            if (!addedOneAttribute)
            {
                [self.typesString appendFormat:@"%@=%@", key, value];
                addedOneAttribute = YES;
            }
            else
            {
                [self.typesString appendFormat:@";%@=%@", key, value];
            }
        }
    }
}

- (void) setStringValue:(NSString *) stringValue
{
    if ([self.encoding length] == 0 && [self isStringNeedQTEncoding:stringValue])
    {
        [self setEncoding:@"QUOTED-PRINTABLE"];
        self.valueString = [stringValue quotedPrintableEncoded];
    }
    else
    {
        self.valueString = stringValue;
    }
}

- (void) setStringValues:(NSArray *) stringValues
{
    if ([stringValues count] == 0)
    {
        return;
    }
    
    NSMutableString *tempString = [NSMutableString stringWithString:[self transformedString:[stringValues objectAtIndex:0]]];
    for (int i = 1; i < [stringValues count]; i ++)
    {
        [tempString appendFormat:@";%@", [self transformedString:[stringValues objectAtIndex:i]]];
    }
    [self setStringValue:tempString];
}

- (void) setDoubleValue:(double) doubleValue
{
    [self setStringValue:[NSString stringWithFormat:@"%f", doubleValue]];
}

- (void) setFloatValue:(float) floatValue
{
    [self setStringValue:[NSString stringWithFormat:@"%f", floatValue]];
}

- (void) setIntegerValue:(NSInteger) integerValue
{
    [self setStringValue:[NSString stringWithFormat:@"%ld", (long)integerValue]];
}

- (void) setDataValue:(NSData *) dataValue
{
    [self setEncoding:@"BASE64"];
    [self setStringValue:[dataValue base64Encoded]];
}

- (void) setDateValue:(NSDate *) dateValue
{
    if (dateValue == nil)
    {
        return;
    }
    
    [self setStringValue:[NSString stringWithFormat:@"%f", [dateValue timeIntervalSince1970]]];
}

- (void) endLine
{
    if ([self.typesString length] == 0 || [self.valueString length] == 0)
    {
        return;
    }
    
    if ([self.characterSet length] != 0)
    {
        [self addType:[NSString stringWithFormat:@"CHARSET=%@", self.characterSet]];
    }
    
    if ([self.encoding length] != 0)
    {
        [self addType:[NSString stringWithFormat:@"ENCODING=%@", self.encoding]];
    }
    
    [self.privateVcardRepresentation appendFormat:@"%@:%@\r\n", self.typesString, self.valueString];
    
    self.typesString = nil;
    self.stringValue = nil;
}


- (void) endVcard
{
    [self doesNotRecognizeSelector:_cmd];
}

@end
