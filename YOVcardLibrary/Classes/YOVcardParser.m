//
//  YOVcardParser.m
//  YOVcardLibrary
//
//  Created by Edward Chen on 11/10/13.
//  Copyright (c) 2013 Edward Chen. All rights reserved.
//

#import "YOVcardParser.h"
#import "NSString+QuotedPrintableEncodeDecode.h"
#import "NSData+EncodeData.h"

NSString * const NoneEncoding = @"None";
NSString * const FailedDecoding = @"FailedDecoding";
NSString * const QuotedPrintableEncoding = @"QUOTED-PRINTABLE";
NSString * const Base64Encoding = @"BASE64";

@interface YOVcardParser ()

@property (nonatomic, retain) id<YOVcardParserProtocol> parser;
@property (nonatomic, copy) NSString *vcardStringRepresentation;

- (void) backgroundParseVCard:(id) object;

// send delegate message on main thread.
- (void) sendDidStartMessage;
- (void) sendDidEndMessage;
- (void) sendFoundLabelMessage:(NSString *) label;
- (void) sendFoundValueMessage:(NSString *) label;
- (void) sendParsedLabelAndValueMessage:(NSArray *) array;

@end

@implementation YOVcardParser

@synthesize delegate = delegate_;
@synthesize parser = parser_;
@synthesize vcardStringRepresentation = vcardStringRepresentation_;

- (void) dealloc
{
    delegate_ = nil;
    [parser_ release];
    [vcardStringRepresentation_ release];
    
    [super dealloc];
}

- (void) setVCardRepresentation:(NSString *) vcardRepresentation
{
    self.vcardStringRepresentation = vcardRepresentation;
}

- (void) setVCardFilePath:(NSString *) vcardFilePath
{
    [self setVCardRepresentation:[NSString stringWithContentsOfFile:vcardFilePath encoding:NSUTF8StringEncoding error:NULL]];
}

- (BOOL) isVcardValid:(NSError **) error
{
    if ([self.vcardStringRepresentation length] == 0) 
    {
        if (error != NULL)
        {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:[NSDictionary dictionaryWithObject:@"VCard representation is nil." forKey:NSLocalizedDescriptionKey]];
        }
        return NO;
    }
//    if (self.parser) 
//    {
//        if (error != NULL)
//        {
//            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-2 userInfo:[NSDictionary dictionaryWithObject:NSTobeLocalizedString(@"Parsing is in progress.", @"Parsing is in progress.") forKey:NSLocalizedDescriptionKey]];
//        }
//        return NO;
//    }
    
    NSScanner *theScanner = [NSScanner scannerWithString:self.vcardStringRepresentation];
    
    if ([theScanner scanString:@"BEGIN:VCARD" intoString:NULL] == NO)
    {
        if (error != NULL)
        {
//            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-2 userInfo:[NSDictionary dictionaryWithObject:NSTobeocalizedString(@"There is no BEGIN:VCARD info in vcard representation.", @"There is no BEGIN:VCARD info in vcard representation.") forKey:NSLocalizedDescriptionKey]];
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-2 userInfo:[NSDictionary dictionaryWithObject:@"There is no BEGIN:VCARD info in vcard representation." forKey:NSLocalizedDescriptionKey]];
        }
        return NO;
    }
    
    NSString *filteredVersion = nil;
    //if no version,should try to use 2.1 vcard parser to parse it.
    if ([theScanner scanString:@"VERSION:" intoString:NULL] == NO)
    {
        if (error != NULL)
        {
//            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-2 userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"There is no VERSION info in vcard representation.", @"There is no VERSION info in vcard representation.") forKey:NSLocalizedDescriptionKey]];
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-2 userInfo:[NSDictionary dictionaryWithObject:@"There is no VERSION info in vcard representation." forKey:NSLocalizedDescriptionKey]];
        }
    }
    else
    {
        NSString *versionString = nil;
        [theScanner scanUpToString:@"\r\n" intoString:&versionString];
        if ([versionString length] == 0) 
        {
            if (error != NULL)
            {
//                    *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-2 userInfo:[NSDictionary dictionaryWithObject:NSTobeLocalizedString(@"The value of VERSION is nil.", @"The value of VERSION is nil.") forKey:NSLocalizedDescriptionKey]];
                *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-2 userInfo:[NSDictionary dictionaryWithObject:@"The value of VERSION is nil." forKey:NSLocalizedDescriptionKey]];
            }
        }
        if (versionString != nil)
        {
            filteredVersion = [[versionString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@"." withString:@"_"];
        }
        else
        {
            filteredVersion = @"2_1";
        }
    }
    
    Class parserClass = NSClassFromString([NSString stringWithFormat:@"YOVcard%@Parser", filteredVersion]);
    if (parserClass == NULL)
    {
        parserClass = NSClassFromString(@"YOVcard2_1Parser");
    }
    self.parser = [[[parserClass alloc] init] autorelease];
    if (!self.parser) 
    {
        if (error != NULL)
        {
//            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-2 userInfo:[NSDictionary dictionaryWithObject:NSTobeLocalizedString(@"The version of vcard is not support yet.", @"The version of vcard is not support yet.") forKey:NSLocalizedDescriptionKey]];
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-2 userInfo:[NSDictionary dictionaryWithObject:@"The version of vcard is not support yet." forKey:NSLocalizedDescriptionKey]];
            
        }
        return NO;
    }
    
    return YES;
}

