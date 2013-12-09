//
//  DFAutomaton.m
//  DFA
//
//  Created by Ortal on 8/27/13.
//
//

#import "DFAutomaton.h"
#import "DFAutomatonPath.h"

const BOOL kOutputReasons = NO;

@interface DFMinimizeCell : NSObject
/// Set of pair of DFState* objects.
@property (nonatomic, strong) NSSet *key;
@property (nonatomic, assign) BOOL marked;
- (void)addDependency:(DFMinimizeCell *)dependency;
/// Marks everything in the dependency chain, and removes some dependencies.
- (void)markRecursively;

/// Returns nil if the pair would have contained the same element.
/// \returns Set/pair of DFState objects.
- (NSSet *)pairForInput:(NSString *)input;
/// Creates a new DFMinimizeCell object.
/// \param key Set/pair of DFState objects.
+ (instancetype)cellWithKey:(NSSet *)key;
@end
@interface DFMinimizeCell ()

/// Array of DFMinimizeCell
@property (nonatomic, strong) NSMutableArray *dependencies;

/// Gets all dependencies including the current item.
/// \returns Set of DFMinimizeCell objects.
- (NSSet *)getAllRecursiveDependencies;
@end
@implementation DFMinimizeCell
- (void)addDependency:(DFMinimizeCell *)dependency {
    [self.dependencies addObject:dependency];
}
- (void)markRecursively {
    NSSet *allDependencies = [self getAllRecursiveDependencies];
    for (DFMinimizeCell *cell in allDependencies) {
        cell.marked = YES;
        [cell.dependencies removeAllObjects]; // NOTE: doesn't remove everything it can. For example, if a cell depends on two items, only one of those connections will probably be deleted.
    }
}
- (NSSet *)pairForInput:(NSString *)input {
    NSMutableSet *result = [NSMutableSet set];
    NSAssert([self.key count] == 2, @"Must have 2 elements.");
    for (DFState *state in self.key) {
        [result addObject:[state stateForInput:input]];
    }
    
    if (result.count == 1) {
        // return nil when it would have returned the same item twice
        return nil;
    } else {
        return [NSSet setWithSet:result];
    }
}
- (NSSet *)getAllRecursiveDependencies {
    NSMutableSet *dependencies = [NSMutableSet setWithObject:self];
    NSMutableArray *objectsToProcess = [NSMutableArray arrayWithObject:self];
    
    while ([objectsToProcess count] > 0) {
        DFMinimizeCell *cell = objectsToProcess[0];
        [objectsToProcess removeObjectAtIndex:0];
        NSAssert([cell isKindOfClass:[DFMinimizeCell class]], @"Expected DFMinimizeCell objects.");
        
        for (DFMinimizeCell *dependency in cell.dependencies) {
            if (![dependencies containsObject:dependency]) {
                [dependencies addObject:dependency];
                [objectsToProcess addObject:dependency];
            }
        }
    }
    return dependencies;
}
+ (instancetype)cellWithKey:(NSSet *)key {
    DFMinimizeCell *cell = [[[self class] alloc] init];
    cell.key = key;
    cell.dependencies = [NSMutableArray array];
    return cell;
}
@end

@implementation DFAutomaton

- (NSString *)description {
    NSMutableString *result = [NSMutableString stringWithFormat:@"-->%@\n", self.startingState];
    for (DFState *state in [self allStates]) {
        for (DFTransition *transition in state.transitions) {
            [result appendFormat:@"%@--%@-->%@\n", state, transition.input, transition.toState];
        }
    }

    return result;
}

