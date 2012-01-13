//
//  VenuesViewController.m
//  BarNapkin
//
//  Created by ekingery on 8/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "VenuesViewController.h"

@implementation VenuesViewController

@synthesize locationLabel;
@synthesize venuesTableView;
@synthesize httpVenueData;
@synthesize venueData;
@synthesize newVenue;
@synthesize userLocation;
@synthesize currentVenueDataCoord;

@synthesize managedObjectContext; 
@synthesize locationManager;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
*/

- (CLLocationManager *)locationManager { 
    if (locationManager != nil) {
		return locationManager;
	}
	
	locationManager = [[CLLocationManager alloc] init];
    //[locationManager setDistanceFilter:kCLDistanceFilterNone];
	[locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
	[locationManager setDelegate:self];
	
	return locationManager;
} 



- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation
{ 
    // set the user's location for global usage / storage
    self.userLocation = newLocation;
    
    //[TODO] - make this a legit static function
    // A number formatter for the latitude and longitude 
    static NSNumberFormatter *numberFormatter = nil; 
    if (numberFormatter == nil) { 
        numberFormatter = [[NSNumberFormatter alloc] init]; 
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle]; 
        [numberFormatter setMaximumFractionDigits:8]; 
    }
    
    CLLocationCoordinate2D userLocationCoordinate = [self.userLocation coordinate]; 

    NSNumber *lat = [NSNumber numberWithDouble:userLocationCoordinate.latitude]; 
    NSNumber *lon = [NSNumber numberWithDouble:userLocationCoordinate.longitude]; 
    
    // test to see if it is necessary to fetch venues
    // match up to four significant digits..
    double lat_dif = fabs([lat doubleValue] - self.currentVenueDataCoord.latitude);
    double lon_dif = fabs([lon doubleValue] - self.currentVenueDataCoord.longitude);
    
    if (lat_dif < .0001 && lon_dif < .0001) {
        locationLabel.text = @"Already fetched venues...";
        return;
    }
    locationLabel.text = @"Fetching venues...";
    
    NSString *lat_str = [numberFormatter stringFromNumber:lat];
    NSString *lon_str = [numberFormatter stringFromNumber:lon];
    
    //[DEBUG] - for app simulator - fake the coords..
    /* [TODO] - this doesn't really work - need to put in venues near sunnyvale
     lat_str = @"34.423453";
     lon_str = @"-119.701771";
     */
    
    // set a coordinate - so we can not duplicate requests
    // [TODO] - reset this value on request failure?
    self.currentVenueDataCoord = [self.userLocation coordinate];
    
    // pull data from venues app
    NSString *urlRequestStr = [NSString stringWithFormat:@"%@/%@?%@&%@",
                               @"http://bn.ztest.ekingery.com",
                               @"get_nearby_venues", lat_str, lon_str];
    
    // create the request
    NSURLRequest *theRequest=
        [NSURLRequest requestWithURL:[NSURL URLWithString:urlRequestStr]
                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                        timeoutInterval:30];
    
    // create the connection with the request and start loading the data
    NSURLConnection *theConnection = [[NSURLConnection alloc]
                                      initWithRequest:theRequest delegate:self];
    if (theConnection) {
        // Create the NSMutableData that will hold the data
        // receivedData is declared as a method instance elsewhere
        httpVenueData=[[NSMutableData data] retain];
    } else {
        // inform the user that the download could not be made
        locationLabel.text = @"Failed to fetch venues...";
    }

} 

- (void)locationManager:(CLLocationManager *)manager 
       didFailWithError:(NSError *)error { 
    // todo - handle error?
} 

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
    
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // receivedData is declared as a method instance elsewhere
    [httpVenueData setLength:0];
}
    
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [httpVenueData appendData:data];
}
          
-(void) setVenueDataFromResponse:(NSString *)venueResults
{              
    //NSString * noResults = @"no results within 30 miles\n";
    
    if (nil == venueResults || 
        [@"no results within 30 miles\n" isEqualToString:venueResults]) 
    {
        // not what we're looking for..
        NSLog(@"No dice fetching venues, results:%@", venueResults);
        locationLabel.text = venueResults;
        venueData = [[NSArray alloc] initWithObjects:@"No venues found w/in 30 miles",nil];
        [self.venuesTableView reloadData];  
        return;
    } 
    
    // parse output into an array
    NSArray *venueLines = [[NSArray alloc] initWithArray:[venueResults componentsSeparatedByString:@"\n"]];
               
    CLLocationCoordinate2D currentVenueCoord; 
               
    //[TODO] - this should stop once venues are cached
    venueData = [[NSMutableArray alloc] init];
               
    // loop through each line, calculating distance from each venue
    for (NSString *venueStr in venueLines) {
               
        NSArray *venueVals = [[NSArray alloc] initWithArray:[venueStr componentsSeparatedByString:@","]];
               
        if (3 != venueVals.count) {
            continue;
        }
               
        //newVenue = (Venue *)[NSEntityDescription insertNewObjectForEntityForName:@"Venue" inManagedObjectContext:managedObjectContext];
        //newVenue.name = @"testname"; //[venueVals objectAtIndex:2];
        //newVenue.latitude = [venueVals objectAtIndex:0];
        //newVenue.longitude = [venueVals objectAtIndex:1];
        NSString *latstr = [venueVals objectAtIndex:0];
        NSString *lonstr = [venueVals objectAtIndex:1];
        NSString *venueName = [venueVals objectAtIndex:2];
        //NSLog(@"venue: name:%@", newVenue.name);
               
        currentVenueCoord.latitude = [latstr doubleValue];
        currentVenueCoord.longitude = [lonstr doubleValue];
               
        CLLocation *venueLocation = [[CLLocation alloc] 
        initWithLatitude:currentVenueCoord.latitude 
        longitude:currentVenueCoord.longitude];
        
        // convert meters to miles
        NSString *distance = [[NSString alloc] initWithFormat:@"%2.2f",
            [venueLocation getDistanceFrom:self.userLocation] / 1609.344];
               
        NSString *table_str = 
            [NSString stringWithFormat:@"%@: %@ miles", venueName, distance]; 
               
        [venueData addObject:table_str];
               
        //[stories addObject:[item copy]];
        // Store what we imported already
        //NSError *error;
        //if (![managedObjectContext save:&error]) {
        // Handle the error.
        //NSLog([error domain]);
        //}
               
    }
    
    // setup the display
    [self.venuesTableView reloadData];  
    locationLabel.text = @"venues loaded successfully";
}
          

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Succeeded! Received %d bytes of data",[httpVenueData length]);

    NSString *test = [[NSString alloc] initWithData:httpVenueData encoding:NSUTF8StringEncoding];
    
    [self setVenueDataFromResponse:test];
    
    // release the connection, and the data object
    [connection release];
    //[TODO] - release this later, was causing crashes
    //[httpVenueData release];
}
          
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    // Start the location manager. 
    [[self locationManager] startUpdatingLocation]; 
    
    venueData = [[NSMutableArray alloc] init];
    //httpVenueData = [[NSMutableData alloc] init];
    
    [super viewDidLoad];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return [venueData count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
   // if(indexPath.section == 0){
        cell.textLabel.text = [venueData objectAtIndex:indexPath.row];
   // }   
    return cell;
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    self.locationManager = nil; 
}


- (void)dealloc {
    [locationLabel release];
    
    [managedObjectContext release]; 
    [locationManager release];     
    [super dealloc];
}


@end
