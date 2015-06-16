/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "IImage.h"
#import "IViewInternal.h"
#import "IStyleInternal.h"

@interface IImage (){
	NSString *_src;
	UIImageView *_imgView;
	UIImage *_image;
}
@end


@implementation IImage

+ (IImage *)imageNamed:(NSString *)name{
	IImage *img = [[IImage alloc] init];
	img.src = name;
	return img;
}

- (id)init{
	self = [super init];
	[self.style setResizeWidth];
	return self;
}

- (NSString *)src{
	return _src;
}

- (void)setSrc:(NSString *)src{
	_src = src;
	// load image from network
	if([src rangeOfString:@"http://"].location == 0 || [src rangeOfString:@"https://"].location == 0){
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
		[request setHTTPMethod:@"GET"];
		[request setURL:[NSURL URLWithString:src]];
		[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *urlresp, NSData *data, NSError *error){
			UIImage *image = [UIImage imageWithData:data];
			[self setImage:image];
		}];
	}else{
		[self setImage:[UIImage imageNamed:src]];
	}
}

- (UIImage *)image{
	return _image;
}

- (void)setImage:(UIImage *)image{
	_image = image;
	if(!_imgView){
		_imgView = [[UIImageView alloc] init];
		_imgView.contentMode = UIViewContentModeScaleToFill;
		[self addUIView:_imgView];
	}
	[_imgView setImage:_image];
	[self setNeedsLayout];
}

- (void)drawRect:(CGRect)rect {
	//NSLog(@"%@ %s", self.name, __func__);
	[super drawRect:rect];
}

- (void)layout{
	//log_debug(@"%@ %s %@", self.name, __func__, _src);
	
	if(_imgView){
		[_imgView sizeToFit];
		if(self.style.resizeWidth){
			//NSLog(@"width: %f", _imgView.frame.size.width);
			[self.style setInnerWidth:_imgView.frame.size.width];
		}
		if(self.style.resizeHeight){
			//NSLog(@"height: %f", _imgView.frame.size.height);
			[self.style setInnerHeight:_imgView.frame.size.height];
		}
	}
	
	// 先做自定义布局, 再进行父类布局
	[super layout];
}

@end
