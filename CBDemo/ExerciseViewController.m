//
//  ExerciseExerciseViewController.m
//  Ardency
//
//  Created by Lin Zhang on 12-7-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ExerciseViewController.h"

@interface ExerciseViewController ()

@end

@implementation ExerciseViewController

@synthesize label = _label;
@synthesize statusLabel = _statusLabel;
@synthesize points = _points;
@synthesize mapView = _mapView;
@synthesize routeLine = _routeLine;
@synthesize routeLineView = _routeLineView;
@synthesize locationManager = _locationManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // setup map view
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.userInteractionEnabled = YES;    
    self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;        
    [self.view addSubview:self.mapView];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    self.label.text = @"GPS正在定位中...";
    self.label.alpha = 0.6;    
    self.label.textAlignment = UITextAlignmentCenter;
    self.label.textColor = [UIColor whiteColor];    
    self.label.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.label];

    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 480-20-44-50, 320, 50)];
    self.statusLabel.text = @"运动状态检测中...";
    self.statusLabel.alpha = 0.6;    
    self.statusLabel.textAlignment = UITextAlignmentCenter;
    self.statusLabel.textColor = [UIColor whiteColor];    
    self.statusLabel.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.statusLabel];

    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(endExercise)];
    self.navigationItem.rightBarButtonItem =  doneItem;
    
    // configure location manager
    // [self configureLocationManager];
    
    [self configureRoutes];
    
    timestamp = 0;
}

- (void)endExercise
{
    return;
    
    // stop the timer
    [timer invalidate];
    timer = nil;
    
    // save the points
    NSString *date = [[NSDate date] description];
        
    NSArray *history = [[NSUserDefaults standardUserDefaults] objectForKey:@"history"];

    NSMutableArray *storedPoints;
    
    if (history) {
        storedPoints = [[NSMutableArray alloc] initWithArray:history];
    } else {
        storedPoints = [[NSMutableArray alloc] init];
    }
            
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i<[_points count]; i++) {
        CLLocation *location = [_points objectAtIndex:i];
        NSString *str = [NSString stringWithFormat:@"%f--%f", 
                         location.coordinate.latitude, location.coordinate.longitude];        
        [array addObject:str];
    }
    
    NSString *length = [NSString stringWithFormat:@"%d", timestamp];
    NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                 date, @"date", array, @"points", length, @"timestamp", nil];
    
    [storedPoints addObject:item];
    
    [[NSUserDefaults standardUserDefaults] setObject:storedPoints forKey:@"history"];
    [[NSUserDefaults standardUserDefaults] synchronize];          
   
    /*
    int count = [self.navigationController viewControllers].count;
    CalorieBurntViewController *controller = [[self.navigationController viewControllers] objectAtIndex:count-2];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];    
    UITableViewCell *cell = [controller.tableView cellForRowAtIndexPath:indexPath];

    cell.textLabel.text = [NSString stringWithFormat:@"已记录运动: %@, 时间: %@",@"Walk", [self prettyTimestamp] ];
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    cell.textLabel.textColor = [UIColor blueColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];

    
    [self.navigationController popViewControllerAnimated:YES];
    */
}

- (void)handleTimer:(NSTimer *)timer
{
    timestamp += 1;
    
    self.label.text = [NSString stringWithFormat:@"时间: %@", [self prettyTimestamp]];
}

