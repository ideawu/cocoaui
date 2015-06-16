/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import <Foundation/Foundation.h>

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

- (void)parseCss:(NSString *)css;
- (void)parseCssFile:(NSString *)filename;

- (NSString *)getStyleById:(NSString *)_id;
- (NSString *)getStyleByTagName:(NSString *)tag;
- (NSString *)getStyleByClass:(NSString *)_class;

// 根据 DOM 节点, 找出包含该节点*前缀*的所有样式选择器
// 这个方法用在如修改了节点的 class 之后, 要先找出所有包含该节点的选择器,
// 然后遍历节点为根的子树, 将样式应用到所有可能的节点上
//- (NSArray *)getSelectorsContainingDomNode:(id)node;

@end
