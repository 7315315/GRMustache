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

#import "GRMustacheSectionElement_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheInvocation_private.h"
#import "GRMustacheHelper_private.h"
#import "GRMustacheRenderingElement_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheSection_private.h"

@interface GRMustacheSectionElement()

/**
 * The rendering of Mustache sections depend on the value they are attached to,
 * whether they are truthy, falsey, enumerable, or helpers. The value is fetched
 * by applying this invocation to a rendering context.
 */
@property (nonatomic, retain) GRMustacheInvocation *invocation;

/**
 * The template string containing the inner template string of the section.
 */
@property (nonatomic, retain) NSString *templateString;

/**
 * The range of the inner template string of the section in `templateString`.
 */
@property (nonatomic) NSRange innerRange;

/**
 * YES if the section is {{^inverted}}; otherwise, NO.
 */
@property (nonatomic) BOOL inverted;

/**
 * The GRMustacheRenderingElement objects that make the section.
 * 
 * @see GRMustacheRenderingElement
 */
@property (nonatomic, retain) NSArray *elems;

/**
 * @see +[GRMustacheSectionElement sectionElementWithInvocation:templateString:innerRange:inverted:elements:]
 */
- (id)initWithInvocation:(GRMustacheInvocation *)invocation templateString:(NSString *)templateString innerRange:(NSRange)innerRange inverted:(BOOL)inverted elements:(NSArray *)elems;
@end


@implementation GRMustacheSectionElement
@synthesize templateString=_templateString;
@synthesize innerRange=_innerRange;
@synthesize invocation=_invocation;
@synthesize inverted=_inverted;
@synthesize elems=_elems;

+ (id)sectionElementWithInvocation:(GRMustacheInvocation *)invocation templateString:(NSString *)templateString innerRange:(NSRange)innerRange inverted:(BOOL)inverted elements:(NSArray *)elems
{
    return [[[self alloc] initWithInvocation:invocation templateString:templateString innerRange:innerRange inverted:inverted elements:elems] autorelease];
}

- (void)dealloc
{
    [_invocation release];
    [_templateString release];
    [_elems release];
    [super dealloc];
}

- (NSString *)innerTemplateString
{
    return [_templateString substringWithRange:_innerRange];
}

- (NSString *)renderElementsWithContext:(GRMustacheContext *)context forTemplate:(GRMustacheTemplate *)rootTemplate delegates:(NSArray *)delegates
{
    NSMutableString *result = [NSMutableString string];
    @autoreleasepool {
        for (id<GRMustacheRenderingElement> elem in _elems) {
            [result appendString:[elem renderContext:context forTemplate:rootTemplate delegates:delegates]];
        }
    }
    return result;
}

#pragma mark <GRMustacheRenderingElement>

- (NSString *)renderContext:(GRMustacheContext *)context forTemplate:(GRMustacheTemplate *)rootTemplate delegates:(NSArray *)delegates
{
    NSString *result = nil;
    @autoreleasepool {
        
        // invoke
        
        [_invocation invokeWithContext:context];
        
        
        // callback delegates in the delegate stack
        
        for (id<GRMustacheTemplateDelegate> delegate in delegates) {
            if ([delegate respondsToSelector:@selector(template:willInterpretReturnValueOfInvocation:as:)]) {
                // 4.1 API
                [delegate template:rootTemplate willInterpretReturnValueOfInvocation:_invocation as:GRMustacheInterpretationSection];
            } else if ([delegate respondsToSelector:@selector(template:willRenderReturnValueOfInvocation:)]) {
                // 4.0 API
                [delegate template:rootTemplate willRenderReturnValueOfInvocation:_invocation];
            }
        }
        
        id value = _invocation.returnValue;
        
        
        // extend the delegate stack if value is a GRMustacheTemplateDelegate
        
        NSArray *innerDelegates = delegates;
        if ([value conformsToProtocol:@protocol(GRMustacheTemplateDelegate)]) {
            if (delegates) {
                innerDelegates = [[NSArray arrayWithObject:value] arrayByAddingObjectsFromArray:delegates];
            } else {
                innerDelegates = [NSArray arrayWithObject:value];
            }
        }
        
        
        // interpret
        
        if (value == nil ||
            value == [NSNull null] ||
            ([value isKindOfClass:[NSNumber class]] && [((NSNumber*)value) boolValue] == NO) ||
            ([value isKindOfClass:[NSString class]] && [((NSString*)value) length] == 0))
        {
            // False value
            if (_inverted) {
                result = [[self renderElementsWithContext:context forTemplate:rootTemplate delegates:innerDelegates] retain];
            }
        }
        else if ([value isKindOfClass:[NSDictionary class]])
        {
            // True object value
            if (!_inverted) {
                GRMustacheContext *innerContext = [context contextByAddingObject:value];
                result = [[self renderElementsWithContext:innerContext forTemplate:rootTemplate delegates:innerDelegates] retain];
            }
        }
        else if ([value conformsToProtocol:@protocol(NSFastEnumeration)])
        {
            // Enumerable
            if (_inverted) {
                BOOL empty = YES;
                for (id object in value) {
                    empty = NO;
                    break;
                }
                if (empty) {
                    result = [[self renderElementsWithContext:context forTemplate:rootTemplate delegates:innerDelegates] retain];
                }
            } else {
                result = [[NSMutableString string] retain];
                for (id object in value) {
                    GRMustacheContext *innerContext = [context contextByAddingObject:object];
                    NSString *itemRendering = [self renderElementsWithContext:innerContext forTemplate:rootTemplate delegates:innerDelegates];
                    [(NSMutableString *)result appendString:itemRendering];
                }
            }
        }
        else if ([value conformsToProtocol:@protocol(GRMustacheHelper)])
        {
            // Helper
            if (!_inverted) {
                GRMustacheSection *section = [GRMustacheSection sectionWithSectionElement:self renderingContext:context rootTemplate:rootTemplate delegates:delegates];
                result = [[(id<GRMustacheHelper>)value renderSection:section] retain];
            }
        }
        else
        {
            // True object value
            if (!_inverted) {
                GRMustacheContext *innerContext = [context contextByAddingObject:value];
                result = [[self renderElementsWithContext:innerContext forTemplate:rootTemplate delegates:innerDelegates] retain];
            }
        }
        
        
        // finish
        
        for (id<GRMustacheTemplateDelegate> delegate in delegates) {
            if ([delegate respondsToSelector:@selector(template:didInterpretReturnValueOfInvocation:as:)]) {
                // 4.1 API
                [delegate template:rootTemplate didInterpretReturnValueOfInvocation:_invocation as:GRMustacheInterpretationSection];
            } else if ([delegate respondsToSelector:@selector(template:didRenderReturnValueOfInvocation:)]) {
                // 4.0 API
                [delegate template:rootTemplate didRenderReturnValueOfInvocation:_invocation];
            }
        }
    }
    if (!result) {
        return @"";
    }
    return [result autorelease];
}


#pragma mark Private

- (id)initWithInvocation:(GRMustacheInvocation *)invocation templateString:(NSString *)templateString innerRange:(NSRange)innerRange inverted:(BOOL)inverted elements:(NSArray *)elems
{
    self = [self init];
    if (self) {
        self.invocation = invocation;
        self.templateString = templateString;
        self.innerRange = innerRange;
        self.inverted = inverted;
        self.elems = elems;
    }
    return self;
}

@end
