/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "IView.h"

@interface IImage : IView

+ (IImage *)imageNamed:(NSString *)name;

@property (nonatomic) NSString *src;
@property (nonatomic) UIImage *image;

@end
