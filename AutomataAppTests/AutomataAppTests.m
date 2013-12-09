//
//  AutomataAppTests.m
//  AutomataAppTests
//
//  Created by Ortal on 9/28/13.
//  Copyright (c) 2013 CS454. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DFAutomaton.h"
#import "DFAutomaton+Homework.h"
#import "DFAutomaton+Samples.h"

@interface AutomataAppTests : XCTestCase

@end

@implementation AutomataAppTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Tests

- (void)testDetermineType {
    // for these examples, assume charcters in language are {0,1,2}.
    DFState *deadState1 = [DFState stateWithName:@"d1"];
    [deadState1 addTransitionToState:deadState1 onInputCharacters:@"012"];
    DFState *deadState2 = [DFState stateWithName:@"d2"];
    [deadState2 addTransitionToState:deadState2 onInputCharacters:@"012"];
    
    // normal DFA (3 transitions)
    DFState *stateA = [DFState stateWithName:@"a"];
    [stateA addTransitionToState:deadState1 onInputCharacters:@"012"];
    DFAutomaton *autom = [DFAutomaton automatonWithStartingState:stateA];
    XCTAssertEqual([autom determineType], DFAutomatonTypeDFA, @"This is a DFA. State A has implemented all 3 inputs.");
    
    // missing input (2 transitions)
    stateA = [DFState stateWithName:@"a"];
    [stateA addTransitionToState:deadState1 onInputCharacters:@"01"];
    autom = [DFAutomaton automatonWithStartingState:stateA];
    XCTAssertEqual([autom determineType], DFAutomatonTypeNFA, @"This is an NFA. State A is missing a transition on the character 2.");

    // missing input (3 transitions)
    stateA = [DFState stateWithName:@"a"];
    [stateA addTransitionToState:deadState1 onInputCharacters:@"01"];
    [stateA addTransitionToState:deadState1 onInputCharacters:@"1"];
    autom = [DFAutomaton automatonWithStartingState:stateA];
    XCTAssertEqual([autom determineType], DFAutomatonTypeNFA, @"This is an NFA. Even though state A has 3 transitions, it is missing a transition on the character 2, and has a duplicate transition on character 1.");

    // duplicate input (4 transitions)
    stateA = [DFState stateWithName:@"a"];
    [stateA addTransitionToState:deadState1 onInputCharacters:@"012"];
    [stateA addTransitionToState:deadState2 onInputCharacters:@"1"];
    autom = [DFAutomaton automatonWithStartingState:stateA];
    XCTAssertEqual([autom determineType], DFAutomatonTypeNFA, @"This is an NFA. State A has duplicate transitions on input 1.");
}

- (void)testIsEqualToAutomaton {
    DFAutomaton *automaton1 = [DFAutomaton automatonForAllNumbersDivisibleBy:3];
    DFAutomaton *automaton2 = [DFAutomaton automatonForAllNumbersDivisibleBy:3];
    XCTAssertTrue([automaton1 isEqualToAutomaton:automaton2], @"");
    automaton1 = [DFAutomaton endsWithIngAutomaton];
    automaton2 = [DFAutomaton endsWithIngAutomaton];
    XCTAssertTrue([automaton1 isEqualToAutomaton:automaton2], @"");
    automaton1 = [DFAutomaton automatonForAllNumbersDivisibleBy:3];
    [automaton1.startingState addTransitionToState:[DFState stateWithName:@"foo"] onInput:@"1"];
    automaton2 = [DFAutomaton automatonForAllNumbersDivisibleBy:3];
    [automaton2.startingState addTransitionToState:[DFState stateWithName:@"foo"] onInput:@"1"];
    XCTAssertTrue([automaton1 isEqualToAutomaton:automaton2], @"Use a modifed DFA to NFA.");
    automaton1 = [DFAutomaton automatonForAllNumbersDivisibleBy:3];
    [automaton1.startingState addTransitionToState:[DFState stateWithName:@"foo"] onInput:@"1"];
    automaton2 = [DFAutomaton automatonForAllNumbersDivisibleBy:3];
    XCTAssertFalse([automaton1 isEqualToAutomaton:automaton2], @"First has more states than second.");
    automaton1 = [DFAutomaton automatonForAllNumbersDivisibleBy:3];
    automaton2 = [DFAutomaton automatonForAllNumbersDivisibleBy:3];
    [automaton2.startingState addTransitionToState:[DFState stateWithName:@"foo"] onInput:@"1"];
    XCTAssertFalse([automaton1 isEqualToAutomaton:automaton2], @"Second has more states than first.");
}

