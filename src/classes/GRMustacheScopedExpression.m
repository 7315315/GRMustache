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

#import "GRMustacheScopedExpression_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheInvocation_private.h"

@interface GRMustacheScopedExpression()
@property (nonatomic, retain) id<GRMustacheExpression> baseExpression;
@property (nonatomic, copy) NSString *scopeIdentifier;

- (id)initWithBaseExpression:(id<GRMustacheExpression>)baseExpression scopeIdentifier:(NSString *)scopeIdentifier;
@end

@implementation GRMustacheScopedExpression
@synthesize baseExpression=_baseExpression;
@synthesize scopeIdentifier=_scopeIdentifier;

+ (id)expressionWithBaseExpression:(id<GRMustacheExpression>)baseExpression scopeIdentifier:(NSString *)scopeIdentifier
{
    return [[[self alloc] initWithBaseExpression:baseExpression scopeIdentifier:scopeIdentifier] autorelease];
}

- (id)initWithBaseExpression:(id<GRMustacheExpression>)baseExpression scopeIdentifier:(NSString *)scopeIdentifier
{
    self = [super init];
    if (self) {
        self.baseExpression = baseExpression;
        self.scopeIdentifier = scopeIdentifier;
    }
    return self;
}

- (void)dealloc
{
    [_baseExpression release];
    [_scopeIdentifier release];
    [super dealloc];
}

- (BOOL)isEqual:(id<GRMustacheExpression>)expression
{
    if (![expression isKindOfClass:[GRMustacheScopedExpression class]]) {
        return NO;
    }
    if (![_baseExpression isEqual:((GRMustacheScopedExpression *)expression).baseExpression]) {
        return NO;
    }
    return [_scopeIdentifier isEqual:((GRMustacheScopedExpression *)expression).scopeIdentifier];
}


#pragma mark - GRMustacheExpression

- (id)valueForContext:(GRMustacheContext *)context filterContext:(GRMustacheContext *)filterContext delegatingTemplate:(GRMustacheTemplate *)delegatingTemplate delegates:(NSArray *)delegates invocation:(GRMustacheInvocation **)outInvocation
{
    id value = [_baseExpression valueForContext:context filterContext:filterContext delegatingTemplate:delegatingTemplate delegates:delegates invocation:outInvocation];
    value = [GRMustacheContext valueForKey:_scopeIdentifier inObject:value];
    if (delegatingTemplate) {
        NSAssert(outInvocation, @"WTF");
        if (*outInvocation == nil) {
            *outInvocation = [[[GRMustacheInvocation alloc] init] autorelease];
        }
        if (value || (*outInvocation).isScopable) {
            (*outInvocation).scopable = (value != nil);
            (*outInvocation).returnValue = value;
            (*outInvocation).key = _scopeIdentifier;
        }
    }
    return value;
}

@end
