//
//  DFAutomaton+Homework.m
//  DFA
//
//  Created by Ortal on 9/13/13.
//
//

#import "DFAutomaton+Homework.h"

@implementation DFAutomaton (Homework)

+ (DFAutomaton *)hw3Automaton {
    DFState *a = [DFState stateWithName:@"A"];
    DFState *b = [DFState stateWithName:@"B"];
    DFState *c = [DFState stateWithName:@"C"];
    DFState *d = [DFState acceptingStateWithName:@"D"];
    
    [a addTransitionToState:b onInput:@"0"];
    [a addTransitionToState:c onInput:@"1"];
    [b addTransitionToState:d onInput:@"1"];
    [c addTransitionToState:d onInput:@"0"];
    [d addTransitionToState:b onInput:@"1"];
    [d addTransitionToState:a onInput:@"0"];
    
    return [DFAutomaton automatonWithStartingState:a];
}

+ (void)printHw3 {
    DFAutomaton *autom = [self hw3Automaton];
    
    const int startK = 1;
    const int endK = 14;
    for (int i = startK; i <= endK; i++) {
        int successes = 0;
        NSArray *binaryStrings = [DFUtils allBinaryStringsOfLength:i];
        NSLog(@"---------------------------");
        NSLog(@"K: %d", i);
        for (NSString *binaryString in binaryStrings) {
            if ([autom acceptsString:binaryString]) {
                //NSLog(@"%@", binaryString);
                successes++;
            }
        }
        NSLog(@"Results: (%d/%d)", successes, [binaryStrings count]);
    }
}

@end
