//
//  DFUtils.h
//  DFA
//
//  Created by Ortal on 9/14/13.
//
//

#import <Foundation/Foundation.h>

@interface DFUtils : NSObject

+ (NSString *)stringByIntermixingCharPositionsLeft:(NSString *)leftArray right:(NSString *)rightArray;
/*! Creates an NSArray object by splitting up an NString into individual characters. 
 \returns NSArray of NSString objects.*/
+ (NSArray *)arrayFromString:(NSString *)string;
+ (NSString *)binaryFromDecimal:(NSInteger)decimal digits:(NSInteger)digits;
+ (NSArray *)allBinaryStringsOfLength:(NSInteger)length;
+ (BOOL)dictionary:(NSDictionary *)dictionary1 isEqualToDictionary:(NSDictionary *)dictionary2;
/// \returns The length of the longest string in \a strings.
/// \param strings NSArray of NSString objects.
+ (NSInteger)maxStringLengthInArray:(NSArray *)strings;

/// Appends the text from column to list. Ensures that each column is of the same length.
/// \param column Array of NSString objects.
/// \param list Array of NSString objects.
/// \pre \a column and \a list must have the same number of elements. The list should be aligned already to the previous column's length.
+ (void)outputColumn:(NSArray*)column toList:(NSMutableArray *)list;

/// \returns The dot product of the two matrixes as an NSArray of NSArray of NSNumber.
/// \pre \a matrix1 must have the same number of columns as \a matrix2's rows. Both matrixes must be NSArrays of NSArrays of NSNumbers.
+ (NSArray *)multiplyMatrix:(NSArray *)matrix1 byMatrix:(NSArray *)matrix2;
+ (NSArray *)raiseMatrix:(NSArray *)matrix toPower:(NSInteger)power;
@end

/// When using a set as a key in a dictionary, the lookup time is extremely slow. That is because the hash value of an NSSet returns the number of elements instead of a more useful hash. As a result, all elements end up in the same bucket.
@interface NSSet (DFUtils)
@end

@interface NSArray (DFUtils)
/// Maps an array of values into a new array. Return nil if the item should not be in the resulting array.
- (NSArray *)dfMap:(id(^)(id obj))mapFunction;
@end