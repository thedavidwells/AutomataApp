//
//  DFTransition.m
//  DFA
//
//  Created by Ortal on 9/25/13.
//
//

#import "DFTransition.h"
#import "DFAutomaton.h"
#import "DFConsts.h"
#import "DFTransition_Private.h"
#import "DFState_Private.h"

@implementation DFTransition

- (NSInteger)matchInput:(NSString *)input {
    NSAssert(NO, @"Abstract class.");
    return 0;
}

- (void)setToState:(DFState *)toState {
    DFState *oldState = self.toState;
    _toState = toState;
    DFState *newState = toState;
    
    // update the state's incoming transitions
    [oldState.mutableIncomingTransitions removeObject:self];
    [newState.mutableIncomingTransitions addObject:self];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"-%@->%@", self.input, self.toState];
}

+ (NSArray *)transitionsOfStates:(NSSet *)states {
    NSMutableArray *transitions = [NSMutableArray array];
    for (DFState *state in states) {
        [transitions addObjectsFromArray:state.transitions];
    }
    return [transitions copy];
}

+ (instancetype)transitionToState:(DFState *)state onInput:(NSString *)input {
    NSAssert(state != nil, @"State must not be nil.");
    if (input.length == 0) {
        return [DFEpsilonTransition transitionToState:state];
    } else if (input.length == 1) {
        return [DFSingleCharTransition transitionToState:state onInput:input];
    } else {
        return [DFMultiCharTransition transitionToState:state onInput:input];
    }
}
@end

@implementation DFSingleCharTransition

- (void)setInput:(NSString *)input {
    NSAssert(input.length == 1, @"Must be single character.");
    [super setInput:input];
}

- (NSInteger)matchInput:(NSString *)input {
    NSRange matchRange = [input rangeOfString:self.input];
    return matchRange.location == 0 ? matchRange.length : 0; // must match at the beginning
}

+ (instancetype)transitionToState:(DFState *)state onInput:(NSString *)input {
    NSAssert(state != nil, @"State must not be nil.");
    DFSingleCharTransition *transition = [[self alloc] init];
    transition.input = input;
    transition.toState = state;
    return transition;
}

@end

@implementation DFEpsilonTransition

- (void)setInput:(NSString *)input {
    NSAssert(input == kEpsilonInput, @"Must remain epsilon input (used for printing).");
    [super setInput:input];
}

- (NSInteger)matchInput:(NSString *)input {
    NSAssert(NO, @"Should never call this method.");
    return 0;
}

+ (instancetype)transitionToState:(DFState *)state {
    NSAssert(state != nil, @"State must not be nil.");
    DFEpsilonTransition *transition = [[self alloc] init];
    transition.input = kEpsilonInput;
    transition.toState = state;
    return transition;
}

@end

@implementation DFMultiCharTransition

- (void)setInput:(NSString *)input {
    NSAssert(input.length > 1, @"Must be more than one character.");
    [super setInput:input];
}

- (NSInteger)matchInput:(NSString *)input {
    NSRange matchRange = [input rangeOfString:self.input];
    return matchRange.location == 0 ? matchRange.length : 0; // must match at the beginning
}

+ (instancetype)transitionToState:(DFState *)state onInput:(NSString *)input {
    NSAssert(state != nil, @"State must not be nil.");
    DFMultiCharTransition *transition = [[self alloc] init];
    transition.input = input;
    transition.toState = state;
    return transition;
}

@end

@interface DFRegexTransition()
@property (strong, nonatomic) NSRegularExpression *regex;
@end

@implementation DFRegexTransition

- (void)setInput:(NSString *)input {
    [super setInput:input];
    self.regex = [NSRegularExpression regularExpressionWithPattern:self.input
                                                           options:0
                                                             error:nil];
}

- (NSInteger)matchInput:(NSString *)input {
    NSRange matchRange = [self.regex rangeOfFirstMatchInString:input options:0 range:NSMakeRange(0, input.length)];
    return matchRange.location == 0 ? matchRange.length : 0; // must match at the beginning
}

+ (instancetype)transitionToState:(DFState *)state onInputMatch:(NSString *)regex {
    DFRegexTransition *transition = [[self alloc] init];
    transition.input = regex;
    transition.toState = state;
    return transition;
}

+ (instancetype)transitionOnAnyInputToState:(DFState *)state {
    return [self transitionToState:state onInputMatch:@"."];
}


@end
