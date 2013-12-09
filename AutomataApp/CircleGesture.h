//
//  gesture.h
//  circleGesture
//
//  Created by Stephen Kyles on 9/26/13.
//  Copyright (c) 2013 Blue Owl Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AAShapeRecognized) {
    AAShapeRecognizedNone,
    AAShapeRecognizedCircle,
    AAShapeRecognizedLine
};

@interface CircleGesture : UIGestureRecognizer

@property (assign) CGPoint pt;
@property (nonatomic, retain) NSMutableArray *points; // of CGPoint (encapuslated by NSValue)
@property (nonatomic, assign) AAShapeRecognized shapeRecognized;
@property (nonatomic, assign) NSInteger topmostPointIndex;
@property (nonatomic, assign) NSInteger bottommostPointIndex;
@property (nonatomic, assign) NSInteger leftmostPointIndex;
@property (nonatomic, assign) NSInteger rightmostPointIndex;
@property (nonatomic, readonly) CGPoint topmostPoint;
@property (nonatomic, readonly) CGPoint bottommostPoint;
@property (nonatomic, readonly) CGPoint leftmostPoint;
@property (nonatomic, readonly) CGPoint rightmostPoint;
@property (nonatomic, readonly) CGPoint centerPoint;

@end