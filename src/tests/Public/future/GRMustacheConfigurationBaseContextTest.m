// The MIT License
//
// Copyright (c) 2013 Gwendal Roué
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

#warning missing GRMUSTACHE_VERSION_MAX_ALLOWED
#import "GRMustachePublicAPITest.h"

@interface GRMustacheConfigurationBaseContextTest : GRMustachePublicAPITest
@end

static BOOL defaultConfigurationHasBeenTouched = NO;

@implementation GRMustacheConfigurationBaseContextTest

- (void)tearDown
{
    [super tearDown];
    
    // Restore default configuration
    [GRMustacheConfiguration defaultConfiguration].baseContext = [GRMustacheConfiguration configuration].baseContext;
    
    // Help test1DefaultConfigurationHasStandardLibraryInBaseContext test the *real* default
    // configuration.
    defaultConfigurationHasBeenTouched = YES;
}

// The goal is to have this test run first.
// It looks that alphabetical order is applied: hence the digit 1 in the method name.
- (void)test1DefaultConfigurationHasStandardLibraryInBaseContext
{
    STAssertFalse(defaultConfigurationHasBeenTouched, @"this test should run first.");
    STAssertNotNil([GRMustacheConfiguration defaultConfiguration], @"");
    // TODO
}

- (void)testFactoryConfigurationHasStandardLibraryInBaseContextRegardlessOfDefaultConfiguration
{
    [GRMustacheConfiguration defaultConfiguration].baseContext = [GRMustacheContext contextWithObject:[NSDictionary dictionaryWithObject:@"bar" forKey:@"foo"]];
    GRMustacheConfiguration *configuration = [GRMustacheConfiguration configuration];
    STAssertNotNil(configuration, @"");
    // TODO
}

- (void)testDefaultConfigurationMustacheBaseContext
{
    [GRMustacheConfiguration defaultConfiguration].baseContext = [GRMustacheContext contextWithObject:[NSDictionary dictionaryWithObject:@"bar" forKey:@"foo"]];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{foo}}" error:NULL];
    NSString *rendering = [template renderObject:nil error:NULL];
    STAssertEqualObjects(rendering, @"bar", @"");
}

- (void)testTemplateBaseContextOverridesDefaultConfigurationBaseContext
{
    [GRMustacheConfiguration defaultConfiguration].baseContext = [GRMustacheContext contextWithObject:[NSDictionary dictionaryWithObject:@"bar" forKey:@"foo"]];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{foo}}" error:NULL];
    template.baseContext = [GRMustacheContext contextWithObject:[NSDictionary dictionaryWithObject:@"templatebar" forKey:@"foo"]];
    NSString *rendering = [template renderObject:nil error:NULL];
    STAssertEqualObjects(rendering, @"templatebar", @"");
}

- (void)testDefaultRepositoryConfigurationHasDefaultConfigurationBaseContext
{
    [GRMustacheConfiguration defaultConfiguration].baseContext = [GRMustacheContext contextWithObject:[NSDictionary dictionaryWithObject:@"bar" forKey:@"foo"]];
    GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
    GRMustacheTemplate *template = [repo templateFromString:@"{{foo}}" error:NULL];
    NSString *rendering = [template renderObject:nil error:NULL];
    STAssertEqualObjects(rendering, @"bar", @"");
}

- (void)testRepositoryConfigurationBaseContextApply
{
    {
        // Setting the whole configuration
        GRMustacheConfiguration *configuration = [GRMustacheConfiguration configuration];
        configuration.baseContext = [GRMustacheContext contextWithObject:[NSDictionary dictionaryWithObject:@"bar" forKey:@"foo"]];
        
        GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
        repo.configuration = configuration;
        
        GRMustacheTemplate *template = [repo templateFromString:@"{{foo}}" error:NULL];
        NSString *rendering = [template renderObject:nil error:NULL];
        STAssertEqualObjects(rendering, @"bar", @"");
    }
    {
        // Setting configuration property
        GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
        repo.configuration.baseContext = [GRMustacheContext contextWithObject:[NSDictionary dictionaryWithObject:@"bar" forKey:@"foo"]];
        
        GRMustacheTemplate *template = [repo templateFromString:@"{{foo}}" error:NULL];
        NSString *rendering = [template renderObject:nil error:NULL];
        STAssertEqualObjects(rendering, @"bar", @"");
    }
}

