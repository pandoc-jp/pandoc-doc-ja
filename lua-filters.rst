
===========================================================
Pandoc Lua Filters 日本語版
===========================================================

.. note::

   現在の翻訳は *プレリリース版* です。不完全な翻訳を含んでいます。
   （ユーザーズガイド以外のページについてはほぼ翻訳されていません。現在翻訳を進めています）

   * 正確な情報については英語の公式 `User's Guide <https://pandoc.org/MANUAL.html>`_ を参照してください
   * この翻訳に対する問題・改善案については `GitHubリポジトリのIssue <https://github.com/pandoc-jp/pandoc-doc-ja/issues>`_ に投稿してください
   * 翻訳のレビュー作業や翻訳作業へのご協力を希望の方は :doc:`trans-intro` をご覧ください

原著者:

   * Albert Krewinkel
   * John MacFarlane

原著バージョン: 2.14.2

更新日: 2021/09/23

翻訳者（アルファベット順）:

* becolomochi
* makotosan
* niszet
* Takada Atsushi
* `Tomoki Ishibashi <https://ishibaki.github.io>`_
* Yuki Fujiwara

.. contents:: 目次
   :depth: 3

Introduction
============

Pandoc has long supported filters, which allow the pandoc abstract
syntax tree (AST) to be manipulated between the parsing and the writing
phase. `Traditional pandoc filters`_ accept a JSON representation of the
pandoc AST and produce an altered JSON representation of the AST. They
may be written in any programming language, and invoked from pandoc
using the ``--filter`` option.

Although traditional filters are very flexible, they have a couple of
disadvantages. First, there is some overhead in writing JSON to stdout
and reading it from stdin (twice, once on each side of the filter).
Second, whether a filter will work will depend on details of the user’s
environment. A filter may require an interpreter for a certain
programming language to be available, as well as a library for
manipulating the pandoc AST in JSON form. One cannot simply provide a
filter that can be used by anyone who has a certain version of the
pandoc executable.

Starting with version 2.0, pandoc makes it possible to write filters in
Lua without any external dependencies at all. A Lua interpreter (version
5.3) and a Lua library for creating pandoc filters is built into the
pandoc executable. Pandoc data types are marshaled to Lua directly,
avoiding the overhead of writing JSON to stdout and reading it from
stdin.

Here is an example of a Lua filter that converts strong emphasis to
small caps:

.. code:: lua

   return {
     {
       Strong = function (elem)
         return pandoc.SmallCaps(elem.c)
       end,
     }
   }

or equivalently,

.. code:: lua

   function Strong(elem)
     return pandoc.SmallCaps(elem.c)
   end

This says: walk the AST, and when you find a Strong element, replace it
with a SmallCaps element with the same content.

To run it, save it in a file, say ``smallcaps.lua``, and invoke pandoc
with ``--lua-filter=smallcaps.lua``.

Here’s a quick performance comparison, converting the pandoc manual
(MANUAL.txt) to HTML, with versions of the same JSON filter written in
compiled Haskell (``smallcaps``) and interpreted Python
(``smallcaps.py``):

======================================= =====
Command                                 Time
======================================= =====
``pandoc``                              1.01s
``pandoc --filter ./smallcaps``         1.36s
``pandoc --filter ./smallcaps.py``      1.40s
``pandoc --lua-filter ./smallcaps.lua`` 1.03s
======================================= =====

As you can see, the Lua filter avoids the substantial overhead
associated with marshaling to and from JSON over a pipe.

Lua filter structure
====================

Lua filters are tables with element names as keys and values consisting
of functions acting on those elements.

Filters are expected to be put into separate files and are passed via
the ``--lua-filter`` command-line argument. For example, if a filter is
defined in a file ``current-date.lua``, then it would be applied like
this:

::

   pandoc --lua-filter=current-date.lua -f markdown MANUAL.txt

The ``--lua-filter`` option may be supplied multiple times. Pandoc
applies all filters (including JSON filters specified via ``--filter``
and Lua filters specified via ``--lua-filter``) in the order they appear
on the command line.

Pandoc expects each Lua file to return a list of filters. The filters in
that list are called sequentially, each on the result of the previous
filter. If there is no value returned by the filter script, then pandoc
will try to generate a single filter by collecting all top-level
functions whose names correspond to those of pandoc elements (e.g.,
``Str``, ``Para``, ``Meta``, or ``Pandoc``). (That is why the two
examples above are equivalent.)

For each filter, the document is traversed and each element subjected to
the filter. Elements for which the filter contains an entry (i.e. a
function of the same name) are passed to Lua element filtering function.
In other words, filter entries will be called for each corresponding
element in the document, getting the respective element as input.

The return of a filter function must be one of the following:

-  nil: this means that the object should remain unchanged.
-  a pandoc object: this must be of the same type as the input and will
   replace the original object.
-  a list of pandoc objects: these will replace the original object; the
   list is merged with the neighbors of the original objects (spliced
   into the list the original object belongs to); returning an empty
   list deletes the object.

The function’s output must result in an element of the same type as the
input. This means a filter function acting on an inline element must
return either nil, an inline, or a list of inlines, and a function
filtering a block element must return one of nil, a block, or a list of
block elements. Pandoc will throw an error if this condition is
violated.

If there is no function matching the element’s node type, then the
filtering system will look for a more general fallback function. Two
fallback functions are supported, ``Inline`` and ``Block``. Each matches
elements of the respective type.

Elements without matching functions are left untouched.

See `module documentation`_ for a list of pandoc elements.

Filters on element sequences
----------------------------

For some filtering tasks, it is necessary to know the order in which
elements occur in the document. It is not enough then to inspect a
single element at a time.

There are two special function names, which can be used to define
filters on lists of blocks or lists of inlines.

``Inlines (inlines)``
   If present in a filter, this function will be called on all lists of
   inline elements, like the content of a `Para`_ (paragraph) block, or
   the description of an `Image`_. The ``inlines`` argument passed to
   the function will be a `List`_ of `Inlines`_ for each call.
``Blocks (blocks)``
   If present in a filter, this function will be called on all lists of
   block elements, like the content of a `MetaBlocks`_ meta element
   block, on each item of a list, and the main content of the `Pandoc`_
   document. The ``blocks`` argument passed to the function will be a
   `List`_ of `Blocks`_ for each call.

These filter functions are special in that the result must either be
nil, in which case the list is left unchanged, or must be a list of the
correct type, i.e., the same type as the input argument. Single elements
are **not** allowed as return values, as a single element in this
context usually hints at a bug.

See `“Remove spaces before normal citations”`_ for an example.

This functionality has been added in pandoc 2.9.2.

Execution Order
---------------

Element filter functions within a filter set are called in a fixed
order, skipping any which are not present:

1. functions for `Inline elements`_,
2. the ```Inlines```_ filter function,
3. functions for `Block elements`_ ,
4. the ```Blocks```_ filter function,
5. the ```Meta```_ filter function, and last
6. the ```Pandoc```_ filter function.

It is still possible to force a different order by explicitly returning
multiple filter sets. For example, if the filter for *Meta* is to be run
before that for *Str*, one can write

.. code:: lua

   -- ... filter definitions ...

   return {
     { Meta = Meta },  -- (1)
     { Str = Str }     -- (2)
   }

Filter sets are applied in the order in which they are returned. All
functions in set (1) are thus run before those in (2), causing the
filter function for *Meta* to be run before the filtering of *Str*
elements is started.

Global variables
----------------

Pandoc passes additional data to Lua filters by setting global
variables.

``FORMAT``
   The global ``FORMAT`` is set to the format of the pandoc writer being
   used (``html5``, ``latex``, etc.), so the behavior of a filter can be
   made conditional on the eventual output format.
``PANDOC_READER_OPTIONS``
   Table of the options which were provided to the parser.
``PANDOC_VERSION``
   Contains the pandoc version as a `Version`_ object which behaves like
   a numerically indexed table, most significant number first. E.g., for
   pandoc 2.7.3, the value of the variable is equivalent to a table
   ``{2, 7, 3}``. Use ``tostring(PANDOC_VERSION)`` to produce a version
   string. This variable is also set in custom writers.
``PANDOC_API_VERSION``
   Contains the version of the pandoc-types API against which pandoc was
   compiled. It is given as a numerically indexed table, most
   significant number first. E.g., if pandoc was compiled against
   pandoc-types 1.17.3, then the value of the variable will behave like
   the table ``{1, 17, 3}``. Use ``tostring(PANDOC_API_VERSION)`` to
   produce a version string. This variable is also set in custom
   writers.
``PANDOC_SCRIPT_FILE``
   The name used to involve the filter. This value can be used to find
   files relative to the script file. This variable is also set in
   custom writers.
``PANDOC_STATE``
   The state shared by all readers and writers. It is used by pandoc to
   collect and pass information. The value of this variable is of type
   `CommonState`_ and is read-only.

Pandoc Module
=============

The ``pandoc`` Lua module is loaded into the filter’s Lua environment
and provides a set of functions and constants to make creation and
manipulation of elements easier. The global variable ``pandoc`` is bound
to the module and should generally not be overwritten for this reason.

Two major functionalities are provided by the module: element creator
functions and access to some of pandoc’s main functionalities.

Element creation
----------------

Element creator functions like ``Str``, ``Para``, and ``Pandoc`` are
designed to allow easy creation of new elements that are simple to use
and can be read back from the Lua environment. Internally, pandoc uses
these functions to create the Lua objects which are passed to element
filter functions. This means that elements created via this module will
behave exactly as those elements accessible through the filter function
parameter.

Exposed pandoc functionality
----------------------------

Some pandoc functions have been made available in Lua:

-  ```walk_block```_ and ```walk_inline```_ allow filters to be applied
   inside specific block or inline elements;
-  ```read```_ allows filters to parse strings into pandoc documents;
-  ```pipe```_ runs an external command with input from and output to
   strings;
-  the ```pandoc.mediabag```_ module allows access to the “mediabag,”
   which stores binary content such as images that may be included in
   the final document;
-  the ```pandoc.utils```_ module contains various utility functions.

Lua interpreter initialization
==============================

Initialization of pandoc’s Lua interpreter can be controlled by placing
a file ``init.lua`` in pandoc’s data directory. A common use-case would
be to load additional modules, or even to alter default modules.

The following snippet is an example of code that might be useful when
added to ``init.lua``. The snippet adds all Unicode-aware functions
defined in the ```text`` module`_ to the default ``string`` module,
prefixed with the string ``uc_``.

.. code:: lua

   for name, fn in pairs(require 'text') do
     string['uc_' .. name] = fn
   end

This makes it possible to apply these functions on strings using colon
syntax (``mystring:uc_upper()``).

Debugging Lua filters
=====================

