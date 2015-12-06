//
//  IKitResourceMananger.m
//  IKit
//
//  Created by ideawu on 12/6/15.
//  Copyright © 2015 ideawu. All rights reserved.
//

#import "IResourceMananger.h"
#import "IKitUtil.h"
#import <CommonCrypto/CommonDigest.h>

@interface IResourceMananger (){
}
@property NSCache *cache;
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
	_cache = [[NSCache alloc] init];
	_cacheTime = 86400 * 30;
	return self;
}

- (NSString *)cacheFilePrefix{
	static NSString *ret = nil;
	if(!ret){
		ret = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/cocoaui."];
	}
	return ret;
}

+ (NSString *)md5:(NSString*)input{
	const char* str = [input UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(str, (CC_LONG)strlen(str), result);
	NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
	for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
		[ret appendFormat:@"%02x",result[i]];
	}
	return ret;
}

// TODO: 定期清理缓存
- (id)cache_get:(NSString *)key{
	id ret;
	NSArray *arr = [_cache objectForKey:key];
	if(arr){
		NSDate *expired_date = arr[0];
		if(expired_date.timeIntervalSince1970 < [NSDate date].timeIntervalSince1970){
			[_cache removeObjectForKey:key];
			return nil;
		}
		ret = arr[1];
		return ret;
	}

	NSString *md5 = [IResourceMananger md5:key];
	NSString *data_file = [self.cacheFilePrefix stringByAppendingFormat:@"%@.data", md5];
	NSString *meta_file = [self.cacheFilePrefix stringByAppendingFormat:@"%@.meta", md5];

	NSString *meta = [NSString stringWithContentsOfFile:meta_file encoding:NSUTF8StringEncoding error:nil];
	if(!meta){
		return nil;
	}
	NSArray *ps = [meta componentsSeparatedByString:@"\n"];
	if(ps.count < 3){
		return nil;
	}
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
	NSDate *expired = [dateFormatter dateFromString:ps[2]];
	if(!expired || expired.timeIntervalSince1970 < [NSDate date].timeIntervalSince1970){
		return nil;
	}

	NSData *data = [NSData dataWithContentsOfFile:data_file];
	if(!data){
		return nil;
	}
	if([ps[0] isEqualToString:@"image"]){
		ret = [UIImage imageWithData:data];
	}

	if(ret){
		[_cache setObject:@[expired, ret] forKey:key];
	}
	return ret;
}

- (void)cache_set:(NSString *)key val:(id)obj{
	NSDate *expired_date = [NSDate dateWithTimeIntervalSinceNow:_cacheTime];

	[_cache setObject:@[expired_date, obj] forKey:key];

	// persistent
	NSMutableString *meta = [[NSMutableString alloc] init];
	NSData *data;
	if([obj isKindOfClass:[UIImage class]]){
		[meta appendString:@"image\n"];
		data = UIImagePNGRepresentation((UIImage *)obj);
	}else{
		return;
	}

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
	NSString *created = [dateFormatter stringFromDate:[NSDate date]];
	NSString *expired = [dateFormatter stringFromDate:expired_date];
	[meta appendFormat:@"%@\n%@\n", created, expired];

	NSString *md5 = [IResourceMananger md5:key];
	NSString *data_file = [self.cacheFilePrefix stringByAppendingFormat:@"%@.data", md5];
	NSString *meta_file = [self.cacheFilePrefix stringByAppendingFormat:@"%@.meta", md5];
	[meta writeToFile:meta_file atomically:YES encoding:NSUTF8StringEncoding error:nil];
	[data writeToFile:data_file atomically:YES];
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
