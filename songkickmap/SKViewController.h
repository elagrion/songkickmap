//
//  SKViewController.h
//  songkickmap
//
//  Created by Oleg Agapov on 3/23/13.
//  Copyright (c) 2013 Oleg Agapov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface SKViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView* mapView;
@property (strong) NSArray* modelData;

@end