- (void)testEpsilonClosures {
    NSDictionary *states = [DFState statesWithNames:[DFUtils arrayFromString:@"abc"]];
    [states[@"a"] addEpsilonTransitionToState:states[@"b"]];
    [states[@"b"] addEpsilonTransitionToState:states[@"a"]];
    [states[@"b"] addTransitionToState:states[@"c"] onInput:@"1"];
    [states[@"c"] addEpsilonTransitionToState:states[@"b"]];

    NSDictionary *dictionary1 = @{states[@"a"]: @"abc"};
    NSDictionary *dictionary2 = @{states[@"a"]: @"abc"};
    XCTAssertTrue([DFUtils dictionary:dictionary1 isEqualToDictionary:dictionary2], @"Dictionary comparisons don't work as expected.");

    DFAutomaton *autom = [DFAutomaton automatonWithStartingState:states[@"a"]];
    NSDictionary *actualEpsilonClosures = [autom epsilonClosures];
    
    NSDictionary *expectedEpsilonClosures = @
    {
        states[@"a"]: [NSSet setWithArray:@[states[@"a"], states[@"b"]]],
        states[@"b"]: [NSSet setWithArray:@[states[@"a"], states[@"b"]]],
        states[@"c"]: [NSSet setWithArray:@[states[@"a"], states[@"b"], states[@"c"]]],
    };
    
    XCTAssertTrue([DFUtils dictionary:actualEpsilonClosures isEqualToDictionary:expectedEpsilonClosures], @"Class Notes - 9/16. %@ != %@", actualEpsilonClosures, expectedEpsilonClosures);
}

- (void)testStates {
    NSDictionary *states = [DFState statesWithNames:@[@"{}", @"{a}", @"{b}", @"{a,b}"] acceptingStateNames:@[@"{a,c}"]];
    [states[@"{a}"] addTransitionsDictionary:@
     {
         @"0": states[@"{a}"],
         @"1": states[@"{b}"],
     }];
    [states[@"{b}"] addTransitionsDictionary:@
     {
         @"0": states[@"{a,c}"],
         @"1": states[@"{}"],
     }];
    [states[@"{a,c}"] addTransitionsDictionary:@
     {
         @"0": states[@"{a}"],
         @"1": states[@"{a,b}"],
     }];
    [states[@"{a,b}"] addTransitionsDictionary:@
     {
         @"0": states[@"{a,c}"],
         @"1": states[@"{b}"],
     }];
    [states[@"{}"] addTransitionsDictionary:@
     {
         @"0": states[@"{}"],
         @"1": states[@"{}"],
     }];
    DFAutomaton *autom = [DFAutomaton automatonWithStartingState:states[@"{a}"]];
    XCTAssertEqual([autom allStates].count, 5U, @"Should not have any extra states.");
}

