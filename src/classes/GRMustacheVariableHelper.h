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
#import "GRMustacheAvailabilityMacros.h"

@class GRMustacheVariable;


// =============================================================================
#pragma mark - <GRMustacheVariableHelper>

/**
 * The protocol for implementing Mustache "variable lambdas".
 *
 * The responsability of a GRMustacheVariableHelper is to render a Mustache
 * variable tag such as `{{name}}`.
 *
 * When the data given to a Mustache variable tag is a GRMustacheVariableHelper,
 * GRMustache invokes the `renderVariable:` method of the helper, and inserts
 * the raw return value in the template rendering.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/helpers.md
 *
 * @since v5.1
 */
@protocol GRMustacheVariableHelper<NSObject>
@required

////////////////////////////////////////////////////////////////////////////////
/// @name Rendering Variable tags
////////////////////////////////////////////////////////////////////////////////

/**
 * Returns the rendering of a Mustache variable.
 *
 * @param variable   The variable to render
 *
 * @return The rendering of the variable
 *
 * @since v5.1
 */
- (NSString *)renderVariable:(GRMustacheVariable *)variable;
@end


// =============================================================================
#pragma mark - GRMustacheVariableHelper

/**
 * The GRMustacheVariableHelper class helps building mustache helpers without
 * writing a custom class that conforms to the GRMustacheVariableHelper
 * protocol.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/helpers.md
 *
 * @see GRMustacheVariableHelper protocol
 *
 * @since v5.1
 */
@interface GRMustacheVariableHelper: NSObject<GRMustacheVariableHelper>

////////////////////////////////////////////////////////////////////////////////
/// @name Creating Helpers
////////////////////////////////////////////////////////////////////////////////

/**
 * Returns a GRMustacheVariableHelper object that executes the provided block
 * when rendering a variable tag.
 *
 * @param block   The block that renders a variable.
 *
 * @return a GRMustacheVariableHelper object.
 *
 * @since v5.1
 */
+ (id)helperWithBlock:(NSString *(^)(GRMustacheVariable* variable))block;

@end


// =============================================================================
#pragma mark - GRMustacheDynamicPartial

/**
 * The GRMustacheDynamicPartial is a specific kind of GRMustacheVariableHelper
 * that, given a partial template name, renders this template.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/helpers.md
 *
 * @see GRMustacheVariableHelper protocol
 *
 * @since v5.1
 */
@interface GRMustacheDynamicPartial: NSObject<GRMustacheVariableHelper> {
    NSString *_name;
}

////////////////////////////////////////////////////////////////////////////////
/// @name Creating Dynamic Partials
////////////////////////////////////////////////////////////////////////////////

/**
 * Returns a GRMustacheDynamicPartial that renders a partial template named
 * _name_.
 *
 * @param name  A template name
 *
 * @return a GRMustacheDynamicPartial
 *
 * @since v5.1
 */
+ (id)dynamicPartialWithName:(NSString *)name;

@end
