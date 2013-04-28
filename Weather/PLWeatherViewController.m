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
@property (nonatomic, assign) CGFloat touchStart;
@property (nonatomic, assign) CGFloat touchEnd;
@property (nonatomic, assign) NSInteger forecastIndex;
@property (nonatomic, assign) BOOL forecastRetrieved;
@property (nonatomic, assign) NSInteger numHours;
@property (nonatomic, assign) NSInteger tempForecastIndex;

@property (nonatomic, assign) NSInteger temperature;
@property (nonatomic, retain) NSString *time;
@property (nonatomic, retain) NSString *icon;
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
        
        self.forecastRetrieved = NO;
        self.numHours = 24;
        
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
    
    [self setNetworkActivityIndicatorVisible:YES];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [self setNetworkActivityIndicatorVisible:NO];
                                                                                            
                                                                                            self.city = JSON[@"location"][@"city"];
                                                                                            self.state = JSON[@"location"][@"state"];
                                                                                            
                                                                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"DidDetermineLocationNotification"
                                                                                                                                                object:nil];
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error,  id JSON) {
                                                                                            [self setNetworkActivityIndicatorVisible:NO];
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
    
    [self setNetworkActivityIndicatorVisible:YES];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [self setNetworkActivityIndicatorVisible:NO];
                                                                                            self.hourlyForecast = JSON[@"hourly_forecast"];
                                                                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"DidRetrieveHourlyForecastNotification"
                                                                                                                                                object:nil];
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error,  id JSON) {
                                                                                            [self setNetworkActivityIndicatorVisible:NO];
                                                                                            NSLog(@"%@", error);
                                                                                        }];
    [operation start];
}

- (void)hourlyForecastRetrieved
{
    self.forecastIndex = 0;
    self.forecastRetrieved = YES;
    self.tempForecastIndex = 0;
    [self showForecastWithIndexOffset:0];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint nowPoint = [touches.anyObject locationInView:self.view];
    self.touchStart = nowPoint.y;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint nowPoint = [touches.anyObject locationInView:self.view];
    NSInteger distance = nowPoint.y - self.touchStart;
    NSInteger hour = [self getHourOffsetForDistance:distance];
    //NSLog(@"hour: %d", hour);
    [self showForecastWithIndexOffset:hour];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesStopped:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesStopped:touches withEvent:event];
}

- (void)touchesStopped:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.touchEnd = 0;
    self.forecastIndex = self.tempForecastIndex;
}

- (NSInteger)getHourOffsetForDistance:(CGFloat)distance
{
    CGFloat deviceHeight = [UIScreen mainScreen].bounds.size.height;
    NSInteger hour = floor((self.numHours / deviceHeight) * distance);
    return hour;
}

- (void)showForecastWithIndexOffset:(NSInteger)offset
{
    if (self.forecastRetrieved) {
        NSInteger index = self.forecastIndex + offset;
        
        if (index < 0) {
            index = 0;
        } else if (index > (self.numHours - 1)) {
            index = self.numHours;
        }

        self.tempForecastIndex = index;
        
        self.temperature = [self.hourlyForecast[index][@"temp"][@"english"] intValue];
        self.icon = self.hourlyForecast[index][@"icon"];
        
        NSInteger hour = [self.hourlyForecast[index][@"FCTTIME"][@"hour"] intValue];

        self.time = self.hourlyForecast[index][@"FCTTIME"][@"civil"];
        NSInteger day = [self.hourlyForecast[index][@"FCTTIME"][@"mday"] intValue];
        
        if (hour >= 19 || hour < 6) {
            self.icon = [NSString stringWithFormat:@"%@night", self.icon];
        } else if (hour < 19 && hour >= 6) {
            self.icon = [NSString stringWithFormat:@"%@day", self.icon];
        }
        
        NSDate *now = [[NSDate alloc] init];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [calendar components:NSDayCalendarUnit fromDate:now];
        NSInteger currentDay = [components day];
        
        if (currentDay == day) {
            self.time = [NSString stringWithFormat:@"Today %@", self.time];
        } else {
            self.time = [NSString stringWithFormat:@"Tomorrow %@", self.time];
        }
        
        self.icon = [self.icon stringByReplacingOccurrencesOfString:@"rain" withString:@"rainy"];
        self.icon = [self.icon stringByReplacingOccurrencesOfString:@"mostly" withString:@"partly"];
        self.icon = [self.icon stringByReplacingOccurrencesOfString:@"clearnight" withString:@"moon"];
        self.icon = [self.icon stringByReplacingOccurrencesOfString:@"clearday" withString:@"clear"];
        self.icon = [self.icon stringByReplacingOccurrencesOfString:@"partlycloudyday" withString:@"partlycloudy"];
        self.icon = [self.icon stringByReplacingOccurrencesOfString:@"partlycloudynight" withString:@"cloudynight"];
        self.icon = [self.icon stringByReplacingOccurrencesOfString:@"tstormsnight" withString:@"rainynight"];
        self.icon = [self.icon stringByReplacingOccurrencesOfString:@"chance" withString:@""];
        
        self.time = [self.time stringByReplacingOccurrencesOfString:@":00" withString:@""];
        
        NSLog(@"%@", self.icon);
        NSLog(@"%@", self.time);
    }
}

- (void)setNetworkActivityIndicatorVisible:(BOOL)visible
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:visible];
}

@end
