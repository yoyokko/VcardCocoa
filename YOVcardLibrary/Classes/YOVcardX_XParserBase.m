//
//  YOVcardX_XParserBase.m
//  YOVcardLibrary
//
//  Created by Edward Chen on 11/10/13.
//  Copyright (c) 2013 Edward Chen. All rights reserved.
//

#import "YOVcardX_XParserBase.h"
#import "NSString+QuotedPrintableEncodeDecode.h"
//#import "ISLog.h"
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

@implementation YOVcardX_XParserBase

@synthesize vcardString = vcardString_;
@synthesize scanner = scanner_;
@synthesize crlfCharacterSet = crlfCharacterSet_;
@synthesize knownLabelArray = knownLabelArray_;

- (void) dealloc
{
    [crlfCharacterSet_ release];
    [vcardString_ release];
    [scanner_ release];
    [knownLabelArray_ release];
    
    [super dealloc];
}

- (id) init
{
    self = [super init];
    if (self)
    {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"VCardLabel" ofType:@"plist"];
        knownLabelArray_ = [[NSArray alloc] initWithContentsOfFile:plistPath];
        if (knownLabelArray_ == nil)
        {
            knownLabelArray_ = [[NSArray arrayWithObjects:vN, vFN, vPHOTO, vADR, vTEL, vEMAIL, vNICKNAME, vTITLE, vORG, vNOTE, vURL, vBDAY, vPREF, @"CHARSET", @"ENCODING", nil] retain];
        }
    }
    return self;
}

- (void) parseVCardRepresentation:(NSString *) vcardRepresentation
{
    self.vcardString = vcardRepresentation;
    self.scanner = [NSScanner scannerWithString:self.vcardString];
    self.crlfCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"\r\n"];
}

- (NSString *) version
{
    return @"X_X";
}

- (BOOL) isAtEnd
{
    return [self.scanner isAtEnd];
}

- (NSString *) vcardRepresentation
{
    return self.vcardString;
}

- (NSUInteger) currentLocation
{
    return [self.scanner scanLocation];
}

- (void) scanToKeyName:(NSString *) vcardKeyName
{
    NSString *key = [NSString stringWithFormat:@"\r\n%@", vcardKeyName];
    [self.scanner scanUpToString:key intoString:NULL];
    if (self.scanner.isAtEnd == NO && (self.scanner.scanLocation + key.length) < self.vcardString.length)
    {
        unichar character = [self.vcardString characterAtIndex:(self.scanner.scanLocation + key.length)];
        if (character == ';' || character == ':')
        {
            return;
        }
        else
        {
            [self scanToKeyName:vcardKeyName];
        }
    }
}

- (id) valueForName:(NSString *) vcardKeyName
{
    NSUInteger currentLocation = [self.scanner scanLocation];

    @try
    {
        [self scanToKeyName:vcardKeyName];
        
        NSCharacterSet *whiteSapceNewLineCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *label = [self scannedLabelFromCurrentLocation];
        
        NSRange quoteprintableRange = [label rangeOfString:@"ENCODING=QUOTED-PRINTABLE" options:NSCaseInsensitiveSearch];
        NSRange base64Range = [label rangeOfString:@"ENCODING=BASE64" options:NSCaseInsensitiveSearch];
        if (quoteprintableRange.location != NSNotFound)
        {
            NSString *quotedPrintableValue = [[self scannedQuoutedPrintableValue] stringByTrimmingCharactersInSet:whiteSapceNewLineCharacterSet];
            NSString *decodedValue = [[quotedPrintableValue quotedPrintableDecoded] stringByTrimmingCharactersInSet:whiteSapceNewLineCharacterSet];
            if ([decodedValue length] != 0)
            {
                return decodedValue;
            }
            else
            {
                return quotedPrintableValue;
            }
        }
        else if (base64Range.location != NSNotFound)
        {
            NSString *base64String = [[self scannedValueFromCurrentLocation] stringByTrimmingCharactersInSet:whiteSapceNewLineCharacterSet];
            if ([base64String length] != 0) 
            {
                return [[base64String dataUsingEncoding:NSUTF8StringEncoding] base64Decoded];
            }
            else
            {
                return base64String;
            }
        }
        else
        {
            NSString *scannedValue = [[self scannedValueFromCurrentLocation] stringByTrimmingCharactersInSet:whiteSapceNewLineCharacterSet];
            return scannedValue;
        }
    }
    @catch (NSException *exception) 
    {
        //ISError(@"%@", exception);
        return nil;
    }
    @finally 
    {
        [self.scanner setScanLocation:currentLocation];
    }
}

