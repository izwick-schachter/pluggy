# Matcher Spec

A matcher is fairly simply. It must be able to be instantiated (taking one argument, typically a URI) and return a pattern object, and have a #match? instance method which optionally can return a MatchData object or respond to names (for a array of keys) and values (for a array of values). This spec is subject to revision, because it's simply based on Mustermann.