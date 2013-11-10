//
//  YOVcard2_1QRCodeGenerator.m
//  CamCard
//
//  Created by Edward Chen on 11/10/13.
//  Copyright (c) 2013 Edward Chen. All rights reserved.
//

#import "YOVcard2_1QRCodeGenerator.h"
#define QR_BUFFER_LIMIT 510


@implementation YOVcard2_1QRCodeGenerator

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
    
    NSMutableString *bufferString = [[NSMutableString alloc] init];
    [bufferString appendFormat:@"%@:%@\r\n", self.typesString, self.valueString];

    const char* buffer1 = [vcardRepresentation_ UTF8String];
    const char* buffer2 = [bufferString UTF8String];
    if (strlen(buffer1) + strlen(buffer2) < QR_BUFFER_LIMIT && [bufferString length] != 0)
    {
        [vcardRepresentation_ appendString:bufferString];
    }
    [bufferString release];
}

- (void) beginVcard
{
    [vcardRepresentation_ appendString:@"BEGIN:VCARD\r\nVERSION:2.1\r\n"];
}

- (void) endVcard
{
    [vcardRepresentation_ appendString:@"END:VCARD\r\n"];
}

@end
