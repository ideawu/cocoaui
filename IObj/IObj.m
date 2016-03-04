/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "IObj.h"
#import "IDict.h"
#import "Text.h"

typedef enum{
	IObjTypeNull,
	IObjTypeUndefined,
	IObjTypeInt,
	IObjTypeDouble,
	IObjTypeString,
	IObjTypeObject,
	IObjTypeArray,
}IObjType;

@interface IObj (){
	IObjType _type;
	int64_t _ival;
	double _fval;
	NSString *_sval;
	IDict *_dict;
	NSMutableArray *_array;
	
	NSNumber *_iterate_int;
}
@property IObjType type;
@end


@implementation IObj

+ (IObj *)obj{
	IObj *obj = [IObj new];
	obj.type = IObjTypeObject;
	return obj;
}

+ (IObj *)undefinedObj{
	IObj *obj = [IObj new];
	obj.type = IObjTypeUndefined;
	return obj;
}

+ (IObj *)nullObj{
	IObj *obj = [IObj new];
	obj.type = IObjTypeNull;
	return obj;
}

+ (IObj *)intObj:(int64_t)val{
	IObj *obj = [IObj new];
	[obj intval:val];
	return obj;
}

+ (IObj *)doubleObj:(double)val{
	IObj *obj = [IObj new];
	[obj doubleval:val];
	return obj;
}

+ (IObj *)strObj:(NSString *)val{
	IObj *obj = [IObj new];
	[obj strval:val];
	return obj;
}

+ (IObj *)stringObj:(NSString *)val{
	return [IObj strObj:val];
}

+ (IObj *)arrayObj{
	IObj *obj = [IObj new];
	obj.type = IObjTypeArray;
	return obj;
}

- (id)init{
	self = [super init];
	_type = IObjTypeNull;
	return self;
}

- (IDict *)dict{
	if(_dict == nil){
		_dict = [IDict new];
	}
	return _dict;
}

- (NSMutableArray *)array{
	if(_array == nil){
		_array = [NSMutableArray new];
	}
	return _array;
}

- (IObj* (^)(id))get{
	return ^id(id key){
		return [self getAttribute:key];
	};
}

- (IObj* (^)(id, id))set{
	return ^id(id key, id val){
		if(![val isKindOfClass:[IObj class]]){
			val = [[IObj alloc] initWithValue:val];
		}
		[self setAttribute:key value:val];
		return self;
	};
}

- (IObj* (^)(id))push{
	return ^id(id val){
		if(![val isKindOfClass:[IObj class]]){
			val = [[IObj alloc] initWithValue:val];
		}
		[self pushObj:val];
		return self;
	};
}

- (IObj* (^)())pop{
	return ^id(){
		return [self popObj];
	};
}

- (IObj *)getAttribute:(id)key{
	IObj *obj = nil;
	if([self is_array] && [key isKindOfClass:[NSNumber class]]){
		NSUInteger index = [key unsignedIntegerValue];
		if(_array && _array.count > index){
			obj = [_array objectAtIndex:index];
		}
	}else{
		obj = [[self dict] objectForKey:key];
	}
	if(!obj){
		obj = [IObj undefinedObj];
	}
	return obj;
}

- (void)setAttribute:(id)key value:(IObj *)obj{
	_type = IObjTypeObject;
	[[self dict] setObject:obj forKey:key];
}

- (BOOL)isset:(NSString *)key{
	return (_dict && [_dict objectForKey:key]);
}

- (void)pushObj:(IObj *)obj{
	[[self array] addObject:obj];
}

- (IObj *)popObj{
	if(_array && _array.count > 0){
		id ret = [_array lastObject];
		[_array removeLastObject];
		return ret;
	}
	return nil;
}

- (int)count{
	if([self is_array]){
		return _array? (int)_array.count : 0;
	}
	if([self is_object]){
		return _dict? (int)_dict.count : 0;
	}
	return 0;
}

- (BOOL)is_undefined{
	return _type == IObjTypeUndefined;
}

- (BOOL)is_null{
	return _type == IObjTypeNull;
}

- (BOOL)is_int{
	return _type == IObjTypeInt;
}

- (BOOL)is_double{
	return _type == IObjTypeDouble;
}

- (BOOL)is_string{
	return _type == IObjTypeString;
}

- (BOOL)is_object{
	return _type == IObjTypeObject;
}

- (BOOL)is_array{
	return _type == IObjTypeArray;
}

- (int64_t)intval{
	if([self is_int]){
		return _ival;
	}
	if([self is_double]){
		return (int64_t)_fval;
	}
	if([self is_string]){
		return [_sval longLongValue];
	}
	return 0;
}

- (double)doubleval{
	if([self is_int]){
		return _ival;
	}
	if([self is_double]){
		return _fval;
	}
	if([self is_string]){
		return (double)[_sval doubleValue];
	}
	return 0;
}

- (NSString *)strval{
	if([self is_int]){
		return [NSString stringWithFormat:@"%lld", (int64_t)_ival];
	}
	if([self is_double]){
		//NSLog(@"### is_double: %f", _fval);
		return [NSString stringWithFormat:@"%f", _fval];
	}
	if([self is_string]){
		//NSLog(@"is_string: %@", _sval);
		return _sval;
	}
	if([self is_null]){
		return nil;
	}
	return nil;
}

