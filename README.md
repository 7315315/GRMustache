GRMustache
==========

GRMustache is an Objective-C implementation of the [Mustache](http://mustache.github.com/) logic-less template engine, for MacOS 10.6, iPhoneOS 3.0 and iOS 4.0

It supports the following Mustache features:

- variables
- sections (boolean, enumerable, inverted, lambda)
- partials (and recursive partials)
- delimiter changes
- comments

It supports extensions to the [regular Mustache syntax](http://mustache.github.com/mustache.5.html):

- dot variable tag: `{{.}}` (introduced by [mustache.js](http://github.com/janl/mustache.js))
- extended paths, as in `{{../name}}` (introduced by [Handlebars.js](https://github.com/wycats/handlebars.js))

### Embedding in your XCode project

GRMustache is a standalone library made of the Objective-C files contained in the `Classes` folder. Add them to your XCode project, and link against Foundation.framework.

Import `GRMustache.h` in order to access all GRMustache features.

Header files whose names contain `private` declare private APIs which are subject to change, without notice, over releases.

### Versioning

GRMustache versioning policy complies to the one defined by the [Apache APR](http://apr.apache.org/versioning.html).

Check the repository's tags, the `GRMustacheVersion.h` header, and `RELEASE_NOTES.md`.

### Testing

Open the MacOSGRMustache.xcodeproj project, and build the MacOSGRMustache target. Tests pass if the build succeeds. You may also run the `make` command from the Terminal.

GRMustache is tested against the [core](https://github.com/groue/Mustache-Spec/tree/master/specs/core/), [file_system](https://github.com/groue/Mustache-Spec/tree/master/specs/file_system/), [dot_key](https://github.com/groue/Mustache-Spec/tree/master/specs/dot_key/), and [extended_path](https://github.com/groue/Mustache-Spec/tree/master/specs/extended_path/) modules of the [Mustache-Spec](https://github.com/groue/Mustache-Spec) project. More tests come from the [Ruby](http://github.com/defunkt/mustache) implementation.

Simple example
--------------

	#import "GRMustache.h"
	
	NSDictionary *object = [NSDictionary dictionaryWithObject:@"Mom" forKey:@"name"];
	[GRMustacheTemplate renderObject:object fromString:@"Hi {{name}}!" error:nil];
	// returns @"Hi Mom!"

Rendering methods
-----------------

The main rendering methods provided by the GRMustacheTemplate class are:

	// Renders the provided templateString.
	+ (NSString *)renderObject:(id)object
	                fromString:(NSString *)templateString
	                     error:(NSError **)outError;
	
	// Renders the template loaded from a url. (from MacOS 10.6 and iOS 4.0)
	+ (NSString *)renderObject:(id)object
	         fromContentsOfURL:(NSURL *)url
	                     error:(NSError **)outError;
	
	// Renders the template loaded from a path.
	+ (NSString *)renderObject:(id)object
	        fromContentsOfFile:(NSString *)path
	                     error:(NSError **)outError;
	
	// Renders the template loaded from a bundle resource of extension "mustache".
	+ (NSString *)renderObject:(id)object
	              fromResource:(NSString *)name
	                    bundle:(NSBundle *)bundle
	                     error:(NSError **)outError;
	
	// Renders the template loaded from a bundle resource of provided extension.
	+ (NSString *)renderObject:(id)object
	              fromResource:(NSString *)name
	             withExtension:(NSString *)ext
	                    bundle:(NSBundle *)bundle
	                     error:(NSError **)outError;

All methods may return errors, described in the "Errors" section below.

Compiling templates
-------------------

If you are planning to render the same template multiple times, it is more efficient to parse it once, with the compiling methods of the GRMustacheTemplate class:

	// Parses the templateString.
	+ (id)parseString:(NSString *)templateString
	            error:(NSError **)outError;
	
	// Loads and parses the template from url. (from MacOS 10.6 and iOS 4.0)
	+ (id)parseContentsOfURL:(NSURL *)url
	                   error:(NSError **)outError;
	
	// Loads and parses the template from path.
	+ (id)parseContentsOfFile:(NSString *)path
	                    error:(NSError **)outError;
	
	// Loads and parses the template from a bundle resource of extension "mustache".
	+ (id)parseResource:(NSString *)name
	             bundle:(NSBundle *)bundle
	              error:(NSError **)outError;
	
	// Loads and parses the template from a bundle resource of provided extension.
	+ (id)parseResource:(NSString *)name
	      withExtension:(NSString *)ext
	             bundle:(NSBundle *)bundle
	              error:(NSError **)outError;

Those methods return GRMustacheTemplate instances, which render objects with the following method:

	- (NSString *)renderObject:(id)object;

For instance:

	// Compile template
	GRMustacheTemplate *template = [GRMustacheTemplate parseString:@"Hi {{name}}!" error:nil];
	// @"Hi Mom!"
	[template renderObject:[NSDictionary dictionaryWithObject:@"Mom" forKey:@"name"]];
	// @"Hi Dad!"
	[template renderObject:[NSDictionary dictionaryWithObject:@"Dad" forKey:@"name"]];
	// @"Hi !"
	[template renderObject:nil];
	// @"Hi !", shortcut to renderObject:nil
	[template render];

Context objects
---------------

You will provide a rendering method with a context object.

Mustache tag names are looked in the context object, through the standard Key-Value Coding method `valueForKey:`.

The most obvious objects which support KVC are dictionaries. You may also provide with any other object:

	@interface Person: NSObject
	+ (id)personWithName:(NSString *)name;
	- (NSString *)name;
	@end

	// returns @"Hi Mom!"
	[GRMustacheTemplate renderObject:[Person personWithName:@"Mom"]
	                      fromString:@"Hi {{name}}!"
	                           error:nil];

GRMustache catches NSUndefinedKeyException:

	// doesn't throw, and returns @"Hi !"
	[GRMustacheTemplate renderObject:[Person personWithName:@"Mom"]
	                      fromString:@"Hi {{blame}}!"
	                           error:nil];

Tag types
---------

We'll now cover all mustache tag types, and how they are rendered.

But let's give some definitions first:

- GRMustache considers *enumerable* all objects conforming to the NSFastEnumeration protocol, but NSDictionary. The most obvious enumerable is NSArray.

- GRMustache considers *false* KVC key misses, and the following values: `nil`, `[NSNull null]`, `[NSNumber numberWithBool:NO]`, `kCFBooleanFalse`, and the empty string `@""`.

### Comments `{{!...}}`

Comments tags are not rendered.

### Variable tags `{{name}}`

Such a tag is rendered according to the value for key `name` in the context.

If the value is *false*, the tag is not rendered.

Otherwise, it is rendered with the regular string description of the value, HTML escaped.

### Unescaped variable tags `{{{name}}}` and `{{&name}}`

Such a tag is rendered according to the value for key `name` in the context.

If the value is *false*, the tag is not rendered.

Otherwise, it is rendered with the regular string description of the value, without HTML escaping.

### Sections `{{#name}}...{{/name}}`

Sections are rendered differently, depending on the value for key `name` in the context:

#### False sections

If the value is *false*, the section is not rendered.

#### Enumerable sections

If the value is *enumerable*, the text between the `{{#name}}` and `{{/name}}` tags is rendered once for each item in the enumerable.

Each item becomes the context while being rendered. This is how you iterate over a collection of objects:

	My shopping list:
	{{#items}}
	- {{name}}
	{{/items}}

When a key is missed at the item level, it is looked into the enclosing context.

#### Lambda sections

Read below "Lambdas and helpers", which covers in detail how GRMustache allows you to provide custom code for rendering sections.

#### Other sections

Otherwise - if the value is not enumerable, false, or lambda - the content of the section is rendered once.

The value becomes the context while being rendered. This is how you traverse an object hierarchy:

	{{#me}}
	  {{#mother}}
	    {{#father}}
	      My mother's father was named {{name}}.
	    {{/father}}
	  {{/mother}}
	{{/me}}

When a key is missed, it is looked into the enclosing context. This is the base mechanism for templates like:

	{{! If there is a title, render it in a <h1> tag }}
	{{#title}}
	  <h1>{{title}}</h1>
	{{/title}}

### Inverted sections `{{^name}}...{{/name}}`

Such a section is rendered when the `{{#name}}...{{/name}}` section would not: in the case of false values, or empty enumerables.

### Partials `{{>partial_name}}`

A `{{>partial_name}}` tag is rendered as a partial loaded from the file system.

Partials must have the same extension as their including template.

Recursive partials are possible. Just avoid infinite loops in your context objects.

Depending on the method which has been used to create the original template, partials will be looked in different places :

- In the main bundle:
	- `renderObject:fromString:error:`
	- `parseString:error:`
- In the specified bundle:
	- `renderObject:fromResource:bundle:error:`
	- `renderObject:fromResource:withExtension:bundle:error:`
	- `parseResource:bundle:error:`
	- `parseResource:withExtension:bundle:error:`
- Relatively to the URL of the including template:
	- `renderObject:fromContentsOfURL:error:`
	- `parseContentsOfURL:error:`
- Relatively to the path of the including template:
	- `renderObject:fromContentsOfFile:error:`
	- `parseContentsOfFile:error:`

The "Template loaders" section below will show you more partial loading GRMustache features.

Dot key and extended paths
--------------------------

### Extended paths

GRMustache supports extended paths introduced by [Handlebars.js](https://github.com/wycats/handlebars.js). Paths are made up of typical expressions and / characters. Expressions allow you to not only display data from the current context, but to display data from contexts that are descendents and ancestors of the current context.

To display data from descendent contexts, use the / character. So, for example, if your context were structured like:

	context = [NSDictionary dictionaryWithObjectsAndKeys:
	           [Person personWithName:@"Alan"], @"person",
	           [Company companyWithName:@"Acme"], @"company",
	           nil];

you could display the person's name from the top-level context with the following expression:

	{{person/name}}

Similarly, if already traversed into the person object you could still display the company's name with an expression like ``{{../company/name}}`, so:

	{{#person}}{{name}} - {{../company/name}}{{/person}}

would render:

	Alan - Acme

### Dot key

Consistently with "`..`", the dot "`.`" stands for the current context itself. This dot key can be useful when iterating a list of scalar objects. For instance, the following context:

	context = [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects: @"beer", @"ham", nil]
	                                      forKey:@"item"];

renders:

	<ul><li>beer</li><li>ham</li></ul>

when applied to the template:

	<ul>{{#item}}<li>{{.}}</li>{{/item}}</ul>

Boolean Properties
------------------

GRMustache handles `BOOL` properties:

	@interface Person: NSObject
	@property BOOL dead;
	@property NSString *name;
	@end

For instance, in the following template, GRMustache would process the `dead` boolean property as expected, and display "RIP" next to dead people only:

	{{#persons}}
	- {{name}} {{#dead}}(RIP){{/dead}}
	{{/persons}}

If you declare a custom getter for your property, make sure you don't use it in the template:

	@interface Person: NSObject
	@property (getter=isDead) BOOL dead;
	@end

	{{person}}
	  {{#dead}}GOOD{{/dead}}
	  {{#isDead}}BAD{{/isDead}}
	{{/person}}

### Undeclared BOOL properties

Undeclared BOOL properties, that is to say: selectors implemented without corresponding `@property` in some `@interface` block, will be considered as numbers, and thus *can not be used for controlling boolean sections*:

	@interface Person: NSObject
	- (BOOL)dead;	// will be considered as 0 and 1 integers
	@end

### Collateral damage: signed characters

`BOOL` is defined as `signed char` in `<objc/objc.h>`. As a consequence, all properties declared as `char` will be considered as booleans:

	@interface Person: NSObject
	@property char initial;	// will be considered as boolean
	@end

We thought that built-in support for `BOOL` properties was worth this annoyance, since it should be pretty rare  that you would use a value of such a type in a template.

However, should this behavior annoy you, we provide a mechanism for having GRMustache behave strictly about boolean properties:

Enter the *strict boolean mode* with the following statement, prior to any rendering:

	[GRMustache setStrictBooleanMode:YES];

In strict boolean mode, `char` and `BOOL` properties will be considered as what they really are: numbers.

### The case for C99 bool

You may consider using the unbeloved C99 `bool` type. They can reliably control boolean sections whatever the boolean mode, and with ou without property declaration.

	@interface Person: NSObject
	- (bool)dead;
	@end


Lambdas and helpers
-------------------

Imagine that, in the following template, you wish the `link` sections to be rendered as hyperlinks:

	<ul>
	  {{#people}}
	  <li>{{#link}}{{name}}{{/link}}</li>
	  {{/people}}
	</ul>

We expect, as an output, something like:

	<ul>
	  <li><a href="/people/1">Roger</a></li>
	  <li><a href="/people/2">Amy</a></li>
	</ul>

GRMustache provides you with two ways in order to achieve this behavior. The first one uses Objective-C blocks, the second requires some selectors to be implemented.

### Lambda blocks

*Note that lambda blocks are not available until MacOS 10.6, and iOS 4.0.*

You will provide in the context an object built with the GRMustacheLambdaBlockMake function. This function takes a block which returns the string that should be rendered, as in the example below:

	// prepare our link lambda block
	id linkLambda = GRMustacheLambdaBlockMake(^(GRMustacheSection *section, GRMustacheContext *context) {
	  return [NSString stringWithFormat:
	          @"<a href=\"/people/%@\">%@</a>",
	          [context valueForKey:@"id"],    // id of person comes from current context
	          [section renderObject:context]] // link text comes from the natural rendering of the inner section
	});

The block takes two arguments:

- `section` is an object which represents the rendered section.
- `context` is the current rendering context.

The `[section renderObject:context]` expression evaluates to the rendering of the section with the given context.

In case you would need it, the `section` object has a `templateString` property, which contains the litteral inner section, unrendered (`{{tags}}` will not have been expanded).

The final rendering now goes as usual, by providing objects for template keys, the lambda for the key `link`, and some people for the key `people`:

	NSArray *people = ...;
	[template renderObject:[NSDictionary dictionaryWithObjectsAndKeys:
	                        linkLambda, @"link",
	                        people, @"people",
	                        nil]];

### Helper methods

Another way to execute code when rendering the `link` sections is to have the context implement the `linkSection:withContext:` selector (generally, implement a method whose name is the name of the section, to which you append `Section:withContext:`).

No block is involved, and this technique works before MacOS 10.6, and iOS 4.0.

Now the question is: which class should implement this helper selector? When the `{{#link}}` section is rendered, GRMustache is actually rendering a person. Remember the template itself:

	<ul>
	  {{#people}}
	  <li>{{#link}}{{name}}{{/link}}</li>
	  {{/people}}
	</ul>

Many objects are in the context and can provide the implementation: the person itself, the `people` array of persons, the object that did provide this array, up to the root, the object which has been initially provided to the template.

Let's narrow those choices to only two: either you have your model objects implement the `linkSection:withContext:` selector, or you isolate helper methods from your model.

#### Helpers as a model category

If your model object is designed as such:

	@interface DataModel
	@property NSArray *people;  // array of Person objects
	@end
	
	@interface Person
	@property NSString *name;
	@property NSString *id;
	@end

You can declare the `linkSection:withContext` in a category of those objects.

You may use the Person object itself:

	@implementation Person(GRMustache)
	- (NSString*)linkSection:(GRMustacheSection *)section withContext:(GRMustacheContext *)context {
	  return [NSString stringWithFormat:
	          @"<a href=\"/people/%@\">%@</a>",
	          self.id,                          // id comes from self
	          [section renderObject:context]];  // link text comes from the natural rendering of the inner section
	}
	@end

Or you may use the root DataModel object:

	@implementation DataModel(GRMustache)
	- (NSString*)linkSection:(GRMustacheSection *)section withContext:(GRMustacheContext *)context {
	  return [NSString stringWithFormat:
	          @"<a href=\"/people/%@\">%@</a>",
	          [context valueForKey:@"id"],      // id of person comes from current context
	          [section renderObject:context]];  // link text comes from the natural rendering of the inner section
	}
	@end

The choice is really up to you, considering how much a piece of code can be reused in other contexts.

This mix of data and rendering code in a single class is a debatable pattern. Well, you can compare this to the NSString(UIStringDrawing) and NSString(AppKitAdditions) categories. Furthermore, a strict MVC separation mechanism is described below.

Anyway, the rendering can now be done with:

	DataModel *dataModel = ...;
	[template renderObject:dataModel];


#### Isolating helper methods

In order to achieve a stricter MVC separation, one might want to isolate helper methods from data.

GRMustache allows you to do that, too. First declare a container for your helper methods:

	@interface RenderingHelper: NSObject
	@end
	
	@implementation RenderingHelper
	+ (NSString*)linkSection:(GRMustacheSection *)section withContext:(GRMustacheContext *)context {
	  return [NSString stringWithFormat:
	          @"<a href=\"/people/%@\">%@</a>",
	          [context valueForKey:@"id"],      // id of person comes from current context
	          [section renderObject:context]];  // link text comes from the natural rendering of the inner section
	}
	@end

Here we have written class methods because our helper doesn't carry any state. You are free to define helpers as instance methods, too.

Now let's introduce a useful feature of the GRMustacheContext class: providing to the template a context which contains both data, and helper methods:

	id dataModel = ...;
	GRMustacheContext *context = [GRMustacheContext contextWithObjects: [RenderingHelper class], dataModel, nil];

And now we can render:

	[template renderObject:context];


#### Usages of lambdas and helpers

Lambdas and helpers can be used for whatever you may find relevant. We'll base our examples on lambda blocks, but the same patterns apply to helper methods.

You may, for instance, implement caching:

	__block NSString *cache = nil;
	GRMustacheLambdaBlockMake(^(GRMustacheSection *section, GRMustacheContext *context) {
	  if (cache == nil) { cache = [section renderObject:context]; }
	  return cache;
	});

You may render another context:

	GRMustacheLambdaBlockMake(^(GRMustacheSection *section, GRMustacheContext *context) {
	  return [section renderObject:[NSDictionary ...]];
	});

You may render an extended context:

	GRMustacheLambdaBlockMake(^(GRMustacheSection *section, GRMustacheContext *context) {
	  return [section renderObject:[context contextByAddingObject:[NSDictionary ...]]];
	});

You may implement debugging sections:

	GRMustacheLambdaBlockMake(^(GRMustacheSection *section, GRMustacheContext *context) {
	  NSLog(section.templateString);         // log the unrendered section 
	  NSLog([section renderObject:context]); // log the rendered section 
	  return nil;                            // don't render anything
	});


Template loaders
----------------

### Fine tuning loading of templates

The GRMustacheTemplateLoader class is able to load templates and their partials from anywhere in the file system, and provides more options than the high-level methods already seen.

You may instanciate one with the following GRMustacheTemplateLoader class methods:

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
	+ (id)templateLoaderWithBasePath:(NSString *)path;

	// Loads templates and partials from a directory, with provided extension, encoded in UTF8
	+ (id)templateLoaderWithBasePath:(NSString *)path
	                       extension:(NSString *)ext;

	// Loads templates and partials from a directory, with provided extension, encoded in provided encoding
	+ (id)templateLoaderWithBasePath:(NSString *)path
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

Once you have a GRMustacheTemplateLoader object, you may load a template from its location:

	GRMustacheTemplate *template = [loader parseTemplateNamed:@"document" error:nil];

You may also have the loader parse a template string. Only partials would then be loaded from the loader's location:

	GRMustacheTemplate *template = [loader parseString:@"..." error:nil];

The rendering is done as usual:

	NSString *rendering = [template renderObject:...];


### Implementing your own template loading strategy

GRMustache is shipped with built-in ability to load templates and partials from the file system, or from a bundle, as seen above.

If this does not fit your needs, you may subclass the GRMustacheTemplateLoader class.

We provide below the implementation of a template loader which loads partials from a dictionary containing template strings:

	#import "GRMustache.h"
	
	@interface DictionaryTemplateLoader : GRMustacheTemplateLoader {
	  NSDictionary *templatesByName;
	}
	+ (id)loaderWithDictionary:(NSDictionary *)templatesByName;
	- (id)initWithDictionary:(NSDictionary *)templatesByName;
	@end
	
	// In your implementation file, import the GRMustacheTemplateLoader_protected.h
	// header, dedicated to GRMustacheTemplateLoader subclasses:
	#import "GRMustacheTemplateLoader_protected.h"
	
	@implementation DictionaryTemplateLoader
	
	+ (id)loaderWithDictionary:(NSDictionary *)templatesByName {
	  return [[[self alloc] initWithDictionary:templatesByName] autorelease];
	}
	
	- (id)initWithDictionary:(NSDictionary *)theTemplatesByName {
	  // initWithExtension:encoding: is the designated initializer.
	  // provide it with some values, even if we won't use them.
	  if (self = [self initWithExtension:nil encoding:NSUTF8StringEncoding]) {
	    templatesByName = [theTemplatesByName retain];
	  }
	  return self;
	}
	
	- (void)dealloc {
	  [templatesByName release];
	  [super dealloc];
	}
	
	// This method must be implemented by GRMustacheTemplateLoader subclasses.
	// Provided with a partial name, returns an object which uniquely identifies a template.
	- (id)templateIdForTemplateNamed:(NSString *)name relativeToTemplateId:(id)baseTemplateId {
	  return name;
	}
	
	// This method must be implemented by GRMustacheTemplateLoader subclasses.
	// Returns a template string.
	- (NSString *)templateStringForTemplateId:(id)templateId error:(NSError **)outError {
	  return [templatesByName objectForKey:templateId];
	}

	@end

Now you may instanciate one:

	DictionaryTemplateLoader *loader = [DictionaryTemplateLoader loaderWithDictionary:
	                                    [NSDictionary dictionaryWithObject:@"It works!"
	                                                                forKey:@"partial"]];

Then load a template from it:

	GRMustacheTemplate *template = [loader parseString:@"{{>partial}}" error:nil];

And finally render:

	[template render];	// "It works!"



Errors
------

The GRMustache library may return errors whose domain is GRMustacheErrorDomain.

	extern NSString* const GRMustacheErrorDomain;

Their error codes may be interpreted with the GRMustacheErrorCode enumeration:

	typedef enum {
		GRMustacheErrorCodeParseError,
		GRMustacheErrorCodeTemplateNotFound,
	} GRMustacheErrorCode;


A less simple example
---------------------

Let's be totally mad, and display a list of people and their birthdates in a UIWebView embedded in our iOS application.

We'll most certainly have a UIViewController for displaying the web view:

	@interface PersonListViewController: UIViewController
	@property (nonatomic, retain) NSArray *persons;
	@property (nonatomic, retain) IBOutlet UIWebView *webView;
	@end

The `persons` array contains some instances of our Person model:

	@interface Person: NSObject
	@property (nonatomic, retain) NSString *name;
	@property (nonatomic, retain) NSDate *birthdate;
	@end

A PersonListViewController instance and its array of persons is a graph of objects that is already perfectly suitable for rendering our template:

	PersonListViewController.mustache:
	
	<html>
	<body>
	<dl>
	  {{#persons}}
	  <dt>{{name}}</dt>
	  <dd>{{localizedBirthdate}}</dd>
	  {{/persons}}
	</dl>
	</body>
	</html>

We already see the match between our classes' properties, and the `persons` and `name` keys. More on the `birthdate` vs. `localizedBirthdate` later.

We should already be able to render most of our template:

	@implementation PersonListViewController
	- (void)viewWillAppear:(BOOL)animated {
	  // Let's use self as the rendering context:
	  NSString *html = [GRMustacheTemplate renderObject:self
	                                       fromResource:@"PersonListViewController"
	                                       bundle:nil
	                                       error:nil];
	  [self.webView loadHTMLString:html baseURL:nil];
	}
	@end

Now our `{{#persons}}` enumerable section and `{{name}}` variable tag will perfectly render.

What about the `{{localizedBirthdate}}` tag?

Since we don't want to pollute our nice and clean Person model, let's add a category to it:

	@interface Person(GRMustache)
	@end

	static NSDateFormatter *dateFormatter = nil;
	@implementation Person(GRMustache)
	- (NSString *)localizedBirthdate {
	  if (dateFormatter == nil) {
	    dateFormatter = [[NSDateFormatter alloc] init];
	    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
	    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	  }
	  return [dateFormatter stringFromDate:date];
	}
	@end

And we're ready to go!

License
-------

Released under the [MIT License](http://en.wikipedia.org/wiki/MIT_License)

Copyright (c) 2010 Gwendal Roué

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

