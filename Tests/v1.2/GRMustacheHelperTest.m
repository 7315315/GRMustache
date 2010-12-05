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

#import "GRMustacheHelperTest.h"
#import "GRMustacheContext.h"


@interface GRMustacheHelperTestContext: NSObject
@end

@implementation GRMustacheHelperTestContext

- (NSString*)boldSection:(GRMustacheSection *)section withObject:(id)object {
	return [NSString stringWithFormat:@"<b>%@</b>", [section renderObject:object]];
}

+ (NSString*)linkSection:(GRMustacheSection *)section withObject:(id)object {
	return [NSString stringWithFormat:
			@"<a href=\"/people/%@\">%@</a>",
			[object valueForKey:@"id"],
			[section renderObject:object]];
}

@end

@implementation GRMustacheHelperTest

- (void)testHelperInstanceMethod {
	NSString *templateString = @"{{#bold}}text{{/bold}}";
	NSDictionary *context = [[[GRMustacheHelperTestContext alloc] init] autorelease];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"<b>text</b>", nil);
}

- (void)testHelperClassMethod {
	NSString *templateString = @"<ul>{{#people}}<li>{{#link}}{{name}}{{/link}}</li>{{/people}}</ul>";
	NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSArray arrayWithObjects:
						   [NSDictionary dictionaryWithObjectsAndKeys:@"Alan", @"name", @"1", @"id", nil],
						   [NSDictionary dictionaryWithObjectsAndKeys:@"Roger", @"name", @"2", @"id", nil],
						   nil], @"people",
						  nil
						  ];
	GRMustacheContext *context = [GRMustacheContext contextWithObjects:[GRMustacheHelperTestContext class], data, nil];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"<ul><li><a href=\"/people/1\">Alan</a></li><li><a href=\"/people/2\">Roger</a></li></ul>", nil);
}

@end
