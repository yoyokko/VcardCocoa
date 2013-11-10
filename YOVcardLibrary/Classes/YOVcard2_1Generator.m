//
//  YOVcard2_1Generator.m
//  YOVcardLibrary
//
//  Created by Edward Chen on 11/10/13.
//  Copyright (c) 2013 Edward Chen. All rights reserved.
//

#import "YOVcard2_1Generator.h"

@implementation YOVcard2_1Generator

- (void) endLine
{
    if ([self.characterSet length] == 0)
    {
        [self setCharacterSet:@"utf-8"];
    }

    [super endLine];
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
