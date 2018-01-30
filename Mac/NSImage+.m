//
//  UIImage.m
//  Mac
//
//  Created by ideawu on 30/01/2018.
//  Copyright © 2018 ideawu. All rights reserved.
//

#import "NSImage+.h"

@implementation NSImage(T)

+ (NSImage *)imageWithData:(NSData *)data{
	return [[NSImage alloc] initWithData:data];
}

@end
