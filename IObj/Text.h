/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#ifndef Text_h
#define Text_h

#import <Foundation/Foundation.h>

id json_decode(NSString *str);
NSString *json_encode(id obj);

NSString *urlencode(NSString *str);
NSString *urldecode(NSString *str);

NSString *base64_encode(NSString *str);
NSString *base64_encode_data(NSData *data);

NSData *base64_decode(NSString *str);

/**
 * 将数字格式化为 xx,xxx.xx 的格式.
 * @param decimals 小数位数
 * @param dec_point 小数和整数的分隔符, 如果传 nil, 将默认是点号"."
 * @param thousands_sep 千分位分隔符, 一般是逗号",", 如果传 nil, 将没有分隔符
 */
NSString *number_format(double number, int decimals, NSString *dec_point, NSString *thousands_sep);
NSString* md5(NSString *input);

@interface Text : NSObject

+ (NSString *)trim:(NSString *)s;

@end

#endif
