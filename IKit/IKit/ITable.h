/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#ifndef IKit_ITable_h
#define IKit_ITable_h

#import <UIKit/UIKit.h>
#import "IView.h"

@class IPullRefresh;
@class IRefreshControl;

@interface ITable : UIViewController

@property (nonatomic, readonly) IPullRefresh *pullRefresh;
@property (nonatomic) IRefreshControl *headerRefreshControl;
@property (nonatomic) IRefreshControl *footerRefreshControl;

@property (nonatomic) IView *headerView;
@property (nonatomic) IView *footerView;

- (void)clear;
- (void)reload;

- (void)registerViewClass:(Class)ivClass forTag:(NSString *)tag;

- (void)addIViewRow:(IView *)view;
- (void)addIViewRow:(IView *)view defaultHeight:(CGFloat)height;
- (void)addDataRow:(id)data forTag:(NSString *)tag;
- (void)addDataRow:(id)data forTag:(NSString *)tag defaultHeight:(CGFloat)height;

- (void)prependIViewRow:(IView *)view;
- (void)prependIViewRow:(IView *)view defaultHeight:(CGFloat)height;
- (void)prependDataRow:(id)data forTag:(NSString *)tag;
- (void)prependDataRow:(id)data forTag:(NSString *)tag defaultHeight:(CGFloat)height;

- (void)addDivider:(NSString *)css;
- (void)addDivider:(NSString *)css height:(CGFloat)height;

// @deprecated, use addDivider instead
- (void)addSeparator:(NSString *)css;
- (void)addSeparator:(NSString *)css height:(CGFloat)height;

- (void)onHighlight:(IView *)view;
- (void)onUnhighlight:(IView *)view;
- (void)onClick:(IView *)view;

- (void)onRefresh:(IRefreshControl *)refreshControl state:(IRefreshState)state;
/**
 * Must call this method in onRefresh() when state is IRefreshBegin
 */
- (void)endRefresh:(IRefreshControl *)refreshControl;

@end

#endif
