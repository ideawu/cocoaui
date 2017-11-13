/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "IViewInternal.h"
#import "IStyleInternal.h"
#import "IKitUtil.h"
#import "IResourceMananger.h"
#import "IStyleSheet.h"
#import "IViewInternal.h"
#import "IViewLoader.h"
#import "ICssDecl.h"
#import "ICssBlock.h"
#import "ICssRule.h"

@implementation IStyleBorder

- (id)init{
	self = [super init];
	self.color = [UIColor clearColor];
	return self;
}

@end

///////////////////////////////////////////////////////////////////////

@interface IStyle (){
	CGFloat _ratioWidth, _ratioHeight;
	CGFloat _opacity;
	UIFont *_font;
	UIColor *_color;
	IStyleTextAlign _textAlign;
	BOOL needsDisplay, needsLayout;
}
@property (nonatomic) CGFloat ratioWidth;
@property (nonatomic) CGFloat ratioHeight;
@property (nonatomic) UIFont *font;
@property (nonatomic) UIColor *color;
@property (nonatomic) IStyleTextAlign textAlign;
@property (nonatomic) NSMutableSet *classes;
@end


@implementation IStyle

+ (CGFloat)smallFontSize{
	return [UIFont smallSystemFontSize];
}

+ (CGFloat)normalFontSize{
	return [UIFont systemFontSize];
}

+ (CGFloat)largeFontSize{
	static CGFloat size = 0;
	if(size == 0){
		size = [IStyle normalFontSize] + ([IStyle normalFontSize] - [IStyle smallFontSize]) + 1;
	}
	return size;
}

- (id)init{
	self = [super init];
	[self reset];
	_cssBlock = [[ICssBlock alloc] init];
	_classes = [[NSMutableSet alloc] init];
	return self;
}

- (void)reset{
	_floatType = IStyleFloatLeft;
	_resizeType = IStyleResizeBoth;
	//_resizeType = IStyleResizeHeight;
	_ratioWidth = 1;
	_opacity = 1.0;
	
	_borderLeft = [[IStyleBorder alloc] init];
	_borderRight = [[IStyleBorder alloc] init];
	_borderTop = [[IStyleBorder alloc] init];
	_borderBottom = [[IStyleBorder alloc] init];
	
	_textAlign = IStyleTextAlignNone;
	_fontSize = [UIFont systemFontSize];
	_backgroundColor = [UIColor clearColor];
}

- (BOOL)hidden{
	return _displayType == IStyleDisplayNone;
}

- (BOOL)overflowHidden{
	return (BOOL)(_overflowType == IStyleOverflowHidden);
}

- (BOOL)overflowVisible{
	return (BOOL)(_overflowType == IStyleOverflowVisible);
}

- (BOOL)floatLeft{
	return (BOOL)(_floatType & IStyleFloatLeft);
}

- (BOOL)floatRight{
	return (BOOL)(_floatType & IStyleFloatRight);
}

- (BOOL)floatCenter{
	return _floatType == IStyleFloatCenter;
}

- (BOOL)clearNone{
	return _clearType == IStyleClearNone;
}

- (BOOL)clearLeft{
	return (BOOL)(_clearType & IStyleClearLeft);
}

- (BOOL)clearRight{
	return (BOOL)(_clearType & IStyleClearRight);
}

- (BOOL)clearBoth{
	return _clearType == IStyleClearBoth;
}

- (BOOL)resizeNone{
	return _resizeType == IStyleResizeNone;
}

- (BOOL)resizeWidth{
	return (BOOL)(_resizeType & IStyleResizeWidth);
}

- (BOOL)resizeHeight{
	return (BOOL)(_resizeType & IStyleResizeHeight);
}

- (BOOL)resizeBoth{
	return _resizeType == IStyleResizeBoth;
}

- (CGSize)size{
	return CGSizeMake(self.w, self.h);
}

- (void)setSize:(CGSize)size{
	[self setWidth:size.width];
	[self setHeight:size.height];
}

