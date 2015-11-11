//
//  IStyleDecl.h
//  IKit
//
//  Created by ideawu on 11/10/15.
//  Copyright © 2015 ideawu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IStyleDecl : NSObject

@property (nonatomic) NSString *key;
@property (nonatomic) NSString *val;

@end


@interface IStyleDeclBlock : NSObject

@property (nonatomic) NSString *baseUrl;
@property (nonatomic, readonly) NSMutableArray *decls;

- (void)addDecl:(IStyleDecl *)decl;
- (void)addKey:(NSString *)key value:(NSString *)val;
- (void)addClass:(NSString *)clz;
- (void)removeClass:(NSString *)clz;
- (BOOL)hasClass:(NSString *)clz;

+ (IStyleDeclBlock *)fromCss:(NSString *)css baseUrl:(NSString *)baseUrl;

@end