- (void)testNFAtoDFA {
    // from Class Notes - 9/11/13
    NSDictionary *states = [DFState statesWithNames:[DFUtils arrayFromString:@"ab"] acceptingStateNames:@[@"c"]];
    [states[@"a"] addTransitionToState:states[@"a"] onInput:@"0"];
    [states[@"a"] addTransitionToState:states[@"b"] onInput:@"0"];
    [states[@"a"] addTransitionToState:states[@"a"] onInput:@"1"];
    [states[@"b"] addTransitionToState:states[@"c"] onInput:@"1"];
    [states[@"c"] addTransitionToState:states[@"c"] onInput:@"0"];
    [states[@"c"] addTransitionToState:states[@"b"] onInput:@"0"];
    DFAutomaton *actualNFA = [DFAutomaton automatonWithStartingState:states[@"a"]];
    XCTAssertTrue([actualNFA determineType] == DFAutomatonTypeNFA, @"This is an NFA because a has two transitions on a 0.");
    DFAutomaton *actualDFA = [actualNFA convertToDFA];
    XCTAssertTrue([actualDFA determineType] == DFAutomatonTypeDFA, @"This should have been converted to a DFA.");

    states = [DFState statesWithNames:@[@"{a}", @"{a,b}"] acceptingStateNames:@[@"{a,c}", @"{a,b,c}"]];
    [states[@"{a}"] addTransitionToState:states[@"{a,b}"] onInput:@"0"];
    [states[@"{a}"] addTransitionToState:states[@"{a}"] onInput:@"1"];
    [states[@"{a,b}"] addTransitionToState:states[@"{a,b}"] onInput:@"0"];
    [states[@"{a,b}"] addTransitionToState:states[@"{a,c}"] onInput:@"1"];
    [states[@"{a,c}"] addTransitionToState:states[@"{a,b,c}"] onInput:@"0"];
    [states[@"{a,c}"] addTransitionToState:states[@"{a}"] onInput:@"1"];
    [states[@"{a,b,c}"] addTransitionToState:states[@"{a,b,c}"] onInput:@"0"];
    [states[@"{a,b,c}"] addTransitionToState:states[@"{a,c}"] onInput:@"1"];
    DFAutomaton *expectedDFA = [DFAutomaton automatonWithStartingState:states[@"{a}"]];
    NSAssert([expectedDFA determineType] == DFAutomatonTypeDFA, @"Should have been a DFA.");
    
    XCTAssertTrue([actualDFA isEqualToAutomaton:expectedDFA], @"Class Notes - 9/11/13 test failed.");
    
    // from Homework 4
    states = [DFState statesWithNames:@[@"a", @"b"] acceptingStateNames:@[@"c"]];
    [states[@"a"] addTransitionsDictionary:@
    {
        @"0": states[@"a"],
        @"1": states[@"b"],
    }];
    [states[@"b"] addTransitionsDictionary:@
     {
         @"0": @[states[@"a"], states[@"c"]],
     }];
    [states[@"c"] addTransitionsDictionary:@
     {
         @"1": @[states[@"a"], states[@"b"]],
     }];
    actualNFA = [DFAutomaton automatonWithStartingState:states[@"a"]];
    XCTAssertTrue([actualNFA determineType] == DFAutomatonTypeNFA, @"This is an NFA because a has two transitions on a 0.");
    actualDFA = [actualNFA convertToDFA];
    XCTAssertTrue([actualDFA determineType] == DFAutomatonTypeDFA, @"This should have been converted to a DFA.");
    
    states = [DFState statesWithNames:@[@"{}", @"{a}", @"{b}", @"{a,b}"] acceptingStateNames:@[@"{a,c}"]];
    [states[@"{a}"] addTransitionsDictionary:@
     {
         @"0": states[@"{a}"],
         @"1": states[@"{b}"],
     }];
    [states[@"{b}"] addTransitionsDictionary:@
     {
         @"0": states[@"{a,c}"],
         @"1": states[@"{}"],
     }];
    [states[@"{a,c}"] addTransitionsDictionary:@
     {
         @"0": states[@"{a}"],
         @"1": states[@"{a,b}"],
     }];
    [states[@"{a,b}"] addTransitionsDictionary:@
     {
         @"0": states[@"{a,c}"],
         @"1": states[@"{b}"],
     }];
    [states[@"{}"] addTransitionsDictionary:@
     {
         @"0": states[@"{}"],
         @"1": states[@"{}"],
     }];
    expectedDFA = [DFAutomaton automatonWithStartingState:states[@"{a}"]];
    NSAssert([expectedDFA determineType] == DFAutomatonTypeDFA, @"Should have been a DFA.");
    XCTAssertEqual([expectedDFA allStates].count, 5U, @"Must have 5 states.");
    XCTAssertEqual([actualDFA allStates].count, 5U, @"Must have 5 states (previous bug). Probably added the starting state twice.");
    
    XCTAssertTrue([actualDFA isEqualToAutomaton:expectedDFA], @"Homework 4 failed.");
}

