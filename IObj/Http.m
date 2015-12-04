/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#include "TargetConditionals.h"
#ifndef TARGET_OS_MAC
#import <UIKit/UIKit.h>
#endif
#import "Http.h"
#import "Text.h"

#define HTTP_GET  0
#define HTTP_POST 1

// TODO:
static NSArray *cookies = nil;
static NSArray *resp_cookies = nil;


@implementation Http

+ (void (^)(NSString *, id, void (^)(IObj *)))get{
	return ^(NSString * url, id params, void (^callback)(IObj *)){
		http_request(url, params, HTTP_GET, callback);
	};
}

+ (void (^)(NSString *, id, void (^)(IObj *)))post{
	return ^(NSString * url, id params, void (^callback)(IObj *)){
		http_request(url, params, HTTP_POST, callback);
	};
}

+ (void (^)(NSString *, id, void (^)(NSData *)))raw_get{
	return ^(NSString * url, id params, void (^callback)(NSData *)){
		http_request_raw(url, params, HTTP_GET, callback);
	};
}

+ (void (^)(NSString *, id, void (^)(NSData *)))raw_post{
	return ^(NSString * url, id params, void (^callback)(NSData *)){
		http_request_raw(url, params, HTTP_GET, callback);
	};
}

void http_request_raw(NSString *urlStr, id params, int method, void (^callback)(NSData *)){
	NSMutableString *query = [[NSMutableString alloc] init];
	if([params isKindOfClass: [NSString class]]){
		query = params;
	}else if([params isKindOfClass: [NSDictionary class]]){
		NSUInteger n = [(NSDictionary *)params count];
		for (NSString *key in params) {
			NSString *val = [NSString stringWithFormat:@"%@", [params objectForKey:key]];
			[query appendString:urlencode(key)];
			[query appendString:@"="];
			[query appendString:urlencode(val)];
			if(--n > 0){
				[query appendString:@"&"];
			}
		}
	}
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
	[request setTimeoutInterval:10];
	
	//[request addValue:@"https://www.cocoaui.com/?ios" forHTTPHeaderField:@"Referer"];
	
	NSString *ua = @"IObj-iphone";
#ifndef TARGET_OS_MAC
	UIDevice *_dev = [UIDevice currentDevice];
	ua = [ua stringByAppendingString:@"_"];
	ua = [ua stringByAppendingString:_dev.systemName];
	ua = [ua stringByAppendingString:@"_"];
	ua = [ua stringByAppendingString:_dev.systemVersion];
	ua = [ua stringByAppendingString:@"_"];
	ua = [ua stringByAppendingString:_dev.model];
#endif
	[request addValue:ua forHTTPHeaderField:@"User-Agent"];

	if(method == HTTP_POST){
		NSData *req_data = [query dataUsingEncoding:NSUTF8StringEncoding];
		[request setHTTPBody:req_data];
		[request setHTTPMethod:@"POST"];
	}else{
		[request setHTTPMethod:@"GET"];
		if(query.length > 0){
			if([urlStr rangeOfString:@"?"].location != NSNotFound){
				urlStr = [NSString stringWithFormat:@"%@&%@", urlStr, query];
			}else{
				urlStr = [NSString stringWithFormat:@"%@?%@", urlStr, query];
			}
		}
	}
	
	NSURL *url = [NSURL URLWithString:urlStr];
	[request setURL:url];
	
	resp_cookies = nil;
	
#ifndef TARGET_OS_MAC
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
#endif
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *urlresp, NSData *data, NSError *error){
#ifndef TARGET_OS_MAC
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
#endif
		NSHTTPURLResponse *response = (NSHTTPURLResponse *)urlresp;
		resp_cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields]
															  forURL:[NSURL URLWithString:@""]];
		if(callback){
			dispatch_async(dispatch_get_main_queue(), ^{
				callback(data);
			});
		}
	}];
}

void http_request(NSString *urlStr, id params, int method, void (^callback)(IObj *)){
	http_request_raw(urlStr, params, method, ^(NSData *data) {
		if(callback){
			NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			//NSLog(@"resp body: %@", str);
			IObj *obj = [[IObj alloc] initWithJSONString:str];
			//NSLog(@"%@", obj);
			dispatch_async(dispatch_get_main_queue(), ^{
				callback(obj);
			});
		}
	});
}

void http_get(NSString *urlStr, id params, void (^callback)(IObj *resp)){
	http_request(urlStr, params, HTTP_GET, callback);
}

void http_post(NSString *urlStr, id params, void (^callback)(IObj *resp)){
	http_request(urlStr, params, HTTP_POST, callback);
}

void http_get_raw(NSString *urlStr, id params, void (^callback)(NSData *data)){
	http_request_raw(urlStr, params, HTTP_GET, callback);
}

void http_post_raw(NSString *urlStr, id params, void (^callback)(NSData *data)){
	http_request_raw(urlStr, params, HTTP_POST, callback);
}

@end
