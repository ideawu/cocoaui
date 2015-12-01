//
//  TestController.m
//  IKit
//
//  Created by ideawu on 12/1/15.
//  Copyright © 2015 ideawu. All rights reserved.
//

#import "TestController.h"

@interface TestController ()

@end

@implementation TestController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.navigationItem.title = @"Test";

	IView *view = [IView namedView:@"Test"];
	[self addIViewRow:view];
}

@end
