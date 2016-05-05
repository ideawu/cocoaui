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

@property (nonatomic) id selectedKey;
@property (readonly, nonatomic) id selectedText;

- (void)addOptionKey:(id)key text:(NSString *)text;

- (void)onSelectKey:(void (^)(id key))callback;

@end
