/*
 Copyright (c) 2014-2016 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "ISelect.h"
#import "ILabel.h"
#import "IStyleInternal.h"
#import "IPopover.h"
#import "ITable.h"
#import "ITableRow.h"

@interface ISelect ()<ITableDelegate>{
	ITable *_table;
	IPopover *_pop;
	void (^_callback)(NSString *key);
}
@property (nonatomic) NSMutableArray *options; // k0, v0, k1, v1, ...
@end

@implementation ISelect

- (id)init{
	self = [super init];
	self.style.tagName = @"select";
	
	_selectedIndex = -1;
	_options = [[NSMutableArray alloc] init];

	_label = [ILabel labelWithText:@"---"];
	_label.label.numberOfLines = 1;
	_label.label.lineBreakMode = NSLineBreakByTruncatingTail;

	_arrow = [ILabel labelWithText:@">"];
	_arrow.label.transform = CGAffineTransformMakeRotation(M_PI_2);

	[self.style set:@"padding: 1px 0; border: 0.5px solid #ccc;"];
	[_arrow.style set:@"float: right; padding-left: 2; width: 15px; height: 100%; font-size: 16px; font-weight: bold; valign: middle; text-align: center; background: #0cf; border-radius: 3; color: #fff;"];
	[_label.style set:@"width: 100%; valign: middle; text-align: center;"];
	[self addSubview:_arrow];
	[self addSubview:_label];

	__weak typeof(self) me = self;
	[self bindEvent:IEventClick handler:^(IEventType event, IView *view) {
		[me showDropdown];
	}];

	return self;
}

- (void)showDropdown{
	_table = [[ITable alloc] init];
	_table.delegate = self;
	
	for(NSUInteger i=0; i<self.options.count; i+=2){
		NSString *text = self.options[i+1];
		ILabel *row = [ILabel labelWithText:text];
		[row.style set:@"height: 35; margin: 0 3; text-align: center; border-bottom: 0.5 solid #eee; background: #fff;"];
		if(i/2 == self.selectedIndex){
			[row.style set:@"font-weight: bold"];
		}
		[_table addIViewRow:row];
	}
	
	IView *wrapper = [[IView alloc] init];
	[wrapper.style set:@"float: center; border: 0.5px solid #ccc; border-radius: 5;"];
	
	CGFloat w = self.viewController.view.frame.size.width * 0.6;
	CGFloat h = self.viewController.view.frame.size.height * 0.6;
	w = MIN(w, 240);
	h = MIN(h, 400);
	CGFloat y = (self.viewController.view.frame.size.height - h)/2 * 0.6;
	[wrapper.style set:[NSString stringWithFormat:@"margin-top: %f", y]];
	
	// 如果不用 uiview 包裹 ITable.view, ITable.view 会布局错误.
	UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
	_table.view.frame = v.bounds;
	[v addSubview:_table.view];
	[wrapper addSubview:v];
	
	_pop = [[IPopover alloc] init];
	[_pop presentView:wrapper onViewController:self.viewController];
	
	if(self.selectedIndex >= 0){
		NSUInteger index = self.selectedIndex;
		if(index + 4 < _options.count/2 - 2){
			index += 4;
		}
		[_table scrollToRowAtIndex:index animated:NO];
	}
}

- (void)table:(ITable *)table onHighlight:(IView *)view atIndex:(NSUInteger)index{
	view.layer.opacity = 0.5;
}
- (void)table:(ITable *)table onUnhighlight:(IView *)view atIndex:(NSUInteger)index{
	view.layer.opacity = 1;
}
- (void)table:(ITable *)table onClick:(IView *)view atIndex:(NSUInteger)index{
	[_pop hide];
	_pop = nil;
	
	id key = self.options[index * 2];
	//log_debug(@"select %d %@", index, key);
	[self setSelectedKey:key];
}

- (void)onSelectKey:(void (^)(NSString *key))callback{
	_callback = callback;
}

- (NSString *)optionTextForKey:(NSString *)key{
	for(NSUInteger i=0; i<_options.count; i+=2){
		if(_options[i] == key){
			return _options[i+1];
		}
	}
	return nil;
}

- (void)addOptionKey:(NSString *)key text:(NSString *)text{
	for(NSUInteger i=0; i<_options.count; i+=2){
		if(_options[i] == key){
			_options[i+1] = text;
			if(key == _selectedKey){
				[self setSelectedKey:key];
			}
			return;
		}
	}
	[_options addObject:key];
	[_options addObject:text];
	if(!_selectedKey){
		[self setSelectedKey:key];
	}
}

- (void)setSelectedKey:(NSString *)key{
	for(NSUInteger i=0; i<_options.count; i+=2){
		if(_options[i] == key){
			_selectedIndex = (NSInteger)i/2;
			_selectedKey = key;
			_selectedText = _options[i+1];
			_label.text = _selectedText;
			if(_callback){
				_callback(key);
			}
			[self setNeedsLayout];
			[self setNeedsDisplay];
			break;
		}
	}
}

- (void)layout{
	if(self.style.resizeWidth){
		[_label.style set:@"width: auto"];
	}
	[super layout];
	if(self.style.resizeWidth){
		//log_debug(@"%f", _label.style.width);
		self.style.width = _label.style.width + _arrow.style.width + 8;
		[_label.style set:@"width: 100%"];
		//[super layout];
	}
}

//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//}

@end
