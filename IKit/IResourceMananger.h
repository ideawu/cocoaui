//
//  IKitResourceMananger.h
//  IKit
//
//  Created by ideawu on 12/6/15.
//  Copyright © 2015 ideawu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IResourceMananger : NSObject

+ (IResourceMananger *)sharedMananger;
+ (void)setSharedManager:(IResourceMananger *)mananger;

//- (void)getXml:(NSString *)name url:(NSString *)url callback:(void (^)(NSString *))callback;

- (UIImage *)getImage:(NSString *)path callback:(void (^)(UIImage *))callback;

@end
