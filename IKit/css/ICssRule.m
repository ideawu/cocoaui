/*
 Copyright (c) 2014-2015 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "ICssRule.h"
#import "IViewInternal.h"
#import "IStyleInternal.h"
#import "ICssBlock.h"

@interface ICssRule()
@property (nonatomic, readonly) NSMutableArray *selectors;
@end

@implementation ICssRule

- (id)init{
	self = [super init];
	return self;
}

- (NSString *)description{
	NSMutableString *ret = [[NSMutableString alloc] init];
	[ret appendString:[_selectors componentsJoinedByString:@" "]];
	[ret appendString:_declBlock.description];
	return ret;
}

+ (ICssRule *)fromSelector:(NSString *)sel css:(NSString *)css baseUrl:(NSString *)baseUrl{
	ICssRule *ret = [[ICssRule alloc] init];
	if(![ret parseSelector:sel css:css baseUrl:baseUrl]){
		return nil;
	}
	return ret;
}

- (BOOL)parseSelector:(NSString *)sel css:(NSString *)css baseUrl:(NSString *)baseUrl{
	[self parseSelector:sel];
	if(_selectors.count == 0){
		return NO;
	}
	_declBlock = [ICssBlock fromCss:css baseUrl:baseUrl];
	if(_declBlock.decls.count == 0){
		return NO;
	}
	return YES;
}

- (void)parseSelector:(NSString *)sel{
	_weight = 0;
	_selectors = [[NSMutableArray alloc] init];

	sel = [sel stringByReplacingOccurrencesOfString:@">" withString:@" > "];
	sel = [sel stringByReplacingOccurrencesOfString:@":" withString:@" : "];
	NSArray *ps = [sel componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	for(NSString *p in ps){
		NSString *key = [p stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if(key.length == 0){
			continue;
		}
		if(_selectors.count > 0 && [_selectors.lastObject isEqualToString:@":"]){
			[_selectors removeLastObject];
			if(_selectors.lastObject){
				key = [NSString stringWithFormat:@"%@:%@", _selectors.lastObject, key];
				[_selectors removeLastObject];
			}
		}
		unichar c = [key characterAtIndex:0];
		switch(c){
			case '#': // ID
				_weight += 1 * 1000 * 1000;
				break;
			case ':': // Class
			case '.': // Class
				_weight += 1 * 1000;
				key = [key lowercaseString];
				break;
			default: // Tag
				_weight += 1;
				key = [key lowercaseString];
				break;
		}
		[_selectors addObject:key];
	}
}

- (BOOL)selector:(NSString *)selector matchView:(IView *)view{
	if([selector isEqualToString:@"*"]){
		return YES;
	}else if([selector rangeOfString:@":"].length > 0){
		if(view.event == IEventHighlight){
			NSArray *ps = [selector componentsSeparatedByString:@":"];
			if(![self selector:ps[0] matchView:view]){
				return NO;
			}
			if([ps[1] isEqualToString:@"hover"] || [ps[1] isEqualToString:@"active"]){
				return YES;
			}
		}
		return NO;
	}else if([selector characterAtIndex:0] == '#'){
		if(view.vid && [view.vid isEqualToString:[selector substringFromIndex:1]]){
			return YES;
		}
	}else if([selector characterAtIndex:0] == '.'){
		if([view.style hasClass:[selector substringFromIndex:1]]){
			return YES;
		}
	}else if(view.style.tagName && [view.style.tagName isEqualToString:selector]){
		return YES;
	}
	return NO;
}

- (BOOL)containsPseudoClass{
	for(NSString *selector in _selectors){
		if([selector rangeOfString:@":"].length > 0){
			return YES;
		}
	}
	return NO;
}

- (BOOL)matchView:(IView *)view{
	IView *curr_view = view;
	NSEnumerator *iter = [_selectors reverseObjectEnumerator];
	
	// key selector
	if(![self selector:[iter nextObject] matchView:curr_view]){
		return NO;
	}
	//NSLog(@"selector: %@, tag: %@", curr_view.style.tagName, curr_view.parent.style.tagName);
	
	NSString *selector;
	while(1){
		curr_view = curr_view.parent;
		
		selector = [iter nextObject];
		if(!selector){
			return YES;
		}
		if(!curr_view){
			return NO;
		}

		if([selector isEqualToString:@">"]){
			selector = [iter nextObject];
			if(!selector || ![self selector:selector matchView:curr_view]){
				return NO;
			}
			continue;
		}

		while(1){
			if([self selector:selector matchView:curr_view]){
				break;
			}
			curr_view = curr_view.parent;
			if(!curr_view){
				return NO;
			}
		}
	}
	return NO;
}

@end
