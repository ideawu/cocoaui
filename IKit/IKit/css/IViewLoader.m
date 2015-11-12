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
#import "IStyleDecl.h"
#import "IStyleUtil.h"

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
	NSMutableArray *parse_stack;
	NSMutableString *_text;
	NSString *_last_tag;
}
@property (nonatomic) NSMutableDictionary *viewsById;
@property (nonatomic) NSMutableArray *rootViews;
@property (nonatomic) NSString *rootPath; // 以'/'结尾, 对于文件, 就是根目录; 对于URL, 就是根URL.
@property (nonatomic) NSString *basePath; // 以'/'结尾
@end

@implementation IViewLoader
	
+ (IView *)viewFromXml:(NSString *)xml{
	IViewLoader *viewLoader = [[IViewLoader alloc] init];
	IView *view = [viewLoader loadXml:xml];
	return view;
}

	
+ (void)loadUrl:(NSString *)url callback:(void (^)(IView *view))callback{
	NSArray *arr = [IStyleUtil parsePath:url];
	NSString *rootPath = [arr objectAtIndex:0];
	NSString *basePath = [arr objectAtIndex:1];
	log_debug(@"root: %@ base: %@", rootPath, basePath);
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setHTTPMethod:@"GET"];
	[request setURL:[NSURL URLWithString:url]];
	[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *urlresp, NSData *data, NSError *error){
		NSString *xml = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		IViewLoader *viewLoader = [[IViewLoader alloc] init];
		viewLoader.rootPath = rootPath;
		viewLoader.basePath = basePath;
		IView *view = [viewLoader loadXml:xml];
		callback(view);
	}];
}

- (id)init{
	self = [super init];
	_rootPath = nil;//[NSString stringWithFormat:@"%@/", [[NSBundle mainBundle] resourcePath]];
	_basePath = _rootPath;
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
	[retView.style renderAllCss];
	return retView;
}

- (IView *)getViewById:(NSString *)id_{
	IView *view =[ _viewsById objectForKey:id_];
	return view;
}

- (BOOL)parseIfIsCSS:(NSString *)tagName attributes:(NSDictionary *)attributeDict{
	BOOL ret = NO;
	NSString *src = nil;
	if([tagName isEqualToString:@"style"]){
		ret = YES;
		src = [attributeDict objectForKey:@"src"];
		if(!src){
			src = [attributeDict objectForKey:@"href"];
		}
	}else if([tagName isEqualToString:@"link"]){
		ret = YES;
		NSString *type = [attributeDict objectForKey:@"type"];
		if([type isEqualToString:@"text/css"]){
			src = [attributeDict objectForKey:@"href"];
		}
	}
	if(src){
		if([IStyleUtil isHttpUrl:_basePath]){
			src = [IStyleUtil buildPath:_basePath src:src];
		}else{
			src = [[NSBundle mainBundle] pathForResource:src ofType:@""];
			//[NSString stringWithFormat:@"%@/", [[NSBundle mainBundle] resourcePath]];
		}
		log_debug(@"load css file: %@", src);
		[_styleSheet parseCssFile:src];
	}
	return ret;
}

	
+ (BOOL)isAutoCloseTag:(NSString *)tagName{
	static NSSet *auto_close_tags = nil;
	if(auto_close_tags == nil){
		auto_close_tags = [NSSet setWithObjects:@"br", @"hr", @"img", @"meta", @"link", nil];
	}
	return tagName != nil && [auto_close_tags containsObject:tagName];
}

// 对于不支持的标签, 转成纯文本

