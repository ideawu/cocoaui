//
//  IStyleDecl.m
//  IKit
//
//  Created by ideawu on 11/10/15.
//  Copyright © 2015 ideawu. All rights reserved.
//

#import "IStyleDecl.h"
#import "IStyleInternal.h"

@implementation IStyleDecl

- (BOOL)isId{
	return [_key characterAtIndex:0] == '#';
}
- (BOOL)isClass{
	return [_key characterAtIndex:0] == '.';
}
- (BOOL)isTagName{
	return [_key characterAtIndex:0] == '@';
}

@end


@implementation IStyleDeclBlock

- (id)init{
	self = [super init];
	_decls = [[NSMutableArray alloc] init];
	return self;
}

+ (IStyleDeclBlock *)fromCss:(NSString *)css baseUrl:(NSString *)baseUrl{
	IStyleDeclBlock *ret = [[IStyleDeclBlock alloc] init];
	ret.baseUrl = baseUrl;
	if(!css){
		return ret;
	}
	css = [css stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSArray *kvs = [css componentsSeparatedByString:@";"];
	for(NSString *s in kvs){
		NSArray *kv = [s componentsSeparatedByString:@":"];
		if(kv.count != 2){
			continue;
		}
		NSString *k = [kv objectAtIndex:0];
		NSString *v = [kv objectAtIndex:1];
		k = [k stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		v = [v stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		k = [k lowercaseString];
		if(![k isEqualToString:@"background"]){
			v = [v lowercaseString];
		}
		[ret addKey:k value:v];
	}
	return ret;
}

- (void)addDecl:(IStyleDecl *)decl{
	[self removeKey:decl.key];
	[_decls addObject:decl];
}

- (void)addKey:(NSString *)key value:(NSString *)val{
	IStyleDecl *decl = [[IStyleDecl alloc] init];
	decl.key = key;
	decl.val = val;
	[self addDecl:decl];
}

- (void)removeKey:(NSString *)key{
	NSUInteger idx = 0;
	for(IStyleDecl *decl in _decls){
		if([decl.key isEqualToString:key]){
			[_decls removeObjectAtIndex:idx];
			break;
		}
		idx ++;
	}
}

- (void)addClass:(NSString *)clz{
	NSString *key = [NSString stringWithFormat:@".%@", clz];
	[self addKey:key value:key];
}

- (void)removeClass:(NSString *)clz{
	NSString *key = [NSString stringWithFormat:@".%@", clz];
	[self removeKey:key];
}

- (BOOL)hasClass:(NSString *)clz{
	NSString *key = [NSString stringWithFormat:@".%@", clz];
	for(IStyleDecl *decl in _decls){
		if([decl.key isEqualToString:key]){
			return YES;
		}
	}
	return NO;
}

@end
