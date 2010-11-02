GRMustache
==========

GRMustache is an Objective-C implementation of the [Mustache](http://mustache.github.com/) logic-less template engine.

Its implementation has been highly inspired by the Mustache [go implementation](http://github.com/hoisie/mustache.go/). Its tests are based on the [Ruby](http://github.com/defunkt/mustache) one, that we have considered as a reference.

It supports the following Mustache features:

- comments
- delimiter changes
- variables
- boolean sections
- enumerable sections
- inverted sections
- lambda sections
- partials and recursive partials

It supports some extensions to the regular [Mustache syntax](http://mustache.github.com/mustache.5.html):

- dot variable tag: `{{.}}`

Embedding in your XCode project
-------------------------------

Add to your project all files contained in the `Classes` folder.

Import `GRMustache.h` in order to access all GRMustache features.

Header files whose names contain `private` declare private APIs which are subject to change, without notice, over releases.

All other headers contain public and stable declarations.

Simple example
--------------

	#import "GRMustache.h"
	
	NSDictionary *object = [NSDictionary dictionaryWithObject:@"Mom" forKey:@"name"];
	[GRMustacheTemplate renderObject:object fromString:@"Hi {{name}}!" error:nil];
	// returns @"Hi Mom!"

That's just for a start. We'll cover a more practical example below.

Rendering methods
-----------------

The main rendering methods provided by the `GRMustacheTemplate` class are:

	// Renders the provided templateString.
	+ (NSString *)renderObject:(id)object
	                fromString:(NSString *)templateString
	                     error:(NSError **)outError;
	
	// Renders the template loaded from a url.
	+ (NSString *)renderObject:(id)object
	         fromContentsOfURL:(NSURL *)url
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

If you are planning to render the same template multiple times, it is more efficient to parse it once, with the compiling methods of the `GRMustacheTemplate` class:

	// Parses the templateString.
	+ (id)parseString:(NSString *)templateString
	            error:(NSError **)outError;
	
	// Loads and parses the template from url.
	+ (id)parseContentsOfURL:(NSURL *)url
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

Those methods return `GRMustacheTemplate` instances, which render objects with the following method:

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

Context objects
---------------

You will provide a rendering method with a context object.

Mustache tag names are looked in the context object, through standard Key-Value Coding.

The most obvious objects which support KVC are dictionaries. You may also provide with any other object, as long as it conforms to the `GRMustacheContext` protocol.

For instance:

	@interface Person: NSObject<GRMustacheContext>
	+ (id)personWithName:(NSString *)name;
	- (NSString *)name;
	@end

	// returns @"Hi Mom!"
	[GRMustacheTemplate renderObject:[Person personWithName:@"Mom"]
	                      fromString:@"Hi {{name}}!"
	                           error:nil];

Note that the KVC method `valueForKey:` raises a `NSUndefinedKeyException` exception in case of key miss. Dictionaries never miss, but your `GRMustacheContext` class could.

For instance:

	// raises an exception, because Person has no `blame` accessor
	[GRMustacheTemplate renderObject:[Person personWithName:@"Mom"]
	                      fromString:@"Hi {{blame}}!"
	                           error:nil];


Tag types
---------

We'll now cover all mustache tag types, and how they are rendered.

But let's give some definitions first:

- GRMustache considers *enumerable* all objects conforming to the `NSFastEnumeration` protocol, but `NSDictionary` and those conforming to the `GRMustacheContext` protocol.

- GRMustache considers *false* `[NSNull null]`, `nil` and the empty string `@""`.


### Comments `{{!...}}`

Comments tags are not rendered.

### Variable tags `{{name}}`

Such a tag is rendered according to the value for key `name` in the context.

If the value is *false*, the tag is rendered with the empty string.

Otherwise, it is rendered with the `description` of the value, HTML escaped.

### Unescaped variable tags `{{{name}}}` and `{{&name}}`

Such a tag is rendered according to the value for key `name` in the context.

If the value is *false*, the tag is rendered with the empty string.

Otherwise, it is rendered with the `description` of the value, without HTML escaping.

### Enumerable sections `{{#name}}...{{/name}}`

If the value for key `name` in the context is *enumerable*, the text between the `{{#name}}` and `{{/name}}` tags is rendered once for each item in the enumerable. Each item will extend the context while being rendered. The section is rendered with an empty string if the enumerable is empty.

### Lambda sections `{{#name}}...{{/name}}`

Such a section is rendered with the string returned by a block of code if the value for key `name` in the context is a `GRMustacheLambda`.

You will build a `GRMustacheLambda` with the `GRMustacheLambdaMake` function. This function takes a block which returns the string that should be rendered, as in the example below:

	// A lambda which renders its section without any special effect:
	GRMustacheLambda lambda = GRMustacheLambdaMake(^(GRMustacheRenderer renderer,
	                                                 GRMustacheContext *context,
	                                                 NSString *templateString) {
	    return renderer();
	});

- `renderer` is a block without argument which returns the normal rendering of the section.
- `context` is the current context object.
- `templateString` contains the litteral section block, unrendered : `{{tags}}` will not have been expanded.

You may use all three arguments for any purpose:

	GRMustacheLambda uppercaseLambda = GRMustacheLambdaMake(^(GRMustacheRenderer renderer,
	                                                          GRMustacheContext *context,
	                                                          NSString *templateString) {
	  if ([context valueForKey:@"important"]) {
	    return [renderer() uppercase];
	  }
	  return renderer();
	});

You may implement caching:

	__block NSString *cache = nil;
	GRMustacheLambda cacheLambda = GRMustacheLambdaMake(^(GRMustacheRenderer renderer,
	                                                      GRMustacheContext *context,
	                                                      NSString *templateString) {
	  if (cache == nil) { cache = renderer(); }
	  return cache;
	});

You may also render a totally different template:

	GRMustacheTemplate *outerspaceTemplate = [GRMustacheTemplate parseString:@"..." error:nil];
	GRMustacheLambda outerspaceLambda = GRMustacheLambdaMake(^(GRMustacheRenderer renderer,
	                                                           GRMustacheContext *context,
	                                                           NSString *templateString) {
		return [outerspaceTemplate renderObject:context];
	});


### Boolean sections `{{#name}}...{{/name}}`

Such a section is rendered according to the value for key `name` in the context.

When *false*, the section is rendered with an empty string.

Otherwise, the section is rendered within a context extended by the value.

### Inverted sections `{{^name}}...{{/name}}`

Such a section is rendered *iff* the `{{#name}}...{{/name}}` would not: if the value for key `name` in the context is *false*, or an empty *enumerable*.

### Partials `{{>name}}`

A `{{>name}}` tag is rendered as a partial loaded from the file system.

The partial must have the same extension as its including template.

Depending on the method which has been used to create the original template, the partial will be looked in different places :

- Methods which will look in the current working directory:
	- `renderObject:fromString:error:`
	- `parseString:error:`
- Methods which will look relatively to the URL of the including template:
	- `renderObject:fromContentsOfURL:error:`
	- `parseContentsOfURL:error:`
- Methods which will look in the bundle:
	- `renderObject:fromResource:bundle:error:`
	- `renderObject:fromResource:withExtension:bundle:error:`
	- `parseResource:bundle:error:`
	- `parseResource:withExtension:bundle:error:`

Recursive partials are possible. Just avoid infinite loops in your context objects.

Extensions
----------

The Mustache syntax is described at [http://mustache.github.com/mustache.5.html](http://mustache.github.com/mustache.5.html).

GRMustache adds the following extensions:

### Dot Variable tag `{{.}}`

This extension has been inspired by the dot variable tag introduced in [mustache.js](http://github.com/janl/mustache.js).

This variable tags output the `description` of the current context.

For instance:

	NSString *templateString = @"{{#name}}: <ul>{{#item}}<li>{{.}}</li>{{/item}}</ul>";
	NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
	                         @"Groue's shopping cart", @"name",
	                         [NSArray arrayWithObjects: @"beer", @"ham", nil], @"item",
	                         nil];
	// Returns @"Groue's shopping cart: <ul><li>beer</li><li>ham</li></ul>"
	[GRMustacheTemplate renderObject:context fromString:templateString error:nil];

Beware that dictionaries and objects conforming to `GRMustacheContext` protocol are the only objects whose KVC capabilities are used.

This allows both those templates to render the same thing, when the key `name` refers to a `NSString`:

	{{#name}}{{.}}{{/name}}
	{{#name}}{{name}}{{/name}}    would raise NSUndefinedKeyException if key `name` was loaded from a string

But this means you can not access, for instance, the length of a string in a template:

	{{#name}}{{length}}{{/name}}  won't raise, but won't render the length of the string

Errors
------

The GRMustache library may return errors whose domain is `GRMustacheErrorDomain`.

	extern NSString* const GRMustacheErrorDomain;

Their error codes may be interpreted with the `GRMustacheErrorCode` enumeration:

	typedef enum {
		GRMustacheErrorCodeParseError,
		GRMustacheErrorCodePartialNotFound,
	} GRMustacheErrorCode;

The `userInfo` dictionary of parse errors contain the `GRMustacheErrorURL` and `GRMustacheErrorLine` keys, which provide with the URL of the erroneous template, and the line where the error occurred.

	extern NSString* const GRMustacheErrorURL;
	extern NSString* const GRMustacheErrorLine;


A practical example
-------------------

Let's be totally mad, and display a list of people and their birthdays in a `UIWebView` embedded in our iOS application.

We'll most certainly have a `UIViewController` for displaying the web view:

	@interface PersonListViewController: UIViewController
	@property (nonatomic, retain) NSArray *persons;
	@property (nonatomic, retain) IBOutlet UIWebView *webView;
	@end

The `persons` array contains some instances of our `Person` model:

	@interface Person: NSObject
	@property (nonatomic, retain) NSString *name;
	@property (nonatomic, retain) NSDate *birthdate;
	@end

A `PersonListViewController` instance and its array of persons is a graph of objects that is already perfectly suitable for rendering our template:

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

We already see the match between the `persons` and `name` keys. More on the `birthdate` vs. `localizedBirthdate` later.

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

Since our `PersonListViewController` instance, and, later, its persons, are the mustache rendering contexts, and that we want the keys like `persons` and `name` to be fetched with KVC, we have to declare those classes as KVC-enabled for GRMustache.

This is done by having them conform to the `GRMustacheContext` protocol. Let's rewrite our interfaces:

	@interface PersonListViewController: UIViewController<GRMustacheContext>
	@interface Person: NSObject<GRMustacheContext>

Now our `{{#persons}}` enumerable section and `{{name}}` variable tag will perfectly render.

What about the `{{localizedBirthdate}}` tag?

Since we don't want to pollute our nice and clean Person model, let's add a category to it:

	@interface Person(GRMustacheContext)
	@end

	static NSDateFormatter *dateFormatter = nil;
	@implementation Person(GRMustacheContext)
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

