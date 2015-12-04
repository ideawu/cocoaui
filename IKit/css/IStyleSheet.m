/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "IStyleSheet.h"
#import "IKitUtil.h"
#import "IViewInternal.h"
#import "IStyleInternal.h"
#import "ICssRule.h"

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
	NSArray *arr = [IKitUtil parsePath:src];
	NSString *baseUrl = [arr objectAtIndex:1];
	
	if([IKitUtil isHttpUrl:src]){
		NSString *text = nil;
		NSError *err;
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
		[request setHTTPMethod:@"GET"];
		[request setURL:[NSURL URLWithString:src]];
		NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&err];
		if(data){
			text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			[self parseCss:text baseUrl:baseUrl];
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
				[sheet parseCss:text baseUrl:baseUrl];
				[cache setObject:sheet forKey:src];
			}
		}
		for(ICssRule *rule in sheet.rules){
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

- (void)parseCss:(NSString *)css baseUrl:(NSString *)baseUrl{
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
		[self setCss:val forSelector:selector baseUrl:baseUrl];
	}
	
	// 按优先级排序样式规则列表
	[_rules sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		ICssRule *a = (ICssRule *)obj1;
		ICssRule *b = (ICssRule *)obj2;
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
	NSLog(@"<<<<<<<<<<");
	for(ICssRule *rule in _rules){
		NSLog(@"%10d: %@", rule.weight, rule);
	}
	NSLog(@">>>>>>>>>>");
}

- (void)setCss:(NSString *)css forSelector:(NSString *)selector baseUrl:(NSString *)baseUrl{
	// grouping rule
	NSArray *ps = [selector componentsSeparatedByString:@","];
	for(NSString *sel in ps){
		ICssRule *rule = [ICssRule fromSelector:sel css:css baseUrl:baseUrl];
		if(rule){
			[_rules addObject:rule];
		}
	}
}

@end