- (void)testENFAtoDFA {
    // From Book, Page 57. (ENFA -> DFA)
    NSDictionary *states;
    DFAutomaton *actualNFA, *actualDFA, *expectedDFA;
    states = [DFState statesWithNames:@[@"2", @"3"] acceptingStateNames:@[@"1"]];
    [states[@"1"] addTransitionsDictionary:@
     {
         @"": states[@"3"],
         @"b": states[@"2"],
     }];
    [states[@"2"] addTransitionsDictionary:@
     {
         @"a": @[states[@"2"], states[@"3"]],
         @"b": states[@"3"],
     }];
    [states[@"3"] addTransitionsDictionary:@
     {
         @"a": states[@"1"],
     }];
    actualNFA = [DFAutomaton automatonWithStartingState:states[@"1"]];
    XCTAssertTrue([actualNFA determineType] == DFAutomatonTypeENFA, @"This is an ENFA because it has an epsilon transition.");
    actualDFA = [actualNFA convertToDFA];
    XCTAssertTrue([actualDFA determineType] == DFAutomatonTypeDFA, @"This should have been converted to a DFA.");
    
    states = [DFState statesWithNames:@[@"{}", @"{2}", @"{3}", @"{2,3}"] acceptingStateNames:@[@"{1,3}", @"{1,2,3}"]];
    [states[@"{1,3}"] addTransitionsDictionary:@
     {
         @"a": states[@"{1,3}"],
         @"b": states[@"{2}"],
     }];
    [states[@"{2}"] addTransitionsDictionary:@
     {
         @"a": states[@"{2,3}"],
         @"b": states[@"{3}"],
     }];
    [states[@"{3}"] addTransitionsDictionary:@
     {
         @"a": states[@"{1,3}"],
         @"b": states[@"{}"],
     }];
    [states[@"{2,3}"] addTransitionsDictionary:@
     {
         @"a": states[@"{1,2,3}"],
         @"b": states[@"{3}"],
     }];
    [states[@"{}"] addTransitionsDictionary:@
     {
         @"a": states[@"{}"],
         @"b": states[@"{}"],
     }];
    [states[@"{1,2,3}"] addTransitionsDictionary:@
     {
         @"a": states[@"{1,2,3}"],
         @"b": states[@"{2,3}"],
     }];
    expectedDFA = [DFAutomaton automatonWithStartingState:states[@"{1,3}"]];
    NSAssert([expectedDFA determineType] == DFAutomatonTypeDFA, @"Should have been a DFA.");
    XCTAssertTrue([actualDFA isEqualToAutomaton:expectedDFA], @"From Book, Page 57. (ENFA -> DFA).");
}
- (void)testMinimizationWithRemovalOfUnreachableStates {
    // This is an automaton from page 68 of the book Introduction to Automata Theory Laungages and computation by John E. Hopcroft and Jeffrey D. Ullman
    NSDictionary *states = [DFState statesWithNames:[DFUtils arrayFromString:@"abcdefgh"]];
    [states[@"c"] setAcceptingState:YES];
    
    [states[@"a"] addTransitionToState:states[@"b"] onInput:@"0"];
    [states[@"a"] addTransitionToState:states[@"f"] onInput:@"1"];
    [states[@"b"] addTransitionToState:states[@"g"] onInput:@"0"];
    [states[@"b"] addTransitionToState:states[@"c"] onInput:@"1"];
    [states[@"c"] addTransitionToState:states[@"a"] onInput:@"0"];
    [states[@"c"] addTransitionToState:states[@"c"] onInput:@"1"];
    [states[@"d"] addTransitionToState:states[@"c"] onInput:@"0"];
    [states[@"d"] addTransitionToState:states[@"g"] onInput:@"1"];
    [states[@"e"] addTransitionToState:states[@"h"] onInput:@"0"];
    [states[@"e"] addTransitionToState:states[@"f"] onInput:@"1"];
    [states[@"f"] addTransitionToState:states[@"c"] onInput:@"0"];
    [states[@"f"] addTransitionToState:states[@"g"] onInput:@"1"];
    [states[@"g"] addTransitionToState:states[@"g"] onInput:@"0"];
    [states[@"g"] addTransitionToState:states[@"e"] onInput:@"1"];
    [states[@"h"] addTransitionToState:states[@"g"] onInput:@"0"];
    [states[@"h"] addTransitionToState:states[@"c"] onInput:@"1"];
    
    DFAutomaton *fullAutomaton = [DFAutomaton automatonWithStartingState:states[@"a"]];
    XCTAssertTrue([fullAutomaton determineType] == DFAutomatonTypeDFA, @"This should be a valid DFA.");
    [fullAutomaton removeUnreachableStates];
    [fullAutomaton minimizeDFA];
    XCTAssertTrue([fullAutomaton determineType] == DFAutomatonTypeDFA, @"Should still be a DFA.");
    DFAutomaton *actualMinimizedAutomaton = fullAutomaton;
    
    states = [DFState statesWithNames:@[@"[a,e]", @"[b,h]", @"c", @"g", @"f"]];
    [states[@"c"] setAcceptingState:YES];
    [states[@"[a,e]"] addTransitionToState:states[@"[b,h]"] onInput:@"0"];
    [states[@"[a,e]"] addTransitionToState:states[@"f"] onInput:@"1"];
    [states[@"[b,h]"] addTransitionToState:states[@"g"] onInput:@"0"];
    [states[@"[b,h]"] addTransitionToState:states[@"c"] onInput:@"1"];
    [states[@"c"] addTransitionToState:states[@"[a,e]"] onInput:@"0"];
    [states[@"c"] addTransitionToState:states[@"c"] onInput:@"1"];
    [states[@"g"] addTransitionToState:states[@"g"] onInput:@"0"];
    [states[@"g"] addTransitionToState:states[@"[a,e]"] onInput:@"1"];
    [states[@"f"] addTransitionToState:states[@"c"] onInput:@"0"];
    [states[@"f"] addTransitionToState:states[@"g"] onInput:@"1"];
    DFAutomaton *expectedMinimizedAutomaton = [DFAutomaton automatonWithStartingState:states[@"[a,e]"]];
        
    XCTAssertTrue([actualMinimizedAutomaton isEqualToAutomaton:expectedMinimizedAutomaton], @"Minimization algorithm.");
}
- (void)testMinimization {
    // This is an automaton from page 68 of the book Introduction to Automata Theory Laungages and computation by John E. Hopcroft and Jeffrey D. Ullman
    NSDictionary *states = [DFState statesWithNames:[DFUtils arrayFromString:@"abcdefgh"]];
    [states[@"c"] setAcceptingState:YES];
    
    [states[@"a"] addTransitionToState:states[@"b"] onInput:@"0"];
    [states[@"a"] addTransitionToState:states[@"f"] onInput:@"1"];
    [states[@"b"] addTransitionToState:states[@"g"] onInput:@"0"];
    [states[@"b"] addTransitionToState:states[@"c"] onInput:@"1"];
    [states[@"c"] addTransitionToState:states[@"a"] onInput:@"0"];
    [states[@"c"] addTransitionToState:states[@"c"] onInput:@"1"];
    [states[@"d"] addTransitionToState:states[@"c"] onInput:@"0"];
    [states[@"d"] addTransitionToState:states[@"g"] onInput:@"1"];
    [states[@"e"] addTransitionToState:states[@"h"] onInput:@"0"];
    [states[@"e"] addTransitionToState:states[@"f"] onInput:@"1"];
    [states[@"f"] addTransitionToState:states[@"c"] onInput:@"0"];
    [states[@"f"] addTransitionToState:states[@"g"] onInput:@"1"];
    [states[@"g"] addTransitionToState:states[@"g"] onInput:@"0"];
    [states[@"g"] addTransitionToState:states[@"e"] onInput:@"1"];
    [states[@"h"] addTransitionToState:states[@"g"] onInput:@"0"];
    [states[@"h"] addTransitionToState:states[@"c"] onInput:@"1"];
    
    DFAutomaton *fullAutomaton = [DFAutomaton automatonWithStartingState:states[@"a"]];
    XCTAssertTrue([fullAutomaton determineType] == DFAutomatonTypeDFA, @"This should be a valid DFA.");
    [fullAutomaton minimizeDFA];
    XCTAssertTrue([fullAutomaton determineType] == DFAutomatonTypeDFA, @"Should still be a DFA.");
    DFAutomaton *actualMinimizedAutomaton = fullAutomaton;
    
    states = [DFState statesWithNames:@[@"[a,e]", @"[b,h]", @"c", @"g", @"[d,f]"]];
    [states[@"c"] setAcceptingState:YES];
    [states[@"[a,e]"] addTransitionToState:states[@"[b,h]"] onInput:@"0"];
    [states[@"[a,e]"] addTransitionToState:states[@"[d,f]"] onInput:@"1"];
    [states[@"[b,h]"] addTransitionToState:states[@"g"] onInput:@"0"];
    [states[@"[b,h]"] addTransitionToState:states[@"c"] onInput:@"1"];
    [states[@"c"] addTransitionToState:states[@"[a,e]"] onInput:@"0"];
    [states[@"c"] addTransitionToState:states[@"c"] onInput:@"1"];
    [states[@"g"] addTransitionToState:states[@"g"] onInput:@"0"];
    [states[@"g"] addTransitionToState:states[@"[a,e]"] onInput:@"1"];
    [states[@"[d,f]"] addTransitionToState:states[@"c"] onInput:@"0"];
    [states[@"[d,f]"] addTransitionToState:states[@"g"] onInput:@"1"];
    DFAutomaton *expectedMinimizedAutomaton = [DFAutomaton automatonWithStartingState:states[@"[a,e]"]];
    
    NSLog(@"%@", actualMinimizedAutomaton);
    
    XCTAssertTrue([actualMinimizedAutomaton isEqualToAutomaton:expectedMinimizedAutomaton], @"Minimization algorithm.");
}

