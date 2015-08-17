/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "IMaskUIView.h"
#import "IViewInternal.h"
#import "IStyleInternal.h"

@implementation IMaskUIView

- (id)init{
	self = [super init];
	return self;
}

- (id)initWithFrame:(CGRect)frame{
	self = [super initWithFrame:frame];
	self.userInteractionEnabled = NO;
	self.backgroundColor = [UIColor clearColor];
	return self;
}

- (void)strokeBorder:(IStyleBorder *)border context:(CGContextRef)context{
	if(border.type == IStyleBorderDashed){
		CGFloat dashes[] = {border.width * 5, border.width * 5};
		CGContextSetLineDash(context, 0, dashes, 2);
	}
	CGContextSetLineWidth(context, border.width);
	[border.color set];
	CGContextStrokePath(context);
}

- (void)drawRect:(CGRect)rect{
	//NSLog(@"%s %@", __func__, NSStringFromCGRect(self.frame));
	IView *view = (IView *)self.superview;
	IStyle *_style = view.style;
	CGFloat radius = _style.borderRadius;
	CGFloat x1, y1, x2, y2;
	x1 = rect.origin.x;
	y1 = rect.origin.y;
	x2 = x1 + rect.size.width;
	y2 = y1 + rect.size.height;
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// top
	//NSLog(@"currentPoint: %@", NSStringFromCGPoint(CGContextGetPathCurrentPoint(context)));
	CGContextAddArc(context, radius, radius, radius-_style.borderTop.width/2, M_PI*5/4, M_PI*6/4, 0);
	//NSLog(@"arc currentPoint: %@", NSStringFromCGPoint(CGContextGetPathCurrentPoint(context)));
	CGContextAddLineToPoint(context, x2 - radius, y1+_style.borderTop.width/2);
	//NSLog(@"line currentPoint: %@", NSStringFromCGPoint(CGContextGetPathCurrentPoint(context)));
	CGContextAddArc(context, x2 - radius, y1 + radius, radius-_style.borderTop.width/2, M_PI*6/4, M_PI*7/4, 0);
	//NSLog(@"arc currentPoint: %@", NSStringFromCGPoint(CGContextGetPathCurrentPoint(context)));
	[self strokeBorder:_style.borderTop context:context];
	
	// right
	CGContextAddArc(context, x2 - radius, y1 + radius, radius-_style.borderRight.width/2, M_PI*7/4, M_PI*8/4, 0);
	CGContextAddLineToPoint(context, x2-_style.borderRight.width/2, y2 - radius);
	CGContextAddArc(context, x2 - radius, y2 - radius, radius-_style.borderRight.width/2, M_PI*8/4, M_PI*9/4, 0);
	[self strokeBorder:_style.borderRight context:context];
	
	// bottom
	CGContextAddArc(context, x2 - radius, y2 - radius, radius-_style.borderBottom.width/2, M_PI*9/4, M_PI*10/4, 0);
	CGContextAddLineToPoint(context, x1 + radius, y2-_style.borderBottom.width/2);
	CGContextAddArc(context, x1 + radius, y2 - radius, radius-_style.borderBottom.width/2, M_PI*10/4, M_PI*11/4, 0);
	[self strokeBorder:_style.borderBottom context:context];
	
	// left
	CGContextAddArc(context, x1 + radius, y2 - radius, radius-_style.borderLeft.width/2, M_PI*11/4, M_PI*12/4, 0);
	CGContextAddLineToPoint(context, x1+_style.borderLeft.width/2, y1 + radius);
	CGContextAddArc(context, x1 + radius, y1 + radius, radius-_style.borderLeft.width/2, M_PI*12/4, M_PI*13/4, 0);
	[self strokeBorder:_style.borderLeft context:context];
}

@end
