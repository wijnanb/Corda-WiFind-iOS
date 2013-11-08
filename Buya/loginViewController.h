//
//  loginViewController.h
//  Buya
//
//  Created by Roberto Dries on 7/11/13.
//  Copyright (c) 2013 Youbba. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

@interface loginViewController : UIViewController<FBLoginViewDelegate>
@property (strong, nonatomic) IBOutlet FBProfilePictureView *FBProfilePic;
@property (strong, nonatomic) IBOutlet FBLoginView *FBLogin;
@property (strong, nonatomic) IBOutlet UILabel *lbUsername;

@property (strong, nonatomic) IBOutlet UIButton *btContinue;

@end
