//
//  PLWeatherView.m
//  Weather
//
//  Created by Paul Young on 27/04/2013.
//  Copyright (c) 2013 Paul Young. All rights reserved.
//

#import "PLWeatherView.h"

#import <CoreText/CoreText.h>

@interface PLWeatherView ()

@property (nonatomic, retain) UILabel *iconLabel;
@property (nonatomic, retain) UILabel *temperatureLabel;
@property (nonatomic, retain) UILabel *timeLabel;

@end

@implementation PLWeatherView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _temperatureLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 210, 100)];
        _temperatureLabel.font = [UIFont fontWithName:@"PT Sans" size:100.0];
        _temperatureLabel.textColor = [UIColor whiteColor];
        _temperatureLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_temperatureLabel];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 100, 200, 40)];
        _timeLabel.font = [UIFont fontWithName:@"PT Sans" size:18.0];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_timeLabel];
        
        _iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(220, 20, 80, 100)];
        _iconLabel.font = [UIFont fontWithName:@"SSForecast" size:80.0];
        _iconLabel.textColor = [UIColor whiteColor];
        _iconLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_iconLabel];
    }
    return self;
}

- (void)updateWithTemperature:(NSInteger)temperature time:(NSString *)time icon:(NSString *)icon
{
    self.temperatureLabel.text = [NSString stringWithFormat:@"%d°", temperature];
    self.timeLabel.text = time;
    
    
    if ([icon isEqualToString:@"rainy"]) {
        self.iconLabel.text = @"\U00002614";
    } else if ([icon isEqualToString:@"partly cloudy"]) {
        self.iconLabel.text = @"\U000026C5";
    } else if ([icon isEqualToString:@"partly sunny"]) {
        self.iconLabel.text = @"\U000026C5";
    } else if ([icon isEqualToString:@"moon"]) {
        self.iconLabel.text = @"\U0001F319";
    } else if ([icon isEqualToString:@"clear"]) {
        self.iconLabel.text = @"\U00002600";
    } else if ([icon isEqualToString:@"partlycloudy"]) {
        self.iconLabel.text = @"\U000026C5";
    } else if ([icon isEqualToString:@"cloudynight"]) {
        self.iconLabel.text = @"\U0000F221";
    } else if ([icon isEqualToString:@"rainynight"]) {
        self.iconLabel.text = @"\U0000F226";
    } else if ([icon isEqualToString:@"rainyday"]) {
        self.iconLabel.text = @"\U0000F225";
    } else {
        self.iconLabel.text = @"";
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [_temperatureLabel release];
    [_timeLabel release];
    [_iconLabel release];
    [super dealloc];
}

@end
