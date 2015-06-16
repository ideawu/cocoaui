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

NSString *number_format(double number, int decimals, NSString *decimalpoint, NSString *separator);
NSString* md5(NSString *input);

@interface Text : NSObject

+ (NSString *)trim:(NSString *)s;

@end

#endif
