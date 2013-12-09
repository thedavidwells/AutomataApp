//
//  DFAutomaton+Samples.m
//  DFA
//
//  Created by Ortal on 9/25/13.
//
//

#import "DFAutomaton+Samples.h"

@implementation DFAutomaton (Samples)

+ (instancetype)even1sBinaryAutomaton {
    // create states
    DFState *stateA = [DFState acceptingStateWithName:@"A"];
    DFState *stateB = [DFState stateWithName:@"B"];
    
    // create transitions
    [stateA addTransitionToState:stateA onInput:@"0"];
    [stateA addTransitionToState:stateB onInput:@"1"];
    [stateB addTransitionToState:stateB onInput:@"0"];
    [stateB addTransitionToState:stateA onInput:@"1"];
    
    return [self automatonWithStartingState:stateA];
}

+ (instancetype)startAndEndSameCharBinaryAutomaton {
    // create states
    DFState *stateA = [DFState acceptingStateWithName:@"A"];
    DFState *stateB = [DFState acceptingStateWithName:@"B"];
    DFState *stateC = [DFState acceptingStateWithName:@"C"];
    DFState *stateD = [DFState stateWithName:@"D"];
    DFState *stateE = [DFState stateWithName:@"E"];
    
    // create transitions
    [stateA addTransitionToState:stateB onInput:@"0"];
    [stateA addTransitionToState:stateC onInput:@"1"];
    [stateB addTransitionToState:stateB onInput:@"0"];
    [stateB addTransitionToState:stateD onInput:@"1"];
    [stateC addTransitionToState:stateE onInput:@"0"];
    [stateC addTransitionToState:stateC onInput:@"1"];
    [stateD addTransitionToState:stateB onInput:@"0"];
    [stateD addTransitionToState:stateD onInput:@"1"];
    [stateE addTransitionToState:stateE onInput:@"0"];
    [stateE addTransitionToState:stateC onInput:@"1"];
    
    return [self automatonWithStartingState:stateA];
}

+ (instancetype)endsWithIngAutomaton {
    // create states
    DFState *stateA = [DFState stateWithName:@"A"];
    DFState *stateI = [DFState stateWithName:@"I"];
    DFState *stateN = [DFState stateWithName:@"N"];
    DFState *stateG = [DFState acceptingStateWithName:@"G"];
    
    // create transitions
    [stateA addTransitionToState:stateI onInput:@"i"];
    [stateA addTransition:[DFRegexTransition transitionToState:stateA onInputMatch:@"[^i]"]];
    [stateI addTransitionToState:stateN onInput:@"n"];
    [stateI addTransitionToState:stateI onInput:@"i"];
    [stateI addTransition:[DFRegexTransition transitionToState:stateA onInputMatch:@"[^in]"]];
    [stateN addTransitionToState:stateG onInput:@"g"];
    [stateN addTransitionToState:stateI onInput:@"i"];
    [stateN addTransition:[DFRegexTransition transitionToState:stateA onInputMatch:@"[^ig]"]];
    [stateG addTransitionToState:stateI onInput:@"i"];
    [stateG addTransition:[DFRegexTransition transitionToState:stateA onInputMatch:@"[^i]"]];
    
    return [self automatonWithStartingState:stateA];
}

+ (instancetype)singleLevelParenMathAutomaton {
    // create states
    DFState *stateStart = [DFState acceptingStateWithName:@"start"];
    DFState *stateAcceptOperator = [DFState acceptingStateWithName:@"accept operator"];
    DFState *stateNeedsMoreChars = [DFState stateWithName:@"needs more chars"];
    DFState *stateParenLetter = [DFState stateWithName:@"paren letter"];
    DFState *stateParenOperator = [DFState stateWithName:@"paren operator"];
    DFState *stateOpenParen = [DFState stateWithName:@"open paren"];
    
    // create transitions
    [stateStart addTransitionToState:stateOpenParen onInput:@"("];
    [stateStart addTransitionToState:stateAcceptOperator onInputCharacters:@"ab"];
    [stateOpenParen addTransitionToState:stateParenLetter onInputCharacters:@"ab"];
    [stateAcceptOperator addTransitionToState:stateNeedsMoreChars onInputCharacters:@"+*"];
    [stateNeedsMoreChars addTransitionToState:stateAcceptOperator onInputCharacters:@"ab"];
    [stateNeedsMoreChars addTransitionToState:stateOpenParen onInput:@"("];
    [stateParenLetter addTransitionToState:stateParenOperator onInputCharacters:@"+*"];
    [stateParenLetter addTransitionToState:stateAcceptOperator onInputCharacters:@")"];
    [stateParenOperator addTransitionToState:stateParenLetter onInputCharacters:@"ab"];
    
    return [self automatonWithStartingState:stateStart];
}

