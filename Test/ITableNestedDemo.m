/*
 Copyright (c) 2017 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.

 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "ITableNestedDemo.h"

@interface ITableNestedDemo (){
	ITable *table;
}
@end

@implementation ITableNestedDemo

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = @"ITableNestedDemo";

	IView *view = [IView namedView:@"ITableNestedDemo"];
	[self addIViewRow:view];

	{
		IView *div = [view getViewById:@"table"];
		table = [[ITable alloc] init];
		for(int i=0; i<20; i+=2){
			NSString *text = [NSString stringWithFormat:@"%d", i];
			ILabel *row = [ILabel labelWithText:text];
			[row.style set:@"height: 42; margin: 0 6; font-size: 15; color: #555; text-align: center; border-bottom: 0.5 solid #eee;"];
			[table addIViewRow:row];
		}
		[div addSubview:table.view style:@"width: 100%; height: 100%"];
	}
}

@end
