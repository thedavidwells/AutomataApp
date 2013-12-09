//
//  AADetailViewController.m
//  AutomataApp
//
//  Created by Ortal on 9/28/13.
//  Copyright (c) 2013 CS454. All rights reserved.
//

#import "AADetailViewController.h"
#import "CircleGesture.h"
#import "DFState.h"
#import "DrawingView.h"
#import "ios_lib.h"

typedef void (^AlertViewClickedButtonAtIndexBlock)(UIAlertView *alertView, NSInteger buttonIndex);

NSString * const kInputSeparator = @", ";
NSString * const kEpsilonString = @"EPS";
NSString * const kRegexChar = @"/";

@interface DrawnState : NSObject
@property (nonatomic, weak) UIImageView *view;
@property (nonatomic, strong) DFState *state;
@end
@implementation DrawnState

- (void)updateImage {
    UIImage *image = [UIImage imageNamed:self.state.acceptingState ? @"accept" : @"state"];
    self.view.image = image;
}

@end

@interface SelfLoop : NSObject
@property (nonatomic, weak) UILabel *label;
@property (nonatomic, weak) UIImageView *view;
@property (nonatomic, weak) DrawnState *state;
@end
@implementation SelfLoop

- (void)updatePosition {
    self.view.center = CGPointMake(self.state.view.center.x, self.state.view.center.y - 50);
    self.label.center = CGPointMake(self.state.view.center.x, self.state.view.center.y - 90);
}

@end

@interface AADetailViewController ()<UIAlertViewDelegate>
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (nonatomic, strong) NSMutableArray *states; // of DrawnState
@property (nonatomic, assign) CGPoint priorPoint;
@property (weak, nonatomic) IBOutlet DrawingView *drawingView;
@property (nonatomic, strong) NSMutableArray *selfLoops; // of SelfLoop
@property (nonatomic, strong) UIFont *inputFont;
@property (weak, nonatomic) UIImageView *startArrow;
@property (weak, nonatomic) IBOutlet UIView *parentView;

@property (nonatomic, strong) AlertViewClickedButtonAtIndexBlock alertViewBlock;
@end

@implementation AADetailViewController

- (DFAutomaton *)automatonForCurrentDrawing {
    if (self.states.count == 0) {
        return nil;
    }
    
    // clear all transitions because we are going to recreate everything
    for (DrawnState *drawnState in self.states) {
        DFState *state = drawnState.state;
        [state removeAllTransitions];
    }
    
    DrawnState *initialState = self.states[0];
    
    for (SelfLoop *selfLoop in self.selfLoops) {
        NSString *input = selfLoop.label.text;
        NSArray *inputs = [input componentsSeparatedByString:kInputSeparator];
        DFState *fromState = selfLoop.state.state;
        DFState *toState = selfLoop.state.state;
        for (NSString *input in inputs) {
            if ([input isEqualToString:kEpsilonString]) {
                [fromState addEpsilonTransitionToState:toState];
            } else if ([input hasPrefix:kRegexChar] && [input hasSuffix:kRegexChar]) {
                NSString *regexInput = [input substringWithRange:NSMakeRange(1, [input length]-2)];
                [fromState addTransition:[DFRegexTransition transitionToState:toState onInputMatch:regexInput]];
            } else {
                [fromState addTransitionToState:toState onInput:input];
            }
        }
    }

    for (AALine *line in self.drawingView.lines) {
        NSString *input = line.label;
        NSArray *inputs = [input componentsSeparatedByString:kInputSeparator];
        DrawnState *startState = [self stateFromView:line.startView];
        DrawnState *endState = [self stateFromView:line.endView];

        DFState *fromState = startState.state;
        DFState *toState = endState.state;
        for (NSString *input in inputs) {
            if ([input isEqualToString:kEpsilonString]) {
                [fromState addEpsilonTransitionToState:toState];
            } else if ([input hasPrefix:kRegexChar] && [input hasSuffix:kRegexChar]) {
                NSString *regexInput = [input substringWithRange:NSMakeRange(1, [input length]-2)];
                [fromState addTransition:[DFRegexTransition transitionToState:toState onInputMatch:regexInput]];
            } else {
                [fromState addTransitionToState:toState onInput:input];
            }
        }
    }
    
    DFAutomaton *automaton = [DFAutomaton automatonWithStartingState:initialState.state];
    return automaton;
}

- (void)updateStartArrow {
    if (self.states.count == 0) {
        self.startArrow.hidden = YES;
        return;
    }
    self.startArrow.hidden = NO;
    DrawnState *state = self.states[0];
    self.startArrow.center = CGPointMake(state.view.center.x - 40, state.view.center.y);
}

- (DrawnState *)stateNearPoint:(CGPoint)point {
    const CGFloat maxDistance = 50;
    CGFloat nearestDistance = 99999;
    DrawnState *nearestState = nil;
    for (DrawnState *state in self.states) {
        CGFloat distance = distanceBetween(point, state.view.center);
        if (!nearestState || (distance < nearestDistance)) {
            nearestState = state;
            nearestDistance = distance;
        }
    }
    if (nearestDistance <= maxDistance) {
        return nearestState;
    } else {
        return nil;
    }
}

- (DrawnState *)stateFromView:(UIView *)view {
    for (DrawnState *state in self.states) {
        if (state.view == view) {
            return state;
        }
    }
    return nil;
}

