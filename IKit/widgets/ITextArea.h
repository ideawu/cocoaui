/*
 Copyright (c) 2014-2016 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "IView.h"

@interface ITextArea : IView

@property (nonatomic, readonly) UITextView *textView;
@property (nonatomic) NSString *value;
@property (nonatomic) NSString *text; // alias of value

@end
