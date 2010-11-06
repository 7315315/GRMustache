// The MIT License
// 
// Copyright (c) 2010 Gwendal Roué
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

#import "GRMustacheSpecTest.h"
#import "YAML.h"
#import "GRMustacheTemplateLoader_protected.h"


@interface GRMustacheSpecTemplateLoader : GRMustacheTemplateLoader {
	NSDictionary *partialsByName;
}
+ (id)loaderWithDictionary:(NSDictionary *)partialsByName;
- (id)initWithDictionary:(NSDictionary *)partialsByName;
@end

@implementation GRMustacheSpecTemplateLoader

+ (id)loaderWithDictionary:(NSDictionary *)partialsByName {
	return [[[self alloc] initWithDictionary:partialsByName] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)thePartialsByName {
	if (self == [self initWithExtension:nil]) {
		partialsByName = [thePartialsByName retain];
	}
	return self;
}

- (void)dealloc {
	[partialsByName release];
	[super dealloc];
}

- (id)templateIdForTemplateNamed:(NSString *)name relativeToTemplateId:(id)baseTemplateId {
	return name;
}

- (NSString *)templateStringWithTemplateId:(id)templateId error:(NSError **)outError {
	return [partialsByName objectForKey:templateId];
}

@end



@interface GRMustacheSpecTest()
- (void)testSuiteAtURL:(NSURL *)suiteURL;
- (void)testSuiteTest:(NSDictionary *)suiteTest inSuiteNamed:(NSString *)suiteName;
@end

@implementation GRMustacheSpecTest

- (void)testMustacheSpecSuite {
	NSArray *suiteURLs = [[self testBundle] URLsForResourcesWithExtension:@"yml" subdirectory:@"specs"];
	for (NSURL *suiteURL in suiteURLs) {
		[self testSuiteAtURL:suiteURL];
	}
}

- (void)testSuiteAtURL:(NSURL *)suiteURL {
	NSString *suiteName = [[suiteURL lastPathComponent] stringByDeletingPathExtension];
	
	// TODO: find a way to test lambdas
	if ([suiteName isEqualToString:@"lambdas"]) {
		return;
	}
	
	NSString *yamlString = [NSString stringWithContentsOfURL:suiteURL encoding:NSUTF8StringEncoding error:nil];
	id suite = yaml_parse(yamlString);
	STAssertNotNil(suite, nil);
	STAssertTrue([suite isKindOfClass:[NSDictionary class]], nil);
	NSArray *suiteTests = [(NSDictionary *)suite objectForKey:@"tests"];
	STAssertNotNil(suiteTests, nil);
	for (NSDictionary *suiteTest in suiteTests) {
		[self testSuiteTest:suiteTest inSuiteNamed:suiteName];
	}
}

- (void)testSuiteTest:(NSDictionary *)suiteTest inSuiteNamed:(NSString *)suiteName {
	NSString *testName = [suiteTest objectForKey:@"name"];
	NSString *testDescription = [suiteTest objectForKey:@"desc"];
	id context = [suiteTest objectForKey:@"data"];
	NSString *templateString = [suiteTest objectForKey:@"template"];
	NSString *expected = [suiteTest objectForKey:@"expected"];
	NSDictionary *partials = [suiteTest objectForKey:@"partials"];
	if (partials == nil) {
		partials = [NSDictionary dictionary];
	}
	GRMustacheTemplateLoader *loader = [GRMustacheSpecTemplateLoader loaderWithDictionary:partials];

	NSError *error;
	GRMustacheTemplate *template = [loader parseString:templateString error:&error];
	STAssertNotNil(template, [NSString stringWithFormat:@"%@/%@(%@): %@", suiteName, testName, testDescription, [[error userInfo] objectForKey:NSLocalizedDescriptionKey]]);
	if (template) {
		NSString *result = [template renderObject:context];
		STAssertEqualObjects(result, expected, [NSString stringWithFormat:@"%@/%@(%@)", suiteName, testName, testDescription]);
	}
}

@end
