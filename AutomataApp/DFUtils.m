//
//  DFUtils.m
//  DFA
//
//  Created by Ortal on 9/14/13.
//
//

#import "DFUtils.h"

typedef struct {
    int* data;
    int rows;
    int cols;
} Matrix;

@implementation DFUtils

+ (NSString *)stringByIntermixingCharPositionsLeft:(NSString *)leftArray right:(NSString *)rightArray {
    // TODO: come up with a better name
    // 0001, 1111 would become the string: 01010111
    NSAssert(leftArray.length == rightArray.length, @"Must be same length.");
    NSMutableString *string = [NSMutableString string];
    for (int i = 0; i < leftArray.length; i++) {
        NSString *char1 = [leftArray substringWithRange:NSMakeRange(i, 1)];
        NSString *char2 = [rightArray substringWithRange:NSMakeRange(i, 1)];
        [string appendFormat:@"%@%@", char1, char2];
    }
    return string;
}

+ (NSArray *)arrayFromString:(NSString *)string {
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < string.length; i++) {
        [array addObject:[string substringWithRange:NSMakeRange(i, 1)]];
    }
    return [array copy];
}

+ (NSString *)binaryFromDecimal:(NSInteger)decimal digits:(NSInteger)digits {
    NSAssert(digits == 4, @"Only works for 4 right now.");
    NSAssert(decimal >= -8 && decimal <= 7, @"out of bounds.");
    NSArray *positives = @[@"0000", @"0001", @"0010", @"0011", @"0100", @"0101", @"0110", @"0111"];
    NSArray *negatives = @[@"0000", @"1111", @"1110", @"1101", @"1100", @"1011", @"1010", @"1001", @"1000"];
    /*
     7: 0111
     6: 0110
     5: 0101
     4: 0100
     3: 0011
     2: 0010
     1: 0001
     0: 0000
     -1: 1111
     -2: 1110
     -3: 1101
     -4: 1100
     -5: 1011
     -6: 1010
     -7: 1001
     -8: 1000*/
    if (decimal < 0) {
        return negatives[-decimal];
    } else {
        return positives[decimal];
    }
}

+ (NSArray *)allBinaryStringsOfLength:(NSInteger)length {
    // returns array of nsstring
    if (length == 0) {
        return @[@""];
    }
    
    NSArray *previousStrings = [self allBinaryStringsOfLength:length - 1];
    NSMutableArray *binaryStrings = [NSMutableArray array];
    
    // append 0s
    for (NSString *binaryString in previousStrings) {
        [binaryStrings addObject:[binaryString stringByAppendingString:@"0"]];
    }
    
    // append 1s
    for (NSString *binaryString in previousStrings) {
        [binaryStrings addObject:[binaryString stringByAppendingString:@"1"]];
    }
    
    return binaryStrings;
}

