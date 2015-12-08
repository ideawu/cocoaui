/*
 Copyright (c) 2014-2015 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import <Foundation/Foundation.h>

@class ICssDecl;

@interface ICssBlock : NSObject

@property (nonatomic) NSString *baseUrl;
@property (nonatomic, readonly) NSArray *decls;

- (void)addDecl:(ICssDecl *)decl;
- (void)addKey:(NSString *)key value:(NSString *)val;
- (void)addClass:(NSString *)clz;
- (void)removeClass:(NSString *)clz;
- (BOOL)hasClass:(NSString *)clz;

+ (ICssBlock *)fromCss:(NSString *)css baseUrl:(NSString *)baseUrl;

@end
