/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import <Foundation/Foundation.h>
#import "IObj.h"
#import "Text.h"

int main(int argc, const char * argv[]) {
	@autoreleasepool {
	    // insert code here...
	    NSLog(@"Hello, World!");
	}
	
	//NSLog(@"%@", [[IObj alloc] initWithJSONString:@"null"]);
	//NSLog(@"%@", [[IObj alloc] initWithJSONString:@"1"]);
	//NSLog(@"%@", [[IObj alloc] initWithJSONString:@"1.01"]);
	
	NSString *str = @"{\"s\": {}, \"t\":10.1,\"code\":1,\"message\":\"你好 error\",\"data\":{\"total\":251,\"items\":[{\"id\":\"281\",\"title\":\"hello\",\"status\":\"2\",\"days\":\"62\"},{\"id\":\"281\",\"title\":\"nihao\",\"status\":\"2\",\"days\":\"62\"}]}}";
	
	IObj *obj = [[IObj alloc] initWithJSONString:str];
	obj.set(@"num", [IObj strObj:@"\\"]);
	NSLog(@"%@", obj);
	NSLog(@"%lld", [obj.get(@"code") intval]);
	
	for(id k in obj){
		NSLog(@"%@: %@", k, obj.get(k));
	}
	
	IObj *arr = [IObj arrayObj];
	arr.push(@"test1");
	arr.push(@"test2");

	NSLog(@"-------");
	for(id k in arr){
		NSLog(@"%@: %@", k, arr.get(k));
	}
	NSLog(@"%@", arr);
	
	double num = 0.05;
	NSLog(@"%@", number_format(num, 8, @".", @","));
	NSLog(@"%@", number_format(1.0, 2, @".", @","));
	NSLog(@"%@", number_format(12.0, 2, @".", @","));
	NSLog(@"%@", number_format(121.0, 2, @".", @","));
	NSLog(@"%@", number_format(1211.0, 2, @".", @","));
	NSLog(@"%@", number_format(12111.0, 2, @".", @","));
	NSLog(@"%@", md5(@"wwwwwa"));
	
    return 0;
}
