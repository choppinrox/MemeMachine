//
//  ViewController.m
//  MemeMachine
//
//  Created by Nikolai on 10/1/15.
//  Copyright (c) 2015 DigitalArsenal. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    memes = [[NSMutableArray alloc] initWithCapacity:1];
    captions = [[NSMutableArray alloc] initWithCapacity:1];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTaps:)];
    [self.memeView addGestureRecognizer:tapGestureRecognizer];
    
    NSString* theURL = @"https://api.imgflip.com/get_memes";
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    NSURL*URL = [NSURL URLWithString:theURL];
    [request setURL:URL];
    [request setCachePolicy:NSURLRequestReloadRevalidatingCacheData];
    [request setTimeoutInterval:40];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   if (error != nil) {
                                       NSLog(@"error recieving request: %@", error);
                                   }
                                   if (data != nil) {
                                       NSError *jsonParsingError = nil;
                                       NSMutableDictionary *listOmemes = [NSJSONSerialization JSONObjectWithData:data
                                                                                                         options:NSJSONReadingMutableContainers
                                                                                                           error:&jsonParsingError];
                                       if(jsonParsingError == nil) {
                                           if (listOmemes[@"data"] != nil && listOmemes[@"data"][@"memes"] != nil) {
                                               NSArray *memeList = listOmemes[@"data"][@"memes"];
                                               for (NSDictionary *currentMeme in memeList) {
                                                   Meme *meme = [currentMeme createMemeWithDictionary];
                                                   [request setURL:[meme url]];
                                                   [NSURLConnection sendAsynchronousRequest:request
                                                                                      queue:queue
                                                                          completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                                                              if (error != nil) {
                                                                                  NSLog(@"error recieving request: %@", error);
                                                                              }
                                                                              if (data != nil) {
                                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                                      UIImage *image = [UIImage imageWithData:data];
                                                                                      meme.image = image;
                                                                                      if (self.memeView.image == nil) {
                                                                                          self.memeView.image = image;
                                                                                      }
                                                                                      [memes addObject:meme];
                                                                                      [self.memeCollection reloadData];
                                                                                  });
                                                                                  
                                                                              }
                                                                          }
                                                    ];
                                               }
                                           } else {
                                               NSLog(@"an error occur");
                                           }
                                       } else {
                                           NSLog(@"error parsing json");
                                       }
                                   }
                               });
                           }
     ];
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [memes count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cellidentifier"
                                                                           forIndexPath:indexPath];
    UIImageView *view = (UIImageView *)[cell viewWithTag:100];
    view.layer.cornerRadius = 8.0f;
    view.layer.masksToBounds = YES;
    Meme *meme = memes[indexPath.row];
    view.image = meme.image;
    NSLog(@"%f %f", view.image.size.width, view.image.size.height);
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Meme *meme = memes[indexPath.row];
    
    if (!animating) {
        animating = YES;
        [UIView animateKeyframesWithDuration:0.3f
                                       delay:0.0f
                                     options:UIViewKeyframeAnimationOptionCalculationModeCubic
                                  animations:^{
                                      self.memeView.alpha = 0.0f;
                                  } completion:^(BOOL completion){
                                      self.memeView.image = meme.image;
                                      [UIView animateKeyframesWithDuration:0.3f
                                                                     delay:0.0f
                                                                   options:UIViewKeyframeAnimationOptionCalculationModeCubic
                                                                animations:^{
                                                                    self.memeView.alpha = 1.0f;
                                                                    animating = NO;
                                                                } completion:nil];
                                  }];
    }
}

- (void) handleTaps:(UITapGestureRecognizer*)paramSender {
    if ([captions count] < 5) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10 + ([captions count] * 10), 10 + ([captions count] * 10), self.view.frame.size.width, 150)];
        [label setText:@"nailed it!"];
        [label setTextColor:[UIColor whiteColor]];
        [label setShadowColor:[UIColor blackColor]];
        [label setFont:[UIFont fontWithName:@"Helvetica" size:50]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setNumberOfLines:0];
        [label setLineBreakMode:NSLineBreakByWordWrapping];
        [label setUserInteractionEnabled:YES];
        [label enableDragging];
        [captions addObject:label];
        [self.memeView addSubview:label];
    } else {
        NSLog(@"too many captions");
    }
}

- (IBAction)submit:(id)sender {
    NSString *templateID = @"61579";
    NSString *text0 = @"someText";
    NSString *text1 = @"someText";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:
                                                                        [NSString stringWithFormat:@"https://api.imgflip.com/caption_image?template_id=%@&username=soijcm&password=1jessica&text0=%@&text1=%@", templateID, text0, text1]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(data.length) {
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"response: %@", responseString);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
