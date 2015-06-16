/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#ifndef Http_h
#define Http_h

#import <Foundation/Foundation.h>
#import "IObj.h"

void http_get(NSString *urlStr, id params, void (^callback)(IObj *resp));
void http_post(NSString *urlStr, id params, void (^callback)(IObj *resp));
void http_get_raw(NSString *urlStr, id params, void (^callback)(NSData *data));
void http_post_raw(NSString *urlStr, id params, void (^callback)(NSData *data));

@interface Http : NSObject

+ (void (^)(NSString *path, id params, void (^)(IObj *resp)))get;
+ (void (^)(NSString *path, id params, void (^)(IObj *resp)))post;

+ (void (^)(NSString *path, id params, void (^)(NSData *resp)))raw_get;
+ (void (^)(NSString *path, id params, void (^)(NSData *resp)))raw_post;

@end

#endif
