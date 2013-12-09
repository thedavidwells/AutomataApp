//
//  DFState.m
//  AutomataApp
//
//  Created by Ortal on 9/29/13.
//  Copyright (c) 2013 CS454. All rights reserved.
//

#import "DFState.h"
#import "DFState_Private.h"
#import "DFTransition_Private.h"

@interface DFState ()
@property (strong, readonly, nonatomic) NSMutableArray *mutableTransitions; // of DFATransition
@end

@implementation DFState

- (NSArray *)transitions {
    return [self.mutableTransitions copy];
}

- (NSArray *)incomingTransitions {
    return [self.mutableIncomingTransitions copy];
}

- (instancetype) init {
    if (self = [super init]) {
        _mutableTransitions = [NSMutableArray array];
        _mutableIncomingTransitions = [NSMutableArray array];
    }
    return self;
}

+ (NSString *)nameForCombinedStates:(NSSet *)states {
    NSMutableArray *namesArray = [NSMutableArray array];
    for (DFState *state in states) {
        [namesArray addObject:state.name];
    }
    NSArray *sortedNamesArray = [namesArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return [NSString stringWithFormat:@"{%@}", [sortedNamesArray componentsJoinedByString:@","]];
}

+ (NSString *)nameForCollapsedStates:(NSSet *)states {
    // TODO: duplicated code from nameForCombinedStates
    NSMutableArray *namesArray = [NSMutableArray array];
    for (DFState *state in states) {
        [namesArray addObject:state.name];
    }
    NSArray *sortedNamesArray = [namesArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return [NSString stringWithFormat:@"[%@]", [sortedNamesArray componentsJoinedByString:@","]];
}

+ (instancetype)stateWithName:(NSString *)name {
    DFState *state = [[self alloc] init];
    state.name = name;
    return state;
}

+ (NSDictionary *)statesWithNames:(NSArray *)names {
    NSMutableDictionary *states = [NSMutableDictionary dictionary];
    for (NSString *name in names) {
        NSAssert(states[name] == nil, @"State already exists: %@", name);
        [states setObject:[DFState stateWithName:name] forKey:name];
    }
    return states;
}

+ (NSDictionary *)statesWithNames:(NSArray *)names acceptingStateNames:(NSArray *)acceptingNames {
    NSMutableDictionary *states = [NSMutableDictionary dictionaryWithDictionary:[self statesWithNames:names]];
    for (NSString *acceptingName in acceptingNames) {
        NSAssert(states[acceptingName] == nil, @"State already exists: %@", acceptingName);
        DFState *state = [DFState acceptingStateWithName:acceptingName];
        [states setObject:state forKey:acceptingName];
    }
    return states;
}

+ (instancetype)acceptingStateWithName:(NSString *)name {
    DFState *state = [self stateWithName:name];
    state.acceptingState = YES;
    return state;
}

- (void)addEpsilonTransitionToState:(DFState *)state {
    [self addTransition:[DFEpsilonTransition transitionToState:state]];
}

- (void)addTransition:(DFTransition *)transition {
    [self.mutableTransitions addObject:transition];
    transition.fromState = self;
}

- (void)addTransitionsDictionary:(NSDictionary *)transitionsDictionary {
    for (NSString *input in transitionsDictionary) {
        NSObject *value = transitionsDictionary[input];
        if (![value isKindOfClass:[NSArray class]]) {
            // if we sent an item with no array, then convert it to an array.
            value = @[value];
        }
        
        NSAssert([value isKindOfClass:[NSArray class]], @"Must be array.");
        NSArray *valueArray = (NSArray *)value;
        for (DFState *state in valueArray) {
            NSAssert([state isKindOfClass:[DFState class]], @"Must be instances of DFState.");
            [self addTransitionToState:state onInput:input];
        }
    }
}

- (void)addTransitionToState:(DFState *)state onInput:(NSString *)input {
    [self addTransition:[DFTransition transitionToState:state onInput:input]];
}

- (void)addTransitionToState:(DFState *)state onInputCharacters:(NSString *)input {
    NSMutableArray *chars = [NSMutableArray array];
    for (int i = 0; i < input.length; i++) {
        [chars addObject:[input substringWithRange:NSMakeRange(i, 1)]];
    }
    
    [self addTransitionToState:state onInputs:chars];
}
- (void)addTransitionToState:(DFState *)state onInputs:(NSArray *)inputs {
    for (NSString *input in inputs) {
        [self addTransitionToState:state onInput:input];
        // TODO: create a compound transition instead of creating a bunch of separate ones?
    }
}
- (NSString *)description {
    NSString *description = [NSString stringWithFormat:@"(%@)", self.name];
    if (self.acceptingState) {
        description = [NSString stringWithFormat:@"(%@)", description];
    }
    return description;
}
- (NSSet *)inputs {
    NSMutableSet *inputs = [NSMutableSet set];
    for (DFTransition *transition in self.transitions) {
        if (![transition isKindOfClass:[DFEpsilonTransition class]]) {
            [inputs addObject:transition.input];
        }
    }
    return [inputs copy];
}
- (BOOL)isEqualToState:(DFState *)other {
    if (self.acceptingState != other.acceptingState) {
        return NO;
    }
    if (![self.name isEqualToString:other.name]) {
        return NO;
    }
    
    // now check that each of my transitions leads to the same other transition (based on name and input)
    NSMutableArray *myTransitions = [NSMutableArray arrayWithArray:self.transitions];
    NSMutableArray *otherTransitions = [NSMutableArray arrayWithArray:other.transitions];
    
    if (myTransitions.count != otherTransitions.count) {
        return NO;
    }

    while (myTransitions.count > 0) {
        DFTransition *myTransition = myTransitions[0];
        [myTransitions removeObjectAtIndex:0];
        BOOL foundMatchingTransition = NO;
        for (DFTransition *otherTransition in otherTransitions) {
            if ([otherTransition.input isEqualToString:myTransition.input] && [otherTransition.toState.name isEqualToString:myTransition.toState.name]) {
                foundMatchingTransition = YES;
                [otherTransitions removeObject:otherTransition];
                break;
            }
        }
        if (!foundMatchingTransition) {
            return NO;
        }
    }
    NSAssert(otherTransitions.count == 0, @"Must have went through all the transitions.");
    return YES;
}

- (DFState *)stateForInput:(NSString *)input {
    NSSet *states = [self statesForInput:input];
    NSAssert(states.count == 1, @"Invalid input.");
    NSAssert([[states anyObject] isKindOfClass:[DFState class]], @"Expecting DFState objects.");
    return [states anyObject];
}

- (NSSet *)statesForInput:(NSString *)input {
    NSAssert(input.length == 1, @"Must be one length for now.");
    NSMutableSet *inputs = [NSMutableSet set];
    for (DFTransition *transition in self.transitions) {
        if (![transition isKindOfClass:[DFEpsilonTransition class]] && [transition matchInput:input] == 1) {
            [inputs addObject:transition.toState];
        }
    }
    return inputs;
}

- (void)removeAllTransitions {
    while ([self.mutableTransitions count] > 0) {
        DFTransition *transition = self.mutableTransitions[0];
        transition.toState = nil;
        [self.mutableTransitions removeObjectAtIndex:0];
    }
    
    // TODO: remove all incoming transitions too
}

+ (NSDictionary *)dictionaryFromStates:(NSSet *)states {
    NSMutableDictionary *statesDict = [NSMutableDictionary dictionary];
    for (DFState *state in states) {
        [statesDict setObject:state forKey:state.name];
    }
    return statesDict;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    // we do dictionary comparisons, and want to use DFStates as keys in dictionaries, but don't want them copied, so return the same instance.
    // Note that this is unsafe if the object is ever changed.
    return self; // http://stackoverflow.com/a/2394171
}

@end
