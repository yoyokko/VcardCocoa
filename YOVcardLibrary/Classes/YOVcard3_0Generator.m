//
//  YOVcard3_0Generator.m
//  YOVcardLibrary
//
//  Created by Edward Chen on 11/10/13.
//  Copyright (c) 2013 Edward Chen. All rights reserved.
//

#import "YOVcard3_0Generator.h"

@implementation YOVcard3_0Generator

- (void) beginVcard
{
    [vcardRepresentation_ appendString:@"BEGIN:VCARD\r\nVERSION:3.0\r\n"];
}

- (void) endVcard
{
    [vcardRepresentation_ appendString:@"END:VCARD\r\n"];
}

@end
