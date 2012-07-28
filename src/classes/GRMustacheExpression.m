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

#import "GRMustacheExpression_private.h"


// =============================================================================
#pragma mark - GRMustacheKeyPathExpression

@interface GRMustacheKeyPathExpression()
- (id)initWithKeys:(NSArray *)keys;
@end

@implementation GRMustacheKeyPathExpression
@synthesize keys = _keys;

+ (id)expressionWithKeys:(NSArray *)keys
{
    return [[[self alloc] initWithKeys:keys] autorelease];
}

- (id)initWithKeys:(NSArray *)keys
{
    self = [super init];
    if (self) {
        _keys = [keys retain];
    }
    return self;
}

- (void)dealloc
{
    [_keys release];
    [super dealloc];
}

- (BOOL)isEqual:(id<GRMustacheExpression>)expression
{
    if (![expression isKindOfClass:[GRMustacheKeyPathExpression class]]) {
        return NO;
    }
    
    return [_keys isEqualToArray:((GRMustacheKeyPathExpression *)expression).keys];
}

@end


// =============================================================================
#pragma mark - GRMustacheFilterChainExpression

@interface GRMustacheFilterChainExpression()
- (id)initWithExpressions:(NSArray *)expressions;
@end

@implementation GRMustacheFilterChainExpression
@synthesize expressions = _expressions;

+ (id)expressionWithExpressions:(NSArray *)expressions
{
    return [[[self alloc] initWithExpressions:expressions] autorelease];
}

- (id)initWithExpressions:(NSArray *)expressions
{
    self = [super init];
    if (self) {
        _expressions = [expressions retain];
    }
    return self;
}

- (void)dealloc
{
    [_expressions release];
    [super dealloc];
}

- (BOOL)isEqual:(id<GRMustacheExpression>)expression
{
    if (![expression isKindOfClass:[GRMustacheFilterChainExpression class]]) {
        return NO;
    }
    
    return [_expressions isEqualToArray:((GRMustacheFilterChainExpression *)expression).expressions];
}

@end
