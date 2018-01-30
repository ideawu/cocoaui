//
//  UIView.m
//  Mac
//
//  Created by ideawu on 30/01/2018.
//  Copyright © 2018 ideawu. All rights reserved.
//

#import "NSView+.h"

@interface NSView(){
	NSColor *_backgroundColor;
	BOOL _clipsToBounds;
}
@end


@implementation NSView(T)

- (void)setNeedsLayout{
	self.needsLayout = YES;
}

- (void)setNeedsDisplay{
	self.needsDisplay = YES;
}

- (void)sendSubviewToBack:(NSView *)subView{
	[subView removeFromSuperview];
	[self addSubview:subView positioned:NSWindowBelow relativeTo:nil];
}

- (void)bringSubviewToFront:(NSView *)subView{
	[subView removeFromSuperview];
	[self addSubview:subView positioned:NSWindowAbove relativeTo:nil];
}

- (BOOL)wantsLayer{
	return YES;
}

- (NSColor *)backgroundColor{
	return _backgroundColor;
}

- (void)setBackgroundColor:(NSColor *)backgroundColor{
	_backgroundColor = backgroundColor;
	self.layer.backgroundColor = _backgroundColor.CGColor;
}

- (BOOL)userInteractionEnabled{
	return NO;
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled{
}

- (BOOL)clipsToBounds{
	return _clipsToBounds;
}

- (void)setClipsToBounds:(BOOL)clipsToBounds{
	_clipsToBounds = clipsToBounds;
}

- (BOOL)wantsDefaultClipping{
	// TODO:
	return YES;
}

@end
