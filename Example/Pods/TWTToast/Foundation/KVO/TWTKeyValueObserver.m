//
//  TWTKeyValueObserver.m
//  Toast
//
//  Created by Josh Johnson on 3/12/14.
//  Copyright (c) 2014 Two Toasters.
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

#import "TWTKeyValueObserver.h"

@interface TWTKeyValueObserver ()

@property (nonatomic, weak, readwrite) id object;
@property (nonatomic, copy, readwrite) NSString *keyPath;
@property (nonatomic, assign, getter = isObserving, readwrite) BOOL observing;

@property (nonatomic, assign) NSKeyValueObservingOptions options;
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, copy) TWTKeyValueObserverChangeBlock changeBlock;

@end


@implementation TWTKeyValueObserver

#pragma mark - NSObject

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


- (void)dealloc
{
    if ([self isObserving]) {
        [self stopObserving];
    }
}

#pragma mark - TWTKeyValueObserver

+ (instancetype)observerWithObject:(id)object keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options changeBlock:(TWTKeyValueObserverChangeBlock)changeBlock
{
    return [self observerWithObject:object keyPath:keyPath options:options startObserving:YES changeBlock:changeBlock];
}


+ (instancetype)observerWithObject:(id)object keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options target:(id)target action:(SEL)action
{
    return [self observerWithObject:object keyPath:keyPath options:options startObserving:YES target:target action:action];
}


+ (instancetype)observerWithObject:(id)object keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options startObserving:(BOOL)startObserving changeBlock:(TWTKeyValueObserverChangeBlock)changeBlock
{
    return [[self alloc] initWithObject:object keyPath:keyPath options:options startObserving:startObserving changeBlock:changeBlock];
}


+ (instancetype)observerWithObject:(id)object keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options startObserving:(BOOL)startObserving target:(id)target action:(SEL)action
{
    return [[self alloc] initWithObject:object keyPath:keyPath options:options startObserving:startObserving target:target action:action];
}


- (instancetype)initWithObject:(id)object keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options startObserving:(BOOL)startObserving changeBlock:(TWTKeyValueObserverChangeBlock)changeBlock
{
    self = [super init];
    if (self) {
        self.object = object;
        self.keyPath = keyPath;
        self.options = options;
        self.changeBlock = changeBlock;
        
        if (startObserving) {
            [self startObserving];
        }
    }
    return self;
}

- (instancetype)initWithObject:(id)object keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options changeBlock:(TWTKeyValueObserverChangeBlock)changeBlock
{
    return [self initWithObject:object keyPath:keyPath options:options startObserving:YES changeBlock:changeBlock];
}


- (instancetype)initWithObject:(id)object keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options startObserving:(BOOL)startObserving target:(id)target action:(SEL)action
{
    self = [super init];
    if (self) {
        self.object = object;
        self.keyPath = keyPath;
        self.options = options;
        self.target = target;
        self.action = action;
        
        if (![self target:target hasValidSignatureForSelector:action]) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"Action method must have a signature that conforms. A conforming signature recieves at most a changed object and a change dictionary."
                                         userInfo:nil];
        }
        
        if (startObserving) {
            [self startObserving];
        }
    }
    return self;
}


- (instancetype)initWithObject:(id)object keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options target:(id)target action:(SEL)action
{
    return [self initWithObject:object keyPath:keyPath options:options startObserving:YES target:target action:action];
}


- (void)startObserving
{
    if (![self isObserving]) {
        [self.object addObserver:self
                      forKeyPath:self.keyPath
                         options:self.options
                         context:(__bridge void *)self];
        self.observing = YES;
    }
}


- (void)stopObserving
{
    if ([self isObserving]) {
        [self.object removeObserver:self
                         forKeyPath:self.keyPath
                            context:(__bridge void *)self];
        self.observing = NO;
    }
}


#pragma mark - Observation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)self) {
        if (self.changeBlock) {
            self.changeBlock(object, change);
        }
        else if ([self.target respondsToSelector:self.action]) {
            NSMethodSignature *methodSignature = [self.target methodSignatureForSelector:self.action];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            invocation.target = self.target;
            invocation.selector = self.action;
            
            if (methodSignature.numberOfArguments > 2) {
                // add object argument to at index 2
                [invocation setArgument:&object atIndex:2];
            }
            
            if (methodSignature.numberOfArguments > 3) {
                // add change dictionary at index 3
                [invocation setArgument:&change atIndex:3];
            }
            
            [invocation invoke];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark - Model Method Signatures for verifying action

- (void)model_objectChanged
{
    // Empty Implementation, method is only used for verifying action method signature
}


- (void)model_objectChanged:(id)object
{
    // Empty Implementation, method is only used for verifying action method signature
}


- (void)model_objectChanged:(id)object changeDictionary:(NSDictionary *)changeDictionary
{
    // Empty Implementation, method is only used for verifying action method signature
}


#pragma mark - Validation

- (BOOL)target:(id)target hasValidSignatureForSelector:(SEL)action;
{
    if (target == nil || action == NULL) {
        return NO;
    }
    
    NSMethodSignature *actionMethodSignature = [target methodSignatureForSelector:action];
    NSArray *validMethodSignatures = @[ [self methodSignatureForSelector:@selector(model_objectChanged)],
                                        [self methodSignatureForSelector:@selector(model_objectChanged:)],
                                        [self methodSignatureForSelector:@selector(model_objectChanged:changeDictionary:)] ];
    
    for (NSMethodSignature *modelMethodSignature in validMethodSignatures) {
        if ([actionMethodSignature isEqual:modelMethodSignature]) {
            return YES;
        }
    }
    
    return NO;
}

@end
