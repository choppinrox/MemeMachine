//
//  ViewController.m
//  MemeMachine
//
//  Created by Nikolai on 10/1/15.
//  Copyright (c) 2015 DigitalArsenal. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotate {
    if (saving) {
        return NO;
    }
    if(currentMeme != nil) {
        [self adjustCaptionsForMeme:currentMeme];
    }
    return  YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (self.view.traitCollection.verticalSizeClass != UIUserInterfaceSizeClassCompact) {
        [self.navigationBar setHidden:YES];
    } else {
        [self.navigationBar setHidden:NO];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGSize size = CGSizeMake(1, 1);
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    [[UIColor whiteColor] setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    clearImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    memes = [[NSMutableArray alloc] initWithCapacity:1];
    
    UITapGestureRecognizer *top = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topTap:)];
    [self.topLabel addGestureRecognizer:top];
    UITapGestureRecognizer *bot = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(botTap:)];
    [self.botLabel addGestureRecognizer:bot];
    
    [self.memeView addSubview:self.container];
    [self.memeView addSubview:self.topLabel];
    [self.memeView addSubview:self.botLabel];
    self.memeView.alpha = 0.0f;
    self.memeCollection.alpha = 0.0f;
    
    self.textField.delegate = self;
    
    actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *save = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.renderView.frame = CGRectMake(0, 0, self.popUpView.image.size.width, self.popUpView.image.size.height);
        self.renderView.image = self.popUpView.image;
        UIGraphicsBeginImageContextWithOptions(self.renderView.image.size, NO, 1.0f);
        [self.renderView.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *data = UIImageJPEGRepresentation(viewImage, 1.0f);
        UIImage *jpgImage = [UIImage imageWithData:data];
        UIImageWriteToSavedPhotosAlbum(jpgImage, nil, nil, nil);
        [UIView animateWithDuration:0.2f animations:^{
            self.popUpBackdrop.alpha = 0.0f;
        } completion:^(BOOL completion) {
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
            saving = NO;
        }];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [UIView animateWithDuration:0.2f animations:^{
            self.popUpBackdrop.alpha = 0.0f;
        } completion:^(BOOL completion) {
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
            saving = NO;
        }];
    }];
    
    [actionSheet addAction:save];
    [actionSheet addAction:cancel];
    
    
    NSString* theURL = @"https://api.imgflip.com/get_memes";
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    NSURL*URL = [NSURL URLWithString:theURL];
    [request setURL:URL];
    [request setCachePolicy:NSURLRequestReloadRevalidatingCacheData];
    [request setTimeoutInterval:40];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil) {
                NSLog(@"error recieving request: %@", error);
            }
            if (data != nil) {
                NSError *jsonParsingError = nil;
                NSMutableDictionary *listOmemes = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonParsingError];
                if(jsonParsingError == nil) {
                    if (listOmemes[@"data"] != nil && listOmemes[@"data"][@"memes"] != nil) {
                        NSArray *memeList = listOmemes[@"data"][@"memes"];
                        for (NSDictionary *current in memeList) {
                            Meme *meme = [current createMemeWithDictionary];
                            [request setURL:[meme url]];
                            [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                if (error != nil) {
                                    NSLog(@"error recieving request: %@", error);
                                }
                                if (data != nil) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        UIImage *image = [UIImage imageWithData:data];
                                        meme.image = image;
                                        if (self.memeView.image == nil) {
                                            self.memeView.image = image;
                                            currentMeme = meme;
                                            [self adjustCaptionsForMeme:meme];
                                            [UIView animateWithDuration:0.6f animations:^{
                                                self.memeView.alpha = 1.0f;
                                                self.memeCollection.alpha = 1.0f;
                                                self.spinner.alpha = 0.0f;
                                            }];
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

- (void)viewDidAppear:(BOOL)animated {
    [UIView animateWithDuration:0.3f animations:^{
        self.spinner.alpha = 1.0f;
    }];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [memes count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cellidentifier" forIndexPath:indexPath];
    UIImageView *view = (UIImageView *)[cell viewWithTag:100];
    view.layer.cornerRadius = 8.0f;
    view.layer.masksToBounds = YES;
    Meme *meme = memes[indexPath.row];
    view.image = meme.image;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Meme *meme = memes[indexPath.row];
    if (currentMeme == meme) {
        return;
    }
    if (!animating) {
        animating = YES;
        self.memeView.image = clearImage;
        [UIView animateKeyframesWithDuration:0.2f delay:0.0f options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
            self.container.alpha = 1.0f;
            [self adjustCaptionsForMeme:meme];
        } completion:^(BOOL completion){
            self.memeView.image = meme.image;
            currentMeme = meme;
            [UIView animateKeyframesWithDuration:0.2f delay:0.0f options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
                self.container.alpha = 0.0f;
                animating = NO;
            } completion:nil];
        }];
    }
}

- (void) topTap:(UITapGestureRecognizer*)sender {
    currentLabel = (UILabel*)[sender view];
    self.textField.text = currentLabel.text;
    [self.textField becomeFirstResponder];
}

- (void) botTap:(UITapGestureRecognizer*)sender {
    currentLabel = (UILabel*)[sender view];
    self.textField.text = currentLabel.text;
    [self.textField becomeFirstResponder];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    textField.text = @"";
    return YES;
}

- (IBAction)textFieldDidChange:(id)sender {
    currentLabel.text = self.textField.text;
}

- (IBAction)didPressFinish:(id)sender {
    [self.textField resignFirstResponder];
}


- (void)adjustCaptionsForMeme:(Meme *)meme {
    CGRect rect;
    CGFloat aspectImage = meme.image.size.width / meme.image.size.height;
    CGFloat aspectView = self.memeView.frame.size.width / self.memeView.frame.size.height;
    
    if (aspectView < aspectImage) {
        rect = CGRectMake(0, 0, self.memeView.frame.size.width , self.memeView.frame.size.width / aspectImage);
        self.container.frame = rect;
    } else {
        rect = CGRectMake(0, 0, self.memeView.frame.size.height * aspectImage, self.memeView.frame.size.height);
        self.container.frame = rect;
    }
    
    self.container.center = self.memeView.center;
    
    self.topLabel.frame = CGRectMake(self.container.frame.origin.x, self.container.frame.origin.y, rect.size.width, rect.size.height / 2);
    self.botLabel.frame = CGRectMake(self.container.frame.origin.x, self.container.frame.origin.y + rect.size.height / 2, rect.size.width, rect.size.height / 2);
}

- (IBAction)submit:(id)sender {
    saving = YES;
    [UIView animateWithDuration:0.3f animations:^{
        self.spinner.alpha = 1.0f;
    }];
    NSString *ID = currentMeme.ID;
    NSString *text0 = [self.topLabel.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *text1 = [self.botLabel.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *url = [NSString stringWithFormat:@"https://api.imgflip.com/caption_image?template_id=%@&username=soijcm&password=1jessica&text0=%@&text1=%@", ID, text0, text1];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: url]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(data.length) {
            NSError *jsonParsingError;
            NSMutableDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonParsingError];
            if (response[@"success"]) {
                NSString *theURL = response[@"data"][@"url"];
                NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
                NSURL*URL = [NSURL URLWithString:theURL];
                [request setURL:URL];
                [request setCachePolicy:NSURLRequestReloadRevalidatingCacheData];
                [request setTimeoutInterval:40];
                NSOperationQueue *queue = [[NSOperationQueue alloc] init];
                [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                    if (error != nil) {
                        NSLog(@"error recieving request: %@", error);
                    }
                    if (data != nil) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIImage *image = [UIImage imageWithData:data];
                            [self presentViewController:actionSheet animated:YES completion:nil];
                            self.popUpView.image = image;
                            [UIView animateWithDuration:0.3f animations:^{
                                self.spinner.alpha = 0.0f;
                                self.popUpBackdrop.alpha = 1.0f;
                            }];
                        });
                        
                    }
                }
                 ];
            }
        }
    }];
}

@end
