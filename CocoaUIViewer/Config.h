//
//  Config.h
//  CocoaUIViewer
//
//  Created by ideawu on 4/12/15.
//  Copyright (c) 2015 ideawu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Config : NSObject

@property NSString *url;
@property int64_t interval;

- (void)save;

@end
