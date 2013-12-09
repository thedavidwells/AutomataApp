//
//  DFAutomaton.h
//  DFA
//
//  Created by Ortal on 8/27/13.
//
//

#import <Foundation/Foundation.h>
#import "DFUtils.h"
#import "DFTransition.h"
#import "DFConsts.h"
#import "DFState.h"

@class DFTransition;

typedef NS_ENUM(NSInteger, DFAutomatonType) {
    DFAutomatonTypeDFA,
    DFAutomatonTypeNFA,
    DFAutomatonTypeENFA,
    DFAutomatonTypeGNFA,
};

@interface DFAutomaton : NSObject

@property (strong, nonatomic) DFState *startingState;

- (BOOL)acceptsString:(NSString *)string;

/// Converts an NFA or ENFA to a DFA.
/// It only leaves reachable states.
- (DFAutomaton *)convertToDFA;
- (DFAutomatonType)determineType;
/*! Computes the recursive epsilon closures of every state in this FA.
 \returns Dictionary with DFState keys and Set<DFState> values.
 */
- (NSDictionary *)epsilonClosures;
- (NSSet *)finalStates;
- (NSSet *)nonFinalStates;
- (NSString *)prettyPrint;

/*! \returns NSSet of NSString objects. */
- (NSSet *)inputs;

- (BOOL)isEqualToAutomaton:(DFAutomaton *)other;

/*! \brief Minimizes a DFA using Hopcroft's algorithm.

 All state names will be the same unless they have been minimized, in which case
 they will appear as \p "[q0,q1,...]".
 \pre It is your responsibitilty to ensure that it is a valid DFA (e.g. by calling \a determineType before invoking this method).
 \returns The number of states that have been removed.
 */
- (NSInteger)minimizeDFA;
- (DFState *)stateForName:(NSString *)stateName;

- (void)removeUnreachableStates;

/*! Traverses entire state path.
 \returns Set of DFState objects. */
- (NSSet *)reachableStates;
- (NSSet *)unreachableStates;
- (NSSet *)allStates;

- (BOOL)validateWithCompletion:(DFCompletionBlockWithError)completion;

+ (instancetype)automatonWithStartingState:(DFState *)startingState;

@end