- (CGFloat)width{
	return _w;
}

- (CGFloat)height{
	return _h;
}

- (void)setWidth:(CGFloat)w{
	[self set:[NSString stringWithFormat:@"width: %f", w]];
}

- (void)setHeight:(CGFloat)h{
	[self set:[NSString stringWithFormat:@"height: %f", h]];
}

- (void)setRatioWidth:(CGFloat)rw{
	[self set:[NSString stringWithFormat:@"width: %f%%", rw*100]];
}

- (void)setRatioHeight:(CGFloat)rh{
	[self set:[NSString stringWithFormat:@"height: %f%%", rh*100]];
}

- (CGFloat)ratioWidth{
	return _ratioWidth;
}

- (CGFloat)ratioHeight{
	return _ratioHeight;
}

- (CGFloat)innerWidth{
	return _w - (_padding.left + _padding.right + _borderLeft.width + _borderRight.width);
}

- (void)setInnerWidth:(CGFloat)w{
	_ratioWidth = 0;
	_w = w + _padding.left + _padding.right + _borderLeft.width + _borderRight.width;
}

- (CGFloat)innerHeight{
	return _h - (_padding.top + _padding.bottom + _borderTop.width + _borderBottom.width);
}

- (void)setInnerHeight:(CGFloat)h{
	_ratioHeight = 0;
	_h = h + _padding.top + _padding.bottom + _borderTop.width + _borderBottom.width;
}

- (CGFloat)outerWidth{
	return _w + _margin.left + _margin.right;
}

- (CGFloat)outerHeight{
	return _h + _margin.top + _margin.bottom;
}

- (CGFloat)opacity{
	return _opacity;
}

- (void)setOpacity:(CGFloat)opacity{
	[self set:[NSString stringWithFormat:@"opacity: %f", opacity]];
}

- (CGRect)rect{
	return CGRectMake(_x, _y, _w, _h);
}

- (IRect)outerBox{
	IRect rect;
	rect.x = _x - _margin.left;
	rect.y = _y - _margin.top;
	rect.w = _w + _margin.left + _margin.right;
	rect.h = _h + _margin.top + _margin.bottom;
	return rect;
}

/// inheritented properties

- (IStyleTextAlign)inheritedTextAlign{
	if(_textAlign == IStyleTextAlignNone && _view && _view.parent){
		return _view.parent.style.inheritedTextAlign;
	}
	return _textAlign;
}

- (UIFont *)inheritedFont{
	if(_font == nil && _view && _view.parent){
		return _view.parent.style.inheritedFont;
	}
	return _font;
}

- (UIColor *)inheritedColor{
	if(_color == nil && _view && _view.parent){
		return _view.parent.style.inheritedColor;
	}
	return _color;
}

///

- (NSTextAlignment)inheritedNSTextAlign{
	switch (self.inheritedTextAlign) {
		case IStyleTextAlignCenter:
			return NSTextAlignmentCenter;
		case IStyleTextAlignRight:
			return NSTextAlignmentRight;
		case IStyleTextAlignJustify:
			return NSTextAlignmentJustified;
		default:
			return NSTextAlignmentLeft;
	}
}

- (void)setClass:(NSString *)clz{
	[_classes removeAllObjects];
	[self addClass:clz];
}

- (void)addClass:(NSString *)clz{
	//log_debug(@"%s %@", __func__, clz);
	clz = [clz lowercaseString];
	[_classes addObject:clz];
//	if(_view.inheritedStyleSheet){
		[self renderAllCss];
//	}
}

- (void)removeClass:(NSString *)clz{
	clz = [clz lowercaseString];
	[_classes removeObject:clz];
//	if(_view.inheritedStyleSheet){
		[self renderAllCss];
//	}
}

- (BOOL)hasClass:(NSString *)clz{
	clz = [clz lowercaseString];
	return [_classes containsObject:clz];
}

