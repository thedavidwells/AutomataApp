//
//  DFAutomatonPath.h
//  DFA
//
//  Created by Ortal on 9/14/13.
//
//

#import <Foundation/Foundation.h>
#import "DFAutomaton.h"

@interface DFPathSegment : NSObject
@property (readonly, nonatomic) DFTransition *transition;
@property (readonly, nonatomic) NSString *matchedInput;
@end

@interface DFAutomatonPath : NSObject <NSCopying>

+ (instancetype)successPathForAutomaton:(DFAutomaton *)automaton withInput:(NSString *)input;

@property (readonly, nonatomic) DFAutomaton *automaton;
@property (readonly, nonatomic) DFState *currentState;
@property (readonly, nonatomic) NSString *remainingInput;
@property (readwrite, nonatomic) BOOL traceStates;

- (BOOL)hasMoreInput;
- (BOOL)isInAcceptingState;

@end
