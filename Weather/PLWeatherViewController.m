//
//  PLWeatherViewController.m
//  Weather
//
//  Created by Paul Young on 27/04/2013.
//  Copyright (c) 2013 Paul Young. All rights reserved.
//

#import "PLWeatherViewController.h"
#import "AFNetworking.h"

@interface PLWeatherViewController ()
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *state;
@property (nonatomic, retain) NSArray *hourlyForecast;
@end

@implementation PLWeatherViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(locationDetermined)
                                                     name:@"DidDetermineLocationNotification"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(hourlyForecastRetrieved)
                                                     name:@"DidRetrieveHourlyForecastNotification"
                                                   object:nil];
        
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
        [self determineLocationForLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    }
}

- (void)determineLocationForLatitude:(double)latitude longitude:(double)longitude
{
    NSString *urlString = [NSString stringWithFormat:@"http://api.wunderground.com/api/d693c724ca3eb165/geolookup/q/%+.6f,%+.6f.json", latitude, longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            self.city = JSON[@"location"][@"city"];
                                                                                            self.state = JSON[@"location"][@"state"];
                                                                                            
                                                                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"DidDetermineLocationNotification"
                                                                                                                                                object:nil];
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error,  id JSON) {
                                                                                            NSLog(@"%@", error);
                                                                                        }];
    [operation start];
}

- (void)locationDetermined
{
    [self retrieveHourlyForecastForCity:self.city state:self.state];
}

- (void)retrieveHourlyForecastForCity:(NSString *)city state:(NSString *)state
{
    NSString *encodedCity = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)city, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    NSString *urlString = [NSString stringWithFormat:@"http://api.wunderground.com/api/d693c724ca3eb165/hourly/q/%@/%@.json", state, encodedCity];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            self.hourlyForecast = JSON[@"hourly_forecast"];
                                                                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"DidRetrieveHourlyForecastNotification"
                                                                                                                                                object:nil];
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error,  id JSON) {
                                                                                            NSLog(@"%@", error);
                                                                                        }];
    [operation start];
}

- (void)hourlyForecastRetrieved
{
    NSLog(@"%@", self.hourlyForecast[0][@"temp"][@"english"]);
}

@end
