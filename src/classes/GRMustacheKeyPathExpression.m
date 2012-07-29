// The MIT License
// 
// Copyright (c) 2012 Gwendal Roué
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "GRMustacheKeyPathExpression_private.h"
#import "GRMustacheInvocation_private.h"
#import "GRMustacheTemplate_private.h"

@interface GRMustacheKeyPathExpression()
@property (nonatomic, retain) GRMustacheInvocation *invocation;
- (id)initWithKeys:(NSArray *)keys;
@end

@implementation GRMustacheKeyPathExpression
@synthesize invocation = _invocation;

+ (id)expressionWithKeys:(NSArray *)keys 
{
    return [[[self alloc] initWithKeys:keys] autorelease];
}

- (id)initWithKeys:(NSArray *)keys
{
    self = [super init];
    if (self) {
        _invocation = [[GRMustacheInvocation invocationWithKeys:keys] retain];
    }
    return self;
}

- (void)dealloc
{
    [_invocation release];
    [super dealloc];
}

- (BOOL)isEqual:(id<GRMustacheExpression>)expression
{
    if (![expression isKindOfClass:[GRMustacheKeyPathExpression class]]) {
        return NO;
    }
    
    return [_invocation isEquivalentToInvocation:((GRMustacheKeyPathExpression *)expression).invocation];
}


#pragma mark GRMustacheExpression

- (GRMustacheToken *)debuggingToken
{
    return _invocation.debuggingToken;
}

- (void)setDebuggingToken:(GRMustacheToken *)debuggingToken
{
    _invocation.debuggingToken = debuggingToken;
}

- (void)prepareForContext:(GRMustacheContext *)context filterContext:(GRMustacheContext *)filterContext delegatingTemplate:(GRMustacheTemplate *)delegatingTemplate delegates:(NSArray *)delegates interpretation:(GRMustacheInterpretation)interpretation
{
    [_invocation invokeWithContext:context];
    [delegatingTemplate invokeDelegates:delegates willInterpretReturnValueOfInvocation:_invocation as:interpretation];
}

- (void)finishForContext:(GRMustacheContext *)context filterContext:(GRMustacheContext *)filterContext delegatingTemplate:(GRMustacheTemplate *)delegatingTemplate delegates:(NSArray *)delegates interpretation:(GRMustacheInterpretation)interpretation
{
    [delegatingTemplate invokeDelegates:delegates didInterpretReturnValueOfInvocation:_invocation as:interpretation];
    _invocation.returnValue = nil;
}

@end
