//
//  loginViewController.m
//  Buya
//
//  Created by Roberto Dries on 7/11/13.
//  Copyright (c) 2013 Youbba. All rights reserved.
//

#import "loginViewController.h"
#import "BeaconViewController.h"

@interface loginViewController ()

@property (nonatomic,strong) id<FBGraphUser> user;

@end

@implementation loginViewController
@synthesize FBLogin =  _login;
@synthesize FBProfilePic = _profilePic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _login.readPermissions = @[@"basic_info",@"user_location"];
    _login.delegate = self;
    
}

-(void)loginView:(FBLoginView *)loginView handleError:(NSError *)error{
    NSLog(@"OEPSSS");
}

-(void)loginViewShowingLoggedInUser:(FBLoginView *)loginView{
    NSLog(@"User is logged in!");
    //[self performSegueWithIdentifier:@"userLoggedIn" sender:self];
    
    [self.btContinue setHidden:NO];
    //[_login setHidden:YES];
}
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView{
    [self.btContinue setHidden:YES];
    //[_login setHidden:NO];
}
-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user{
    _profilePic.profileID = user.id;
    _profilePic.layer.cornerRadius = 50;
    NSLog(@"%@",user.username);
    _user = user;
    self.lbUsername.text = [NSString stringWithFormat:@"Hello, %@",user.name];
    [_profilePic layoutSubviews];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"userContinue"]||[segue.identifier isEqualToString:@"userLoggedIn"]){
        BeaconViewController *resultController = segue.destinationViewController;
        resultController.user = _user;
    }
}
@end
