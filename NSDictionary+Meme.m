//
//  NSDictionary+Meme.m
//  MemeMachine
//
//  Created by Nikolai on 10/1/15.
//  Copyright (c) 2015 DigitalArsenal. All rights reserved.
//

#import "NSDictionary+Meme.h"

@implementation Meme

- (void)setID:(NSString *)ID {
    _ID = ID;
}

- (void) setName:(NSString *)name {
    _name = name;
}

- (void) setUrl:(NSString *)url {
    _url = [NSURL URLWithString:url];
}

- (void) setSize:(CGFloat)width andHeight:(CGFloat)height {
    _size = CGSizeMake(width, height);
}

@end

@implementation NSDictionary (Meme)

- (Meme *)createMemeWithDictionary {
    if (self != nil) {
        Meme *meme = [[Meme alloc] init];
        [meme setID:[self objectForKey:@"id"]];
        [meme setName:[self objectForKey:@"name"]];
        [meme setUrl:[self objectForKey:@"url"]];
        [meme setSize:[[self objectForKey:@"width"]  floatValue]
            andHeight:[[self objectForKey:@"height"] floatValue]];
        return meme;
    }
    return nil;
}

@end
