/*
 Copyright (c) 2014-2015 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "ICssBlock.h"
#import "ICssDecl.h"

@interface ICssBlock(){
	NSMutableArray *_decls;
}
@end

@implementation ICssBlock

- (id)init{
	self = [super init];
	_decls = [[NSMutableArray alloc] init];
	return self;
}

- (NSString *)description{
	NSMutableString *ret = [[NSMutableString alloc] init];
	[ret appendString:@"{ "];
	for(ICssDecl *decl in _decls){
		[ret appendFormat:@"%@: %@; ", decl.key, decl.val];
	}
	[ret appendString:@"}"];
	return ret;
}

+ (ICssBlock *)fromCss:(NSString *)css baseUrl:(NSString *)baseUrl{
	ICssBlock *ret = [[ICssBlock alloc] init];
	ret.baseUrl = baseUrl;
	if(!css){
		return ret;
	}
	
#define PARSE_KEY  0
#define PARSE_VAL  1
	
	NSString *k, *v;
	NSUInteger spos = 0;
	NSUInteger epos = 0;
	int state = PARSE_KEY;
	while(epos <= css.length){
		unichar c;
		if(epos == css.length){
			c = '\0';
		}else{
			c = [css characterAtIndex:epos];
		}
		epos ++;
		
		switch(c){
			case ':':{
				if(state == PARSE_KEY){
					NSRange range = NSMakeRange(spos, epos - spos - 1);
					k = [css substringWithRange:range];
					spos = epos;
					state = PARSE_VAL;
				}
				break;
			}
			case '\0':
			case ';':{
				if(state == PARSE_VAL){
					NSRange range = NSMakeRange(spos, epos - spos - 1);
					v = [css substringWithRange:range];
					spos = epos;
					state = PARSE_KEY;
					
					if(k && v){
						k = [k stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
						v = [v stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
						k = [k lowercaseString];
						if(![k isEqualToString:@"background"]){
							v = [v lowercaseString];
						}
						//NSLog(@"%@: %@;", k, v);
						if(k.length > 0 && v.length > 0){
							[ret addKey:k value:v];
						}
					}
					k = nil;
					v = nil;
				}else{
					// syntax error
					k = nil;
					v = nil;
				}
				break;
			}
			case '(':{
				NSRange srange = NSMakeRange(epos, css.length - epos);
				NSRange range = [css rangeOfString:@")" options:NSLiteralSearch range:srange];
				if(range.length > 0){
					epos = range.location + 1;
				}
				break;
			}
			case '\"':{
				NSRange srange = NSMakeRange(epos, css.length - epos);
				NSRange range = [css rangeOfString:@"\"" options:NSLiteralSearch range:srange];
				if(range.length > 0){
					epos = range.location + 1;
				}
				break;
			}
			case '\'':{
				NSRange srange = NSMakeRange(epos, css.length - epos);
				NSRange range = [css rangeOfString:@"\'" options:NSLiteralSearch range:srange];
				if(range.length > 0){
					epos = range.location + 1;
				}
				break;
			}
		}
	}
	
	/*
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
	*/
	return ret;
}

- (void)addDecl:(ICssDecl *)decl{
	[self removeKey:decl.key];
	[_decls addObject:decl];
}

- (void)addKey:(NSString *)key value:(NSString *)val{
	ICssDecl *decl = [[ICssDecl alloc] init];
	decl.key = key;
	decl.val = val;
	[self addDecl:decl];
}

- (void)removeKey:(NSString *)key{
	NSUInteger idx = 0;
	for(ICssDecl *decl in _decls){
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
	for(ICssDecl *decl in _decls){
		if([decl.key isEqualToString:key]){
			return YES;
		}
	}
	return NO;
}

@end
