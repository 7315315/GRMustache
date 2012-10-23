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

#import "GRMustacheSectionTagHelper_private.h"
#import "GRMustacheSectionElement_private.h"
#import "GRMustacheRuntime_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheTemplateRepository_private.h"

@interface GRMustacheSectionTagRenderingContext()
- (id)initWithSectionElement:(GRMustacheSectionElement *)sectionElement runtime:(GRMustacheRuntime *)runtime;
@end

@implementation GRMustacheSectionTagRenderingContext

+ (id)contextWithSectionElement:(GRMustacheSectionElement *)sectionElement runtime:(GRMustacheRuntime *)runtime
{
    return [[[GRMustacheSectionTagRenderingContext alloc] initWithSectionElement:sectionElement runtime:runtime] autorelease];
}

- (void)dealloc
{
    [_sectionElement release];
    [_runtime release];
    [super dealloc];
}

- (id)initWithSectionElement:(GRMustacheSectionElement *)sectionElement runtime:(GRMustacheRuntime *)runtime
{
    self = [super init];
    if (self) {
        _sectionElement = [sectionElement retain];
        _runtime = [runtime retain];
    }
    return self;
}

- (NSString *)render
{
    return [self renderObject:nil withFilters:nil];
}

- (NSString *)renderObject:(id)object
{
    return [self renderObject:object withFilters:nil];
}

- (NSString *)renderObject:(id)object withFilters:(id)filters
{
    NSMutableString *buffer = [NSMutableString string];
    GRMustacheRuntime *runtime = [_runtime runtimeByAddingContextObject:object];
    runtime = [runtime runtimeByAddingFilterObject:filters];
    [_sectionElement renderInnerElementsInBuffer:buffer withRuntime:runtime];
    return buffer;
}

- (NSString *)renderString:(NSString *)string error:(NSError **)outError
{
    return [self renderObject:nil withFilters:nil fromString:string error:outError];
}

- (NSString *)renderObject:(id)object fromString:(NSString *)templateString error:(NSError **)outError
{
    return [self renderObject:object withFilters:nil fromString:templateString error:outError];
}

- (NSString *)renderObject:(id)object withFilters:(id)filters fromString:(NSString *)templateString error:(NSError **)outError
{
    GRMustacheTemplate *template = [_sectionElement.templateRepository templateFromString:templateString error:outError];
    if (!template) {
        return nil;
    }
    
    NSMutableString *buffer = [NSMutableString string];
    GRMustacheRuntime *runtime = [_runtime runtimeByAddingContextObject:object];
    runtime = [runtime runtimeByAddingFilterObject:filters];
    [template renderInBuffer:buffer withRuntime:runtime];
    return buffer;
}

- (NSString *)innerTemplateString
{
    return _sectionElement.innerTemplateString;
}

@end
