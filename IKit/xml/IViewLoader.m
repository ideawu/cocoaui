/*
 Copyright (c) 2014-2015 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import <Foundation/NSXMLParser.h>
#import "IViewLoader.h"
#import "IViewInternal.h"
#import "IStyleInternal.h"
#import "IStyleSheet.h"
#import "ICssDecl.h"
#import "ICssBlock.h"
#import "IKitUtil.h"
#import "ILabel.h"
#import "IInput.h"
#import "IButton.h"
#import "ISwitch.h"
#import "IImage.h"
#import "INSXmlViewLoader.h"
#import "IDTHTMLViewLoader.h"
#import "IResourceMananger.h"

typedef enum{
	ParseInit,
	ParseHtml,
	ParseHead,
	ParseBody,
	ParseView,
}ParseState;

@interface IViewLoader () <NSXMLParserDelegate, DTHTMLParserDelegate>{
	ParseState state;
	IView *parentView;
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
	return [IViewLoader viewFromXml:xml basePath:nil];
}

+ (IView *)viewFromXml:(NSString *)xml basePath:(NSString *)basePath{
	IViewLoader *viewLoader = [[IViewLoader alloc] init];
	if(basePath){
		NSArray *arr = [IKitUtil parsePath:basePath];
		NSString *rootPath = [arr objectAtIndex:0];
		viewLoader.rootPath = rootPath;
		viewLoader.basePath = basePath;
	}
	IView *view = [viewLoader loadXml:xml];
	return view;
}

+ (void)loadUrl:(NSString *)url callback:(void (^)(IView *view))callback{
	NSArray *arr = [IKitUtil parsePath:url];
	NSString *rootPath = [arr objectAtIndex:0];
	NSString *basePath = [arr objectAtIndex:1];
	log_debug(@"URL root: %@ base: %@", rootPath, basePath);
	
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
	parentView = nil;
	_styleSheet = [[IStyleSheet alloc] init];
	
	_rootViews = [[NSMutableArray alloc] init];
	parse_stack = [[NSMutableArray alloc] init];
	_viewsById = [[NSMutableDictionary alloc] init];
	_text = [[NSMutableString alloc] init];
	
	if([IKitUtil isHTML:str]){
		log_trace(@"parse using DTHTML");
		IDTHTMLViewLoader *loader = [[IDTHTMLViewLoader alloc] init];
		[loader parseXml:str viewLoader:self];
	}else{
		log_trace(@"parse using NSXml");
		INSXmlViewLoader *loader = [[INSXmlViewLoader alloc] init];
		[loader parseXml:str viewLoader:self];
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
	parentView = nil;
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
		NSString *rel = [attributeDict objectForKey:@"rel"];
		if([type isEqualToString:@"text/css"] || [rel isEqualToString:@"stylesheet"]){
			src = [attributeDict objectForKey:@"href"];
		}
	}
	if(src){
		if([IKitUtil isHttpUrl:_basePath]){
			src = [IKitUtil buildPath:_basePath src:src];
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

- (IImage *)buildImageWithAttributes:(NSDictionary *)attributeDict{
	NSString *src = [attributeDict objectForKey:@"src"];
	IImage *img = [[IImage alloc] init];
	if(src){
		if([IKitUtil isDataURI:src]){
			log_debug(@"load image element from data URI");
			img.image = [IKitUtil loadImageFromDataURI:src];
		}else{
			if([IKitUtil isHttpUrl:_basePath]){
				src = [IKitUtil buildPath:_basePath src:src];
			}
			[[IResourceMananger sharedMananger] getImage:src callback:^(UIImage *_img) {
				img.image = _img;
			}];
		}
	}
	
	NSString *width = [attributeDict objectForKey:@"width"];
	NSString *height = [attributeDict objectForKey:@"height"];
	if(width){
		[img.style set:[NSString stringWithFormat:@"width: %@", width]];
	}
	if(height){
		[img.style set:[NSString stringWithFormat:@"height: %@", height]];
	}
	return img;
}

- (IInput *)buildInputWithAttributes:(NSDictionary *)attributeDict{
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
	return input;
}

- (void)checkPlainTextNode{
	if(_text.length > 0){
		NSString *str = [self getAndResetText];
		if(str.length > 0){
			ILabel *textView = [ILabel labelWithText:str];
			if(parentView){
				[parentView addSubview:textView];
			}else{
				[_rootViews addObject:textView];
			}
		}
	}
}

- (void)bindStyleToView:(IView *)view attributes:(NSDictionary *)attributeDict{
	// 1. builtin(default) css
	// 2. stylesheet(by style tag) css
	// 3. inline css
	// $: dynamically set css
	
	// REMEMBER to set baseUrl!
	view.style.cssBlock.baseUrl = _basePath;
	
	// 1.
	NSString *defaultCss = [IViewLoader getDefaultCssForTag:view.style.tagName];
	if(defaultCss){
		[view.style set:defaultCss];
	}
	// 2.
	[view.style.cssBlock addKey:@"@" value:@""];
	
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
}

// 对于不支持的标签, 转成纯文本

- (void)didStartElement:(NSString *)tagName attributes:(NSDictionary *)attributeDict{
	//log_trace(@"%*s<%@>", (int)parse_stack.count*4, "", tagName);

	tagName = [tagName lowercaseString];
	
	// 兼容不闭合的标签
	if([IViewLoader isAutoCloseTag:_last_tag]){
		log_debug(@"auto close tag: %@", _last_tag);
		[self didEndElement:_last_tag];
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

	IView *view;
	if([tagName isEqualToString:@"img"]){
		view = [self buildImageWithAttributes:attributeDict];
	}else if([tagName isEqualToString:@"input"]){
		view = [self buildInputWithAttributes:attributeDict];
	}else{
		Class clz = [IViewLoader getClassForTag:tagName];
		// 避免嵌套的 ILabel
		if(clz == [ILabel class]){
			Class pclz = [parentView class];
			if(pclz == [ILabel class] || pclz == [IButton class]){
				clz = nil;
			}
		}
		if(clz){
			view = [[clz alloc] init];
		}
	}
	
	if(view){
		view.style.tagName = tagName;
		[self checkPlainTextNode];
		[self bindStyleToView:view attributes:attributeDict];
		
		if(parentView){
			[parentView addSubview:view];
		}
		parentView = view;
		[parse_stack addObject:view];
		
		NSString *id_ = [attributeDict objectForKey:@"id"];
		if(id_ != nil && id_.length > 0){
			view.vid = id_;
			[_viewsById setObject:view forKey:id_];
		}
	}else{
		[parse_stack addObject:@""];
	}
}

- (void)didEndElement:(NSString *)tagName{
	//log_trace(@"%*s</%@>", (int)(parse_stack.count-1)*4, "", tagName);

	_last_tag = nil;
	tagName = [tagName lowercaseString];
	if([tagName isEqualToString:@"script"]){
		_text = [[NSMutableString alloc] init];
		return;
	}
	if([tagName isEqualToString:@"style"]){
		[_styleSheet parseCss:_text baseUrl:_basePath];
		_text = [[NSMutableString alloc] init];
		return;
	}
	if(state != ParseView){
		_text = [[NSMutableString alloc] init];
		return;
	}
	
	if(parse_stack.count == 0){
		[self checkPlainTextNode];
		return;
	}
	
	id last_parse = [parse_stack lastObject];
	[parse_stack removeLastObject];
	
	if([last_parse isKindOfClass:[NSString class]]){
		return;
	}
	
	IView *view = (IView *)last_parse;
	Class viewClass = [last_parse class];
	if(viewClass == [ILabel class]){
		[(ILabel *)view setText:[self getAndResetText]];
	}else if(viewClass == [IButton class]){
		[(IButton *)view setText:[self getAndResetText]];
	}else{
		[self checkPlainTextNode];
	}

	parentView = view.parent;
	if(!parentView){
		[_rootViews addObject:view];
	}
}

- (NSString *)getAndResetText{
	if(_text.length == 0){
		return @"";
	}
	// TODO: 根据相临节点的类型(是否是文本节点), 保留末尾的空白字符.
	NSString *str = [_text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	_text = [[NSMutableString alloc] init];
	return str;
}

/*
 https://developer.apple.com/library/mac/documentation/Cocoa/Reference/NSXMLParserDelegate_Protocol/Reference/Reference.html#//apple_ref/doc/uid/TP40008632-CH1-SW12
 The parser object may send the delegate several parser:foundCharacters: messages to report the characters of an element. Because string may be only part of the total character content for the current element, you should append it to the current accumulation of characters until the element changes.
 */

- (void)foundCharacters:(NSString *)str{
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
		tagClassTable[@"label"] = textClass;
		tagClassTable[@"span"] = textClass;

		tagClassTable[@"p"] = viewClass;
		tagClassTable[@"h1"] = viewClass;
		tagClassTable[@"h2"] = viewClass;
		tagClassTable[@"h3"] = viewClass;
		tagClassTable[@"h4"] = viewClass;
		tagClassTable[@"h5"] = viewClass;

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
		defaultCssTable[@"br"] = @"clear: both; width: 100%; height: 12;";
		defaultCssTable[@"hr"] = @"clear: both; width: 100%; height: 1; margin: 12 0; background: #333;";
		
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
