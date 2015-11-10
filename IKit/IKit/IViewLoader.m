/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import <Foundation/NSXMLParser.h>
#import "IViewLoader.h"
#import "IViewInternal.h"
#import "IStyleInternal.h"
#import "ILabel.h"
#import "IInput.h"
#import "IButton.h"
#import "ISwitch.h"
#import "IImage.h"
#import "IStyleSheet.h"
#import "Text.h"
#import "IStyleInternal.h"

#define DTHTML 0

typedef enum{
	ParseInit,
	ParseHtml,
	ParseHead,
	ParseBody,
	ParseView,
}ParseState;

#if DTHTML
#import "DTHTMLParser.h"
@interface IViewLoader () <DTHTMLParserDelegate>{
#else
@interface IViewLoader () <NSXMLParserDelegate>{
#endif
	ParseState state;
	IView *currentView;
	IStyleSheet *_styleSheet;
	NSString *_tag;
	NSMutableArray *parse_stack;
	NSDictionary *_attributeDict;
	BOOL _ignore;
	NSMutableString *_text;
}
@property (nonatomic) NSMutableDictionary *viewsById;
@property (nonatomic) NSMutableArray *rootViews;
@end

@implementation IViewLoader
	
+ (IView *)viewFromXml:(NSString *)xml{
	IViewLoader *viewLoader = [[IViewLoader alloc] init];
	IView *view = [viewLoader loadXml:xml];
	return view;
}

	
+ (void)loadUrl:(NSString *)url callback:(void (^)(IView *view))callback{
	NSRange r1 = [url rangeOfString:@"://"];
	NSRange r2 = [url rangeOfString:@"/" options:NSBackwardsSearch];
	NSString *base;
	if(r2.location < r1.location + r1.length){
		base = [url stringByAppendingString:@"/"];
	}else{
		base = [url substringToIndex:r2.location + 1];
	}
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setHTTPMethod:@"GET"];
	[request setURL:[NSURL URLWithString:url]];
	[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *urlresp, NSData *data, NSError *error){
		NSString *xml = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		IViewLoader *viewLoader = [[IViewLoader alloc] init];
		viewLoader.baseUrl = base;
		IView *view = [viewLoader loadXml:xml];
		callback(view);
	}];
}

- (id)init{
	self = [super init];
	return self;
}

- (IStyleSheet *)styleSheet{
	return _styleSheet;
}

- (IView *)loadXml:(NSString *)str{
	//log_trace(@"%@", str);
	state = ParseInit;
	currentView = nil;
	_styleSheet = [[IStyleSheet alloc] init];
	
	_ignore = NO;
	_rootViews = [[NSMutableArray alloc] init];
	parse_stack = [[NSMutableArray alloc] init];
	_viewsById = [[NSMutableDictionary alloc] init];
	_text = [[NSMutableString alloc] init];
	
	NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
#if DTHTML
	DTHTMLParser *parser = [[DTHTMLParser alloc] initWithData:data encoding:NSUTF8StringEncoding];
#else
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
#endif
	parser.delegate = self;
	BOOL ret = [parser parse];
	if(ret == NO){
		log_trace(@"parse xml error: %@", [parser parserError]);
	}
	log_trace(@"views: %d", (int)_rootViews.count);
	
	IView *retView;
	if(_rootViews.count == 1){
		retView = [_rootViews objectAtIndex:0];
	}else{
		retView = [[IView alloc] init];
		for(IView *v in _rootViews){
			[retView addSubview:v];
		}
	}
	// 未来每一个 view 都应指向 viewLoader, 当 view 被从节点树中删除时, 也要从相应的 viewLoader 中删除
	retView.viewLoader = self;
	
	// 避免循环引用
	if(retView.vid){
		[_viewsById removeObjectForKey:retView.vid];
	}
	_rootViews = nil;
	parse_stack = nil;
	currentView = nil;
	_text = nil;
	
	// 之前设置的 class 属性并没有立即生效
	[retView.style applyAllCss];
	return retView;
}

- (IView *)getViewById:(NSString *)id_{
	IView *view =[ _viewsById objectForKey:id_];
	return view;
}

- (BOOL)parseIfIsCSS:(NSString *)tagName attributes:(NSDictionary *)attributeDict{
	BOOL ret = NO;
	NSString *src = nil;
	if([_tag isEqualToString:@"style"]){
		ret = YES;
		src = [attributeDict objectForKey:@"src"];
	}else if([_tag isEqualToString:@"link"]){
		ret = YES;
		NSString *type = [attributeDict objectForKey:@"type"];
		if([type isEqualToString:@"text/css"]){
			src = [attributeDict objectForKey:@"href"];
		}
	}
	if(src){
		[_styleSheet parseCssFile:src baseUrl:_baseUrl];
	}
	return ret;
}

