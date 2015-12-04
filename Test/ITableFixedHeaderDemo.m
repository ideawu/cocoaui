//
//  ITableFixedHeaderDemo.m
//  IKit
/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "ITableFixedHeaderDemo.h"

@implementation ITableFixedHeaderDemo

- (id)init{
	self = [super init];
	self.navigationItem.title = @"ITableFixedHeaderDemo";
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];

	{
		ITableRow *headerRow = [[ITableRow alloc] initWithNumberOfColumns:3];
		[headerRow.style set:@"height: 30; font-weight: bold; text-align: center; background: #6cf;"];
		[headerRow column:0 setText:@"Id"];
		[headerRow column:1 setText:@"Name"];
		[headerRow column:2 setText:@"Age"];
		self.headerView = headerRow;
	}
	
	for(int i=0; i<20; i++){
		ITableRow *row = [[ITableRow alloc] initWithNumberOfColumns:3];
		[row.style set:@"height: 40; text-align: center; border-bottom: 1 solid #eee; background: #fff;"];
		[row column:0 setText:[NSString stringWithFormat:@"%d", i+1]];
		[row column:1 setText:[NSString stringWithFormat:@"name-%d", i+1]];
		[row column:2 setText:[NSString stringWithFormat:@"%d", rand()%50+1]];
		[self addIViewRow:row];
	}
	
	return self;
}

@end
