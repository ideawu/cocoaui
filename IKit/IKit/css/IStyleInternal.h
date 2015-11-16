/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#ifndef IKit_IStyleInternal_h
#define IKit_IStyleInternal_h

#import "IStyle.h"

@class IView;
@class IStyleBorder;
@class ICssBlock;

typedef struct{
	CGFloat x, y, w, h;
}IRect;

typedef enum{
	IStyleDisplayAuto = 0,
	IStyleDisplayNone = 1,
}IStyleDisplayType;

typedef enum{
	IStyleClearNone  = 0,
	IStyleClearLeft  = 1<<0,
	IStyleClearRight = 1<<1,
	IStyleClearBoth  = IStyleClearLeft | IStyleClearRight
}IStyleClearType;

typedef enum{
	IStyleFloatLeft   = 1<<0,
	IStyleFloatRight  = 1<<1,
	IStyleFloatCenter = IStyleFloatLeft | IStyleFloatRight
}IStyleFloatType;

typedef enum{
	IStyleValignTop    = 0,
	IStyleValignBottom = 1<<0,
	IStyleValignMiddle = 1<<1,
}IStyleValignType;

typedef enum{
	IStyleResizeNone   = 0,
	IStyleResizeWidth  = 1<<0,
	IStyleResizeHeight = 1<<1,
	IStyleResizeBoth   = IStyleResizeWidth | IStyleResizeHeight
}IStyleResizeType;

typedef enum{
	IStyleOverflowHidden   = 0,
	IStyleOverflowVisible  = 1<<0
}IStyleOverflowType;

typedef enum{
	IStyleBorderDrawNone     = 0,
	IStyleBorderDrawSeparate = 1<<0,
	IStyleBorderDrawAll      = 1<<1
}IStyleBorderDrawType;

typedef enum{
	IStyleTextAlignNone     = -1,
	IStyleTextAlignLeft     = 0,
	IStyleTextAlignCenter   = 1,
	IStyleTextAlignRight    = 2,
	IStyleTextAlignJustify  = 3
}IStyleTextAlign;

typedef enum{
	IStyleBorderSolid,
	IStyleBorderDashed,
}IStyleBorderType;


@interface IStyleBorder : NSObject

@property (nonatomic) CGFloat width;
@property (nonatomic) IStyleBorderType type;
@property (nonatomic) UIColor *color;

@end


/*
 With CSS 2.1 box model(http://www.w3.org/TR/CSS2/box.html)
 box: include margin
 rect: include border
 */

@interface IStyle ()

@property (nonatomic, weak) IView *view;
@property (nonatomic) NSString *tagName;

// TODO:
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat left;

@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) CGFloat w;
@property (nonatomic) CGFloat h;

@property (nonatomic, readonly) IStyleDisplayType displayType;
@property (nonatomic, readonly) IStyleOverflowType overflowType;
@property (nonatomic, readonly) IStyleClearType clearType;
@property (nonatomic, readonly) IStyleFloatType floatType;
@property (nonatomic, readonly) IStyleResizeType resizeType;
@property (nonatomic, readonly) IStyleValignType valignType;

@property (nonatomic, readonly) UIEdgeInsets margin;
@property (nonatomic, readonly) UIEdgeInsets padding;

@property (nonatomic, readonly) IStyleBorderDrawType borderDrawType;
@property (nonatomic, readonly) CGFloat borderRadius;
@property (nonatomic, readonly) IStyleBorder *borderLeft;
@property (nonatomic, readonly) IStyleBorder *borderRight;
@property (nonatomic, readonly) IStyleBorder *borderTop;
@property (nonatomic, readonly) IStyleBorder *borderBottom;

@property (nonatomic, readonly) CGFloat fontSize;
@property (nonatomic, readonly) NSString *fontWeight;
@property (nonatomic, readonly) NSString *fontFamily;

@property (nonatomic, readonly) UIColor *backgroundColor;
@property (nonatomic, readonly) UIImage *backgroundImage;
@property (nonatomic, readonly) BOOL backgroundRepeat;

@property (nonatomic) ICssBlock *cssBlock;

+ (CGFloat)smallFontSize;
+ (CGFloat)normalFontSize;
+ (CGFloat)largeFontSize;

- (void)reset;
- (void)renderAllCss;

- (void)setId:(NSString *)ident;
- (void)set:(NSString *)css baseUrl:(NSString *)baseUrl;


- (UIColor *)inheritedColor;
- (UIFont *)inheritedFont;
- (NSTextAlignment)inheritedNSTextAlign;
- (IStyleTextAlign)inheritedTextAlign;


- (BOOL)hidden;

- (BOOL)overflowHidden;
- (BOOL)overflowVisible;

- (BOOL)floatLeft;
- (BOOL)floatRight;
- (BOOL)floatCenter;

- (BOOL)clearNone;
- (BOOL)clearLeft;
- (BOOL)clearRight;
- (BOOL)clearBoth;

- (BOOL)resizeNone;
- (BOOL)resizeWidth;
- (BOOL)resizeHeight;
- (BOOL)resizeBoth;

- (void)setResizeWidth;

- (void)setSize:(CGSize)size;

- (void)setInnerWidth:(CGFloat)w;
- (void)setInnerHeight:(CGFloat)h;
- (void)setRatioWidth:(CGFloat)rw;
- (void)setRatioHeight:(CGFloat)rh;
- (CGFloat)ratioWidth;
- (CGFloat)ratioHeight;

// 不包括 margin
- (CGRect)rect;
- (IRect)outerBox;

@end

#endif