#if DTHTML
- (void)parser:(DTHTMLParser *)parser didStartElement:(NSString *)tagName attributes:(NSDictionary *)attributeDict{
#else
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)tagName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
#endif
	tagName = [tagName lowercaseString];
	NSString *last_tag = _tag;
	_tag = tagName;
	_attributeDict = attributeDict;

	if([self parseIfIsCSS:tagName attributes:attributeDict]){
		return;
	}
	if([_tag isEqualToString:@"script"]){
		_ignore = YES;
		return;
	}
	if(state != ParseView){
		if([tagName isEqualToString:@"body"]){
			state = ParseView;
			return;
		}
		if([tagName isEqualToString:@"view"] || [tagName isEqualToString:@"div"]){
			state = ParseView;
		}else{
			return;
		}
	}
	[self parser:parser elementChanged:tagName];
	
	// 兼容不闭合的标签
	static NSArray *auto_close_tags = nil;
	if(auto_close_tags == nil){
		auto_close_tags = @[@"br", @"hr", @"img", @"meta", @"link"];
	}
	if([auto_close_tags indexOfObject:last_tag] != NSNotFound){
#if DTHTML
		[self parser:parser didEndElement:last_tag];
#else
		[self parser:parser didEndElement:last_tag namespaceURI:nil qualifiedName:nil];
#endif
	}

	//log_trace(@"<%@> %d", tagName, (int)parse_stack.count);

	IView *view;
	NSString *defaultCss = nil;
	if([tagName isEqualToString:@"view"] || [tagName isEqualToString:@"div"]){
		view = [[IView alloc] init];
	}else if([tagName isEqualToString:@"img"]){
		NSString *src = [attributeDict objectForKey:@"src"];
		IImage *img = [[IImage alloc] init];
		if(src){
			if(_baseUrl){
				src = [_baseUrl stringByAppendingString:src];
			}
			img.src = src;
		}
		view = img;
	}else if([tagName isEqualToString:@"input"]){
		NSString *placeholder = [attributeDict objectForKey:@"placeholder"];
		NSString *type = [attributeDict objectForKey:@"type"];
		NSString *value = [attributeDict objectForKey:@"value"];
		IInput *input = [[IInput alloc] init];
		if(placeholder){
			input.placeholder = placeholder;
		}
		if(type && [type isEqualToString:@"password"]){
			input.isPasswordInput = YES;
		}
		if(value){
			input.value = value;
		}
		view = input;
	}else if([tagName isEqualToString:@"button"]){
		view = [[IButton alloc] init];
	}else if([tagName isEqualToString:@"switch"]){
		view = [[ISwitch alloc] init];
	}else if([tagName isEqualToString:@"h1"]){
		view = [[ILabel alloc] init];
		defaultCss = @"clear: both; font-weight: bold; width: 100%; margin: 12 0; font-size: 240%;";
	}else if([tagName isEqualToString:@"h2"]){
		view = [[ILabel alloc] init];
		defaultCss = @"clear: both; font-weight: bold; width: 100%; margin: 10 0; font-size: 180%;";
	}else if([tagName isEqualToString:@"h3"]){
		view = [[ILabel alloc] init];
		defaultCss = @"clear: both; font-weight: bold; width: 100%; margin: 10 0; font-size: 140%;";
	}else if([tagName isEqualToString:@"h4"]){
		view = [[ILabel alloc] init];
		defaultCss = @"clear: both; font-weight: bold; width: 100%; margin: 8 0; font-size: 110%;";
	}else if([tagName isEqualToString:@"h5"]){
		view = [[ILabel alloc] init];
		defaultCss = @"clear: both; font-weight: bold; width: 100%; margin: 6 0; font-size: 100%;";
	}else if([tagName isEqualToString:@"hr"]){
		view = [[IView alloc] init];
		defaultCss = @"clear: both; margin: 12 0; width: 100%; height: 1; background: #000;";
	}else if([tagName isEqualToString:@"br"]){
		static NSString *br_s = nil;
		if(!br_s){
			br_s = [NSString stringWithFormat:@"clear: both; width: 100%%; height: %f;", [IStyle normalFontSize]];
		}
		view = [[IView alloc] init];
		defaultCss = br_s;
	}else if([tagName isEqualToString:@"li"]){
		view = [[ILabel alloc] init];
		defaultCss = @"clear: both; margin: 4 0; width: 100%;";
	}else if([tagName isEqualToString:@"p"]){
		view = [[ILabel alloc] init];
		defaultCss = @"clear: both; margin: 12 0; width: 100%;";
	}else if([tagName isEqualToString:@"a"]){
		view = [[ILabel alloc] init];
		defaultCss = @"color: #00f;";
	}else if([tagName isEqualToString:@"b"]){
		view = [[ILabel alloc] init];
		defaultCss = @"font-weight: bold;";
	}else if([tagName isEqualToString:@"label"] || [tagName isEqualToString:@"span"]){
		view = [[ILabel alloc] init];
	}else if([tagName isEqualToString:@"*text*"]){
		view = [[ILabel alloc] init];
	}else{
		//view = [[ILabel alloc] init];
		//log_trace(@"parse_stack add: nil");
		//[parse_stack addObject: @""];
		//return;
	}
	
	//static NSString *text_tags = @"|label|span|a|b|i|u|s";
	
	if(view){
		view.style.tagName = tagName;
		[view.style set:@"" baseUrl:_baseUrl];
		
		if(currentView){
			if([currentView class] == [IView class]){
				[currentView addSubview:view];
			}else{
				IView *parent = currentView.parent;
				if(!parent){
					parent = [[IView alloc] init];
					[parent addSubview:currentView];
					//[parse_stack addObject:parent];
					[_rootViews addObject:parent];
				}
				[parent addSubview:view];
			}
		}
		currentView = view;
		[parse_stack addObject:view];
		
		// 1. builtin(default) css
		// 2. class css
		// 3. ID css
		// 4. inline css
		
		if(defaultCss){
			[view.style set:defaultCss];
		}
		
		//[_styleSheet applyCssForView:view attributes:attributeDict];
		if(attributeDict){
			NSString *class_ = [attributeDict objectForKey:@"class"];
			if(class_ != nil){
				NSMutableArray *ps = [NSMutableArray arrayWithArray:
									  [class_ componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
				[ps removeObject:@""];
				for(NSString *clz in ps){
					[view.style addClass:clz];
				}
			}
			
			NSString *id_ = [attributeDict objectForKey:@"id"];
			if(id_ != nil && id_.length > 0){
				view.vid = id_;
				[_viewsById setObject:view forKey:id_];
				[view.style setId:id_];
			}
			
			NSString *css = [attributeDict objectForKey:@"style"];
			if(css){
				[view.style set:css];
			}
		}
	}else{
		[parse_stack addObject:@""];
	}
	
}

#if DTHTML
- (void)parser:(DTHTMLParser *)parser didEndElement:(NSString *)tagName{
#else
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)tagName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
#endif
	_tag = nil;
	if([tagName isEqualToString:@"script"]){
		_ignore = NO;
		return;
	}
	if([tagName isEqualToString:@"style"]){
		return;
	}
	if(state != ParseView){
		return;
	}
	
	[self parser:parser elementChanged:tagName];
	
	id view = [parse_stack lastObject];
	[parse_stack removeLastObject];
	
	//log_trace(@"</%@> %d", tagName, (int)parse_stack.count);

	if([view isKindOfClass:[IView class]]){
		currentView = view;
		if(currentView.parent){
			currentView = currentView.parent;
		}else{
			[_rootViews addObject:currentView];
			currentView = nil;
		}
	}
}


