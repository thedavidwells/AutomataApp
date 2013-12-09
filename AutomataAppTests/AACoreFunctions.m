//
//  AACoreFunctions.m
//  AutomataApp
//
//  Created by Ortal on 10/5/13.
//  Copyright (c) 2013 CS454. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DFAutomaton.h"


@interface AACoreFunctions : XCTestCase

@end

@implementation AACoreFunctions

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}



- (void)testAutomatonStateMethods {
    //XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    // This is an automaton from page 68 of the book Introduction to Automata Theory Laungages and computation by John E. Hopcroft and Jeffrey D. Ullman
    NSDictionary *states = [DFState statesWithNames:[DFUtils arrayFromString:@"abcd"]];
    
    // ->a --0--> b <--0-- c <--0-- d
    //   a <--0-- b
    [states[@"a"] addTransitionToState:states[@"b"] onInput:@"0"];
    [states[@"b"] addTransitionToState:states[@"a"] onInput:@"0"];
    [states[@"c"] addTransitionToState:states[@"b"] onInput:@"0"];
    [states[@"d"] addTransitionToState:states[@"c"] onInput:@"0"];
    DFAutomaton *autom = [DFAutomaton automatonWithStartingState:states[@"a"]];
    XCTAssertTrue(([[autom reachableStates] isEqualToSet:DFPair(states[@"a"], states[@"b"])]), @"Reachable states.");
    XCTAssertTrue(([[autom allStates] isEqualToSet:[NSSet setWithArray:@[states[@"a"], states[@"b"], states[@"c"], states[@"d"]]]]), @"All states.");
    XCTAssertTrue(([[autom unreachableStates] isEqualToSet:DFPair(states[@"c"], states[@"d"])]), @"Unreachable states.");
    
    [autom removeUnreachableStates];
    XCTAssertTrue(([[autom allStates] isEqualToSet:[NSSet setWithArray:@[states[@"a"], states[@"b"]]]]), @"Unrechable states should have been removed.");
}

- (void)testMinimizeByCombiningThreeStates {
    NSDictionary *states = [DFState statesWithNames:[DFUtils arrayFromString:@"abcd"] acceptingStateNames:@[@"e"]];
    [states[@"a"] addTransitionsDictionary:@
     {
         @"0": states[@"b"],
         @"1": states[@"c"],
         @"2": states[@"d"],
     }];
    [states[@"b"] addTransitionsDictionary:@
     {
         @"0": states[@"a"],
         @"1": states[@"b"],
         @"2": states[@"e"],
     }];
    [states[@"c"] addTransitionsDictionary:@
     {
         @"0": states[@"a"],
         @"1": states[@"c"],
         @"2": states[@"e"],
     }];
    [states[@"d"] addTransitionsDictionary:@
     {
         @"0": states[@"a"],
         @"1": states[@"d"],
         @"2": states[@"e"],
     }];
    [states[@"e"] addTransitionToState:states[@"e"] onInputCharacters:@"012"];
    DFAutomaton *actualAutom = [DFAutomaton automatonWithStartingState:states[@"a"]];
    XCTAssertTrue([actualAutom determineType] == DFAutomatonTypeDFA, @"Should be a valid DFA.");
    
    states = [DFState statesWithNames:@[@"a", @"[b,c,d]"] acceptingStateNames:@[@"e"]];
    [states[@"a"] addTransitionToState:states[@"[b,c,d]"] onInputCharacters:@"012"];
    [states[@"[b,c,d]"] addTransitionsDictionary:@
     {
         @"0": states[@"a"],
         @"1": states[@"[b,c,d]"],
         @"2": states[@"e"],
     }];
    [states[@"e"] addTransitionToState:states[@"e"] onInputCharacters:@"012"];
    DFAutomaton *expectedAutom = [DFAutomaton automatonWithStartingState:states[@"a"]];
    XCTAssertTrue([expectedAutom determineType] == DFAutomatonTypeDFA, @"Should be a valid DFA.");
    
    XCTAssertFalse([actualAutom isEqualToAutomaton:expectedAutom], @"Haven't minimized yet.");
    [actualAutom minimizeDFA];
    XCTAssertTrue([actualAutom isEqualToAutomaton:expectedAutom], @"Three states should have been combined into one.");
}

- (void)testMulitplyMatrix {
    NSArray *matrix1 = @[@[@3, @4, @2]];
    NSArray *matrix2 = @
    [
     @[@13, @9, @7, @15],
     @[@8, @7, @4, @6],
     @[@6, @4, @0, @3],
    ];
    NSArray *result = [DFUtils multiplyMatrix:matrix1 byMatrix:matrix2];
    NSArray *expectedMatrix = @[@[@83, @63, @37, @75]];
    XCTAssertEqualObjects(result, expectedMatrix, @"Multiply matrix (1x3) X (3x4).");
    
    matrix1 = @
    [
     @[@1, @2],
     @[@3, @4],
     ];
    matrix2 = @
    [
     @[@2, @0],
     @[@1, @2],
     ];
    result = [DFUtils multiplyMatrix:matrix1 byMatrix:matrix2];
    expectedMatrix = @
    [
     @[@4, @4],
     @[@10, @8],
     ];
    XCTAssertEqualObjects(result, expectedMatrix, @"Multiply matrix (2x2) X (2x2).");

    result = [DFUtils multiplyMatrix:matrix2 byMatrix:matrix1];
    expectedMatrix = @
    [
     @[@2, @4],
     @[@7, @10],
     ];
    XCTAssertEqualObjects(result, expectedMatrix, @"Multiply matrix (2x2) X (2x2), reverse should not be the same.");
    
    // TODO: test multiplying by the same matrix several times
}

- (void)testMatrixPower {
    // wolfram alpha query: {{13, 9, 7, 15},{8, 7, 4, 6}, {6,4,0,3}, {5,2,3,1}}^4
    NSArray *matrix, *actualMatrix, *expectedMatrix;
    
    matrix = @
    [
     @[@13, @9, @7, @15],
     @[@8, @7, @4, @6],
     @[@6, @4, @0, @3],
     @[@5, @2, @3, @1],
     ];
    
    actualMatrix = [DFUtils raiseMatrix:matrix toPower:1];
    expectedMatrix = matrix;
    XCTAssertEqualObjects(actualMatrix, expectedMatrix, @"1st power should work.");
    
    expectedMatrix = @
    [
     @[@230236, @156607, @110486, @192639],
     @[@139968, @95249, @67120, @117204],
     @[@84125, @57299, @40347, @70653],
     @[@68692, @46758, @32878, @57571],
     ];
    actualMatrix = [DFUtils raiseMatrix:matrix toPower:4];
    XCTAssertEqualObjects(actualMatrix, expectedMatrix, @"4th power should work.");
    
    expectedMatrix = @
    [
     @[@5872035, @3995595, @2815997, @4917279],
     @[@3570316, @2429343, @1712384, @2989578],
     @[@2147364, @1460912, @1030030, @1797363],
     @[@1752183, @1192188, @840589, @1467133],
     ];
    actualMatrix = [DFUtils raiseMatrix:matrix toPower:5];
    XCTAssertEqualObjects(actualMatrix, expectedMatrix, @"5th power should work.");
}

@end