#if DTHTML
- (void)parser:(DTHTMLParser *)parser didStartElement:(NSString *)tagName attributes:(NSDictionary *)attributeDict{
#else
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)tagName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
#endif
	tagName = [tagName lowercaseString];
	//NSLog(@"<%@>", tagName);
	
	// 兼容不闭合的标签
	if([IViewLoader isAutoCloseTag:_last_tag]){
		//[parse_stack addObject:@""];
#if DTHTML
		[self parser:parser didEndElement:_last_tag];
#else
		[self parser:parser didEndElement:_last_tag namespaceURI:nil qualifiedName:nil];
#endif
	}
	_last_tag = tagName; // 在 didEndElement 时清除
	
	if([self parseIfIsCSS:tagName attributes:attributeDict]){
		return;
	}
	if([tagName isEqualToString:@"script"]){
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

	//log_trace(@"<%@> %d", tagName, (int)parse_stack.count);

	IView *view;
	if([tagName isEqualToString:@"img"]){
		NSString *src = [attributeDict objectForKey:@"src"];
		IImage *img = [[IImage alloc] init];
		if(src){
			if([IStyleUtil isHttpUrl:_basePath]){
				src = [IStyleUtil buildPath:_basePath src:src];
			}
			img.src = src;
		}
		
		NSString *width = [attributeDict objectForKey:@"width"];
		NSString *height = [attributeDict objectForKey:@"height"];
		if(width){
			[img.style set:[NSString stringWithFormat:@"width: %@", width]];
		}
		if(height){
			[img.style set:[NSString stringWithFormat:@"height: %@", height]];
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
	}else{
		Class clz = [IViewLoader getClassForTag:tagName];
		if(clz){
			// 避免嵌套的 ILabel
			if([currentView class] == [ILabel class] && clz == [ILabel class]){
				//
			}else{
				view = [[clz alloc] init];
			}
		}
	}
	
	if(view){
		NSString *str = [self getAndResetText];
		if(str.length > 0){
			ILabel *textView = [ILabel labelWithText:str];
			[currentView addSubview:textView];
		}
		
		view.style.tagName = tagName;
		[view.style set:@"" baseUrl:_basePath];
		
		if(currentView){
			if([currentView class] == [IView class]){
				[currentView addSubview:view];
			}else{
				IView *parent = currentView.parent;
				if(!parent){
					parent = [[IView alloc] init];
					[parent addSubview:currentView];
					[_rootViews addObject:parent];
				}
				[parent addSubview:view];
			}
		}
		currentView = view;
		[parse_stack addObject:view];
		
		// 1. builtin(default) css
		// 2. stylesheet(by style tag) css
		// 3. inline css
		// $: dynamically set css
		
		// 1.
		NSString *defaultCss = [IViewLoader getDefaultCssForTag:tagName];
		if(defaultCss){
			[view.style set:defaultCss];
		}
		// 2.
		[view.style.declBlock addKey:@"@" value:@""];
		
		if(attributeDict){
			// 3.
			NSString *css = [attributeDict objectForKey:@"style"];
			if(css){
				[view.style set:css];
			}

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
				[_viewsById setObject:view forKey:id_];
				[view.style setId:id_];
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
	_last_tag = nil;
	//log_trace(@"</%@> %d", tagName, (int)parse_stack.count);
	tagName = [tagName lowercaseString];
	if([tagName isEqualToString:@"script"]){
		return;
	}
	if([tagName isEqualToString:@"style"]){
		[_styleSheet parseCss:_text];
		_text = [[NSMutableString alloc] init];
		return;
	}
	if(state != ParseView){
		_text = [[NSMutableString alloc] init];
		return;
	}
	
	if(parse_stack.count == 0){
		NSString *str = [self getAndResetText];
		if(str.length > 0){
			ILabel *textView = [ILabel labelWithText:str];
			[_rootViews addObject:textView];
		}
		return;
	}
	
	id view = [parse_stack lastObject];
	[parse_stack removeLastObject];
	
	if([view isKindOfClass:[NSString class]]){
		return;
	}
	
	Class viewClass = [view class];
	if(viewClass == [ILabel class]){
		[(ILabel *)currentView setText:[self getAndResetText]];
	}else if(viewClass == [IButton class]){
		[(IButton *)currentView setText:[self getAndResetText]];
	}else{
		NSString *str = [self getAndResetText];
		if(str.length > 0){
			ILabel *textView = [ILabel labelWithText:str];
			[currentView addSubview:textView];
		}
	}
	if(currentView.parent){
		currentView = currentView.parent;
	}else{
		[_rootViews addObject:currentView];
		currentView = nil;
	}
}

- (NSString *)getAndResetText{
	if(_text.length == 0){
		return @"";
	}
	// TODO: 对文本进行处理
	NSString *str = [_text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	_text = [[NSMutableString alloc] init];
	return str;
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
	//log_trace(@"    parse text: %@", str);
	[_text appendString:str];
}

+ (Class)getClassForTag:(NSString *)tagName{
	static NSMutableDictionary *tagClassTable = nil;
	if(tagClassTable == nil){
		tagClassTable = [[NSMutableDictionary alloc] init];
		
		Class textClass = [ILabel class];
		Class viewClass = [IView class];
		
		tagClassTable[@"a"] = textClass;
		tagClassTable[@"b"] = textClass;
		tagClassTable[@"p"] = textClass;
		tagClassTable[@"h1"] = textClass;
		tagClassTable[@"h2"] = textClass;
		tagClassTable[@"h3"] = textClass;
		tagClassTable[@"h4"] = textClass;
		tagClassTable[@"h5"] = textClass;
		tagClassTable[@"label"] = textClass;
		tagClassTable[@"span"] = textClass;
		tagClassTable[@"*text*"] = textClass;
		
		tagClassTable[@"br"] = viewClass;
		tagClassTable[@"hr"] = viewClass;
		tagClassTable[@"ul"] = viewClass;
		tagClassTable[@"ol"] = viewClass;
		tagClassTable[@"li"] = viewClass;
		tagClassTable[@"div"] = viewClass;
		tagClassTable[@"view"] = viewClass;
		
		tagClassTable[@"switch"] = [ISwitch class];
		tagClassTable[@"button"] = [IButton class];
	}
	return [tagClassTable objectForKey:tagName];
}

+ (NSString *)getDefaultCssForTag:(NSString *)tagName{
	static NSMutableDictionary *defaultCssTable = nil;
	if(defaultCssTable == nil){
		defaultCssTable = [[NSMutableDictionary alloc] init];
		defaultCssTable[@"a"] = @"color: #00f;";
		defaultCssTable[@"b"] = @"font-weight: bold;";
		defaultCssTable[@"p"] = @"clear: both; width: 100%; margin: 12 0;";
		defaultCssTable[@"br"] = @"clear: both; width: 100%%; height: 12;";
		defaultCssTable[@"hr"] = @"clear: both; margin: 12 0; width: 100%; height: 1; background: #000;";
		
		defaultCssTable[@"ul"] = @"clear: both; width: 100%; padding-left: 20; margin: 12 0;";
		defaultCssTable[@"ol"] = @"clear: both; width: 100%; padding-left: 20; margin: 12 0;";
		defaultCssTable[@"li"] = @"clear: both; width: 100%;";
		
		defaultCssTable[@"h1"] = @"clear: both; font-weight: bold; width: 100%; margin: 12 0; font-size: 240%;";
		defaultCssTable[@"h2"] = @"clear: both; font-weight: bold; width: 100%; margin: 10 0; font-size: 180%;";
		defaultCssTable[@"h3"] = @"clear: both; font-weight: bold; width: 100%; margin: 10 0; font-size: 140%;";
		defaultCssTable[@"h4"] = @"clear: both; font-weight: bold; width: 100%; margin: 8 0; font-size: 110%;";
		defaultCssTable[@"h5"] = @"clear: both; font-weight: bold; width: 100%; margin: 6 0; font-size: 100%;";
	}
	return [defaultCssTable objectForKey:tagName];
}

@end
