//
//  DFConsts.h
//  DFA
//
//  Created by Ortal on 8/27/13.
//
//

#import <Foundation/Foundation.h>

#define DFPair(x, y) [NSSet setWithArray:@[(x), (y)]]

typedef void (^DFCompletionBlockWithError)(NSError *error);

extern NSString * const kEpsilonInput;