- (BOOL)acceptsString:(NSString *)string {
    DFAutomatonPath *successPath = [DFAutomatonPath successPathForAutomaton:self withInput:string];
    return successPath != nil;
}
- (DFAutomaton *)convertToDFA {
    DFAutomatonType type = [self determineType];
    NSSet *finalStates = [self finalStates];
    if (type == DFAutomatonTypeDFA) {
        return self; // TODO: copy the automaton?
    }
    NSAssert(type == DFAutomatonTypeNFA || type == DFAutomatonTypeENFA, @"This has only been tested for NFAs and ENFAs.");
    
    NSArray *inputs = [self.inputs allObjects];
    DFState *deadState = [DFState stateWithName:@"{}"];
    for (NSString *input in inputs) {
        NSAssert(input.length == 1, @"Only works for single characters for now.");
        [deadState addTransitionToState:deadState onInput:input];
    }
    
    NSDictionary *epsilonClosures = [self epsilonClosures];
    NSSet *startingStates = epsilonClosures[self.startingState];
    DFState *newStartState = [DFState stateWithName:[DFState nameForCombinedStates:startingStates]];
    newStartState.acceptingState = [startingStates intersectsSet:finalStates];

    NSMutableArray *stateSetsToProcess = [NSMutableArray arrayWithObject:startingStates]; // Array[Set[DFState*] states]
    NSMutableArray *stateSetsToProcess_state = [NSMutableArray arrayWithObject:newStartState]; // the corresponding DFState* object
    NSMutableDictionary *ultimateStates = [NSMutableDictionary dictionaryWithDictionary:@{startingStates: newStartState}]; // dictionary[NSSet *states] = (DFState* state)

    while (stateSetsToProcess.count > 0) {
        // dequeue a stateSet
        NSSet *stateSet = stateSetsToProcess[0];
        NSAssert([[stateSet anyObject] isKindOfClass:[DFState class]], @"Expecting DFState objects.");
        [stateSetsToProcess removeObjectAtIndex:0];
        DFState *stateSetState = stateSetsToProcess_state[0]; // the corresponding resulting state for stateSet
        NSAssert([stateSetState isKindOfClass:[DFState class]], @"Expecting DFState.");
        [stateSetsToProcess_state removeObjectAtIndex:0];
        
        // process the stateSet
        for (NSString *input in inputs) {
            // on this state set (e.g. {a}), given an input (e.g. 1), get the stateForInput (e.g. {a,b,c}).
            NSMutableSet *statesForInputWithoutETrans = [NSMutableSet set];
            for (DFState *state in stateSet) {
                [statesForInputWithoutETrans unionSet:[state statesForInput:input]];
            }
            NSMutableSet *statesForInput = [NSMutableSet set];
            for (DFState *stateForInput in statesForInputWithoutETrans) {
                NSSet *epsStates = epsilonClosures[stateForInput];
                [statesForInput unionSet:epsStates];
            }
            DFState *stateForInput;
            if (statesForInput.count == 0) {
                stateForInput = deadState;
            } else {
                if (ultimateStates[statesForInput] == nil) {
                    // we haven't created this set of states yet
                    DFState *newState = [DFState stateWithName:[DFState nameForCombinedStates:statesForInput]];
                    newState.acceptingState = [statesForInput intersectsSet:finalStates];
                    
                    [stateSetsToProcess addObject:statesForInput];
                    [stateSetsToProcess_state addObject:newState];
                    
                    ultimateStates[statesForInput] = newState;
                }
                NSAssert(ultimateStates[statesForInput] != nil, @"NSSet isn't working correctly as a dictionary key.");
                stateForInput = ultimateStates[statesForInput];
            }
            [stateSetState addTransitionToState:stateForInput onInput:input];
        }
    }
    
    return [DFAutomaton automatonWithStartingState:newStartState];
}
- (DFAutomatonType)determineType {
    NSString *reasons = nil;
    DFAutomatonType type = [self determineTypeWithReasons:&reasons];
    if (reasons && kOutputReasons) {
        NSLog(@"%@", reasons);
    }
    return type;
}
- (DFAutomatonType)determineTypeWithReasons:(NSString **)reasonsOut {
    /*  Does it have these properties?
     Y: Yes
     N: No
     A: Allowed (doesn't necessarily have it)
     
     .               DFA     NFA     ENFA    GNFA
     Eps-trans       N       N       Y       A
     Rgx-trans       N       N       N       Y
     Dupe-inputs     N       A       A       A
     Missing-inp     N       A       A       A
     
     Note: DFA takes precedence over NFA.
     Note: Rgx-trans = Rgx-trans || hasMultiCharTransitions
     */

    NSSet *inputs = [self inputs];
    NSSet *allStates = [self allStates];
    NSArray *transitions = [DFTransition transitionsOfStates:allStates];
    NSMutableString *reasons = [NSMutableString string];
    BOOL hasEpsilonTransitions = NO;
    BOOL hasMultiCharTransitions = NO;
    BOOL hasRegexTransitions = NO;
    BOOL hasDuplicateInputs = NO;
    BOOL hasMissingInputs = NO;

    for (DFTransition *transition in transitions) {
        if ([transition isKindOfClass:[DFEpsilonTransition class]]) {
            if (!hasEpsilonTransitions) {
                hasEpsilonTransitions = YES;
                [reasons appendFormat:@"Epsilon transition found (%@)\n", transition];
            }
        } else if ([transition isKindOfClass:[DFMultiCharTransition class]]) {
            if (!hasMultiCharTransitions) {
                hasMultiCharTransitions = YES;
                [reasons appendFormat:@"Multi-char transition found (%@)\n", transition];
            }
        } else if ([transition isKindOfClass:[DFRegexTransition class]]) {
            if (!hasRegexTransitions) {
                hasRegexTransitions = YES;
                [reasons appendFormat:@"Regex transition found (%@)\n", transition];
            }
        }
    }
    
    // multi-char transitions are considered regex transitions
    hasRegexTransitions = hasRegexTransitions || hasMultiCharTransitions;
    
    // first two types can now be checked
    if (reasonsOut && reasons.length) {
        *reasonsOut = [reasons copy];
    }
    if (hasRegexTransitions) {
        return DFAutomatonTypeGNFA;
    } else if (hasEpsilonTransitions) {
        return DFAutomatonTypeENFA;
    }
    
    // from this point on, it will either be an NFA or DFA
    
    // For all these examples, assume the language is L = {A,B,C}.
    for (DFState *state in allStates) {
        NSSet *stateInputs = [state inputs];
        if (stateInputs.count < inputs.count) {
            hasMissingInputs = YES; // e.g. state has transitions on {A,B}. or state has transitions on {A,A,B}
            NSMutableSet *missingInputs = [NSMutableSet setWithSet:inputs];
            [missingInputs minusSet:stateInputs];
            [reasons appendFormat:@"Missing inputs (%@) on state (%@)\n", missingInputs, state];
        } else if (inputs.count < state.transitions.count) {
            if (!hasDuplicateInputs) {
                hasDuplicateInputs = YES; // e.g. state has transitions on {A,A,B,C}
                // TODO: output which states are duplicates
                [reasons appendFormat:@"Duplicate inputs on state (%@)\n", state];
            }
        }
    }
    
    if (reasonsOut && reasons.length) {
        *reasonsOut = [reasons copy];
    }
    if (!hasMissingInputs && !hasDuplicateInputs) {
        NSAssert(!hasEpsilonTransitions && !hasRegexTransitions, @"Must not have had these other conditions.");
        return DFAutomatonTypeDFA;
    } else {
        return DFAutomatonTypeNFA;
    }
}
- (NSDictionary *)epsilonClosures {
    NSMutableDictionary *epsilonClosures = [NSMutableDictionary dictionary]; // only add to the dictionary once the item is complete
    NSMutableArray *statesToProcess = [NSMutableArray arrayWithArray:[[self allStates] allObjects]];
    while (statesToProcess.count > 0) {
        DFState *currentState = statesToProcess[0];
        [statesToProcess removeObjectAtIndex:0];

        NSMutableSet *currentEpsilonClosureStates = [NSMutableSet setWithObject:currentState];
        NSMutableArray *epsilonStatesToProcess = [NSMutableArray arrayWithObject:currentState];
        while (epsilonStatesToProcess.count > 0) {
            DFState *epsState = epsilonStatesToProcess[0];
            [epsilonStatesToProcess removeObjectAtIndex:0];
            
            for (DFTransition *transition in epsState.transitions) {
                if (![transition isKindOfClass:[DFEpsilonTransition class]]) {
                    continue; // not an epsilon transition
                }
                // found an epsilon transition
                if ([currentEpsilonClosureStates containsObject:transition.toState]) {
                    continue; // we already know about this state
                }
                
                [currentEpsilonClosureStates addObject:transition.toState];
                if (epsilonClosures[transition.toState] != nil) {
                    // we have already computed this epsilon closure, so use our cached value
                    [currentEpsilonClosureStates unionSet:epsilonClosures[transition.toState]];
                } else {
                    // never computed this epsilon closure
                    [epsilonStatesToProcess addObject:transition.toState];
                }
            }
        }
        
        NSAssert(epsilonClosures[currentState] == nil, @"Must not have already been set.");
        epsilonClosures[currentState] = currentEpsilonClosureStates;
    }
    return epsilonClosures;
}
- (NSSet *)finalStates {
    NSMutableSet *finalStates = [NSMutableSet set];
    for (DFState *state in [self allStates]) {
        if (state.acceptingState) {
            [finalStates addObject:state];
        }
    }
    return finalStates;
}
- (NSSet *)nonFinalStates {
    NSMutableSet *states = [[self allStates] mutableCopy];
    [states minusSet:[self finalStates]];
    return states;
}