- (void)testEven1s {
    DFAutomaton *even1s = [DFAutomaton even1sBinaryAutomaton];
    XCTAssertTrue([even1s determineType] == DFAutomatonTypeDFA, @"");
    
    // valid inputs
    XCTAssertTrue([even1s acceptsString:@"11"], @"");
    XCTAssertTrue([even1s acceptsString:@""], @"");
    XCTAssertTrue([even1s acceptsString:@"01010"], @"");
    XCTAssertTrue([even1s acceptsString:@"000"], @"");
    XCTAssertTrue([even1s acceptsString:@"011000101"], @"");
    
    // invalid inputs
    XCTAssertFalse([even1s acceptsString:@"1"], @"");
    XCTAssertFalse([even1s acceptsString:@"01"], @"");
    XCTAssertFalse([even1s acceptsString:@"0111"], @"");
    XCTAssertFalse([even1s acceptsString:@"01110011000"], @"");
    XCTAssertFalse([even1s acceptsString:@"2"], @"");
}

- (void)testStartAndEnd {
    DFAutomaton *sameChars = [DFAutomaton startAndEndSameCharBinaryAutomaton];
    XCTAssertTrue([sameChars determineType] == DFAutomatonTypeDFA, @"");
    
    // valid inputs
    XCTAssertTrue([sameChars acceptsString:@"1101"], @"");
    XCTAssertTrue([sameChars acceptsString:@""], @"");
    XCTAssertTrue([sameChars acceptsString:@"0"], @"");
    XCTAssertTrue([sameChars acceptsString:@"1"], @"");
    XCTAssertTrue([sameChars acceptsString:@"00000"], @"");
    XCTAssertTrue([sameChars acceptsString:@"00100110"], @"");
    
    // invalid inputs
    XCTAssertFalse([sameChars acceptsString:@"001001101"], @"");
    XCTAssertFalse([sameChars acceptsString:@"01"], @"");
    XCTAssertFalse([sameChars acceptsString:@"0101"], @"");
    XCTAssertFalse([sameChars acceptsString:@"2"], @"");
}

