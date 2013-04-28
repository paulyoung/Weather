//
//  PLWeatherView.h
//  Weather
//
//  Created by Paul Young on 27/04/2013.
//  Copyright (c) 2013 Paul Young. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLWeatherView : UIView

@property (nonatomic, assign) NSInteger temperature;
@property (nonatomic, retain) NSString *time;
@property (nonatomic, retain) NSString *icon;

- (void)update;

@end