// 该方法只被 IViewLoader 使用
- (void)setId:(NSString *)ident{
	_view.vid = ident;
	if(_view.inheritedStyleSheet){
		[self renderAllCss];
	}
}

- (void)set:(NSString *)css{
	[self set:css baseUrl:nil];
}

- (void)set:(NSString *)css baseUrl:(NSString *)baseUrl{
	if(!css){
		return;
	}
	needsDisplay = NO;
	needsLayout = NO;
	
	if(baseUrl){
		_cssBlock.baseUrl = baseUrl;
	}
	
	ICssBlock *set = [ICssBlock fromCss:css baseUrl:_cssBlock.baseUrl];
	for(ICssDecl *decl in set.decls){
		[self applyDecl:decl baseUrl:set.baseUrl];
		[_cssBlock addDecl:decl];
	}

	if(needsDisplay && _view){
		[_view setNeedsDisplay];
	}
	if(needsLayout && _view){
		[_view setNeedsLayout];
	}
}

- (void)renderCssFromStylesheet:(IStyleSheet *)sheet{
	for(ICssRule *rule in sheet.rules){
		//log_debug(@"RULE: %@", rule);
		if([rule matchView:_view]){
			//log_debug(@" %@#%@ match?: %d", _tagName, self.view.vid, [rule matchView:_view]);
			for(ICssDecl *decl in rule.declBlock.decls){
				//log_debug(@"  %@ %@ %@: %@", decl, decl.key, decl.key, decl.val);
				[self applyDecl:decl baseUrl:rule.declBlock.baseUrl];
			}
		}
	}
}

- (void)renderAllCss{
	// 1. builtin(default) css
	// 2. stylesheet(by style tag) css
	// 3. inline css
	// $: dynamically set css
	
	//log_debug(@"%@ %@ %s", _view.name, _tagName, __func__);
	[self reset];

	// 1. built-in css
	[self renderCssFromStylesheet:[IStyleSheet builtin]];
	
	// 2. stylesheet css
	IStyleSheet *sheet = _view.inheritedStyleSheet;
	if(sheet){
		[self renderCssFromStylesheet:sheet];
	}
	
	// 3. inline css
	for(ICssDecl *decl in _cssBlock.decls){
		[self applyDecl:decl baseUrl:_cssBlock.baseUrl];
	}
	
	[_view setNeedsDisplay];
	[_view setNeedsLayout];
	
	// 重新应用子节点的样式
	for(IView *sub in _view.subs){
		[sub.style renderAllCss];
	}
}

