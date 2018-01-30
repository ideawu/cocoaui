//
//  UIImageView.m
//  Mac
//
//  Created by ideawu on 30/01/2018.
//  Copyright © 2018 ideawu. All rights reserved.
//

#import "NSImageView+.h"

@implementation NSImageView(T)

- (NSImageView *)initWithImage:(UIImage *)image{
	self = [super init];
	self.image = image;
	return self;
}

@end
