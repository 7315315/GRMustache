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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_6_0
#import "GRMustachePublicAPITest.h"

@interface GRPositionFilter : NSObject<GRMustacheFilter>
@end

@implementation GRPositionFilter

- (id)transformedValue:(id)object
{
    NSAssert([object isKindOfClass:[NSArray class]], @"Not an NSArray");
    NSArray *array = (NSArray *)object;
    
    return [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheSection *section, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
        
        if (section && !section.isInverted) {
            
            // Custom rendering for non-inverted sections
            
            NSMutableString *buffer = [NSMutableString string];
            [array enumerateObjectsUsingBlock:^(id item, NSUInteger index, BOOL *stop) {
                GRMustacheRuntime *itemRuntime = [runtime runtimeByAddingContextObject:@{ @"position": @(index + 1) }];
                itemRuntime = [itemRuntime runtimeByAddingContextObject:item];
                
                NSString *rendering = [section renderForSection:section inRuntime:itemRuntime templateRepository:templateRepository HTMLEscaped:HTMLEscaped];
                if (rendering) {
                    [buffer appendString:rendering];
                }
            }];
            return buffer;
        } else {
            
            // Genuine Mustache rendering otherwise
            
            id<GRMustacheRendering> original = [GRMustache renderingObjectForObject:array];
            return [original renderForSection:section inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped];
        }
    }];
}

@end


@interface GRPositionFilterTest : GRMustachePublicAPITest

@end

@implementation GRPositionFilterTest

- (void)testGRPositionFilterRendersPositions
{
    // GRPositionFilter should do its job
    id data = @{ @"array": @[@"foo", @"bar"], @"f": [[[GRPositionFilter alloc] init] autorelease] };
    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{#f(array)}}{{position}}:{{.}} {{/}}" error:NULL] renderObject:data];
    STAssertEqualObjects(rendering, @"1:foo 2:bar ", @"");
}

- (void)testGRPositionFilterRendersArrayOfFalseValuesJustAsOriginalArray
{
    // GRPositionFilter should not alter the way an array is rendered
    id data = @{ @"array": @[[NSNull null], @NO] };
    id filters = @{ @"f": [[[GRPositionFilter alloc] init] autorelease] };
    NSString *rendering1 = [[GRMustacheTemplate templateFromString:@"{{#array}}<{{.}}>{{/}}" error:NULL] renderObject:data];
    NSString *rendering2 = [[GRMustacheTemplate templateFromString:@"{{#f(array)}}<{{.}}>{{/}}" error:NULL] renderObject:data];
    STAssertEqualObjects(rendering1, rendering2, @"");
}

- (void)testGRPositionFilterRendersEmptyArrayJustAsOriginalArray
{
    // GRPositionFilter should not alter the way an array is rendered
    id data = @{ @"array": @[] };
    id filters = @{ @"f": [[[GRPositionFilter alloc] init] autorelease] };
    
    {
        NSString *rendering1 = [[GRMustacheTemplate templateFromString:@"{{#array}}<{{.}}>{{/}}" error:NULL] renderObject:data];
        NSString *rendering2 = [[GRMustacheTemplate templateFromString:@"{{#f(array)}}<{{.}}>{{/}}" error:NULL] renderObject:data];
        STAssertEqualObjects(rendering1, rendering2, @"");
    }
    {
        NSString *rendering1 = [[GRMustacheTemplate templateFromString:@"{{^array}}<{{.}}>{{/}}" error:NULL] renderObject:data];
        NSString *rendering2 = [[GRMustacheTemplate templateFromString:@"{{^f(array)}}<{{.}}>{{/}}" error:NULL] renderObject:data];
        STAssertEqualObjects(rendering1, rendering2, @"");
    }
}

@end
