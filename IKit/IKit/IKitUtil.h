/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#ifndef IKit_IKitUtil_h
#define IKit_IKitUtil_h

#import <Foundation/Foundation.h>

@interface IKit : NSObject

+ (UIColor *) colorFromHex:(NSString *)hex;
+ (void)alert:(NSString *)msg;

@end

#endif
