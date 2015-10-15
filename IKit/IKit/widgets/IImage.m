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
#import "IStyleUtil.h"

@interface IImage (){
	NSString *_src;
	UIImage *_image;
	UIImageView *_imageView;
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
	self.style.tagName = @"img";
	return self;
}

- (NSString *)src{
	return _src;
}

- (void)setSrc:(NSString *)src{
	_src = src;
	// load image from network
	if([IStyleUtil isHttpUrl:src]){
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
		[request setHTTPMethod:@"GET"];
		[request setURL:[NSURL URLWithString:src]];
		NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
		if(data){
			UIImage *img = [UIImage imageWithData:data];
			if(img){
				[self setImage:img];
			}
		}
	}else{
		[self setImage:[UIImage imageNamed:src]];
	}
}

- (UIImage *)image{
	return _image;
}

- (void)setImage:(UIImage *)image{
	_image = image;
	[self.imageView setImage:_image];
	[self setNeedsLayout];
}

- (UIImageView *)imageView{
	if(!_imageView){
		_imageView = [[UIImageView alloc] init];
		_imageView.contentMode = UIViewContentModeScaleToFill;
		[self addUIView:_imageView];
	}
	return _imageView;
}

- (void)setImageView:(UIImageView *)imageView{
	if(_imageView){
		[_imageView removeFromSuperview];
	}
	_imageView = imageView;
	[self addUIView:_imageView];
}

- (void)drawRect:(CGRect)rect {
	//NSLog(@"%@ %s", self.name, __func__);
	[super drawRect:rect];
}

- (void)layout{
	//log_debug(@"%@ %s %@", self.name, __func__, _src);
	
	if(_imageView){
		[_imageView sizeToFit];
		if(self.style.resizeWidth){
			//NSLog(@"width: %f", _imageView.frame.size.width);
			[self.style setInnerWidth:_imageView.frame.size.width];
		}
		if(self.style.resizeHeight){
			//NSLog(@"height: %f", _imageView.frame.size.height);
			[self.style setInnerHeight:_imageView.frame.size.height];
		}
		if(!self.style.resizeWidth && self.style.resizeHeight){
			// 等比缩放
			CGFloat h = self.style.innerWidth / _imageView.frame.size.width * _imageView.frame.size.height;
			[self.style setInnerHeight:h];
		}else if(self.style.resizeWidth && !self.style.resizeHeight){
			// 等比缩放
			CGFloat w = self.style.innerHeight / _imageView.frame.size.height * _imageView.frame.size.width;
			[self.style setInnerWidth:w];
		}
	}
	
	// 先做自定义布局, 再进行父类布局
	[super layout];
}

@end