- (NSSet *)inputs {
    NSMutableSet *inputs = [NSMutableSet set];
    for (DFState *state in [self allStates]) {
        [inputs unionSet:[state inputs]];
    }
    return [inputs copy];
}
- (BOOL)isEqualToAutomaton:(DFAutomaton *)other {
    if (self == other) {
        return YES;
    }

    // check first state manually, because the first state status must be the same
    if (![self.startingState isEqualToState:other.startingState]) {
        return NO;
    }
    
    NSSet *states = [self allStates];
    NSSet *otherStates = [other allStates];
    
    if (states.count != otherStates.count)
        return NO;
        
    NSDictionary *otherStatesDict = [DFState dictionaryFromStates:otherStates];
    for (DFState *state in states) {
        DFState *otherState = otherStatesDict[state.name];
        if (![state isEqualToState:otherState]) {
            return NO;
        }
    }
    return YES;
}


- (NSInteger)minimizeDFA {
    NSAssert([self determineType] == DFAutomatonTypeDFA, @"Can only minimize DFAs, try converting to a DFA first.");
    
    NSSet *inputs = [self inputs];
    
    // create grid
    NSSet *states = [self allStates];
    /// of DFState
    NSArray *statesArray = [states allObjects];
    /// Keys are NSSet, Values are DFMinimizeCell
    NSMutableDictionary *minimizeCells = [NSMutableDictionary dictionary];
    // Note: it is very slow to use two for...in loops, so instead use this method
    for (int i = 0; i < statesArray.count; i++) {
        for (int j = i+1; j < statesArray.count; j++) {
            NSSet *keyPair = [NSSet setWithArray:@[statesArray[i], statesArray[j]]];
            [minimizeCells setObject:[DFMinimizeCell cellWithKey:keyPair] forKey:keyPair];
        }
    }
    
    // 1. mark all pairs of final and non-final states.
    NSSet *finalStates = self.finalStates;
    NSMutableSet *statesM = [states mutableCopy];
    [statesM minusSet:finalStates];
    NSSet *nonFinalStates = [statesM copy];
    for (DFState *finalState in finalStates) {
        for (DFState *nonFinalState in nonFinalStates) {
            DFMinimizeCell *cell = minimizeCells[DFPair(finalState, nonFinalState)];
            [cell markRecursively];
        }
    }
    
    // 2. create set of all pairs of final X final, and non-final X non-final states
    NSMutableSet *initiallyUnmarkedCells = [NSMutableSet set]; // of DFMinimizeCell
    for (DFState *finalState1 in finalStates) {
        for (DFState *finalState2 in finalStates) {
            if (finalState1 != finalState2) {
                NSAssert(![minimizeCells[DFPair(finalState1, finalState2)] marked], @"Must not have been marked yet.");
                [initiallyUnmarkedCells addObject:minimizeCells[DFPair(finalState1, finalState2)]];
            }
        }
    }
    for (DFState *nonFinalState1 in nonFinalStates) {
        for (DFState *nonFinalState2 in nonFinalStates) {
            if (nonFinalState1 != nonFinalState2) {
                NSAssert(![minimizeCells[DFPair(nonFinalState1, nonFinalState2)] marked], @"Must not have been marked yet.");
                [initiallyUnmarkedCells addObject:minimizeCells[DFPair(nonFinalState1, nonFinalState2)]];
            }
        }
    }
    
    for (DFMinimizeCell *cell in initiallyUnmarkedCells) {
        // 3. see if any input symbol has it
        BOOL foundMarkedPair = NO;
        for (NSString *input in inputs) {
            NSSet *pair = [cell pairForInput:input];
            if (!pair)
                continue;
            
            DFMinimizeCell *cellForPair = minimizeCells[pair];
            if (cellForPair.marked) {
                foundMarkedPair = YES;
                break;
            }
        }
        
        if (foundMarkedPair) {
            // 4 & 5
            [cell markRecursively];
        } else {
            // 6
            for (NSString *input in inputs) {
                NSSet *pair = [cell pairForInput:input];
                if (!pair)
                    continue;
                
                // 7
                DFMinimizeCell *cellForPair = minimizeCells[pair];
                NSAssert(!cellForPair.marked, @"Should have found it if it had already been marked.");
                [cellForPair addDependency:cell];
            }
        }
    }
    
    // Grid is complete at this stage. Anything not marked is equivalent.
    NSMutableArray *unmarkedPairs = [NSMutableArray array]; // of NSSet of DFState
    for (NSSet *key in minimizeCells) {
        DFMinimizeCell *cell = minimizeCells[key];
        if (!cell.marked) {
            [unmarkedPairs addObject:key];
        }
    }
    
    if ([unmarkedPairs count] == 0) {
        // nothing could be minimized
        return 0;
    }
    

    // Collapse all the sets. For example, say we end up with the following pairs: [a,b] [b,c] [a,c] [d,e]
    // this should be: [a,b,c] [d,e].
    
    // begin at the first element [a,b], now go through the entire list, and "steal" all the elements it intersects with.
    NSMutableArray *finalStateEquivalences = [NSMutableArray array];
    for (int i = 0; i < unmarkedPairs.count; i++) {
        NSMutableSet *setI = [unmarkedPairs[i] mutableCopy];
        for (int j = unmarkedPairs.count - 1; j > i; j--) {
            NSSet *setJ = unmarkedPairs[j];
            if ([setI intersectsSet:setJ]) {
                [setI unionSet:setJ];
                [unmarkedPairs removeObjectAtIndex:j];
            }
        }
        [finalStateEquivalences addObject:setI];
    }
    
    // We now have something such as [a,b,c] [d,e]
    NSInteger totalStatesRemoved = 0;
    for (NSSet *setOfEquivalentStates in finalStateEquivalences) {
        NSMutableArray *equivalentStates = [[setOfEquivalentStates allObjects] mutableCopy];
        totalStatesRemoved += equivalentStates.count - 1;
        DFState *masterState; // the state to keep
        if ([setOfEquivalentStates containsObject:self.startingState]) {
            // make sure not to delete the starting state
            masterState = self.startingState;
        } else {
            // select the one with the first letter in the alphabet
            [equivalentStates sortUsingComparator:^NSComparisonResult(DFState *obj1, DFState *obj2) {
                return [obj1.name caseInsensitiveCompare:obj2.name];
            }];
            masterState = equivalentStates[0];
        }
        
        // rename the master state
        masterState.name = [DFState nameForCollapsedStates:[NSSet setWithArray:equivalentStates]];
        
        // now delete all the rest of the states
        [equivalentStates removeObject:masterState];
        for (DFState *equivalentState in equivalentStates) {
            // consolidate all incoming transitions
            for (DFTransition *transition in equivalentState.incomingTransitions) {
                // the incoming transition should be routed to the master
                transition.toState = masterState;
            }
            [equivalentState removeAllTransitions];
        }
    }
    
    NSAssert([self determineType] == DFAutomatonTypeDFA, @"Minimizing retains the DFA type.");
    return totalStatesRemoved;
}

