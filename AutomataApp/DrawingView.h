//
//  draw.h
//  circleGesture
//
//  Created by Stephen Kyles on 9/26/13.
//  Copyright (c) 2013 Blue Owl Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

OBJC_EXTERN const CGFloat kStateDimension;
OBJC_EXTERN const CGFloat kMinCircleWidth;
OBJC_EXTERN const CGFloat kMaxCircleWidth;

@interface AALine : NSObject
@property (nonatomic, weak) UIView *startView;
@property (nonatomic, weak) UIView *endView;
@property (nonatomic, copy) NSString *label;
@property (nonatomic, readonly) CGPoint startPoint;
@property (nonatomic, readonly) CGPoint endPoint;
@property (nonatomic, weak) UIImageView *arrowView;
- (void)positionArrow;
@end

@interface DrawingView : UIView
@property (nonatomic, strong) NSMutableArray *lines; // array of AALine
@end
