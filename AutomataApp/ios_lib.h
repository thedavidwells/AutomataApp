#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h> // needed for CALayer (http://stackoverflow.com/a/7813688)


#define DEGREES_TO_RADIANS(degree) ((degree) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(radians) ((radians) * 180/M_PI)

typedef struct {
    CGPoint center;
    CGFloat radius;
} NPCircle;

typedef struct {
    CGFloat Slope;
    CGPoint YIntercept;
} Line;

//Line LineFromPoints(CGPoint point1, CGPoint point2);
double distanceBetween(CGPoint point1, CGPoint point2);

extern const NPCircle NPCircleNull;

NPCircle NPCircleMake(CGFloat centerX, CGFloat centerY, CGFloat radius);
NPCircle NPCircleFromPoints(CGPoint point1, CGPoint point2, CGPoint point3);
CGPoint pointOnCircle(NPCircle circle, CGFloat degrees);

CGFloat angleFromPoints(CGPoint basePoint, CGPoint otherPoint); // returns radians
CGPoint bottomLeftFromCenterAndRotation(CGSize unrotatedSize, CGPoint center, CGFloat degrees);
CGPoint getCenterAfterRotatingViewAnchoredAtBottomLeftCorner(CGSize unrotatedSize, CGPoint bottomLeftCornerAnchor, CGFloat degrees);
CGPoint midpointOfLine(CGPoint startPoint, CGPoint endPoint);
//CGPoint minPoint(CGPoint point1, CGPoint point2);

void setKeyValueForView(UIView *view, NSString *key, id value);
id getKeyValueForView(UIView *view, NSString *key);

@interface ios_lib : NSObject

@end
