//
//  SKViewController.m
//  songkickmap
//
//  Created by Oleg Agapov on 3/23/13.
//  Copyright (c) 2013 Oleg Agapov. All rights reserved.
//

#import "SKViewController.h"
#import "SKAnnotation.h"

@interface SKViewController ()

@end

@implementation SKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.fromDatePicker = [[UIDatePicker alloc] init];
	self.fromDatePicker.datePickerMode = UIDatePickerModeDate;
	[self.fromDatePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];

	self.toDatePicker = [[UIDatePicker alloc] init];
	self.toDatePicker.datePickerMode = UIDatePickerModeDate;
	[self.toDatePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];


	UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone target: self action: @selector(finishDate:)];
	[toolbar setItems:[NSArray arrayWithObject: doneButton]];

	self.dateToolbar = toolbar;

	self.fromDateSelect.inputView = self.fromDatePicker;
	self.fromDateSelect.inputAccessoryView = self.dateToolbar;

	self.toDateSelect.inputView = self.toDatePicker;
	self.toDateSelect.inputAccessoryView = self.dateToolbar;
}

- (void) dateChanged: (UIDatePicker*) sender
{
	NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterMediumStyle];
	[formatter setTimeStyle:NSDateFormatterNoStyle];

	UITextField* currField = sender == self.fromDatePicker ? self.fromDateSelect : self.toDateSelect;
	currField.text = [formatter stringFromDate: [sender date]];
}

- (void) finishDate: (id) sender
{
	[self.toDateSelect endEditing: YES];
	[self.fromDateSelect endEditing: YES];

	[self.mapView removeAnnotations: self.modelData];

	NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(eventDate >= %@) AND (eventDate <= %@)", [self.fromDatePicker date], [self.toDatePicker date]];
	NSArray* array = [self.modelData filteredArrayUsingPredicate: predicate];
	[self.mapView addAnnotations: array];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) getInfo
{
	self.modelData = [NSArray array];
	NSURL* artistsURL = [NSURL URLWithString: @"http://api.songkick.com/api/3.0/users/oleg-agapov/artists/tracked.json?per_page=all&apikey=g8AWpOV7AEVTeDj7"];

	NSData* data = [NSData dataWithContentsOfURL: artistsURL];
	NSDictionary* artistsResponse = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];

	NSArray* artistsInfo = [[[artistsResponse objectForKey: @"resultsPage"] objectForKey: @"results"] objectForKey: @"artist"];

	NSDateFormatter* responseFormatter = [[NSDateFormatter alloc] init];
	responseFormatter.dateFormat = @"yyyy-MM-dd";
	NSDateFormatter* displayFormatter = [[NSDateFormatter alloc] init];
	displayFormatter.dateFormat = @"dMMM";

	for (NSDictionary* artist in artistsInfo)
	{
		NSString* name = [artist objectForKey: @"displayName"];
		NSArray* artistIdsArray = [artist objectForKey: @"identifier"];

		

		for (NSDictionary* artistId in artistIdsArray)
		{
			NSURL* eventsURL = [NSURL URLWithString: [[artistId objectForKey: @"eventsHref"] stringByAppendingString: @"?apikey=g8AWpOV7AEVTeDj7"]];

			NSData* data = [NSData dataWithContentsOfURL: eventsURL];
			NSDictionary* eventResponse = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];

			NSArray* eventsArray = [[[eventResponse objectForKey: @"resultsPage"] objectForKey: @"results"] objectForKey: @"event"];
			for (NSDictionary* event in eventsArray)
			{
				NSString* latStr = [[event objectForKey: @"location"] objectForKey: @"lat"];
				CGFloat lat = 0;
				if (![latStr isKindOfClass:[NSNull class]])	lat = [latStr floatValue];

				NSString* lngStr = [[event objectForKey: @"location"] objectForKey: @"lng"];
				CGFloat lng = 0;
				if (![lngStr isKindOfClass:[NSNull class]]) lng = [lngStr floatValue];

				NSDate* start = [responseFormatter dateFromString: [[event objectForKey: @"start"] objectForKey: @"date"]];

				//NSDictionary* dict = @{@"name": name, @"lat": [NSNumber numberWithFloat: lat], @"lan": [NSNumber numberWithFloat: lan]};

				SKAnnotation* annotation = [SKAnnotation new];
				annotation.coordinate = CLLocationCoordinate2DMake(lat, lng);
				annotation.title = name;// stringByAppendingString: [displayFormatter stringFromDate: start]];
				annotation.subtitle = [displayFormatter stringFromDate: start];
				annotation.eventDate = start;
				self.modelData = [self.modelData arrayByAddingObject: annotation];
			}
		}
	}

	[self.mapView addAnnotations: self.modelData];
}


#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
	MKAnnotationView* result = nil;
	if (!(result = [mapView dequeueReusableAnnotationViewWithIdentifier: @"SKConcertAnnotationView"]))
	{
		result = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"SKConcertAnnotationView"];
		result.canShowCallout = YES;
	}
	return result;
}

- (void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	NSLog(@"anotation: %@", view.annotation.title);
}

@end
