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

- (void)layout{
	//log_debug(@"%@ %s %@", self.name, __func__, _textField.text);
	
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
		//NSLog(@"%f", _textField.frame.size.height);
		[self.style setInnerHeight:_textField.frame.size.height];
	}

	// 先做自定义布局, 再进行父类布局
	[super layout];

	// 根据 padding 拉伸 UITextField
	// TODO: 应该再设置 UITextField 的 padding 属性
	CGRect frame = _textField.frame;
	frame.origin.x += self.style.padding.left;
	frame.origin.y += self.style.padding.top;
	frame.size.width -= self.style.padding.left + self.style.padding.right;
	frame.size.height -= self.style.padding.top + self.style.padding.bottom;
	_textField.frame = frame;
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
	//NSLog(@"old=%@, replace=%@, new=%@ range=%@", self.value, string, newStr, NSStringFromRange(range));
	textField.text = newStr;
	
	if(cursor){
		[textField setSelectedTextRange:[textField textRangeFromPosition:cursor toPosition:cursor]];
	}
	
	[self fireEvent:IEventChange];
	return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	//NSLog(@"%s", __func__);
	[self fireEvent:IEventReturn];
	if(!_returnHandler){
		[textField resignFirstResponder];
	}
	return YES;
}

@end
