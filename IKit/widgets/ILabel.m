/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "ILabel.h"
#import "IViewInternal.h"
#import "IStyleInternal.h"

@interface ILabel (){
	UILabel *_label;
}
@end;

@implementation ILabel

+ (ILabel *)labelWithText:(NSString *)text{
	ILabel *ret = [[ILabel alloc] init];
	[ret setText:text];
	return ret;
}

- (id)init{
	static UIFont *defaultFont = nil;
	if(defaultFont == nil){
		defaultFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
	}
	
	self = [super init];
	self.style.tagName = @"label";

	_label = [[UILabel alloc] init];
	_label.font = defaultFont;
	_label.numberOfLines = 0;
	_label.lineBreakMode = NSLineBreakByWordWrapping; // NSLineBreakByCharWrapping NSLineBreakByWordWrapping
	
	[self addUIView:_label];
	return self;
}

- (NSString *)text{
	return _label.text;
}

- (void)setText:(NSString *)text{
	//log_debug(@"%@ %s %@", self.name, __func__, text);
	_label.text = text;
	[self setNeedsLayout];
}

- (NSAttributedString *)attributedText{
	return _label.attributedText;
}

- (void)setAttributedText:(NSAttributedString *)attributedText{
	_label.attributedText = attributedText;
	[self setNeedsLayout];
}

- (void)updateFrame{
	[super updateFrame];
	// label 的定位和 button 不一样, button 是直接拉伸, 因为 button 的 padding 是可点击的,
	// 如果以后 label 需要可点击, 那么必须创建 UILabel 的子类.
	_label.frame = UIEdgeInsetsInsetRect(_label.frame, self.style.padding);
}

- (void)drawRect:(CGRect)rect{
	UIColor *color = self.style.inheritedColor;
	if(color){
		_label.textColor = color;
	}

	[super drawRect:rect];
}

- (void)layout{
	//log_debug(@"%@ %s %@", self.name, __func__, _label.text);
	[super layout];

	UIFont *font = self.style.inheritedFont;
	if(font){
		_label.font = font;
	}
	_label.textAlignment = self.style.inheritedNSTextAlign;
	
	{
		CGRect frame = _label.frame;
		// 如果 label 是 auto-width, 那么这里的宽度应该是父容器的宽度
		if(self.style.resizeWidth){
			frame.size.width = self.parent.style.innerWidth;
		}else{
			frame.size.width = self.style.w;
		}
		_label.frame = frame;
		[_label sizeToFit];
		/*
		CGSize maxSize = CGSizeMake(self.style.w, FLT_MAX);
		NSStringDrawingOptions opts = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
		//NSDictionary *attrs = @{NSFontAttributeName:_label.font};
		//CGRect rect = [_label.text boundingRectWithSize:maxSize options:opts attributes:attrs context:nil];
		CGRect rect = [_label.attributedText boundingRectWithSize:maxSize options:opts context:nil];
		CGRect frame = _label.frame;
		frame.size.width = ceil(rect.size.width);
		frame.size.height = ceil(rect.size.height);
		_label.frame = frame;
		 */
	}
	
	if(self.style.resizeWidth){
		//log_debug(@"resize width %f", _label.frame.size.width);
		[self.style setInnerWidth:_label.frame.size.width];
	}
	if(self.style.resizeHeight){
		//log_debug(@"resize height %f", _label.frame.size.height);
		[self.style setInnerHeight:_label.frame.size.height];
	}
}

@end