- (void)testRepositoryConfigurationBaseContextOverridesDefaultConfigurationBaseContext
{
    {
        // Setting the whole configuration
        [GRMustacheConfiguration defaultConfiguration].baseContext = [GRMustacheContext contextWithObject:[NSDictionary dictionaryWithObject:@"bar" forKey:@"foo"]];
        
        GRMustacheConfiguration *configuration = [GRMustacheConfiguration configuration];
        configuration.baseContext = [GRMustacheContext contextWithObject:[NSDictionary dictionaryWithObject:@"repobar" forKey:@"foo"]];
        
        GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
        repo.configuration = configuration;
        
        GRMustacheTemplate *template = [repo templateFromString:@"{{foo}}" error:NULL];
        NSString *rendering = [template renderObject:nil error:NULL];
        STAssertEqualObjects(rendering, @"repobar", @"");
    }
    {
        // Setting configuration property
        [GRMustacheConfiguration defaultConfiguration].baseContext = [GRMustacheContext contextWithObject:[NSDictionary dictionaryWithObject:@"bar" forKey:@"foo"]];
        
        GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
        repo.configuration.baseContext = [GRMustacheContext contextWithObject:[NSDictionary dictionaryWithObject:@"repobar" forKey:@"foo"]];
        
        GRMustacheTemplate *template = [repo templateFromString:@"{{foo}}" error:NULL];
        NSString *rendering = [template renderObject:nil error:NULL];
        STAssertEqualObjects(rendering, @"repobar", @"");
    }
}

- (void)testTemplateBaseContextOverridesRepositoryConfigurationBaseContext
{
    {
        // Setting the whole configuration
        GRMustacheConfiguration *configuration = [GRMustacheConfiguration configuration];
        configuration.baseContext = [GRMustacheContext contextWithObject:[NSDictionary dictionaryWithObject:@"bar" forKey:@"foo"]];
        
        GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
        repo.configuration = configuration;
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{foo}}" error:NULL];
        template.baseContext = [GRMustacheContext contextWithObject:[NSDictionary dictionaryWithObject:@"templatebar" forKey:@"foo"]];
        NSString *rendering = [template renderObject:nil error:NULL];
        STAssertEqualObjects(rendering, @"templatebar", @"");
    }
    {
        // Setting configuration property
        GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
        repo.configuration.baseContext = [GRMustacheContext contextWithObject:[NSDictionary dictionaryWithObject:@"bar" forKey:@"foo"]];
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{foo}}" error:NULL];
        template.baseContext = [GRMustacheContext contextWithObject:[NSDictionary dictionaryWithObject:@"templatebar" forKey:@"foo"]];
        NSString *rendering = [template renderObject:nil error:NULL];
        STAssertEqualObjects(rendering, @"templatebar", @"");
    }
}

- (void)testRepositoryConfigurationCanBeMutatedBeforeAnyTemplateHasBeenCompiled
{
    GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
    STAssertNoThrow([repo.configuration setBaseContext:[GRMustacheContext contextWithObject:[NSDictionary dictionaryWithObject:@"bar" forKey:@"foo"]]], @"");
}

- (void)testDefaultConfigurationCanBeMutatedBeforeAnyTemplateHasBeenCompiled
{
    GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
    [repo templateFromString:@"" error:NULL];
    
    STAssertNoThrow([[GRMustacheConfiguration defaultConfiguration] setBaseContext:[GRMustacheContext contextWithObject:[NSDictionary dictionaryWithObject:@"bar" forKey:@"foo"]]], @"");
}

- (void)testRepositoryConfigurationCanNotBeMutatedAfterATemplateHasBeenCompiled
{
    GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
    [repo templateFromString:@"" error:NULL];
    STAssertThrows([repo.configuration setBaseContext:[GRMustacheContext contextWithObject:[NSDictionary dictionaryWithObject:@"bar" forKey:@"foo"]]], @"");
    STAssertThrows([repo setConfiguration:[GRMustacheConfiguration configuration]], @"");
}

#warning check error when setting ridiculous baseContext

@end
