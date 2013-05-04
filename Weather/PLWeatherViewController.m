//
//  PLWeatherViewController.m
//  Weather
//
//  Created by Paul Young on 27/04/2013.
//  Copyright (c) 2013 Paul Young. All rights reserved.
//

#import "PLWeatherViewController.h"

#import "AFNetworking.h"
#import "PLWeatherView.h"


@interface PLWeatherViewController ()

@property (nonatomic, retain) NSString *city;
@property (nonatomic, assign) NSInteger forecastIndex;
@property (nonatomic, assign) BOOL forecastRetrieved;
@property (nonatomic, retain) NSArray *hourlyForecast;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, assign) NSInteger numHours;
@property (nonatomic, retain) NSString *state;
@property (nonatomic, assign) NSInteger tempForecastIndex;
@property (nonatomic, assign) CGFloat tempWeatherViewY;
@property (nonatomic, assign) CGFloat touchEnd;
@property (nonatomic, assign) CGFloat touchStart;
@property (nonatomic, retain) PLWeatherView *weatherView;

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
        
        [self updateBackgroundColorWithAlpha:1];
        
        _forecastRetrieved = NO;
        _numHours = 24;
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        [_locationManager startMonitoringSignificantLocationChanges];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.weatherView = [[[PLWeatherView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150)] autorelease];
    [self.view addSubview:self.weatherView];
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
    [self determineLocationForLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
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
    [encodedCity release];
    
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
    self.tempWeatherViewY = self.weatherView.frame.origin.y;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint nowPoint = [touches.anyObject locationInView:self.view];
    NSInteger distance = nowPoint.y - self.touchStart;
    
    NSInteger hour = [self getHourOffsetForDistance:distance];
    [self showForecastWithIndexOffset:hour];
    
    CGRect frame = self.weatherView.frame;
    CGFloat yPos = self.tempWeatherViewY + (distance * ((self.view.frame.size.height - self.weatherView.frame.size.height) / self.view.frame.size.height));
    
    if (yPos < 0) {
        yPos = 0;
    } else if (yPos > self.view.frame.size.height - self.weatherView.frame.size.height) {
        yPos = self.view.frame.size.height - self.weatherView.frame.size.height;
    }
    
    frame.origin.y = yPos;
    self.weatherView.frame = frame;
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
        
        NSInteger temperature = [self.hourlyForecast[index][@"temp"][@"english"] intValue];
        NSString *icon = self.hourlyForecast[index][@"icon"];
        
        NSInteger hour = [self.hourlyForecast[index][@"FCTTIME"][@"hour"] intValue];
        
        //CGFloat a = -0.00694444;
        //CGFloat b = 0.166667;
        //CGFloat c = 0.00000000000000850251;
        
        CGFloat a = -0.00555556;
        CGFloat b = 0.133333;
        CGFloat c = 0.1;
        
        CGFloat alpha = (a * hour * hour) + (b * hour) + c;
        [self updateBackgroundColorWithAlpha:alpha];
        
        NSString *time = self.hourlyForecast[index][@"FCTTIME"][@"civil"];
        NSInteger day = [self.hourlyForecast[index][@"FCTTIME"][@"mday"] intValue];
        
        if (hour >= 19 || hour < 6) {
            icon = [NSString stringWithFormat:@"%@night", icon];
        } else if (hour < 19 && hour >= 6) {
            icon = [NSString stringWithFormat:@"%@day", icon];
        }
        
        NSDate *now = [[NSDate alloc] init];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [calendar components:NSDayCalendarUnit fromDate:now];
        [now release];
        [calendar release];
        NSInteger currentDay = [components day];
        
        if (index == 0) {
            time = @"Now";
        } else {
            if (currentDay == day) {
                time = [NSString stringWithFormat:@"Today %@", time];
            } else {
                time = [NSString stringWithFormat:@"Tomorrow %@", time];
            }
        }
        
        icon = [icon stringByReplacingOccurrencesOfString:@"rain" withString:@"rainy"];
        icon = [icon stringByReplacingOccurrencesOfString:@"mostly" withString:@"partly"];
        icon = [icon stringByReplacingOccurrencesOfString:@"clearnight" withString:@"moon"];
        icon = [icon stringByReplacingOccurrencesOfString:@"clearday" withString:@"clear"];
        icon = [icon stringByReplacingOccurrencesOfString:@"partlycloudyday" withString:@"partlycloudy"];
        icon = [icon stringByReplacingOccurrencesOfString:@"partlycloudynight" withString:@"cloudynight"];
        icon = [icon stringByReplacingOccurrencesOfString:@"tstormsnight" withString:@"rainynight"];
        icon = [icon stringByReplacingOccurrencesOfString:@"chance" withString:@""];
        
        time = [time stringByReplacingOccurrencesOfString:@":00" withString:@""];
        
        [self.weatherView updateWithTemperature:temperature time:time icon:icon];
    }
}

- (void)updateBackgroundColorWithAlpha:(CGFloat)alpha
{
    self.view.backgroundColor = [UIColor colorWithRed:192.0/255.0 green:228.0/255.0 blue:254.0/255.0 alpha:alpha];
}

- (void)setNetworkActivityIndicatorVisible:(BOOL)visible
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:visible];
}

- (void)dealloc
{
    [_city release];
    [_hourlyForecast release];
    [_locationManager release];
    [_state release];
    [_weatherView release];
    [super dealloc];
}

@end
