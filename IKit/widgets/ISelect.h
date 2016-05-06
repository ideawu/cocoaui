/*
 Copyright (c) 2014-2016 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "IView.h"

@class ILabel;

@interface ISelect : IView

@property (readonly, nonatomic) ILabel *label;
@property (readonly, nonatomic) ILabel *arrow;

@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic) NSString *selectedKey;
@property (readonly, nonatomic) NSString *selectedText;

- (void)addOptionKey:(NSString *)key text:(NSString *)text;

- (void)onSelectKey:(void (^)(NSString *key))callback;

@end
