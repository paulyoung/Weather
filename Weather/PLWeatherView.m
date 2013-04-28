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
        self.temperatureLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 210, 100)];
        self.temperatureLabel.font = [UIFont fontWithName:@"PT Sans" size:100.0];
        self.temperatureLabel.textColor = [UIColor whiteColor];
        self.temperatureLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.temperatureLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 100, 200, 40)];
        self.timeLabel.font = [UIFont fontWithName:@"PT Sans" size:18.0];
        self.timeLabel.textColor = [UIColor whiteColor];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.timeLabel];
        
        self.iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(220, 20, 80, 100)];
        self.iconLabel.font = [UIFont fontWithName:@"SSForecast" size:80.0];
        self.iconLabel.textColor = [UIColor whiteColor];
        self.iconLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.iconLabel];
    }
    return self;
}

- (void)update
{
    self.temperatureLabel.text = [NSString stringWithFormat:@"%d°", self.temperature];
    self.timeLabel.text = self.time;
    
    
    if ([self.icon isEqualToString:@"rainy"]) {
        self.iconLabel.text = @"\U00002614";
    } else if ([self.icon isEqualToString:@"partly cloudy"]) {
        self.iconLabel.text = @"\U000026C5";
    } else if ([self.icon isEqualToString:@"partly sunny"]) {
        self.iconLabel.text = @"\U000026C5";
    } else if ([self.icon isEqualToString:@"moon"]) {
        self.iconLabel.text = @"\U0001F319";
    } else if ([self.icon isEqualToString:@"clear"]) {
        self.iconLabel.text = @"\U00002600";
    } else if ([self.icon isEqualToString:@"partlycloudy"]) {
        self.iconLabel.text = @"\U000026C5";
    } else if ([self.icon isEqualToString:@"cloudynight"]) {
        self.iconLabel.text = @"\U0000F221";
    } else if ([self.icon isEqualToString:@"rainynight"]) {
        self.iconLabel.text = @"\U0000F226";
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

@end