- (DFState *)stateForName:(NSString *)stateName {
    // breadth first search across the tree to find the name
    NSMutableSet *visitedStates = [NSMutableSet set]; // of DFState*
    NSMutableArray *statesToVisit = [NSMutableArray array];
    NSAssert(self.startingState, @"Must have an initial starting state in order for search to work.");
    [visitedStates addObject:self.startingState];
    [statesToVisit addObject:self.startingState];
    while (statesToVisit.count > 0) {
        DFState *state = statesToVisit[0];
        [statesToVisit removeObjectAtIndex:0];
        
        // first check if this is the correct state
        if ([state.name isEqualToString:stateName]) {
            return state;
        }
        
        // if not, then check all of its children
        for (DFTransition *transition in state.transitions) {
            if ([visitedStates containsObject:transition.toState])
                continue;
            [visitedStates addObject:transition.toState];
            [statesToVisit addObject:transition.toState];
        }
    }
    return nil;
}
- (NSSet *)_statesByFollowingIncomingToo:(BOOL)followIncoming {
    NSMutableSet *states = [NSMutableSet set];
    NSMutableArray *queue = [NSMutableArray array]; // array of DFStates which have never been processed before
    
    [queue addObject:self.startingState];
    [states addObject:self.startingState];
    
    while (queue.count > 0) {
        // process first item in queue
        DFState *state = queue[0];
        [queue removeObjectAtIndex:0];
        
        // add each transitions state to the queue
        for (DFTransition *transition in state.transitions) {
            DFState *transitionState = transition.toState;
            if (![states containsObject:transitionState]) {
                // only add to queue if we haven't seen it already
                [queue addObject:transitionState];
                [states addObject:transitionState];
            }
        }
        if (followIncoming) {
            // add each transitions state to the queue
            for (DFTransition *transition in state.incomingTransitions) {
                DFState *transitionState = transition.fromState;
                if (![states containsObject:transitionState]) {
                    // only add to queue if we haven't seen it already
                    [queue addObject:transitionState];
                    [states addObject:transitionState];
                }
            }
        }
    }
    return [states copy];
}
- (NSSet *)reachableStates {
    return [self _statesByFollowingIncomingToo:NO];
}
- (NSSet *)allStates {
    return [self _statesByFollowingIncomingToo:YES];
}
- (NSSet *)unreachableStates {
    NSMutableSet *set = [[self allStates] mutableCopy];
    [set minusSet:[self reachableStates]];
    return set;
}