- (UIImageView *)createStateViewWithName:(NSString *)name atPoint:(CGPoint)centerPoint {
    CGPoint originPoint = CGPointMake(centerPoint.x - (kStateDimension / 2.0), centerPoint.y-(kStateDimension/2.0));
    
    // create imageview for new state
    UIImageView *singleState = [[UIImageView alloc] initWithFrame:CGRectMake(originPoint.x, originPoint.y, kStateDimension, kStateDimension)];
    //singleState.image = [UIImage imageNamed:@"state"];
    singleState.userInteractionEnabled = YES;
    
    // state label
    UILabel *stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kStateDimension, kStateDimension)];
    stateLabel.text = name;
    stateLabel.textAlignment = NSTextAlignmentCenter;
    [singleState addSubview:stateLabel];
    
    // attach long press gesture to the imageview
    UIGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [singleState addGestureRecognizer:longPress];
    
    // add double tap gesture to the imageview
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    [singleState addGestureRecognizer:doubleTapRecognizer];
    
    [self.parentView addSubview:singleState];
    return singleState;
}

- (void)addTransitionFromState:(DrawnState *)startState toState:(DrawnState *)endState onInput:(NSString *)input {
    if (startState == endState) {
        // draw a self loop
        SelfLoop *selfLoop = [SelfLoop new];
        selfLoop.state = startState;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        label.text = input;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = self.inputFont;
        selfLoop.label = label;
        [self.parentView addSubview:label];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selfLoop"]];
        selfLoop.view = imageView;
        [self.parentView addSubview:imageView];
        [selfLoop updatePosition];
        [self.selfLoops addObject:selfLoop];
        return;
    }
    
    AALine *line = [AALine new];
    line.startView = startState.view;
    line.endView = endState.view;
    line.label = input;
    UIImageView *arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
    [self.parentView addSubview:arrowImage];
    line.arrowView = arrowImage;
    [self.drawingView.lines addObject:line];
    [self.drawingView setNeedsDisplay];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"timeStamp"] description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    UIImageView *startArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"initialArrow"]];
    [self.parentView addSubview:startArrow];
    self.startArrow = startArrow;
    self.startArrow.hidden = YES;
    self.inputFont = [UIFont systemFontOfSize:18]; // TODO: use this elsewhere as well
    self.states = [NSMutableArray array];
    self.selfLoops = [NSMutableArray array];
    
    // add custom circle gesture recognizer
    CircleGesture *circleRecognizer = [[CircleGesture alloc] initWithTarget:self action:@selector(handleCircleGesture:)];
    [self.parentView addGestureRecognizer:circleRecognizer];
    
    [self configureView];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController {
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Gesture Events

- (void)handleCircleGesture:(CircleGesture *)recognizer {
    NSValue *value = recognizer.points[0];
    CGPoint firstTouchPoint = [value CGPointValue];
    if (recognizer.shapeRecognized == AAShapeRecognizedCircle) {
        // find first touch point of successful circle
        DrawnState *drawnState = [DrawnState new];
        NSString *stateName = [NSString stringWithFormat:@"q%d", self.states.count];
        drawnState.state = [DFState stateWithName:stateName];
        drawnState.view = [self createStateViewWithName:stateName atPoint:recognizer.centerPoint];
        [drawnState updateImage];
        [self.states addObject:drawnState];
        if (self.states.count == 1) {
            [self updateStartArrow];
        }
    } else if (recognizer.shapeRecognized == AAShapeRecognizedLine) {
        value = recognizer.points[recognizer.points.count-1];
        CGPoint lastTouchPoint = [value CGPointValue];
        
        DrawnState *startState = [self stateNearPoint:firstTouchPoint];
        DrawnState *endState = [self stateNearPoint:lastTouchPoint];
        if (!startState || !endState) {
            return; // can only draw a connection between two lines
        }
        
        // valid line drawn, so now ask for an input string
        UIAlertView *getInputStringAlert = [[UIAlertView alloc] initWithTitle:@"Input String"
                                                                    message:@"Enter a string for the input."
                                                                   delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                          otherButtonTitles:@"OK", nil];
        getInputStringAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [self showAlertView:getInputStringAlert
                  withBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                      if (buttonIndex == alertView.cancelButtonIndex) {
                          // cancel tapped, do nothing
                          return;
                      }
                      
                      UITextField *textField = [alertView textFieldAtIndex:0];
                      [self addTransitionFromState:startState toState:endState onInput:textField.text];
                  }];
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)recognizer {
    // once long press begins, apply shadow
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        recognizer.view.layer.shadowOffset = CGSizeMake(0, 5);
        recognizer.view.layer.shadowRadius = 5;
        recognizer.view.layer.shadowOpacity = 0.4;
    }
    
    // once long press state has changed, move state
    UIView *view = recognizer.view;
    CGPoint point = [recognizer locationInView:view.superview];
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint center = view.center;
        center.x += point.x - self.priorPoint.x;
        center.y += point.y - self.priorPoint.y;
        view.center = center;
        [self updateStartArrow]; // TODO: doesn't need to be called each time
        [self.drawingView setNeedsDisplay]; // update lines
    }
    self.priorPoint = point;
    
    // once long press has ended, remove shadow
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        recognizer.view.layer.shadowOpacity = 0.0;
        [self updateStartArrow]; // TODO: doesn't need to be called each time
        [self.drawingView setNeedsDisplay]; // update lines
    }
}

- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)recognizer {
    // toggle acceptance of the state
    DrawnState *state = [self stateFromView:recognizer.view];
    assert(state);
    state.state.acceptingState = !state.state.acceptingState;
    [state updateImage];
}

#pragma mark - UIAlertViewDelegate

- (void)showAlertView:(UIAlertView *)alertView withBlock:(AlertViewClickedButtonAtIndexBlock)block {
    [alertView show];
    self.alertViewBlock = block;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    self.alertViewBlock(alertView, buttonIndex);
    self.alertViewBlock = nil;
}


@end
