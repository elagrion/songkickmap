//
//  SKViewController.m
//  songkickmap
//
//  Created by Oleg Agapov on 3/23/13.
//  Copyright (c) 2013 Oleg Agapov. All rights reserved.
//

#import "SKViewController.h"

@interface SKViewController ()

@end

@implementation SKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) getInfo
{
	self.modelData = [NSArray array];
	NSURL* artistsURL = [NSURL URLWithString: @"http://api.songkick.com/api/3.0/users/oleg-agapov/artists/tracked.json?apikey=g8AWpOV7AEVTeDj7"];

	NSData* data = [NSData dataWithContentsOfURL: artistsURL];
	NSDictionary* artistsResponse = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];


	NSArray* artistsInfo = [[[artistsResponse objectForKey: @"resultsPage"] objectForKey: @"results"] objectForKey: @"artist"];

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
				CGFloat lat = [[[event objectForKey: @"location"] objectForKey: @"lat"] floatValue];
				CGFloat lan = [[[event objectForKey: @"location"] objectForKey: @"lan"] floatValue];

				NSDictionary* dict = @{@"name": name, @"lat": [NSNumber numberWithFloat: lat], @"lan": [NSNumber numberWithFloat: lan]};

				self.modelData = [self.modelData arrayByAddingObject: dict];
			}
		}
	}

	//now we have array with concerts. LETS SHOW IT ON MAP!!!

	
}

@end