- (void)applyDecl:(ICssDecl *)decl baseUrl:(NSString *)baseUrl{
	NSString *k = decl.key;
	NSString *v = decl.val;
	//log_debug(@"    %@: %@;", k, v);
	
	if([k isEqualToString:@"display"]){
		needsLayout = YES;
		if([v isEqualToString:@"auto"]){
			_displayType = IStyleDisplayAuto;
		}else if([v isEqualToString:@"none"]){
			_displayType = IStyleDisplayNone;
		}
	}else if([k isEqualToString:@"float"] || [k isEqualToString:@"align"]){
		needsLayout = YES;
		if([v isEqualToString:@"left"]){
			_floatType = IStyleFloatLeft;
		}else if([v isEqualToString:@"right"]){
			_floatType = IStyleFloatRight;
		}else if([v isEqualToString:@"center"]){
			_floatType = IStyleFloatCenter;
		}
		//log_trace(@"floatType = %d", self.floatType);
	}else if([k isEqualToString:@"valign"]){
		needsLayout = YES;
		if([v isEqualToString:@"top"]){
			_valignType = IStyleValignTop;
		}else if([v isEqualToString:@"bottom"]){
			_valignType = IStyleValignBottom;
		}else if([v isEqualToString:@"middle"]){
			_valignType = IStyleValignMiddle;
		}
	}else if([k isEqualToString:@"clear"]){
		needsLayout = YES;
		if([v isEqualToString:@"left"]){
			_clearType = IStyleClearLeft;
		}else if([v isEqualToString:@"right"]){
			_clearType = IStyleClearRight;
		}else if([v isEqualToString:@"both"]){
			_clearType = IStyleClearBoth;
		}else if([v isEqualToString:@"none"]){
			_clearType = IStyleClearNone;
		}
		//log_trace(@"clearType = %d", self.clearType);
	}else if([k isEqualToString:@"width"]){
		needsLayout = YES;
		if([v isEqualToString:@"auto"]){
			// 默认 width: 100%
			_ratioWidth = 0;
			_resizeType |= IStyleResizeWidth;
			return;
		}
		_resizeType &= ~IStyleResizeWidth;
		
		float f = [v floatValue];
		if([v rangeOfString:@"%"].location == NSNotFound){
			_w = f;
			_ratioWidth = 0;
		}else{
			_w = 0;
			_ratioWidth = f/100;
		}
		//log_trace(@"w = %f, ratioW = %f", self.w, self.ratioWidth);
	}else if([k isEqualToString:@"height"]){
		needsLayout = YES;
		if([v isEqualToString:@"auto"]){
			// 默认 height: auto grow
			_ratioHeight = 0;
			_resizeType |= IStyleResizeHeight;
			return;
		}
		_resizeType &= ~IStyleResizeHeight;
		
		float f = [v floatValue];
		if([v rangeOfString:@"%"].location == NSNotFound){
			_h = f;
			_ratioHeight = 0;
		}else{
			_h = 0;
			_ratioHeight = f/100;
		}
		//log_trace(@"h = %f, ratioH = %f", self.h, self.ratioH);
	}else if([k isEqualToString:@"aspect-ratio"]){
		needsLayout = YES;
		if([v isEqualToString:@"auto"]){
			_aspectRatio = 0;
			return;
		}
		
		float f = [v floatValue];
		if([v rangeOfString:@"%"].location == NSNotFound){
			if([v rangeOfString:@"/"].location == NSNotFound){
				_aspectRatio = f;
			}else{
				NSArray *ps = [v componentsSeparatedByString:@"/"];
				f = ((NSString *)ps[0]).floatValue / ((NSString *)ps[1]).floatValue;
				_aspectRatio = f;
			}
		}else{
			_aspectRatio = f/100;
		}
	}else if([k isEqualToString:@"margin"]){
		needsLayout = YES;
		_margin = [self parseEdge:v];
		//log_trace(@"margin: %f %f %f %f", _margin.top, _margin.right, _margin.bottom, _margin.left);
	}else if([k isEqualToString:@"margin-top"]){
		needsLayout = YES;
		_margin.top = [v floatValue];
	}else if([k isEqualToString:@"margin-right"]){
		needsLayout = YES;
		_margin.right = [v floatValue];
	}else if([k isEqualToString:@"margin-bottom"]){
		needsLayout = YES;
		_margin.bottom = [v floatValue];
	}else if([k isEqualToString:@"margin-left"]){
		needsLayout = YES;
		_margin.left = [v floatValue];
	}else if([k isEqualToString:@"padding"]){
		needsLayout = YES;
		_padding = [self parseEdge:v];
		//log_trace(@"padding: %f %f %f %f", _padding.top, _padding.right, _padding.bottom, _padding.left);
	}else if([k isEqualToString:@"padding-top"]){
		needsLayout = YES;
		_padding.top = [v floatValue];
	}else if([k isEqualToString:@"padding-right"]){
		needsLayout = YES;
		_padding.right = [v floatValue];
	}else if([k isEqualToString:@"padding-bottom"]){
		needsLayout = YES;
		_padding.bottom = [v floatValue];
	}else if([k isEqualToString:@"padding-left"]){
		needsLayout = YES;
		_padding.left = [v floatValue];
	}else if([k isEqualToString:@"border"]){
		needsDisplay = YES;
		_borderLeft = [self parseBorder:v];
		_borderRight = _borderTop = _borderBottom = _borderLeft;
		_borderDrawType = IStyleBorderDrawAll;
	}else if([k isEqualToString:@"border-top"]){
		needsDisplay = YES;
		_borderTop = [self parseBorder:v];
		[self determineBorderDrawType];
	}else if([k isEqualToString:@"border-right"]){
		needsDisplay = YES;
		_borderRight = [self parseBorder:v];
		[self determineBorderDrawType];
	}else if([k isEqualToString:@"border-bottom"]){
		needsDisplay = YES;
		_borderBottom = [self parseBorder:v];
		[self determineBorderDrawType];
	}else if([k isEqualToString:@"border-left"]){
		needsDisplay = YES;
		_borderLeft = [self parseBorder:v];
		[self determineBorderDrawType];
	}else if([k isEqualToString:@"border-radius"]){
		needsDisplay = YES;
		_borderRadius = [v floatValue];
		//log_trace(@"border-radius: %f", _borderRadius);
	}else if([k isEqualToString:@"text-align"]){
		needsLayout = YES;
		if([v isEqualToString:@"left"]){
			_textAlign = IStyleTextAlignLeft;
		}else if([v isEqualToString:@"right"]){
			_textAlign = IStyleTextAlignRight;
		}else if([v isEqualToString:@"center"]){
			_textAlign = IStyleTextAlignCenter;
		}else if([v isEqualToString:@"justify"]){
			_textAlign = IStyleTextAlignJustify;
		}
	}else if([k isEqualToString:@"font-size"]){
		needsLayout = YES;
		if([v isEqualToString:@"small"]){
			_fontSize = [IStyle smallFontSize];
		}else if([v isEqualToString:@"large"]){
			_fontSize = [IStyle largeFontSize];
		}else if([v isEqualToString:@"normal"]){
			_fontSize = [IStyle normalFontSize];
		}else{
			_fontSize = [v floatValue];
			if([v rangeOfString:@"%"].location != NSNotFound){
				_fontSize = [IStyle normalFontSize] * (_fontSize/100);
			}
		}
		[self applyFont];
	}else if([k isEqualToString:@"color"]){
		needsDisplay = YES;
		if([v isEqualToString:@"none"]){
			_color = nil;
		}else{
			_color = [IKitUtil colorFromHex:v];
		}
		//log_trace(@"color: %@", color);
	}else if([k isEqualToString:@"font-family"]){
		needsLayout = YES;
		_fontFamily = v;
		[self applyFont];
	}else if([k isEqualToString:@"font-weight"]){
		needsLayout = YES;
		if([v isEqualToString:@"bold"]){
			_fontWeight = @"bold";
		}else{
			_fontWeight = @"normal";
		}
		[self applyFont];
	}else if([k isEqualToString:@"background"]){
		needsDisplay = YES;
		[self parseBackground:v baseUrl:baseUrl];
		//log_trace(@"background: %@", self.backgroundColor);
	}else if([k isEqualToString:@"opacity"]){
		needsDisplay = YES;
		_opacity = [v floatValue];
	}else if([k isEqualToString:@"left"]){
		needsLayout = YES;
		_left = [v floatValue];
	}else if([k isEqualToString:@"top"]){
		needsLayout = YES;
		_top = [v floatValue];
	}else if([k isEqualToString:@"www"]){
		log_debug(@"www for c*ui");
	}
}

