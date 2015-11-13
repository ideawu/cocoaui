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

@interface IStyleSheet()
@end

@implementation IStyleSheet

- (id)init{
	self = [super init];
	_rules = [[NSMutableArray alloc] init];
	return self;
}

- (void)parseCssFile:(NSString *)src{
	if(!src){
		return;
	}
	NSArray *arr = [IStyleUtil parsePath:src];
	_baseUrl = [arr objectAtIndex:1];
	
	if([IStyleUtil isHttpUrl:src]){
		NSString *text = nil;
		NSError *err;
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
		[request setHTTPMethod:@"GET"];
		[request setURL:[NSURL URLWithString:src]];
		NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&err];
		if(data){
			text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			[self parseCss:text];
		}
	}else{
		static NSMutableDictionary *cache = nil;
		if(cache == nil){
			cache = [[NSMutableDictionary alloc] init];
		}
		
		IStyleSheet *sheet = [cache objectForKey:src];
		if(sheet){
			log_debug(@"load css file from cache: %@", src);
		}else{
			//log_debug(@"load css file: %@", src);
			sheet = [[IStyleSheet alloc] init];
			NSString *text = nil;
			NSError *err;
			text = [NSString stringWithContentsOfFile:src encoding:NSUTF8StringEncoding error:&err];
			if(!err){
				[sheet parseCss:text];
				[cache setObject:sheet forKey:src];
			}
		}
		for(IStyleRule *rule in sheet.rules){
			[_rules addObject:rule];
		}
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
	if(css.length == 0){
		return;
	}
	
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
		[self setCssValue:val forSelector:selector];
	}
	
	// 按优先级排序样式规则列表
	[_rules sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		IStyleRule *a = (IStyleRule *)obj1;
		IStyleRule *b = (IStyleRule *)obj2;
		if(a.weight > b.weight){
			return 1;
		}else if(a.weight < b.weight){
			return -1;
		}else{
			return 0;
		}
	}];
	//[self debugRules];
}

- (void)debugRules{
	for(IStyleRule *rule in _rules){
		NSLog(@"%10d: %@", rule.weight, rule);
	}
}

- (void)setCssValue:(id)val forSelector:(NSString *)selector{
	// grouped rule
	NSArray *ps = [selector componentsSeparatedByString:@","];
	for(NSString *p in ps){
		NSString *key = [p stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if(key.length == 0){
			continue;
		}
		
		IStyleRule *rule = [[IStyleRule alloc] init];
		[rule parseRule:key css:val baseUrl:_baseUrl];
		[_rules addObject:rule];
	}
}

@end
