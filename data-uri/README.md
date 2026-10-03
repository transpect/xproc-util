# Create a map from archive entry href and/or name to the entry’s data: URI

…where “archive” is typically a ZIP file, and “entry” is a `c:archive/c:entry` manifest entry with `@name` and `@href`
attributes. 

See the documentation in [test/test-contents-data-uri-map.xpl](test/test-contents-data-uri-map.xpl) and the preparation/invocation instructions in
[test/test-contents-data-uri-map.sh](test/test-contents-data-uri-map.sh). 

The test pipeline creates two maps. First the step `tr:contents-data-uri-map` creates a map “normalized base URI → data
URI” (for [test/dir.zip](test/dir.zip), it’s [test/entry-href-data-uris.json](test/entry-href-data-uris.json)). Then `tr:manifest-data-uri-map` creates a map “manifest `@name` → data URI” ([test/entry-name-data-uris.json](test/entry-name-data-uris.json)). The second step uses `c:entry/@href`
in order to locate archive manifest entries by archive member base URIs. It then uses the entry’s `@name` attribute and
associates it with the data URI that was associated with the archive member’s base URI in the first step.

If you already have the archive contents on one port and the archive manifest on another port, you can create the name →
data URI map with `tr:archive-data-uri-map` that combines both mappings.

The steps `tr:manifest-data-uri-map` and `tr:archive-data-uri-map` (and the test pipeline) accept the option
`name-keys-relative-to` with a default value 'index.html'. If the name keys should match relative paths found in an HTML
file, for example '../img/image.png' in 'html/index.html', you can supply 'html/index.html' as this option’s value. Then the keys will be calculated as '../img/image.png' instead of the default 'img/image.png'.
    
## To Do
    
 * Deal with percent escaping that may or may not be present in `img/@src` etc. attribute values.
   This is probably not the task of this library, unless we want to duplicate map entries for unescaped and escaped
   names.   