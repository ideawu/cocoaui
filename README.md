# CocoaUI

Build adaptive UI for iOS Apps with Flow-Layout mechanism and CSS properties.

[![Platform](https://img.shields.io/badge/platform-iOS-blue.svg?style=flat)](https://github.com/ideawu/cocoaui) ![Language](https://img.shields.io/badge/language-Objective%20C-blue.svg) [![License](https://img.shields.io/badge/license-New%20BSD-blue.svg?style=flat)](LICENSE)

| AAA | BBB |
| ----| --- |
| OS | iOS 9.x, 8.x, 7.x |
| Language | Objective-C, Swift(see https://github.com/XiaoCC/CocoaUI-Swift) |
| License | New BSD License |
| Author | [ideawu](http://www.ideawu.net/) |
| Website | [http://www.cocoaui.com/](http://www.cocoaui.com/) |


__Demos:__
 * [https://github.com/ideawu/cocoaui-demos](https://github.com/ideawu/cocoaui-demos)

## Dependency

 * libxml2
 
## Setup

 1. Download the source files from GitHub: [git](https://github.com/ideawu/cocoaui.git), [.zip](https://github.com/ideawu/cocoaui/archive/dev.zip)
 1. Use Xcode the open the IKit Project
 1. Build the schema IKit-universal, set the schema Build Configuration to Release(default is Debug)
 1. Add the header files folder and static library to you own project(see [Quick Start](http://www.cocoaui.com/en/docs/quickstart)):
   * header files folder: `build/release-universal/include/IKit`
   * static libarry file: `build/release-universal/include/libIKit.a`
 
## Usage

### Sample Code(Objective-C)

CocoaUI makes things ass-kicking easy! -

	[superview.style set:@"padding: 10;"];

Without CocoaUI, here's the equivalent code you'd have to write using Apple's Foundation API directly:

	UIView *superview = self;
	UIView *view1 = [[UIView alloc] init];
	view1.translatesAutoresizingMaskIntoConstraints = NO;
	[superview addSubview:view1];
	UIEdgeInsets padding = UIEdgeInsetsMake(10, 10, 10, 10);
	[superview addConstraints:@[
	    //view1 constraints
	    [NSLayoutConstraint constraintWithItem:view1
	                                 attribute:NSLayoutAttributeTop
	                                 relatedBy:NSLayoutRelationEqual
	                                    toItem:superview
	                                 attribute:NSLayoutAttributeTop
	                                multiplier:1.0
	                                  constant:padding.top],
	    [NSLayoutConstraint constraintWithItem:view1
	                                 attribute:NSLayoutAttributeLeft
	                                 relatedBy:NSLayoutRelationEqual
	                                    toItem:superview
	                                 attribute:NSLayoutAttributeLeft
	                                multiplier:1.0
	                                  constant:padding.left],
	    [NSLayoutConstraint constraintWithItem:view1
	                                 attribute:NSLayoutAttributeBottom
	                                 relatedBy:NSLayoutRelationEqual
	                                    toItem:superview
	                                 attribute:NSLayoutAttributeBottom
	                                multiplier:1.0
	                                  constant:-padding.bottom],
	    [NSLayoutConstraint constraintWithItem:view1
	                                 attribute:NSLayoutAttributeRight
	                                 relatedBy:NSLayoutRelationEqual
	                                    toItem:superview
	                                 attribute:NSLayoutAttributeRight
	                                multiplier:1
	                                  constant:-padding.right],
	]];

CocoaUI supports most CSS layout and styling feature, the key of CocoaUI is Flow Layout.

### Example Apps

 * [https://github.com/ideawu/cocoaui-demos](https://github.com/ideawu/cocoaui-demos)
 * [https://github.com/ideawu/cocoaui/tree/master/IKit/Test](https://github.com/ideawu/cocoaui/tree/master/IKit/Test)

### Learning CocoaUI

 * [Learn iOS Flow Layout in 10 Minutes](http://www.cocoaui.com/en/docs/flowlayout)
 * [Quick Start](http://www.cocoaui.com/en/docs/quickstart)
 * [Tutorial - Pull Down to Refresh and Pull Up to Load More](http://www.cocoaui.com/en/docs/examples/pullToRefresh)

### Documentation

[http://www.cocoaui.com/en/docs](http://www.cocoaui.com/en/docs)


## About Source Code

### IKit

The CocoaUI library.

### IObj

A dynamic JSON object/model library for Objective-C.

### Test

Demo app for CocoaUI

### CocoaUIViewer

A __Write and Seen__ tool helps you easily develop XML UI.
