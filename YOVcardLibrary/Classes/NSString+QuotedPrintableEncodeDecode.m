//
//  NSString+QuotedPrintableEncodeDecode.m
//  YOVcardLibrary
///
//  Created by Edward Chen on 11/10/13.
//  Copyright (c) 2013 Edward Chen. All rights reserved.
//

#import "NSString+QuotedPrintableEncodeDecode.h"

int EncodeQuoted(const unsigned char* pSrc, char* pDst, int nSrcLen, int nMaxLineLen);
int DecodeQuoted(const char* pSrc, unsigned char* pDst, int nSrcLen);

@implementation NSString (NSString_QuotedPrintableEncodeDecode)

- (NSString *) quotedPrintableEncoded
{
    const char *pSrc = [self UTF8String];
    int sourceLength = (int)strlen(pSrc);
    int targetLength = sourceLength * 3;
    int maxLength = 78;
    char *pDst = (char *)malloc(targetLength * sizeof(char *));
    EncodeQuoted((const unsigned char *)pSrc, pDst, sourceLength, maxLength);
    NSString *encodeString = [NSString stringWithUTF8String:pDst];
    free(pDst);
    return encodeString;
}

- (NSString *) quotedPrintableDecoded
{
    const char *pSrc = [self UTF8String];
    int sourceLength = (int)strlen(pSrc);
    int targetLength = sourceLength;
    unsigned char *pDst = (unsigned char *)malloc(targetLength*sizeof(unsigned char *));
    DecodeQuoted(pSrc, pDst, sourceLength);
    NSString *decodedString = [NSString stringWithUTF8String:(const char *)pDst];
    free(pDst);
    return decodedString;
}

@end

int EncodeQuoted(const unsigned char* pSrc, char* pDst, int nSrcLen, int nMaxLineLen)
{
    int nDstLen;        // 输出的字符计数
    int nLineLen;       // 输出的行长度计数

    nDstLen = 0;
    nLineLen = 0;

    for (int i = 0; i < nSrcLen; i++, pSrc++)
    {
        // ASCII 33-60, 62-126原样输出，其余的需编码
        if ((*pSrc >= '!') && (*pSrc <= '~') && (*pSrc != '='))
        {
            *pDst++ = (char)*pSrc;
            nDstLen++;
            nLineLen++;
        }
        else
        {
            sprintf(pDst, "=%02X", *pSrc);
            pDst += 3;
            nDstLen += 3;
            nLineLen += 3;
        }

        // 输出换行？
        if (nLineLen >= nMaxLineLen - 3)
        {
            sprintf(pDst, "=\r\n");
            pDst += 3;
            nDstLen += 3;
            nLineLen = 0;
        }
    }

    // 输出加个结束符
    *pDst = '\0';

    return nDstLen;
}

int DecodeQuoted(const char* pSrc, unsigned char* pDst, int nSrcLen)
{
    int nDstLen;        // 输出的字符计数
    int i;

    i = 0;
    nDstLen = 0;

    while (i < nSrcLen)
    {
        if (strncmp(pSrc, "=\r\n", 3) == 0)        // 软回车，跳过
        {
            pSrc += 3;
            i += 3;
        }
        else
        {
            if (*pSrc == '=')        // 是编码字节
            {
                sscanf(pSrc, "=%02X", (unsigned int *)pDst);
                pDst++;
                pSrc += 3;
                i += 3;
            }
            else        // 非编码字节
            {
                *pDst++ = (unsigned char)*pSrc++;
                i++;
            }

            nDstLen++;
        }
    }

    // 输出加个结束符
    *pDst = '\0';

    return nDstLen;
}
