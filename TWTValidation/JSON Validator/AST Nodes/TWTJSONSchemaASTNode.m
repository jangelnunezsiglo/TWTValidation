//
//  TWTJSONSchemaASTNode.m
//  TWTValidation
//
//  Created by Jill Cohen on 12/12/14.
//  Copyright (c) 2015 Ticketmaster Entertainment, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <TWTValidation/TWTJSONSchemaASTNode.h>

#import <URLMock/NSException+UMKSubclassResponsibility.h>


@implementation TWTJSONSchemaASTNode

- (void)acceptProcessor:(id)processor
{
    [NSException umk_subclassResponsibilityExceptionWithReceiver:self selector:_cmd];
}


- (NSSet *)validTypes
{
    [NSException umk_subclassResponsibilityExceptionWithReceiver:self selector:_cmd];
    return nil;
}


- (NSArray *)childrenReferenceNodes
{
    NSMutableArray *referenceNodes = [[NSMutableArray alloc] init];

    [referenceNodes addObjectsFromArray:[self childrenReferenceNodesFromNodeArray:self.andSchemas]];
    [referenceNodes addObjectsFromArray:[self childrenReferenceNodesFromNodeArray:self.orSchemas]];
    [referenceNodes addObjectsFromArray:[self childrenReferenceNodesFromNodeArray:self.exactlyOneOfSchemas]];
    [referenceNodes addObjectsFromArray:self.notSchema.childrenReferenceNodes];

    [referenceNodes addObjectsFromArray:[self childrenReferenceNodesFromNodeDictionary:self.definitions]];

    return referenceNodes;
}


- (NSArray *)childrenReferenceNodesFromNodeArray:(NSArray *)array
{
    if (!array) {
        return @[ ];
    }

    NSMutableArray *referenceNodes = [[NSMutableArray alloc] init];
    for (TWTJSONSchemaASTNode *node in array) {
        [referenceNodes addObjectsFromArray:node.childrenReferenceNodes];
    }
    return [referenceNodes copy];
}


- (NSArray *)childrenReferenceNodesFromNodeDictionary:(NSDictionary *)dictionary
{
    if (!dictionary) {
        return @[ ];
    }

    NSMutableArray *referenceNodes = [[NSMutableArray alloc] init];
    for (NSString *key in dictionary) {
        [referenceNodes addObjectsFromArray:[dictionary[key] childrenReferenceNodes]];
    }
    return [referenceNodes copy];
}


- (TWTJSONSchemaASTNode *)nodeForPathComponents:(NSArray *)path
{
    if (path.count == 0) {
        return self;
    }

    NSString *key = path.firstObject;
    NSArray *remainingPath = [self remainingPathFromPath:path];

    if ([key isEqualToString:TWTJSONSchemaKeywordAllOf]) {
        return [self nodeForPathComponents:remainingPath fromNodeArray:self.andSchemas];
    } else if ([key isEqualToString:TWTJSONSchemaKeywordAnyOf]) {
        return [self nodeForPathComponents:remainingPath fromNodeArray:self.orSchemas];
    } else if ([key isEqualToString:TWTJSONSchemaKeywordOneOf]) {
        return [self nodeForPathComponents:remainingPath fromNodeArray:self.exactlyOneOfSchemas];
    } else if ([key isEqualToString:TWTJSONSchemaKeywordNot]) {
        return [self.notSchema nodeForPathComponents:remainingPath];
    } else if ([key isEqualToString:TWTJSONSchemaKeywordDefinitions]) {
        return [self nodeForPathComponents:remainingPath fromDefinitions:self.definitions];
    }

    return nil;
}


- (TWTJSONSchemaASTNode *)nodeForPathComponents:(NSArray *)path fromNodeArray:(NSArray *)array
{
    NSString *index = path.firstObject;
    if (!index || ![self componentIsIndex:index] || index.integerValue > array.count) {
        return nil;
    }

    return [array[index.integerValue] nodeForPathComponents:[self remainingPathFromPath:path]];
}


- (TWTJSONSchemaASTNode *)nodeForPathComponents:(NSArray *)path fromDefinitions:(NSDictionary *)definitions
{
    NSString *key = path.firstObject;

    return [definitions[key] nodeForPathComponents:[self remainingPathFromPath:path]];
}


- (BOOL)componentIsIndex:(NSString *)key
{
    NSRange nonDigitCharacterRange = [key rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    return nonDigitCharacterRange.location == NSNotFound;
}


- (NSArray *)remainingPathFromPath:(NSArray *)path
{
    return [path subarrayWithRange:NSMakeRange(1, path.count - 1)];
}
 
@end

