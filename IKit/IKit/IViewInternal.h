/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#ifndef IKit_IViewInternal_h
#define IKit_IViewInternal_h

#import "IView.h"

@class IRow;
@class ICell;
@class IViewLoader;

@interface IView ()

@property (nonatomic) IViewLoader *viewLoader;

// 故意制造内存泄露
#ifdef DEBUG
@property (nonatomic) IView *parent;
#else
@property (nonatomic, weak) IView *parent;
#endif
@property (nonatomic, readonly) NSArray *subs;

@property (nonatomic, weak) IRow *row;
@property (nonatomic, weak) ICell *cell;
@property (nonatomic) int seq;
@property (nonatomic) int level;
@property (nonatomic) NSString *vid;


@property (readonly) void (^highlightHandler)(IEventType, IView *);
@property (readonly) void (^unhighlightHandler)(IEventType, IView *);
@property (readonly) void (^clickHandler)(IEventType, IView *);


- (void)addUIView:(UIView *)view;

- (NSString *)name;
- (void)layout;
- (void)updateFrame;

- (void)fireHighlightEvent;
- (void)fireUnhighlightEvent;
- (void)fireClickEvent;

@end

#endif
