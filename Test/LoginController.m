/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "LoginController.h"

@interface LoginController() <UITextFieldDelegate>
@property (strong, nonatomic) IView *cap_div, *iview;
@property (strong, nonatomic) IView *bottomView;
@property (strong, nonatomic) UIButton *captchaView;
@property (strong, nonatomic) UITextField *nameField, *passField, *captchaField;
@property (strong, nonatomic) NSString *captchaCode, *encryptCode;
@end

@implementation LoginController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.title = @"登录";
	
	{
		IView *bottomBar = [[IView alloc] init];
		[bottomBar.style set:@"height: 30; background: #ff3; border-top: 1 solid #ff3;"];
		self.footerView = bottomBar;
	}
	
	// UI stuff
	_iview = [[IView alloc] init];
	[_iview.style set:@"margin: 15;"];
	[self addIViewRow:_iview];
	
	IImage *logo = [IImage imageNamed:@"icon.png"];
	[_iview addSubview:logo style:@"float: center; clear: both; width: auto; height: 80; margin: 10 0;"];
	
	{
		_nameField = [[UITextField alloc] init];
		_nameField.placeholder = @"用户名/手机/邮箱";
		_nameField.delegate = self;
		_nameField.tag = 1;
		_nameField.returnKeyType = UIReturnKeyNext;
		_nameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		UIImageView *ico = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_ic_name.png"]];
		IView *v = [[IView alloc] init];
		[v addSubview:ico style:@"width: 18; height: 24; margin: 8 8 0 0;"];
		[v addSubview:_nameField style:@"width: 100%; height: 40;"];
		[_iview addSubview:v style:@"margin: 15 0; border-bottom: 1 solid #eee;"];
	}
	
	{
		_passField = [[UITextField alloc] init];
		_passField.secureTextEntry = YES;
		_passField.placeholder = @"密码";
		_passField.delegate = self;
		_passField.tag = 2;
		_passField.secureTextEntry = YES;
		UIImageView *ico = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_ic_pass.png"]];
		IView *v = [[IView alloc] init];
		[v addSubview:ico style:@"width: 18; height: 24; margin: 8 8 0 0;"];
		[v addSubview:_passField style:@"width: 100%; height: 40;"];
		[_iview addSubview:v style:@"margin: 15 0; border-bottom: 1 solid #eee;"];
	}
	
	{
		_cap_div = [[IView alloc] init];
		_captchaView = [[UIButton alloc] init];
		[_captchaView setBackgroundImage:[UIImage imageNamed:@"captcha_holder.jpg"] forState:UIControlStateNormal];
		[_cap_div addSubview:_captchaView style:@"float: right; width: 130; height: 56;"];
		
		_captchaField = [[UITextField alloc] init];
		_captchaField.placeholder = @"验证码";
		_captchaField.delegate = self;
		_captchaField.tag = 3;
		_captchaField.returnKeyType = UIReturnKeyGo;
		UIImageView *ico = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_ic_captcha.png"]];
		IView *v = [[IView alloc] init];
		[v addSubview:ico style:@"width: 18; height: 24; margin: 8 8 0 0;"];
		[v addSubview:_captchaField style:@"width: 100%; height: 40;"];
		[_cap_div addSubview:v style:@"margin: 15 0; border-bottom: 1 solid #eee;"];
		
		[_iview addSubview:_cap_div style:@""];
		[_cap_div hide];
	}
	
	IButton *submit = [IButton buttonWithText:@"登  录"];
	[_iview addSubview:submit style:@"clear: both; width: 100%; height: 40; margin: 20 0 0 0; font-size: 18; color: #fff; background: #f36145; border-radius: 5;"];
	
	UIButton *lost_pass = [UIButton buttonWithType:UIButtonTypeSystem];
	lost_pass.titleLabel.font = [UIFont systemFontOfSize:12];
	[lost_pass setTitle:@"忘记密码?" forState:UIControlStateNormal];
	[lost_pass setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[_iview addSubview:lost_pass style:@"clear: both; width: auto; height: 40; margin: 0 0 20 0;"];
	
	
	// Event listeners
	[submit.button addTarget:self action:@selector(onSubmit:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)onSubmit:(UIButton *)btn{
	log_debug(@"submit");
	[_cap_div toggle];
}


@end