- (NSRange) valueRangeForName:(NSString *) vcardKeyName
{
    NSUInteger currentLocation = [self.scanner scanLocation];
    
    @try
    {
        [self scanToKeyName:vcardKeyName];
        
        if (self.scanner.isAtEnd)
        {
            return NSMakeRange(NSNotFound, 0);
        }
        
        NSInteger location = self.scanner.scanLocation + 2;
        NSInteger length = 0;
        NSCharacterSet *whiteSapceNewLineCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *label = [self scannedLabelFromCurrentLocation];
        
        NSRange quoteprintableRange = [label rangeOfString:@"ENCODING=QUOTED-PRINTABLE" options:NSCaseInsensitiveSearch];
        if (quoteprintableRange.location != NSNotFound)
        {
            [[self scannedQuoutedPrintableValue] stringByTrimmingCharactersInSet:whiteSapceNewLineCharacterSet];
            length = self.scanner.scanLocation - location;
        }
        else
        {
            [[self scannedValueFromCurrentLocation] stringByTrimmingCharactersInSet:whiteSapceNewLineCharacterSet];
            length = self.scanner.scanLocation - location;
        }
        if (length > 0)
        {
            return NSMakeRange(location, length);
        }
        else
        {
            return NSMakeRange(NSNotFound, 0);
        }
    }
    @catch (NSException *exception)
    {
        return NSMakeRange(NSNotFound, 0);
    }
    @finally
    {
        [self.scanner setScanLocation:currentLocation];
    }
}

- (NSString *) unTransformedString:(NSString *) string
{
    NSMutableString *tempString = [NSMutableString string];
    NSInteger length = [string length];
    for (int i = 0; i < length; i ++)
    {
        unichar character = [string characterAtIndex:i];
        if (character == '\\')
        {
            if ((i+1) < length) 
            {
                unichar nextCharacter = [string characterAtIndex:i+1];
                [tempString appendFormat:@"%C", nextCharacter];
                i++;
            }
            else
            {
                [tempString appendFormat:@"%C", character];
            }
        }
        else
        {
            [tempString appendFormat:@"%C", character];
        }
    }
    
    return [NSString stringWithString:tempString];
}

- (NSArray *) labelComponentsSeparatedBySemicolon:(NSString *) label
{
    return [self componentsSeparatedBySemicolon:label unTransformString:NO];
}

- (NSArray *) valueComponentsSeparatedBySemicolon:(NSString *) value
{
    return [self componentsSeparatedBySemicolon:value unTransformString:YES];
}

- (NSArray *) componentsSeparatedBySemicolon:(NSString *) labelOrValue unTransformString:(BOOL) yesOrNo
{
    NSMutableArray *components = [NSMutableArray array];
    //NSCharacterSet *semicolonSet = [NSCharacterSet characterSetWithCharactersInString:@";"];
    NSScanner *theScanner = [NSScanner scannerWithString:[[labelOrValue copy] autorelease]];
    while ([theScanner isAtEnd] == NO) 
    {
        NSString *tempString = @"";
        NSUInteger offsetBefore = [theScanner scanLocation];
        if ([theScanner scanUpToString:@";" intoString:&tempString] == YES)
        {
            while ([tempString length] > 0 && [tempString hasSuffix:@"\\"] && ![tempString hasSuffix:@"\\\\"])
            {
                [theScanner scanString:@";" intoString:NULL];
                NSString *temp = @"";
                [theScanner scanUpToString:@";" intoString:&temp];
                tempString = [tempString stringByAppendingFormat:@";%@", temp];
            }
            [theScanner scanString:@";" intoString:NULL];
            if ([tempString rangeOfString:@"ENCODING" options:NSCaseInsensitiveSearch].location != NSNotFound ||
                [tempString rangeOfString:@"CHARSET" options:NSCaseInsensitiveSearch].location != NSNotFound) 
            {
                continue;
            }
            if (yesOrNo)
            {
                [components addObject:[self unTransformedString:tempString]];
            }
            else
            {
                [components addObject:tempString];
            }
        }
        // if the scanner is not at end, it must encountered a ;, so just add it.
        else if ([theScanner isAtEnd] == NO)
        {
            [theScanner scanString:@";" intoString:NULL];
            [components addObject:@""];
        }
        NSUInteger offsetAfter = [theScanner scanLocation];
        
        if (offsetBefore == offsetAfter)
        {
//            ISError(@"!!!!!!!!!!What's wrong with the vcf file line value [%@]. We scanned nothing. Just break the while.", labelOrValue);
            break;
        }
    }
    // we need to add a empty string to array.
    if ([labelOrValue hasSuffix:@";"]) 
    {
        [components addObject:@""];
    }
    
    if ([components count] == 0 && [labelOrValue length] != 0)
    {
        [components addObject:labelOrValue];
    }
    
    return [NSArray arrayWithArray:components];
}

