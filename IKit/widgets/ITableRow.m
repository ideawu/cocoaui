/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "ITableRow.h"
#import "ILabel.h"

@interface ITableRow (){
	NSUInteger _numberOfRows;
}
@end

@implementation ITableRow

- (id)init{
	self = [self initWithNumberOfColumns:1];
	return self;
}

- (id)initWithNumberOfColumns:(NSUInteger)num{
	self = [super init];
	[self.style set:@"padding: 5 4;"];
	_numberOfRows = num;
	for(NSUInteger i=num; i>0; i--){
		IView *view = [[IView alloc] init];
		NSString *css = [NSString stringWithFormat:@"width: %f%%;", 1.0/i * 100];
		[self addSubview:view style:css];
	}
	return self;
}

- (void)column:(NSUInteger)column setText:(NSString *)text{
	IView *view = [self.subviews objectAtIndex:column];
	IView *label = view.subviews.firstObject;
	if(label == nil){
		label = [ILabel labelWithText:@"-"];
		[view addSubview:label style:@"width: 100%;"];
	}
	if([label isKindOfClass:[ILabel class]]){
		[(ILabel *)label setText:text];
	}
}

- (IView *)columnView:(NSUInteger)column{
	return [self.subviews objectAtIndex:column];
}

@end
