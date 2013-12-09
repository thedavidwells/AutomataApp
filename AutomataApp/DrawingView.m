//
//  draw.m
//  circleGesture
//
//  Created by Stephen Kyles on 9/26/13.
//  Copyright (c) 2013 Blue Owl Labs. All rights reserved.
//

//
//  SKhandDraw.m
//  handDraw
//
//  Created by Stephen Kyles on 9/25/13.
//  Copyright (c) 2013 Blue Owl Labs. All rights reserved.
//

#import "DrawingView.h"
#import "ios_lib.h"

const CGFloat kStateDimension = 52;
const CGFloat kMinCircleWidth = kStateDimension - 20;
const CGFloat kMaxCircleWidth = kStateDimension + 35;

@implementation DrawingView
{
    UIBezierPath *path;
    CGPoint pts[5]; // keep track of the four points of a Bezier segment and the first control point of the next segment
    uint ctr;
}

- (void)commonInit {
    self.lines = [NSMutableArray array];
    [self setMultipleTouchEnabled:NO];
    //[self setBackgroundColor:[UIColor whiteColor]];
    path = [UIBezierPath bezierPath];
    [path setLineWidth:2.0];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (CGPoint)midPointOffsetBy:(CGFloat)offsetValue forPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 {
    // the control point should be on a perpendicular line from the midpoint
    CGPoint midpoint = midpointOfLine(point1, point2);
    CGFloat distance = distanceBetween(point1, point2);
    CGFloat angleRadians = angleFromPoints(point1, point2);
    
    angleRadians -= DEGREES_TO_RADIANS(90);
    distance /= offsetValue;
    
    NPCircle circle = NPCircleMake(midpoint.x, midpoint.y, distance);
    return pointOnCircle(circle, RADIANS_TO_DEGREES(angleRadians));
}

- (CGPoint)labelPointForPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 {
    return [self midPointOffsetBy:6.0 forPoint1:point1 andPoint2:point2];
}

- (CGPoint)controlPointForPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 {
    return [self midPointOffsetBy:4.0 forPoint1:point1 andPoint2:point2];
}

- (void)drawRect:(CGRect)rect {
    [path stroke];
    
    // draw lines
    for (AALine *line in self.lines) {
        UIBezierPath *linePath = [UIBezierPath bezierPath];
        [linePath setLineWidth:1.0];
        [linePath moveToPoint:line.startPoint];
        CGPoint controlPoint = [self controlPointForPoint1:line.startPoint andPoint2:line.endPoint];
        [linePath addQuadCurveToPoint:line.endPoint controlPoint:controlPoint];
        [[UIColor blackColor] set];
        [linePath stroke];
        
        CGPoint labelPoint = [self labelPointForPoint1:line.startPoint andPoint2:line.endPoint];
        labelPoint = controlPoint; // TODO: temp fix to ensure line doesn't cross the label
        [line.label drawAtPoint:labelPoint withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18]}];

        [line positionArrow]; // TODO: shouldn't need to do this each time, only if something changed
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    ctr = 0;
    UITouch *touch = [touches anyObject];
    pts[0] = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    ctr++;
    pts[ctr] = p;
    if (ctr == 4)
    {
        // move the endpoint to the middle of the line joining the second control point of the first Bezier segment
        // and the first control point of the second Bezier segment
        pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0);
        [path moveToPoint:pts[0]];
        // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
        [path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]];
        [self setNeedsDisplay];
        
        // debug
//        NSLog(@"point 0 is %@", NSStringFromCGPoint(pts[0]));
        //NSLog(@"point 1 is %@", NSStringFromCGPoint(pts[1]));
        //NSLog(@"point 2 is %@", NSStringFromCGPoint(pts[2]));
//        NSLog(@"point 3 is %@", NSStringFromCGPoint(pts[3]));
//        NSLog(@"point 4 is %@", NSStringFromCGPoint(pts[4]));
        
        // replace points and get ready to handle the next segment
        pts[0] = pts[3];
        pts[1] = pts[4];
        ctr = 1;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //[self drawBitmap];
    [self setNeedsDisplay];
    [path removeAllPoints];
    ctr = 0;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}


@end

@implementation AALine

const CGFloat kAngleDelta = 25;

- (CGPoint)startPoint {
    CGFloat startAngleRads = angleFromPoints(self.startView.center, self.endView.center);
    CGFloat startAngleDegs = RADIANS_TO_DEGREES(startAngleRads) - kAngleDelta;
    
    CGPoint result = self.startView.center;
    NPCircle stateCircle = NPCircleMake(result.x, result.y, kStateDimension/2);
    result = pointOnCircle(stateCircle, startAngleDegs);
    return result;
}
- (CGPoint)endPoint {
    CGFloat endAngleRads = angleFromPoints(self.endView.center, self.startView.center);
    CGFloat endAngleDegs = RADIANS_TO_DEGREES(endAngleRads) + kAngleDelta;
    
    CGPoint result = self.endView.center;
    NPCircle stateCircle = NPCircleMake(result.x, result.y, kStateDimension/2);
    result = pointOnCircle(stateCircle, endAngleDegs);
    return result;
}

- (void)positionArrow {
    self.arrowView.center = self.endPoint;
    CGFloat startAngleRads = angleFromPoints(self.startView.center, self.endView.center);
    CGFloat startAngleDegs = RADIANS_TO_DEGREES(startAngleRads) + kAngleDelta + 180;
    startAngleRads = DEGREES_TO_RADIANS(startAngleDegs);
    
    //self.arrowView.transform = CGAffineTransformIdentity;
    CGAffineTransform transform = CGAffineTransformMakeRotation(startAngleRads);
    self.arrowView.transform = transform;
}

@end