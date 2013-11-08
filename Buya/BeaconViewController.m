//
//  BeaconViewController.m
//  Buya
//
//  Created by Roberto Dries on 7/11/13.
//  Copyright (c) 2013 Youbba. All rights reserved.
//

#import "BeaconViewController.h"
#import "connectivityObj.h"

@interface BeaconViewController ()

@end

@implementation BeaconViewController

-(void)viewWillAppear:(BOOL)animated{
    
    // add observer for ssid notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSSID:)
                                                 name:SSID_notify
                                               object:nil];
    
    
    // add observer for beacon notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleBeacon:)
                                                 name:beacon_notify
                                               object:nil];
    [[connectivityObj sharedManager]start];
    [self showValuesToUser];
}

- (void)handleSSID:(NSNotification *)note{
    NSLog(@"%@",[connectivityObj sharedManager].connectedSSID);
    [self showValuesToUser];
}

- (void)handleBeacon:(NSNotification *)note{
    NSLog(@"%@",[[connectivityObj sharedManager].connectedBeacon.proximityUUID UUIDString]);
    [self showValuesToUser];
}

-(void)sendUserLocation{
    //https://graph.facebook.com/ *username* /picture
    //SSID:slkjqsldf-major-minor,username:sdflsqdjf,picture:picurl
    
    NSString *ssid=[connectivityObj sharedManager].connectedSSID;
    ssid = (ssid)? ssid : @"";
    NSString *beaconData =[NSString stringWithFormat:@"%@-%@",[connectivityObj sharedManager].connectedBeacon.major,[connectivityObj sharedManager].connectedBeacon.minor];
    if([beaconData hasPrefix:@"(null)"] ||  [beaconData hasPrefix:@"(null)"])
        beaconData=@"";
    NSDictionary *json = [[NSDictionary alloc]initWithObjectsAndKeys:ssid,@"SSID",
                          beaconData,@"beacon",
                          [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",_user.username],@"picture",
                          _user.username,@"username", nil];
    
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&err];
    
    [[NSUserDefaults standardUserDefaults] synchronize ];
    NSString *server = [[NSUserDefaults standardUserDefaults] stringForKey:@"preferedServer"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/userlocation/",server]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    
    NSLog(@"POST to server: %@",url);
    NSLog(@"json: %@", json);
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        NSLog(@"Data has been send to server: %@",url);
    }];

}
//change UI
-(void) showValuesToUser{
    [self sendUserLocation];
}


@end
