//
//  DFTransition.h
//  DFA
//
//  Created by Ortal on 9/25/13.
//
//

#import <Foundation/Foundation.h>

@class DFState;

@interface DFTransition : NSObject
@property (strong, nonatomic) NSString *input;
@property (strong, nonatomic) DFState *toState; // the state to transition to
@property (weak, readonly, nonatomic) DFState *fromState;
/*! \returns The length of the successfully matched input.*/
- (NSInteger)matchInput:(NSString *)input;
/// Gets all the outgoing transitions for each of the \a states.
/// \returns an array of DFTransition objects.
+ (NSArray *)transitionsOfStates:(NSSet *)states;
+ (instancetype)transitionToState:(DFState *)state onInput:(NSString *)input; // returns a simple matching transition
@end

@interface DFSingleCharTransition : DFTransition
+ (instancetype)transitionToState:(DFState *)state onInput:(NSString *)input;
@end

@interface DFEpsilonTransition : DFTransition
+ (instancetype)transitionToState:(DFState *)state;
@end

@interface DFMultiCharTransition : DFTransition
+ (instancetype)transitionToState:(DFState *)state onInput:(NSString *)input;
@end

@interface DFRegexTransition : DFTransition
+ (instancetype)transitionToState:(DFState *)state onInputMatch:(NSString *)regex;
+ (instancetype)transitionOnAnyInputToState:(DFState *)state;
@end