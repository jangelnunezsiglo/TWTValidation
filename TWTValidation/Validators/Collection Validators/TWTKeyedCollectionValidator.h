//
//  TWTKeyedCollectionValidator.h
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/29/2014.
//  Copyright (c) 2014 Two Toasters, LLC.
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

#import <TWTValidation/TWTValueValidator.h>

/*!
 TWTKeyedCollectionValidators validate keyed collection, e.g., dictionaries and map tables. Keyed 
 collection validators validate a collection’s count, keys, values, and specific key-value pairs. 

 Keyed collection validators are immutable objects. As such, sending -copy or -copyWithZone: to a 
 collection validator will simply return the validator itself.
 */
@interface TWTKeyedCollectionValidator : TWTValidator <NSCopying>

/*!
 @abstract The validator for a keyed collection’s count.
 @discussion If nil, keyed collections with any number of objects will pass validation.
 */
@property (nonatomic, strong, readonly) TWTValidator *countValidator;

/*!
 @abstract The validators for a keyed collection’s keys.
 @discussion A keyed collection is only valid if all its keys pass validation by all the key validators.
     If nil, all keys in a collection will pass validation. Keyed collection validators get a collection’s
     keys using fast enumeration.
 */
@property (nonatomic, copy, readonly) NSArray *keyValidators;

/*!
 @abstract The validators for a keyed collection’s values.
 @discussion A keyed collection is only valid if all its values pass validation by all the value validators.
     If nil, all values in a collection will pass validation. Keyed collection validators get a collection’s
     value for a specific key by sending the collection the -objectForKey: message.
 */
@property (nonatomic, copy, readonly) NSArray *valueValidators;

/*!
 @abstract The validators for specific key-value pairs in a keyed collection.
 @discussion These validators must be instances of TWTKeyValuePairValidator.
 
     A keyed collection is only valid if all its key-value pairs pass validation by their corresponding
     key-value pair validators. If there is no key-value pair validator for a particular key, the key-value
     pair will always pass validation.
 */
@property (nonatomic, copy, readonly) NSArray *keyValuePairValidators;

/*!
 @abstract Initializes a newly created keyed collection validator with the specified count, key, value, and 
     key-value pair validators.
 @discussion This is the class’s designated initializer.
 @param countValidator The validator to validate a collection’s count. If nil, collections with any number of
     objects will pass validation.
 @param keyValidators The validators to use for a collection’s keys. If nil, the resulting validator
     will successfully validate all a collection’s keys.
 @param valueValidators The validators to use for a collection’s values. If nil, the resulting validator
     will successfully validate all a collection’s values.
 @param keyValuePairValidators The validators to use for specific key-value pairs in a collection. The objects
     must be elements of TWTKeyValuePairValidator. If nil, the resulting validator will successfully validate 
     all a collection’s key-value pairs. If there is no key-value pair validator for a particular key, that 
     key-value pair will always pass validation.
 @result An initialized collection validator with the specified count, key, value, and key-value pair
     validators.
 */
- (instancetype)initWithCountValidator:(TWTValidator *)countValidator
                         keyValidators:(NSArray *)keyValidators
                       valueValidators:(NSArray *)valueValidators
                keyValuePairValidators:(NSArray *)keyValuePairValidators;

@end
