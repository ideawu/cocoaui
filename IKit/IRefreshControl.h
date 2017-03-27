/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#ifndef IKit_IRefreshControl_h
#define IKit_IRefreshControl_h

#import "IView.h"

typedef enum{
	IRefreshTriggerPull,
	IRefreshTriggerScroll,
}IRefreshTriggerMode;

@class IPullRefresh;

@interface IRefreshControl : IView

@property (nonatomic, weak) IPullRefresh *pullRefresh;
@property (nonatomic) IRefreshTriggerMode triggerMode;

@property (nonatomic, readonly) IView *indicatorView;
@property (nonatomic, readonly) IView *contentView;
@property (nonatomic) IRefreshState state;

- (void)setStateTextForNone:(NSString *)none maybe:(NSString *)maybe begin:(NSString *)begin;

/**
 * Programmatically trigger a refresh event.
 */
- (void)beginRefresh;
/**
 * Must be called to end refresh state.
 */
- (void)endRefresh;

@end

#endif
