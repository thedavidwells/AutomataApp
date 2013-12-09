//
//  DFAutomatonPath.m
//  DFA
//
//  Created by Ortal on 9/14/13.
//
//

#import "DFAutomatonPath.h"

@interface DFPathSegment()
@property (strong, nonatomic) DFTransition *transition;
@property (strong, nonatomic) NSString *matchedInput;
@end

@implementation DFPathSegment

- (NSString *)description {
    if ([self.transition isKindOfClass:[DFRegexTransition class]]) {
        // complex match, so show me what actually matched
        return [NSString stringWithFormat:@"-%@(%@)->%@", self.matchedInput, self.transition.input, self.transition.toState];
    } else {
        // simple match, so don't need to see an explanation
        return [NSString stringWithFormat:@"-%@->%@", self.transition.input, self.transition.toState];
    }
}

@end

@interface DFAutomatonPath()
@property (weak, nonatomic) DFAutomaton *automaton;
@property (strong, nonatomic) NSString *remainingInput;
@property (strong, nonatomic) NSMutableArray *transitionHistory; // array of DFPathSegment
@end

@implementation DFAutomatonPath

- (id)copyWithZone:(NSZone *)zone {
    DFAutomatonPath *copy = [[[self class] alloc] init];
    
    if (copy) {
        // copy NSObject subclasses
        copy.automaton = self.automaton;
        copy.remainingInput = [self.remainingInput copyWithZone:zone];
        copy.transitionHistory = [self.transitionHistory mutableCopyWithZone:zone];
        
        // set primitives
        copy.traceStates = self.traceStates;
    }
    return copy;
}

- (NSString *)description {
    NSMutableString *result = [NSMutableString stringWithFormat:@"->%@", self.automaton.startingState];
    for (DFPathSegment *segment in self.transitionHistory) {
        [result appendString:segment.description];
    }
    return [result stringByAppendingFormat:@" (Remaining input: %@)", self.remainingInput];
}

+ (instancetype)successPathForAutomaton:(DFAutomaton *)automaton withInput:(NSString *)input {
    DFAutomatonPath *path = [[self alloc] init];

    path.transitionHistory = [NSMutableArray array];
    path.remainingInput = input;
    path.automaton = automaton; // TODO: deep copy the automaton in case it is changed in the future?
    
    NSAssert(path.currentState, @"Must have a starting state.");
    
    NSMutableArray *pathsQueue = [NSMutableArray arrayWithObject:path];
    while ([pathsQueue count] > 0) {
        DFAutomatonPath *path = pathsQueue[0];
        [pathsQueue removeObjectAtIndex:0];
        
        // We will store in the queue paths that don't end with epsilons. We will only follow epsilons
        // right before we need to process the next input.
        // For example, assume the next input to process is 01. We will add 0 to the queue, and then
        // when it is time to process 1, we will follow all of 0's epsilons,
        // and then follow all paths. Any concrete (non-epsilon ending) paths will be added to the queue.
        
        NSArray *epsilonPaths = [path forksForEpsilonPaths];
        for (DFAutomatonPath *epsilonPath in epsilonPaths) {
            if (!epsilonPath.hasMoreInput) {
                if (epsilonPath.isInAcceptingState)
                    return epsilonPath;
                else
                    continue; // don't fork this path anymore, it is dead
            }
            
            NSArray *nextInputForks = [epsilonPath forksForNextInput];
            [pathsQueue addObjectsFromArray:nextInputForks];
        }
    }
    return nil;
}

- (NSArray *)forksForEpsilonPaths {
    NSMutableArray *epsilonPaths = [NSMutableArray arrayWithObject:self];
    NSMutableSet *epsilonStatesSeen = [NSMutableSet setWithObject:self.currentState];
    
    NSMutableArray *epsilonPathsToProcess = [NSMutableArray arrayWithObject:self];
    while (epsilonPathsToProcess.count > 0) {
        DFAutomatonPath *path = epsilonPathsToProcess[0];
        [epsilonPathsToProcess removeObjectAtIndex:0];
        
        for (DFTransition *transition in path.currentState.transitions) { // TODO: transitions should be immutable in public API
            if (![transition isKindOfClass:[DFEpsilonTransition class]])
                continue;
            
            if ([epsilonStatesSeen containsObject:transition.toState])
                continue; // state has already been entered into the queue
            
            // brand new epsilon state
            DFAutomatonPath *forkedPath = [path fork];
            [forkedPath followTransition:transition withInput:kEpsilonInput];
            
            [epsilonPaths addObject:forkedPath];
            [epsilonStatesSeen addObject:transition.toState];
            [epsilonPathsToProcess addObject:forkedPath];
        }
    }
    return epsilonPaths;
}

- (NSArray *)forksForNextInput {
    NSMutableArray *forks = [NSMutableArray array];
    for (DFTransition *transition in self.currentState.transitions) {
        if ([transition isKindOfClass:[DFEpsilonTransition class]])
            continue; // does not follow epsilon paths
        
        NSInteger matchLength = [transition matchInput:self.remainingInput];
        if (matchLength == 0)
            continue;
        
        NSString *matchedInput = [self.remainingInput substringToIndex:matchLength];
        DFAutomatonPath *fork = [self fork];
        [fork followTransition:transition withInput:matchedInput];
        [forks addObject:fork];
    }
    return forks;
}

- (DFAutomatonPath *)fork {
    return [self copy];
}

- (BOOL)hasMoreInput {
    return self.remainingInput.length > 0;
}

- (BOOL)isInAcceptingState {
    return self.currentState.acceptingState;
}

- (DFState *)currentState {
    if (self.transitionHistory.count == 0) {
        return self.automaton.startingState;
    } else {
        DFPathSegment *segment = [self.transitionHistory lastObject];
        return segment.transition.toState;
    }
}

- (void)followTransition:(DFTransition *)transition withInput:(NSString *)input {
    DFPathSegment *segment = [[DFPathSegment alloc] init];
    segment.transition = transition;
    segment.matchedInput = input;
    
    if (input != kEpsilonInput) {
        NSAssert([self.remainingInput rangeOfString:input].location == 0, @"string being matched must be at the start.");
        self.remainingInput = [self.remainingInput substringFromIndex:input.length];
    }
    
    [self.transitionHistory addObject:segment];
}

@end
