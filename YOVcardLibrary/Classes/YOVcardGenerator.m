//
//  YOVcardGenerator.m
//  YOVcardLibrary
//
//  Created by Edward Chen on 11/10/13.
//  Copyright (c) 2013 Edward Chen. All rights reserved.
//

#import "YOVcardGenerator.h"
#import "YOVcard2_1Generator.h"
#import "YOVcard3_0Generator.h"
#import "YOVcard2_1QRCodeGenerator.h"

NSString * const vN = @"N"; // name
NSString * const vFN = @"FN"; // formatted name
NSString * const vPHOTO = @"PHOTO"; // photograph
NSString * const vADR = @"ADR"; // delivery address
NSString * const vTEL = @"TEL"; // telephone
NSString * const vEMAIL = @"EMAIL"; // email
NSString * const vNICKNAME = @"NICKNAME";
NSString * const vTITLE = @"TITLE"; // title
NSString * const vORG = @"ORG"; // organization name or organization unit
NSString * const vNOTE = @"NOTE"; // Note
NSString * const vURL = @"URL"; // URL internet location
NSString * const vBDAY = @"BDAY"; // birthday
NSString * const vPREF = @"PREF"; // preferred item

@implementation YOVcardGenerator

+ (id<YOVcardGeneratorProtocol>) vcardGeneratorForVersion:(YOVcardVersion) vcardVersion
{
    switch (vcardVersion)
    {
        case YOVcardVersion2_1:
        {
            return [[[YOVcard2_1Generator alloc] init] autorelease];
        }
            break;
        case YOVcardVersion3_0:
        {
            return [[[YOVcard3_0Generator alloc] init] autorelease];
        }
            break;
        case YOVcardVersion2_1QRCode:
        {
            return [[[YOVcard2_1QRCodeGenerator alloc] init] autorelease];
        }
        default:
        {
            return [[[YOVcard2_1Generator alloc] init] autorelease];
        }
            break;
    }
}

@end
