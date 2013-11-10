//
//  YOVcardParser.h
//  YOVcardLibrary
//
//  Created by Edward Chen on 11/10/13.
//  Copyright (c) 2013 Edward Chen. All rights reserved.
//

#import "YOVcardParserDelegate.h"

// YOVcardParser is a event driven vcard parser class.
// It will find each paired key:value and will notify 
// delegate in main thread with callbacks.
// To use it, alloc a YOVcardParser instance, set the vcard representaiton,
// maybe a file path or vcard string, and set the callback delegate.
// Finally, call start: method, if parser starts successfully, it will 
// return YES and no error. It will return NO and the error info if failed.
// Because parsing is processed in background thread, client can do run loop
// and waiting for parsing finish. You can set a flag in parserDidEndVCard: 
// callback to end the run loop.
// =============================================================================
// Example:
// YOVcardParser *parser = [[YOVcardParse alloc] init];
// [parser setVCardFilePath:@"..."];
// NSError *error = nil;
// if ([parser start:&error] == YES)
// {
//     ...
// }
// do
// {
//     [[NSRunLoop currentRunloop] runMode:NSDefaultRunloopMode untilDate:[NSDate distentFuture]];
// } while(parsingFinished == NO);
// [parser release];
@interface YOVcardParser : NSObject
{
@private
    id<YOVcardParserDelegate> delegate_;
    id<YOVcardParserProtocol> parser_;
    NSString *vcardStringRepresentation_;
    
    BOOL isSyncronize_;
}

@property (nonatomic, assign) id<YOVcardParserDelegate> delegate;

- (void) setVCardRepresentation:(NSString *) vcardRepresentation;
- (void) setVCardFilePath:(NSString *) vcardFilePath;

- (BOOL) isVcardValid:(NSError **) error;

- (id) valueForName:(NSString *) vcardKeyName error:(NSError **) error;
- (NSRange) valueRangeForName:(NSString *) vcardKeyName error:(NSError **) error;
// default Asynchronously
- (BOOL) start:(NSError **) error;
- (BOOL) startSynchronously:(BOOL) synchronize error:(NSError **) error; 

@end
