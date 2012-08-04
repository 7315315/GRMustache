[up](../../../../GRMustache), [next](delegate.md)

Filters
=======

You can filter values before they are rendered.

**Filters are not yet part of the Mustache specification**, while the topic is currently under [discussion](http://github.com/mustache/spec/issues/41). You thus need to explicitely opt-in in order to use them, with the `{{%FILTERS}}` special "pragma" tag in your templates.

You apply a filter just like calling a function, with parentheses:

- `{{%FILTERS}}My name is {{ uppercase(name) }}` would render `My name is ARTHUR`, provided with "Arthur" as a name.

- Filters can chain: `{{ uppercase(reversed(name)) }}` would render `RUHTRA`.

- Filters can apply to compound key paths: `{{ uppercase(person.name) }}`.

- You can extract values from filtered values: `{{ last(persons).name }}`.

- You can filter sections as well : `{{^ isEmpty(people) }}...{{/ isEmpty(people) }}` renders if the people collection is not empty.
    
    For brevity's sake, closing section tags can be empty: `{{^ isEmpty(people) }}...{{/}}` is valid.

## Standard library

GRMustache ships with a bunch of already implemented filters:

- `capitalized`
    
    Given "johannes KEPLER", it returns "Johannes Kepler".
    
- `lowercase`
    
    Given "johannes KEPLER", it returns "johannes kepler".

- `uppercase`
    
    Given "johannes KEPLER", it returns "JOHANNES KEPLER".

- `isEmpty`
    
    Returns YES if the input is nil, [NSNull null], or an empty enumerable object, or an empty string. Returns NO otherwise.

- `isBlank`
    
    Returns YES if the input is nil, [NSNull null], or an empty enumerable object, or a string made of zero or more white space characters (space, tabs, newline). Returns NO otherwise.

## Defining your own filters

You can implement your own filters with objects that conform to the `GRMustacheFilter` protocol.

This protocol defines a single required method:

```objc
@protocol GRMustacheFilter <NSObject>
@required
- (id)transformedValue:(id)object;
@end
```

You can for instance declare a filter that outputs numbers as percentages:

```objc
@interface PercentFilter : NSObject<GRMustacheFilter>
@end

@implementation PercentFilter
- (id)transformedValue:(id)object
{
    NSNumberFormatter *percentNumberFormatter = [[NSNumberFormatter alloc] init];
    percentNumberFormatter.numberStyle = kCFNumberFormatterPercentStyle;
    return [numberFormatter stringFromNumber:object];
}
@end

id percentFilters = [[PercentFilter alloc] init];
```

Starting iOS4 and MacOS 10.6, the Objective-C language provides us with blocks. This can relieve the burden of declaring a full class for each filter:

```objc
id percentFilter = [GRMustacheFilter filterWithBlock:^id(id object) {
    NSNumberFormatter *percentNumberFormatter = [[NSNumberFormatter alloc] init];
    percentNumberFormatter.numberStyle = kCFNumberFormatterPercentStyle;
    return [numberFormatter stringFromNumber:object];
}];
```

Now, let's have GRMustache know about your custom filter, and use it:

```objc
// Prepare the data
float gain = 0.5;
NSDictionary *data = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:gain] forKey:@"gain"];

// Prepare the filters
NSDictionary *filters = [NSDictionary dictionaryWithObject:percentFilter forKey:@"percent"];

// Renders @"Enjoy your 50% productivity bump!"
NSString *templateString = @"{{%FILTERS}}Enjoy your {{ percent(gain) }} productivity bump!";
NSString *rendering = [GRMustacheTemplate renderObject:data
                                           withFilters:filters
                                            fromString:templateString
                                                 error:NULL];
```

## Filters namespaces

When rendering the tag `{{ f(x) }}`, GRMustache extracts the value of `x` by performing a key lookup described in the [Context Stack Guide](runtime/context_stack.md).

The mechanism for extracting the filter for `f` is the same, but it applies to the `filters` argument of the rendering method, not its `object` argument:

```objc
[GRMustacheTemplate renderObject:data       // values are fetched here
                     withFilters:filters    // filters are fetched here
                      fromString:templateString
                           error:NULL];
```

Just as you can provide an object hierarchy for values, and extract `foo.bar` from it, you can provide filters as an object hierarchy, and "namespace" your filters. For instance, let's declare the `math.abs` filter, and render `{{ math.abs(x) }}`:

```objc
id absFilter = [GRMustacheFilter filterWithBlock:^id(id object) {
    return [NSNumber numberWithInt: abs([object intValue])];
}];
NSDictionary *mathFilters = [NSDictionary dictionaryWithObject:absFilter forKey:@"abs"];
NSDictionary *filters = [NSDictionary dictionaryWithObject:mathFilters forKey:@"math"];

[GRMustacheTemplate renderObject:...
                     withFilters:filters
                      fromString:@"{{%FILTERS}}{{math.abs(x)}}"
                           error:NULL];
```

## Missing filters

Should a filter be misspelled, missing, or should the matching object not conform to the GRMustacheFilter protocol, GRMustache will raise an exception.

GRMustache helps you debugging by providing the exact place where the error occurs:

    Missing filter for key `f` in tag `{{ f(foo) }}` at line 13 of /path/to/teplate.
    
    Object for key `f` in tag `{{ f(foo) }}` at line 13 of /path/to/template does not conform to GRMustacheFilter protocol: "blah"

[up](../../../../GRMustache), [next](delegate.md)
