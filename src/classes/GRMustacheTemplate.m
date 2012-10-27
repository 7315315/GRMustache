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

#import "GRMustacheTemplate_private.h"
#import "GRMustacheRuntime_private.h"
#import "GRMustacheTemplateRepository_private.h"
#import "GRMustacheSectionTag_private.h"
#import "GRMustacheRendering.h"

@interface GRMustacheTemplate()<GRMustacheRendering>
@end

@implementation GRMustacheTemplate
@synthesize components=_components;
@synthesize delegate=_delegate;
@synthesize templateRepository=_templateRepository;

+ (id)templateFromString:(NSString *)templateString error:(NSError **)error
{
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBundle:[NSBundle mainBundle]];
    return [templateRepository templateFromString:templateString error:error];
}

+ (id)templateFromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)error
{
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBundle:bundle];
    return [templateRepository templateNamed:name error:error];
}

+ (id)templateFromContentsOfFile:(NSString *)path error:(NSError **)error
{
    NSString *directoryPath = [path stringByDeletingLastPathComponent];
    NSString *templateExtension = [path pathExtension];
    NSString *templateName = [[path lastPathComponent] stringByDeletingPathExtension];
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath templateExtension:templateExtension];
    return [templateRepository templateNamed:templateName error:error];
}

+ (id)templateFromContentsOfURL:(NSURL *)URL error:(NSError **)error
{
    NSURL *baseURL = [URL URLByDeletingLastPathComponent];
    NSString *templateExtension = [URL pathExtension];
    NSString *templateName = [[URL lastPathComponent] stringByDeletingPathExtension];
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:baseURL templateExtension:templateExtension];
    return [templateRepository templateNamed:templateName error:error];
}

- (void)dealloc
{
    [_components release];
    [super dealloc];
}

- (NSString *)renderAndReturnError:(NSError **)error
{
    return [self renderObject:nil error:error];
}

- (NSString *)renderObject:(id)object error:(NSError **)error
{
    GRMustacheRuntime *runtime = [GRMustacheRuntime runtime];
    runtime = [runtime runtimeByAddingContextObject:object];
    
    NSMutableString *buffer = [NSMutableString string];
    if (![self renderInBuffer:buffer withRuntime:runtime error:error]) {
        return nil;
    }
    return buffer;
}

- (NSString *)renderObjectsFromArray:(NSArray *)objects error:(NSError **)error
{
    GRMustacheRuntime *runtime = [GRMustacheRuntime runtime];
    for (id object in objects) {
        runtime = [runtime runtimeByAddingContextObject:object];
    }
    
    NSMutableString *buffer = [NSMutableString string];
    if (![self renderInBuffer:buffer withRuntime:runtime error:error]) {
        return nil;
    }
    return buffer;
}

- (NSString *)renderWithRuntime:(GRMustacheRuntime *)runtime HTMLEscaped:(BOOL *)HTMLEscaped error:(NSError **)error
{
    NSMutableString *buffer = [NSMutableString string];
    if (![self renderInBuffer:buffer withRuntime:runtime error:error]) {
        return nil;
    }
    *HTMLEscaped = YES;
    return buffer;
}


#pragma mark - <GRMustacheTemplateComponent>

- (BOOL)renderInBuffer:(NSMutableString *)buffer withRuntime:(GRMustacheRuntime *)runtime error:(NSError **)error
{
    runtime = [runtime runtimeWithDelegatingTemplate:self];
    runtime = [runtime runtimeByAddingTemplateDelegate:self.delegate];
    
    for (id<GRMustacheTemplateComponent> component in _components) {
        // component may be overriden by a GRMustacheTemplateOverride: resolve it.
        component = [runtime resolveTemplateComponent:component];
        
        // render
        if (![component renderInBuffer:buffer withRuntime:runtime error:error]) {
            return NO;
        }
    }
    
    return YES;
}

- (id<GRMustacheTemplateComponent>)resolveTemplateComponent:(id<GRMustacheTemplateComponent>)component
{
    // look for the last overriding component in inner components.
    //
    // This allows a partial do define an overriding section:
    //
    //    {
    //        data: { },
    //        expected: "partial1",
    //        name: "Partials in overridable partials can override overridable sections",
    //        template: "{{<partial2}}{{>partial1}}{{/partial2}}"
    //        partials: {
    //            partial1: "{{$overridable}}partial1{{/overridable}}";
    //            partial2: "{{$overridable}}ignored{{/overridable}}";
    //        },
    //    }
    for (id<GRMustacheTemplateComponent> innerComponent in _components) {
        component = [innerComponent resolveTemplateComponent:component];
    }
    return component;
}


#pragma mark - <GRMustacheRendering>

// Allows template to render as "dynamic partials"
- (NSString *)renderForTag:(GRMustacheTag *)tag withRuntime:(GRMustacheRuntime *)runtime HTMLEscaped:(BOOL *)HTMLEscaped error:(NSError **)error
{
    return [self renderWithRuntime:runtime HTMLEscaped:HTMLEscaped error:error];
}

@end
