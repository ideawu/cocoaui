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
#import "IStyleUtil.h"

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
	UIFont *_font;
	UIColor *_color;
	IStyleTextAlign _textAlign;
}
@property (nonatomic) CGFloat ratioWidth;
@property (nonatomic) CGFloat ratioHeight;
@property (nonatomic) UIFont *font;
@property (nonatomic) UIColor *color;
@property (nonatomic) IStyleTextAlign textAlign;
@end


@implementation IStyle

- (void)copyFrom:(IStyle *)style{
	_top = style.top;
	_left = style.left;
	_x = style.x;
	_y = style.y;
	_w = style.w;
	_h = style.h;
	_ratioWidth = style.ratioWidth;
	_ratioHeight = style.ratioHeight;
	
	_displayType = style.displayType;
	_overflowType = style.overflowType;
	_clearType = style.clearType;
	_floatType = style.floatType;
	_resizeType = style.resizeType;
	
	_margin = style.margin;
	_padding = style.padding;
	
	_borderDrawType = style.borderDrawType;
	_borderRadius = style.borderRadius;
	_borderLeft.width = style.borderLeft.width;
	_borderLeft.type = style.borderLeft.type;
	_borderLeft.color = style.borderLeft.color;
	_borderRight.width = style.borderRight.width;
	_borderRight.type = style.borderRight.type;
	_borderRight.color = style.borderRight.color;
	_borderTop.width = style.borderTop.width;
	_borderTop.type = style.borderTop.type;
	_borderTop.color = style.borderTop.color;
	_borderBottom.width = style.borderBottom.width;
	_borderBottom.type = style.borderBottom.type;
	_borderBottom.color = style.borderBottom.color;
	
	_fontSize = style.fontSize;
	_fontWeight = style.fontWeight;
	_fontFamily = style.fontFamily;
	_textAlign = style.textAlign;
	
	_font = style.font;
	_color = style.color;
	_backgroundColor = style.backgroundColor;
}

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
	_floatType = IStyleFloatLeft;
	_resizeType = IStyleResizeBoth;
	//_resizeType = IStyleResizeHeight;
	_ratioWidth = 1;

	_borderLeft = [[IStyleBorder alloc] init];
	_borderRight = [[IStyleBorder alloc] init];
	_borderTop = [[IStyleBorder alloc] init];
	_borderBottom = [[IStyleBorder alloc] init];
	
	_textAlign = IStyleTextAlignNone;
	_fontSize = [UIFont systemFontSize];
	_backgroundColor = [UIColor clearColor];
	return self;
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

