//
//  IStyleRule.m
//  IKit
//
//  Created by ideawu on 8/17/15.
//  Copyright (c) 2015 ideawu. All rights reserved.
//

#import "IStyleRule.h"
#import "IViewInternal.h"
#import "IStyleInternal.h"

@implementation IStyleRule

- (id)init{
	self = [super init];
	_selectors = [[NSMutableArray alloc] init];
	return self;
}

- (void)parseRule:(NSString *)rule{
	NSArray *ps = [rule componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	for(NSString *p in ps){
		NSString *key = [p stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if(key.length == 0){
			continue;
		}
		if([key characterAtIndex:0] == '>'){
			[_selectors addObject:@">"];
			key = [key substringFromIndex:1];
			key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			if(key.length == 0){
				continue;
			}
			[_selectors addObject:key];
		}else{
			[_selectors addObject:key];
		}
	}
}

- (BOOL)selector:(NSString *)selector matchView:(IView *)view{
	if([selector isEqualToString:@"*"]){
		return YES;
	}
	if([selector characterAtIndex:0] == '#'){
		selector = [selector substringFromIndex:1];
		if(view.vid && [view.vid isEqualToString:selector]){
			return YES;
		}
	}
	if([selector characterAtIndex:0] == '.'){
		selector = [selector substringFromIndex:1];
		if([view.style hasClass:selector]){
			return YES;
		}
	}
	// tag name
	if(view.style.tagName && [view.style.tagName isEqualToString:selector]){
		return YES;
	}
	return NO;
}

- (BOOL)match:(IView *)view{
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
