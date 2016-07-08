/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "IInput.h"
#import "IViewInternal.h"
#import "IStyleInternal.h"

typedef enum{
	IInputText,
	IInputPassword
}IInputType;

@interface IInput () <UITextFieldDelegate>{
	IInputType _type;
	void (^_changeHandler)(IEventType, IView *);
	void (^_returnHandler)(IEventType, IView *);
}
@property (nonatomic) IInputType type;
@end

@implementation IInput

+ (IInput *)textInput{
	IInput *ret = [[self alloc] init];
	ret.isPasswordInput = NO;
	return ret;
}

+ (IInput *)passwordInput{
	IInput *ret = [[self alloc] init];
	ret.isPasswordInput = YES;
	return ret;
}

- (id)init{
	static UIFont *defaultFont = nil;
	if(defaultFont == nil){
		defaultFont = [UIFont systemFontOfSize:([UIFont systemFontSize]+2)];
	}

	self = [super init];
	self.style.tagName = @"input";

	_textField = [[UITextField alloc] init];
	[self addUIView:_textField];
	_textField.delegate = self;
	_textField.font = defaultFont;
	//_textField.returnKeyType = UIReturnKeyDone;

	//_textField.backgroundColor = [UIColor yellowColor];
	return self;
}

- (BOOL)isPasswordInput{
	return (_type == IInputPassword);
}

- (void)setIsPasswordInput:(BOOL)yesno{
	_type = yesno? IInputPassword : IInputText;
	_textField.secureTextEntry = yesno;
}

- (NSString *)text{
	return self.value;
}

- (void)setText:(NSString *)text{
	self.value = text;
}

- (NSString *)value{
	return _textField.text;
}

- (void)setValue:(NSString *)value{
	_textField.text = value;
}

- (NSString *)placeholder{
	return _textField.placeholder;
}

- (void)setPlaceholder:(NSString *)value{
	_textField.placeholder = value;
}

- (void)drawRect:(CGRect)rect{
	UIColor *color = self.style.inheritedColor;
	if(color){
		_textField.textColor = color;
	}

	[super drawRect:rect];
}

- (void)updateFrame{
	[super updateFrame];
	_textField.frame = UIEdgeInsetsInsetRect(_textField.frame, self.style.padding);
}

- (void)layout{
	//log_debug(@"%@ %s %@", self.name, __func__, _textField.text);
	[super layout];
	
	UIFont *font = self.style.inheritedFont;
	if(font){
		_textField.font = font;
	}
	_textField.textAlignment = self.style.inheritedNSTextAlign;

	[_textField sizeToFit];
	if(self.style.resizeWidth){
		[self.style setInnerWidth:_textField.frame.size.width];
	}
	if(self.style.resizeHeight){
		//log_debug(@"%f", _textField.frame.size.height);
		[self.style setInnerHeight:_textField.frame.size.height];
	}
}


//#pragma mark - Events

- (void)addEvent:(IEventType)event handler:(void (^)(IEventType, IView *))handler{
	[super addEvent:event handler:handler];
	if(event & IEventChange){
		_changeHandler = handler;
	}
	if(event & IEventReturn){
		_returnHandler = handler;
	}
}

- (BOOL)fireEvent:(IEventType)event{
	if(event == IEventChange && _changeHandler){
		_changeHandler(event, self);
		return YES;
	}
	if(event == IEventReturn && _returnHandler){
		_returnHandler(event, self);
		return YES;
	}
	return [super fireEvent:event];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
	UITextPosition *begin = textField.beginningOfDocument;
	UITextPosition *cursor = [textField positionFromPosition:begin offset:(range.location + string.length)];

	NSString *newStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
	//log_debug(@"old=%@, replace=%@, new=%@ range=%@", self.value, string, newStr, NSStringFromRange(range));
	textField.text = newStr;
	
	if(cursor){
		[textField setSelectedTextRange:[textField textRangeFromPosition:cursor toPosition:cursor]];
	}
	
	[self fireEvent:IEventChange];
	return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	//log_debug(@"%s", __func__);
	[self fireEvent:IEventReturn];
	if(!_returnHandler){
		[textField resignFirstResponder];
	}
	return YES;
}

@end
