//
//  NSValue+.h
//  Mac
//
//  Created by ideawu on 30/01/2018.
//  Copyright © 2018 ideawu. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSValue(T)

+ (NSValue *)valueWithCGPoint:(CGPoint)point;

- (CGPoint)CGPointValue;

@end
