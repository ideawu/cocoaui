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
#import "IStyleSheet.h"

@class ICell;
@class IViewLoader;

@interface IView ()

@property (nonatomic) IViewLoader *viewLoader;

@property (nonatomic, weak) IView *parent;
@property (nonatomic, readonly) NSMutableArray *subs;

@property (nonatomic, weak) ICell *cell;
@property (nonatomic) int seq;
@property (nonatomic) int level;
@property (nonatomic) NSString *vid;


@property (readonly) void (^highlightHandler)(IEventType, IView *);
@property (readonly) void (^unhighlightHandler)(IEventType, IView *);
@property (readonly) void (^clickHandler)(IEventType, IView *);
@property (nonatomic) IEventType event;

- (void)setDataInternal:(id)data;
- (void)addUIView:(UIView *)view;

- (NSString *)name;
- (void)layout;
- (void)updateFrame;

- (void)fireHighlightEvent;
- (void)fireUnhighlightEvent;
- (void)fireClickEvent;

- (IStyleSheet *)inheritedStyleSheet;

@end

#endif
