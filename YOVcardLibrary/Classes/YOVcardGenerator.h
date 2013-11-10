//
//  YOVcardGenerator.h
//  YOVcardLibrary
//
//  Created by Edward Chen on 11/10/13.
//  Copyright (c) 2013 Edward Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YOVcardGeneratorProtocol.h"

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

@interface YOVcardGenerator : NSObject

+ (id<YOVcardGeneratorProtocol>) vcardGeneratorForVersion:(YOVcardVersion) vcardVersion;

@end
