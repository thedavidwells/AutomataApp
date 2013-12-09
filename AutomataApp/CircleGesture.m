//
//  gesture.m
//  circleGesture
//
//  Created by Stephen Kyles on 9/26/13.
//  Copyright (c) 2013 Blue Owl Labs. All rights reserved.
//

#import "CircleGesture.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "ios_lib.h"
#import "DrawingView.h"

@implementation CircleGesture

- (CGPoint)topmostPoint {
    return [self.points[self.topmostPointIndex] CGPointValue];
}

- (CGPoint)bottommostPoint {
    return [self.points[self.bottommostPointIndex] CGPointValue];
}

- (CGPoint)leftmostPoint {
    return [self.points[self.leftmostPointIndex] CGPointValue];
}

- (CGPoint)rightmostPoint {
    return [self.points[self.rightmostPointIndex] CGPointValue];
}

- (CGPoint)centerPoint {
    return CGPointMake((self.rightmostPoint.x - self.leftmostPoint.x) / 2.0 + self.leftmostPoint.x, (self.bottommostPoint.y - self.topmostPoint.y) / 2.0 + self.topmostPoint.y);
}

// On new touch, start a new array of points
- (void) touchesBegan:(NSSet *) touches withEvent:(UIEvent *) event
{
    self.shapeRecognized = AAShapeRecognizedNone;
    self.points = [NSMutableArray array];
    CGPoint pt = [[touches anyObject] locationInView:self.view];
    [self.points addObject:[NSValue valueWithCGPoint:pt]];
    self.topmostPointIndex = 0;
    self.bottommostPointIndex = 0;
    self.leftmostPointIndex = 0;
    self.rightmostPointIndex = 0;
}

// Add each point to the array
- (void) touchesMoved:(NSSet *) touches withEvent:(UIEvent *) event
{
    CGPoint pt = [[touches anyObject] locationInView:self.view];
    [self.points addObject:[NSValue valueWithCGPoint:pt]];
    [self.view setNeedsDisplay];
    
    NSInteger currentPointIndex = self.points.count - 1;

    if (pt.y < self.topmostPoint.y) {
        self.topmostPointIndex = currentPointIndex;
    }
    if (pt.x < self.leftmostPoint.x) {
        self.leftmostPointIndex = currentPointIndex;
    }
    if (self.bottommostPoint.y < pt.y) {
        self.bottommostPointIndex = currentPointIndex;
    }
    if (self.rightmostPoint.x < pt.x) {
        self.rightmostPointIndex = currentPointIndex;
    }
}

// At the end of touches, determine whether a circle was drawn
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *) event {
    AAShapeRecognized recognizedShape = [self getRecognizedShape];
    self.shapeRecognized = recognizedShape;
    if (recognizedShape == AAShapeRecognizedNone) {
        [self setState:UIGestureRecognizerStateFailed];
    } else {
        [self setState:UIGestureRecognizerStateRecognized];
    }
    [self.view setNeedsDisplay];
    self.pt = CGPointZero;
}

- (AAShapeRecognized)getRecognizedShape {
    if (!self.points) return AAShapeRecognizedNone;
    
    
    NSLog(@"first point %@", [self.points objectAtIndex:0]);
    NSLog(@"last point %@", [self.points lastObject]);
    
    NSValue *t1 = [self.points objectAtIndex:0];
    NSValue *t2 = [self.points lastObject];
    
    NSLog(@"t1 is %@", t1);
    NSLog(@"t2 is %@", t2);
    
    CGPoint p1 = [t1 CGPointValue];
    CGPoint p2 = [t2 CGPointValue];

    if (self.points.count < 5) {
        // we don't have enough points
        return AAShapeRecognizedNone;
    }
    
    // Circle Test 1: The start and end points must be between 60 pixels of each other
    CGFloat distance = distanceBetween(p1, p2);
    if (distance < 60.0f) {
        CGFloat width = self.rightmostPoint.x - self.leftmostPoint.x;
        CGFloat height = self.bottommostPoint.y - self.topmostPoint.y;
        if (kMinCircleWidth <= width && width <= kMaxCircleWidth) {
            if (kMinCircleWidth <= height && height <= kMaxCircleWidth) {
                return AAShapeRecognizedCircle;
            }
        }
    }
    
    // todo: only set to recognized if a line was recognized
    return AAShapeRecognizedLine;
    
    /*
    // Circle Test 2: Count the distance traveled in degrees.
    //CGRect tcircle;
    CGPoint center = CGPointMake(CGRectGetMidX(tcircle), CGRectGetMidY(tcircle));
    float distance = ABS(acos(dotproduct(centerPoint(POINT(0), center), centerPoint(POINT(1), center))));
    for (int i = 1; i < (self.points.count - 1); i++)
        distance += ABS(acos(dotproduct(centerPoint(POINT(i), center), centerPoint(POINT(i+1), center))));
    if ((ABS(distance - 2 * M_PI) < (M_PI / 4.0f))) tcircle = tcircle;
    */
}

@end
