//
//  DFAutomaton+Samples.h
//  DFA
//
//  Created by Ortal on 9/25/13.
//
//

#import "DFAutomaton.h"

@interface DFAutomaton (Samples)

+ (instancetype)even1sBinaryAutomaton;
+ (instancetype)startAndEndSameCharBinaryAutomaton;
+ (instancetype)endsWithIngAutomaton;
+ (instancetype)singleLevelParenMathAutomaton;
+ (instancetype)twoMatrixGreaterThanBinaryComp;
+ (instancetype)twoMatrixGreaterThanBinaryUnsignedComp;
+ (instancetype)epsilonSampleAutomaton;
+ (instancetype)automatonForAllNumbersDivisibleBy:(NSInteger)divisor;
+ (instancetype)automatonForAllNumbersNearlyDivisibleBy:(NSInteger)divisor;

@end
