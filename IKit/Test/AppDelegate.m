/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "AppDelegate.h"
#import "IKit/IKit.h"
#import "LoginController.h"
#import "ITableFixedHeaderDemo.h"
#import "IPopoverDemo.h"
#import "ITablePullRefreshDemo.h"
#import "HomeController.h"

@interface AppDelegate (){
	ITable *table;
}
@property IView *iview;
@property IView *v3;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	//UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:table];
	UINavigationController *nav = [[UINavigationController alloc] init];
	//[nav setNavigationBarHidden:YES];
	
	//TableViewController *table = [[TableViewController alloc] initWithStyle:UITableViewStyleGrouped];
	table = [[ITable alloc] init];
	table.navigationItem.title = @"Table";
	//NSLog(@"%@", table.tableView);
	//table.tableView.backgroundColor = [UIColor blackColor];
	
	self.window.rootViewController = nav;
	[self.window makeKeyAndVisible];

	/*
	IView *v4 = [[IView alloc] init];
	[v4 addSubview:make_btn(@"Btn10", 53, 40) style:@"float: left;"];
	[self.iview addSubview:v4 style:@"margin: 10 0; float: center; background: #fff; border-bottom: 1px solid #aaa;"];
	 */
	
	int yn = 1;
	if(yn){
		UIViewController *controller = [[HomeController alloc] init];
		[nav pushViewController:controller animated:YES];
		return YES;
	}else{
		//[nav pushViewController:table animated:YES];
		ITable *page = [[ITable alloc] init];
		for(int i=0; i<100; i++){
			[page addDataRow:nil forTag:@"item" defaultHeight:0];
		}
		[nav pushViewController:page animated:YES];
	}
	
	self.iview = [[IView alloc] init];
	[self.iview.style set:@"margin: 10; border: 3px solid #33f; background: #eee; border-left: 5px dashed #f33; border-radius: 12;"];
	[table addIViewRow:self.iview];

	
	[self test];
	return YES;
}

static UIButton* make_btn(NSString *text, CGFloat w, CGFloat h){
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
	btn.frame = CGRectMake(0, 0, w, h);
	[btn setTitle:text forState:UIControlStateNormal];
	[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	btn.backgroundColor = [UIColor colorWithRed:0.953 green:0.38 blue:0.271 alpha:1] /*#f36145*/;
	[btn.layer setBorderColor:[[UIColor brownColor] CGColor]];
	[btn.layer setBorderWidth:1];
	return btn;
}

- (void)add_one{
	int w = 12 * (arc4random() % 6 + 2);
	int h = 7 * (arc4random() % 9 + 2);
	[self.iview addSubview:make_btn(@"New", w, h)];
	[self.iview setNeedsLayout];
}

- (void)zoom:(UIButton *)btn{
	//IView *view = self.v3;
	IView *view = self.iview;
	if([btn.titleLabel.text isEqualToString:@"+"]){
		//view.style.width += 30;
		[self.v3 show];
	}else{
		//view.style.width -= 30;
		[self.v3 hide];
	}
	[view setNeedsLayout];
}

- (void)test{
//	[self.iview addSubview:make_btn(@"Btn1", 170, 50) style:@"clear: left;"];
//	[self.iview addSubview:make_btn(@"Btn2", 85, 30) style:@"width: 30%; background: #333;"];
//	[self.iview addSubview:make_btn(@"Btn3", 85, 25) style:@"width: 100%;"];

	UIButton *btn0 = make_btn(@"+", 35, 35);
	[btn0 addTarget:self action:@selector(zoom:) forControlEvents:UIControlEventTouchUpInside];
	[self.iview addSubview:btn0 style:@"clear: left;"];
	
	UIButton *btn1 = make_btn(@"-", 35, 35);
	[btn1 addTarget:self action:@selector(zoom:) forControlEvents:UIControlEventTouchUpInside];
	[self.iview addSubview:btn1 style:@"float: right;"];
	
	UIButton *btn2 = make_btn(@"添加新节点", 120, 35);
	[btn2 addTarget:self action:@selector(add_one) forControlEvents:UIControlEventTouchUpInside];
	[self.iview addSubview:btn2 style:@"width: 100%;"];

	[self.iview addSubview:make_btn(@"Btn6", 61, 30)];
	[self.iview addSubview:make_btn(@"Btn7", 50, 50)];
	
	UITextField *text = [[UITextField alloc] init];
	[self.iview addSubview:text style:@"clear: both; margin: 8px; width: 100%; height: 30; border: 1px solid #ccc; border-radius: 5;"];
	
	
	IView *v3 = [[IView alloc] init];
	
	UIButton *btn3 = make_btn(@"节点", 153, 35);
	self.v3 = [IView viewWithUIView:btn3];
	
	[v3 addSubview:self.v3];
	[v3 addSubview:make_btn(@"Btn8", 71, 40)];
	[v3 addSubview:make_btn(@"Btn9", 80, 30)];
	[v3 addSubview:make_btn(@"Btn81", 60, 45)];
	[v3 addSubview:make_btn(@"Btn82", 50, 45)];
	[v3 addSubview:make_btn(@"Btn83", 80, 45)];
	//[self.iview addSubview:v3 style:@"background: #ddd; border: 1px solid #ff3; border-radius: 10;"];
	
	self.v3 = v3;
	
	IView *v4 = [[IView alloc] init];
	[v4 addSubview:make_btn(@"Btn10", 53, 40) style:@"float: left;"];
	[self.iview addSubview:v4 style:@"margin: 10 0; float: center; background: #fff; border-bottom: 1px solid #aaa;"];
	
	[self.iview addSubview:make_btn(@"Btn8", 72, 40)];
	[self.iview addSubview:make_btn(@"Btn9", 120, 30)];
	//[self.iview addSubview:[IView new] style:@"width: 100%; height: 130;"];
	[self.iview addSubview:make_btn(@"Test", 100, 10) style:@"float: center; clear: both; margin: 10; width: 100%; height: 30;"];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
