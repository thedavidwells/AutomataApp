//
//  DFState_Private.h
//  AutomataApp
//
//  Created by Ortal on 10/5/13.
//  Copyright (c) 2013 CS454. All rights reserved.
//

#import "DFState.h"

@interface DFState ()
@property (strong, readonly, nonatomic) NSMutableArray *mutableIncomingTransitions; // of DFATransition
@end
