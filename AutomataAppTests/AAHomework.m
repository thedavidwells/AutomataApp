//
//  AAHomework.m
//  AutomataApp
//
//  Created by Ortal on 10/5/13.
//  Copyright (c) 2013 CS454. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DFAutomaton.h"
#import "DFAutomaton+Homework.h"
#import "DFAutomaton+Samples.h"

@interface AAHomework : XCTestCase

@end

@implementation AAHomework

- (void)setUp {
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown {
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testProject1 {
    NSLog(@"Part 1.");
    NSLog(@"-------------------------------------------------------------------");
    
    NSLog(@"Part 2.");
    NSLog(@"-------------------------------------------------------------------");
    DFAutomaton *autom = [DFAutomaton automatonForAllNumbersNearlyDivisibleBy:11];
    XCTAssertTrue([autom determineType] == DFAutomatonTypeNFA, @"Should be a normal NFA.");
    NSLog(@"\n%@", [autom prettyPrint]);

    NSLog(@"Part 3.");
    NSLog(@"-------------------------------------------------------------------");
    NSLog(@"Note: this can take up to a minute.");
    const NSInteger kNearlyDivisibleBy = 7;
    const NSInteger kNumberOfDigits = 50;
    autom = [DFAutomaton automatonForAllNumbersNearlyDivisibleBy:kNearlyDivisibleBy];
    autom = [autom convertToDFA];
    XCTAssertTrue([autom determineType] == DFAutomatonTypeDFA, @"Should be converted to a DFA.");
    [autom removeUnreachableStates];
    [autom minimizeDFA];
    NSLog(@"Number of minimized states when k=%d: %d", kNearlyDivisibleBy, [autom allStates].count);

    NSLog(@"Part 4.");
    NSLog(@"-------------------------------------------------------------------");
    NSLog(@"Note: this can take up to a minute.");
    /// matrix[i][j] = the number of transitions from state i to state j in DFA.
    NSMutableArray *matrix = [NSMutableArray array];
    NSArray *states = [[autom allStates] allObjects];
    for (DFState *stateRow in states) {
        NSMutableArray *row = [NSMutableArray array];
        for (DFState *stateCol in states) {
            NSInteger numberOfTransitions = 0;
            for (DFTransition *transition in stateRow.transitions) {
                if (transition.toState == stateCol) {
                    numberOfTransitions++;
                }
            }
            [row addObject:@(numberOfTransitions)];
        }
        [matrix addObject:row];
    }
    
    /// column vector v of order m by 1 where v[i] = 1 if i is an accepting state, 0 else.
    NSMutableArray *vectorMatrix = [NSMutableArray array];
    for (DFState *state in states) {
        [vectorMatrix addObject:state.acceptingState ? @[@1] : @[@0]];
    }

    NSArray *resultMatrix;
    resultMatrix = [DFUtils raiseMatrix:matrix toPower:kNumberOfDigits];
    resultMatrix = [DFUtils multiplyMatrix:resultMatrix byMatrix:vectorMatrix];
    
    NSNumber *resultValue = resultMatrix[0][0]; // Our answer is the first item in the first row
    NSLog(@"Result value\n%@", resultValue);
}

@end
