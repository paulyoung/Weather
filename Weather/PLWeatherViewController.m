//
//  PLWeatherViewController.m
//  Weather
//
//  Created by Paul Young on 27/04/2013.
//  Copyright (c) 2013 Paul Young. All rights reserved.
//

#import "PLWeatherViewController.h"

@interface PLWeatherViewController ()
@property (nonatomic, retain) CLLocationManager *locationManager;
@end

@implementation PLWeatherViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Called in iOS 5
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self handleLocation:newLocation];
}

// Called in iOS 6
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    [self handleLocation:location];
}

- (void)handleLocation:(CLLocation *)location
{
    NSDate *eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    if (abs(howRecent) < 15.0) {
        NSLog(@"latitude %+.6f, longitude %+.6f\n", location.coordinate.latitude, location.coordinate.longitude);
    }
}

@end
