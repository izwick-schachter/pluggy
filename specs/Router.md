# Router Spec

## Structure Recommendations

The job of a Router is to create Route objects, store them (typically in an Array of Route objects), and retrieve routes based on parameters passed from the server (typically a URI and an HTTP Verb).

Therefore, it is recommended that the #initialize method take an Array of Route objects to begin with, and that the #route method generate Routes and append them to an internal routes array.It is also recommened that this Routes array be exposed via an attr_reader.

## Methods

{include:file:specs/Router/#initialize.md}

{include:file:specs/Router/#route.md}

{include:file:specs/Router/#where.md}

{include:file:specs/Router/#find_by.md}
