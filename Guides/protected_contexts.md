[up](../../../../GRMustache#documentation), [next](../../../tree/master/Guides/sample_code)

Protected Contexts
==================

The Mustache key shadowing
--------------------------

As Mustache sections get nested, the [context stack](runtime.md) expands:

    {{#person}}
        {{#pet}}
            {{name}}  {{! the name of the pet of the person }}
        {{/pet}}
    {{/person}}

This is all good. However, the children contexts shadow their parents: keys get "redefined" as sections get nested:

    {{#person}}
        {{name}}        {{! the person's name }}
        {{#pet}}
            {{name}}    {{! the pet's name }}
        {{/pet}}
    {{/person}}

Some will say: "Mustache needs a syntax that lets me access outer contexts!".

It would surely help. However this is not the main trouble.

Robust code in an untrusted environment
---------------------------------------

The main trouble is that you may want to write robust and/or reusable [partials](partials.md), [filters](filters.md), [rendering objects](rendering_objects.md) that process *untrusted data* in *untrusted templates*.

Because of untrusted data, you can not be sure that your precious keys won't be shadowed.

Because of untrusted templates, you can not be sure that your precious keys will be invoked with the correct syntax, should a syntax for navigating the context stack exist.

Untrusted data and templates do exist, I've seen them: at the minimum they are the data and the templates built by the [future you](http://xkcd.com/302/).

Protected contexts
------------------

GRMustache addresses this concern by letting you store *protected objects* in the *base context* of a template.

The base context contains [context stack values](runtime.md) and [tag delegates](delegate.md) that are always available for the template rendering. It contains all the ready for use filters of the [filter library](filters.md), for example. Context objects are detailed in the [Rendering Objects Guide](rendering_objects.md).

You can derive a new context that contain protected objects with the `contextByAddingProtectedObject:` method:

```objc

id protectedData = @{
    @"safe": @"important",
};

GRMustacheTemplate *template = [GRMustacheTemplate templateFrom...];
template.baseContext = [template.baseContext contextByAddingProtectedObject:protectedData];
```

Now the `safe` key can not be shadowed: it will always evaluate to the `important` value.


Compatibility with other Mustache implementations
-------------------------------------------------

The [Mustache specification](https://github.com/mustache/spec) does not have any concept of "protected objects".

**If your goal is to design templates that remain compatible with [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations), use protected objects with great care.**


[up](../../../../GRMustache#documentation), [next](../../../tree/master/Guides/sample_code)
