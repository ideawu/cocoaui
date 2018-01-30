//
//  NSValue+.m
//  Mac
//
//  Created by ideawu on 30/01/2018.
//  Copyright © 2018 ideawu. All rights reserved.
//

#import "NSValue_.h"

@implementation NSValue(T)

+ (NSValue *)valueWithCGPoint:(CGPoint)point{
	return [NSValue valueWithPoint:point];
}

- (CGPoint)CGPointValue{
	return self.pointValue;
}

@end