- (id) valueForName:(NSString *) vcardKeyName error:(NSError **) error
{
    BOOL isValid = [self isVcardValid:error];
    if (isValid == NO)
    {
        return nil;
    }
    if ([vcardKeyName length] == 0)
    {
        return nil;
    }
    [self.parser parseVCardRepresentation:self.vcardStringRepresentation];
    return [self.parser valueForName:vcardKeyName];
}

- (NSRange) valueRangeForName:(NSString *) vcardKeyName error:(NSError **) error
{
    BOOL isValid = [self isVcardValid:error];
    if (isValid == NO)
    {
        return NSMakeRange(NSNotFound, 0);
    }
    if ([vcardKeyName length] == 0)
    {
        return NSMakeRange(NSNotFound, 0);
    }
    [self.parser parseVCardRepresentation:self.vcardStringRepresentation];
    return [self.parser valueRangeForName:vcardKeyName];
}

- (BOOL) startSynchronously:(BOOL) synchronize error:(NSError **) error
{
    BOOL isValid = [self isVcardValid:error];
    if (isValid == NO)
    {
        return NO;
    }
    
    isSyncronize_ = synchronize;
    
    if (synchronize == NO)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
        {
            [self backgroundParseVCard:nil];
        });
    }
    else
    {
        [self backgroundParseVCard:nil];
    }
    return YES;
}

- (BOOL) start:(NSError **) error
{
    return [self startSynchronously:NO error:error];
}

- (void) backgroundParseVCard:(id) object
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSCharacterSet *whiteSapceNewLineCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    [self.parser parseVCardRepresentation:self.vcardStringRepresentation];
    
    while ([self.parser isAtEnd] == NO)
    {
        @autoreleasepool
        {
            NSString *label = [[self.parser scannedLabelFromCurrentLocation] stringByTrimmingCharactersInSet:whiteSapceNewLineCharacterSet];
            if ([label compare:@"BEGIN" options:NSCaseInsensitiveSearch] == NSOrderedSame)
            {
                [self sendDidStartMessage];
                [self.parser scannedValueFromCurrentLocation];
                continue;
            }
            else if ([label compare:@"END" options:NSCaseInsensitiveSearch] == NSOrderedSame)
            {
                [self sendDidEndMessage];
                [self.parser scannedValueFromCurrentLocation];
                continue;
            }
            else if ([label compare:@"VERSION" options:NSCaseInsensitiveSearch] == NSOrderedSame)
            {
                NSString *versionString = [self.parser scannedValueFromCurrentLocation];
                [self sendDidGetVersionMessage:versionString];
                continue;
            }
            
            [self sendFoundLabelMessage:label];
            
            NSRange quoteprintableRange = [label rangeOfString:@"ENCODING=QUOTED-PRINTABLE" options:NSCaseInsensitiveSearch];
            NSRange base64Range = [label rangeOfString:@"ENCODING=BASE64" options:NSCaseInsensitiveSearch];
            if (quoteprintableRange.location != NSNotFound)
            {
                NSString *quotedPrintableValue = [[self.parser scannedQuoutedPrintableValue] stringByTrimmingCharactersInSet:whiteSapceNewLineCharacterSet];
                [self sendFoundValueMessage:quotedPrintableValue];
                NSDictionary *labelInfo = [self.parser labelInfoSeparatedBySemicolon:label];
                NSString *decodedValue = [quotedPrintableValue quotedPrintableDecoded];
                if ([decodedValue length] != 0)
                {
                    [self sendParsedLabelAndValueMessage:[NSArray arrayWithObjects:labelInfo, label, decodedValue, QuotedPrintableEncoding, nil]];
                }
                else
                {
                    [self sendParsedLabelAndValueMessage:[NSArray arrayWithObjects:labelInfo, label, quotedPrintableValue, FailedDecoding, nil]];
                }
            }
            else if (base64Range.location != NSNotFound)
            {
                NSString *base64String = [[self.parser scannedValueFromCurrentLocation] stringByTrimmingCharactersInSet:whiteSapceNewLineCharacterSet];
                [self sendFoundValueMessage:base64String];
                NSDictionary *labelInfo = [self.parser labelInfoSeparatedBySemicolon:label];
                if ([base64String length] != 0)
                {
                    NSData *decodedValue = [[base64String dataUsingEncoding:NSUTF8StringEncoding] base64Decoded];
                    [self sendParsedLabelAndValueMessage:[NSArray arrayWithObjects:labelInfo, label, decodedValue, Base64Encoding, nil]];
                }
                else
                {
                    [self sendParsedLabelAndValueMessage:[NSArray arrayWithObjects:labelInfo, label, base64String, FailedDecoding, nil]];
                }
            }
            else
            {
                NSString *scannedValue = [[self.parser scannedValueFromCurrentLocation] stringByTrimmingCharactersInSet:whiteSapceNewLineCharacterSet];
                NSDictionary *labelInfo = [self.parser labelInfoSeparatedBySemicolon:label];
                [self sendFoundValueMessage:scannedValue];
                [self sendParsedLabelAndValueMessage:[NSArray arrayWithObjects:labelInfo, label, scannedValue, NoneEncoding, nil]];
            }
        }
    }
    
    [pool release];
}