#if DTHTML
- (void)parser:(DTHTMLParser *)parser elementChanged:(NSString *)tag{
#else
- (void)parser:(NSXMLParser *)parser elementChanged:(NSString *)tag{
#endif
	if(_text.length == 0){
		return;
	}
	NSString *str = _text;
	_text = [[NSMutableString alloc] init];
	
	Class clz = [currentView class];
	//log_trace(@"    clz: %@", clz);
	if(clz == nil || clz == [IView class]){
		if([_tag isEqualToString:@"div"] || [_tag isEqualToString:@"view"]){
			_attributeDict = nil;
		}
#if DTHTML
		[self parser:parser didStartElement:@"*text*" attributes:_attributeDict];
		[self parser:parser foundCharacters:str];
		[self parser:parser didEndElement:@"*text*"];
#else
		[self parser:parser didStartElement:@"*text*" namespaceURI:nil qualifiedName:nil attributes:_attributeDict];
		[self parser:parser foundCharacters:str];
		[self parser:parser didEndElement:@"*text*" namespaceURI:nil qualifiedName:nil];
#endif
		return;
	}
	if(clz == [IButton class]){
		[(IButton *)currentView setText:str];
	}else if(clz == [ILabel class]){
		[(ILabel *)currentView setText:str];
	}else{
		return;
	}
	//log_trace(@"%@ %@", str, clz);
}
	

/*
 https://developer.apple.com/library/mac/documentation/Cocoa/Reference/NSXMLParserDelegate_Protocol/Reference/Reference.html#//apple_ref/doc/uid/TP40008632-CH1-SW12
 The parser object may send the delegate several parser:foundCharacters: messages to report the characters of an element. Because string may be only part of the total character content for the current element, you should append it to the current accumulation of characters until the element changes.
 */
	
#if DTHTML
- (void)parser:(DTHTMLParser *)parser foundCharacters:(NSString *)str{
#else
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)str{
#endif
	if(_ignore){
		return;
	}
	if([_tag isEqualToString:@"style"]){
		//log_trace(@"    parse text: %@", str);
		[_styleSheet parseCss:str];
		return;
	}
	if(state != ParseView){
		return;
	}
	str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if(str.length == 0){
		return;
	}
	//log_trace(@"    parse text: %@", str);
	[_text appendString:str];
}

@end