- (NSString *)prettyTimestamp
{
    NSString *result;
    if (timestamp < 60) {
        result = [NSString stringWithFormat:@"%d 秒", timestamp];
    } else if (timestamp >= 60 && timestamp < 60*60) {
        result = [NSString stringWithFormat:@"%d 分 %d 秒", timestamp/60, timestamp%60];
    } else if (timestamp >= 60*60 && timestamp < 60*60*24) {
        result = [NSString stringWithFormat:@"%d 时 %d 分 %d 秒", timestamp/(60*60), timestamp%60, timestamp%(60*60)];
    } else {
        result = [NSString stringWithFormat:@"%d 秒", timestamp];
    }
    
    return  result;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.label = nil;
    self.statusLabel = nil;
    self.mapView = nil;
	self.routeLine = nil;
	self.routeLineView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark
#pragma mark Map View

- (void)configureRoutes
{
    // define minimum, maximum points
	MKMapPoint northEastPoint = MKMapPointMake(0.f, 0.f); 
	MKMapPoint southWestPoint = MKMapPointMake(0.f, 0.f); 
	
	// create a c array of points. 
	MKMapPoint* pointArray = malloc(sizeof(CLLocationCoordinate2D) * _points.count);
    
	// for(int idx = 0; idx < pointStrings.count; idx++)
    for(int idx = 0; idx < _points.count; idx++)
	{        
        CLLocation *location = [_points objectAtIndex:idx];  
        CLLocationDegrees latitude  = location.coordinate.latitude;
		CLLocationDegrees longitude = location.coordinate.longitude;		 
        
		// create our coordinate and add it to the correct spot in the array 
		CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
		MKMapPoint point = MKMapPointForCoordinate(coordinate);
		
		// if it is the first point, just use them, since we have nothing to compare to yet. 
		if (idx == 0) {
			northEastPoint = point;
			southWestPoint = point;
		} else {
			if (point.x > northEastPoint.x) 
				northEastPoint.x = point.x;
			if(point.y > northEastPoint.y)
				northEastPoint.y = point.y;
			if (point.x < southWestPoint.x) 
				southWestPoint.x = point.x;
			if (point.y < southWestPoint.y) 
				southWestPoint.y = point.y;
		}
        
		pointArray[idx] = point;        
	}
	
    if (self.routeLine) {
        [self.mapView removeOverlay:self.routeLine];
    }
    
    self.routeLine = [MKPolyline polylineWithPoints:pointArray count:_points.count];
    
    // add the overlay to the map
	if (nil != self.routeLine) {
		[self.mapView addOverlay:self.routeLine];
	}

    // clear the memory allocated earlier for the points
	free(pointArray);	
    
    /*
    double width = northEastPoint.x - southWestPoint.x;
    double height = northEastPoint.y - southWestPoint.y;
    
	_routeRect = MKMapRectMake(southWestPoint.x, southWestPoint.y, width, height);    	
	
    // zoom in on the route. 
	[self.mapView setVisibleMapRect:_routeRect];
    */
}

/*
#pragma mark
#pragma mark Location Manager

- (void)configureLocationManager
{
    // Create the location manager if this object does not already have one.
    if (nil == _locationManager)
        _locationManager = [[CLLocationManager alloc] init];
    
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    _locationManager.distanceFilter = 50;
    [_locationManager startUpdatingLocation];    
    // [_locationManager startMonitoringSignificantLocationChanges];
}

#pragma mark
#pragma mark CLLocationManager delegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    
    // If it's a relatively recent event, turn off updates to save power
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];    
    
    if (abs(howRecent) < 2.0)
    {
        NSLog(@"recent: %g", abs(howRecent));        
        NSLog(@"latitude %+.6f, longitude %+.6f\n", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    }
    
    // else skip the event and process the next one
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    NSLog(@"error: %@",error);
}
*/

#pragma mark
#pragma mark MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    NSLog(@"overlayViews: %@", overlayViews);
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    NSLog(@"overlay: %@", overlay);
	MKOverlayView* overlayView = nil;
	
	if(overlay == self.routeLine)
	{
		//if we have not yet created an overlay view for this overlay, create it now. 
        if (self.routeLineView) {
            [self.routeLineView removeFromSuperview];
        }

        self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine];
        self.routeLineView.fillColor = [UIColor redColor];
        self.routeLineView.strokeColor = [UIColor redColor];
        self.routeLineView.lineWidth = 10;
        
		overlayView = self.routeLineView;		
	}
	
	return overlayView;
}

/*
 - (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
 {
 NSLog(@"mapViewWillStartLoadingMap:(MKMapView *)mapView");
 }
 
 - (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
 {
 NSLog(@"mapViewDidFinishLoadingMap:(MKMapView *)mapView");
 } 
 
 - (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
 {
 NSLog(@"mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error");
 }
 
 - (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
 {
 NSLog(@"mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated");
 NSLog(@"%f, %f", mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude);    
 }

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    NSLog(@"centerCoordinate: %f, %f", mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude);    
}
*/ 

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    NSLog(@"annotation views: %@", views);
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
}

/*
 - (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
 {
 NSLog(@"mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated");
 }
 
 - (void)mapViewWillStartLocatingUser:(MKMapView *)mapView
 {
 NSLog(@"mapViewWillStartLocatingUser:(MKMapView *)mapView");
 }
 
 - (void)mapViewDidStopLocatingUser:(MKMapView *)mapView
 {
 NSLog(@"mapViewDidStopLocatingUser:(MKMapView *)mapView");
 }
 */ 

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude 
                                                      longitude:userLocation.coordinate.longitude];
    // check the zero point
    if  (userLocation.coordinate.latitude == 0.0f ||
         userLocation.coordinate.longitude == 0.0f)
        return;
    
    // check the move distance
    if (_points.count > 0) {        
        CLLocationDistance distance = [location distanceFromLocation:currentLocation];        
        if (distance < 5) 
            return;        
    }        
    
    if (nil == _points) {
        _points = [[NSMutableArray alloc] init];
    }
    
    if (_points.count == 0) {
        timer = [NSTimer scheduledTimerWithTimeInterval: 1
                                                 target: self
                                               selector: @selector(handleTimer:)
                                               userInfo: nil
                                                repeats: YES];
    }
    
    [_points addObject:location];	
    currentLocation = location;

    NSLog(@"points: %@", _points);
    
    [self configureRoutes];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
    [self.mapView setCenterCoordinate:coordinate animated:YES];
}

@end
