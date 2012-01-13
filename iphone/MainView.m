//
//  MainView.m
//  BarNapkin
//
//  Created by ekingery on 8/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MainView.h"


@implementation MainView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
    NSString *hello   = @"Hello, World!";
    CGPoint  location = CGPointMake(10, 20);
    UIFont   *font    = [UIFont systemFontOfSize:24];
    [[UIColor whiteColor] set];
    [hello drawAtPoint:location withFont:font];
}


- (void)dealloc {
    [super dealloc];
}


@end