- (void)testEndsWithIng {
    DFAutomaton *endsWithIng = [DFAutomaton endsWithIngAutomaton];
    XCTAssertTrue([endsWithIng determineType] == DFAutomatonTypeGNFA, @"This automaton uses the negated regex.");
    
    // valid inputs
    XCTAssertTrue([endsWithIng acceptsString:@"Coding"], @"");
    XCTAssertTrue([endsWithIng acceptsString:@"Codinging"], @"");
    XCTAssertTrue([endsWithIng acceptsString:@"Codining"], @"");
    XCTAssertTrue([endsWithIng acceptsString:@"Codiing"], @"");
    XCTAssertTrue([endsWithIng acceptsString:@"ing"], @"");
    
    // invalid inputs
    XCTAssertFalse([endsWithIng acceptsString:@"Codinginng"], @"");
    XCTAssertFalse([endsWithIng acceptsString:@"Testing "], @"");
    XCTAssertFalse([endsWithIng acceptsString:@"Hello"], @"");
    XCTAssertFalse([endsWithIng acceptsString:@""], @"");
    XCTAssertFalse([endsWithIng acceptsString:@"TestinG"], @"");
}

- (void)testSingleLevelParenMath {
    // CS 454 - Homework 2 - Problem 1
    DFAutomaton *singleLevelParenMath = [DFAutomaton singleLevelParenMathAutomaton];
    XCTAssertTrue([singleLevelParenMath determineType] == DFAutomatonTypeNFA, @"This automaton has simple, single character inputs, but foregoes the need for dead states by not implementing the inputs it doesn't need. Therefore it is an NFA.");
    
    // valid inputs
    XCTAssertTrue([singleLevelParenMath acceptsString:@"a+b"], @"");
    XCTAssertTrue([singleLevelParenMath acceptsString:@""], @"");
    XCTAssertTrue([singleLevelParenMath acceptsString:@"a+b*b"], @"");
    XCTAssertTrue([singleLevelParenMath acceptsString:@"(a+b*a+a*b+b)"], @"");
    XCTAssertTrue([singleLevelParenMath acceptsString:@"(a+b*a)*(a*b)+a"], @"");
    XCTAssertTrue([singleLevelParenMath acceptsString:@"a+a*a"], @"");
    XCTAssertTrue([singleLevelParenMath acceptsString:@"b*(b+b)"], @"");
    XCTAssertTrue([singleLevelParenMath acceptsString:@"(a)"], @"");
    XCTAssertTrue([singleLevelParenMath acceptsString:@"(a)+b"], @"");
    
    // invalid inputs
    XCTAssertFalse([singleLevelParenMath acceptsString:@"ab"], @"");
    XCTAssertFalse([singleLevelParenMath acceptsString:@"+"], @"");
    XCTAssertFalse([singleLevelParenMath acceptsString:@"a+ba"], @"");
    XCTAssertFalse([singleLevelParenMath acceptsString:@"a+*b"], @"");
    XCTAssertFalse([singleLevelParenMath acceptsString:@"a+b*"], @"");
    XCTAssertFalse([singleLevelParenMath acceptsString:@"(a+(b*a))"], @"");
    XCTAssertFalse([singleLevelParenMath acceptsString:@"(a+b"], @"");
    XCTAssertFalse([singleLevelParenMath acceptsString:@"()"], @"");
    XCTAssertFalse([singleLevelParenMath acceptsString:@"()+a"], @"");
    XCTAssertFalse([singleLevelParenMath acceptsString:@"a+()"], @"");
}

