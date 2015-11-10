//
//  IStyleRule.h
//  IKit
//
//  Created by ideawu on 8/17/15.
//  Copyright (c) 2015 ideawu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IView;

@interface IStyleRule : NSObject

@property (nonatomic) NSMutableArray *selectors;
@property (nonatomic) NSString *css;
@property (nonatomic) NSString *baseUrl;

- (void)parseRule:(NSString *)rule;
- (BOOL)match:(IView *)view;

@end
