/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "IDict.h"

@interface IDict(){
	NSMutableDictionary *dict;
	NSMutableArray *list;
}

@end

@implementation IDict

- (id)init{
	self = [super init];
	dict = [[NSMutableDictionary alloc] init];
	list = [[NSMutableArray alloc] init];
	return self;
}

- (void)setObject:(id)anObject forKey:(id)aKey{
	if (![dict objectForKey:aKey]){
		[list addObject:aKey];
	}
	[dict setObject:anObject forKey:aKey];
}

- (void)removeObjectForKey:(id)aKey{
	[dict removeObjectForKey:aKey];
	[list removeObject:aKey];
}

- (NSUInteger)count{
	return [list count];
}

- (id)objectForKey:(id)aKey{
	return [dict objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator{
	return [list objectEnumerator];
}

- (NSEnumerator *)reverseKeyEnumerator{
	return [list reverseObjectEnumerator];
}

NSString *DescriptionForObject(NSObject *obj, id locale, NSUInteger indent){
	NSString *str;
	if ([obj isKindOfClass:[NSString class]]){
		str = (NSString *)obj;
	}else if ([obj respondsToSelector:@selector(descriptionWithLocale:indent:)]){
		str = [(NSDictionary *)obj descriptionWithLocale:locale indent:indent];
	}else if ([obj respondsToSelector:@selector(descriptionWithLocale:)]){
		str = [(NSSet *)obj descriptionWithLocale:locale];
	}else{
		str = [obj description];
	}
	return str;
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level{
	NSMutableString *indentString = [NSMutableString string];
	NSUInteger i, count = level;
	for (i = 0; i < count; i++){
		[indentString appendFormat:@"    "];
	}
	
	NSMutableString *description = [NSMutableString string];
	[description appendFormat:@"%@{\n", indentString];
	for (NSObject *key in list){
		[description appendFormat:@"%@    %@ = %@;\n",
			indentString,
			DescriptionForObject(key, locale, level),
			DescriptionForObject([self objectForKey:key], locale, level)];
	}
	[description appendFormat:@"%@}\n", indentString];
	return description;
}

@end
