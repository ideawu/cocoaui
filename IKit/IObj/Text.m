/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import <CommonCrypto/CommonDigest.h>
#import "Text.h"

NSString *json_encode(id obj){
	if([obj isKindOfClass:[NSString class]]){
		NSString *s = obj;
		s = [s stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
		s = [s stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
		s = [s stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
		s = [s stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
		s = [s stringByReplacingOccurrencesOfString:@"\t" withString:@"\\t"];
		s = [s stringByReplacingOccurrencesOfString:@"\b" withString:@"\\b"];
		return [NSString stringWithFormat:@"\"%@\"", s];
	}
	BOOL is_primative = false;
	if(![obj isKindOfClass:[NSArray class]] && ![obj isKindOfClass:[NSDictionary class]]){
		is_primative = true;
		obj = [NSArray arrayWithObject: obj];
	}
	id data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:nil];
	NSError *err = nil;
	NSString *str = [[NSString alloc] initWithData:data encoding:[NSString defaultCStringEncoding]];
	if(err){
		NSLog(@"error for: %@", obj);
		return nil;
	}
	if(is_primative){
		str = [str substringWithRange:NSMakeRange(1, [str length]-2)];
	}
	return str;
}

id json_decode(NSString *str){
	str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
	if(!data){
		return nil;
	}
	NSError *err = nil;
	id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
	if(err){
		return nil;
	}
	return obj;
}


NSString *urlencode(NSString *str){
	CFStringEncoding cfEncoding = kCFStringEncodingUTF8;
	str = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
																	   NULL,
																	   (CFStringRef)str,
																	   NULL,
																	   CFSTR("!*'();:@&=+$,/?%#[]"),
																	   cfEncoding
																	   );
	return str;
}

NSString *urldecode(NSString *str){
	CFStringEncoding cfEncoding = kCFStringEncodingUTF8;
	str = (__bridge NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding (
																						NULL,
																						(CFStringRef)str,
																						CFSTR(""),
																						cfEncoding
																						);
	return str;
}


NSString *base64_encode(NSString *str){
	NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
	if(!data){
		return nil;
	}
	return base64_encode_data(data);
}

NSString *base64_encode_data(NSData *data){
	data = [data base64EncodedDataWithOptions:0];
	NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	return ret;
}

NSData *base64_decode(NSString *str){
	NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
	return data;
}


NSString *number_format(double number, int decimals, NSString *decimalpoint, NSString *separator){
	if(decimalpoint == nil || decimalpoint.length == 0){
		decimalpoint = @".";
	}
	NSString *str;
	if(decimals > 0){
		str = [NSString stringWithFormat:@"%.*f", decimals, number];
	}else{
		str = [NSString stringWithFormat:@"%f.", number];
	}
	NSArray *ps = [str componentsSeparatedByString:@"."];
	NSString *ival = ps[0];
	NSString *fval = ps[1];
	if(separator != nil && separator.length > 0){
		int offset = number > 0? 0 : 1;
		for(int i = (int)ival.length - 3; i>offset; i-=3){
			NSRange range = NSMakeRange(i, 0);
			ival = [ival stringByReplacingCharactersInRange:range withString:separator];
		}
	}
	if(decimals > 0){
		ival = [ival stringByAppendingFormat:@"%@%@", decimalpoint, fval];
	}
	return ival;
}

NSString* md5(NSString *input){
	const char *cStr = [input UTF8String];
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5(cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
	
	NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
	
	for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++){
		[output appendFormat:@"%02x", digest[i]];
	}
	
	return  output;
}

@implementation Text

+ (NSString *)trim:(NSString *)s{
	return [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
