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
        self.temperatureLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 210, 100)];
        self.temperatureLabel.font = [UIFont fontWithName:@"PT Sans" size:100.0];
        [self addSubview:self.temperatureLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 80, 200, 40)];
        self.timeLabel.font = [UIFont fontWithName:@"PT Sans" size:18.0];
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
