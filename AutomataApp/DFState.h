//
//  DFState.h
//  AutomataApp
//
//  Created by Ortal on 9/29/13.
//  Copyright (c) 2013 CS454. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFTransition.h"

@interface DFState : NSObject <NSCopying>

/*! \returns A string with each sorted state name concatted with a comma. (e.g. {a,b,c}). */
+ (NSString *)nameForCombinedStates:(NSSet *)states;
/*! \returns A string with each sorted state name concatted with a comma. (e.g. [a,b,c]). */
+ (NSString *)nameForCollapsedStates:(NSSet *)states;
+ (instancetype)stateWithName:(NSString *)name;
+ (instancetype)acceptingStateWithName:(NSString *)name;
/*! Generates many DFState objects, and indexes them in an NSDictionary.
 \param names An array of NSStrings for each of the state names.
 \returns An NSDictionary object with (NSString*, DFState*) pairs.
 */
+ (NSDictionary *)statesWithNames:(NSArray *)names;
/*! Generates many DFState objects, and indexes them in an NSDictionary. States should not exist in both lists.
 \param names An array of NSStrings for each of the non-accepting state names.
 \param acceptingNames The names for each of the accepting states.
 \returns An NSDictionary object with (NSString*, DFState*) pairs.
 */
+ (NSDictionary *)statesWithNames:(NSArray *)names acceptingStateNames:(NSArray *)acceptingNames;

@property (assign, nonatomic) BOOL acceptingState;
@property (copy, nonatomic) NSString *name;
/// Outgoing transitions. Array of DFATransition objects.
@property (readonly, nonatomic) NSArray *transitions;
@property (readonly, nonatomic) NSArray *incomingTransitions;

- (void)addEpsilonTransitionToState:(DFState *)state;
- (void)addTransition:(DFTransition *)transition;
/*! Creates many transitions via a dictionary.
 \param transitionsDictionary dictionary[NSString *input] = (Array[DFState *states] OR DFState*state)
 */
- (void)addTransitionsDictionary:(NSDictionary *)transitionsDictionary;
/*! Creates an epsilon, single character, or multi character transition. */
- (void)addTransitionToState:(DFState *)state onInput:(NSString *)input;
/*! Creates many single character input transitions. */
- (void)addTransitionToState:(DFState *)state onInputCharacters:(NSString *)input;
/*! Creates many epsilon, single character, or multi character transitions. */
- (void)addTransitionToState:(DFState *)state onInputs:(NSArray *)input;
- (NSSet *)inputs; // of NSString
/*! Checks that this state is the same as another based on all of its attributes (e.g. acceptingState, name), and verifies that this state has the same 
 transitions as another based on which state's each lead to (based on name). */
- (BOOL)isEqualToState:(DFState *)other;
/// \returns The state you would reach if you were to transition on \a input.
/// \pre The state must have exactly one transition on \a input.
/// \see statesForInput:
- (DFState *)stateForInput:(NSString *)input;
/// Returns all states you would reach if you were to transition on \a input.
/// \returns Set of DFState objects.
/// \note Does not follow Epsilon-paths.
/// \see stateForInput:
- (NSSet *)statesForInput:(NSString *)input;
- (void)removeAllTransitions;

+ (NSDictionary *)dictionaryFromStates:(NSSet *)states;

@end
