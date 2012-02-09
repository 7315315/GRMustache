[up](../../../../GRMustache), [next](runtime.md)

Template loaders
================

GRMustache provides [convenient methods](templates.md) for loading UTF8-encoded templates and partials from the file system.

However, we may have more needs: your templates and partials hierarchy may not be stored in the file system. If they are, they may not be UTF8-encoded.

This is where the GRMustacheTemplateLoader class comes in. GRMustacheTemplateLoader objects are generally initialized with a template source, a location where to load templates from. Their role is then to provide template strings whenever a template or a partial is needed.

Loading templates from the file system
--------------------------------------

GRMustacheTemplateLoader ships with the following class methods:

    // Loads templates and partials from a directory, with "mustache" extension, encoded in UTF8 (from MacOS 10.6 and iOS 4.0)
    + (id)templateLoaderWithBaseURL:(NSURL *)url;

    // Loads templates and partials from a directory, with provided extension, encoded in UTF8 (from MacOS 10.6 and iOS 4.0)
    + (id)templateLoaderWithBaseURL:(NSURL *)url
                          extension:(NSString *)ext;

    // Loads templates and partials from a directory, with provided extension, encoded in provided encoding (from MacOS 10.6 and iOS 4.0)
    + (id)templateLoaderWithBaseURL:(NSURL *)url
                          extension:(NSString *)ext
                           encoding:(NSStringEncoding)encoding;

    // Loads templates and partials from a directory, with "mustache" extension, encoded in UTF8
    + (id)templateLoaderWithDirectory:(NSString *)path;

    // Loads templates and partials from a directory, with provided extension, encoded in UTF8
    + (id)templateLoaderWithDirectory:(NSString *)path
                            extension:(NSString *)ext;

    // Loads templates and partials from a directory, with provided extension, encoded in provided encoding
    + (id)templateLoaderWithDirectory:(NSString *)path
                            extension:(NSString *)ext
                             encoding:(NSStringEncoding)encoding;

    // Loads templates and partials from a bundle, with "mustache" extension, encoded in UTF8
    + (id)templateLoaderWithBundle:(NSBundle *)bundle;

    // Loads templates and partials from a bundle, with provided extension, encoded in UTF8
    + (id)templateLoaderWithBundle:(NSBundle *)bundle
                         extension:(NSString *)ext;

    // Loads templates and partials from a bundle, with provided extension, encoded in provided encoding
    + (id)templateLoaderWithBundle:(NSBundle *)bundle
                         extension:(NSString *)ext
                          encoding:(NSStringEncoding)encoding;

For instance:

    GRMustacheTemplateLoader *loader = [GRMustacheTemplate templateLoaderWithBaseURL:...];

You may now load a template from its location:

    GRMustacheTemplate *template = [loader parseTemplateNamed:@"document" error:NULL];
    
You may also have the loader parse a template string. Only partials would then be loaded from the loader's location:

    GRMustacheTemplate *template = [loader parseString:@"..." error:NULL];
    
The rendering is done as usual:

    NSString *rendering = [template renderObject:...];

Other sources for templates
---------------------------

GRMustache allows you to subclass the GRMustacheTemplateLoader in order to load templates from any location.

We provide below the implementation of a template loader which loads partials from a dictionary containing template strings.

The header file:

    #import "GRMustache.h"

    @interface DictionaryTemplateLoader : GRMustacheTemplateLoader
    + (id)loaderWithDictionary:(NSDictionary *)templatesByName;
    @end

In our implementation file, import the `GRMustacheTemplateLoader_protected.h` header, dedicated to GRMustacheTemplateLoader subclasses:

    #import "GRMustacheTemplateLoader_protected.h"
    
    @interface DictionaryTemplateLoader()
    @property (nonatomic, retain) NSDictionary *templatesByName;
    @end
    
    @implementation DictionaryTemplateLoader
    @synthetise templatesByName;

    + (id)loaderWithDictionary:(NSDictionary *)templatesByName {
        // initWithExtension:encoding: is the designated initializer.
        // provide it with some values, even if we won't use them.
        DictionaryTemplateLoader *loader = [[[self alloc] initWithExtension:nil encoding:NSUTF8StringEncoding] autorelease];
        loader.templatesByName = templatesByName;
        return loader;
    }

    - (void)dealloc {
        self.templatesByName = nil;
        [super dealloc];
    }

Now let's implement the `templateIdForTemplateNamed:relativeToTemplateId:` method.

Provided with a partial name that comes from a `{{>name}}` mustache tag, it should return an object which uniquely identifies a template. In our case, we ignore the second argument that would come in handy when implementing a partial hierarchy. However, the template name looks like a perfect way to identify the partials:

    - (id)templateIdForTemplateNamed:(NSString *)name relativeToTemplateId:(id)baseTemplateId {
        return name;
    }

And finally, we have to provide template strings:

    - (NSString *)templateStringForTemplateId:(id)templateId error:(NSError **)outError {
        return [self.templatesByName objectForKey:templateId];
    }

    @end

Now we may instanciate one:
    
    NSDictionary *templates = [NSDictionary dictionaryWithObject:@"It works!" forKey:@"partial"];
    DictionaryTemplateLoader *loader = [DictionaryTemplateLoader loaderWithDictionary:templates];

Then load templates from it:

    GRMustacheTemplate *template1 = [loader parseString:@"{{>partial}}" error:NULL];
    GRMustacheTemplate *template2 = [loader parseTemplateNamed:@"partial" error:NULL];

And finally render:

    [template1 render];     // "It works!"
    [template2 render];     // "It works!"


Flavors
-------

Remember GRMustache supports two flavors of the Mustache language: check [guides/flavors.md](flavors.md)

[up](../../../../GRMustache), [next](runtime.md)
