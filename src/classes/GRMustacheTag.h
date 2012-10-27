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

@class GRMustacheTemplateRepository;

/**
 * TODO
 */
typedef enum {
    /**
     * Type for variable tags such as {{ name }}
     */
    GRMustacheTagTypeVariable = 1 << 1 AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER,
    
    /**
     * Type for section tags such as {{# name }}...{{/}}
     */
    GRMustacheTagTypeSection = 1 << 2 AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER,
    
    /**
     * Type for overridable section tags such as {{$ name }}...{{/}}
     */
    GRMustacheTagTypeOverridableSection = 1 << 3 AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER,
    
    /**
     * Type for inverted section tags such as {{^ name }}...{{/}}
     */
    GRMustacheTagTypeInvertedSection = 1 << 4 AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER,
} GRMustacheTagType AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;

/**
 * TODO
 */
@interface GRMustacheTag: NSObject {
    id _expression;
    GRMustacheTemplateRepository *_templateRepository;
}

/**
 * TODO
 */
@property (nonatomic, readonly) GRMustacheTagType type AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;

/**
 * TODO
 */
@property (nonatomic, readonly) GRMustacheTemplateRepository *templateRepository AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;

/**
 * The literal inner content of the tag, with unprocessed Mustache `{{tags}}`.
 * Nil for variable tags.
 */
@property (nonatomic, readonly) NSString *innerTemplateString AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;

/**
 * TODO
 */
- (NSString *)renderWithRuntime:(GRMustacheRuntime *)runtime HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;

@end