It is possible to use a debugging interface to halt execution and step
through a Lua filter line by line as it is run inside Pandoc. This is
accomplished using the remote-debugging interface of the package
```mobdebug```_. Although mobdebug can be run from the terminal, it is
more useful run within the donation-ware Lua editor and IDE,
`ZeroBrane`_. ZeroBrane offers a REPL console and UI to step-through and
view all variables and state.

If you already have Lua 5.3 installed, you can add
```mobdebug`` <https://luarocks.org/modules/paulclinger/mobdebug>`__ and
its dependency ```luasocket```_ using ```luarocks```_, which should then
be available on the path. ZeroBrane also includes both of these in its
package, so if you don’t want to install Lua separately, you should
add/modify your ``LUA_PATH`` and ``LUA_CPATH`` to include the correct
locations; `see detailed instructions here`_.

Examples
========

The following filters are presented as examples. A repository of useful
Lua filters (which may also serve as good examples) is available at
https://github.com/pandoc/lua-filters.

Macro substitution
------------------

The following filter converts the string ``{{helloworld}}`` into
emphasized text “Hello, World”.

.. code:: lua

   return {
     {
       Str = function (elem)
         if elem.text == "{{helloworld}}" then
           return pandoc.Emph {pandoc.Str "Hello, World"}
         else
           return elem
         end
       end,
     }
   }

Center images in LaTeX and HTML output
--------------------------------------

For LaTeX, wrap an image in LaTeX snippets which cause the image to be
centered horizontally. In HTML, the image element’s style attribute is
used to achieve centering.

.. code:: lua

   -- Filter images with this function if the target format is LaTeX.
   if FORMAT:match 'latex' then
     function Image (elem)
       -- Surround all images with image-centering raw LaTeX.
       return {
         pandoc.RawInline('latex', '\\hfill\\break{\\centering'),
         elem,
         pandoc.RawInline('latex', '\\par}')
       }
     end
   end

   -- Filter images with this function if the target format is HTML
   if FORMAT:match 'html' then
     function Image (elem)
       -- Use CSS style to center image
       elem.attributes.style = 'margin:auto; display: block;'
       return elem
     end
   end

Setting the date in the metadata
--------------------------------

This filter sets the date in the document’s metadata to the current
date, if a date isn’t already set:

.. code:: lua

   function Meta(m)
     if m.date == nil then
       m.date = os.date("%B %e, %Y")
       return m
     end
   end

Remove spaces before citations
------------------------------

This filter removes all spaces preceding an “author-in-text” citation.
In Markdown, author-in-text citations (e.g., ``@citekey``), must be
preceded by a space. If these spaces are undesired, they must be removed
with a filter.

.. code:: lua

   local function is_space_before_author_in_text(spc, cite)
     return spc and spc.t == 'Space'
       and cite and cite.t == 'Cite'
       -- there must be only a single citation, and it must have
       -- mode 'AuthorInText'
       and #cite.citations == 1
       and cite.citations[1].mode == 'AuthorInText'
   end

   function Inlines (inlines)
     -- Go from end to start to avoid problems with shifting indices.
     for i = #inlines-1, 1, -1 do
       if is_space_before_author_in_text(inlines[i], inlines[i+1]) then
         inlines:remove(i)
       end
     end
     return inlines
   end

Replacing placeholders with their metadata value
------------------------------------------------

Lua filter functions are run in the order

   *Inlines → Blocks → Meta → Pandoc*.

Passing information from a higher level (e.g., metadata) to a lower
level (e.g., inlines) is still possible by using two filters living in
the same file:

.. code:: lua

   local vars = {}

   function get_vars (meta)
     for k, v in pairs(meta) do
       if type(v) == 'table' and v.t == 'MetaInlines' then
         vars["%" .. k .. "%"] = {table.unpack(v)}
       end
     end
   end

   function replace (el)
     if vars[el.text] then
       return pandoc.Span(vars[el.text])
     else
       return el
     end
   end

   return {{Meta = get_vars}, {Str = replace}}

If the contents of file ``occupations.md`` is

.. code:: markdown

   ---
   name: Samuel Q. Smith
   occupation: Professor of Phrenology
   ---

   Name

   :   %name%

   Occupation

   :   %occupation%

then running ``pandoc --lua-filter=meta-vars.lua occupations.md`` will
output:

.. code:: html

   <dl>
   <dt>Name</dt>
   <dd><p><span>Samuel Q. Smith</span></p>
   </dd>
   <dt>Occupation</dt>
   <dd><p><span>Professor of Phrenology</span></p>
   </dd>
   </dl>

Modifying pandoc’s ``MANUAL.txt`` for man pages
-----------------------------------------------

This is the filter we use when converting ``MANUAL.txt`` to man pages.
It converts level-1 headers to uppercase (using ``walk_block`` to
transform inline elements inside headers), removes footnotes, and
replaces links with regular text.

.. code:: lua

   -- we use preloaded text to get a UTF-8 aware 'upper' function
   local text = require('text')

   function Header(el)
       if el.level == 1 then
         return pandoc.walk_block(el, {
           Str = function(el)
               return pandoc.Str(text.upper(el.text))
           end })
       end
   end

   function Link(el)
       return el.content
   end

   function Note(el)
       return {}
   end

Creating a handout from a paper
-------------------------------

This filter extracts all the numbered examples, section headers, block
quotes, and figures from a document, in addition to any divs with class
``handout``. (Note that only blocks at the “outer level” are included;
this ignores blocks inside nested constructs, like list items.)

