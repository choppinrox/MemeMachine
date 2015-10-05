//
//  NSDictionary+Meme.h
//  MemeMachine
//
//  Created by Nikolai on 10/1/15.
//  Copyright (c) 2015 DigitalArsenal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Meme : NSObject

@property (nonatomic, readonly) NSString *ID;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSURL    *url;
@property (nonatomic, readonly) CGSize   size;
@property (nonatomic) UIImage *image;

@end

@interface NSDictionary (Meme)
- (Meme*)createMemeWithDictionary;
@end
