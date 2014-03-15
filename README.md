# GDocHtml2Manning

An XSLT for transforming HTML-exported Google Docs into Manning DocBook format.

## How to use it

It is quite simple:

    xsltproc --html -o <yourdoc.xml> transform.xslt <yourdoc.html>

## What it supports

The current version correctly translates sections up to `<h6>` if they are also correctly nested in the source document (i.e. a `<h3>` directly “within” a `<h1>` will not be translated).

Furthermore ordered and unordered lists and footnotes should work correctly (for technical reasons the first paragraph of each footnote has a leading space token).

## What it does not support

Images are currently ignored, as are `<br>` tags.
