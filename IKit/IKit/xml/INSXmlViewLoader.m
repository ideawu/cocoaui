/*
 Copyright (c) 2014-2015 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "INSXmlViewLoader.h"
#import "IViewLoader.h"

@implementation INSXmlViewLoader

- (void)parseXml:(NSString *)xml viewLoader:(IViewLoader *)viewLoader{
	_viewLoader = viewLoader;
	
	NSData* data = [xml dataUsingEncoding:NSUTF8StringEncoding];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
	parser.delegate = self;
	BOOL ret = [parser parse];
	if(ret == NO){
		log_trace(@"parse xml error: %@", [parser parserError]);
	}
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)tagName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
	[_viewLoader didStartElement:tagName attributes:attributeDict];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)tagName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
	[_viewLoader didEndElement:tagName];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)str{
	[_viewLoader foundCharacters:str];
}

@end