- (NSDictionary *) labelInfoSeparatedBySemicolon:(NSString *) string
{
    NSMutableDictionary *labelDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *attributeDictionary = [NSMutableDictionary dictionary];
    NSMutableArray *typeArray = [NSMutableArray array];
    NSMutableArray *unknownLabelArray = [NSMutableArray array];
    NSMutableArray *unknownAttributeArray = [NSMutableArray array];
    
    NSArray *labelComponents = [self componentsSeparatedBySemicolon:string unTransformString:NO];
    for (NSString *component in labelComponents)
    {
        if ([labelComponents indexOfObject:component] == 0)
        {
            // it's key
            [labelDictionary setValue:component forKey:@"key"];
        }
        else if ([component rangeOfString:@"="].location != NSNotFound)
        {
            // it's attribute
            NSArray *attributeComponent = [component componentsSeparatedByString:@"="];
            NSString *attributeName = [attributeComponent objectAtIndex:0];
            NSString *attributeValue = [attributeComponent objectAtIndex:1];
            
            BOOL isKnownLabel = NO;
            for (NSString *knowLabel in self.knownLabelArray)
            {
                if ([knowLabel caseInsensitiveCompare:attributeName] == NSOrderedSame)
                {
                    isKnownLabel = YES;
                    break;
                }
            }
            if (!isKnownLabel)
            {
                [unknownAttributeArray addObject:component];
                continue;
            }
            
            NSArray *attributeValueArray = [attributeDictionary valueForKey:attributeName];
            if ([attributeValueArray count] == 0)
            {
                [attributeDictionary setValue:[NSArray arrayWithObject:attributeValue] forKey:attributeName];
            }
            else
            {
                NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:attributeValueArray];
                [mutableArray addObject:attributeValue];
                [attributeDictionary setValue:[NSArray arrayWithArray:mutableArray] forKey:attributeName];
            }
        }
        else
        {
            /*
            // it's label
            // check whether is is a known label
            BOOL isKnownLabel = NO;
            for (NSString *knowLabel in self.knownLabelArray)
            {
                if ([knowLabel caseInsensitiveCompare:component] == NSOrderedSame)
                {
                    isKnownLabel = YES;
                    break;
                }
            }
            if (!isKnownLabel)
            {
                [unknownLabelArray addObject:component];
                continue;
            }
            
            // remove x- prefix
            if ([component hasPrefix:@"X-"])
            {
                component = [component substringFromIndex:2];
            }
            */
            // Edit By Edward Chen, 2012/08/15
            // Just add the type to typeArray
            [typeArray addObject:component];
        }
    }
    
    [labelDictionary setValue:typeArray forKey:@"types"];
    [labelDictionary setValue:attributeDictionary forKey:@"attribute"];
    
    NSMutableString *unknown = [NSMutableString string];
    for (NSString *string in unknownLabelArray)
    {
        [unknown appendFormat:@"%@;", string];
    }
    for (NSString *string in unknownAttributeArray)
    {
        [unknown appendFormat:@"%@;", string];
    }
    
    [labelDictionary setValue:[unknown stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@";"]] forKey:@"unknown"];
    
    return labelDictionary;
}

- (NSString *) scannedLabelFromCurrentLocation
{
    NSString *tempLabel = @"";
    [self.scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@":"] intoString:&tempLabel];
    return tempLabel;
}

- (NSString *) scannedValueFromCurrentLocation
{
    NSMutableString *theValue = [NSMutableString stringWithString:@""];
    NSString *tempValue = @"";
    while ([self.scanner scanUpToCharactersFromSet:crlfCharacterSet_ intoString:&tempValue] == YES) 
    {
        if ([tempValue isEqualToString:@":"]) 
        {
            break;
        }
        else if ([tempValue hasPrefix:@":"])
        {
            tempValue = [tempValue substringFromIndex:1];
        }
        [theValue appendString:tempValue];
        
        NSUInteger currentLocation = [self.scanner scanLocation];
        NSString *nextLine = nil;
        [self.scanner scanUpToCharactersFromSet:crlfCharacterSet_ intoString:&nextLine];
        [self.scanner setScanLocation:currentLocation];
        if ([nextLine rangeOfString:@":"].location != NSNotFound) 
        {
            break;
        }
        tempValue = @"";
    }
    return [NSString stringWithString:theValue];
}

- (NSString *) scannedQuoutedPrintableValue
{
    NSMutableString *quotedPritableValue = [NSMutableString stringWithString:@""];
    NSString *tempValue = @"";
    while ([self.scanner scanUpToCharactersFromSet:crlfCharacterSet_ intoString:&tempValue] == YES) 
    {
        BOOL hasNextLine = NO;
        if ([tempValue isEqualToString:@":"]) 
        {
            break;
        }
        else if ([tempValue hasPrefix:@":"])
        {
            tempValue = [tempValue substringFromIndex:1];
        }
        if ([tempValue hasSuffix:@"="]) 
        {
            hasNextLine = YES;
            [quotedPritableValue appendString:[NSString stringWithFormat:@"%@\r\n", tempValue]];
        }
        else
        {
            [quotedPritableValue appendString:tempValue];
        }
        
        if (hasNextLine == NO)
        {
            break;
        }
        
        if ([self.scanner isAtEnd] == NO)
        {
            NSString *subString = [[self.scanner string] substringFromIndex:self.scanner.scanLocation];
            if ([subString hasPrefix:@"\r\n\r\n"] || [subString hasPrefix:@"\r\r"] || [subString hasPrefix:@"\n\n"]) 
            {
                break;
            }
        }
        
        tempValue = @"";
    }
    return [NSString stringWithString:quotedPritableValue];
}

- (NSString *) scannedBase64Value
{
    return nil;
}

@end
