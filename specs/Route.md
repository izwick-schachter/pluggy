# Router Spec

## Structure Recommendations

A Route object is responsible for checking if it matches a URI and HTTP Verb (this responsibility is shared with the Router), and is reponsible for generating a view from `env` and `req`.

## Sub-Specs

To be fully compatible with the Pluggy spec, the `#initialize` method must accept a `view_class:` keyword argument containing any view class which is compatible with the Pluggy view spec. In addition, it must accept a `matcher_class:` keyword argument containing any matcher class which is compatible with the Pluggy matcher spec.

## Methods

{include:file:specs/Route/#initialize.md}

{include:file:specs/Route/#evaluate_with.md}

{include:file:specs/Route/#matches?.md}