+ (instancetype)twoMatrixGreaterThanBinaryComp {
    // create states
    DFState *stateA = [DFState stateWithName:@"A"];
    DFState *stateB = [DFState stateWithName:@"B"];
    DFState *stateC = [DFState acceptingStateWithName:@"C"];
    DFState *stateD = [DFState stateWithName:@"D"];
    
    // create transitions
    [stateA addTransitionToState:stateB onInput:@"00"];
    [stateA addTransitionToState:stateB onInput:@"11"];
    [stateA addTransitionToState:stateC onInput:@"01"];
    [stateA addTransitionToState:stateD onInput:@"10"];
    [stateB addTransitionToState:stateB onInput:@"00"];
    [stateB addTransitionToState:stateB onInput:@"11"];
    [stateB addTransitionToState:stateC onInput:@"10"];
    [stateB addTransitionToState:stateD onInput:@"01"];
    [stateC addTransition:[DFRegexTransition transitionOnAnyInputToState:stateC]];
    [stateD addTransition:[DFRegexTransition transitionOnAnyInputToState:stateD]];
    
    return [self automatonWithStartingState:stateA];
}

+ (instancetype)twoMatrixGreaterThanBinaryUnsignedComp {
    // create states
    DFState *stateA = [DFState stateWithName:@"A"];
    DFState *stateB = [DFState acceptingStateWithName:@"B"];
    
    // create transitions
    [stateA addTransitionToState:stateA onInput:@"00"];
    [stateA addTransitionToState:stateA onInput:@"11"];
    [stateA addTransitionToState:stateB onInput:@"10"];
    [stateB addTransitionToState:stateB onInputs:@[@"00", @"01", @"10", @"11"]];
    
    return [self automatonWithStartingState:stateA];
}

+ (instancetype)epsilonSampleAutomaton {
    // from the 2nd lecture
    DFState *stateA = [DFState stateWithName:@"A"];
    DFState *stateB = [DFState stateWithName:@"B"];
    DFState *stateC = [DFState stateWithName:@"C"];
    DFState *stateD = [DFState acceptingStateWithName:@"D"];
    DFState *stateE = [DFState stateWithName:@"E"];
    DFState *stateF = [DFState stateWithName:@"F"];
    
    [stateA addTransitionToState:stateB onInput:@"1"];
    [stateA addTransitionToState:stateE onInput:@"0"];
    [stateB addTransitionToState:stateC onInput:@"1"];
    [stateB addEpsilonTransitionToState:stateD];
    [stateC addTransitionToState:stateD onInput:@"1"];
    [stateE addEpsilonTransitionToState:stateB];
    [stateE addEpsilonTransitionToState:stateC];
    [stateE addTransitionToState:stateF onInput:@"0"];
    [stateF addTransitionToState:stateD onInput:@"0"];
    
    return [self automatonWithStartingState:stateA];
}

+ (instancetype)automatonForAllNumbersDivisibleBy:(NSInteger)divisor {
    // returns an automaton which accepts numbers that are divsible by divisor. For example, if divsior is 7, then the automaton
    // will accept 0, 7, 14, 21, etc. And will not accept any of the other numbers.
    
    // we must create the same number of states as the divisor, since if divisor is 7, we will have to keep track of
    // 7 different remainders at each step (namely 0-6).
    NSMutableArray *states = [NSMutableArray arrayWithCapacity:divisor]; // array of DFState
    DFState *state0 = [DFState acceptingStateWithName:@"0"];
    [states addObject:state0];
    for (int i = 1; i < divisor; i++) {
        DFState *state = [DFState stateWithName:@(i).stringValue];
        [states addObject:state];
    }
    
    // now connect the states
    for (int stateNum = 0; stateNum < divisor; stateNum++) {
        DFState *state = states[stateNum];
        // assume we are processing the transitions for state 2. All we have to do is combine the 2 with every other input to determine
        // where it should go. For example, at 8 it should go to 0, since 28/7=0. Similarly, 3 should go to 2 because 23/7=2.
        for (int i = 0; i < 10; i++) { // create a transition for each number from 0-9
            NSInteger numerator = stateNum*10 + i;
            NSInteger remainder = numerator%divisor;
            [state addTransitionToState:states[remainder] onInput:@(i).stringValue];
        }
    }
    
    return [self automatonWithStartingState:state0];
}

+ (instancetype)automatonForAllNumbersNearlyDivisibleBy:(NSInteger)divisor {
    // a number is nearly divisible by divisor if you can remove 0 or 1 digits and the resulting number is divisible by divisor.
    // For example, 757 is nearly divisible by 7 since you can remove the 5 to generate the number 77, which is divisible by 7.
    
    DFAutomaton *automatonA = [self automatonForAllNumbersDivisibleBy:divisor];
    DFAutomaton *automatonB = [self automatonForAllNumbersDivisibleBy:divisor];
    
    for (int i = 0; i < divisor; i++) {
        DFState *stateA = [automatonA stateForName:@(i).stringValue];
        DFState *stateB = [automatonB stateForName:@(i).stringValue];
        stateA.name = [stateA.name stringByAppendingString:@"a"];
        stateB.name = [stateB.name stringByAppendingString:@"b"]; // change the name because once we add it to stateA, we don't want it to find duplicates
        [stateA addTransitionToState:stateB onInputCharacters:@"0123456789"]; 
    }
    
    return automatonA;
}

@end