- (void)parseBackground:(NSString *)v baseUrl:(NSString *)baseUrl{
	NSString *src = nil;
	NSArray *ps = [IKitUtil split:v];
	for(NSString *p in ps){
		if([p characterAtIndex:0] == '#'){
			_backgroundColor = [IKitUtil colorFromHex:p];
		}else if([p rangeOfString:@"url("].location != NSNotFound){
			src = [p substringFromIndex:4];
			static NSCharacterSet *cs = nil;
			if(!cs){
				cs = [NSCharacterSet characterSetWithCharactersInString:@"'\")"];
			}
			src = [src stringByTrimmingCharactersInSet:cs];
		}else if([p isEqualToString:@"none"]){
			_backgroundColor = [UIColor clearColor];
			_backgroundImage = nil;
			_backgroundRepeat = NO;
		}else if([p isEqualToString:@"repeat"]){
			_backgroundRepeat = YES;
		}else if([p isEqualToString:@"no-repeat"]){
			_backgroundRepeat = NO;
		}
	}
	_backgroundImage = nil;
	if(src){
		if(![IKitUtil isDataURI:src]){
			src = [IKitUtil buildPath:baseUrl src:src];
		}
		//log_debug(@"%@ load background image: %@", _view.name, src);
		IEventType event = _view.event;
		[[IResourceMananger sharedMananger] loadImageSrc:src callback:^(UIImage *img) {
			// 如果在异步加载的前后, _view 状态发生了改变, 则不更新 background-image
			// 可能有考虑不到的地方, 但先这么做吧.
			if(event == _view.event){
				_backgroundImage = img;
				[_view setNeedsDisplay];
			}
		}];
	}
}

