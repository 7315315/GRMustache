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

#import "GRMustache_private.h"
#import "GRMustacheTemplateLoader_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheURLTemplateLoader_private.h"
#import "GRMustacheBundleTemplateLoader_private.h"


NSString* const GRMustacheDefaultExtension = @"mustache";


@interface GRMustacheTemplateLoader()
//- (GRMustacheTemplate *)parseContentsOfURL:(NSURL *)url error:(NSError **)outError;
@end

@implementation GRMustacheTemplateLoader
@synthesize extension;

+ (id)templateLoaderWithURL:(NSURL *)url {
	return [[[GRMustacheURLTemplateLoader alloc] initWithURL:url extension:nil] autorelease];
}

+ (id)templateLoaderWithURL:(NSURL *)url extension:(NSString *)ext {
	return [[[GRMustacheURLTemplateLoader alloc] initWithURL:url extension:ext] autorelease];
}

+ (id)templateLoaderWithBundle:(NSBundle *)bundle {
	return [[[GRMustacheBundleTemplateLoader alloc] initWithBundle:bundle extension:nil] autorelease];
}

+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext {
	return [[[GRMustacheBundleTemplateLoader alloc] initWithBundle:bundle extension:ext] autorelease];
}

- (id)initWithExtension:(NSString *)theExtension {
	if (self = [self init]) {
		if (theExtension.length == 0) {
			theExtension = GRMustacheDefaultExtension;
		}
		extension = [theExtension retain];
		templatesById = [[NSMutableDictionary dictionaryWithCapacity:4] retain];
	}
	return self;
}

- (GRMustacheTemplate *)parseTemplateNamed:(NSString *)name relativeToTemplate:(GRMustacheTemplate *)baseTemplate error:(NSError **)outError {
	id templateId = [self templateIdForTemplateNamed:name relativeToTemplateId:baseTemplate.templateId];
	if (templateId == nil) {
		if (outError != NULL) {
			*outError = [NSError errorWithDomain:GRMustacheErrorDomain
											code:GRMustacheErrorCodeTemplateNotFound
										userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"No such template: %@", name, nil]
																			 forKey:NSLocalizedDescriptionKey]];
		}
		return nil;
	}
//	return [self parseContentsOfURL:url error:outError];
	
	GRMustacheTemplate *template = [templatesById objectForKey:templateId];
	
	if (template == nil) {
		NSString *templateString = [self templateStringForTemplateId:templateId error:outError];
		if (!templateString) {
			return nil;
		}
		
		template = [GRMustacheTemplate templateWithString:templateString templateId:templateId templateLoader:self];
		
		// store template before parsing, so that we support recursive templates
		[self setTemplate:template forTemplateId:templateId];
		
		if (![template parseAndReturnError:outError]) {
			// remove template if parsing fails
			[self setTemplate:nil forTemplateId:templateId];
			return nil;
		}
	}
	
	return template;
}

- (GRMustacheTemplate *)parseTemplateNamed:(NSString *)name error:(NSError **)outError {
	return [self parseTemplateNamed:name relativeToTemplate:nil error:outError];
}

- (GRMustacheTemplate *)parseString:(NSString *)templateString error:(NSError **)outError {
	GRMustacheTemplate *template = [GRMustacheTemplate templateWithString:templateString templateId:nil templateLoader:self];
	if (![template parseAndReturnError:outError]) {
		return nil;
	}
	return template;
}

- (GRMustacheTemplate *)parseContentsOfURL:(NSURL *)url error:(NSError **)outError {
	NSString *templateString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:outError];
	if (!templateString) {
		return nil;
	}
	return [self parseString:templateString error:outError];
}

- (void)setTemplate:(GRMustacheTemplate *)template forTemplateId:(id)templateId {
	if (template) {
		[templatesById setObject:template forKey:templateId];
	} else {
		[templatesById removeObjectForKey:templateId];
	}
}

- (id)templateIdForTemplateNamed:(NSString *)name relativeToTemplateId:(id)baseTemplateId {
	NSAssert(NO, @"abstract method");
	return nil;
}

- (NSString *)templateStringForTemplateId:(id)templateId error:(NSError **)outError {
	NSAssert(NO, @"abstract method");
	return nil;
}

- (void)dealloc {
	[extension release];
	[templatesById release];
	[super dealloc];
}

@end



