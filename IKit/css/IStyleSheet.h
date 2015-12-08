/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import <Foundation/Foundation.h>

@class IView;

/*
 CSS(级联样式表) 的主要特性:
 1. 级联(Cascade, Selector)
 2. 样式(Style)
 3. 继承(Inherit)
 
 其它:
 1. Group Style(如 a, b, c{})
*/

// @see http://www.w3.org/TR/2011/REC-CSS2-20110607/selector.html

@interface IStyleSheet : NSObject

@property (nonatomic, readonly) NSArray *rules;

- (void)mergeWithStyleSheet:(IStyleSheet *)sheet;
- (void)parseCss:(NSString *)css baseUrl:(NSString *)baseUrl;

@end
