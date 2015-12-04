/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#ifndef IObj_h
#define IObj_h

#import <Foundation/Foundation.h>

@interface IObj : NSObject <NSFastEnumeration>

+ (IObj *)obj;
//+ (IObj *)undefinedObj;
+ (IObj *)nullObj;
+ (IObj *)intObj:(int64_t)val;
+ (IObj *)doubleObj:(double)val;
+ (IObj *)strObj:(NSString *)val;
+ (IObj *)stringObj:(NSString *)val;
+ (IObj *)arrayObj;

- (id)initWithValue:(id)val;
- (id)initWithJSONString:(NSString *)str;
- (id)initWithDictionary:(NSDictionary *)dict;
- (id)initWithArray:(NSArray *)array;

- (IObj* (^)(id key))get;
- (IObj* (^)(id key, id val))set;

- (IObj* (^)(id val))push;
- (IObj* (^)())pop;

- (int)count;

- (BOOL)is_undefined;
- (BOOL)is_null;
- (BOOL)is_int;
- (BOOL)is_double;
- (BOOL)is_string;
- (BOOL)is_array;
- (BOOL)is_object;

- (int64_t)intval;
- (double)doubleval;
- (NSString *)strval;

- (void)intval:(int64_t)val;
- (void)doubleval:(double)val;
- (void)strval:(NSString *)val;

- (void)setIntval:(int64_t)val;
- (void)setDoubleval:(double)val;
- (void)setStrval:(NSString *)val;

@end

#endif
