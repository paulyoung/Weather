//
//  PLWeatherView.m
//  Weather
//
//  Created by Paul Young on 27/04/2013.
//  Copyright (c) 2013 Paul Young. All rights reserved.
//

#import "PLWeatherView.h"

@interface PLWeatherView ()
@property (nonatomic, retain) UILabel *temperatureLabel;
@property (nonatomic, retain) UILabel *timeLabel;
@end

@implementation PLWeatherView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:192.0/255.0 green:228.0/255.0 blue:254.0/255.0 alpha:1];
        
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
    }
    return self;
}

- (void)update
{
    self.temperatureLabel.text = [NSString stringWithFormat:@"%d°", self.temperature];
    self.timeLabel.text = self.time;
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
