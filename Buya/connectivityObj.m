//
//  connectivityObj.m
//  Buya
//
//  Created by Roberto Dries on 7/11/13.
//  Copyright (c) 2013 Youbba. All rights reserved.
//

#import "connectivityObj.h"
#import "AppDelegate.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <SystemConfiguration/CaptiveNetwork.h>

@interface connectivityObj ()

@property (nonatomic, strong) CLLocationManager     *locationManager;
@property (nonatomic, strong) CLBeaconRegion        *beaconRegion;
@property (nonatomic, strong) NSString              *latestSSID;
@property (nonatomic, strong) NSMutableSet          *SSIDHistory;
@property (nonatomic, strong) CLBeacon              *latestBeacon;
@property (nonatomic, strong) NSMutableDictionary   *beaconHistory; //key: major, value: (nsarray)minors
@property (nonatomic, strong) NSArray               *beaconsAvailable;
@end

static connectivityObj *_sharedInstance = nil;


@implementation connectivityObj
- (NSArray *) historySSID{
    return _SSIDHistory.allObjects;
}
- (NSArray *) availableBeacons{
    return _beaconsAvailable;
}
- (NSDictionary *) historyBeacons{
    return _beaconHistory;
}
- (NSString *) connectedSSID{
    return self.latestSSID;
}
- (CLBeacon *) connectedBeacon{
    return self.latestBeacon;
}
- (void) setSSID{
    CFArrayRef myArray1 = CNCopySupportedInterfaces();
    if(myArray1){
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray1, 0));
        if(myDict){
            NSDictionary* ssid_info = (__bridge NSDictionary*) myDict;
            NSString *newSSID = [ssid_info objectForKey:@"SSID"];
            [_SSIDHistory addObject:newSSID];
            if(![newSSID isEqualToString:self.latestSSID]){
                [self sendStatus:@"" withType:SSID_notify];
                self.latestSSID = newSSID;
            }
        }
    }
    
}

- (void) sendStatus: (NSString *)notification withType:(NSString *)type{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:type
                                                        object:Nil
                                                      userInfo:@{@"status" : notification}];
}

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[connectivityObj alloc] init];
        _sharedInstance.latestSSID = @"";
        _sharedInstance.beaconHistory = [[NSMutableDictionary alloc]init];
        _sharedInstance.SSIDHistory = [[NSMutableSet alloc]init];
    });
    return _sharedInstance;
}
- (void)start{
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self initRegion];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    [self setSSID];
    
    //keep refreshing every 60min
    [NSTimer scheduledTimerWithTimeInterval: 60.0 target:self selector: @selector(setSSID) userInfo:nil repeats: YES];
}
- (void) initRegion{
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"496E176B-346F-456D-88F1-26D7C2A113AF"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"CordaFinder"];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"Beacon Found");
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"Left Region");
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    //self.beaconFoundLabel.text = @"No";
}

//UUID same for every company
//major -> building X
//minor -> room in building
-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    CLBeacon *chosenOne = [[CLBeacon alloc] init];
    chosenOne = [beacons lastObject];
    
    NSMutableArray *minors = [_beaconHistory objectForKey:chosenOne.major];
    if(minors){
        if(![minors containsObject:chosenOne.minor])
            [minors addObject:chosenOne.minor];
    }else{
        minors = [[NSMutableArray alloc]initWithObjects:chosenOne.minor, nil];
    }
    
    _beaconsAvailable = beacons;
    
    if(!_latestBeacon){
        if(chosenOne.major!=_latestBeacon.major)
            if(chosenOne.minor !=_latestBeacon.minor){
                [self sendStatus:[NSString stringWithFormat:@"minor: %@  major:  %@",chosenOne.minor, chosenOne.major] withType:beacon_notify];
                _latestBeacon = chosenOne;
            }
    }
    
    /*if (beacon.proximity == CLProximityUnknown) {
     self.distanceLabel.text = @"Unknown Proximity";
     } else if (beacon.proximity == CLProximityImmediate) {
     self.distanceLabel.text = @"Immediate";
     } else if (beacon.proximity == CLProximityNear) {
     self.distanceLabel.text = @"Near";
     } else if (beacon.proximity == CLProximityFar) {
     self.distanceLabel.text = @"Far";
     }*/
}




@end