+ (BOOL)dictionary:(NSDictionary *)dictionary1 isEqualToDictionary:(NSDictionary *)dictionary2 {
    if ([dictionary1 allKeys].count != [dictionary2 allKeys].count) {
        return NO;
    }
    for (id key in dictionary1) {
        id id1 = [dictionary1 objectForKey:key];
        id id2 = [dictionary2 objectForKey:key];
        NSAssert([id1 isKindOfClass:[NSObject class]], @"Must be object for now.");
        NSAssert([id2 isKindOfClass:[NSObject class]], @"Must be object for now.");
        NSObject *object1 = id1;
        NSObject *object2 = id2;
        
        if ([object1 isKindOfClass:[NSSet class]] && [object2 isKindOfClass:[NSSet class]]) {
            NSSet *set1 = (NSSet *)object1;
            NSSet *set2 = (NSSet *)object2;
            if (![set1 isEqualToSet:set2]) {
                return NO;
            }
        } else if ([object1 isKindOfClass:[NSArray class]] && [object2 isKindOfClass:[NSArray class]]) {
            NSArray *array1 = (NSArray *)object1;
            NSArray *array2 = (NSArray *)object2;
            if (![array1 isEqualToArray:array2]) {
                return NO;
            }
        } else if ([object1 isKindOfClass:[NSDictionary class]] && [object2 isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict1 = (NSDictionary *)object1;
            NSDictionary *dict2 = (NSDictionary *)object2;
            if (![self dictionary:dict1 isEqualToDictionary:dict2]) {
                return NO;
            }
        } else {
            if (![object1 isEqual:object2]) {
                return NO;
            }
        }
    }
    return YES;
}

+ (NSInteger)maxStringLengthInArray:(NSArray *)strings {
    NSInteger length = 0;
    for (NSString *string in strings) {
        NSAssert([string isKindOfClass:[NSString class]], @"Must be string objects.");
        if (string.length > length) {
            length = string.length;
        }
    }
    return length;
}

+ (void)outputColumn:(NSArray *)column toList:(NSMutableArray *)list {
    NSAssert(column.count == list.count, @"Must have the same count.");
    NSInteger maxLength = [DFUtils maxStringLengthInArray:column];
    for (int i = 0; i < column.count; i++) {
        NSString *cellText = column[i];
        cellText = [cellText stringByPaddingToLength:maxLength withString:@" " startingAtIndex:0];
        list[i] = [((NSString *)list[i]) stringByAppendingString:cellText];
    }
}


void setMatrixValue(Matrix *matrix, int row, int col, int value) {
    assert(0 <= row && row < matrix->rows);
    assert(0 <= col && col < matrix->cols);
    matrix->data[row*matrix->cols + col] = value;
}
int getMatrixValue(Matrix *matrix, int row, int col) {
    assert(0 <= row && row < matrix->rows);
    assert(0 <= col && col < matrix->cols);
    return matrix->data[row*matrix->cols + col];
}
Matrix newMatrixFromCopy(Matrix matrix) {
    Matrix result = newMatrix(matrix.rows, matrix.cols);
    int elementCount = matrix.rows * matrix.cols;
    for (int i = 0; i < elementCount; i++) {
        result.data[i] = matrix.data[i];
    }
    return result;
}
Matrix newMatrix(int rows, int cols) {
    Matrix matrix;
    matrix.data = malloc(sizeof(int)*rows*cols);
    matrix.rows = rows;
    matrix.cols = cols;
    return matrix;
}
void freeMatrix(Matrix *matrix) {
    matrix->data = NULL;
    matrix->rows = 0;
    matrix->cols = 0;
}
/// \returns a new matrix.
Matrix newMatrixFromPower(Matrix matrix, int n) {
    if (n == 1) {
        return newMatrixFromCopy(matrix);
    } else if (n % 2 == 0) {
        Matrix temp = newMatrixFromPower(matrix, n/2);
        Matrix result = newMatrixFromMultiply(temp, temp);
        freeMatrix(&temp);
        return result;
    } else {
        Matrix temp = newMatrixFromPower(matrix, (n-1)/2);
        Matrix result1 = newMatrixFromMultiply(temp, temp);
        freeMatrix(&temp);
        Matrix result2 = newMatrixFromMultiply(result1, matrix);
        freeMatrix(&result1);
        return result2;
    }
}
/// \returns a new matrix, \p matrix1.rows by \p matrix2.cols.
Matrix newMatrixFromMultiply(Matrix matrix1, Matrix matrix2) {
    assert(matrix1.cols == matrix2.rows); // Matrix1's cols must be the same amount as matrix 2's rows.
    Matrix resultMatrix = newMatrix(matrix1.rows, matrix2.cols);
    
    for (int m1Row = 0; m1Row < matrix1.rows; m1Row++) {
        for (int m2Col = 0; m2Col < matrix2.cols; m2Col++) {
            // multiply m1Row by m2Col
            int result = 0;
            for (int m1Col = 0; m1Col < matrix1.cols; m1Col++) {
                int m2Row = m1Col;
                result += getMatrixValue(&matrix1, m1Row, m1Col) * getMatrixValue(&matrix2, m2Row, m2Col);
            }
            setMatrixValue(&resultMatrix, m1Row, m2Col, result);
        }
    }
    return resultMatrix;
}

+ (Matrix)newMatrixFromArray:(NSArray *)matrix {
    NSInteger m1Rows = [matrix count];
    NSInteger m1Cols = [matrix[0] count];
    
    NSAssert([matrix[0] isKindOfClass:[NSArray class]], @"Must be an array.");
    NSAssert([matrix[0][0] isKindOfClass:[NSNumber class]], @"Must be a number.");
    
    Matrix result = newMatrix(m1Rows, m1Cols);
    
    NSInteger i = 0;
    for (NSArray *array in matrix) {
        NSInteger j = 0;
        for (NSNumber *number in array) {
            setMatrixValue(&result, i, j, [number integerValue]);
            j++;
        }
        i++;
    }

    return result;
}
+ (NSArray *)arrayFromMatrix:(Matrix)matrix {
    // convert to cocoa objects
    NSMutableArray *resultMatrix = [NSMutableArray array];
    for (int i = 0; i < matrix.rows; i++) {
        NSMutableArray *resultRow = [NSMutableArray array];
        for (int j = 0; j < matrix.cols; j++) {
            [resultRow addObject:@(getMatrixValue(&matrix, i, j))];
        }
        [resultMatrix addObject:resultRow];
    }
    return resultMatrix;
}

+ (NSArray *)raiseMatrix:(NSArray *)matrix toPower:(NSInteger)power {
    Matrix m1 = [self newMatrixFromArray:matrix];
    Matrix m2 = newMatrixFromPower(m1, power);
    NSArray *result = [self arrayFromMatrix:m2];
    
    freeMatrix(&m1);
    freeMatrix(&m2);
    return result;
}

+ (NSArray *)multiplyMatrix:(NSArray *)matrix1 byMatrix:(NSArray *)matrix2 {
    // Note: performing the calculations on NSArrays with NSNumbers yields very poor performance. Instead, use C arrays.
    Matrix m1 = [self newMatrixFromArray:matrix1];
    Matrix m2 = [self newMatrixFromArray:matrix2];
    Matrix m3 = newMatrixFromMultiply(m1, m2);
    NSArray *result = [self arrayFromMatrix:m3];

    freeMatrix(&m1);
    freeMatrix(&m2);
    freeMatrix(&m3);
    
    return result;
}

@end

@implementation NSSet (DFUtils)

- (NSUInteger)hash {
    // TODO: I read that it was dangerous to change the hash of a mutable object, is this true? NSMutableSet doesn't seem to obey this.
//    if ([self isKindOfClass:[NSMutableSet class]]) {
//        return <#expression#>
//        // it's dangerous to change the hash of a mutable object, so use default mechanism
//    }
//    DFState *stateA = [DFState stateWithName:@"a"];
//    DFState *stateB = [DFState stateWithName:@"a"];
//    NSLog(@"HASH A: %d", [stateA hash]);
//    NSLog(@"HASH B: %d", [stateB hash]);
//    NSSet *set = [NSSet setWithArray:@[@"a", @"b"]];
//    NSLog(@"HASH SET: %d", [set hash]);
//    NSMutableSet *mset = [NSMutableSet setWithArray:@[@"a", @"b"]];
//    NSLog(@"HASH MUTABLE SET: %d", [mset hash]);
//    [mset addObject:@"c"];
//    NSLog(@"HASH MUTABLE SET: %d", [mset hash]);

    // TODO: ideally we wouldn't modify the framework under someone, so we should instead subclass NSSet, the problem is that NSSet has many abstract methods we would need to override.
    NSUInteger result = 0;
    for (id object in self) {
        result += [object hash];
    }
    return result;
}

@end

@implementation NSArray (DFUtils)

- (NSArray *)dfMap:(id(^)(id))mapFunction {
    NSMutableArray *result = [NSMutableArray array];
    for (id obj in self) {
        id object = mapFunction(obj);
        if (object != nil)
            [result addObject:object];
    }
    return [result copy];
}

@end
