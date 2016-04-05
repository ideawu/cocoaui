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
	    log_debug(@"Hello, World!");
	}
	
	//log_debug(@"%@", [[IObj alloc] initWithJSONString:@"null"]);
	//log_debug(@"%@", [[IObj alloc] initWithJSONString:@"1"]);
	//log_debug(@"%@", [[IObj alloc] initWithJSONString:@"1.01"]);
	
	NSString *str = @"{\"s\": {}, \"t\":10.1,\"code\":1,\"message\":\"你好 error\",\"data\":{\"total\":251,\"items\":[{\"id\":\"281\",\"title\":\"hello\",\"status\":\"2\",\"days\":\"62\"},{\"id\":\"281\",\"title\":\"nihao\",\"status\":\"2\",\"days\":\"62\"}]}}";
	
	IObj *obj = [[IObj alloc] initWithJSONString:str];
	obj.set(@"num", [IObj strObj:@"\\"]);
	log_debug(@"%@", obj);
	log_debug(@"%lld", [obj.get(@"code") intval]);
	
	for(id k in obj){
		log_debug(@"%@: %@", k, obj.get(k));
	}
	
	IObj *arr = [IObj arrayObj];
	arr.push(@"test1");
	arr.push(@"test2");

	log_debug(@"-------");
	for(id k in arr){
		log_debug(@"%@: %@", k, arr.get(k));
	}
	log_debug(@"%@", arr);
	
	double num = 0.05;
	log_debug(@"%@", number_format(num, 8, @".", @","));
	log_debug(@"%@", number_format(1.0, 2, @".", @","));
	log_debug(@"%@", number_format(12.0, 2, @".", @","));
	log_debug(@"%@", number_format(121.0, 2, @".", @","));
	log_debug(@"%@", number_format(1211.0, 2, @".", @","));
	log_debug(@"%@", number_format(12111.0, 2, @".", @","));
	log_debug(@"%@", md5(@"wwwwwa"));
	
    return 0;
}
