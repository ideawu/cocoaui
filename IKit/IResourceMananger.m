/*
 Copyright (c) 2014-2015 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.

 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import <CommonCrypto/CommonDigest.h>
#import "IResourceMananger.h"
#import "IKitUtil.h"
#import "IStyleSheet.h"

@interface IResourceMananger (){
}
@property NSCache *cache;
@property (nonatomic) NSTimeInterval cacheTime;
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
	_enableCssCache = YES;
	_enableImageCache = YES;
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

- (UIImage *)loadImageSrc:(NSString *)src callback:(void (^)(UIImage *))callback{
	UIImage *img = nil;

	if([IKitUtil isHttpUrl:src]){
		if(_enableImageCache){
			img = [self cache_get:src];
		}
		if(img){
			log_debug(@"load img from cache: %@", src);
			if(callback){
				callback(img);
			}
			return img;
		}

		// TODO: 并发控制, 去重
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
		[request setHTTPMethod:@"GET"];
		[request setURL:[NSURL URLWithString:src]];
		[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
		[NSURLConnection sendAsynchronousRequest:request
										   queue:[NSOperationQueue currentQueue]
							   completionHandler:^(NSURLResponse *urlresp, NSData *data, NSError *error)
		{
			log_debug(@"load img from remote: %@", src);
			UIImage *img = [UIImage imageWithData:data];
			if(img){
				if(_enableImageCache){
					[self cache_set:src val:img];
				}
				if(callback){
					dispatch_async(dispatch_get_main_queue(), ^{
						callback(img);
					});
				}
			}
		}];
	}else if([IKitUtil isDataURI:src]){
		log_debug(@"load image element from data URI");
		img = [IKitUtil loadImageFromDataURI:src];
		if(callback){
			callback(img);
		}
	}else if(![src isEqual:@""]){
		if([src characterAtIndex:0] != '/'){
			img = [UIImage imageNamed:src]; // imageNamed 内部有 cache
		}else if([src rangeOfString:[NSBundle mainBundle].resourcePath].length > 0){
			src = [src substringFromIndex:[NSBundle mainBundle].resourcePath.length + 1];
			img = [UIImage imageNamed:src]; // imageNamed 内部有 cache
		}else{
			NSData *data = [NSData dataWithContentsOfFile:src];
			img = [UIImage imageWithData:data];
		}
		log_debug(@"load img from local: %@", src);
		if(img){
			if(callback){
				callback(img);
			}
		}
	}
	return img;
}

- (IStyleSheet *)loadCss:(NSString *)path{
	IStyleSheet *sheet = nil;
	NSString *baseUrl = [IKitUtil getBasePath:path];

	if(_enableCssCache){
		sheet = [_cache objectForKey:path];
		if(sheet){
			if([IKitUtil isHttpUrl:path]){
				log_debug(@"load css from cache: %@", path);
			}else{
				log_debug(@"load css from cache: %@", [path lastPathComponent]);
			}
			return sheet;
		}
	}

	NSString *text = nil;
	NSError *err;
	if([IKitUtil isHttpUrl:path]){
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
		[request setHTTPMethod:@"GET"];
		[request setURL:[NSURL URLWithString:path]];
		NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&err];
		if(data){
			text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			if(text){
				log_debug(@"load css from remote: %@", path);
				sheet = [[IStyleSheet alloc] init];
				[sheet parseCss:text baseUrl:baseUrl];
			}
		}
	}else{
		text = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
		log_debug(@"load css from local: %@", path);
		if(!err){
			sheet = [[IStyleSheet alloc] init];
			[sheet parseCss:text baseUrl:baseUrl];
		}
	}

	if(_enableCssCache && sheet){
		[_cache setObject:sheet forKey:path];
	}

	return sheet;
}

@end
