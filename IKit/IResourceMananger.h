/*
 Copyright (c) 2014-2015 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.

 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IResourceMananger : NSObject

@property (nonatomic) NSTimeInterval cacheTime;

+ (IResourceMananger *)sharedMananger;
+ (void)setSharedManager:(IResourceMananger *)mananger;

//- (void)getXml:(NSString *)name url:(NSString *)url callback:(void (^)(NSString *))callback;

- (UIImage *)getImage:(NSString *)path callback:(void (^)(UIImage *))callback;

@end