- (void)testTwoMatrixGreaterThanBinaryComp {
    // CS 454 - Homework 2 - Problem 2
    DFAutomaton *autom = [DFAutomaton twoMatrixGreaterThanBinaryComp];
    XCTAssertTrue([autom determineType] == DFAutomatonTypeGNFA, @"");
    
    BOOL (^leftBiggerThanRight)(NSString*, NSString*) = ^(NSString *left, NSString *right) {
        return [autom acceptsString:[DFUtils stringByIntermixingCharPositionsLeft:left right:right]];
    };
    BOOL (^leftBiggerThanRightNum)(NSInteger, NSInteger) = ^(NSInteger left, NSInteger right) {
        return leftBiggerThanRight([DFUtils binaryFromDecimal:left digits:4], [DFUtils binaryFromDecimal:right digits:4]);
    };
    
    // valid inputs (left > right)
    XCTAssertTrue(leftBiggerThanRight(@"0001", @"0000"), @"(1 > 0)");
    XCTAssertTrue(leftBiggerThanRight(@"0000", @"1000"), @"(0 > -7)");
    XCTAssertTrue(leftBiggerThanRight(@"0001", @"1111"), @"(1 > -1)");
    XCTAssertTrue(leftBiggerThanRight(@"1111", @"1101"), @"(-1 > -3)");
    XCTAssertTrue(leftBiggerThanRight(@"0110", @"0011"), @"Book example (6 > 3)");
    XCTAssertTrue(leftBiggerThanRightNum(-6, -8), @"");
    XCTAssertTrue(leftBiggerThanRightNum(0, -8), @"");
    XCTAssertTrue(leftBiggerThanRightNum(7, -8), @"");
    XCTAssertTrue(leftBiggerThanRightNum(2, 1), @"");
    
    // invalid inputs (left <= right)
    XCTAssertFalse(leftBiggerThanRight(@"0000", @"0000"), @"(0 > 0)");
    XCTAssertFalse(leftBiggerThanRight(@"0010", @"0010"), @"(2 > 2)");
    XCTAssertFalse(leftBiggerThanRight(@"1010", @"1010"), @"()");
    XCTAssertFalse(leftBiggerThanRight(@"1010", @"0010"), @"");
    XCTAssertFalse(leftBiggerThanRight(@"0010", @"0110"), @"Book example (3 > 6)");
    XCTAssertFalse(leftBiggerThanRightNum(1, 6), @"");
    XCTAssertFalse(leftBiggerThanRightNum(-6, 1), @"");
    XCTAssertFalse(leftBiggerThanRightNum(-8, -6), @"");
}

- (void)testTwoMatrixGreaterThanBinaryUnsignedComp {
    DFAutomaton *autom = [DFAutomaton twoMatrixGreaterThanBinaryUnsignedComp];
    XCTAssertTrue([autom determineType] == DFAutomatonTypeGNFA, @"Uses two character inputs, meaning it is a regex.");
    
    BOOL (^leftBiggerThanRight)(NSString *left, NSString *right) = ^(NSString *left, NSString *right) {
        return [autom acceptsString:[DFUtils stringByIntermixingCharPositionsLeft:left right:right]];
    };
    BOOL (^leftBiggerThanRightNum)(NSInteger, NSInteger) = ^(NSInteger left, NSInteger right) {
        return leftBiggerThanRight([DFUtils binaryFromDecimal:left digits:4], [DFUtils binaryFromDecimal:right digits:4]);
    };
    
    // valid inputs (left > right)
    XCTAssertTrue(leftBiggerThanRight(@"1000", @"0111"), @"");
    XCTAssertTrue(leftBiggerThanRight(@"0010", @"0001"), @"");
    XCTAssertTrue(leftBiggerThanRight(@"1110", @"1101"), @"");
    XCTAssertTrue(leftBiggerThanRightNum(5, 3), @"");
    
    // invalid inputs (left <= right)
    XCTAssertFalse(leftBiggerThanRightNum(3, 5), @"");
    XCTAssertFalse(leftBiggerThanRightNum(3, 3), @"");
}

- (void)testSampleEpsilonTransition {
    DFAutomaton *autom = [DFAutomaton epsilonSampleAutomaton];
    XCTAssertTrue([autom determineType] == DFAutomatonTypeENFA, @"");
    
    XCTAssertTrue([autom acceptsString:@"1"], @"");
    XCTAssertTrue([autom acceptsString:@"0"], @"");
    XCTAssertTrue([autom acceptsString:@"01"], @"");
    XCTAssertTrue([autom acceptsString:@"000"], @"");
    XCTAssertTrue([autom acceptsString:@"111"], @"");
    XCTAssertTrue([autom acceptsString:@"011"], @"");
    
    XCTAssertFalse([autom acceptsString:@""], @"");
    XCTAssertFalse([autom acceptsString:@"11"], @"");
    XCTAssertFalse([autom acceptsString:@"00"], @"");
    XCTAssertFalse([autom acceptsString:@"12"], @"");
}

- (void)testAmbiguous11Automaton {
    /*
     A --11-> (B)
     A --1--> C --1-->D
     */
    DFState *a = [DFState stateWithName:@"A"];
    DFState *b = [DFState acceptingStateWithName:@"B"];
    DFState *c = [DFState stateWithName:@"C"];
    DFState *d = [DFState stateWithName:@"D"];
    
    [a addTransitionToState:b onInput:@"11"];
    [a addTransitionToState:c onInput:@"1"];
    [c addTransitionToState:d onInput:@"1"];
    
    DFAutomaton *automaton = [DFAutomaton automatonWithStartingState:a];
    XCTAssertTrue([automaton determineType] == DFAutomatonTypeGNFA, @"Uses two character inputs, meaning it is a regex.");
    
    XCTAssertTrue([automaton acceptsString:@"11"], @"Ambiguous string should still be matched.");
    
    /*
     A --11-> B
     A --1--> C --1-->(D)
     */
    b.acceptingState = NO;
    d.acceptingState = YES;
    XCTAssertTrue([automaton acceptsString:@"11"], @"Ambiguous string should still be matched.");
}

