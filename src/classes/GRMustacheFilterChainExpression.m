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

#import "GRMustacheFilterChainExpression_private.h"
#import "GRMustacheInvocation_private.h"
#import "GRMustacheFilter.h"

@interface GRMustacheFilterChainExpression()
@property (nonatomic, retain) GRMustacheInvocation *invocation;
@property (nonatomic, retain) id<GRMustacheExpression> filteredExpression;
@property (nonatomic, retain) NSArray *filterExpressions;
- (id)initWithFilteredExpression:(id<GRMustacheExpression>)filteredExpression filterExpressions:(NSArray *)filterExpressions;
@end

@implementation GRMustacheFilterChainExpression
@synthesize invocation = _invocation;
@synthesize filteredExpression = _filteredExpression;
@synthesize filterExpressions = _filterExpressions;

+ (id)expressionWithFilteredExpression:(id<GRMustacheExpression>)filteredExpression filterExpressions:(NSArray *)filterExpressions
{
    return [[[self alloc] initWithFilteredExpression:filteredExpression filterExpressions:filterExpressions] autorelease];
}

- (id)initWithFilteredExpression:(id<GRMustacheExpression>)filteredExpression filterExpressions:(NSArray *)filterExpressions
{
    self = [super init];
    if (self) {
        _filteredExpression = [filteredExpression retain];
        _filterExpressions = [filterExpressions retain];
    }
    return self;
}

- (void)dealloc
{
    [_invocation release];
    [_filteredExpression release];
    [_filterExpressions release];
    [super dealloc];
}

- (BOOL)isEqual:(id<GRMustacheExpression>)expression
{
    if (![expression isKindOfClass:[GRMustacheFilterChainExpression class]]) {
        return NO;
    }
    if (![_filteredExpression isEqual:((GRMustacheFilterChainExpression *)expression).filteredExpression]) {
        return NO;
    }
    return [_filterExpressions isEqualToArray:((GRMustacheFilterChainExpression *)expression).filterExpressions];
}


#pragma mark GRMustacheExpression

- (GRMustacheToken *)debuggingToken
{
    return _filteredExpression.debuggingToken;
}

- (void)setDebuggingToken:(GRMustacheToken *)debuggingToken
{
    _filteredExpression.debuggingToken = debuggingToken;
    for (id<GRMustacheExpression> filterExpression in _filterExpressions) {
        filterExpression.debuggingToken = debuggingToken;
    }
}

- (void)prepareForContext:(GRMustacheContext *)context filterContext:(GRMustacheContext *)filterContext delegatingTemplate:(GRMustacheTemplate *)delegatingTemplate delegates:(NSArray *)delegates interpretation:(GRMustacheInterpretation)interpretation
{
    [_filteredExpression prepareForContext:context filterContext:filterContext delegatingTemplate:delegatingTemplate delegates:delegates interpretation:interpretation];
    self.invocation = _filteredExpression.invocation;
    
    for (id<GRMustacheExpression> filterExpression in _filterExpressions) {
        [filterExpression prepareForContext:filterContext filterContext:filterContext delegatingTemplate:delegatingTemplate delegates:delegates interpretation:GRMustacheInterpretationFilter];
        GRMustacheInvocation *filterInvocation = filterExpression.invocation;
        id<GRMustacheFilter> filter = filterInvocation.returnValue;
        
        if (filter == nil) {
            [NSException raise:GRMustacheFilterException format:@"Missing filter for key `%@` in tag %@", filterInvocation.key, filterInvocation.description];
        }
        
        if (![filter conformsToProtocol:@protocol(GRMustacheFilter)]) {
            [NSException raise:GRMustacheFilterException format:@"Object for key `%@` in tag %@ does not conform to GRMustacheFilter protocol: %@", filterInvocation.key, filterInvocation.description, filter];
        }
        
        if (filter) {
            _invocation.returnValue = [filter transformedValue:_invocation.returnValue];
        }
    }
}

- (void)finishForContext:(GRMustacheContext *)context filterContext:(GRMustacheContext *)filterContext delegatingTemplate:(GRMustacheTemplate *)delegatingTemplate delegates:(NSArray *)delegates interpretation:(GRMustacheInterpretation)interpretation
{
    for (id<GRMustacheExpression> filterExpression in _filterExpressions) {
        [filterExpression finishForContext:filterContext filterContext:filterContext delegatingTemplate:delegatingTemplate delegates:delegates interpretation:GRMustacheInterpretationFilter];
    }
    
    [_filteredExpression finishForContext:context filterContext:filterContext delegatingTemplate:delegatingTemplate delegates:delegates interpretation:interpretation];
    
    self.invocation = nil;
}


@end