- (void) sendDidStartMessage
{
    if ([self.delegate respondsToSelector:@selector(parserDidStartVCard:)])
    {
        if (isSyncronize_)
        {
            [self.delegate parserDidStartVCard:self.parser];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self.delegate parserDidStartVCard:self.parser];
            });
        }
    }
}

- (void) sendDidEndMessage
{
    if ([self.delegate respondsToSelector:@selector(parserDidEndVCard:)])
    {
        if (isSyncronize_)
        {
            [self.delegate parserDidEndVCard:self.parser];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self.delegate parserDidEndVCard:self.parser];
            });
        }
    }
}

- (void) sendDidGetVersionMessage:(NSString *) version
{
    if ([self.delegate respondsToSelector:@selector(parser:didGetVersion:)])
    {
        if (isSyncronize_)
        {
            [self.delegate parser:self.parser didGetVersion:version];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self.delegate parser:self.parser didGetVersion:version];
            });
        }
    }
}

- (void) sendFoundLabelMessage:(NSString *) label
{
    if ([self.delegate respondsToSelector:@selector(parser:foundLabel:)])
    {
        if (isSyncronize_)
        {
            [self.delegate parser:self.parser foundLabel:label];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self.delegate parser:self.parser foundLabel:label];
            });
        }
    }
}

- (void) sendFoundValueMessage:(NSString *) value
{
    if ([self.delegate respondsToSelector:@selector(parser:foundValue:)])
    {
        if (isSyncronize_)
        {
            [self.delegate parser:self.parser foundValue:value];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self.delegate parser:self.parser foundValue:value];
            });
        }
    }
}

- (void) sendParsedLabelAndValueMessage:(NSArray *) array
{
    NSDictionary *labelInfo = [array objectAtIndex:0];
    NSString *key = [labelInfo valueForKey:@"key"];
    NSArray *types = [labelInfo valueForKey:@"types"];
    NSDictionary *attribute = [labelInfo valueForKey:@"attribute"];
    NSString *unknown = [labelInfo valueForKey:@"unknown"];
    
    if ([self.delegate respondsToSelector:@selector(parser:parsedKey:types:attributes:unknownTypesAndAttributes:parsedLabel:parsedValue:encoding:)] && [array count] == 4)
    {
        if (isSyncronize_)
        {
            [self.delegate parser:self.parser
                        parsedKey:key
                            types:types
                       attributes:attribute
        unknownTypesAndAttributes:unknown
                      parsedLabel:[array objectAtIndex:1]
                      parsedValue:[array objectAtIndex:2]
                         encoding:[array objectAtIndex:3]];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self.delegate parser:self.parser
                            parsedKey:key
                                types:types
                           attributes:attribute
            unknownTypesAndAttributes:unknown
                          parsedLabel:[array objectAtIndex:1]
                          parsedValue:[array objectAtIndex:2]
                             encoding:[array objectAtIndex:3]];
            });
        }
    }
}

@end