- (void)setResizeWidth{
	_resizeType |= IStyleResizeWidth;
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

- (void)setWidth:(CGFloat)w{
	_w = w;
	_ratioWidth = 0;
	_resizeType &= ~IStyleResizeWidth;
}

- (CGFloat)height{
	return _h;
}

- (void)setHeight:(CGFloat)h{
	_h = h;
	_ratioHeight = 0;
	_resizeType &= ~IStyleResizeHeight;
}

- (void)setRatioWidth:(CGFloat)rw{
	_w = 0;
	_ratioWidth = rw;
	_resizeType &= ~IStyleResizeWidth;
}

- (void)setRatioHeight:(CGFloat)rh{
	_h = 0;
	_ratioHeight = rh;
	_resizeType &= ~IStyleResizeHeight;
}

- (CGFloat)ratioWidth{
	return _ratioWidth;
}

- (CGFloat)ratioHeight{
	return _ratioHeight;
}

- (CGFloat)innerWidth{
	return _w - (_padding.left + _padding.right);
}

- (void)setInnerWidth:(CGFloat)w{
	_ratioWidth = 0;
	_w = w + _padding.left + _padding.right;
}

- (CGFloat)innerHeight{
	return _h - (_padding.top + _padding.bottom);
}

- (void)setInnerHeight:(CGFloat)h{
	_ratioHeight = 0;
	_h = h + _padding.top + _padding.bottom;
}

- (CGFloat)outerWidth{
	return _w + _margin.left + _margin.right;
}

- (CGFloat)outerHeight{
	return _h + _margin.top + _margin.bottom;
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

- (void)set:(NSString *)css{
	[self set:css baseUrl:nil];
}

- (void)set:(NSString *)css baseUrl:(NSString *)baseUrl{
	if(!css){
		return;
	}
	css = [css stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSArray *kvs = [css componentsSeparatedByString:@";"];
	BOOL needsDisplay = NO;
	BOOL needsLayout = NO;
	
	for(NSString *s in kvs){
		NSArray *kv = [s componentsSeparatedByString:@":"];
		if(kv.count != 2){
			continue;
		}
		NSString *k = [kv objectAtIndex:0];
		NSString *v = [kv objectAtIndex:1];
		k = [k stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		v = [v stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		k = [k lowercaseString];
		v = [v lowercaseString];
		
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
				continue;
			}
			
			float f = [v floatValue];
			if([v rangeOfString:@"%"].location == NSNotFound){
				[self setWidth:f];
			}else{
				[self setRatioWidth:f/100];
			}
			//log_trace(@"w = %f, ratioW = %f", self.w, self.ratioW);
		}else if([k isEqualToString:@"height"]){
			needsLayout = YES;
			if([v isEqualToString:@"auto"]){
				// 默认 height: auto grow
				_ratioHeight = 0;
				_resizeType |= IStyleResizeHeight;
				continue;
			}
			
			float f = [v floatValue];
			if([v rangeOfString:@"%"].location == NSNotFound){
				[self setHeight:f];
			}else{
				[self setRatioHeight:f/100];
			}
			//log_trace(@"h = %f, ratioH = %f", self.h, self.ratioH);
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
				_color = [IKit colorFromHex:v];
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
		}else if([k isEqualToString:@"left"]){
			needsLayout = YES;
			_left = [v floatValue];
		}else if([k isEqualToString:@"top"]){
			needsLayout = YES;
			_top = [v floatValue];
		}else if([k isEqualToString:@"www"]){
			NSLog(@"www for c*ui");
		}
	}
	
	if(needsDisplay && _view){
		[_view setNeedsDisplay];
	}
	if(needsLayout && _view){
		[_view setNeedsLayout];
	}
}

- (void)parseBackground:(NSString *)v baseUrl:(NSString *)baseUrl{
	NSMutableArray *ps = [NSMutableArray arrayWithArray:
						  [v componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	[ps removeObject:@""];
	
	NSString *src = nil;
	for(NSString *p in ps){
		if([p characterAtIndex:0] == '#'){
			_backgroundColor = [IKit colorFromHex:p];
		}else if([p rangeOfString:@"url("].location != NSNotFound){
			src = [p substringFromIndex:4];
			static NSMutableCharacterSet *cs = nil;
			if(!cs){
				cs = [[NSMutableCharacterSet alloc] init];
				[cs addCharactersInString:@"\")"];
			}
			src = [src stringByTrimmingCharactersInSet:cs];
		}else if([p isEqualToString:@"none"]){
			_backgroundColor = [UIColor clearColor];
		}else if([p isEqualToString:@"repeat"]){
			_backgroundRepeat = YES;
		}else if([p isEqualToString:@"no-repeat"]){
			_backgroundRepeat = NO;
		}
	}
	if(src){
		if(![IStyleUtil isHttpUrl:src]){
			if(baseUrl){
				src = [baseUrl stringByAppendingString:src];
			}else{
				src = [[NSBundle mainBundle] pathForResource:src ofType:@""];
			}
		}
		if(src){
			log_debug(@"load background image: %@", src);
			if([IStyleUtil isHttpUrl:src]){
				NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
				[request setHTTPMethod:@"GET"];
				[request setURL:[NSURL URLWithString:src]];
				NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
				if(data){
					_backgroundImage = [UIImage imageWithData:data];
				}
			}else{
				_backgroundImage = [UIImage imageNamed:src];
			}
		}
	}
	if(_backgroundImage){
		//[_view setNeedsLayout]; // why do we need this?
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
	UIEdgeInsets edge;
	NSMutableArray *ps = [NSMutableArray arrayWithArray:
						  [v componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	[ps removeObject:@""];
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
	NSMutableArray *ps = [NSMutableArray arrayWithArray:
						  [v componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	[ps removeObject:@""];
	if(ps.count > 0){
		border.width = [ps[0] floatValue];
	}
	if([ps[1] isEqualToString:@"dashed"]){
		border.type = IStyleBorderDashed;
	}else{
		border.type = IStyleBorderSolid;
	}
	if(ps.count > 2){
		border.color = [IKit colorFromHex:ps[2]];
	}
	return border;
}

@end
