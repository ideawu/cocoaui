/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "IStyleSheet.h"
#import "IStyleUtil.h"
#import "IViewInternal.h"
#import "IStyleInternal.h"
#import "IStyleRule.h"

@interface IStyleSheet(){
	NSString *_baseUrl;
}

@end

@implementation IStyleSheet

- (id)init{
	self = [super init];
	_rules = [[NSMutableArray alloc] init];
	return self;
}

- (void)parseCssFile:(NSString *)src baseUrl:(NSString *)baseUrl{
	if(!src){
		return;
	}
	_baseUrl = baseUrl;
	if(![IStyleUtil isHttpUrl:src]){
		if(baseUrl){
			src = [baseUrl stringByAppendingString:src];
		}else{
			src = [[NSBundle mainBundle] pathForResource:src ofType:@""];
		}
	}
	
	static NSMutableDictionary *cache = nil;
	if(cache == nil){
		cache = [[NSMutableDictionary alloc] init];
	}
	IStyleSheet *sheet;
	
	if([IStyleUtil isHttpUrl:src]){
		sheet = [[IStyleSheet alloc] init];
		NSString *text = nil;
		NSError *err;
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
		[request setHTTPMethod:@"GET"];
		[request setURL:[NSURL URLWithString:src]];
		NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&err];
		if(data){
			text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			[sheet parseCss:text];
		}
	}else{
		sheet = [cache objectForKey:src];
		if(sheet){
			log_debug(@"load css resource from cache: %@", src);
		}else{
			log_debug(@"load css resource: %@", src);
			sheet = [[IStyleSheet alloc] init];
			NSString *text = nil;
			NSError *err;
			text = [NSString stringWithContentsOfFile:src encoding:NSUTF8StringEncoding error:&err];
			if(!err){
				[sheet parseCss:text];
				[cache setObject:sheet forKey:src];
			}
		}
	}

	for(IStyleRule *rule in sheet.rules){
		[_rules addObject:rule];
	}
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
	// grouped rule
	NSArray *ps = [selector componentsSeparatedByString:@","];
	for(NSString *p in ps){
		NSString *key = [p stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if(key.length == 0){
			continue;
		}
		
		IStyleRule *rule = [[IStyleRule alloc] init];
		[rule parseRule:key];
		rule.css = val;
		[_rules addObject:rule];
	}
}

@end
