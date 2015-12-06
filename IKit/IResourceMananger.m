//
//  IKitResourceMananger.m
//  IKit
//
//  Created by ideawu on 12/6/15.
//  Copyright © 2015 ideawu. All rights reserved.
//

#import "IResourceMananger.h"
#import "IKitUtil.h"

@interface IResourceMananger (){
}
//@property NSMutableDictionary *cache;
@end

static IResourceMananger *_sharedMananger;

@implementation IResourceMananger

+ (IResourceMananger *)sharedMananger{
	if(!_sharedMananger){
		_sharedMananger = [[IResourceMananger alloc] init];
	}
	return _sharedMananger;
}

+ (void)setSharedManager:(IResourceMananger *)mananger{
	_sharedMananger = mananger;
}

- (id)init{
	self = [super init];
	//_cache = [[NSMutableDictionary alloc] init];
	return self;
}

- (id)cache_get:(NSString *)key{
	// TODO:
	//return [_cache objectForKey:key];
	return nil;
}

- (void)cache_set:(NSString *)key val:(id)obj{
	// TODO:
	//[_cache setObject:obj forKey:key];
}

- (UIImage *)getImage:(NSString *)path callback:(void (^)(UIImage *))callback{
	UIImage *img = nil;

	if([IKitUtil isHttpUrl:path]){
		img = [self cache_get:path];
		if(img){
			log_debug(@"load image from cache: %@", path);
			if(callback){
				callback(img);
			}
			return img;
		}

		// TODO: 并发控制, 去重
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
		[request setHTTPMethod:@"GET"];
		[request setURL:[NSURL URLWithString:path]];
		[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
		[NSURLConnection sendAsynchronousRequest:request
										   queue:[NSOperationQueue currentQueue]
							   completionHandler:^(NSURLResponse *urlresp, NSData *data, NSError *error)
		{
			log_debug(@"load image from remote: %@", path);
			UIImage *img = [UIImage imageWithData:data];
			if(img){
				[self cache_set:path val:img];
				if(callback){
					dispatch_async(dispatch_get_main_queue(), ^{
						callback(img);
					});
				}
			}
		}];
	}else{
		if([path characterAtIndex:0] == '/'){
			NSData *data = [NSData dataWithContentsOfFile:path];
			if(data){
				img = [UIImage imageWithData:data];
			}
		}else{
			img = [UIImage imageNamed:path];
		}
		if(img){
			log_debug(@"load image from local: %@", path);
			if(callback){
				callback(img);
			}
		}
	}
	return img;
}

@end
