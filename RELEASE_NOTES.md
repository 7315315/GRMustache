GRMustache Release Notes
========================

## v1.5.2

The `DEBUG` macro has GRMustache raise much less NSUndefinedKeyException

## v1.5.1

Bug fixes

## v1.5.0

**API simplification**

New GRMustacheTemplate method:

- `- (NSString *)renderObjects:(id)object, ...;`

New GRMustacheSection method:

- `- (NSString *)renderObjects:(id)object, ...;`

New class:

- `GRMustacheBlockHelper`

Deprecated class (use `id` instead when refering to a context, and use `renderObjects:` methods instead of instanciating one):

- `GRMustacheContext`

Deprecated function (use GRMustacheBlockHelper instead):

- `id GRMustacheLambdaBlockMake(NSString *(^block)(GRMustacheSection*, GRMustacheContext*));`

## v1.4.0

**iOS 3.0 support**

New `GRMustacheTemplate` methods:

- `+ (NSString *)renderObject:(id)object fromContentsOfFile:(NSString *)path error:(NSError **)outError;`
- `+ (id)parseContentsOfFile:(NSString *)path error:(NSError **)outError;`

New `GRMustacheTemplateLoader` class methods:

- `+ (id)templateLoaderWithBasePath:(NSString *)path;`
- `+ (id)templateLoaderWithBasePath:(NSString *)path extension:(NSString *)ext;`
- `+ (id)templateLoaderWithBasePath:(NSString *)path extension:(NSString *)ext encoding:(NSStringEncoding)encoding;`

## v1.3.3

Bug fixes

## v1.3.2

Bug fixes

## v1.3.1

Bug fixes

## v1.3.0

**Block-less API for helpers.**

New classes:

- `GRMustacheContext`
- `GRMustacheSection`

New functions:

- `id GRMustacheLambdaBlockMake(NSString *(^block)(GRMustacheSection*, GRMustacheContext*));`

Deprecated functions (use GRMustacheLambdaBlockMake instead):

- `GRMustacheLambda GRMustacheLambdaMake(NSString *(^block)(NSString *(^)(id object), id, NSString *));`

## v1.2.0

**iOS 4.0 support**

Deprecated class (use `[NSNumber numberWithBool:YES]` instead of `[GRYes yes]`):

- `GRYes`

Deprecated class (use `[NSNumber numberWithBool:NO]` instead of `[GRNo no]`):

- `GRNo`

## v1.1.6

GRMustacheTemplateLoader subclasses can now rely on an immutable `extension` property.

## v1.1.5

Bug fixes

## v1.1.4

Bug fixes

## v1.1.3

**Rendering performance improvement**

## v1.1.2

**Template compiling performance improvement**

## v1.1.1

Bug fixes

## v1.1.0

New methods:

- `[GRYes yes]` responds to `boolValue`
- `[GRNo no]` responds to `boolValue`

## v1.0.0

**First versioned release**
