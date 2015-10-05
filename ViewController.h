//
//  ViewController.h
//  MemeMachine
//
//  Created by Nikolai on 10/1/15.
//  Copyright (c) 2015 DigitalArsenal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSDictionary+Meme.h"
#import "UIView+draggable.h"

@interface ViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate> {
    NSMutableArray *memes;
    NSMutableArray *captions;
    BOOL animating;
    CGPoint offset;
}

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *gestureRecognizer;
@property (strong, nonatomic) IBOutlet UIImageView *memeView;
@property (strong, nonatomic) IBOutlet UICollectionView *memeCollection;

@end

