//
//  Config.m
//  CocoaUIViewer
//
//  Created by ideawu on 4/12/15.
//  Copyright (c) 2015 ideawu. All rights reserved.
//

#import "Config.h"
#import "IObj/IObj.h"

static NSString *CONF_KEY = @"config";

@interface Config(){
	IObj *obj;
}

@end

@implementation Config

- (id)init{
	self = [super init];
	[self load];
	return self;
}

- (void)load{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *str = [userDefaults objectForKey:CONF_KEY];
	str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	obj = [[IObj alloc] initWithJSONString:str];
}

- (void)save{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:[obj description] forKey:CONF_KEY];
}

- (NSString *)url{
	static NSString *URL = @"http://192.168.0.1:8080/cocoaui.xml";
	
	NSString *s = obj.get(@"url").strval;
	if(s == nil || s.length == 0){
		s = URL;
	}
	return s;
}

- (void)setUrl:(NSString *)url{
	obj.set(@"url", url);
}

- (int64_t)interval{
	return obj.get(@"interval").intval;
}

- (void)setInterval:(int64_t)intval{
	obj.set(@"interval", [NSNumber numberWithInt:(int)intval]);
}

@end
