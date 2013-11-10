//
//  YOVcardX_XParserBase.h
//  YOVcardLibrary
//
//  Created by Edward Chen on 11/10/13.
//  Copyright (c) 2013 Edward Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YOVcardParserDelegate.h"

@interface YOVcardX_XParserBase : NSObject<YOVcardParserProtocol>
{
@private
    NSString *vcardString_;
    NSScanner *scanner_;
    NSCharacterSet *crlfCharacterSet_;
    
    NSArray *knownLabelArray_;
}

@property (nonatomic, copy) NSString *vcardString;
@property (nonatomic, copy) NSScanner *scanner;
@property (nonatomic, retain) NSCharacterSet *crlfCharacterSet;
@property (nonatomic, retain) NSArray *knownLabelArray;

- (NSArray *) componentsSeparatedBySemicolon:(NSString *) string unTransformString:(BOOL) yesOrNo;
- (NSDictionary *) labelInfoSeparatedBySemicolon:(NSString *) string;
- (NSString *) unTransformedString:(NSString *) string;
- (NSString *) scannedQuoutedPrintableValue;
- (NSString *) scannedBase64Value;

@end
