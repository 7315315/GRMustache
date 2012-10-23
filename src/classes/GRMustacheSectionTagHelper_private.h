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

#import <Foundation/Foundation.h>
#import "GRMustacheAvailabilityMacros_private.h"

@class GRMustacheSectionTagRenderingContext;
@class GRMustacheSectionElement;
@class GRMustacheRuntime;

// =============================================================================
#pragma mark - <GRMustacheSectionTagHelper>

// Documented in GRMustacheSectionTagHelper.h
@protocol GRMustacheSectionTagHelper<NSObject>
@required

// Documented in GRMustacheSectionTagHelper.h
- (NSString *)renderForSectionTagInContext:(GRMustacheSectionTagRenderingContext *)context GRMUSTACHE_API_PUBLIC;
@end


// =============================================================================
#pragma mark - GRMustacheSectionTagHelper

// Documented in GRMustacheSectionTagHelper.h
@interface GRMustacheSectionTagHelper: NSObject<GRMustacheSectionTagHelper>

// Documented in GRMustacheSectionTagHelper.h
+ (id)helperWithBlock:(NSString *(^)(GRMustacheSectionTagRenderingContext* context))block GRMUSTACHE_API_PUBLIC;

@end


// =============================================================================
#pragma mark - GRMustacheSectionTagRenderingContext

// Documented in GRMustacheSectionTagHelper.h
@interface GRMustacheSectionTagRenderingContext: NSObject {
@private
    GRMustacheSectionElement *_sectionElement;
    GRMustacheRuntime *_runtime;
}

// Documented in GRMustacheSectionTagHelper.h
@property (nonatomic, readonly) NSString *innerTemplateString GRMUSTACHE_API_PUBLIC;

/**
 * Builds and returns a context suitable for GRMustacheSectionTagHelper.
 *
 * @param sectionElement    The underlying sectionElement.
 * @param runtime           A runtime.
 *
 * @return A section rendering context.
 *
 * @see GRMustacheSectionTagHelper protocol
 * @see GRMustacheSectionElement
 * @see GRMustacheRuntime
 */
+ (id)contextWithSectionElement:(GRMustacheSectionElement *)sectionElement runtime:(GRMustacheRuntime *)runtime GRMUSTACHE_API_INTERNAL;

// Documented in GRMustacheSectionTagHelper.h
- (NSString *)render GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheSectionTagHelper.h
- (NSString *)renderObject:(id)object GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheSectionTagHelper.h
- (NSString *)renderObject:(id)object withFilters:(id)filters GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheSectionTagHelper.h
- (NSString *)renderString:(NSString *)string error:(NSError **)outError GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheSectionTagHelper.h
- (NSString *)renderObject:(id)object fromString:(NSString *)templateString error:(NSError **)outError GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheSectionTagHelper.h
- (NSString *)renderObject:(id)object withFilters:(id)filters fromString:(NSString *)templateString error:(NSError **)outError GRMUSTACHE_API_PUBLIC;

@end
