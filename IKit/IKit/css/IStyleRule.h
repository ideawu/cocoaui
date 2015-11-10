//
//  IStyleRule.h
//  IKit
//
//  Created by ideawu on 8/17/15.
//  Copyright (c) 2015 ideawu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IView;
@class IStyleBlock;

@interface IStyleRule : NSObject

@property (nonatomic, readonly) NSMutableArray *selectors;
@property (nonatomic, readonly) IStyleBlock *declBlock;
@property (nonatomic, readonly) NSString *baseUrl;

- (void)parseRule:(NSString *)rule css:(NSString *)css baseUrl:(NSString *)baseUrl;
- (BOOL)match:(IView *)view;

@end
