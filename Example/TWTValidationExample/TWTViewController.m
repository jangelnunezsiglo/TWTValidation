//
//  TWTViewController.m
//  TWTValidationExample
//
//  Created by Ameir Al-Zoubi on 6/12/14.
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

#import "TWTViewController.h"

#import <TWTToast/TWTKeyValueObserver.h>
#import <TWTValidation/TWTValidation.h>

@interface TWTViewController ()

@property (nonatomic, strong) TWTKeyValueObserver *formValidObserver;
@property (nonatomic, strong) TWTKeyValueCodingValidator *formValidator;

@property (nonatomic, copy) NSString *emailAddress;
@property (nonatomic, strong) NSNumber *age;
@property (nonatomic, copy) NSString *password;

@property (nonatomic, assign) IBOutlet UITextField *emailField;
@property (nonatomic, assign) IBOutlet UITextField *ageField;
@property (nonatomic, assign) IBOutlet UITextField *passwordField;

@property (nonatomic, assign) IBOutlet UIButton *doneButton;

@end


@implementation TWTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup our Key Value Coding Validator with keyPaths of our form data
    self.formValidator = [[TWTKeyValueCodingValidator alloc] initWithKeys:[NSSet setWithObjects:@"emailAddress", @"age", @"password", nil]];
    
    // Setup a listner so we can take action when the form validates
    self.formValidObserver = [[TWTKeyValueObserver alloc] initWithObject:self
                                                                 keyPath:@"formValid"
                                                                 options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                                          startObserving:NO
                                                                  target:self
                                                                  action:@selector(formValidDidChange)];
    
    // Set targets for our textfields so we can update our form data with their contents
    [self.emailField addTarget:self action:@selector(emailFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.ageField addTarget:self action:@selector(ageFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.passwordField addTarget:self action:@selector(passwordFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.formValidObserver startObserving];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.formValidObserver stopObserving];
}


#pragma mark - Validators

+ (NSSet *)twt_validatorsForEmailAddress
{
    return [NSSet setWithObjects:[TWTStringValidator stringValidatorWithMinimumLength:3 maximumLength:99],
            [TWTStringValidator stringValidatorWithRegularExpression:[NSRegularExpression regularExpressionWithPattern:@".+@.+" options:0 error:nil] options:0],
            nil];
}


+ (NSSet *)twt_validatorsForAge
{
    return [NSSet setWithObject:[[TWTNumberValidator alloc] initWithMinimum:@13 maximum:@150]];
}


+ (NSSet *)twt_validatorsForPassword
{
    return [NSSet setWithObject:[TWTStringValidator stringValidatorWithMinimumLength:5 maximumLength:99]];
}


#pragma mark - Key Value Observing

- (BOOL)isFormValid
{
    NSError *error;
    BOOL valid = [self.formValidator validateValue:self error:&error];
    
    if (!valid) {
        NSLog(@"Error: %@", [error description]);
    }
    
    return valid;
}


- (void)formValidDidChange
{
    self.doneButton.enabled = [self isFormValid];
}


+ (NSSet *)keyPathsForValuesAffectingFormValid
{
    return [NSSet setWithObjects:@"emailAddress", @"age", @"password", nil];
}

#pragma mark - Text Field Actions

- (void)emailFieldDidChange:(id)sender
{
    self.emailAddress = self.emailField.text;
}


- (void)ageFieldDidChange:(id)sender
{
    self.age = @(self.ageField.text.integerValue);
}


- (void)passwordFieldDidChange:(id)sender
{
    self.password = self.passwordField.text;
}


@end
