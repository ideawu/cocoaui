/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "IStyleSheet.h"

@interface IStyleSheet(){
	NSMutableDictionary *_idStyle;
	NSMutableDictionary *_tagStyle;
	NSMutableDictionary *_classStyle;
}

@end

@implementation IStyleSheet

- (id)init{
	self = [super init];
	_idStyle = [[NSMutableDictionary alloc] init];
	_tagStyle = [[NSMutableDictionary alloc] init];
	_classStyle = [[NSMutableDictionary alloc] init];
	return self;
}

- (void)parseCssFile:(NSString *)filename{
	NSError *err;
	NSString *str = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:&err];
	if(!err){
		[self parseCss:str];
	}
}

- (NSString *)getStyleById:(NSString *)_id{
	return [_idStyle objectForKey:_id];
}

- (NSString *)getStyleByTagName:(NSString *)tag{
	return [_tagStyle objectForKey:tag];
}

- (NSString *)getStyleByClass:(NSString *)_class{
	return [_classStyle objectForKey:_class];
}

- (NSString *)stripComment:(NSString *)css{
	NSRange searchRange = NSMakeRange(0, css.length);
	NSRange srange = [css rangeOfString:@"/*" options:NSLiteralSearch range:searchRange];
	if(srange.location == NSNotFound){
		return css;
	}
	
	NSMutableString *ret = [[NSMutableString alloc] initWithString:css];
	while (1){
		NSRange srange = [ret rangeOfString:@"/*" options:NSLiteralSearch range:searchRange];
		if(srange.location == NSNotFound){
			break;
		}
		NSRange erange = [ret rangeOfString:@"*/" options:NSLiteralSearch range:searchRange];
		if(erange.location == NSNotFound){
			break;
		}
		
		NSRange stripRange = NSMakeRange(srange.location, erange.location + erange.length - srange.location);
		[ret replaceCharactersInRange:stripRange withString:@""];
		
		searchRange.location = srange.location;
		searchRange.length = ret.length - searchRange.location;
	}
	return ret;
}

- (void)parseCss:(NSString *)css{
	css = [self stripComment:css];
	
	NSRange searchRange = NSMakeRange(0, css.length);
	while (searchRange.length > 0) {
		NSRange srange = [css rangeOfString:@"{" options:NSLiteralSearch range:searchRange];
		if(srange.location == NSNotFound){
			break;
		}
		NSString *selector = [css substringWithRange:NSMakeRange(searchRange.location, srange.location - searchRange.location)];
		selector = [selector stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

		searchRange.location = srange.location + srange.length;
		searchRange.length = css.length - searchRange.location;
		
		NSRange erange = [css rangeOfString:@"}" options:NSLiteralSearch range:searchRange];
		if(erange.location == NSNotFound){
			break;
		}
		NSString *val = [css substringWithRange:NSMakeRange(searchRange.location, erange.location - searchRange.location)];

		searchRange.location = erange.location + erange.length;
		searchRange.length = css.length - searchRange.location;

		//NSLog(@"%@ = %@", key,val);
		[self setValue:val forSelector:selector];
	}
}

- (void)setValue:(id)val forSelector:(NSString *)selector{
	NSArray *ps = [selector componentsSeparatedByString:@","];
	for(NSString *p in ps){
		NSString *key = [p stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if(key.length == 0){
			continue;
		}
		if([key characterAtIndex:0] == '.'){
			key = [key substringFromIndex:1];
			[_classStyle setObject:val forKey:key];
		}else if([key characterAtIndex:0] == '#'){
			key = [key substringFromIndex:1];
			[_idStyle setObject:val forKey:key];
		}else{
			[_tagStyle setObject:val forKey:key.lowercaseString];
		}
	}
}

@end