.. code:: lua

   -- creates a handout from an article, using its headings,
   -- blockquotes, numbered examples, figures, and any
   -- Divs with class "handout"

   function Pandoc(doc)
       local hblocks = {}
       for i,el in pairs(doc.blocks) do
           if (el.t == "Div" and el.classes[1] == "handout") or
              (el.t == "BlockQuote") or
              (el.t == "OrderedList" and el.style == "Example") or
              (el.t == "Para" and #el.c == 1 and el.c[1].t == "Image") or
              (el.t == "Header") then
              table.insert(hblocks, el)
           end
       end
       return pandoc.Pandoc(hblocks, doc.meta)
   end

Counting words in a document
----------------------------

This filter counts the words in the body of a document (omitting
metadata like titles and abstracts), including words in code. It should
be more accurate than ``wc -w`` run directly on a Markdown document,
since the latter will count markup characters, like the ``#`` in front
of an ATX header, or tags in HTML documents, as words. To run it,
``pandoc --lua-filter wordcount.lua myfile.md``.

.. code:: lua

   -- counts words in a document

   words = 0

   wordcount = {
     Str = function(el)
       -- we don't count a word if it's entirely punctuation:
       if el.text:match("%P") then
           words = words + 1
       end
     end,

     Code = function(el)
       _,n = el.text:gsub("%S+","")
       words = words + n
     end,

     CodeBlock = function(el)
       _,n = el.text:gsub("%S+","")
       words = words + n
     end
   }

   function Pandoc(el)
       -- skip metadata, just count body:
       pandoc.walk_block(pandoc.Div(el.blocks), wordcount)
       print(words .. " words in body")
       os.exit(0)
   end

Converting ABC code to music notation
-------------------------------------

This filter replaces code blocks with class ``abc`` with images created
by running their contents through ``abcm2ps`` and ImageMagick’s
``convert``. (For more on ABC notation, see https://abcnotation.com.)

Images are added to the mediabag. For output to binary formats, pandoc
will use images in the mediabag. For textual formats, use
``--extract-media`` to specify a directory where the files in the
mediabag will be written, or (for HTML only) use ``--self-contained``.

.. code:: lua

   -- Pandoc filter to process code blocks with class "abc" containing
   -- ABC notation into images.
   --
   -- * Assumes that abcm2ps and ImageMagick's convert are in the path.
   -- * For textual output formats, use --extract-media=abc-images
   -- * For HTML formats, you may alternatively use --self-contained

   local filetypes = { html = {"png", "image/png"}
                     , latex = {"pdf", "application/pdf"}
                     }
   local filetype = filetypes[FORMAT][1] or "png"
   local mimetype = filetypes[FORMAT][2] or "image/png"

   local function abc2eps(abc, filetype)
       local eps = pandoc.pipe("abcm2ps", {"-q", "-O", "-", "-"}, abc)
       local final = pandoc.pipe("convert", {"-", filetype .. ":-"}, eps)
       return final
   end

   function CodeBlock(block)
       if block.classes[1] == "abc" then
           local img = abc2eps(block.text, filetype)
           local fname = pandoc.sha1(img) .. "." .. filetype
           pandoc.mediabag.insert(fname, mimetype, img)
           return pandoc.Para{ pandoc.Image({pandoc.Str("abc tune")}, fname) }
       end
   end

Building images with Ti\ *k*\ Z
-------------------------------

This filter converts raw LaTeX Ti\ *k*\ Z environments into images. It
works with both PDF and HTML output. The Ti\ *k*\ Z code is compiled to
an image using ``pdflatex``, and the image is converted from pdf to svg
format using ```pdf2svg```_, so both of these must be in the system
path. Converted images are cached in the working directory and given
filenames based on a hash of the source, so that they need not be
regenerated each time the document is built. (A more sophisticated
version of this might put these in a special cache directory.)

.. code:: lua

   local system = require 'pandoc.system'

   local tikz_doc_template = [[
   \documentclass{standalone}
   \usepackage{xcolor}
   \usepackage{tikz}
   \begin{document}
   \nopagecolor
   %s
   \end{document}
   ]]

   local function tikz2image(src, filetype, outfile)
     system.with_temporary_directory('tikz2image', function (tmpdir)
       system.with_working_directory(tmpdir, function()
         local f = io.open('tikz.tex', 'w')
         f:write(tikz_doc_template:format(src))
         f:close()
         os.execute('pdflatex tikz.tex')
         if filetype == 'pdf' then
           os.rename('tikz.pdf', outfile)
         else
           os.execute('pdf2svg tikz.pdf ' .. outfile)
         end
       end)
     end)
   end

   extension_for = {
     html = 'svg',
     html4 = 'svg',
     html5 = 'svg',
     latex = 'pdf',
     beamer = 'pdf' }

   local function file_exists(name)
     local f = io.open(name, 'r')
     if f ~= nil then
       io.close(f)
       return true
     else
       return false
     end
   end

   local function starts_with(start, str)
     return str:sub(1, #start) == start
   end


   function RawBlock(el)
     if starts_with('\\begin{tikzpicture}', el.text) then
       local filetype = extension_for[FORMAT] or 'svg'
       local fname = system.get_working_directory() .. '/' ..
           pandoc.sha1(el.text) .. '.' .. filetype
       if not file_exists(fname) then
         tikz2image(el.text, filetype, fname)
       end
       return pandoc.Para({pandoc.Image({}, fname)})
     else
      return el
     end
   end

Example of use:

::

   pandoc --lua-filter tikz.lua -s -o cycle.html <<EOF
   Here is a diagram of the cycle:

   \begin{tikzpicture}

   \def \n {5}
   \def \radius {3cm}
   \def \margin {8} % margin in angles, depends on the radius

   \foreach \s in {1,...,\n}
   {
     \node[draw, circle] at ({360/\n * (\s - 1)}:\radius) {$\s$};
     \draw[->, >=latex] ({360/\n * (\s - 1)+\margin}:\radius)
       arc ({360/\n * (\s - 1)+\margin}:{360/\n * (\s)-\margin}:\radius);
   }
   \end{tikzpicture}
   EOF

Lua type reference
==================

This section describes the types of objects available to Lua filters.
See the `pandoc module`_ for functions to create these objects.

Shared Properties
-----------------

``clone``
~~~~~~~~~

``clone ()``

All instances of the types listed here, with the exception of read-only
objects, can be cloned via the ``clone()`` method.

Usage:

::

   local emph = pandoc.Emph {pandoc.Str 'important'}
   local cloned_emph = emph:clone()  -- note the colon

.. _type-pandoc:

Pandoc
------

Pandoc document

Values of this type can be created with the ```pandoc.Pandoc```_
constructor. Object equality is determined via
```pandoc.utils.equals```_.

``blocks``
   document content (`List`_ of `Blocks`_)
``meta``
   document meta information (`Meta`_ object)

.. _type-meta:

Meta
----

Meta information on a document; string-indexed collection of
`MetaValues`_.

Values of this type can be created with the ```pandoc.Meta```_
constructor. Object equality is determined via
```pandoc.utils.equals```_.

.. _type-metavalue:

MetaValue
---------

Document meta information items.

Object equality is determined via ```pandoc.utils.equals```_.

.. _type-metablocks:

MetaBlocks
~~~~~~~~~~

A list of blocks usable as meta value (`List`_ of `Blocks`_).

Fields:

``tag``, ``t``
   the literal ``MetaBlocks`` (string)

.. _type-metabool:

MetaBool
~~~~~~~~

Alias for Lua boolean, i.e. the values ``true`` and ``false``.

.. _type-metainlines:

MetaInlines
~~~~~~~~~~~

List of inlines used in metadata (`List`_ of `Inlines`_)

Values of this type can be created with the ```pandoc.MetaInlines```_
constructor.

Fields:

``tag``, ``t``
   the literal ``MetaInlines`` (string)

.. _type-metalist:

MetaList
~~~~~~~~

A list of other metadata values (`List`_ of `MetaValues`_).

Values of this type can be created with the ```pandoc.MetaList```_
constructor.

Fields:

``tag``, ``t``
   the literal ``MetaList`` (string)

All methods available for `List`_\ s can be used on this type as well.

.. _type-metamap:

MetaMap
~~~~~~~

A string-indexed map of meta-values. (table).

Values of this type can be created with the ```pandoc.MetaMap```_
constructor.

Fields:

``tag``, ``t``
   the literal ``MetaMap`` (string)

*Note*: The fields will be shadowed if the map contains a field with the
same name as those listed.

.. _type-metastring:

MetaString
~~~~~~~~~~

Plain Lua string value (string).

.. _type-block:

Block
-----

Object equality is determined via ```pandoc.utils.equals```_.

.. _type-blockquote:

BlockQuote
~~~~~~~~~~

A block quote element.

Values of this type can be created with the ```pandoc.BlockQuote```_
constructor.

Fields:

``content``:
   block content (`List`_ of `Blocks`_)
``tag``, ``t``
   the literal ``BlockQuote`` (string)

.. _type-bulletlist:

BulletList
~~~~~~~~~~

A bullet list.

Values of this type can be created with the ```pandoc.BulletList```_
constructor.

Fields:

``content``
   list items (`List`_ of `List`_ of `Blocks`_)
``tag``, ``t``
   the literal ``BulletList`` (string)

.. _type-codeblock:

CodeBlock
~~~~~~~~~

Block of code.

Values of this type can be created with the ```pandoc.CodeBlock```_
constructor.

Fields:

``text``
   code string (string)
``attr``
   element attributes (`Attr`_)
``identifier``
   alias for ``attr.identifier`` (string)
``classes``
   alias for ``attr.classes`` (`List`_ of strings)
``attributes``
   alias for ``attr.attributes`` (`Attributes`_)
``tag``, ``t``
   the literal ``CodeBlock`` (string)

.. _type-definitionlist:

DefinitionList
~~~~~~~~~~~~~~

Definition list, containing terms and their explanation.

Values of this type can be created with the ```pandoc.DefinitionList```_
constructor.

Fields:

``content``
   list of items
``tag``, ``t``
   the literal ``DefinitionList`` (string)

.. _type-div:

Div
~~~

Generic block container with attributes.

Values of this type can be created with the ```pandoc.Div```_
constructor.

Fields:

``content``
   block content (`List`_ of `Blocks`_)
``attr``
   element attributes (`Attr`_)
``identifier``
   alias for ``attr.identifier`` (string)
``classes``
   alias for ``attr.classes`` (`List`_ of strings)
``attributes``
   alias for ``attr.attributes`` (`Attributes`_)
``tag``, ``t``
   the literal ``Div`` (string)

.. _type-header:

Header
~~~~~~

Creates a header element.

Values of this type can be created with the ```pandoc.Header```_
constructor.

Fields:

``level``
   header level (integer)
``content``
   inline content (`List`_ of `Inlines`_)
``attr``
   element attributes (`Attr`_)
``identifier``
   alias for ``attr.identifier`` (string)
``classes``
   alias for ``attr.classes`` (`List`_ of strings)
``attributes``
   alias for ``attr.attributes`` (`Attributes`_)
``tag``, ``t``
   the literal ``Header`` (string)

.. _type-horizontalrule:

HorizontalRule
~~~~~~~~~~~~~~

A horizontal rule.

Values of this type can be created with the ```pandoc.HorizontalRule```_
constructor.

Fields:

``tag``, ``t``
   the literal ``HorizontalRule`` (string)

.. _type-lineblock:

LineBlock
~~~~~~~~~

A line block, i.e. a list of lines, each separated from the next by a
newline.

Values of this type can be created with the ```pandoc.LineBlock```_
constructor.

Fields:

``content``
   inline content
``tag``, ``t``
   the literal ``LineBlock`` (string)

.. _type-null:

Null
~~~~

A null element; this element never produces any output in the target
format.

Values of this type can be created with the ```pandoc.Null```_
constructor.

``tag``, ``t``
   the literal ``Null`` (string)

.. _type-orderedlist:

OrderedList
~~~~~~~~~~~

An ordered list.

Values of this type can be created with the ```pandoc.OrderedList```_
constructor.

Fields:

``content``
   list items (`List`_ of `List`_ of `Blocks`_)
``listAttributes``
   list parameters (`ListAttributes`_)
``start``
   alias for ``listAttributes.start`` (integer)
``style``
   alias for ``listAttributes.style`` (string)
``delimiter``
   alias for ``listAttributes.delimiter`` (string)
``tag``, ``t``
   the literal ``OrderedList`` (string)

.. _type-para:

Para
~~~~

A paragraph.

Values of this type can be created with the ```pandoc.Para```_
constructor.

Fields:

``content``
   inline content (`List`_ of `Inlines`_)
``tag``, ``t``
   the literal ``Para`` (string)

.. _type-plain:

Plain
~~~~~

Plain text, not a paragraph.

Values of this type can be created with the ```pandoc.Plain```_
constructor.

Fields:

``content``
   inline content (`List`_ of `Inlines`_)
``tag``, ``t``
   the literal ``Plain`` (string)

.. _type-rawblock:

RawBlock
~~~~~~~~

Raw content of a specified format.

Values of this type can be created with the ```pandoc.RawBlock```_
constructor.

Fields:

``format``
   format of content (string)
``text``
   raw content (string)
``tag``, ``t``
   the literal ``RawBlock`` (string)

.. _type-table:

Table
~~~~~

A table.

Values of this type can be created with the ```pandoc.Table```_
constructor.

Fields:

``attr``
   table attributes (`Attr`_)
``caption``
   table caption (`Caption`_)
``colspecs``
   column specifications, i.e., alignments and widths (`List`_ of
   `ColSpec`_\ s)
``head``
   table head (`TableHead`_)
``bodies``
   table bodies (`List`_ of `TableBody`_\ s)
``foot``
   table foot (`TableFoot`_)
``identifier``
   alias for ``attr.identifier`` (string)
``classes``
   alias for ``attr.classes`` (`List`_ of strings)
``attributes``
   alias for ``attr.attributes`` (`Attributes`_)
``tag``, ``t``
   the literal ``Table`` (string)

A table cell is a list of blocks.

*Alignment* is a string value indicating the horizontal alignment of a
table column. ``AlignLeft``, ``AlignRight``, and ``AlignCenter`` leads
cell content to be left-aligned, right-aligned, and centered,
respectively. The default alignment is ``AlignDefault`` (often
equivalent to centered).

.. _type-inline:

Inline
------

Object equality is determined via ```pandoc.utils.equals```_.

.. _type-cite:

Cite
~~~~

Citation.

Values of this type can be created with the ```pandoc.Cite```_
constructor.

Fields:

``content``
   (`List`_ of `Inlines`_)
``citations``
   citation entries (`List`_ of `Citations`_)
``tag``, ``t``
   the literal ``Cite`` (string)

.. _type-code:

Code
~~~~

Inline code

Values of this type can be created with the ```pandoc.Code```_
constructor.

Fields:

``text``
   code string (string)
``attr``
   attributes (`Attr`_)
``identifier``
   alias for ``attr.identifier`` (string)
``classes``
   alias for ``attr.classes`` (`List`_ of strings)
``attributes``
   alias for ``attr.attributes`` (`Attributes`_)
``tag``, ``t``
   the literal ``Code`` (string)

.. _type-emph:

Emph
~~~~

Emphasized text

Values of this type can be created with the ```pandoc.Emph```_
constructor.

Fields:

``content``
   inline content (`List`_ of `Inlines`_)
``tag``, ``t``
   the literal ``Emph`` (string)

.. _type-image:

Image
~~~~~

Image: alt text (list of inlines), target

Values of this type can be created with the ```pandoc.Image```_
constructor.

Fields:

``attr``
   attributes (`Attr`_)
``caption``
   text used to describe the image (`List`_ of `Inlines`_)
``src``
   path to the image file (string)
``title``
   brief image description
``identifier``
   alias for ``attr.identifier`` (string)
``classes``
   alias for ``attr.classes`` (`List`_ of strings)
``attributes``
   alias for ``attr.attributes`` (`Attributes`_)
``tag``, ``t``
   the literal ``Image`` (string)

.. _type-linebreak:

LineBreak
~~~~~~~~~

Hard line break

Values of this type can be created with the ```pandoc.LineBreak```_
constructor.

Fields:

``tag``, ``t``
   the literal ``LineBreak`` (string)

.. _type-link:

Link
~~~~

Hyperlink: alt text (list of inlines), target

Values of this type can be created with the ```pandoc.Link```_
constructor.

Fields:

``attr``
   attributes (`Attr`_)
``content``
   text for this link (`List`_ of `Inlines`_)
``target``
   the link target (string)
``title``
   brief link description
``identifier``
   alias for ``attr.identifier`` (string)
``classes``
   alias for ``attr.classes`` (`List`_ of strings)
``attributes``
   alias for ``attr.attributes`` (`Attributes`_)
``tag``, ``t``
   the literal ``Link`` (string)

.. _type-math:

Math
~~~~

TeX math (literal)

Values of this type can be created with the ```pandoc.Math```_
constructor.

Fields:

``mathtype``
   specifier determining whether the math content should be shown inline
   (``InlineMath``) or on a separate line (``DisplayMath``) (string)
``text``
   math content (string)
``tag``, ``t``
   the literal ``Math`` (string)

.. _type-note:

Note
~~~~

Footnote or endnote

Values of this type can be created with the ```pandoc.Note```_
constructor.

Fields:

``content``
   (`List`_ of `Blocks`_)
``tag``, ``t``
   the literal ``Note`` (string)

.. _type-quoted:

Quoted
~~~~~~

Quoted text

Values of this type can be created with the ```pandoc.Quoted```_
constructor.

Fields:

``quotetype``
   type of quotes to be used; one of ``SingleQuote`` or ``DoubleQuote``
   (string)
``content``
   quoted text (`List`_ of `Inlines`_)
``tag``, ``t``
   the literal ``Quoted`` (string)

.. _type-rawinline:

RawInline
~~~~~~~~~

Raw inline

Values of this type can be created with the ```pandoc.RawInline```_
constructor.

Fields:

``format``
   the format of the content (string)
``text``
   raw content (string)
``tag``, ``t``
   the literal ``RawInline`` (string)

.. _type-smallcaps:

SmallCaps
~~~~~~~~~

Small caps text

Values of this type can be created with the ```pandoc.SmallCaps```_
constructor.

Fields:

``content``
   (`List`_ of `Inlines`_)
``tag``, ``t``
   the literal ``SmallCaps`` (string)

.. _type-softbreak:

SoftBreak
~~~~~~~~~

Soft line break

Values of this type can be created with the ```pandoc.SoftBreak```_
constructor.

Fields:

``tag``, ``t``
   the literal ``SoftBreak`` (string)

.. _type-space:

Space
~~~~~

Inter-word space

Values of this type can be created with the ```pandoc.Space```_
constructor.

Fields:

``tag``, ``t``
   the literal ``Space`` (string)

.. _type-span:

Span
~~~~

Generic inline container with attributes

Values of this type can be created with the ```pandoc.Span```_
constructor.

Fields:

``attr``
   attributes (`Attr`_)
``content``
   wrapped content (`List`_ of `Inlines`_)
``identifier``
   alias for ``attr.identifier`` (string)
``classes``
   alias for ``attr.classes`` (`List`_ of strings)
``attributes``
   alias for ``attr.attributes`` (`Attributes`_)
``tag``, ``t``
   the literal ``Span`` (string)

.. _type-str:

Str
~~~

Text

Values of this type can be created with the ```pandoc.Str```_
constructor.

Fields:

``text``
   content (string)
``tag``, ``t``
   the literal ``Str`` (string)

.. _type-strikeout:

Strikeout
~~~~~~~~~

Strikeout text

Values of this type can be created with the ```pandoc.Strikeout```_
constructor.

Fields:

``content``
   inline content (`List`_ of `Inlines`_)
``tag``, ``t``
   the literal ``Strikeout`` (string)

.. _type-strong:

Strong
~~~~~~

Strongly emphasized text

Values of this type can be created with the ```pandoc.Strong```_
constructor.

Fields:

``content``
   inline content (`List`_ of `Inlines`_)
``tag``, ``t``
   the literal ``Strong`` (string)

.. _type-subscript:

Subscript
~~~~~~~~~

Subscripted text

Values of this type can be created with the ```pandoc.Subscript```_
constructor.

Fields:

``content``
   inline content (`List`_ of `Inlines`_)
``tag``, ``t``
   the literal ``Subscript`` (string)

.. _type-superscript:

Superscript
~~~~~~~~~~~

Superscripted text

Values of this type can be created with the ```pandoc.Superscript```_
constructor.

Fields:

``content``
   inline content (`List`_ of `Inlines`_)
``tag``, ``t``
   the literal ``Superscript`` (string)

.. _type-underline:

Underline
~~~~~~~~~

Underlined text

Values of this type can be created with the ```pandoc.Underline```_
constructor.

Fields:

``content``
   inline content (`List`_ of `Inlines`_)
``tag``, ``t``
   the literal ``Underline`` (string)

Element components
------------------

.. _type-attr:

Attr
~~~~

A set of element attributes. Values of this type can be created with the
```pandoc.Attr```_ constructor. For convenience, it is usually not
necessary to construct the value directly if it is part of an element,
and it is sufficient to pass an HTML-like table. E.g., to create a span
with identifier “text” and classes “a” and “b”, one can write:

::

   local span = pandoc.Span('text', {id = 'text', class = 'a b'})

This also works when using the ``attr`` setter:

::

   local span = pandoc.Span 'text'
   span.attr = {id = 'text', class = 'a b', other_attribute = '1'}

Object equality is determined via ```pandoc.utils.equals```_.

Fields:

``identifier``
   element identifier (string)
``classes``
   element classes (`List`_ of strings)
``attributes``
   collection of key/value pairs (`Attributes`_)

.. _type-attributes:

Attributes
~~~~~~~~~~

List of key/value pairs. Values can be accessed by using keys as indices
to the list table.

.. _type-caption:

Caption
~~~~~~~

The caption of a table, with an optional short caption.

Fields:

``long``
   long caption (list of `Blocks`_)
``short``
   short caption (list of `Inlines`_)

.. _type-cell:

Cell
~~~~

A table cell.

Fields:

``attr``
   cell attributes
``alignment``
   individual cell alignment (`Alignment`_).
``contents``
   cell contents (list of `Blocks`_).
``col_span``
   number of columns occupied by the cell; the height of the cell
   (integer).
``row_span``
   number of rows occupied by the cell; the height of the cell
   (integer).

.. _type-citation:

Citation
~~~~~~~~

Single citation entry

Values of this type can be created with the ```pandoc.Citation```_
constructor.

Object equality is determined via ```pandoc.utils.equals```_.

Fields:

``id``
   citation identifier, e.g., a bibtex key (string)
``mode``
   citation mode, one of ``AuthorInText``, ``SuppressAuthor``, or
   ``NormalCitation`` (string)
``prefix``
   citation prefix (`List`_ of `Inlines`_)
``suffix``
   citation suffix (`List`_ of `Inlines`_)
``note_num``
   note number (integer)
``hash``
   hash (integer)

.. _type-colspec:

ColSpec
~~~~~~~

Column alignment and width specification for a single table column.

This is a pair with the following components:

1. cell alignment (`Alignment`_).
2. table column width, as a fraction of the total table width (number).

.. _type-listattributes:

ListAttributes
~~~~~~~~~~~~~~

List attributes

Values of this type can be created with the ```pandoc.ListAttributes```_
constructor.

Object equality is determined via ```pandoc.utils.equals```_.

Fields:

``start``
   number of the first list item (integer)
``style``
   style used for list numbers; possible values are ``DefaultStyle``,
   ``Example``, ``Decimal``, ``LowerRoman``, ``UpperRoman``,
   ``LowerAlpha``, and ``UpperAlpha`` (string)
``delimiter``
   delimiter of list numbers; one of ``DefaultDelim``, ``Period``,
   ``OneParen``, and ``TwoParens`` (string)

.. _type-row:

Row
~~~

A table row.

Tuple fields:

1. row attributes
2. row cells (list of `Cells`_)

.. _type-tablebody:

TableBody
~~~~~~~~~

A body of a table, with an intermediate head and the specified number of
row header columns.

Fields:

``attr``
   table body attributes (`Attr`_)
``body``
   table body rows (list of `Rows`_)
``head``
   intermediate head (list of `Rows`_)
``row_head_columns``
   number of columns taken up by the row head of each row of a
   `TableBody`_. The row body takes up the remaining columns.

.. _type-tablefoot:

TableFoot
~~~~~~~~~

The foot of a table.

This is a pair with the following components:

1. attributes
2. foot rows (`Rows`_)

.. _type-tablehead:

TableHead
~~~~~~~~~

The head of a table.

This is a pair with the following components:

1. attributes
2. head rows (`Rows`_)

.. _type-readeroptions:

ReaderOptions
-------------

Pandoc reader options

Fields:

``abbreviations``
   set of known abbreviations (set of strings)
``columns``
   number of columns in terminal (integer)
``default_image_extension``
   default extension for images (string)
``extensions``
   string representation of the syntax extensions bit field (string)
``indented_code_classes``
   default classes for indented code blocks (list of strings)
``standalone``
   whether the input was a standalone document with header (boolean)
``strip_comments``
   HTML comments are stripped instead of parsed as raw HTML (boolean)
``tab_stop``
   width (i.e. equivalent number of spaces) of tab stops (integer)
``track_changes``
   track changes setting for docx; one of ``AcceptChanges``,
   ``RejectChanges``, and ``AllChanges`` (string)

.. _type-commonstate:

CommonState
-----------

The state used by pandoc to collect information and make it available to
readers and writers.

Fields:

``input_files``
   List of input files from command line (`List`_ of strings)
``output_file``
   Output file from command line (string or nil)
``log``
   A list of log messages in reverse order (`List`_ of `LogMessage`_\ s)
``request_headers``
   Headers to add for HTTP requests; table with header names as keys and
   header contents as value (table)
``resource_path``
   Path to search for resources like included images (`List`_ of
   strings)
``source_url``
   Absolute URL or directory of first source file (string or nil)
``user_data_dir``
   Directory to search for data files (string or nil)
``trace``
   Whether tracing messages are issued (boolean)
``verbosity``
   Verbosity level; one of ``INFO``, ``WARNING``, ``ERROR`` (string)

.. _type-list:

List
----

A list is any Lua table with integer indices. Indices start at one, so
if ``alist = {'value'}`` then ``alist[1] == 'value'``.

Lists, when part of an element, or when generated during marshaling, are
made instances of the ``pandoc.List`` type for convenience. The
``pandoc.List`` type is defined in the `pandoc.List`_ module. See there
for available methods.

Values of this type can be created with the ```pandoc.List```_
constructor, turning a normal Lua table into a List.

.. _type-logmessage:

LogMessage
----------

A pandoc log message. Objects have no fields, but can be converted to a
string via ``tostring``.

.. _type-simpletable:

SimpleTable
-----------

A simple table is a table structure which resembles the old (pre pandoc
2.10) Table type. Bi-directional conversion from and to `Tables`_ is
possible with the ```pandoc.utils.to_simple_table```_ and
```pandoc.utils.from_simple_table```_ function, respectively. Instances
of this type can also be created directly with the
```pandoc.SimpleTable```_ constructor.

Fields:

``caption``:
   `List`_ of `Inlines`_
``aligns``:
   column alignments (`List`_ of `Alignments`_)
``widths``:
   column widths; a (`List`_ of numbers)
``headers``:
   table header row (`List`_ of lists of `Blocks`_)
``rows``:
   table rows (`List`_ of rows, where a row is a list of lists of
   `Blocks`_)

.. _type-version:

Version
-------

A version object. This represents a software version like “2.7.3”. The
object behaves like a numerically indexed table, i.e., if ``version``
represents the version ``2.7.3``, then

::

   version[1] == 2
   version[2] == 7
   version[3] == 3
   #version == 3   -- length

Comparisons are performed element-wise, i.e.

::

   Version '1.12' > Version '1.9'

Values of this type can be created with the ```pandoc.types.Version```_
constructor.

``must_be_at_least``
~~~~~~~~~~~~~~~~~~~~

``must_be_at_least(actual, expected [, error_message])``

Raise an error message if the actual version is older than the expected
version; does nothing if actual is equal to or newer than the expected
version.

Parameters:

``actual``
   actual version specifier (`Version`_)
``expected``
   minimum expected version (`Version`_)
``error_message``
   optional error message template. The string is used as format string,
   with the expected and actual versions as arguments. Defaults to
   ``"expected version %s or newer, got %s"``.

Usage:

::

   PANDOC_VERSION:must_be_at_least '2.7.3'
   PANDOC_API_VERSION:must_be_at_least(
     '1.17.4',
     'pandoc-types is too old: expected version %s, got %s'
   )

Module text
===========

UTF-8 aware text manipulation functions, implemented in Haskell. The
module is made available as part of the ``pandoc`` module via
``pandoc.text``. The text module can also be loaded explicitly:

.. code:: lua

   -- uppercase all regular text in a document:
   text = require 'text'
   function Str (s)
     s.text = text.upper(s.text)
     return s
   end

.. _text.lower:

lower
~~~~~

``lower (s)``

Returns a copy of a UTF-8 string, converted to lowercase.

.. _text.upper:

upper
~~~~~

``upper (s)``

Returns a copy of a UTF-8 string, converted to uppercase.

.. _text.reverse:

reverse
~~~~~~~

``reverse (s)``

Returns a copy of a UTF-8 string, with characters reversed.

.. _text.len:

len
~~~

``len (s)``

Returns the length of a UTF-8 string.

.. _text.sub:

sub
~~~

``sub (s)``

Returns a substring of a UTF-8 string, using Lua’s string indexing
rules.

Module pandoc
=============

Lua functions for pandoc scripts; includes constructors for document
tree elements, functions to parse text in a given format, and functions
to filter and modify a subtree.

Pandoc
------

``Pandoc (blocks[, meta])``
   A complete pandoc document

   Parameters:

   ``blocks``:
      document content
   ``meta``:
      document meta data

   Returns: `Pandoc`_ object

Meta
----

``Meta (table)``
   Create a new Meta object.

   Parameters:

   ``table``:
      table containing document meta information

   Returns: `Meta`_ object

MetaValue
---------

``MetaBlocks (blocks)``
   Meta blocks

   Parameters:

   ``blocks``:
      blocks

   Returns: `MetaBlocks`_ object

``MetaInlines (inlines)``
   Meta inlines

   Parameters:

   ``inlines``:
      inlines

   Returns: `MetaInlines`_ object

``MetaList (meta_values)``
   Meta list

   Parameters:

   ``meta_values``:
      list of meta values

   Returns: `MetaList`_ object

``MetaMap (key_value_map)``
   Meta map

   Parameters:

   ``key_value_map``:
      a string-indexed map of meta values

   Returns: `MetaMap`_ object

``MetaString (str)``
   Creates string to be used in meta data.

   Parameters:

   ``str``:
      string value

   Returns: `MetaString`_ object

``MetaBool (bool)``
   Creates boolean to be used in meta data.

   Parameters:

   ``bool``:
      boolean value

   Returns: `MetaBool`_ object

Blocks
------

``BlockQuote (content)``
   Creates a block quote element

   Parameters:

   ``content``:
      block content

   Returns: `BlockQuote`_ object

``BulletList (items)``
   Creates a bullet list.

   Parameters:

   ``items``:
      list items

   Returns: `BulletList`_ object

``CodeBlock (text[, attr])``
   Creates a code block element

   Parameters:

   ``text``:
      code string
   ``attr``:
      element attributes

   Returns: `CodeBlock`_ object

``DefinitionList (content)``
   Creates a definition list, containing terms and their explanation.

   Parameters:

   ``content``:
      list of items

   Returns: `DefinitionList`_ object

``Div (content[, attr])``
   Creates a div element

   Parameters:

   ``content``:
      block content
   ``attr``:
      element attributes

   Returns: `Div`_ object

``Header (level, content[, attr])``
   Creates a header element.

   Parameters:

   ``level``:
      header level
   ``content``:
      inline content
   ``attr``:
      element attributes

   Returns: `Header`_ object

``HorizontalRule ()``
   Creates a horizontal rule.

   Returns: `HorizontalRule`_ object

``LineBlock (content)``
   Creates a line block element.

   Parameters:

   ``content``:
      inline content

   Returns: `LineBlock`_ object

``Null ()``
   Creates a null element.

   Returns: `Null`_ object

``OrderedList (items[, listAttributes])``
   Creates an ordered list.

   Parameters:

   ``items``:
      list items
   ``listAttributes``:
      list parameters

   Returns: `OrderedList`_ object

``Para (content)``
   Creates a para element.

   Parameters:

   ``content``:
      inline content

   Returns: `Para`_ object

``Plain (content)``
   Creates a plain element.

   Parameters:

   ``content``:
      inline content

   Returns: `Plain`_ object

``RawBlock (format, text)``
   Creates a raw content block of the specified format.

   Parameters:

   ``format``:
      format of content
   ``text``:
      string content

   Returns: `RawBlock`_ object

``Table (caption, colspecs, head, bodies, foot[, attr])``
   Creates a table element.

   Parameters:

   ``caption``:
      table `caption`_
   ``colspecs``:
      column alignments and widths (list of `ColSpec`_\ s)
   ``head``:
      `table head`_
   ``bodies``:
      `table bodies`_
   ``foot``:
      `table foot`_
   ``attr``:
      element attributes

   Returns: `Table`_ object

Inline
------

``Cite (content, citations)``
   Creates a Cite inline element

   Parameters:

   ``content``:
      List of inlines
   ``citations``:
      List of citations

   Returns: `Cite`_ object

``Code (text[, attr])``
   Creates a Code inline element

   Parameters:

   ``text``:
      code string
   ``attr``:
      additional attributes

   Returns: `Code`_ object

``Emph (content)``
   Creates an inline element representing emphasized text.

   Parameters:

   ``content``:
      inline content

   Returns: `Emph`_ object

``Image (caption, src[, title[, attr]])``
   Creates a Image inline element

   Parameters:

   ``caption``:
      text used to describe the image
   ``src``:
      path to the image file
   ``title``:
      brief image description
   ``attr``:
      additional attributes

   Returns: `Image`_ object

``LineBreak ()``
   Create a LineBreak inline element

   Returns: `LineBreak`_ object

``Link (content, target[, title[, attr]])``
   Creates a link inline element, usually a hyperlink.

   Parameters:

   ``content``:
      text for this link
   ``target``:
      the link target
   ``title``:
      brief link description
   ``attr``:
      additional attributes

   Returns: `Link`_ object

``Math (mathtype, text)``
   Creates a Math element, either inline or displayed.

   Parameters:

   ``mathtype``:
      rendering specifier
   ``text``:
      Math content

   Returns: `Math`_ object

``DisplayMath (text)``
   Creates a math element of type “DisplayMath” (DEPRECATED).

   Parameters:

   ``text``:
      Math content

   Returns: `Math`_ object

``InlineMath (text)``
   Creates a math element of type “InlineMath” (DEPRECATED).

   Parameters:

   ``text``:
      Math content

   Returns: `Math`_ object

``Note (content)``
   Creates a Note inline element

   Parameters:

   ``content``:
      footnote block content

   Returns: `Note`_ object

``Quoted (quotetype, content)``
   Creates a Quoted inline element given the quote type and quoted
   content.

   Parameters:

   ``quotetype``:
      type of quotes to be used
   ``content``:
      inline content

   Returns: `Quoted`_ object

``SingleQuoted (content)``
   Creates a single-quoted inline element (DEPRECATED).

   Parameters:

   ``content``:
      inline content

   Returns: `Quoted`_

``DoubleQuoted (content)``
   Creates a single-quoted inline element (DEPRECATED).

   Parameters:

   ``content``:
      inline content

   Returns: `Quoted`_

``RawInline (format, text)``
   Creates a raw inline element

   Parameters:

   ``format``:
      format of the contents
   ``text``:
      string content

   Returns: `RawInline`_ object

``SmallCaps (content)``
   Creates text rendered in small caps

   Parameters:

   ``content``:
      inline content

   Returns: `SmallCaps`_ object

``SoftBreak ()``
   Creates a SoftBreak inline element.

   Returns: `SoftBreak`_ object

``Space ()``
   Create a Space inline element

   Returns: `Space`_ object

``Span (content[, attr])``
   Creates a Span inline element

   Parameters:

   ``content``:
      inline content
   ``attr``:
      additional attributes

   Returns: `Span`_ object

``Str (text)``
   Creates a Str inline element

   Parameters:

   ``text``:
      content

   Returns: `Str`_ object

``Strikeout (content)``
   Creates text which is struck out.

   Parameters:

   ``content``:
      inline content

   Returns: `Strikeout`_ object

``Strong (content)``
   Creates a Strong element, whose text is usually displayed in a bold
   font.

   Parameters:

   ``content``:
      inline content

   Returns: `Strong`_ object

``Subscript (content)``
   Creates a Subscript inline element

   Parameters:

   ``content``:
      inline content

   Returns: `Subscript`_ object

``Superscript (content)``
   Creates a Superscript inline element

   Parameters:

   ``content``:
      inline content

   Returns: `Superscript`_ object

``Underline (content)``
   Creates an Underline inline element

   Parameters:

   ``content``:
      inline content

   Returns: `Underline`_ object

.. _element-components-1:

Element components
------------------

``Attr ([identifier[, classes[, attributes]]])``
   Create a new set of attributes (Attr).

   Parameters:

   ``identifier``:
      element identifier
   ``classes``:
      element classes
   ``attributes``:
      table containing string keys and values

   Returns: `Attr`_ object

``Citation (id, mode[, prefix[, suffix[, note_num[, hash]]]])``
   Creates a single citation.

   Parameters:

   ``id``:
      citation identifier (like a bibtex key)
   ``mode``:
      citation mode
   ``prefix``:
      citation prefix
   ``suffix``:
      citation suffix
   ``note_num``:
      note number
   ``hash``:
      hash number

   Returns: `Citation`_ object

``ListAttributes ([start[, style[, delimiter]]])``
   Creates a set of list attributes.

   Parameters:

   ``start``:
      number of the first list item
   ``style``:
      style used for list numbering
   ``delimiter``:
      delimiter of list numbers

   Returns: `ListAttributes`_ object

Legacy types
------------

``SimpleTable (caption, aligns, widths, headers, rows)``
   Creates a simple table resembling the old (pre pandoc 2.10) table
   type.

   Parameters:

   ``caption``:
      `List`_ of `Inlines`_
   ``aligns``:
      column alignments (`List`_ of `Alignments`_)
   ``widths``:
      column widths; a (`List`_ of numbers)
   ``headers``:
      table header row (`List`_ of lists of `Blocks`_)
   ``rows``:
      table rows (`List`_ of rows, where a row is a list of lists of
      `Blocks`_)

   Returns: `SimpleTable`_ object

   Usage:

   ::

      local caption = "Overview"
      local aligns = {pandoc.AlignDefault, pandoc.AlignDefault}
      local widths = {0, 0} -- let pandoc determine col widths
      local headers = {{pandoc.Plain({pandoc.Str "Language"})},
                       {pandoc.Plain({pandoc.Str "Typing"})}}
      local rows = {
        {{pandoc.Plain "Haskell"}, {pandoc.Plain "static"}},
        {{pandoc.Plain "Lua"}, {pandoc.Plain "Dynamic"}},
      }
      simple_table = pandoc.SimpleTable(
        caption,
        aligns,
        widths,
        headers,
        rows
      )

Constants
---------

``AuthorInText``
   Author name is mentioned in the text.

   See also: `Citation`_

``SuppressAuthor``
   Author name is suppressed.

   See also: `Citation`_

``NormalCitation``
   Default citation style is used.

   See also: `Citation`_

``AlignLeft``
   Table cells aligned left.

   See also: `Table <#type-alignment>`__

``AlignRight``
   Table cells right-aligned.

   See also: `Table <#type-alignment>`__

``AlignCenter``
   Table cell content is centered.

   See also: `Table <#type-alignment>`__

``AlignDefault``
   Table cells are alignment is unaltered.

   See also: `Table <#type-alignment>`__

``DefaultDelim``
   Default list number delimiters are used.

   See also: `ListAttributes`_

``Period``
   List numbers are delimited by a period.

   See also: `ListAttributes`_

``OneParen``
   List numbers are delimited by a single parenthesis.

   See also: `ListAttributes`_

``TwoParens``
   List numbers are delimited by a double parentheses.

   See also: `ListAttributes`_

``DefaultStyle``
   List are numbered in the default style

   See also: `ListAttributes`_

``Example``
   List items are numbered as examples.

   See also: `ListAttributes`_

``Decimal``
   List are numbered using decimal integers.

   See also: `ListAttributes`_

``LowerRoman``
   List are numbered using lower-case roman numerals.

   See also: `ListAttributes`_

``UpperRoman``
   List are numbered using upper-case roman numerals

   See also: `ListAttributes`_

``LowerAlpha``
   List are numbered using lower-case alphabetic characters.

   See also: `ListAttributes`_

``UpperAlpha``
   List are numbered using upper-case alphabetic characters.

   See also: `ListAttributes`_

``sha1``
   Alias for ```pandoc.utils.sha1```_ (DEPRECATED).

Helper functions
----------------

.. _pandoc.pipe:

pipe
~~~~

``pipe (command, args, input)``

Runs command with arguments, passing it some input, and returns the
output.

Parameters:

``command``
   program to run; the executable will be resolved using default system
   methods (string).
``args``
   list of arguments to pass to the program (list of strings).
``input``
   data which is piped into the program via stdin (string).

Returns:

-  Output of command, i.e. data printed to stdout (string)

Raises:

-  A table containing the keys ``command``, ``error_code``, and
   ``output`` is thrown if the command exits with a non-zero error code.

Usage:

::

   local output = pandoc.pipe("sed", {"-e","s/a/b/"}, "abc")

.. _pandoc.walk_block:

walk_block
~~~~~~~~~~

``walk_block (element, filter)``

Apply a filter inside a block element, walking its contents.

Parameters:

``element``:
   the block element
``filter``:
   a Lua filter (table of functions) to be applied within the block
   element

Returns: the transformed block element

.. _pandoc.walk_inline:

walk_inline
~~~~~~~~~~~

``walk_inline (element, filter)``

Apply a filter inside an inline element, walking its contents.

Parameters:

``element``:
   the inline element
``filter``:
   a Lua filter (table of functions) to be applied within the inline
   element

Returns: the transformed inline element

.. _pandoc.read:

read
~~~~

``read (markup[, format])``

Parse the given string into a Pandoc document.

Parameters:

``markup``:
   the markup to be parsed
``format``:
   format specification, defaults to ``"markdown"``.

Returns: pandoc document

Usage:

::

   local org_markup = "/emphasis/"  -- Input to be read
   local document = pandoc.read(org_markup, "org")
   -- Get the first block of the document
   local block = document.blocks[1]
   -- The inline element in that block is an `Emph`
   assert(block.content[1].t == "Emph")

Module pandoc.utils
===================

This module exposes internal pandoc functions and utility functions.

The module is loaded as part of the ``pandoc`` module and available as
``pandoc.utils``. In versions up-to and including pandoc 2.6, this
module had to be loaded explicitly. Example:

::

   pandoc.utils = require 'pandoc.utils'

Use the above for backwards compatibility.

.. _pandoc.utils.blocks_to_inlines:

blocks_to_inlines
~~~~~~~~~~~~~~~~~

``blocks_to_inlines (blocks[, sep])``

Squash a list of blocks into a list of inlines.

Parameters:

``blocks``:
   List of `Blocks`_ to be flattened.
``sep``:
   List of `Inlines`_ inserted as separator between two consecutive
   blocks; defaults to
   ``{ pandoc.Space(), pandoc.Str'¶', pandoc.Space()}``.

Returns:

-  `List`_ of `Inlines`_

Usage:

::

   local blocks = {
     pandoc.Para{ pandoc.Str 'Paragraph1' },
     pandoc.Para{ pandoc.Emph 'Paragraph2' }
   }
   local inlines = pandoc.utils.blocks_to_inlines(blocks)
   -- inlines = {
   --   pandoc.Str 'Paragraph1',
   --   pandoc.Space(), pandoc.Str'¶', pandoc.Space(),
   --   pandoc.Emph{ pandoc.Str 'Paragraph2' }
   -- }

.. _pandoc.utils.equals:

equals
~~~~~~

``equals (element1, element2)``

Test equality of AST elements. Elements in Lua are considered equal if
and only if the objects obtained by unmarshaling are equal.

Parameters:

``element1``, ``element2``:
   Objects to be compared. Acceptable input types are `Pandoc`_,
   `Meta`_, `MetaValue`_, `Block`_, `Inline`_, `Attr`_,
   `ListAttributes`_, and `Citation`_.

Returns:

-  Whether the two objects represent the same element (boolean)

.. _pandoc.utils.from_simple_table:

from_simple_table
~~~~~~~~~~~~~~~~~

``from_simple_table (table)``

Creates a `Table`_ block element from a `SimpleTable`_. This is useful
for dealing with legacy code which was written for pandoc versions older
than 2.10.

Returns:

-  table block element (`Table`_)

Usage:

::

   local simple = pandoc.SimpleTable(table)
   -- modify, using pre pandoc 2.10 methods
   simple.caption = pandoc.SmallCaps(simple.caption)
   -- create normal table block again
   table = pandoc.utils.from_simple_table(simple)

.. _pandoc.utils.make_sections:

make_sections
~~~~~~~~~~~~~

``make_sections (number_sections, base_level, blocks)``

Converts list of `Blocks`_ into sections. ``Div``\ s will be created
beginning at each ``Header`` and containing following content until the
next ``Header`` of comparable level. If ``number_sections`` is true, a
``number`` attribute will be added to each ``Header`` containing the
section number. If ``base_level`` is non-null, ``Header`` levels will be
reorganized so that there are no gaps, and so that the base level is the
level specified.

Returns:

-  List of `Blocks`_.

Usage:

::

   local blocks = {
     pandoc.Header(2, pandoc.Str 'first'),
     pandoc.Header(2, pandoc.Str 'second'),
   }
   local newblocks = pandoc.utils.make_sections(true, 1, blocks)

.. _pandoc.utils.run_json_filter:

run_json_filter
~~~~~~~~~~~~~~~

``run_json_filter (doc, filter[, args])``

Filter the given doc by passing it through the a JSON filter.

Parameters:

``doc``:
   the Pandoc document to filter
``filter``:
   filter to run
``args``:
   list of arguments passed to the filter. Defaults to ``{FORMAT}``.

Returns:

-  (`Pandoc`_) Filtered document

Usage:

::

   -- Assumes `some_blocks` contains blocks for which a
   -- separate literature section is required.
   local sub_doc = pandoc.Pandoc(some_blocks, metadata)
   sub_doc_with_bib = pandoc.utils.run_json_filter(
     sub_doc,
     'pandoc-citeproc'
   )
   some_blocks = sub_doc.blocks -- some blocks with bib

.. _pandoc.utils.normalize_date:

normalize_date
~~~~~~~~~~~~~~

``normalize_date (date_string)``

Parse a date and convert (if possible) to “YYYY-MM-DD” format. We limit
years to the range 1601-9999 (ISO 8601 accepts greater than or equal to
1583, but MS Word only accepts dates starting 1601).

Returns:

-  A date string, or nil when the conversion failed.

.. _pandoc.utils.sha1:

sha1
~~~~

``sha1 (contents)``

Returns the SHA1 has of the contents.

Returns:

-  SHA1 hash of the contents.

Usage:

::

   local fp = pandoc.utils.sha1("foobar")

.. _pandoc.utils.stringify:

stringify
~~~~~~~~~

``stringify (element)``

Converts the given element (Pandoc, Meta, Block, or Inline) into a
string with all formatting removed.

Returns:

-  A plain string representation of the given element.

Usage:

::

   local inline = pandoc.Emph{pandoc.Str 'Moin'}
   -- outputs "Moin"
   print(pandoc.utils.stringify(inline))

.. _pandoc.utils.to_roman_numeral:

to_roman_numeral
~~~~~~~~~~~~~~~~

``to_roman_numeral (integer)``

Converts an integer < 4000 to uppercase roman numeral.

Returns:

-  A roman numeral string.

Usage:

::

   local to_roman_numeral = pandoc.utils.to_roman_numeral
   local pandoc_birth_year = to_roman_numeral(2006)
   -- pandoc_birth_year == 'MMVI'

.. _pandoc.utils.to_simple_table:

to_simple_table
~~~~~~~~~~~~~~~

``to_simple_table (table)``

Creates a `SimpleTable`_ out of a `Table`_ block.

Returns:

-  a simple table object (`SimpleTable`_)

Usage:

::

   local simple = pandoc.utils.to_simple_table(table)
   -- modify, using pre pandoc 2.10 methods
   simple.caption = pandoc.SmallCaps(simple.caption)
   -- create normal table block again
   table = pandoc.utils.from_simple_table(simple)

Module pandoc.mediabag
======================

The ``pandoc.mediabag`` module allows accessing pandoc’s media storage.
The “media bag” is used when pandoc is called with the
``--extract-media`` or (for HTML only) ``--self-contained`` option.

The module is loaded as part of module ``pandoc`` and can either be
accessed via the ``pandoc.mediabag`` field, or explicitly required,
e.g.:

::

   local mb = require 'pandoc.mediabag'

.. _pandoc.mediabag.delete:

delete
~~~~~~

``delete (filepath)``

Removes a single entry from the media bag.

Parameters:

``filepath``:
   filename of the item to be deleted. The media bag will be left
   unchanged if no entry with the given filename exists.

.. _pandoc.mediabag.empty:

empty
~~~~~

``empty ()``

Clear-out the media bag, deleting all items.

.. _pandoc.mediabag.insert:

insert
~~~~~~

``insert (filepath, mime_type, contents)``

Adds a new entry to pandoc’s media bag. Replaces any existing mediabag
entry with the same ``filepath``.

Parameters:

``filepath``:
   filename and path relative to the output folder.
``mime_type``:
   the file’s MIME type; use ``nil`` if unknown or unavailable.
``contents``:
   the binary contents of the file.

Usage:

::

   local fp = "media/hello.txt"
   local mt = "text/plain"
   local contents = "Hello, World!"
   pandoc.mediabag.insert(fp, mt, contents)

.. _pandoc.mediabag.items:

items
~~~~~

``items ()``

Returns an iterator triple to be used with Lua’s generic ``for``
statement. The iterator returns the filepath, MIME type, and content of
a media bag item on each invocation. Items are processed one-by-one to
avoid excessive memory use.

This function should be used only when full access to all items,
including their contents, is required. For all other cases, ```list```_
should be preferred.

Returns:

-  The iterator function; must be called with the iterator state and the
   current iterator value.
-  Iterator state – an opaque value to be passed to the iterator
   function.
-  Initial iterator value.

Usage:

::

   for fp, mt, contents in pandoc.mediabag.items() do
     -- print(fp, mt, contents)
   end

.. _pandoc.mediabag.list:

list
~~~~

``list ()``

Get a summary of the current media bag contents.

Returns: A list of elements summarizing each entry in the media bag. The
summary item contains the keys ``path``, ``type``, and ``length``,
giving the filepath, MIME type, and length of contents in bytes,
respectively.

Usage:

::

   -- calculate the size of the media bag.
   local mb_items = pandoc.mediabag.list()
   local sum = 0
   for i = 1, #mb_items do
       sum = sum + mb_items[i].length
   end
   print(sum)

.. _pandoc.mediabag.lookup:

lookup
~~~~~~

``lookup (filepath)``

Lookup a media item in the media bag, and return its MIME type and
contents.

Parameters:

``filepath``:
   name of the file to look up.

Returns:

-  the entry’s MIME type, or nil if the file was not found.
-  contents of the file, or nil if the file was not found.

Usage:

::

   local filename = "media/diagram.png"
   local mt, contents = pandoc.mediabag.lookup(filename)

.. _pandoc.mediabag.fetch:

fetch
~~~~~

``fetch (source)``

Fetches the given source from a URL or local file. Returns two values:
the contents of the file and the MIME type (or an empty string).

The function will first try to retrieve ``source`` from the mediabag; if
that fails, it will try to download it or read it from the local file
system while respecting pandoc’s “resource path” setting.

Parameters:

``source``:
   path to a resource; either a local file path or URI

Returns:

-  the entries MIME type, or nil if the file was not found.
-  contents of the file, or nil if the file was not found.

Usage:

::

   local diagram_url = "https://pandoc.org/diagram.jpg"
   local mt, contents = pandoc.mediabag.fetch(diagram_url)

Module pandoc.List
==================

This module defines pandoc’s list type. It comes with useful methods and
convenience functions.

Constructor
-----------

``pandoc.List([table])``
   Create a new List. If the optional argument ``table`` is given, set
   the metatable of that value to ``pandoc.List``. This is an alias for
   ```pandoc.List:new([table])```_.

Metamethods
-----------

``pandoc.List:__concat (list)``
   Concatenates two lists.

   Parameters:

   ``list``:
      second list concatenated to the first

   Returns: a new list containing all elements from list1 and list2

Methods
-------

``pandoc.List:clone ()``
   Returns a (shallow) copy of the list.

``pandoc.List:extend (list)``
   Adds the given list to the end of this list.

   Parameters:

   ``list``:
      list to appended

``pandoc.List:find (needle, init)``
   Returns the value and index of the first occurrence of the given
   item.

   Parameters:

   ``needle``:
      item to search for
   ``init``:
      index at which the search is started

   Returns: first item equal to the needle, or nil if no such item
   exists.

``pandoc.List:find_if (pred, init)``
   Returns the value and index of the first element for which the
   predicate holds true.

   Parameters:

   ``pred``:
      the predicate function
   ``init``:
      index at which the search is started

   Returns: first item for which \`test\` succeeds, or nil if no such
   item exists.

``pandoc.List:filter (pred)``
   Returns a new list containing all items satisfying a given condition.

   Parameters:

   ``pred``:
      condition items must satisfy.

   Returns: a new list containing all items for which \`test\` was true.

``pandoc.List:includes (needle, init)``
   Checks if the list has an item equal to the given needle.

   Parameters:

   ``needle``:
      item to search for
   ``init``:
      index at which the search is started

   Returns: true if a list item is equal to the needle, false otherwise

``pandoc.List:insert ([pos], value)``
   Inserts element ``value`` at position ``pos`` in list, shifting
   elements to the next-greater index if necessary.

   This function is identical to ```table.insert```_.

   Parameters:

   ``pos``:
      index of the new value; defaults to length of the list + 1
   ``value``:
      value to insert into the list

``pandoc.List:map (fn)``
   Returns a copy of the current list by applying the given function to
   all elements.

   Parameters:

   ``fn``:
      function which is applied to all list items.

``pandoc.List:new([table])``
   Create a new List. If the optional argument ``table`` is given, set
   the metatable of that value to ``pandoc.List``.

   Parameters:

   ``table``:
      table which should be treatable as a list; defaults to an empty
      table

   Returns: the updated input value

``pandoc.List:remove ([pos])``
   Removes the element at position ``pos``, returning the value of the
   removed element.

   This function is identical to ```table.remove```_.

   Parameters:

   ``pos``:
      position of the list value that will be removed; defaults to the
      index of the last element

   Returns: the removed element

``pandoc.List:sort ([comp])``
   Sorts list elements in a given order, in-place. If ``comp`` is given,
   then it must be a function that receives two list elements and
   returns true when the first element must come before the second in
   the final order (so that, after the sort, ``i < j`` implies
   ``not comp(list[j],list[i]))``. If comp is not given, then the
   standard Lua operator ``<`` is used instead.

   Note that the comp function must define a strict partial order over
   the elements in the list; that is, it must be asymmetric and
   transitive. Otherwise, no valid sort may be possible.

   The sort algorithm is not stable: elements considered equal by the
   given order may have their relative positions changed by the sort.

   This function is identical to ```table.sort```_.

   Parameters:

   ``comp``:
      Comparison function as described above.

Module pandoc.path
==================

Module for file path manipulations.

.. _pandoc.path-fields:

Static Fields
-------------

.. _pandoc.path.separator:

separator
~~~~~~~~~

The character that separates directories.

.. _pandoc.path.search_path_separator:

search_path_separator
~~~~~~~~~~~~~~~~~~~~~

The character that is used to separate the entries in the ``PATH``
environment variable.

.. _pandoc.path-functions:

Functions
---------

.. _pandoc.path.directory:

directory (filepath)
~~~~~~~~~~~~~~~~~~~~

Gets the directory name, i.e., removes the last directory separator and
everything after from the given path.

Parameters:

filepath
   path (string)

Returns:

-  The filepath up to the last directory separator. (string)

.. _pandoc.path.filename:

filename (filepath)
~~~~~~~~~~~~~~~~~~~

Get the file name.

Parameters:

filepath
   path (string)

Returns:

-  File name part of the input path. (string)

.. _pandoc.path.is_absolute:

is_absolute (filepath)
~~~~~~~~~~~~~~~~~~~~~~

Checks whether a path is absolute, i.e. not fixed to a root.

Parameters:

filepath
   path (string)

Returns:

-  ``true`` iff ``filepath`` is an absolute path, ``false`` otherwise.
   (boolean)

.. _pandoc.path.is_relative:

is_relative (filepath)
~~~~~~~~~~~~~~~~~~~~~~

Checks whether a path is relative or fixed to a root.

Parameters:

filepath
   path (string)

Returns:

-  ``true`` iff ``filepath`` is a relative path, ``false`` otherwise.
   (boolean)

.. _pandoc.path.join:

join (filepaths)
~~~~~~~~~~~~~~~~

Join path elements back together by the directory separator.

Parameters:

filepaths
   path components (list of strings)

Returns:

-  The joined path. (string)

.. _pandoc.path.make_relative:

make_relative (path, root[, unsafe])
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Contract a filename, based on a relative path. Note that the resulting
path will usually not introduce ``..`` paths, as the presence of
symlinks means ``../b`` may not reach ``a/b`` if it starts from ``a/c``.
For a worked example see `this blog post`_.

Set ``unsafe`` to a truthy value to a allow ``..`` in paths.

Parameters:

path
   path to be made relative (string)
root
   root path (string)
unsafe
   whether to allow ``..`` in the result. (boolean)

Returns:

-  contracted filename (string)

.. _pandoc.path.normalize:

normalize (filepath)
~~~~~~~~~~~~~~~~~~~~

Normalizes a path.

-  ``//`` makes sense only as part of a (Windows) network drive;
   elsewhere, multiple slashes are reduced to a single
   ``path.separator`` (platform dependent).
-  ``/`` becomes ``path.separator`` (platform dependent)
-  ``./`` -> ’’
-  an empty path becomes ``.``

Parameters:

filepath
   path (string)

Returns:

-  The normalized path. (string)

.. _pandoc.path.split:

split (filepath)
~~~~~~~~~~~~~~~~

Splits a path by the directory separator.

Parameters:

filepath
   path (string)

Returns:

-  List of all path components. (list of strings)

.. _pandoc.path.split_extension:

split_extension (filepath)
~~~~~~~~~~~~~~~~~~~~~~~~~~

Splits the last extension from a file path and returns the parts. The
extension, if present, includes the leading separator; if the path has
no extension, then the empty string is returned as the extension.

Parameters:

filepath
   path (string)

Returns:

-  filepath without extension (string)

-  extension or empty string (string)

.. _pandoc.path.split_search_path:

split_search_path (search_path)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Takes a string and splits it on the ``search_path_separator`` character.
Blank items are ignored on Windows, and converted to ``.`` on Posix. On
Windows path elements are stripped of quotes.

Parameters:

search_path
   platform-specific search path (string)

Returns:

-  list of directories in search path (list of strings)

Module pandoc.system
====================

Access to system information and functionality.

Static Fields
-------------

.. _pandoc.system.arch:

arch
~~~~

The machine architecture on which the program is running.

.. _pandoc.system.os:

os
~~

The operating system on which the program is running.

Functions
---------

.. _pandoc.system.environment:

environment
~~~~~~~~~~~

``environment ()``

Retrieve the entire environment as a string-indexed table.

Returns:

-  A table mapping environment variables names to their string value
   (table).

.. _pandoc.system.get_working_directory:

get_working_directory
~~~~~~~~~~~~~~~~~~~~~

``get_working_directory ()``

Obtain the current working directory as an absolute path.

Returns:

-  The current working directory (string).

.. _pandoc.system.with_environment:

with_environment
~~~~~~~~~~~~~~~~

``with_environment (environment, callback)``

Run an action within a custom environment. Only the environment
variables given by ``environment`` will be set, when ``callback`` is
called. The original environment is restored after this function
finishes, even if an error occurs while running the callback action.

Parameters:

``environment``
   Environment variables and their values to be set before running
   ``callback``. (table with string keys and string values)
``callback``
   Action to execute in the custom environment (function)

Returns:

-  The result(s) of the call to ``callback``

.. _pandoc.system.with_temporary_directory:

with_temporary_directory
~~~~~~~~~~~~~~~~~~~~~~~~

``with_temporary_directory ([parent_dir,] templ, callback)``

Create and use a temporary directory inside the given directory. The
directory is deleted after the callback returns.

Parameters:

``parent_dir``
   Parent directory to create the directory in (string). If this
   parameter is omitted, the system’s canonical temporary directory is
   used.
``templ``
   Directory name template (string).
``callback``
   Function which takes the name of the temporary directory as its first
   argument (function).

Returns:

-  The result of the call to ``callback``.

.. _pandoc.system.with_working_directory:

with_working_directory
~~~~~~~~~~~~~~~~~~~~~~

``with_working_directory (directory, callback)``

Run an action within a different directory. This function will change
the working directory to ``directory``, execute ``callback``, then
switch back to the original working directory, even if an error occurs
while running the callback action.

Parameters:

``directory``
   Directory in which the given ``callback`` should be executed (string)
``callback``
   Action to execute in the given directory (function)

Returns:

-  The result(s) of the call to ``callback``

Module pandoc.types
===================

Constructors for types which are not part of the pandoc AST.

.. _pandoc.types.version:

Version
~~~~~~~

``Version (version_specifier)``

Creates a Version object.

Parameters:

``version_specifier``:
   Version specifier: this can be a version string like ``'2.7.3'``, a
   list of integers like ``{2, 7, 3}``, a single integer, or a
   `Version`_.

Returns:

-  A new `Version`_ object.

.. _Traditional pandoc filters: https://pandoc.org/filters.html
.. _module documentation: #module-pandoc
.. _Para: #type-para
.. _Image: #type-image
.. _List: #type-list
.. _Inlines: #type-inline
.. _MetaBlocks: #type-metablocks
.. _Pandoc: #type-pandoc
.. _Blocks: #type-block
.. _“Remove spaces before normal citations”: #remove-spaces-before-citations
.. _Inline elements: #type-inline
.. _``Inlines``: #inlines-filter
.. _Block elements: #type-block
.. _``Blocks``: #inlines-filter
.. _``Meta``: #type-meta
.. _``Pandoc``: #type-pandoc
.. _Version: #type-version
.. _CommonState: #type-commonstate
.. _``walk_block``: #pandoc.walk_block
.. _``walk_inline``: #pandoc.walk_inline
.. _``read``: #pandoc.read
.. _``pipe``: #pandoc.pipe
.. _``pandoc.mediabag``: #module-pandoc.mediabag
.. _``pandoc.utils``: #module-pandoc.utils
.. _``text`` module: #module-text
.. _``mobdebug``: https://github.com/pkulchenko/MobDebug
.. _ZeroBrane: https://studio.zerobrane.com/
.. _``luasocket``: https://luarocks.org/modules/luasocket/luasocket
.. _``luarocks``: https://luarocks.org
.. _see detailed instructions here: https://studio.zerobrane.com/doc-remote-debugging
.. _``pdf2svg``: https://github.com/dawbarton/pdf2svg
.. _pandoc module: #module-pandoc
.. _``pandoc.Pandoc``: #pandoc.pandoc
.. _``pandoc.utils.equals``: #pandoc.utils.equals
.. _Meta: #type-meta
.. _MetaValues: #type-metavalue
.. _``pandoc.Meta``: #pandoc.meta
.. _``pandoc.MetaInlines``: #pandoc.metainlines
.. _``pandoc.MetaList``: #pandoc.metalist
.. _``pandoc.MetaMap``: #pandoc.metamap
.. _``pandoc.BlockQuote``: #pandoc.blockquote
.. _``pandoc.BulletList``: #pandoc.bulletlist
.. _``pandoc.CodeBlock``: #pandoc.codeblock
.. _Attr: #type-attr
.. _Attributes: #type-attributes
.. _``pandoc.DefinitionList``: #pandoc.definitionlist
.. _``pandoc.Div``: #pandoc.div
.. _``pandoc.Header``: #pandoc.header
.. _``pandoc.HorizontalRule``: #pandoc.horizontalrule
.. _``pandoc.LineBlock``: #pandoc.lineblock
.. _``pandoc.Null``: #pandoc.null
.. _``pandoc.OrderedList``: #pandoc.orderedlist
.. _ListAttributes: #type-listattributes
.. _``pandoc.Para``: #pandoc.para
.. _``pandoc.Plain``: #pandoc.plain
.. _``pandoc.RawBlock``: #pandoc.rawblock
.. _``pandoc.Table``: #pandoc.table
.. _Caption: #type-caption
.. _ColSpec: #type-colspec
.. _TableHead: #type-tablehead
.. _TableBody: #type-tablebody
.. _TableFoot: #type-tablefoot
.. _``pandoc.Cite``: #pandoc.cite
.. _Citations: #type-citation
.. _``pandoc.Code``: #pandoc.code
.. _``pandoc.Emph``: #pandoc.emph
.. _``pandoc.Image``: #pandoc.image
.. _``pandoc.LineBreak``: #pandoc.linebreak
.. _``pandoc.Link``: #pandoc.link
.. _``pandoc.Math``: #pandoc.math
.. _``pandoc.Note``: #pandoc.note
.. _``pandoc.Quoted``: #pandoc.quoted
.. _``pandoc.RawInline``: #pandoc.rawinline
.. _``pandoc.SmallCaps``: #pandoc.smallcaps
.. _``pandoc.SoftBreak``: #pandoc.softbreak
.. _``pandoc.Space``: #pandoc.space
.. _``pandoc.Span``: #pandoc.span
.. _``pandoc.Str``: #pandoc.str
.. _``pandoc.Strikeout``: #pandoc.strikeout
.. _``pandoc.Strong``: #pandoc.strong
.. _``pandoc.Subscript``: #pandoc.subscript
.. _``pandoc.Superscript``: #pandoc.superscript
.. _``pandoc.Underline``: #pandoc.underline
.. _``pandoc.Attr``: #pandoc.attr
.. _Alignment: #type-alignment
.. _``pandoc.Citation``: #pandoc.citation
.. _``pandoc.ListAttributes``: #pandoc.listattributes
.. _Cells: #type-cell
.. _Rows: #type-row
.. _LogMessage: #type-logmessage
.. _pandoc.List: #module-pandoc.list
.. _``pandoc.List``: #pandoc.list
.. _Tables: #type-table
.. _``pandoc.utils.to_simple_table``: #pandoc.utils.to_simple_table
.. _``pandoc.utils.from_simple_table``: #pandoc.utils.from_simple_table
.. _``pandoc.SimpleTable``: #pandoc.simpletable
.. _Alignments: #type-alignment
.. _``pandoc.types.Version``: #pandoc.types.version
.. _MetaInlines: #type-metainlines
.. _MetaList: #type-metalist
.. _MetaMap: #type-metamap
.. _MetaString: #type-metastring
.. _MetaBool: #type-metabool
.. _BlockQuote: #type-blockquote
.. _BulletList: #type-bulletlist
.. _CodeBlock: #type-codeblock
.. _DefinitionList: #type-definitionlist
.. _Div: #type-div
.. _Header: #type-header
.. _HorizontalRule: #type-horizontalrule
.. _LineBlock: #type-lineblock
.. _Null: #type-null
.. _OrderedList: #type-orderedlist
.. _Plain: #type-plain
.. _RawBlock: #type-rawblock
.. _caption: #type-caption
.. _table head: #type-tablehead
.. _table bodies: #type-tablebody
.. _table foot: #type-tablefoot
.. _Table: #type-table
.. _Cite: #type-cite
.. _Code: #type-code
.. _Emph: #type-emph
.. _LineBreak: #type-linebreak
.. _Link: #type-link
.. _Math: #type-math
.. _Note: #type-note
.. _Quoted: #type-quoted
.. _RawInline: #type-rawinline
.. _SmallCaps: #type-smallcaps
.. _SoftBreak: #type-softbreak
.. _Space: #type-space
.. _Span: #type-span
.. _Str: #type-str
.. _Strikeout: #type-strikeout
.. _Strong: #type-strong
.. _Subscript: #type-subscript
.. _Superscript: #type-superscript
.. _Underline: #type-underline
.. _Citation: #type-citation
.. _SimpleTable: #type-simpletable
.. _``pandoc.utils.sha1``: #pandoc.utils.sha1
.. _MetaValue: #type-metavalue
.. _Block: #type-block
.. _Inline: #type-inline
.. _``list``: #pandoc.mediabag.list
.. _```pandoc.List:new([table])```: #pandoc.list:new
.. _``table.insert``: https://www.lua.org/manual/5.3/manual.html#6.6
.. _``table.remove``: https://www.lua.org/manual/5.3/manual.html#6.6
.. _``table.sort``: https://www.lua.org/manual/5.3/manual.html#6.6
.. _this blog post: https://neilmitchell.blogspot.co.uk/2015/10/filepaths-are-subtle-symlinks-are-hard.html
