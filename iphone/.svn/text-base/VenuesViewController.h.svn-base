//
//  VenuesViewController.h
//  BarNapkin
//
//  Created by ekingery on 8/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Venue.h"

@interface VenuesViewController : UIViewController <CLLocationManagerDelegate> {
    IBOutlet UILabel *locationLabel;
    IBOutlet UITableView *venuesTableView;
    NSMutableArray *venueData;
    NSMutableData *httpVenueData;
    CLLocation *userLocation;
    CLLocationCoordinate2D currentVenueDataCoord;
    Venue *newVenue;
    
    NSManagedObjectContext *managedObjectContext; 
    CLLocationManager *locationManager; 
}

-(void) setVenueDataFromResponse:(NSString *)requestResponse;

@property (nonatomic, retain) UILabel *locationLabel;
@property (nonatomic, retain) UITableView *venuesTableView;
@property (nonatomic, retain) NSMutableArray *venueData;
@property (nonatomic, retain) NSMutableData *httpVenueData;
@property (nonatomic, retain) CLLocation *userLocation;
@property (nonatomic) CLLocationCoordinate2D currentVenueDataCoord;

// [TODO] - this may not be necessary (for IB?)
@property (nonatomic, retain) Venue *newVenue;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext; 
@property (nonatomic, retain) CLLocationManager *locationManager; 

@end
