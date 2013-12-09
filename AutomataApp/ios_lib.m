#import "ios_lib.h"

const NPCircle NPCircleNull = {0, 0, 0};

//Line LineFromPoints(CGPoint point1, CGPoint point2) {
//    
//}
//
//CGFloat SlopeOfLine(Line line) {
//    return arctan2(
//}

double distanceBetween(CGPoint point1, CGPoint point2) {
    double dx = (point2.x-point1.x);
    double dy = (point2.y-point1.y);
    return sqrt(dx*dx + dy*dy);
}

void setKeyValueForView(UIView *view, NSString *key, id value) {
    // can be used to set arbitrary keys and link them to a view (or any of its subclasses)
    // http://stackoverflow.com/a/400251
    [view.layer setValue:value forKey:key];
}

id getKeyValueForView(UIView *view, NSString *key) {
    return [view.layer valueForKey:key];
}

//void getMinAndMax(CGPoint point1, CGPoint point2, CGPoint &minPoint, CGPoint &maxPoint) {
//    if (point1.x < point2.x && point1.y < point2.y) {
//        minPoint = point1;
//        maxPoint = point2;
//        return;
//    } else if (point2.x < point1.x && point2.y < point1.y) {
//        minPoint = point2;
//        maxPoint = point1;
//        return;
//    } else {
//        // x1 < x2 and y2 < y1
//    }
//}
//
//CGPoint minPoint(CGPoint point1, CGPoint point2) {
//}

NPCircle NPCircleMake(CGFloat centerX, CGFloat centerY, CGFloat radius) {
    NPCircle c;
    c.center.x = centerX;
    c.center.y = centerY;
    c.radius = radius;
    return c;
}

CGPoint pointOnCircle(NPCircle circle, CGFloat degrees) {
    // note: degrees starts at right position, and then goes clockwise (rather than counter clockwise)
    // due to the grid in iOS starting at the top left rather than bottom left.
    CGFloat x = cos(DEGREES_TO_RADIANS(degrees)) * circle.radius + circle.center.x;
    CGFloat y = sin(DEGREES_TO_RADIANS(degrees)) * circle.radius + circle.center.y;
    return CGPointMake(x, y);
}

NPCircle NPCircleFromPoints(CGPoint point1, CGPoint point2, CGPoint point3) {
    float bx = point1.x; float by = point1.y;
    float cx = point2.x; float cy = point2.y;
    float dx = point3.x; float dy = point3.y;
    float temp = cx*cx+cy*cy;
    float bc = (bx*bx + by*by - temp)/2.0;
    float cd = (temp - dx*dx - dy*dy)/2.0;
    float det = (bx-cx)*(cy-dy)-(cx-dx)*(by-cy);
    if (fabs(det) < 1.0e-6) {
        return NPCircleNull;
    }
    det = 1/det;
    
    NPCircle result;
    result.center.x = (bc*(cy-dy)-cd*(by-cy))*det;
    result.center.y = ((bx-cx)*cd-(cx-dx)*bc)*det;
    cx = result.center.x; cy = result.center.y;
    result.radius = sqrt((cx-bx)*(cx-bx)+(cy-by)*(cy-by));
    return result;
}

CGFloat angleFromPoints(CGPoint basePoint, CGPoint otherPoint) {
    //CGFloat baseAngleRadians = atan((otherPoint.y - basePoint.y) / (otherPoint.x - basePoint.x));
    CGFloat baseAngleRadians = atan2(otherPoint.y - basePoint.y, otherPoint.x - basePoint.x);
    return baseAngleRadians;
}

CGPoint getBottomLeftCornerAfterRotatingViewAnchoredInCenter(CGSize unrotatedSize, CGPoint center, CGFloat degrees) {
    return bottomLeftFromCenterAndRotation(unrotatedSize, center, degrees); // todo: rename the other one
}

CGPoint bottomLeftFromCenterAndRotation(CGSize unrotatedSize, CGPoint center, CGFloat degrees) {
    // imagine a square view (100 x 100) that is rotated 45 degrees. If you examine its bottom left using the traditional method, it will be near (0,75). What you actually want, though is (0, 50), since that is where the bottom left corner of the view is now located
    // unrotatedSize: the size of the view when it is not rotated
    CGFloat w = unrotatedSize.width;
    CGFloat h = unrotatedSize.height;
    
    CGFloat hyp = sqrtf(h*h + w*w)/2.0;
    CGFloat angleDeg = RADIANS_TO_DEGREES(asin(w/(sqrtf(h*h + w*w))));
    CGFloat x = hyp * sin(DEGREES_TO_RADIANS(angleDeg + degrees));
    CGFloat y = hyp * sin(DEGREES_TO_RADIANS(90 - angleDeg - degrees));
    return CGPointMake(center.x - x, center.y + y);
}

CGPoint getCenterAfterRotatingViewAnchoredAtBottomLeftCorner(CGSize unrotatedSize, CGPoint bottomLeftCornerAnchor, CGFloat degrees) {
    // the view wants to be anchored at bottomLeft, and it wants to use a specific rotation, so figure out the center needed
    // imagine holding a few cards in your hand and anchoring all of them on the bottom left. now you want to rotate the top one by 10 degrees and still have its bottom left anchored with the other cards.
    
    // first get the coordinates of the bottom left corner as though we rotated the view
    CGPoint cornerDisplacementFromCenter = getBottomLeftCornerAfterRotatingViewAnchoredInCenter(unrotatedSize, CGPointZero, degrees);
    // e.g. if the view is not rotated and its dimensions are (50 x 100), then the displacement will be (-25, 50)
    
    CGPoint centerDisplacementFromCorner = CGPointMake(-cornerDisplacementFromCenter.x, -cornerDisplacementFromCenter.y);
    // e.g. now we have (25, -50), or in other words, the values that need to be added in order to go from the BL corner to the center
    
    return CGPointMake(bottomLeftCornerAnchor.x + centerDisplacementFromCorner.x, bottomLeftCornerAnchor.y + centerDisplacementFromCorner.y);
}

CGPoint midpointOfLine(CGPoint startPoint, CGPoint endPoint) {
    CGPoint result;
    result.x = (ABS(startPoint.x - endPoint.x) / 2.0) + MIN(startPoint.x, endPoint.x);
    result.y = (ABS(startPoint.y - endPoint.y) / 2.0) + MIN(startPoint.y, endPoint.y);
    return result;
}

@implementation ios_lib

@end