- (void)intval:(int64_t)val{
	_type = IObjTypeInt;
	_ival = val;
}

- (void)doubleval:(double)val{
	_type = IObjTypeDouble;
	_fval = val;
}

- (void)strval:(NSString *)val{
	_type = IObjTypeString;
	_sval = val;
}

- (void)setIntval:(int64_t)val{
	[self intval:val];
}

- (void)setDoubleval:(double)val{
	[self doubleval:val];
}

- (void)setStrval:(NSString *)val{
	[self strval:val];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len{
	if([self is_object]){
		if(!_dict){
			return 0;
		}else{
			return [_dict countByEnumeratingWithState:state objects:buffer count:len];
		}
	}
	if([self is_array]){
		if(!_array || _array.count == 0){
			return 0;
		}
		if(state->state == 0){
			state->mutationsPtr = &state->extra[0];
			state->state = 1;
			_iterate_int = [NSNumber numberWithInt:0];
		}else{
			_iterate_int = [NSNumber numberWithInt:([_iterate_int intValue] + 1)];
		}
		buffer[0] = _iterate_int;
		state->itemsPtr = buffer;
		if([_iterate_int intValue] >= _array.count){
			return 0;
		}else{
			return 1;
		}
	}
	return 0;
}

- (id)initWithValue:(id)res{
	if([res isKindOfClass:[NSDictionary class]]){
		return [self initWithDictionary:res];
	}
	if([res isKindOfClass:[NSArray class]]){
		return [self initWithArray:res];
	}
	if([res isKindOfClass:[IObj class]]){
		return res;
	}
	
	self = [self init];
	if(!res){
		_type = IObjTypeNull;
	}else if([res isKindOfClass:[NSNull class]]){
		//NSLog(@"null: null");
		_type = IObjTypeNull;
	}else if([res isKindOfClass:[NSString class]]){
		//NSLog(@"NSString: %@", res);
		[self strval:res];
	}else if([res isKindOfClass:[NSNumber class]]){
		//NSLog(@"NSNumber: %@", res);
		if (strcmp([res objCType], @encode(float)) == 0 || strcmp([res objCType], @encode(double)) == 0){
			[self doubleval:[res doubleValue]];
		}else{
			[self intval:[res longLongValue]];
		}
	}else{
		_type = IObjTypeNull;
		NSLog(@"unsupported type %@", [res class]);
	}
	return self;
}

- (id)initWithJSONData:(NSData *)data{
	NSError *err = nil;
	id jso = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
	return [self initWithValue:jso];
}

- (id)initWithJSONString:(NSString *)str{
	id res = json_decode(str);
	//NSLog(@"%@", res);
	return [self initWithValue:res];
}

- (id)initWithDictionary:(NSDictionary *)dict{
	self = [self init];
	_type = IObjTypeObject;
	for (NSString *key in dict) {
		id val = dict[key];
		//NSLog(@"%@ => ", key);
		IObj *obj = [[IObj alloc] initWithValue:val];
		[self setAttribute:key value:obj];
	}
	return self;
}

- (id)initWithArray:(NSArray *)array{
	self = [self init];
	_type = IObjTypeArray;
	for (id val in array) {
		IObj *obj = [[IObj alloc] initWithValue:val];
		[self pushObj:obj];
	}
	return self;
}

-(void)_toString:(NSMutableString *)text indent:(int)indent{
	if([self is_int] || [self is_double]){
		[text appendString:[self strval]];
		return;
	}
	if([self is_string]){
		[text appendString:json_encode([self strval])];
		//[text appendString:[self strval]];
		return;
	}
	if([self is_null]){
		[text appendString:@"null"];
		return;
	}
	if([self is_undefined]){
		[text appendString:@"null"];
		return;
	}
	if([self is_object]){
		if(!_dict){
			[text appendString:@"{}"];
			return;
		}
		[text appendFormat:@"{\n"];
		NSUInteger count = _dict.count;
		for (NSString *key in _dict) {
			IObj *val = [self.dict objectForKey:key];
			[text appendFormat:@"%*s\"%@\": ", (indent+1) * 4, "", key];
			[val _toString:text indent:(indent+1)];
			if(--count > 0){
				[text appendString:@",\n"];
			}else{
				[text appendString:@"\n"];
			}
		}
		[text appendFormat:@"%*s}", indent * 4, ""];
		return;
	}
	if([self is_array]){
		if(!_array){
			[text appendString:@"[]"];
			return;
		}
		[text appendFormat:@"[\n"];
		NSUInteger count = _array.count;
		for (IObj *val in _array) {
			if([val is_object] || [val is_array]){
				[text appendFormat:@"%*s", (indent+1) * 4, ""];
			}
			[val _toString:text indent:(indent+1)];
			if(--count > 0){
				[text appendString:@",\n"];
			}else{
				[text appendString:@"\n"];
			}
		}
		[text appendFormat:@"%*s]", indent * 4, ""];
		return;
	}
}

-(NSString *)description{
	NSMutableString* text = [[NSMutableString alloc] init];
	[self _toString:text indent:0];
	return text;
}

@end