- (void)removeUnreachableStates {
    for (DFState *state in [self unreachableStates]) {
        [state removeAllTransitions];
    }
}

- (BOOL)validateWithCompletion:(DFCompletionBlockWithError)completion {
    return YES;
    // TODO: return NO if one or more inputs are missing, if there are multiple states with the same name, etc.
}

- (NSString *)prettyPrint {
    /* Example:
     starting state: a
     accepting states: {b,c}
     
        0    1    2
     a  b  {b,c}  b
     b  a         c
     c  c    c    c
     */

    /// of NSString
    NSArray *sortedInputs = [[[self inputs] allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    /// of DFState
    NSArray *sortedStates = [[[self allStates] allObjects] sortedArrayUsingComparator:^NSComparisonResult(DFState *obj1, DFState *obj2) {
        return [obj1.name localizedCaseInsensitiveCompare:obj2.name];
    }];
    
    BOOL isDFA = [self determineType] == DFAutomatonTypeDFA;
    
    // of NSString
    NSMutableArray *stateNames = [[sortedStates dfMap:^id(DFState *obj) {
        return obj.name;
    }] mutableCopy];
    [stateNames insertObject:@"" atIndex:0];
    
    /// of NSString
    NSMutableArray *outputLines = [NSMutableArray array];
    NSMutableArray *colSeparator = [NSMutableArray array];
    for (NSString *string in stateNames) {
        [outputLines addObject:@""];
        [colSeparator addObject:@"  "];
    }

    
    // output col 1 (the state names)
    [DFUtils outputColumn:stateNames toList:outputLines];
    
    for (NSString *input in sortedInputs) {
        NSMutableArray *column = [NSMutableArray arrayWithObject:input];
        for (DFState *state in sortedStates) {
            NSArray *transitionStates = [[state statesForInput:input] allObjects];
            NSArray *sortedTransitionStateNames = [[transitionStates dfMap:^id(DFState *obj) {
                return obj.name;
            }] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            NSString *cellText = [sortedTransitionStateNames componentsJoinedByString:@","];
            if (!isDFA) {
                cellText = [NSString stringWithFormat:@"{%@}", cellText];
            }
            [column addObject:cellText];
        }
        
        // output col n
        [DFUtils outputColumn:colSeparator toList:outputLines];
        [DFUtils outputColumn:column toList:outputLines];
    }
    
    [outputLines addObject:[NSString stringWithFormat:@"Starting state: %@", self.startingState.name]];
    NSString *finalStates = [[[[[self finalStates] allObjects] dfMap:^id(DFState *obj) {
        return obj.name;
    }] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] componentsJoinedByString:@","];
    [outputLines addObject:[NSString stringWithFormat:@"Accepting states: {%@}", finalStates]];
    return [outputLines componentsJoinedByString:@"\n"];
}

+ (instancetype)automatonWithStartingState:(DFState *)startingState {
    DFAutomaton *automaton = [[self alloc] init];
    automaton.startingState = startingState;
    return automaton;
}

@end