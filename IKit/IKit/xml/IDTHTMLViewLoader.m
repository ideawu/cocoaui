/*
 Copyright (c) 2014-2015 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "IDTHTMLViewLoader.h"
#import "IViewLoader.h"

@implementation IDTHTMLViewLoader

- (void)parseXml:(NSString *)xml viewLoader:(IViewLoader *)viewLoader{
	_viewLoader = viewLoader;
	
	NSData* data = [xml dataUsingEncoding:NSUTF8StringEncoding];
	DTHTMLParser *parser = [[DTHTMLParser alloc] initWithData:data encoding:NSUTF8StringEncoding];
	parser.delegate = self;
	BOOL ret = [parser parse];
	if(ret == NO){
		log_trace(@"parse xml error: %@", [parser parserError]);
	}
}

- (void)parser:(DTHTMLParser *)parser didStartElement:(NSString *)tagName attributes:(NSDictionary *)attributeDict{
	[_viewLoader didStartElement:tagName attributes:attributeDict];
}

- (void)parser:(DTHTMLParser *)parser didEndElement:(NSString *)tagName{
	[_viewLoader didEndElement:tagName];
}

- (void)parser:(DTHTMLParser *)parser foundCharacters:(NSString *)str{
	[_viewLoader foundCharacters:str];
}

@end

