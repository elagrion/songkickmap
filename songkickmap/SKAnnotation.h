//
//  SKAnnotation.h
//  songkickmap
//
//  Created by Oleg Agapov on 4/7/13.
//  Copyright (c) 2013 Oleg Agapov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface SKAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSDate* eventDate;
//@property (strong, nonatomic) NSString* artistName;


@end
