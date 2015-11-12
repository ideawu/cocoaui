/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import <UIKit/UIKit.h>

@interface IStyleUtil : NSObject

+ (UIColor *) colorFromHex:(NSString *)hex;
+ (BOOL)isHttpUrl:(NSString *)src;

+ (NSArray *)parsePath:(NSString *)path;
// combine basePath + src, src may be URL or absolute file path
+ (NSString *)buildPath:(NSString *)basePath src:(NSString *)src;

+ (UIImage *)loadImageFromPath:(NSString *)path;

@end
