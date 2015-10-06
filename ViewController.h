//
//  ViewController.h
//  MemeMachine
//
//  Created by Nikolai on 10/1/15.
//  Copyright (c) 2015 DigitalArsenal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSDictionary+Meme.h"

@interface ViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate> {
    Meme *currentMeme;
    NSMutableArray *memes;
    
    BOOL animating;
    BOOL saving;
    
    UIImage *clearImage;
    UILabel *currentLabel;
    UIAlertController *actionSheet;
}

@property (strong, nonatomic) IBOutlet UIImageView *memeView;
@property (strong, nonatomic) IBOutlet UICollectionView *memeCollection;
@property (strong, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) IBOutlet UILabel *topLabel;
@property (strong, nonatomic) IBOutlet UILabel *botLabel;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIImageView *popUpView;
@property (strong, nonatomic) IBOutlet UIView *popUpBackdrop;
@property (strong, nonatomic) IBOutlet UIImageView *renderView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

