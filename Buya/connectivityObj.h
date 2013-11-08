//
//  connectivityObj.h
//  Buya
//
//  Created by Roberto Dries on 7/11/13.
//  Copyright (c) 2013 Youbba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define SSID_notify @"SSID_notification"
#define beacon_notify @"beacon_notifcation"

@interface connectivityObj : NSObject<CLLocationManagerDelegate>

+(instancetype) sharedManager;

- (NSString *) connectedSSID;
- (CLBeacon *) connectedBeacon;
- (void)start;

@end