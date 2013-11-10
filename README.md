VcardCocoa
==========

A vcard parse &amp; generate library for Mac &amp; iOS.


To compile this project, you need to install [iOS-Universal-Framework](https://github.com/kstenerud/iOS-Universal-Framework) first. (Real Framework Type)

### Usage of Parser

    YOVcardParser *parser = [[YOVcardParser alloc] init];
    [parser setVCardRepresentation:@"BEGIN:VCARD\nN:Edward;Chen;;;\nEND:VCARD"];
    parser.delegate = (id<YOVcardParserDelegate) self;
    [parser startSynchronously:YES error:NULL];
    [parser release];

    // or
    NSString *name = [parser valueForName:@"N"];

    // or get range and replace
    NSString *vcardString = [xxx xxx];
    [parser setVCardRepresentation:vcardString];
    NSRange range = [parser valueRangeForName:@"N"];
    vcardString = [vcardString stringByReplacingStringAtRange:range withString:@"BlaBlaBla"];
    [parser setVCardRepresentation:vcardString];
    NSString *name = [parser valueForName:@"N"];


### Usage of Generator

    id<YOVcardGeneratorProtocol> generator = [YOVcardGenerator vcardGeneratorForVersion:YOVcardVersion2_1];
    [generator beginVcard];
    // following code generated a line:
    // TEL;PREF;CELL;X-ID=007;CHARSET=UTF-8:0123456789
    [generator addLineWithBlock:^{
        [generator addType:@"TEL"];
        [generator addType:@"PREF"]
        [generator addType:@"CELL"];
        [generator addAttributes:@{@"X-ID":@"007"}];
        [generator setStringValue:@"0123456789"];
    }];
    [generator endVcard];

    NSString *vcardString = [generator vcardRepresentation];
