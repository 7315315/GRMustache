//
//  GRMustacheTemplateLoader.m
//

#import "GRMustache_private.h"
#import "GRMustacheTemplateLoader_private.h"
#import "GRMustacheTemplate_private.h"


NSString* const GRMustacheDefaultExtension = @"mustache";


@interface GRMustacheURLTemplateLoader: GRMustacheTemplateLoader {
	NSURL *url;
}
- (id)initWithURL:(NSURL *)url extension:(NSString *)ext;
@end


@interface GRMustacheBundleTemplateLoader: GRMustacheTemplateLoader {
	NSBundle *bundle;
}
- (id)initWithBundle:(NSBundle *)bundle extension:(NSString *)ext;
@end


@interface GRMustacheTemplateLoader()
- (id)initWithExtension:(NSString *)ext;
- (NSURL *)urlForTemplateNamed:(NSString *)name relativeToTemplate:(GRMustacheTemplate *)template;
@end

@implementation GRMustacheTemplateLoader

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

- (id)initWithExtension:(NSString *)ext {
	if (self = [self init]) {
		if (ext.length == 0) {
			ext = GRMustacheDefaultExtension;
		}
		extension = [ext retain];
		templatesByURL = [[NSMutableDictionary dictionaryWithCapacity:4] retain];
	}
	return self;
}

- (GRMustacheTemplate *)parseTemplateNamed:(NSString *)name relativeToTemplate:(GRMustacheTemplate *)template error:(NSError **)outError {
	NSURL *url = [self urlForTemplateNamed:name relativeToTemplate:template];
	if (url == nil) {
		if (outError != NULL) {
			*outError = [NSError errorWithDomain:GRMustacheErrorDomain
											code:GRMustacheErrorCodePartialNotFound
										userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"No such template: %@", name, nil]
																			 forKey:NSLocalizedDescriptionKey]];
		}
		return nil;
	}
	return [self parseContentsOfURL:url error:outError];
}

- (GRMustacheTemplate *)parseTemplateNamed:(NSString *)name error:(NSError **)outError {
	return [self parseTemplateNamed:name relativeToTemplate:nil error:outError];
}

- (GRMustacheTemplate *)parseContentsOfURL:(NSURL *)url error:(NSError **)outError {
	NSAssert(url, @"Can't build template with nil url");
	GRMustacheTemplate *template = [templatesByURL objectForKey:url];
	if (template == nil) {
		NSString *templateString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:outError];
		if (!templateString) {
			return nil;
		}
		template = [GRMustacheTemplate templateWithString:templateString url:url templateLoader:self];
		
		// store template before parsing, so that we support recursive templates
		[templatesByURL setObject:template forKey:url];
		
		if (![template parseAndReturnError:outError]) {
			// remove template if parsing fails
			[templatesByURL removeObjectForKey:url];
			return nil;
		}
	}
	return template;
}

- (NSURL *)urlForTemplateNamed:(NSString *)name relativeToTemplate:(GRMustacheTemplate *)template {
	NSAssert(NO, @"abstract method");
	return nil;
}

- (void)dealloc {
	[extension release];
	[templatesByURL release];
	[super dealloc];
}

@end


#pragma mark -


@implementation GRMustacheURLTemplateLoader

- (id)initWithURL:(NSURL *)theURL extension:(NSString *)ext {
	if (self = [super initWithExtension:ext]) {
		url = [theURL retain];
	}
	return self;
}

- (NSURL *)urlForTemplateNamed:(NSString *)name relativeToTemplate:(GRMustacheTemplate *)template {
	if (template.url) {
		return [NSURL URLWithString:[name stringByAppendingPathExtension:extension] relativeToURL:template.url];
	}
	return [[url URLByAppendingPathComponent:name] URLByAppendingPathExtension:extension];
}

- (void)dealloc {
	[url release];
	[super dealloc];
}

@end


#pragma mark -


@implementation GRMustacheBundleTemplateLoader

- (id)initWithBundle:(NSBundle *)theBundle extension:(NSString *)ext {
	if (self = [self initWithExtension:ext]) {
		if (theBundle == nil) {
			theBundle = [NSBundle mainBundle];
		}
		bundle = [theBundle retain];
	}
	return self;
}

- (NSURL *)urlForTemplateNamed:(NSString *)name relativeToTemplate:(GRMustacheTemplate *)template {
	return [bundle URLForResource:name withExtension:extension];
}

- (void)dealloc {
	[bundle release];
	[super dealloc];
}

@end


