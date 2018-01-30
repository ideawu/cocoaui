//
//  UIView.h
//  Mac
//
//  Created by ideawu on 30/01/2018.
//  Copyright © 2018 ideawu. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface UIView : NSView

@property NSColor *backgroundColor;
@property BOOL userInteractionEnabled;
@property BOOL clipsToBounds;

- (void)setNeedsLayout;
- (void)setNeedsDisplay;
- (void)sendSubviewToBack:(UIView *)subView;
- (void)bringSubviewToFront:(UIView *)subView;

@end