- (void)applyFont{
	if(!_fontFamily){
		if([_fontWeight isEqualToString:@"bold"]){
			_font = [UIFont boldSystemFontOfSize:_fontSize];
		}else{
			_font = [UIFont systemFontOfSize:_fontSize];
		}
	}else{
		if([_fontWeight isEqualToString:@"bold"]){
			NSString *f = [NSString stringWithFormat:@"%@-bold", _fontFamily];
			_font = [UIFont fontWithName:f size:_fontSize];
		}else{
			_font = [UIFont fontWithName:_fontFamily size:_fontSize];
		}
	}
}

- (void)determineBorderDrawType{
	if(_borderTop.width == _borderBottom.width
	   && _borderTop.width == _borderLeft.width
	   && _borderTop.width == _borderRight.width
	   && CGColorEqualToColor(_borderTop.color.CGColor, _borderBottom.color.CGColor)
	   && CGColorEqualToColor(_borderTop.color.CGColor, _borderLeft.color.CGColor)
	   && CGColorEqualToColor(_borderTop.color.CGColor, _borderRight.color.CGColor)){
		_borderDrawType = IStyleBorderDrawAll;
	}else{
		_borderDrawType = IStyleBorderDrawSeparate;
	}
}

- (UIEdgeInsets)parseEdge:(NSString *)v{
	UIEdgeInsets edge = UIEdgeInsetsZero;
	NSArray *ps = [IKitUtil split:v];
	if(ps.count == 1){
		edge.left = edge.right = edge.top = edge.bottom = [ps[0] floatValue];
	}else if(ps.count == 2){
		edge.top = edge.bottom = [ps[0] floatValue];
		edge.left = edge.right = [ps[1] floatValue];
	}else if(ps.count == 3){
		edge.top    = [ps[0] floatValue];
		edge.left   = [ps[1] floatValue];
		edge.right  = [ps[1] floatValue];
		edge.bottom = [ps[2] floatValue];
	}else if(ps.count == 4){
		edge.top    = [ps[0] floatValue];
		edge.right  = [ps[1] floatValue];
		edge.bottom = [ps[2] floatValue];
		edge.left   = [ps[3] floatValue];
	}
	return edge;
}

- (IStyleBorder *)parseBorder:(NSString *)v{
	IStyleBorder *border = [[IStyleBorder alloc] init];
	if([v isEqualToString:@"none"]){
		return border;
	}
	NSArray *ps = [IKitUtil split:v];
	if(ps.count > 0){
		border.width = [ps[0] floatValue];
	}
	if(ps.count > 1){
		if([ps[1] isEqualToString:@"dashed"]){
			border.type = IStyleBorderDashed;
		}else{
			border.type = IStyleBorderSolid;
		}
	}
	if(ps.count > 2){
		border.color = [IKitUtil colorFromHex:ps[2]];
	}
	return border;
}

@end