- (void)testDivisorAutomaton {
    DFAutomaton *autom;
    
    autom = [DFAutomaton automatonForAllNumbersDivisibleBy:7];
    XCTAssertTrue([autom determineType] == DFAutomatonTypeDFA, @"");
    XCTAssertTrue([autom acceptsString:@(777).stringValue], @"");
    XCTAssertTrue([autom acceptsString:@(3878).stringValue], @"");
    XCTAssertTrue([autom acceptsString:@(0).stringValue], @"");
    XCTAssertTrue([autom acceptsString:@(7).stringValue], @"");
    XCTAssertTrue([autom acceptsString:@(14).stringValue], @"");
    
    XCTAssertFalse([autom acceptsString:@(776).stringValue], @"");
    XCTAssertFalse([autom acceptsString:@(6548).stringValue], @"");
    
    autom = [DFAutomaton automatonForAllNumbersDivisibleBy:3];
    XCTAssertTrue([autom acceptsString:@(5481).stringValue], @"");
    XCTAssertTrue([autom acceptsString:@(642).stringValue], @"");
    
    XCTAssertFalse([autom acceptsString:@(653).stringValue], @"");
}

- (void)testNearlyDivisbleAutomaton {
    DFAutomaton *autom = [DFAutomaton automatonForAllNumbersNearlyDivisibleBy:7];
    XCTAssertTrue([autom determineType] == DFAutomatonTypeNFA, @"");
    
    XCTAssertTrue([autom acceptsString:@(757).stringValue], @"");
    
    XCTAssertFalse([autom acceptsString:@(123).stringValue], @"");
    XCTAssertFalse([autom acceptsString:@"741842607938866199443579680083706254648829519399268"], @"");
}
- (void)testNearlyDivisbleDFA {
    DFAutomaton *autom = [DFAutomaton automatonForAllNumbersNearlyDivisibleBy:7];
    XCTAssertTrue([autom determineType] == DFAutomatonTypeNFA, @"");
    autom = [autom convertToDFA];
    //NSLog(@"States: %d", [autom allStates].count);
    XCTAssertTrue([autom determineType] == DFAutomatonTypeDFA, @"");
    
    XCTAssertTrue([autom acceptsString:@(757).stringValue], @"");
    
    XCTAssertFalse([autom acceptsString:@(123).stringValue], @"");
    XCTAssertFalse([autom acceptsString:@"741842607938866199443579680083706254648829519399268"], @"");
}
- (void)testNearlyDivisbleBy3 {
    DFAutomaton *autom = [DFAutomaton automatonForAllNumbersNearlyDivisibleBy:3];
    XCTAssertTrue([autom determineType] == DFAutomatonTypeNFA, @"This is an NFA because each state has two transitions on each of the inputs from 0-9.");
    autom = [autom convertToDFA];
    XCTAssertTrue([autom determineType] == DFAutomatonTypeDFA, @"Ensure that after conversion, it is actually a DFA.");

    XCTAssertTrue([autom acceptsString:@"314335"], @"Can remove the 5.");
    XCTAssertTrue([autom acceptsString:@"33334333"], @"Can remove the 4.");
    XCTAssertTrue([autom acceptsString:@"3333"], @"Don't have to remove anything.");
    XCTAssertTrue([autom acceptsString:@"24"], @"Must not remove anything.");
    XCTAssertTrue([autom acceptsString:@"2222"], @"Can remove any 2.");
    XCTAssertFalse([autom acceptsString:@"22222"], @"No matter which 2 you remove, still not divisible.");

    XCTAssertEqual([autom allStates].count, 20U, @"According to JFLAP, after conversion to DFA, there are 20 states.");

    [autom minimizeDFA];
    XCTAssertEqual([autom allStates].count, 8U, @"According to JFLAP, after minimization, the DFA must contain 8 states.");
    XCTAssertEqual([autom nonFinalStates].count, 2U, @"According to JFLAP, 2 of those 8 must be non-final.");
}


- (void)testHomework3 {
    // Note: this test is a bit slow (1.658 seconds)
    DFAutomaton *autom = [DFAutomaton hw3Automaton];
    XCTAssertTrue([autom determineType] == DFAutomatonTypeNFA, @"");
    
    int successes = 0;
    NSArray *binaryStrings = [DFUtils allBinaryStringsOfLength:14];
    for (NSString *binaryString in binaryStrings) {
        if ([autom acceptsString:binaryString]) {
            successes++;
        }
    }
    
    XCTAssertEqual(successes, 114, @"114 of 16384 strings must pass.");
}
@end
