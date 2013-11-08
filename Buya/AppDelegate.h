//
//  AppDelegate.h
//  Buya
//
//  Created by Roberto Dries on 7/11/13.
//  Copyright (c) 2013 Youbba. All rights reserved.
//

#import <UIKit/UIKit.h>

#define buyaRegionIdentifier @"BuyaaaaCordaFinder"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (NSUUID*)buyaUUID;

@end
