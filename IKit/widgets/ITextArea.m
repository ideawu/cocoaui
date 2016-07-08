/*
 Copyright (c) 2014-2016 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "ITextArea.h"
#import "IViewInternal.h"
#import "IStyleInternal.h"

@implementation ITextArea

- (id)init{
	static UIFont *defaultFont = nil;
	if(defaultFont == nil){
		defaultFont = [UIFont systemFontOfSize:([UIFont systemFontSize]+2)];
	}
	
	self = [super init];
	self.style.tagName = @"textarea";
	
	_textView = [[UITextView alloc] init];
	[self addUIView:_textView];
	_textView.font = defaultFont;

	return self;
}

- (NSString *)text{
	return self.value;
}

- (void)setText:(NSString *)text{
	self.value = text;
}

- (NSString *)value{
	return _textView.text;
}

- (void)setValue:(NSString *)value{
	_textView.text = value;
}

- (void)drawRect:(CGRect)rect{
	UIColor *color = self.style.inheritedColor;
	if(color){
		_textView.textColor = color;
	}
	
	[super drawRect:rect];
}

- (void)updateFrame{
	[super updateFrame];
	_textView.frame = UIEdgeInsetsInsetRect(_textView.frame, self.style.padding);
}

- (void)layout{
	//log_debug(@"%@ %s %@", self.name, __func__, _textField.text);
	[super layout];
	
	UIFont *font = self.style.inheritedFont;
	if(font){
		_textView.font = font;
	}
	_textView.textAlignment = self.style.inheritedNSTextAlign;
}

@end
