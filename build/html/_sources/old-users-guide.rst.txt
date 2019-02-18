==========================================
（旧）Pandocユーザーズガイド 日本語版
==========================================

注意：これは古いバージョン（1.12.4.2）のPandocユーザーズガイドを訳したものです。

原著：John MacFarlane

原著バージョン：1.12.4.2

翻訳：Yuki Fujiwara（2014年6月27日）

書式
====

pandoc [*options*] [*input-file*]…

説明
====

Pandocは `Haskell <http://www.haskell.org/>`__
で書かれたライブラリおよびコマンドラインツールであり、
あるマークアップ形式で書かれた文書を別の形式へ変換するものです。

対応している入力形式は以下の通りです：

-  `markdown <http://daringfireball.net/projects/markdown/>`__
-  `Textile <http://redcloth.org/textile>`__ （のサブセット、以下同様）
-  `reStructuredText <http://docutils.sourceforge.net/docs/ref/rst/introduction.html>`__
-  `HTML <http://www.w3.org/TR/html40/>`__
-  `LaTeX <http://www.latex-project.org/>`__
-  `MediaWiki markup <http://www.mediawiki.org/wiki/Help:Formatting>`__
-  `Haddock
   markup <http://www.haskell.org/haddock/doc/html/ch03s08.html>`__
-  `OPML <http://dev.opml.org/spec2.html>`__
-  `Emacs Org-mode <http://orgmode.org>`__
-  `DocBook <http://www.docbook.org/>`__

出力形式は以下の通りです：

-  プレーンテキスト
-  `markdown <http://daringfireball.net/projects/markdown/>`__
-  `reStructuredText <http://docutils.sourceforge.net/docs/ref/rst/introduction.html>`__
-  `XHTML <http://www.w3.org/TR/xhtml1/>`__
-  `HTML 5 <http://www.w3.org/TR/html5/>`__
-  `LaTeX <http://www.latex-project.org/>`__
   （\ `beamer <http://www.tex.ac.uk/CTAN/macros/latex/contrib/beamer>`__\ スライドショーを含む）
-  `ConTeXt <http://www.pragma-ade.nl/>`__
-  `RTF <http://en.wikipedia.org/wiki/Rich_Text_Format>`__
-  `OPML <http://dev.opml.org/spec2.html>`__
-  `DocBook <http://www.docbook.org/>`__
-  `OpenDocument <http://opendocument.xml.org/>`__
-  `ODT <http://en.wikipedia.org/wiki/OpenDocument>`__
-  `Word
   docx <http://www.microsoft.com/interop/openup/openxml/default.aspx>`__
-  `GNU Texinfo <http://www.gnu.org/software/texinfo/>`__
-  `MediaWiki markup <http://www.mediawiki.org/wiki/Help:Formatting>`__
-  `EPUB <http://www.idpf.org/>`__ (v2またはv3)
-  `FictionBook2 <http://www.fictionbook.org/index.php/Eng:XML_Schema_Fictionbook_2.1>`__
-  `Textile <http://redcloth.org/textile>`__
-  `groff
   man <http://developer.apple.com/DOCUMENTATION/Darwin/Reference/ManPages/man7/groff_man.7.html>`__\ ページ
-  `Emacs Org-Mode <http://orgmode.org>`__
-  `AsciiDoc <http://www.methods.co.nz/asciidoc/>`__
-  `InDesign
   ICML <https://www.adobe.com/content/dam/Adobe/en/devnet/indesign/cs55-docs/IDML/idml-specification.pdf>`__
-  HTMLスライドショー：\ `Slidy <http://www.w3.org/Talks/Tools/Slidy/>`__\ 、\ `Slideous <http://goessner.net/articles/slideous/>`__\ 、\ `DZSlides <http://paulrouget.com/dzslides/>`__\ 、\ `reveal.js <http://lab.hakim.se/reveal-js/>`__\ 、\ `S5 <http://meyerweb.com/eric/tools/s5/>`__
-  PDF出力（LaTeXがインストールされているシステムで使用できます）

Pandocによる拡張Markdown書式は以下を含みます：脚注、表、柔軟な順序付きリスト、
定義リスト、囲まれた(fenced)コードブロック、上付き文字、下付き文字、取り消し線、
タイトルブロック、目次の自動作成、LaTeX数式の埋め込み、引用、HTMLブロック要素のMarkdownへの埋め込み。
（これらの拡張については、以下の
`Pandocによる拡張Markdown <#pandocs-markdown>`__ にて説明されます。
また、これらの拡張は入力および出力形式として\ ``markdown_strict``\ を与えることで無効にできます。）

HTMLからMarkdownに変換する多くのツールが正規表現による置換を使っているのに対して、
Pandocはモジュール式のデザインで構成されています。
Pandocは、与えられた形式のテキストを解析してHaskell
Native形式に変換するReader、 およびHaskell
Native形式をターゲットの出力形式に変換するWriterで構成されており、
これらは各々の入力・出力形式ごとに存在します。
つまり、入力または出力形式を追加するには、ReaderまたはWriterを追加するだけでよいのです。

``pandoc`` の使い方
-------------------

入力ファイルとして\ *input-file*\ が指定されていない場合は、
入力として標準入力 *stdin* が指定されます。
*input-file*\ が指定されている場合は、それを入力とします。（ファイルを複数とることも可能です。）

出力ファイルはデフォルトで標準出力 *stdout* に出力されます。
（ただし出力フォーマットが\ ``odt``\ 、\ ``docx``\ 、\ ``epub``\ 、\ ``epub3``\ の場合は、標準出力への出力が無効となります。）
ファイルへ出力したい場合は、\ ``-o``\ オプションを使用してください：

::

   pandoc -o output.html input.txt

ファイルの代わりに、絶対パスのURIを指定することもできます。
この場合、PandocはHTTPを用いてコンテンツを取得します。

::

   pandoc -f html -t markdown http://www.fsf.org

複数の\ *input-file*\ が指定されている場合、Pandocは解析の前に、各入力ファイルを結合してその間に空行を挿入します。

入力および出力フォーマットはオプションを用いて明示的に指定できます。
入力フォーマットは\ ``-r/--read``\ または\ ``-f/--from``\ により、
出力フォーマットは\ ``-w/--write``\ または\ ``-t/--to``\ により指定できます。
例えば、LaTeXファイルの\ ``hello.txt``\ を入力とし、Markdownに出力する場合は、以下のようなコマンドを実行します：

::

   pandoc -f markdown -t latex hello.txt

HTMLファイルの\ ``hello.html``\ をMarkdownに変換する場合はこのようにします：

::

   pandoc -f html -t markdown hello.html

サポートされている出力フォーマットについては、後の\ ``-t/--to``\ オプションの項で、
入力フォーマットについては、\ ``-f/--from``\ オプションの項でリストアップします。
注意：\ ``rst``\ 、\ ``textile``\ 、\ ``latex``\ 、\ ``html``\ のReaderはそれぞれのフォーマットを
完全にサポートしません。これらの文書の要素には、無視されるものがあります。

入力または出力フォーマットが明示されていない場合、
Pandocはファイル名の拡張子から入力・出力フォーマットを推測しようとします。
例えば、

::

   pandoc -o hello.tex hello.txt

は\ ``hello.txt``\ をMarkdownからLaTeX形式に変換します。

出力ファイルが指定されていない場合（この場合標準出力に出力されます）、
または出力ファイルの拡張子が不明な場合は、\ ``-t/--to``\ オプションで明示しない限り、
出力フォーマットはデフォルトとしてHTMLが選ばれます。
入力ファイルが指定されていない場合（この場合は入力を標準入力から得ます）、
または入力ファイルの拡張子が不明な場合は、\ ``-f/--from``\ オプションで明示しない限り、
入力フォーマットはMarkdownとして扱います。

Pandocは入力・出力のデフォルトエンコーディングとしてUTF-8を採用しています。
UTF-8以外の文字コードを利用したい場合は、\ ``iconv``\ などの文字コード変換ツールにより
入力や出力をパイプする必要があります：

::

   iconv -t utf-8 input.txt | pandoc | iconv -f utf-8

.. _creating-a-pdf:

PDFを作成する
-------------

初期のPandocは、PDF生成のためにPandocとpdfLaTeXを用いる ``markdown2pdf``
というプログラムとともに発展しました。
現在はPandoc自身がPDFを生成できるため、このプログラムは必要ありません。

PDFを生成するには、単に出力ファイルの拡張子として ``.pdf``
を指定するだけです。
Pandocは内部でLaTeXファイルを作成し、それをpdfLaTeXを用いてPDFに変換します。
（他のLaTeXエンジンを利用するには、\ ``--latex-engine``\ の項をご覧ください。）

::

   pandoc test.txt -o test.pdf

（訳注：pdfLaTeXは日本語に対応していません。その代わりに、LuaLaTeXの利用を推奨します。
インストールやコマンドなどの詳細は以下のページをご覧ください。 `HTML -
多様なフォーマットに対応！ドキュメント変換ツールPandocを知ろう -
Qiita <http://qiita.com/sky_y/items/80bcd0f353ef5b8980ee>`__ ）

PDFの生成のためには、LaTeXエンジンがインストールされている必要があります
（詳細は以下の ``--latex-engine`` の項をご覧ください）。
以下のLaTeXパッケージは有効であると見なされます：

-  ``amssymb``
-  ``amsmath``
-  ``ifxetex``
-  ``ifluatex``
-  ``listings`` (``--listings``\ オプションが有効の場合)
-  ``fancyvrb``
-  ``longtable``
-  ``booktabs``
-  ``url``
-  ``graphicx``
-  ``hyperref``
-  ``ulem``
-  ``babel`` (``lang``\ オプションが有効の場合)
-  ``fontspec``
   (LaTeXエンジンとして``xelatex``\ または\ ``lualatex``\ が指定されている場合)
-  ``xltxtra``
-  ``xunicode`` (LaTeXエンジンとして``xelatex``\ が指定されている場合).

``hsmarkdown``
--------------

``Markdown.pl``\ の暫定的な置き換えとしてPandocを利用したいユーザは、
``pandoc``\ 実行ファイルへのシンボリックリンクを\ ``hsmarkdown``\ として利用することができます。
Pandocを\ ``hsmarkdown``\ として呼びだした場合、 Pandocはオプション
``-f markdown_strict --email-obfuscation=references``
が指定されたものとして呼びだされ、
全てのコマンドラインオプションは通常の引数として取り扱われます。
ただし、Cygwinの下ではシンボリックリンクのシミュレーションの問題により、この方法では動作しません。

オプション
==========

.. _general-options:

一般的なオプション
------------------

``-f`` *FORMAT*, ``-r`` *FORMAT*, ``--from=``\ *FORMAT*, ``--read=``\ *FORMAT*
   入力フォーマットを指定します。\ *FORMAT*
   として指定できるのは以下のフォーマットです：

   -  ``native`` (Native Haskell; Haskellで読み込める形式のデータ構造)
   -  ``json`` (ネイティブASTのJSONバージョン)
   -  ``markdown`` (Pandocによる拡張Markdown)
   -  ``markdown_strict`` (オリジナルの拡張されていないMarkdown)
   -  ``markdown_phpextra`` (PHP Markdown Extraによる拡張Markdown)
   -  ``markdown_github`` (GitHubによる拡張Markdown)
   -  ``textile`` (Textile)
   -  ``rst`` (reStructuredText)
   -  ``html`` (HTML)
   -  ``docbook`` (DocBook)
   -  ``opml`` (OPML)
   -  ``org`` (Emacs Org-mode)
   -  ``mediawiki`` (MediaWikiマークアップ)
   -  ``haddock`` (Haddockマークアップ)
   -  ``latex`` (LaTeX)

   ``+lhs`` をフォーマット ``markdown``, ``rst``, ``latex``, ``html``
   の後ろにつけ加えた場合、 その入力はLiterate
   Haskellのソースコードとして扱われます （詳細は下記の\ `Literate
   Haskellのサポート <#literate-haskell-support>`__\ を参照）。

   Markdownの拡張文法は、フォーマットの末尾に\ ``+EXTENSION``\ または\ ``-EXTENSION``\ をつけ加えることで
   それぞれ有効・無効を切り替えられます。
   例えば、\ ``markdown_strict+footnotes+definition_lists``\ は、
   ``markdown_strict``\ をベースにして脚注と定義リストを有効にしたもの、という意味になります。
   同様に、\ ``markdown-pipe_tables+hard_line_breaks``\ は、
   PandocのMarkdownからパイプテーブルを無効にし強制改行を有効にしたもの、という意味です。
   拡張とその名前の詳細については、下記の\ `Pandocによる拡張Markdown <#pandocs-markdown>`__\ をご覧ください。

``-t`` *FORMAT*, ``-w`` *FORMAT*, ``--to=``\ *FORMAT*, ``--write=``\ *FORMAT*
   出力フォーマットを指定します。\ *FORMAT*\ として指定できるのは以下のフォーマットです：

   -  ``native`` (Native Haskell)
   -  ``json`` (ネイティブASTのJSONバージョン)
   -  ``plain`` (プレーンテキスト)
   -  ``markdown`` (Pandocによる拡張Markdown)
   -  ``markdown_strict`` (オリジナルの拡張されていないMarkdown)
   -  ``markdown_phpextra`` (PHP Markdown Extraによる拡張Markdown)
   -  ``markdown_github`` (GitHubによる拡張Markdown)
   -  ``rst`` (reStructuredText)
   -  ``html`` (XHTML 1)
   -  ``html5`` (HTML 5)
   -  ``latex`` (LaTeX)
   -  ``beamer`` (LaTeX beamer スライドショー)
   -  ``context`` (ConTeXt)
   -  ``man`` (groff man)
   -  ``mediawiki`` (MediaWiki マークアップ)
   -  ``textile`` (Textile)
   -  ``org`` (Emacs Org-Mode)
   -  ``texinfo`` (GNU Texinfo)
   -  ``opml`` (OPML)
   -  ``docbook`` (DocBook)
   -  ``opendocument`` (OpenDocument)
   -  ``odt`` (OpenOffice/LibreOffice Writerドキュメント)
   -  ``docx`` (Word docx)
   -  ``rtf`` (リッチテキストフォーマット)
   -  ``epub`` (EPUB v2 book)
   -  ``epub3`` (EPUB v3)
   -  ``fb2`` (FictionBook2 e-book)
   -  ``asciidoc`` (AsciiDoc)
   -  ``icml`` (InDesign ICML)
   -  ``slidy`` (Slidy HTML and javascript スライドショー)
   -  ``slideous`` (Slideous HTML and javascript スライドショー)
   -  ``dzslides`` (DZSlides HTML5 + javascript スライドショー)
   -  ``revealjs`` (reveal.js HTML5 + javascript スライドショー)
   -  ``s5`` (S5 HTML and javascript スライドショー),
   -  カスタム Lua Writer へのパス（詳細は下記の
      `カスタムWriter <#custom-writers>`__ を参照）

   注意：\ ``odt``, ``epub``, ``epub3``\ の出力は 標準出力 *stdout*
   に出力されないため、 出力ファイル名を
   ``-o/--output``\ オプションにより必ず指定する必要があります。
   ``+lhs``\ を\ ``markdown``, ``rst``, ``latex``, ``beamer``, ``html``,
   ``html5``\ のいずれかの後ろにつけ加えた場合、 出力はLiterate
   Haskellソースコードとして出力されます （詳細は下記の\ `Literate
   Haskellのサポート <#literate-haskell-support>`__\ を参照）。

   Markdownの拡張文法は、\ ``+EXTENSION`` または ``-EXTENSION``
   をフォーマット名の後ろにつけ加えることにより、
   それぞれ有効または無効を切り替えることができます（上記の ``-f``
   セクションでの説明と同様）。

``-o`` *FILE*, ``--output=``\ *FILE*
   標準出力 *stdout* に出力するのではなく、ファイル *FILE*
   へ出力するようにします。 *FILE* として
   ``-``\ を指定した場合、標準出力 *stdout*\ へ出力するようにします。
   （例外：出力フォーマットが\ ``odt``, ``docx``, ``epub``,
   ``epub3``\ のいずれかの場合、標準出力への出力は無効になります。）
``--data-dir=``\ *DIRECTORY*
   Pandocデータファイルを検索するために、ユーザデータディレクトリを指定します。
   このオプションが指定されていない場合、デフォルトとして下記のユーザデータディレクトリが使用されます。

   デフォルトのユーザデータディレクトリは、Unixの場合は

   ::

      $HOME/.pandoc

   Windows XPの場合は

   ::

      C:\Documents And Settings\USERNAME\Application Data\pandoc

   Windows 7の場合は

   ::

      C:\Users\USERNAME\AppData\Roaming\pandoc

   です。（デフォルトのユーザデータディレクトリが分からない場合は、
   ``pandoc --version``\ コマンドの出力の中から見つけることができます。）

   ユーザデータディレクトリに\ ``reference.odt``, ``reference.docx``,
   ``default.csl``, ``epub.css``\ ファイル、\ ``templates``, ``slidy``,
   ``slideous``, ``s5``\ ディレクトリを置いた場合、
   それらはPandocで通常使用されるのデフォルトのファイル・フォルダと置き換えられます。

``-v``, ``--version``
   バージョンを出力します。
``-h``, ``--help``
   使用方法を表示します。

.. _reader-options:

Readerのオプション
------------------

``-R``, ``--parse-raw``
   解釈できないHTMLコードまたはLaTeX環境を無視する代わりに、
   生(raw)のHTMLまたはLaTeXソースとしてそのまま出力します。
   このオプションはHTMLまたはLaTeXソースの入力時のみに影響します。
   生のHTMLは出力がMarkdown, reStructuredText, HTML, Slidy, Slideous,
   DZSlides, reveal.js, S5の場合に表示され、 生のLaTeXは出力がMarkdown,
   reStructuredText, LaTeX, ConTeXtの場合に表示されます。
   デフォルト動作では、Readerは解釈できないHTMLコードまたはLaTeX環境を無視します。
   （LaTeX Readerは、たとえ\ ``-R``\ が指定されていない場合でも、LaTeX
   *コマンド* をそのまま出力します。）
``-S``, ``--smart``
   タイポグラフィ的に正しく出力します。
   具体的には、直線状の引用符を曲がった引用符に、\ ``---``\ をemダッシュ「\ ``—``\ 」に、\ ``--``\ をenダッシュ「\ ``–``\ 」に、
   ``...``\ を3点リーダーに変換します。
   また、“Mr.”のようなある種の略記・略称に対しては、自動的な改行のないスペース(non-breaking
   space)がその後に挿入されます。
   （注意：入力フォーマットが\ ``markdown``, ``markdown_strict``,
   ``textile``\ の場合にこのオプションは重要です。
   また、入力フォーマットが\ ``textile``\ の場合や出力ファイルが\ ``latex``,
   ``context``\ の場合は、
   ``--no-tex-ligatures``\ を有効にしない限り、このオプションが有効になります。）
``--old-dashes``
   ダッシュ記号の解釈をPandoc バージョン <= 1.8.2.1
   の振る舞いと同等にします：
   数字の前の\ ``-``\ をenダッシュに、\ ``--``\ をemダッシュに変換します。
   このオプションは\ ``textile``\ 入力の際に自動的に選択されます。
``--base-header-level=``\ *NUMBER*
   ヘッダのベースレベルを指定します（デフォルトは1）。
   （訳注：ヘッダのベースレベルは、HTMLにおける最上位のヘッダレベルと対応します。
   例えば\ ``--base-header-level=3``\ の場合は、HTMLのヘッダが\ ``<h3>``\ から始まります。）
``--indented-code-classes=``\ *CLASSES*
   通常のインデントコードブロックに対して適用するシンタックスハイライト用クラスを指定します。
   例えば、\ ``perl,numberLines``\ や\ ``haskell``\ のように指定します。複数のクラスを指定する場合は、スペースかコンマで区切ります。
   訳注：シンタックスハイライトが可能な言語については下記の
   `訳注：シンタックスハイライトが可能なプログラミング言語 <#code-highlighting>`__
   を参照して下さい。
``--default-image-extension=``\ *EXTENSION*
   画像パス・URLの拡張子が無い場合のデフォルト拡張子を指定します。
   このコマンドにより、異なる種類の画像を必要とするフォーマットに対し、同一のソースを利用できるようになります。
   現在のところ、このオプションはMarkdownとLaTeXのReaderのみに影響を与えます。
``--filter=``\ *EXECUTABLE*
   Pandocの入力処理と出力処理の間に挟んでPandoc
   ASTの変換処理を行うフィルタの実行ファイルを指定します。
   この実行ファイルは標準入力からJSONを読み、JSONを標準出力へ出力する必要があります。
   このJSONはPandoc自身の入力および出力のようなフォーマットでなければなりません。
   出力フォーマット名はフィルタへ第1引数として渡されます。したがって、

   ::

      pandoc --filter ./caps.py -t latex

   は以下と等価です：

   ::

      pandoc -t json | ./caps.py latex | pandoc -f json -t latex

   後者のコマンド形式はフィルタをデバッグする際に有用です。

   フィルタは任意の言語で書くことができます。Haskellでは\ ``Text.Pandoc.JSON``\ は\ ``toJSONFilter``\ をエクスポートし、Haskellでフィルタを書くことを容易にします。
   Pythonでフィルタを書きたい方は、モジュール\ ``pandocfilters``\ をPyPIからインストールできます。このモジュールといくつかの例については、
   http://github.com/jgm/pandocfilters をご覧ください。

   注意：Pandocは実行ファイル\ *EXECUTABLE*\ をユーザの環境変数\ ``PATH``\ から見つけますが、ディレクトリ名を明示していない場合、カレントディレクトリにある実行ファイルは無視されます。
   カレントディレクトリにあるスクリプトをフィルタとして実行したい場合は、そのスクリプト名の前に
   ``./`` を付けて下さい。

``-M`` *KEY[=VAL]*, ``--metadata=``\ *KEY[:VAL]*
   メタデータとしてフィールド *KEY* に対し値 *VAL*
   をセットします。コマンドラインで指定された値は文書中の値を上書きします。
   値はYAMLのbooleanまたはstring値として解釈されます。値 *VAL*
   が指定されてない場合、その値はboolean値の\ ``true``\ として見なされます。
   ``--variable``\ や\ ``--metadata``\ のようなオプションにより、テンプレート変数がセットされます。
   しかし、\ ``--variable``\ とは違い、\ ``--metadata``\ はその文書に内在するメタデータへ影響を与えます（このメタデータはフィルタからアクセス可能であり、ある出力フォーマットでは表示されることがあります）。
``--normalize``
   入力処理の後に文書を簡素化します：例えば、隣接した\ ``Str``\ や\ ``Emph``\ 要素をマージしたり、
   複数繰り返される\ ``Space``\ を取り除いたりします。
``-p``, ``--preserve-tabs``
   このオプションを指定すると、タブ文字がスペースに変換されなくなります（デフォルトではタブ文字はスペースに変換されます）。
   注意：このオプションは文字通りのコード表示やコードブロックのみで有効です。通常のテキスト中のタブ文字はスペースとして扱われます。
``--tab-stop=``\ *NUMBER*
   タブ文字をスペースに変換する際に、1つのタブ文字を何個のスペースで置換するかを指定します（デフォルト値は4）。

.. _general-writer-options:

一般的なWriterオプション
------------------------

``-s``, ``--standalone``
   スタンドアローンモード。適切なヘッダおよびフッタのついた出力を生成します。（言い換えると、この出力は断片ではなく、1つの完全で独立したHTML,
   LaTeX, およびRTFファイルです。）
   このオプションは出力フォーマットが\ ``pdf``, ``epub``, ``epub3``,
   ``fb2``, ``docx``, ``odt``\ の場合に自動的に付加されます。
   訳注：このオプションは、Pandoc実行後にブラウザでHTMLファイルを表示させたり、LaTeXコマンドで直接ソースを処理したりする場合に必要となるでしょう。リッチテキストエディタでRTFファイルを扱う場合にはおそらく必須です。
   逆に、例えばブログなどに使う用途で最低限のHTMLだけが必要な場合は、このオプションを付けない方が用途に合っているでしょう。
``--template=``\ *FILE*
   テンプレートファイル\ *FILE*\ をカスタムテンプレートとして出力文書に適用します。
   暗黙に\ ``--standalone``\ オプションが指定されます。
   テンプレートの文法についての説明は、下記の
   `テンプレート <#templates>`__ の節をご覧ください。
   拡張子が無い場合、Writerに対応する拡張子が *FILE*
   に追加されます。例えば、\ ``--template=special``\ と指定すれば、PandocはHTML出力に対して\ ``special.html``\ を探します。
   テンプレートファイルが見つからない場合、Pandocはユーザデータディレクトリを検索します（\ ``--data-dir``\ を参照）。
   このオプションが使われない場合、出力に対してふさわしいデフォルトテンプレートが指定されます（\ ``-D/--print-default-template``\ を参照）。
``-V`` *KEY[=VAL]*, ``--variable=``\ *KEY[:VAL]*
   スタンドアローンモードで文書を出力する際に、テンプレート変数 *KEY*
   に対して値 *VAL* をセットします。
   Pandocはデフォルトテンプレートの中で変数を自動的に設定するため、
   このオプションはカスタムテンプレートを利用する際（\ ``--template``\ オプションが指定されている場合）に有用です。
   値 *VAL*
   が何も指定されてない場合、\ *KEY*\ に対応する値として\ ``true``\ が指定されます。
``-D`` *FORMAT*, ``--print-default-template=``\ *FORMAT*
   出力フォーマット *FORMAT*
   で用いるデフォルトテンプレートを表示します。（指定できる *FORMAT*
   の一覧は ``-t`` の節を参照。）
``--print-default-data-file=``\ *FILE*
   デフォルトのデータファイルを表示します。
``--no-wrap``
   出力におけるテキストの折り返しを無効にします。デフォルトでは、テキストは出力フォーマットに応じて適切に折り返しされます。
``--columns``\ =\ *NUMBER*
   1行あたりの文字数を指定します（テキストの折り返しに影響します）。
``--toc``, ``--table-of-contents``
   自動的に生成された目次を出力文書に含めます（\ ``latex``, ``context``,
   ``rst``\ の場合は、目次を作成する命令を挿入します）。このオプションは、\ ``man``,
   ``docbook``, ``slidy``, ``slideous``, ``s5``, ``docx``,
   ``odt``\ の場合は何も影響を与えません。
``--toc-depth=``\ *NUMBER*
   目次に含める節のレベル番号を指定します。デフォルトは3です（つまり、レベル1,
   2, 3のヘッダが目次にリストアップされます）。
``--no-highlight``
   コードブロックやインラインにおける構文強調表示を無効にします（構文強調表示用に言語が指定されている場合も同様です）。
``--highlight-style``\ =\ *STYLE*
   ソースコードのシンタックスハイライトに用いる色のスタイルを指定します。オプションは\ ``pygments``
   (デフォルト値), ``kate``, ``monochrome``, ``espresso``, ``zenburn``,
   ``haddock``, ``tango``\ の中から選べます。
   訳注：これらのオプション値の名前の一部は実在のシンタックスハイライトエンジンに由来しますが、そのエンジンを実際に使用するわけではなく、それに準じた色テーマを指定するだけです。
``-H`` *FILE*, ``--include-in-header=``\ *FILE*
   ヘッダの末尾に、\ *FILE*\ の内容をそのままつけ加えます。
   使用例としては、HTMLヘッダに自前のCSSやJavaScriptのmetaタグをつけ加える用途に使えます。
   複数のファイルをヘッダに含めるために、このオプションを複数回指定することができます。オプションを指定した順番通りに、出力ファイルのヘッダへも追加されます。
   このオプションにより、\ ``--standalone``\ も暗黙に指定されます。
``-B`` *FILE*, ``--include-before-body=``\ *FILE*
   文書本文(body)の先頭に、\ *FILE*\ の内容をそのままつけ加えます（具体的には、HTMLの\ ``<body>``\ タグの直後や、LaTeXの\ ``\begin{document}``\ の直後です）。
   使用例としては、HTML文書にナビゲーションバーやバナーをつけ加える用途に使えます。
   複数のファイルを含めるために、このオプションを複数回指定することができます。オプションを指定した順番通りに、出力ファイルの文書本文先頭へも追加されます。
   このオプションにより、\ ``--standalone``\ も暗黙に指定されます。
``-A`` *FILE*, ``--include-after-body=``\ *FILE*
   文書本文(body)の末尾に、\ *FILE*\ の内容をそのままつけ加えます（具体的には、HTMLの\ ``</body>``\ タグの直前や、LaTeXの\ ``\end{document}``\ の直前です）。
   複数のファイルを含めるために、このオプションを複数回指定することができます。オプションを指定した順番通りに、出力ファイルの文書本文末尾へも追加されます。
   このオプションにより、\ ``--standalone``\ も暗黙に指定されます。

.. _options-affecting-specific-writers:

特定のWriterに影響を与えるオプション
------------------------------------

``--self-contained``
   他のファイルに依存せず、単一ファイルで完結したHTMLを生成します。
   リンクされたスクリプト、スタイルシート、画像および動画は、\ ``data:``
   URIスキームを用いてHTMLファイル内に埋め込まれます。この出力ファイルは、一切の外部ファイルを必要とせず、ネットが繋がらない場所でも正しくブラウザで表示できるという意味では、自己完結した(self-contained)ファイルといえるでしょう。
   このオプションはHTMLに関連した出力フォーマットに対して有効であり、具体的には\ ``html``,
   ``html5``, ``html+lhs``, ``html5+lhs``, ``s5``, ``slidy``,
   ``slideous``, ``dzslides``, ``revealjs``\ で用いることができます。
   絶対パスのURLで指定されたスクリプト、画像、スタイルシートはダウンロードされる一方で、相対パスのURLで指定されたそれらはまずカレントディレクトリから検索され、その後ユーザデータディレクトリから検索されます（\ ``--data-dir``\ の節を参照）。最後に、Pandocのデフォルトデータディレクトリから検索されます。
   なお、\ ``--self-contained``\ は\ ``--mathjax``\ オプションと併用することができません。
``--offline``
   *（非推奨）* ``--self-contained``\ と等価。
``-5``, ``--html5``
   *（非推奨）*
   HTML4の代わりにHTML5で出力します。\ ``html``\ 以外の出力フォーマットでは無効です。
   現在はこのオプションの代わりに ``html5``
   出力フォーマットを利用するようにしてください。
``--html-q-tags``
   HTMLで引用の際に ``<q>`` タグを利用します。
``--ascii``
   ASCII文字のみを出力に利用します。現在のところHTML出力のみに対してサポートしています。（このオプションが指定されると、UTF-8の代わりに数値文字参照を利用します。）
``--reference-links``
   MarkdownまたはreStructuredTextを出力する際に、インライン形式のリンクではなく参照形式のリンクを用いるようにします。デフォルトではインライン形式のリンクを出力します。
   （訳注：Markdownにおける各形式の詳細は `リンク <#links>`__
   の節をご覧ください。）
``--atx-headers``
   MarkdownまたはAsciiDocを出力する際に、ATX形式のヘッダを用いるようにします。デフォルトでは、レベル1-2のヘッダに対してはSetext形式を、それ以降のレベルに対してはATX形式を用います。
   （訳注：Markdownにおける各形式の詳細は `ヘッダ <#headers>`__
   の節をご覧ください。）
``--chapters``
   最も上位のヘッダを章(chapter)として扱います。LaTeX, ConTeXt,
   DocBookの出力にて有効です。 LaTeXのテンプレートがreport, book,
   memoirクラスファイルを用いる場合、このオプションが暗黙に指定されます。
   出力フォーマットとして\ ``beamer``\ が指定された場合、最上位のヘッダは\ ``\part{..}``\ になります。
``-N``, ``--number-sections``
   番号付き節ヘッダを出力します。LaTeX, ConTeXt, HTML,
   EPUBの出力で有効です。
   デフォルトでは、節に番号は付いていません。\ ``unnumbered``\ クラスの付いている節では、\ ``--number-section``\ が指定されていている場合でも、番号は付きません。

   訳注1：\ ``unnumbered``\ クラスは、例えば

   ::

      # 見出し {.unnumbered}

   のように指定します。

   訳注2：Pandocのデフォルトでは、\ ``-s/--standalone``\ オプション付きでLaTeX出力すると、ヘッダに番号を付けない設定付きのLaTeXソースが出力されます。これはLaTeXそのもののデフォルトと異なるので注意して下さい。

``--number-offset``\ =\ *NUMBER[,NUMBER,…]*,
   HTML出力中の節ヘッダ番号に対して、指定されたオフセット値を加えます（他の出力フォーマットでは無視されます）。
   オフセット値はカンマ区切りで複数指定でき、最初の番号はトップレベルのヘッダに対して、
   2番目の番号は2番目のレベルのヘッダに対して、というように指定できます。
   例えば、トップレベルのヘッダを“6”から始めたい場合は、\ ``--number-offset=5``\ と指定します。
   また、レベル2のヘッダを“1.5”から始めたい場合は、\ ``--number-offset=1,4``\ と指定します。
   オフセット値のデフォルトは0です。\ ``--number-sections``\ を暗黙に指定します。
``--no-tex-ligatures``
   LaTeXやConTeXtの出力において、引用符やアポストロフィ、ダッシュ記号をTeXの記号表記に変換しないようにします。
   その代わりに、Unicodeにおける各々の記号を文字通りに出力します。
   このオプションは、OpenTypeの高度な機能をXeLaTeXやLuaLaTeXで用いる際に必要となります。

   注意：通常、LaTeXとConTeXtの出力において ``--smart``
   オプションが自動的に指定されます。しかし、\ ``--no-tex-ligatures``\ を指定する場合は、\ ``--smart``\ を明示的に指定しなければなりません。ただし、丸まった引用符やダッシュ記号、3点リーダー記号をソースコード内で用いる場合は、\ ``--smart``\ を指定せずに\ ``--no-tex-ligatures``\ を使う必要があるかもしれません。

``--listings``
   LaTeXのコードブロックに対してlistingパッケージを適用します。
``-i``, ``--incremental``
   スライドショー内のリスト項目を一気に表示するのではなく1つずつ表示するようにします。
   デフォルトでは、リスト項目は全てが一気に表示されます。
``--slide-level``\ =\ *NUMBER*
   指定したレベルのヘッダごとに1枚ずつスライドを作るようにします（\ ``beamer``,
   ``s5``, ``slidy``, ``slideous``, ``dzslides``\ で有効です）。
   このレベルよりも上のヘッダはスライドショーを節ごとに区切るために使われます。また、このレベルよりも下のヘッダはスライド内の副ヘッダを作ります。
   デフォルト値はドキュメントの内容によって変わります。詳しくは
   `スライドショーの構造を作る <#structuring-the-slide-show>`__
   をご覧ください。
``--section-divs``
   HTMLでヘッダタグ（\ ``<h1>``\ など）を使う代わりに、節を\ ``<div>``\ タグ（HTML5では\ ``<section>``\ タグ）で囲み、
   識別子を\ ``<div>``\ （または\ ``<section>``\ ）タグの中に含めるようにします。
   詳しくは
   `ヘッダ識別子 <#header-identifiers-in-html-latex-and-context>`__
   の項目をご覧ください。
``--email-obfuscation=``\ *none|javascript|references*
   HTML文書において\ ``mailto:``\ リンクを難読化する方法を指定します。
   *none*\ の場合は、リンクは難読化されません。\ *javascript*\ の場合はJavaScriptを用いて難読化します。
   *references*\ の場合は、メールアドレスの文字を10進または16進の数値参照により難読化します。
``--id-prefix``\ =\ *STRING*
   HTMLとDocBookの出力において、自動的に生成される全ての識別子に対して付ける接頭辞(prefix)を指定します。
   または、Markdown出力においては、脚注番号に対して付ける接頭辞を指定します。
   このオプションは、文書の断片を生成し他の文書に埋め込む場合に、識別子が重複することを防ぐため便利です。
``-T`` *STRING*, ``--title-prefix=``\ *STRING*
   HTMLヘッダの\ ``<title>``\ タグの最初に現れる接頭辞(prefix)を指定します（ただしHTMLのbody部分の最初に現れるタイトルではありません）。\ ``--standalone``\ を暗黙に指定します。
``-c`` *URL*, ``--css=``\ *URL*
   スタイルシート(CSS)へのリンクを指定します。複数のスタイルシートを指定したい場合は、このオプションを繰り返し使用することもできます。オプションを指定した順に、スタイルシートも追加されます。
``--reference-odt=``\ *FILE*
   OpenOffice/LibreOffice
   ODTファイルを出力する際に、スタイルの元となる参照用ODTファイルを使用します。ファイル名が指定されている場合は、そのファイルを参照用ODTファイルとして使用します。
   最も良い出力を得るために、参照用ODTファイルはPandocを用いて生成されたものを変更して使用して下さい。参照用ODTファイルの内容（コンテンツ）は無視され、そのスタイルシートが新しく出力されるODTファイルに適用されます。
   ODTファイルがコマンドラインに指定されていない場合、Pandocはユーザデータディレクトリから\ ``reference.odt``\ という名前のファイルを検索します（\ ``--data-dir``\ の節を参照）。もし見つからなければ、デフォルトの参照用ODTファイルを使います。

   訳注：カスタマイズの元になる参照用ODTファイルを得るには、

   ::

      pandoc --print-default-data-file reference.odt > reference.odt

   を実行して下さい。

``--reference-docx=``\ *FILE*
   Word
   docxファイルを出力する際に、スタイルの元となる参照用docxファイルを使用します。ファイル名が指定されている場合は、そのファイルを参照用docxファイルとして使用します。
   最も良い出力を得るためには、参照用docxファイルはPandocを用いて生成されたものを変更して使用して下さい。参照用odocxファイルの内容（コンテンツ）は無視され、そのスタイルシートが新しく出力されるdocxファイルに適用されます。
   docxファイルがコマンドラインに指定されていない場合、Pandocはユーザデータディレクトリから\ ``reference.docx``\ という名前のファイルを検索します（\ ``--data-dir``\ の節を参照）。もし見つからなければ、デフォルトの参照用docxファイルを使います。

   Pandocでは以下のスタイルを使用します：【段落】 標準(Normal), Compact,
   表題(Title), Authors, 日付(Date), Heading 1, Heading 2, Heading 3,
   Heading 4, Heading 5, Block Quote, Definition Term, Definition,
   本文(Body Text), Table Caption, Image Caption; 【文字】 Default
   Paragraph Font, Body Text Char, Verbatim Char, Footnote Ref, Link.

   訳注：カスタマイズの元になる参照用docxファイルを得るには、

   ::

      pandoc --print-default-data-file reference.docx > reference.docx

   を実行して下さい。

``--epub-stylesheet=``\ *FILE*
   EPUBでスタイルを整えるためにスタイルシート(CSS)を使用します。ファイル名が指定された場合はそれを使用し、指定されていない場合は\ ``epub.css``\ という名前のファイルをユーザデータディレクトリから検索します（\ ``--data-dir``\ の項を参照）。それでも見つからない場合は、デフォルトのスタイルシートを使用します。

   訳注：デフォルトのepub.cssを得るには、

   ::

      pandoc --print-default-data-file epub.css > epub.css

   を実行して下さい。

``--epub-cover-image=``\ *FILE*
   EPUBのカバー画像として指定された画像を用います。 画像は、縦と横が
   1000px よりも小さいものを推奨します。
   注意：Markdownのソースファイル中では、YAMLメタデータブロックの中で\ ``cover-image``\ を指定することもできます（下記の\ `EPUBメタデータ <#epub-metadata>`__\ を参照）。
``--epub-metadata=``\ *FILE*
   EPUB出力の際に、指定されたEPUB用XMLメタデータを参照します。
   このファイルには\ http://dublincore.org/documents/dces/\ に記載されているDublin
   Core要素が含まれている必要があります。 例：

   ::

       <dc:rights>Creative Commons</dc:rights>
       <dc:language>es-AR</dc:language>

   デフォルトでは、Pandocは以下のメタデータ要素を含みます：

   -  ``<dc:title>`` (文書のタイトルから取得)
   -  ``<dc:creator>`` (文書の著者名から取得)
   -  ``<dc:date>`` (文書の日付から取得, `ISO 8601
      format <http://www.w3.org/TR/NOTE-datetime>`__\ に従う必要があります)
   -  ``<dc:language>`` (変数 ``lang`` から取得,
      設定されていない場合はロケールから取得)
   -  ``<dc:identifier id="BookId">`` (ランダムに生成されたUUID)

   注意：入力文書がMarkdownの場合、文書中のYAMLメタデータブロックが代わりに使用されます。詳しくは下記の\ `EPUBメタデータ <#epub-metadata>`__\ を参照してください。

``--epub-embed-font=``\ *FILE*
   EPUBに指定したフォントを埋め込みます。複数のフォントを埋め込みたい場合は、このオプションを複数回使用することもできます。埋め込みフォントを利用するには、CSSファイルに以下のような宣言を追加する必要があります（\ ``--epub-stylesheet``\ の項を参照）。

   ::

      @font-face {
      font-family: DejaVuSans;
      font-style: normal;
      font-weight: normal;
      src:url("DejaVuSans-Regular.ttf");
      }
      @font-face {
      font-family: DejaVuSans;
      font-style: normal;
      font-weight: bold;
      src:url("DejaVuSans-Bold.ttf");
      }
      @font-face {
      font-family: DejaVuSans;
      font-style: italic;
      font-weight: normal;
      src:url("DejaVuSans-Oblique.ttf");
      }
      @font-face {
      font-family: DejaVuSans;
      font-style: italic;
      font-weight: bold;
      src:url("DejaVuSans-BoldOblique.ttf");
      }
      body { font-family: "DejaVuSans"; }

``--epub-chapter-level=``\ *NUMBER*
   EPUBファイルをいくつかの“chapter”（章）ファイルに分割するために、章に相当するヘッダレベルを設定します。
   デフォルトでは、レベル1のヘッダを使って複数の章に分割します。
   このオプションはEPUBファイルの内部構成に影響を与えるだけであり、ユーザに見せる章や節を制御するものではありません。
   いくつかのEPUBリーダーでは、chapterファイルのサイズが大きすぎる場合、動作が遅くなることがあります。少数のレベル1ヘッダを持つ大きな文書を変換する場合には、このオプションを使って章のヘッダレベルを2または3に設定したくなるかもしれません。
``--latex-engine=``\ *pdflatex|lualatex|xelatex*
   PDFを出力する際に、指定したLaTeXエンジンを利用します。デフォルトは\ ``pdflatex``\ です。指定したエンジンがPATHの中に存在しない場合は、そのエンジンのフルパスを指定することもできます。
   訳注：日本語文書を処理する場合、特に理由が無ければ\ ``lualatex``\ の利用を推奨します。

.. _citation-rendering:

引用文献の表示
--------------

``--bibliography=``\ *FILE*
   文書中のメタデータにおいて\ ``bibliography``\ フィールドを\ *FILE*\ で上書きし、
   ``pandoc-citeproc``\ を用いて引用を処理します。（これは\ ``--metadata bibliography=file --filter pandoc-citeproc``\ と等価です。）
   訳注：\ ``bibliography``\ フィールドはBibTeXファイル(.bib)などの引用文献ファイルを指定するために利用します。詳細は下記の\ `文献の引用 <#citations>`__\ をご覧ください。
``--csl=``\ *FILE*
   文書中のメタデータにおいて\ ``csl``\ フィールドを\ *FILE*\ で上書きします。（これは\ ``--metadata csl=FILE``\ と等価です。）
   訳注：\ ``csl``\ フィールドは引用の書式を指定するために利用します。詳細は下記の\ `文献の引用 <#citations>`__\ をご覧ください。
``--citation-abbreviations=``\ *FILE*
   文書中のメタデータにおいて\ ``citation-abbreviations``\ フィールドを\ *FILE*\ で上書きします。（これは\ ``--metadata citation-abbreviations=FILE``\ と等価です。）
``--natbib``
   latex出力において、natbibパッケージを引用に利用します。
   このオプションは\ ``pandoc-citeproc``\ フィルタやPDF出力とともに使うものではありません。
   pdflatexとbibtexでLaTeXファイルを処理する際に使用することを想定しています。
``--biblatex``
   latex出力において、BibLaTeXを引用に利用します。
   このオプションは\ ``pandoc-citeproc``\ フィルタやPDF出力とともに使うものではありません。
   pdflatexとbibtex（またはbiber）でLaTeXファイルを処理する際に使用することを想定しています。

.. _math-rendering-in-html:

HTMLにおける数式の表示
----------------------

``-m`` [*URL*], ``--latexmathml``\ [=*URL*]
   HTML出力において、\ `LaTeXMathML <http://math.etsu.edu/LaTeXMathML/>`__\ スクリプトを用いて埋め込まれたTeX数式を表示します。
   ローカルの\ ``LaTeXMathML.js``\ をリンクとして挿入したい場合は、\ *URL*\ を指定して下さい。
   *URL*\ が指定されていない場合は、効率を犠牲にして可搬性を向上させるために、スクリプトの内容をHTMLヘッダに直接挿入します。
   もし数式をいくつかのページに使うつもりであれば、スクリプトをリンクする方が良いでしょう（スクリプトがキャッシュされるため）。
``--mathml``\ [=*URL*]
   ``docbook``\ や\ ``html``,
   ``html5``\ において、TeX数式をMathMLに変換します。
   スタンドアローンの\ ``html``\ 出力では、MathMLをいくつかのブラウザで見られるようにするために、ヘッダに小さいJavaScriptを挿入します（\ *URL*\ が指定されている場合は、リンクを挿入します）。
``--jsmath``\ [=*URL*]
   HTML出力において、埋め込まれたTeX数式を\ `jsMath <http://www.math.union.edu/~dpvc/jsmath/>`__\ を用いて表示します。
   *URL*\ はjsMathのloadスクリプトである必要があり（例：\ ``jsmath/easy/load.js``\ ）、
   これを指定するとスタンドアローンなHTML文書のヘッダにリンクが埋め込まれます。
   *URL*\ が指定されていない場合は、jsMathのloadスクリプトへのリンクは挿入されないため、HTMLテンプレートなど別の手段を用いて適宜リンクを指定する必要があります。
``--mathjax``\ [=*URL*]
   HTML出力において、埋め込まれたTeX数式を\ `MathJax <http://www.mathjax.org/>`__\ を用いて表示します。
   *URL*\ はMathJaxのloadスクリプト\ ``MathJax.js``\ である必要があります。
   *URL*\ が指定されていない場合は、MathJax
   CDNへのリンクが挿入されます。
``--gladtex``
   HTML出力において、TeX数式を\ ``<eq>``\ タグで囲みます。
   これらの数式は\ `gladTeX <http://ans.hsh.no/home/mgg/gladtex/>`__\ によって処理され、タイプセットされた画像へのリンクが生成されます。
``--mimetex``\ [=*URL*]
   TeX数式を\ `mimeTeX <http://www.forkosh.com/mimetex.html>`__\ CGIスクリプトによって生成します。
   *URL*\ が指定されていない場合は、スクリプトが\ ``/cgi-bin/mimetex.cgi``\ にあると仮定します。
``--webtex``\ [=*URL*]
   TeX数式を外部スクリプトを用いて生成します。スクリプトはTeX数式を画像に変換するものに限ります。数式は指定されたURLで連結されます。\ *URL*\ が指定されていない場合は、Google
   Chart APIが使用されます。

.. _options-for-wrapper-scripts:

ラッパースクリプトのためのオプション
------------------------------------

``--dump-args``
   コマンドライン引数に関する情報を標準出力\ *stdout*\ に出力し、終了します。
   このオプションは主にラッパースクリプトで使用するためのものです。
   出力の1行目は\ ``-o``\ オプションで指定された出力ファイル名（出力ファイルを指定していない場合は標準出力の\ ``-``\ ）が表示されます。
   残りの行は引数で指定した順番に、引数1つにつき1行ずつ出力します。
   通常、標準のPandocオプションおよびその引数はこれらには含まれませんが、
   セパレータ\ ``--``\ の後ろに付け足したオプションおよび引数に関しては出力されます。
``--ignore-args``
   コマンドライン引数を無視します（ラッパースクリプトで使用するためのオプションです）。
   標準のPandocオプションは無視されません。例えば、

   ::

      pandoc --ignore-args -o foo.html -s foo.txt -- -e latin1

   は以下と等価です：

   ::

      pandoc -o foo.html -s

.. _templates:

テンプレート
============

``-s/--standalone``\ オプションを使用している場合、Pandocは完全で独立した文書を生成するために、ヘッダとフッタをつけ加えるためのテンプレートを使用します。
デフォルトテンプレートを見るには、以下を実行してください（ただし\ ``FORMAT``\ は出力フォーマットの名前）：

::

   pandoc -D FORMAT

カスタムテンプレートは\ ``--template``\ オプションで指定することができます。
また、カスタムテンプレートをユーザデータディレクトリ（\ ``--data-dir``\ を参照）の
``templates/default.FORMAT``\ に置くことで、
与えられた出力フォーマット\ ``FORMAT``\ に対するシステムのデフォルトテンプレートの代わりに使用することができます。

*例外*\ ：\ ``odt``\ 出力については、\ ``default.opendocument``\ を使用して下さい。また、\ ``pdf``\ 出力については、\ ``default.latex``\ を使用して下さい。

テンプレートには\ *変数*\ が含まれます。変数名は英数字、\ ``-``\ および\ ``_``\ の並びから成り、1文字目は英字です。変数名を\ ``$``\ 記号で囲むと、その値に置換されます。
例えば、以下のような\ ``$title$``\ は

::

   <title>$title$</title>

その文書のタイトルに置き換えられます。

テンプレート内で\ ``$``\ を文字通りに入力したい場合は、\ ``$$``\ を使用して下さい。

いくつかの変数はPandocによって自動的に設定されます。これらは出力フォーマットによって変化しますが、メタデータフィールド（\ ``title``\ や\ ``author``\ 、\ ``date``\ など）と同様に以下も含みます：

``header-includes``
   ``-H/--include-in-header``\ によって指定されるコンテンツ（複数の値を取ることができます）
   ``toc``
   ``--toc/--table-of-contents``\ が指定されたときの非null値
   ``include-before``
   ``-B/--include-before-body``\ によって指定されるコンテンツ（複数の値を取ることができます）
   ``include-after``
   ``-A/--include-after-body``\ によって指定されるコンテンツ（複数の値を取ることができます）
   ``body``
   文書の本体(body) ``lang``
   HTMLまたはLaTeX文書の言語コード ``slidy-url``
   Slidy文書のベースURL（デフォルトは\ ``http://www.w3.org/Talks/Tools/Slidy2``\ ）
   ``slideous-url``
   Slideous文書のベースURL（デフォルトは\ ``slideous``\ ） ``s5-url``
   S5文書のベースURL（デフォルトは\ ``s5/default``\ ） ``revealjs-url``
   reveal.js文書のベースURL（デフォルトは\ ``reveal.js``\ ） ``theme``
   reveal.jsまたはLaTeX Beamerテーマ ``transition``
   reveal.jsのトランジション（遷移） ``fontsize``
   LaTeX文書のフォントサイズ（10pt, 11pt, 12pt） ``documentclass``
   LaTeX文書のドキュメントクラス ``classoption``
   LaTeXにおけるdocumentclassのオプション（例：\ ``oneside``\ ）；複数の値を繰り返し指定することができます
   ``geometry``
   LaTeXにおける\ ``geometry``\ クラスのオプション（例：\ ``margin=1in``\ ）；複数の値を繰り返し指定することができます
   ``linestretch``
   行間の空白の調整（\ ``setspace``\ パッケージが必要です）
   ``fontfamily``
   LaTeX文書で私用するフォントパッケージ（pdflatexにて有効）:
   TeXLiveには\ ``bookman`` (Bookman)、``utopia``\ または\ ``fourier``
   (Utopia)、 ``fouriernc`` (New Century
   Schoolbook)、\ ``times``\ または\ ``txfonts`` (Times)、
   ``mathpazo``\ または\ ``pxfonts``\ または\ ``mathpple`` (Palatino)、
   ``libertine`` (Linux Libertine)、\ ``arev`` (Arev Sans)、
   そしてデフォルトフォントの ``lmodern``\ 、その他があります。
   ``mainfont``, ``sansfont``, ``monofont``, ``mathfont``
   LaTeX文書のフォント（XeLaTeXまたはLuaLaTeXのみで有効） ``colortheme``
   LaTeX Beamer文書のcolortheme ``fonttheme``
   LaTeX Beamer文書のfonttheme ``linkcolor``
   LaTeX文書における内部リンクの色 （\ ``red``, ``green``, ``magenta``,
   ``cyan``, ``blue``, ``black``\ ） ``urlcolor``
   LaTeX文書における外部リンクの色 ``citecolor``
   LaTeX文書における引用リンクの色 ``links-as-notes``
   LaTeX文書においてリンクを脚注として表示 ``biblio-style``
   LaTeXにおける参考文献のスタイル（\ ``--natbib``\ とともに使用する際に）
   ``biblio-files``
   LaTeXで使用する参考文献ファイル（\ ``--natbib``\ または\ ``--biblatex``\ オプションで使用）
   ``section``
   manページにおけるセクション番号 ``header``
   manページにおけるヘッダ ``footer``
   manページにおけるフッタ

変数は\ ``-V/--variable``\ オプションを使用することで、コマンドラインから設定することができます。
このように設定された変数は同名のメタデータフィールドを上書きします。

テンプレートには条件分岐を含めることができます。文法は以下の通りです：

::

   $if(variable)$
   X
   $else$
   Y
   $endif$

この場合、\ ``variable``\ が非null値の場合に\ ``X``\ を適用し、そうでない場合は\ ``Y``\ を適用します。
``X``\ と\ ``Y``\ は有効なテンプレートテキストのプレースホルダーであり、変数やその他の条件分岐を含むことができます。

変数が複数の値からなる場合（例えば\ ``author``\ が複数の著者の場合）、\ ``$for$``\ キーワードを使用することができます：

::

   $for(author)$
   <meta name="author" content="$author$" />
   $endfor$

また、連続したアイテムとアイテムの間に使用するセパレータをオプションとして指定することもできます：

::

   $for(author)$$author$$sep$, $endfor$

ドット（\ ``.``\ ）はオブジェクト変数のフィールドを指定するのに使用できます。例えば：

::

   $author.name$ ($author.affiliation$)

カスタムテンプレートを使用する際には、Pandocのアップデートによる変更をそのテンプレートに反映させる必要があります。我々としては、デフォルトテンプレートの変更を追跡し、それに応じてあなたのカスタムテンプレートを変更することをお勧めします。これを行う簡単な方法として、pandoc-templatesリポジトリ(\ http://github.com/jgm/pandoc-templates)をフォークし、新しいPandocがリリースされた後に変更をマージすることができます。

.. _pandocs-markdown:

Pandocによる拡張Markdown
========================

Pandocは、拡張されわずかに改訂されたバージョンの、John
Gruberによる\ `markdown <http://daringfireball.net/projects/markdown/>`__\ の文法を解釈することができます。この文書ではその文法とともに、標準的なMarkdownとの差分を説明します。
注意として示したものを除いて、\ ``markdown``\ フォーマットの代わりに\ ``markdown_strict``\ を用いることでこれらの差分を無くした標準的なMarkdownを使用することができます。

拡張部分は、\ ``+EXTENSION``\ をフォーマット名につけ加えることで追加でき、\ ``-EXTENSION``\ をつけ加えることで無効にすることができます。例えば、\ ``markdown_strict+footnotes``\ は、厳密なMarkdownに加えて脚注機能を有効にします。一方で、\ ``markdown-footnotes-pipe_tables``\ はPandoc拡張Markdownから脚注とパイプテーブル形式の表を無効にします。

.. _philosophy:

哲学
----

Markdownは文書を書きやすいように設計され、さらに重要なこととして、文書を読みやすいように設計されています。

   A Markdown-formatted document should be publishable as-is, as plain
   text, without looking like it’s been marked up with tags or
   formatting instructions.

   Markdownで書かれた文書はプレーンテキストとして、そのままの形で発行されるべきである。
   しかし、タグや整形のための指示によってマークアップされているように見えてはならない。
   – `John
   Gruber <http://daringfireball.net/projects/markdown/syntax#philosophy>`__

この原則は、Pandocにおいて表、脚注やその他の拡張文法を設計する際の指針となっています。

しかしながら、ある1つの点においてPandocの目指すものはオリジナル版のそれとは異なります。
Markdownは本来、HTMLを生成することを目的として設計されたのに対し、Pandocは複数の出力フォーマットに対応するように設計されています。つまり、Pandocは生の(raw)HTMLを埋め込むことを許可する一方でそれを推奨せず、その代わりに定義リストや表、数式、脚注のように、重要な文書要素をHTMLらしくない表現によって提供しています。

.. _paragraphs:

段落
----

段落は1行以上のテキストと、それに続く1行以上の空行から成ります。
単なる改行はスペースとして扱われるので、段落を好きなように再構成するために使用できます。
強制改行が必要な場合は、行末に2個以上のスペースを置いてください。

**拡張: ``escaped_line_breaks``**

改行のあとのバックスラッシュも強制改行になります。

注意：マルチラインテーブルまたはグリッドテーブルのセルでは、この拡張は強制改行を行う唯一の手段になります。なぜならこれらのセル内では、行末のスペースが無視されるからです。

.. _headers:

ヘッダ
------

Setext形式とATX形式の2種類のヘッダ形式が使用できます。

Setext形式のヘッダ
~~~~~~~~~~~~~~~~~~

Setext形式のヘッダは「下線を引いた」テキストです。ヘッダのテキスト部分の下に、\ ``=``\ 記号（レベル1ヘッダ）または\ ``-``\ 記号（レベル2ヘッダ）を並べた行を置きます：

::

   レベル1ヘッダ
   ============

   レベル2ヘッダ
   ------------

ヘッダのテキストは強調のようなインライン形式の修飾を含むことができます（下記の\ `インライン形式の修飾 <#inline-formatting>`__\ を参照）。

ATX形式のヘッダ
~~~~~~~~~~~~~~~

ATX形式のヘッダは1〜6個の\ ``#``\ 記号および1行のテキストから成り、オプションで任意の数の\ ``#``\ 記号をその末尾につけることができます。先頭の\ ``#``\ 記号の数はヘッダレベルを表します：

::

   ## レベル2ヘッダ

   ### レベル3ヘッダ ###

   ### ヘッダの後ろにはいくらでも`#`を付けてもよい ######

Setext形式のヘッダと同様に、ヘッダにはテキスト修飾を含むことができます。

::

   # レベル1ヘッダと [リンク](/url) そして *強調*

**拡張: ``blank_before_header``**

標準的なMarkdown文法では「ヘッダの前に空行を入れる」という制約がありません。
Pandocではこの制約を付けています（もちろん、文書の先頭を除きます）。
なぜなら、\ ``#``\ 記号は行頭にうっかり付けてしまうことが多いからです（もしかすればエディタによる行の折り返しでもそうなるかもしれません）。以下の例を考えてみてください：

::

   I like several of their flavors of ice cream:
   #22, for example, and #5.

.. _header-identifiers-in-html-latex-and-context:

HTML, LaTeX, そしてConTeXtにおけるヘッダ識別子
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**拡張: ``header_attributes``**

ヘッダテキストを含む行の最後にこの文法を用いることで、ヘッダに属性(attribute)を付けることができます：

::

   {#identifier .class .class key=value key=value}

この文法によりクラスとキー/値の属性を付けることができますが、識別子のみが現在のところWriterに影響を与えます（そしてそれは一部のWriterのみです：HTML,
LaTeX, ConTeXt, Textile,
AsciiDoc）。つまり、例えば、以下のようなヘッダには\ ``foo``\ という識別子が割り当てられます：

::

   # ヘッダ {#foo}

   ## ヘッダ ##    {#foo}

   他のヘッダ  {#foo}
   ----------

（この文法は\ `PHP Markdown
Extra <http://michelf.ca/projects/php-markdown/extra/#table>`__\ と互換性があります。）

``unnumbered``\ クラスを付けたヘッダには、たとえ\ ``--number-sections``\ オプションが指定されていても番号が付きません。単一のハイフン(\ ``-``)を属性として使うと\ ``.unnumbered``\ と等価な意味になります（非英語圏の文書に適しています）。よって、

::

   # ヘッダ {-}

は以下と同じ意味になります：

::

   # ヘッダ {.unnumbered}

**拡張: ``auto_identifiers``**

識別子を明示的に指定していないヘッダは、ヘッダのテキストを元にして自動的に識別子が割り当てられます。
ヘッダテキストから識別子を生成するために以下の処理を行います：

-  全ての修飾やリンクなどを取り除く
-  全ての脚注を取り除く
-  アンダースコアやハイフン、ピリオド以外の全ての記号を取り除く
-  全てのスペースと改行をハイフンに置換する
-  全ての英字を小文字に置換する
-  最初の英字より前にある文字を全て取り除く（識別子は数字や記号から始まってはならない）
-  その結果何も残らなければ、識別子を\ ``section``\ とする

よって、例えば以下のようになります：

============================== ==============================
ヘッダ                         識別子
============================== ==============================
``Header identifiers in HTML`` ``header-identifiers-in-html``
``*Dogs*?--in *my* house?``    ``dogs--in-my-house``
``[HTML], [S5], or [RTF]?``    ``html-s5-or-rtf``
``3. Applications``            ``applications``
``33``                         ``section``
============================== ==============================

訳注：ヘッダテキストが日本語の場合は、多くの場合、識別子も日本語テキストがそのまま割り当てられます。識別子が日本語の場合、HTMLやLaTeXなどで識別子が正しく動くかどうかは処理系に依存するため、ヘッダには英数字による識別子を明示的に与えることを推奨します。

これらのルールはほとんどの場合、1つのヘッダテキストから1つの識別子を決定できます。
例外としてはいくつかのヘッダが同じテキストである場合があり、この場合、最初のヘッダについては上記の通りに識別子が決まります。2番目のヘッダからは末尾に\ ``-1``\ がついた識別子が得られ、3番目は\ ``-2``\ がつき、以下同様です。

これらの識別子は\ ``--toc|--table-of-contents``\ オプションによって生成される目次におけるリンクターゲットを生成するのに使われます。これらはまた、文書中の1つの節から他へのリンクをより簡単にします。例えば、この節へのリンクは以下の通りになるでしょう（訳注：この節の原題は
“Header identifiers in HTML, LaTeX, and ConTeXt” です）：

::

   以下の節をご覧ください：
   [HTML, LaTeX, そしてConTeXtにおけるヘッダ識別子](#header-identifiers-in-html-latex-and-context).

注意：節へのリンクを提供するこの方法は、HTML, LaTeX,
ConTeXtフォーマットのみで有効です。

HTMLフォーマットにおいて\ ``--section-divs``\ オプションが指定されている場合は、各節が\ ``div``\ （\ ``--html5``\ が指定されている場合は\ ``section``\ ）で囲まれます。そしてその識別子はヘッダそのものとしてでなく、\ ``<div>``\ タグ（または\ ``<section>``\ タグ）の内部に埋め込まれます。これは節全体をJavaScriptで操作したり、CSSで扱ったりする際に使うことができます。

**拡張: ``implicit_header_references``**

Pandocはそれぞれのヘッダに対し参照リンクが定義されているかのように振る舞います。よって、

::

   [header identifiers](#header-identifiers-in-html)

の代わりに、下記のように

::

   [header identifiers]

や

::

   [header identifiers][]

や

::

   [the section on header identifiers][header identifiers]

のように書くことができます。

同一のテキストに対して複数のヘッダが存在する場合は、それらのうち最初のヘッダに対してリンクされます。
その他へのリンクについては、上記で説明したように、明示的なリンクとして書く必要があります。

標準的な参照リンクとは違い、これらの参照は大文字・小文字を区別します。

注意：あるヘッダに対して明示的に識別子を指定した場合は、暗黙の参照は無効になります。

.. _block-quotations:

引用
----

Markdownはテキストの引用についてEメールの慣習を踏襲しています。
引用は各行が\ ``>``\ と1つのスペースから始まる、1つ以上の段落またはブロック要素（リストやヘッダなど）から成ります。
（\ ``>``\ は左端から始まる必要はありませんが、4つ以上のスペースでインデントされてはなりません。）

::

   > これは引用です。この
   > 段落は2行で構成されています。
   >
   > 1. これは引用内部にあるリストです。
   > 2. 2つ目のアイテムです。

怠惰(lazy)な形、つまり\ ``>``\ が各ブロックの最初の行だけにある形も有効です：

::

   > これは引用です。この
   段落は2行で構成されています。

   > 1. これは引用内部にあるリストです。
   2. 2つ目のアイテムです。

引用に含むことができるブロック要素として、他のブロック要素があります。すなわち、引用は入れ子（ネスト）にすることができます：

::

   > これは引用です。
   >
   > > 引用の中の引用です。

**拡張: ``blank_before_blockquote``**

標準的なMarkdown文法では「引用の前に空行を入れなければならない」という制約がありません。Pandocではこの制約を付けています（もちろん、文書の先頭は除きます）。なぜなら、\ ``>``\ 記号は行頭にうっかり付けてしまうことが多いからです（もしかすればエディタによる行の折り返しでもそうなるかもしれません）。そのためPandocでは、\ ``markdown_strict``\ フォーマットを使わない限りは、以下の例において入れ子の引用を生成しません：

::

   > これは引用です。
   >> 入れ子です。

.. _verbatim-code-blocks:

コードブロック
--------------

インデントによるコードブロック
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

4つのスペース（または1つのタブ）でインデントされたテキストブロックは入力通りの出力(verbatim)、つまりコードブロックとして扱われます。具体的には、特別な文字が特別な整形や修飾を意味せず、全てのスペースや改行が保持されます。例えばこのような記法です：

::

       if (a > 3) {
         moveShip(5 * gravity, DOWN);
       }

最初のインデント（4つのスペースまたは1つのタブ）はコードブロックとして扱われず、出力の際には削除されます。

注意：コードブロックの空行は4つのスペースで始まる必要はありません。

囲まれた(fenced)コードブロック
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**拡張: ``fenced_code_blocks``**

標準的なインデントコードブロックに加え、Pandocは\ *囲まれた(fenced)*\ コードブロックもサポートしています。これは3つ以上のチルダ(\ ``~``)またはバックスラッシュ(\ :literal:`\``)の行で始まり、同じものの行で終わります。チルダやバックスラッシュの数は、始まりの行と終わりの行で同じでなければなりません。その2行の間に挟まる行はコードとして解釈されます。インデントは必要ありません：

::

   ~~~~~~~
   if (a > 3) {
     moveShip(5 * gravity, DOWN);
   }
   ~~~~~~~

標準的なコードブロックと同様に、囲まれたコードブロックも空行で囲まれている必要があります。

コード自身にチルダまたはバックスラッシュが含まれている場合は、より長いチルダまたはバックスラッシュの行で囲んでください：

::

   ~~~~~~~~~~~~~~~~
   ~~~~~~~~~~
   チルダの入ったコード
   ~~~~~~~~~~
   ~~~~~~~~~~~~~~~~

オプションとして、コードブロックに対して以下のような文法を用いて属性を付けることができます：

::

   ~~~~ {#mycode .haskell .numberLines startFrom="100"}
   qsort []     = []
   qsort (x:xs) = qsort (filter (< x) xs) ++ [x] ++
                  qsort (filter (>= x) xs)
   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ここで\ ``mycode``\ は識別子、\ ``haskell``\ と\ ``numberLines``\ はクラス、\ ``startFrom``\ は値\ ``100``\ の属性です。いくつかの出力フォーマットではこの情報をシンタックスハイライトに使います。現在のところ、HTMLおよびLaTeX出力フォーマットのみがこの情報を使います。シンタックスハイライトがサポートされている出力フォーマットおよび言語では、上記のコードブロックは色つきになり、行番号が付きます（どの言語がサポートされているかを知るには、\ ``pandoc --version``\ を実行してください）。その他の表記として、上記のコードブロックは以下のようになります：

::

   <pre id="mycode" class="haskell numberLines" startFrom="100">
     <code>
     ...
     </code>
   </pre>

短縮形として、言語を指定するタイプのコードブロックも使用できます：

::

   ```haskell
   qsort [] = []
   ```

これは下記と等価です：

::

   ``` {.haskell}
   qsort [] = []
   ```

シンタックスハイライトを無効にするには\ ``--no-highlight``\ オプションを使用してください。
シンタックスハイライトのスタイルを指定するには、\ ``--highlight-style``\ オプションを使用してください。

.. _code-highlighting:

訳注：シンタックスハイライトが可能なプログラミング言語
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Pandoc 1.12.2.1
においてシンタックスハイライトが可能なプログラミング言語は以下の通りです：

::

   actionscript, ada, apache, asn1, asp, awk, bash, bibtex, boo, c, changelog,
   clojure, cmake, coffee, coldfusion, commonlisp, cpp, cs, css, curry, d,
   diff, djangotemplate, doxygen, doxygenlua, dtd, eiffel, email, erlang,
   fortran, fsharp, gnuassembler, go, haskell, haxe, html, ini, java, javadoc,
   javascript, json, jsp, julia, latex, lex, literatecurry, literatehaskell,
   lua, makefile, mandoc, markdown, matlab, maxima, metafont, mips, modelines,
   modula2, modula3, monobasic, nasm, noweb, objectivec, objectivecpp, ocaml,
   octave, pascal, perl, php, pike, postscript, prolog, python, r,
   relaxngcompact, rhtml, roff, ruby, rust, scala, scheme, sci, sed, sgml, sql,
   sqlmysql, sqlpostgresql, tcl, texinfo, verilog, vhdl, xml, xorg, xslt, xul,
   yacc, yaml

.. _line-blocks:

ラインブロック
--------------

**拡張: ``line_blocks``**

ラインブロックは縦線(\ ``|``)と1つのスペースで始まる行を続けて並べたものです。
行の分割は出力にそのまま反映され、先頭のスペースもそのまま保持されます。各行はMarkdown記法で修飾されます。
この記法は詩（韻文）や住所を書く際に便利です。

::

   | The limerick packs laughs anatomical
   | In space that is quite economical.
   |    But the good ones I've seen
   |    So seldom are clean
   | And the clean ones so seldom are comical

   | 200 Main St.
   | Berkeley, CA 94718

行は必要であれば強制改行できますが、続きの行はスペースで始まる必要があります：

::

   | The Right Honorable Most Venerable and Righteous Samuel L.
     Constable, Jr.
   | 200 Main St.
   | Berkeley, CA 94718

この文法は\ `reStructuredText <http://docutils.sourceforge.net/docs/ref/rst/introduction.html>`__\ から借りたものです。

.. _lists:

リスト
------

記号付きリスト
~~~~~~~~~~~~~~

記号付きリストは行頭に記号の付いたアイテムのリストです。記号付きリストのアイテムの行頭には記号(\ ``*``,
``+``, ``-``\ のいずれか)を付けます。以下に例を示します：

::

   * ひとつめ
   * ふたつめ
   * みっつめ

このリストは「コンパクト」なリストを生成します。もっと「緩い(loose)」リストが欲しい場合、つまり各アイテムが段落として整形されてほしい場合は、アイテムとアイテムの間に空行を置きましょう：

::

   * ひとつめ

   * ふたつめ

   * みっつめ

行頭の記号は行頭に揃っている必要はなく、1〜3個のスペースによるインデントがあっても構いません。記号の後ろには必ずスペースを置く必要があります。

リストのアイテムは後続の行が先頭の行（記号を除いたテキスト）に揃っていればベストです：

::

   * これは最初の
     リストアイテムです。
   * そしてこれは二番目です。

しかしMarkdownでは下記のような緩い(“lazy”)な形式でもOKです：

::

   * これは最初の
   リストアイテムです。
   * そしてこれは二番目です。

.. _the-four-space-rule:

フォー・スペース・ルール
~~~~~~~~~~~~~~~~~~~~~~~~

リストアイテムは複数の段落や他のブロックレベルのコンテンツを含むことができます。しかし、後続の段落の前には空行を置き、次に4つのスペース（または1つのタブ）を置く必要があります。このリストは最初の段落に残りの要素を揃えていればベストでしょう：

::

     * 最初の段落です。

       続きです。

     * 二番目の段落です。コードブロックは8つのスペースで
       インデントされている必要があります：

           { code }

リストのアイテムは他のリストを含むことができます。この場合、続く空行があってもなくても構いません。入れ子になったリストは4つのスペースまたは1つのタブでインデントされている必要があります：

::

   * フルーツ
       + りんご
           - サンふじ
           - 紅玉
       + なし
       + もも
   * 野菜
       + ブロッコリー
       + セロリ

上記で言及したように、Markdownではリストアイテムをちゃんとインデントする代わりに「緩く」書くことができます。
しかし、複数の段落やリストアイテム中の他のブロックがある場合は、そのアイテムの1行目はインデントされている必要があります。

::

   + ゆるいゆるいリスト
   アイテム。

   + もうひとつ。お行儀はよくないけど
   正しい文です。

       二番目のリストアイテムの、二番目の段落
   です。

**注意**:
連続する段落に対するフォー・スペース・ルールはオフィシャルの\ `markdown
syntax
guide <http://daringfireball.net/projects/markdown/syntax#list>`__\ に由来しますが、その実装である\ ``Markdown.pl``\ はそのガイドに従っていません。よって文書の作者が4つ未満のスペースでインデントされた、連続する段落を書いた場合、Pandocにおけるその振る舞いは\ ``Markdown.pl``\ とは異なります。

この\ `markdown syntax
guide <http://daringfireball.net/projects/markdown/syntax#list>`__\ ではフォー・スペース・ルールがリストアイテム内で\ *全ての*\ ブロックレベルのコンテンツに対して適用されるかどうかについては明示していません。ただ段落とコードブロックに対して言及しているのみです。しかしこのルールが全てのブロックレベルのコンテンツ（入れ子のリストを含む）に対して適用されることは暗に示されており、Pandocではそのように解釈しています。

.. _ordered-lists:

順序付きリスト
~~~~~~~~~~~~~~

順序付きリストは記号付きリストのように働きますが、アイテムの先頭に記号ではなく番号が振られます。

標準的なMarkdownでは、番号は10進の数字で、その後ろにピリオドと1つのスペースを付けます。
この番号自体は無視されるので、以下のリストと

::

   1.  ひとつめ
   2.  ふたつめ
   3.  みっつめ

以下のリストの出力は全く同じです：

::

   5.  ひとつめ
   7.  ふたつめ
   1.  みっつめ

**拡張: ``fancy_lists``**

標準的なMarkdownとは違い、Pandocでは数字に加えて、大文字または小文字の英字、あるいはローマ数字を番号（リストマーカ）として使った順序付きリストを作ることができます。リストマーカは括弧で囲むか、その後ろに閉じ括弧またはピリオドを置くことができます。この部分とテキストは1つ以上のスペースで区切られている必要があり、リストマーカが大文字とピリオドで構成されている場合は、2つ以上のスペースで区切られる必要があります。 [1]_

``fancy_lists``\ 拡張はまた、\ ``#``\ を順序付きリストのマーカーとして数字の代わりに使用することができます：

::

   #. ひとつめ
   #. ふたつめ

**拡張: ``startnum``**

Pandocはリストマーカの型とその始まりの番号を認識し、出力の際には可能な限り保持します。つまり、下記の例では、番号が9から始まる閉じ括弧付き番号付きリストと、そのサブリストとして小文字のローマ数字付きリストを与えます：

::

    9)  Ninth
   10)  Tenth
   11)  Eleventh
          i. subone
         ii. subtwo
        iii. subthree

Pandocは異なる型のリストマーカが使用される度に、新しいリストを開始します。よって、下記の例では3つのリストが生成されます：

::

   (2) Two
   (5) Three
   1.  Four
   *   Five

デフォルトのリストマーカがお望みであれば、\ ``#.``\ を使えます。

::

   #.  one
   #.  two
   #.  three

.. _definition-lists:

定義リスト
~~~~~~~~~~

**拡張: ``definition_lists``**

Pandocは定義リストをサポートします。この文法は\ `PHP Markdown
Extra <http://michelf.ca/projects/php-markdown/extra/#table>`__\ と\ `reStructuredText <http://docutils.sourceforge.net/docs/ref/rst/introduction.html>`__\ から着想を得たものです： [2]_

::

   用語1

   :   定義1

   *インラインマークアップ*の入った用語2

   :   定義2

           { コード、定義2の一部 }

       定義2の3つ目の段落。

各用語は1行に収まっている必要がありますが、空行をその後ろに続けることができます。その用語の後ろには、必ず1つ以上の定義を続ける必要があります。定義は1つのコロンまたはチルダで始めますが、1〜2個のスペースでインデントしても構いません。定義の本体（最初の行のうちコロン又はチルダの右側も含む）は4つのスペースでインデントするべきです。1つの用語は複数の定義を持つことができ、各定義は4つのスペース（または1つのタブ）によるインデントとともに、1つ以上のブロック要素（段落、コードブロック、リストなど）で構成できます。

（上記の例で示したように）定義の後ろに空行を入れた場合、そのブロックは段落として解釈されます。いくつかの出力フォーマットでは、この空行は用語/定義のペアの間の空白よりも大きな意味を持つ場合があります。コンパクトな定義リストの場合、前の定義と次の用語の間に空行を作らないでください：

::

   用語1
     ~ 定義1
   用語2
     ~ 定義2a
     ~ 定義2b

.. _numbered-example-lists:

順序付き例示リスト
~~~~~~~~~~~~~~~~~~

**拡張: ``example_lists``**

特別なリストマーカ\ ``@``\ は順序付きの例を順に列挙する場合に使用できます。1番目の\ ``@``\ マーカ付きリストアイテムは番号’1’が振られ、2番目のアイテムは’2’となり、文書の最後まで以下同様になります。順序付き例示リストは1つのリストに収まっている必要はありません。\ ``@``\ を使った新しいリストは最後に使ったリストの番号を引き継ぎます。例えば：

::

   (@)  最初の例には番号(1)が付きます。
   (@)  2番目の例には番号(2)が付きます。

   ここで例を説明。

   (@)  3番目の例には番号(3)が付きます。

順序付き例示リストはラベルを付けることができ、文書中で参照することができます：

::

   (@good)  This is a good example.

   As (@good) illustrates, ...

このラベルは英数字およびアンダースコア、ハイフンから成る文字列です。

.. _compact-and-loose-lists:

コンパクトなリスト、ルーズなリスト
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Pandocは\ ``Markdown.pl``\ とは違い、リストに関して「微妙な場合」で振るまいが異なります。以下の例を考えてみましょう：

::

   +   ひとつめ
   +   ふたつめ：
       -   ほげ
       -   ふが
       -   ぴよ

   +   みっつめ

Pandocはこれを「コンパクトなリスト」（「ひとつめ」「ふたつめ」「みっつめ」に対して\ ``<p>``\ タグで囲まない）に変換します。一方、\ ``Markdown.pl``\ では、「みっつめ」の周りに空行があるので、（「ひとつめ」を飛ばして）\ ``<p>``\ タグを「ふたつめ」と「みっつめ」に付けます。Pandocは「もしテキストの下に空行があれば、そのテキストを1つの段落として扱う」という単純なルールに従います。「ふたつめ」の下には空行ではなくリストがあるため、「ふたつめ」は段落として扱いません。入れ子になっているリストの下に空行があるという事実は重要ではありません。（注意：Pandocは\ ``markdown_strict``\ フォーマットが指定されているときでも、このように動作します。この振る舞いはオフィシャルのMarkdown文法の解説と矛盾しませんが、\ ``Markdown.pl``\ の振る舞いとは異なります。）

.. _ending-a-list:

リストの終わり
~~~~~~~~~~~~~~

では、インデントコードブロックをリストの後に置きたい場合はどうでしょうか？

::

   -   ひとつめ
   -   ふたつめ

       { コードブロック }

困りました！ここでPandocでは（他のMarkdown実装のように）\ ``{ コードブロック }``\ を、「ふたつめ」の2つ目の段落として解釈するため、コードブロックとして解釈されません。

「ふたつめ」の後ろのコードブロックをそのリストから「切り離す」ために、インデントされていないコンテンツを挿入することができます。HTMLコメントのような、どのフォーマットでも目に見える出力がされないようなものがよいでしょう。

::

   -   ひとつめ
   -   ふたつめ

   <!-- リストの終わり -->

       { コードブロック }

同様に、下記のように1つの大きなリストにするのではなく2つのリストに分けたいときも、同じ裏技が使用できます。

::

   1.  ワン
   2.  ツー
   3.  スリー

   <!-- -->

   1.  アン
   2.  ドゥ
   3.  トロワ

.. _horizontal-rules:

水平線
------

3つ以上の ``*``, ``-``, ``_``
から成る行は水平線になります（オプションでスペースを入れても構いません）。

::

   *  *  *  *

   ---------------

.. _tables:

表
--

4種類の表（テーブル）が使用できます。最初の3種類はCourierのような等幅フォントの使用を前提とします。4種類目はプロポーショナルフォントの使用が可能で、列を左右・中央に寄せるために列のテキストを左右に移動する必要もありません。

シンプルテーブル
~~~~~~~~~~~~~~~~

**拡張: ``simple_tables``, ``table_captions``**

シンプルテーブルはこのように書けます：

::

     Right     Left     Center     Default
   -------     ------ ----------   -------
        12     12        12            12
       123     123       123          123
         1     1          1             1

   Table:  シンプルテーブルのデモ

表のヘッダと行はそれぞれ1行に収まっている必要があります。列を左右・中央のどちらに寄せるかは、ヘッダの下にある’\ ``-``\ ’の線（以下、ヘッダ下線）に対するヘッダテキストの位置で決まります： [3]_

-  ヘッダ下線とヘッダテキストが右側で揃っており、ヘッダ下線が左側にはみ出している場合は、列は右寄せとなります。
-  ヘッダ下線とヘッダテキストが左側で揃っており、ヘッダ下線が右側にはみ出している場合は、列は左寄せとなります。
-  ヘッダ下線がヘッダテキストに対して両側にはみ出している場合は、列は中央寄せとなります。
-  ヘッダ下線とヘッダテキストの幅が等しい場合は、デフォルトの方法で列を寄せます（たいていの場合は左寄せとなります）。

表は空行で終わっている必要があります。あるいは、’\ ``-``\ ’を並べた線の行の後に空行をつけ加えたもので終わることもできます。表題(caption)は上記の例で示したとおり、オプションで付けることができます。表題は\ ``Table:``\ （または単に\ ``:``\ ）で始まる段落で、この\ ``Table:``\ の部分は出力の際に取り除かれます。表題は表の前か後に付けることができます。

列のヘッダは省略可能ですが、その場合は’\ ``-``\ ’の線を表の最後に付けてください。例を示します：

::

   -------     ------ ----------   -------
        12     12        12             12
       123     123       123           123
         1     1          1              1
   -------     ------ ----------   -------

ヘッダが省略された場合は、列の寄せ方は表本体(body)の1行目がどう寄せられているかで決まります。つまり、上記の例では、列はそれぞれ右寄せ、左寄せ、中央寄せ、右寄せの順になります。

マルチラインテーブル
~~~~~~~~~~~~~~~~~~~~

**拡張: ``multiline_tables``, ``table_captions``**

マルチラインテーブルでは、表のヘッダと行のセル内部に複数の行を入れることができます（ただしセルの結合はサポートしていません）。例を示します：

::

   -------------------------------------------------------------
    Centered   Default           Right Left
     Header    Aligned         Aligned Aligned
   ----------- ------- --------------- -------------------------
      First    row                12.0 Example of a row that
                                       spans multiple lines.

     Second    row                 5.0 Here's another one. Note
                                       the blank line between
                                       rows.
   -------------------------------------------------------------

   Table: 表題がここに入ります。
   複数の行です。

この表はシンプルテーブルと同様に働きますが、下記のような違いがあります：

-  ヘッダテキストの前の行（1行目）は’\ ``-``\ ’を並べた線の行でなければならない（ただしヘッダが無い場合は除く）。
-  最終行には’\ ``-``\ ’を並べた線の行と、それに続く空行を置かなければならない。
-  それぞれの行は空行で区切られなければならない。

マルチラインテーブルにおいて、PandocのReaderは列の幅をチェックしており、Writerはそれに応じて相対的に幅を調節して出力しようとします。よって、ある列が必要以上に狭く出力されてしまった場合は、Markdownのソースにてその列を広げてみてください。

マルチラインテーブルでも、シンプルテーブルと同様にヘッダを省略することができます。

::

   ----------- ------- --------------- -------------------------
      First    row                12.0 Example of a row that
                                       spans multiple lines.

     Second    row                 5.0 Here's another one. Note
                                       the blank line between
                                       rows.
   ----------- ------- --------------- -------------------------

   : ヘッダのないマルチラインテーブルです。

マルチラインテーブルでは1行だけを保持することができますが、その行の下には空行を入れるべきです（そして表の最後には’\ ``-``\ ’を並べた行を入れます）。そうしなければ、表がシンプルテーブルと解釈されてしまう場合があります。

グリッドテーブル
~~~~~~~~~~~~~~~~

**拡張: ``grid_tables``, ``table_captions``**

グリッドテーブルはこのような表です：

::

   : グリッドテーブルのサンプル。

   +---------------+---------------+--------------------+
   | 果物           | 値段          | 利点                |
   +===============+===============+====================+
   | バナナ         | $1.34         | - むきやすい        |
   |               |               | - 明るい色          |
   +---------------+---------------+--------------------+
   | オレンジ       | $2.10         | - ビタミンCが豊富    |
   |               |               | - おいしい          |
   +---------------+---------------+--------------------+

’\ ``=``\ ’を並べた行はヘッダと表本体を分割しますが、ヘッダを省略したい場合には無くても構いません。グリッドテーブルのセルには任意のブロック要素（複数の段落、コードブロック、リストなど）を含めることができます。列の右寄せ・中央寄せやセルの結合はサポートされていません。グリッドテーブルは\ `Emacs
table
mode <http://table.sourceforge.net/>`__\ を用いることで簡単に作成することができます。

パイプテーブル
~~~~~~~~~~~~~~

**拡張: ``pipe_tables``, ``table_captions``**

パイプテーブルは下記のような表です：

::

   |右寄せ | 左寄せ|デフォルト|中央寄せ|
   |------:|:-----|---------|:------:|
   |   12  |  12  |    12   |    12  |
   |  123  |  123 |   123   |   123  |
   |    1  |    1 |     1   |     1  |

     : パイプテーブルのデモ

文法は\ `PHP markdown
extra <http://michelf.ca/projects/php-markdown/extra/#table>`__\ と同じです。始まりと終わりのパイプ文字(\ ``|``)は無くても構いませんが、パイプは全ての列と列の間に挟む必要があります。コロンは列のテキストを寄せる方向を示します。ヘッダは省略可能ですが、列を寄せる方向を決めるために水平線の行は含めなければなりません。

パイプは列の境界を示すため、上記の例で示したとおり、列自体はテキストを左右に寄せたりして整形する必要がありません。つまり、下記は全く正しい（が、汚い）パイプテーブルの例です：

::

   果物| 値段
   -----|-----:
   りんご|2.05
   なし|1.37
   オレンジ|3.09

パイプテーブルのセルには段落やリストのようなブロック要素を含めることができず、セルに複数行を入れることもできません。

メモ：Pandocは下記のような形式のパイプテーブルも認識できます。これはEmacsのorgtbl-modeで用いられるものです：

::

   | 1つ目   | 2つ目 |
   |---------+------|
   | この    | 表は  |
   | なかなか| よい  |

違いは’\ ``|``\ ‘の代わりに’\ ``+``\ ’を使っている点です。他のorgtblの機能はサポートされていません。特に、デフォルトでない列テキストの寄せ方をする場合は、上記のようにコロンを付ける必要があります。

.. _title-block:

タイトルブロック
----------------

**拡張: ``pandoc_title_block``**

ファイルがこのようなタイトルブロックで始まっている場合は、

::

   % タイトル
   % 著者 (複数の場合はセミコロンで区切る)
   % 日付

これらは通常のテキストではなく文書の情報として認識されます。（例えば、スタンドアローンなLaTeXまたはHTMLのタイトルに使われます。）このブロックには「タイトルのみ」「タイトル、著者」「タイトル、著者、日付」のいずれかの組み合わせを含めることができます。もし「著者のみ」（タイトルなし）をブロックに含めたい場合は、空行を入れる必要があります：

::

   %
   % 著者

   % タイトル
   %
   % 2006年6月15日

タイトルには複数行を入れることができますが、2行目以降には次のようにテキストの前にスペースを入れる必要があります：

::

   % 複数行の
     タイトル

ドキュメントに複数の著者を含めたい場合は、複数行で書く（2行目以降の前にはスペースを入れる）か、セミコロンで区切るか、その両方で書くことができます。よって、下記の3つは全て等価です：

::

   % 著者1
     著者2

   % 著者1; 著者2

   % 著者1;
     著者2

日付は1行で書く必要があります。

上記3つのメタデータフィールドには標準的なインライン形式の修飾（斜体、リンク、脚注など）を入れることができます。

タイトルブロックは読み込み時において常に解釈されますが、\ ``--standalone``
(``-s``)
オプションが選択されたときに限り、出力に影響を与えます。HTML出力においては、タイトルは2箇所に影響を与えます。1つ目は\ ``<head>``\ タグ内部で、これはブラウザウィンドウの上部に表れるタイトルです。2つ目は\ ``<body>``\ タグに入って最初の部分です。\ ``<head>``\ タグ内部のタイトルについては、接頭辞を与えることができます（\ ``--title-prefix``\ または\ ``-T``\ オプション）。\ ``<body>``\ タグに入ってすぐのタイトルは、class=“title”のH1要素として表れるので、CSSを用いて消去したり書式を変えたりすることができます。タイトルの接頭辞が\ ``-T``\ によって指定され、タイトルブロックが文書中に無い場合は、タイトルの接頭辞そのものがHTMLのタイトルとして使用されます。

manページのWriterはタイトル行からタイトル、manページのセクション番号、その他のヘッダ又はフッタ情報を取得します。このWriterはタイトル行の最初の単語(word)をタイトルとして解釈します。このタイトルは括弧に囲まれたセクション番号（1桁の数字）で終わることもできます。（タイトルと括弧の間にはスペースを入れてはなりません。）この後に足される全てのテキストは、追加のフッタ又はヘッダテキストと解釈されます。パイプ記号(\ ``|``)はフッタとヘッダを区切るセパレータとなります。つまり、

::

   % PANDOC(1)

は、タイトルが\ ``PANDOC``\ でセクション1のmanページをもたらします。

::

   % PANDOC(1) Pandoc User Manuals

は、上記に加え、“Pandoc User Manuals”をフッタに加えます。

::

   % PANDOC(1) Pandoc User Manuals | Version 4.0

は、上記に加え、“Version 4.0”をヘッダに加えます。

.. _yaml-metadata-block:

YAMLメタデータブロック
----------------------

**拡張: ``yaml_metadata_block``**

YAMLメタデータブロックは正当なYAMLオブジェクトであり、最初の行が3つのハイフン(\ ``---``)の行、最後の行が3つのハイフン(\ ``---``)または3つのドット(\ ``...``)であるブロックです。YAMLメタデータブロックは文書中の任意の場所に置くことができますが、先頭に置く場合を除いて、必ず空行の後にこのブロックを置く必要があります。

メタデータはYAMLオブジェクトのフィールドから取得され、文書中の既存のメタデータに対して追加されます。メタデータにはリストやオブジェクトを含むことができます（適宜、入れ子にもできます）。しかし全ての文字列スカラ値はMarkdownとして解釈されます。アンダースコアで終わっている名前付きフィールドはPandocでは無視されます。（これらは外部の処理系によって与えられる場合があります。）

1つの文書には複数のメタデータブロックを含むことができます。複数のメタデータフィールドは\ *left-biased
union*\ ルールにより統合されます。つまり、2つのメタデータブロックが同じフィールドを定義しようとする場合、最初のブロックの値が採用されます。

注意：YAMLのエスケープルールは以下の通りです。例えば、タイトルにコロンが含まれる場合は、引用符(\ ``'``)で囲む必要があります。パイプ文字(\ ``|``)はインデントブロックの始めに使うことができ、このブロックは（エスケープする必要がなく）文字通りに表示されます。この形式は空行をフィールドに含める際に必要となります：

::

   ---
   title:  'これはタイトルです: コロンを含んでいます'
   author:
   - name: 著者1
     affiliation: どこかの大学
   - name: 著者2
     affiliation: どこにもない大学
   tags: [nothing, nothingness]
   abstract: |
     これは概要です。

     2つの段落で構成されています。
   ...

テンプレート変数にはメタデータからの値が自動的にセットされます。つまり、例えば、HTMLを書き出す場合、変数\ ``abstract``\ はMarkdown中の\ ``abstract``\ フィールドに等しいものがHTML文書にセットされます：

::

   <p>これは概要です。</p>
   <p>2つの段落で構成されています。</p>

注意：デフォルトテンプレートにおける変数\ ``author``\ には単純なリストまたは文字列が入ることを仮定しています。上記の例に示したような複雑な構造のauthorフィールドを利用するには、下記のようなカスタムテンプレートを使用する必要があるでしょう：

::

   $for(author)$
   $if(author.name)$
   $author.name$$if(author.affiliation)$ ($author.affiliation$)$endif$
   $else$
   $author$
   $endif$
   $endfor$

.. _backslash-escapes:

バックスラッシュ・エスケープ
----------------------------

**拡張: ``all_symbols_escapable``**

コードブロックやインサイドコードを除き、バックスラッシュの次にある任意の記号やスペース文字は、文字通りに扱われます。これはテキスト修飾を表す記号に対しても同様です。例えば、

::

   *\*hello\**

は下記と等価であり、

::

   <em>*hello*</em>

下記とは異なります：

::

   <strong>hello</strong>

このルールはMarkdownの標準ルールよりも覚えやすいものです。Markdownの標準ルールでは、下記の記号のみがバックスラッシュでエスケープできます：

::

   \`*_{}[]()>#+-.!

（しかし、\ ``markdown_strict``\ フォーマットが指定された場合は、Markdownの標準ルールが適用されます。）

バックスラッシュでエスケープされたスペースは、改行を伴わないスペースとして解釈されます。これはTeXの出力では\ ``~``\ として、HTMLやXMLでは\ ``\&#160;``\ または\ ``\&nbsp;``\ として表れます。

バックスラッシュでエスケープされた改行（具体的には、行末に現れるバックスペース）は強制改行として解釈されます。これはTeXの出力では\ ``\\``\ として、HTMLでは\ ``<br />``\ として表れます。この方法はMarkdownにおける「見えない改行」（強制改行を末尾のスペース2つで表す方法）のよい代替案として使えます。

バックスペース・エスケープは、コードブロックやインラインコードなど文字通り(verbatim)に表す環境では機能しません。

.. _smart-punctuation:

スマートな記号
--------------

**拡張**

``--smart``\ オプションが指定された場合、Pandocはタイポグラフィ的に正しい出力を行います。つまり、直線状の引用符を曲がった引用符に、\ ``---``\ をemダッシュ「\ ``—``\ 」に、\ ``--``\ をenダッシュ「\ ``–``\ 」に、
``...``\ を3点リーダーに変換します。“Mr.”のようなある種の略記・略称に対しては、改行を伴わないスペースが挿入されます。

注意：LaTeXのテンプレートで\ ``csquotes``\ が使用されている場合、Pandocは自動的にこれを検出し、引用符のついたテキストには\ ``\enquote{...}``\ が使用されます。

.. _inline-formatting:

インライン形式の修飾
--------------------

強調
~~~~

テキストを\ *強調*\ するには、下記のように\ ``*``\ または\ ``_``\ のペアで囲みます：

::

   このテキストは _アンダースコアで強調されており_、そして
   これは *アスタリスクで強調されています*。

2重の\ ``*``\ または\ ``_``\ は\ **強い強調**\ をもたらします：

::

   これは **強い強調** で、これは __アンダースコアで囲んだものです__。

スペースで囲まれた\ ``*``\ や\ ``_``\ 、およびバックスペースでエスケープされたものは強調扱いになりません：

::

   これは * 強調されません *、そして \*これも同様です\*。

**拡張: ``intraword_underscores``**

``_``\ 記号は時々、言葉や識別子の間に入ったりするので、Pandocでは英数字に囲まれた\ ``_``\ を強調記号として認識しません。単語の一部分を強調したい場合は、\ ``*``\ を使用してください：

::

   feas*ible*, not feas*able*.

取り消し線
~~~~~~~~~~

**拡張: ``strikeout``**

テキストに水平線の取り消し線をかける場合は、そのテキストを\ ``~~``\ で囲んでください。例えば：

::

   これは ~~削除されたテキストです。~~

上付き文字と下付き文字
~~~~~~~~~~~~~~~~~~~~~~

**拡張: ``superscript``, ``subscript``**

あるテキストを上付き文字にするには、テキストを\ ``^``\ で囲んでください。同様に下付き文字にするには、テキストを\ ``~``\ で囲んでください。例えば：

::

   H~2~O は液体です。2^10^ は 1024 です。

上付き文字または下付き文字にスペースが含まれる場合、このスペースはバックスラッシュでエスケープする必要があります。（これは、通常の\ ``~``\ や\ ``^``\ の使用によって、意図に反して上付き文字や下付き文字が適用されることを防ぎます。つまり、もし文字Pに対して’a
cat’を下付き文字にしたい場合、\ ``P~a cat~``\ ではなく、\ ``P~a\ cat~``\ とする必要があります。）

.. _verbatim:

文字通りの出力 (Verbatim)
~~~~~~~~~~~~~~~~~~~~~~~~~

短いブロックで文字通りの出力(verbatim)を得たい場合、バックスラッシュで囲みます：

::

   `>>=`と`>>`の違いは何でしょうか？

もし文字通りの出力にバックスラッシュを含めたい場合は、2重のバックスラッシュを使います：

::

   これは文字通りのバックスラッシュです： `` ` ``。

（開きバックスラッシュと閉じバックスラッシュの間のスペースは無視されます。）

共通のルールは、文字通りに出力させたい部分(span)を、同じ数の連続したバックスラッシュの組で囲むことです（その内側にそれぞれ1つずつのスペースを入れても構いません）。

注意：バックスラッシュのエスケープ（や他のMarkdown文法）は、文字通りの出力を行っている最中には有効になりません。

::

   これはバックスラッシュの後にアスタリスクを付けたものです：`\*`。

**拡張: ``inline_code_attributes``**

文字通りの出力に対して、\ `囲まれたコードブロック <#fenced-code-blocks>`__\ と同様に属性を付けることができます：

::

   `<$>`{.haskell}

.. _math:

数式
----

**拡張: ``tex_math_dollars``**

``$``\ で囲まれたものは全てTeXの数式として認識されます。左の（開く側の）\ ``$``\ の次や、右の（閉じる側の）\ ``$``\ の前には、スペースや改行が来てはいけません。つまり、\ ``$20,000 and $30,000``\ は数式として認識されません。もし何らかの理由でテキストの末尾に\ ``$``\ 記号を付けなければならない場合は、バックスラッシュでエスケープしましょう。そうすれば、この\ ``$``\ は数式の区切りとして認識されなくなります。

TeXの数式は全ての出力フォーマットで出力されます。どのように数式が生成されるかは、その出力フォーマットによります。

Markdown, LaTeX, Org-Mode, ConTeXt
   ``$``\ 記号に囲まれたものが、文字通りに出力されます。
   reStructuredText
   `ここ <http://www.american.edu/econ/itex2mml/mathhack.rst>`__\ で説明されているように、解釈済みテキストロール\ ``:math:``\ を使用して生成されます。
   AsciiDoc
   ``latexmath:[...]``\ として生成されます。 Texinfo
   ``@math``\ コマンドに埋め込む形で生成されます。 groff man
   ``$``\ 記号を取り除いた形で、文字通りに出力されます。 MediaWiki
   ``<math>``\ で数式が囲まれた形で生成されます。 Textile
   ``<span class="math">``\ で数式が囲まれた形で生成されます。 RTF,
   OpenDocument, ODT
   可能であれば、Unicode文字で生成されます。そうでなければ、文字通りに出力されます。
   Docbook
   ``--mathml``\ オプションが指定された場合は、MathMLを用いて\ ``inlineequation``\ または\ ``informalequation``\ タグで囲んだ形で生成されます。そうでなければ、可能な限りUnicode文字で生成されます。
   Docx
   OMML数式マークアップの形式で生成されます。 FictionBook2
   ``--webtex``\ オプションが指定された場合は、数式はGoogle Chart
   APIやその他の互換性のあるWebサービス（e-bookにダウンロードおよび埋め込みされたもの）を用いて、画像として生成されます。そうでなければ、文字通りに出力されます。
   HTML, Slidy, DZSlides, S5, EPUB
   HTMLにおける数式の生成方法は、コマンドラインオプションに依存します：

   1. デフォルトではRTF,
      DocBookそしてOpenDocument出力のように、Unicode文字で可能な限り出力します。後でCSSなどを用いて修飾できるように、数式は\ ``<span class="math">``\ タグで囲まれます。

   2. ``--latexmathml``\ オプションが指定された場合、TeX数式は\ ``$``\ または\ ``$$``\ 記号に囲まれた状態で、さらに\ ``<span class="LaTeX">``\ タグで囲まれて出力されます。\ `LaTeXMathML <http://math.etsu.edu/LaTeXMathML/>`__\ スクリプトが数式の生成に使用されます。（このトリックはFireFoxで使用できますが、LaTeXMathMLをサポートしない他のブラウザでは動作しません。後者の場合、TeX数式は\ ``$``\ 記号に囲まれた状態で文字通りに出力されます。）

   3. ``--jsmath``\ オプションが指定された場合、TeX数式は\ ``<span class="math">``\ タグ（インライン形式）または\ ``<div class="math">``\ タグ（ディスプレイ形式）で囲まれて出力されます。\ `jsMath <http://www.math.union.edu/~dpvc/jsmath/>`__\ スクリプトが数式の生成に使用されます。

   4. ``--mimetex``\ オプションが指定された場合、TeX数式を画像に変換するために\ `mimeTeX <http://www.forkosh.com/mimetex.html>`__
      CGIスクリプトが呼ばれます。この方法は全てのブラウザで動作します。\ ``--mimetex``\ オプションは、任意でmimeTeX
      CGIスクリプトのURLを引数に指定できます。URLが指定されなかった場合は、その引数を\ ``/cgi-bin/mimetex.cgi``\ と見なします。

   5. ``--gladtex``\ オプションが指定された場合、TeX数式はHTML出力において\ ``<eq>``\ タグで囲まれて出力されます。この結果\ ``htex``\ ファイルが得られ、\ `gladTeX <http://ans.hsh.no/home/mgg/gladtex/>`__\ によって処理されます。これにより、それぞれの数式が画像として出力され、この画像がリンクされた\ ``html``\ ファイルが生成されます。まとめると、これらの手続きは以下の通りになります：

      ::

         pandoc -s --gladtex myfile.txt -o myfile.htex
         gladtex -d myfile-images myfile.htex
         # produces myfile.html and images in myfile-images

   6. ``--webtex``\ オプションが指定された場合、TeX数式は\ ``<img>``\ タグで囲まれ、外部スクリプトによって変換された数式画像にリンクされます。数式はURLエンコードされ、与えられたURLに結合されます。引数としてURLが指定されなかった場合、\ `Google
      Chart
      API <http://chart.apis.google.com/chart?cht=tx&chl=>`__\ が使用されます。

   7. ``--mathjax``\ オプションが指定された場合、TeX数式は\ ``\(...\)``
      （インライン形式）または\ ``\[...\]``\ （ディスプレイ形式）で囲まれ、さらに\ ``<span class="math">``\ タグで囲まれて出力されます。\ `MathJax <http://www.mathjax.org/>`__\ スクリプトが数式の生成に利用されます。

.. _raw-html:

生のHTML (Raw HTML)
-------------------

**拡張: ``raw_html``**

Markdownでは生のHTML（またはDocBook）を文書中のどこにでも挿入することができます。（ただし文字通り(verbatim)の出力の中は除きます。この場合は、\ ``<``,
``>``\ や\ ``&``\ は文字通りに出力されます。）

メモ：厳密に言えばこれは拡張ではなく、標準のMarkdownでも許されていることです。しかし、必要なときにこの機能をオフにすることができるように、拡張機能として実装されています。

以下のフォーマットでは、生のHTMLはそのまま出力されます：HTML, S5, Slidy,
Slideous, DZSlides, EPUB, Markdown,
Textile。その他のフォーマットでは、出力されません。

**拡張: ``markdown_in_html_blocks``**

標準のMarkdownではHTML「ブロック」を含めることができます：HTMLのブロックは数に矛盾の無いタグのペアに挟まれ、さらに空行で挟まれたものです。始まりと終わりの行は左のマージンに揃っています。このブロックの中では、全てがMarkdownではなくHTMLとして解釈されます。例えば、\ ``*``\ は強調を意味しません。

Pandocでは\ ``markdown_strict``\ が指定されたときにこのような振る舞いをします。しかしデフォルトでは、PandocはHTMLブロックの間にあるMarkdown記法を、そのままMarkdownとして解釈します。つまり、例えば、Pandocは下記のコードを

::

   <table>
       <tr>
           <td>*one*</td>
           <td>[a link](http://google.com)</td>
       </tr>
   </table>

下記に変換します：

::

   <table>
       <tr>
           <td><em>one</em></td>
           <td><a href="http://google.com">a link</a></td>
       </tr>
   </table>

一方で、\ ``Markdown.pl``\ では\ ``*one*``\ は変換せずそのまま保存します。

このルールには1つ例外があります：\ ``<script>``\ または\ ``<style>``\ タグで囲まれたテキストはMarkdownとして解釈されません。

この標準Markdownからの「出発」は、MarkdownとHTMLブロック要素とのミックスを容易にします。例えば、\ ``<div>``\ タグでMarkdownテキストを囲むことができるため、\ ``<div>``\ タグ自身がMarkdownとして解釈されないかと心配する必要がなくなります。

.. _raw-tex:

生のTeX (Raw TeX)
-----------------

**拡張: ``raw_tex``**

生のHTMLに加えて、Pandocでは生のLaTeX、TeX、ConTeXtを文書に含めることができます。インラインのTeXコマンドは保存され、変更されないままLaTeXまたはConTeXtのWriterに送られます。したがって、例えば、このようなBibTeX引用をLaTeXに使用することができます：

::

   この結果は\cite{jones.1967}で示された。

注意：LaTeXの環境(environment)では

::

   \begin{tabular}{|l|l|}\hline
   年齢 & 頻度 \\ \hline
   18--25  & 15 \\
   26--35  & 33 \\
   36--45  & 22 \\ \hline
   \end{tabular}

のようにbeginとendで囲まれたものは（Markdownではなく）生のLaTeXとして扱われます。

インラインLaTeXの記述はMarkdown, LaTeX,
ConTeXt以外の出力フォーマットでは無視されます。

.. _latex-macros:

LaTeXマクロ
-----------

**拡張: ``latex_macros``**

LaTeX以外の出力では、Pandocは\ ``\newcommand``\ および\ ``\renewcommand``\ による定義を解釈し、その結果を全てのLaTeX数式に適用します。例えば、以下の例は全ての出力フォーマット（LaTeXを除く）で働きます：

::

   \newcommand{\tuple}[1]{\langle #1 \rangle}

   $\tuple{a, b, c}$

LaTeX出力では、\ ``\newcommand``\ 定義は変更されないまま単に出力されるだけです。

.. _links:

リンク
------

Markdownではいくつかのリンク形式を指定することができます。

自動リンク
~~~~~~~~~~

URLやEメールアドレスを不等号記号\ ``<``,
``>``\ で囲むと、それはリンクになります：

::

   <http://google.com>
   <sam@green.eggs.ham>

インラインリンク
~~~~~~~~~~~~~~~~

インラインリンクは角括弧で囲まれたテキストと、それに続く丸括弧で囲まれたURLの組です。（任意で、URLの後には引用符付きでリンクタイトルを含めることができます。）

::

   これは[インラインリンク](/url)です。そしてこれが [タイトル付きのリンク](http://fsf.org "クリックしてね！")です。

それぞれの括弧の中にはスペースを含めてはいけません。リンクテキストは（強調などの）修飾ができますが、タイトルはできません。

参照リンク
~~~~~~~~~~

*明示的な*\ 参照リンクは2つの部分に分かれます。1つはリンクそのもので、もう1つはリンクの定義です（これは文書のどこに置いても、リンクそのものに対しての前後どちらでもかまいません。）。

前者のリンクは2つの角括弧で構成されます。1つ目の角括弧にはリンクテキストが、もう1つには参照用のラベルが入ります。（両者の間にはスペースを入れても構いません。）
後者のリンク定義は角括弧で囲まれた参照用ラベル、それにコロンとスペースが続き、さらに続けてURL、任意で（スペースの後に、引用符または丸括弧で囲んで）リンクタイトルが入ります。

例を示します：

::

   [my label 1]: /foo/bar.html  "お好みでタイトルを"
   [my label 2]: /foo
   [my label 3]: http://fsf.org (The free software foundation)
   [my label 4]: /bar#special  'シングルクォーテーションで囲まれたタイトル'

URLは任意で不等号記号で囲むこともできます：

::

   [my label 5]: <http://foo.bar.baz>

タイトルは次の行に続いても構いません：

::

   [my label 3]: http://fsf.org
     "The free software foundation"

注意：リンクラベルは大文字・小文字を区別しません。よって以下は正しく動きます：

::

   これは[リンクです][FOO]

   [Foo]: /bar/baz

*暗黙の*\ 参照リンクでは、2つ目の角括弧ペアを空にするか、角括弧ごと無くしてしまいます：

::

   See [my website][], or [my website].

   [my website]: http://foo.bar.baz

注意：\ ``Markdown.pl``\ や多くのMarkdown処理系では、参照リンクの定義はリストアイテムや引用のように、他のブロックに対して入れ子にすることができません。Pandocでは、一貫性がないように見えるこのような制約を取り除いています。よって、以下の例はPandocでは期待通り動きますが、他の処理系では動きません：

::

   > My block [quote].
   >
   > [quote]: /foo

内部リンク
~~~~~~~~~~

同一文書中の他の節にリンクしたい場合は、自動的に生成された識別子を使用できます（下記の\ `HTML,
LaTeX,
ConTeXtにおけるヘッダ識別子 <#header-identifiers-in-html-latex-and-context>`__\ を参照）。例えば：

::

   See the [Introduction](#introduction).

または

::

   See the [Introduction].

   [Introduction]: #introduction

内部リンクは現在のところ、HTML(HTMLスライドショーやEPUBも含む), LaTeX,
ConTeXtフォーマットのみでサポートしています。

.. _images:

画像
----

``!``\ で始まるリンクは画像として扱われます（\ ``!``\ の後ろにスペースを空けてはいけません）。リンクテキストは画像のalt属性として使われます：

::

   ![ラ・ルーン](lalune.jpg "月への旅行")

   ![1編のフィルム]

   [1編のフィルム]: movie.gif

画像とキャプション
~~~~~~~~~~~~~~~~~~

**拡張: ``implicit_figures``**

1つの段落に1つの画像のみを置いた場合、その画像はキャプション付き画像として生成されます。 [4]_
（LaTeXでは、figure環境が使用されます。HTMLでは、画像は\ ``<div class="figure">``\ タグで囲まれ、さらに\ ``<p class="caption">``\ で囲まれたキャプションが付きます。）画像のalt属性がキャプションとして使用されます。

::

   ![これはキャプションです](/url/of/image.png)

もしこれを1つのインライン画像として置きたい場合、1つの段落に1つの画像だけを置いてはいけません。1つの方法としては、画像の後に改行を伴わないスペースを置く手があります：

::

   ![これはfigureにはなりません](/url/of/image.png)\

.. _footnotes:

脚注
----

**拡張: ``footnotes``**

PandocのMarkdownでは脚注を付けることができます。下記の文法の通りです：

::

   これは脚注の参照です[^1]、 そしてもう1つ[^longnote]。

   [^1]: これは脚注です。

   [^longnote]: これは長いブロックから成る脚注です。

       インデントされたいくつかの段落が続くと、
   それらは前の脚注に含まれます。

           { some.code }

       段落の全体または1行目がインデントされていればOKです。このように、
       複数の段落による脚注は複数項目のリストアイテムのように機能します。

   この段落は脚注ではありません。なぜならインデントされていないからです。

脚注を参照するための識別子にはスペース、タブ、改行を含んではいけません。これらの識別子は脚注の参照と脚注本体が対応しているときに限り使用され、出力では脚注は順に番号付けされます。

脚注そのものは文書の最後に置かれる必要はありません。他のブロック要素（リスト、引用、表など）の中を除けば、どこに置いても構いません。

**拡張: ``inline_notes``**

インライン脚注が使用できます（ただし標準の引用とは違い、複数の段落を含むことはできません）。文法は以下の通りです：

::

   これはインライン脚注です。^[識別子をわざわざ探して打つ必要が無いため、
   インライン脚注は楽に書けます。]

インライン脚注と標準の脚注は自由に混在できます。

.. _citations:

文献の引用
----------

**拡張: ``citations``**

``pandoc-citeproc``\ という外部フィルタを用いて、Pandocは自動的に引用やあらゆるスタイルの参考文献を生成することができます。標準的な使い方はこのようなものです：

::

   pandoc --filter pandoc-citeproc myinput.txt

この機能を使うには、YAMLメタデータセクションの\ ``bibliography``\ メタデータフィールドを使って参考文献ファイルを指定する必要があります。参考文献ファイルとしてこのようなフォーマットが使用できます：

============= ==============
Format        File extension
============= ==============
MODS          .mods
BibLaTeX      .bib
BibTeX        .bibtex
RIS           .ris
EndNote       .enl
EndNote XML   .xml
ISI           .wos
MEDLINE       .medline
Copac         .copac
JSON citeproc .json
============= ==============

注意：\ ``.bib``\ はBibTeXとBibLaTeXの両方で通常使用されます。BibTeXを強制的に使用したい場合は、\ ``.bibtex``\ を使用できます。

代わりに、文書中のYAMLメタデータに\ ``references``\ フィールドを置くことができます。これにはYAML形式に直した参考文献を記入する必要があります。例えば：

::

   ---
   references:
   - id: fenner2012a
     title: One-click science marketing
     author:
     - family: Fenner
       given: Martin
     container-title: Nature Materials
     volume: 11
     URL: 'http://dx.doi.org/10.1038/nmat3283'
     DOI: 10.1038/nmat3283
     issue: 4
     publisher: Nature Publishing Group
     page: 261-263
     type: article-journal
     issued:
       year: 2012
       month: 3
   ...

（\ ``pandoc-citeproc``\ から派生したプログラム\ ``mods2yaml``\ は、MODSリファレンスコレクションからYAML形式の参考文献を生成するのに役立ちます。）

デフォルトでは、\ ``pandoc-citeproc``\ はChicago
author-dateフォーマットが引用および参考文献に使われます。他のスタイルを使用したい場合は、\ `CSL <http://CitationStyles.org>`__
1.0
スタイルファイルを探し、\ ``csl``\ メタデータフィールドに指定する必要があります。CSLスタイルファイルの作成および修正のための入門ガイドは
http://citationstyles.org/downloads/primer.html
を参照してください。CSLスタイルファイルのリポジトリは
https://github.com/citation-style-language/styles
で手に入ります。もっと楽に探したい場合は http://zotero.org/styles
もご覧ください。

引用は角括弧の中に入れることができ、各内部要素はセミコロンで区切られます。それぞれの引用はキーを持つ必要があり、「\ ``@``
+
引用の識別子（データベースから）」という形式で構成され、オプションとして接頭辞、locator、接尾辞をつけることができます。引用のキーは英字または\ ``_``\ で始まり、その後に英数字、\ ``_``\ または記号(\ ``:.#$%&-+?<>~/``)が続く必要があります。

例を示します：

::

   Blah blah [see @doe99, pp. 33-35; also @smith04, ch. 1].

   Blah blah [@doe99, pp. 33-35, 38-39 and *passim*].

   Blah blah [@smith04; @doe99].

``@``\ の前のマイナス記号は引用内での著者への言及(mention)をしないようにします。この機能は、著者が既に言及されている場合に便利です。

::

   Smith says blah [-@smith04].

テキスト内引用も以下の通り可能です：

::

   @smith04 says blah.

   @smith04 [p. 33] says blah.

もし使用しているスタイルが引用した文献のリストを呼んでいる場合、それを文書の最後に置くことができます。通常は、適切なヘッダとともに文献リストを最後に置きたいでしょう：

::

   last paragraph...

   # References

文献リストはこのヘッダの後に配置されます。

注意：このセクションに番号が付かないように、\ ``unnumbered``\ クラスがこのヘッダに追加されます。

この文献リストに本文で引用されていない項目を含めたい場合は、ダミーの\ ``nocite``\ メタデータフィールドを定義し、下記のように引用を置くことができます：

::

   ---
   nocite:
    | @item1, @item2
   ...

   @item3

この例では、文書には引用として\ ``item3``\ のみが含まれますが、文献リストには\ ``item1``\ 、\ ``item2``\ 、\ ``item3``\ が含まれます。

.. _non-pandoc-extensions:

Pandoc標準以外の拡張
--------------------

下記のMarkdown文法はPandocのデフォルトでは有効になっていませんが、\ ``+EXTENSION``\ をフォーマット名の前に付けることで有効にすることができます（\ ``EXTENSION``\ は拡張の名前です）。例えば、\ ``markdown+hard_line_breaks``\ はMarkdownに強制改行の機能を付けます。

| **拡張: ``lists_without_preceding_blankline``**
| 段落の後ろに、空行を置くことなくすぐにリストを置くことができます。

| **拡張: ``hard_line_breaks``**
| 段落内の全ての改行がスペースでなく強制改行として解釈されます。

| **拡張: ``ignore_line_breaks``**
| 段落内の全ての改行がスペースや強制改行として解釈されることなく、無視されます。このオプションはスペースを単語区切りに用いない東アジアの言語（訳注：日本語、中国語、韓国語など）を意図していますが、可読性向上のためテキストは複数行に分割されます。

| **拡張: ``tex_math_single_backslash``**
| ``\(``\ と\ ``\)``\ で囲まれた全てのものがTeXのインライン数式として解釈されます。\ ``\[``\ と\ ``\]``\ で囲まれたものはTeXのディスプレイ数式として解釈されます。注意：この拡張の欠点は、\ ``(``\ と\ ``[``\ のエスケープが不可能になることです。

| **拡張: ``tex_math_double_backslash``**
| ``\\(``\ と\ ``\\)``\ で囲まれた全てのものがTeXのインライン数式として解釈されます。\ ``\\[``\ と\ ``\\]``\ で囲まれたものはTeXのディスプレイ数式として解釈されます。

| **拡張: ``markdown_attribute``**
| デフォルトでは、Pandocはブロックレベルタグ内のテキストをMarkdownとして解釈します。この拡張ではその振る舞いを変えて、そのタグの属性として\ ``markdown=1``\ が指定されている場合に限り、ブロックレベルタグ内のテキストをMarkdownとして解釈します。

| **拡張: ``mmd_title_block``**
| 文書先頭にある\ `MultiMarkdown <http://fletcherpenney.net/multimarkdown/>`__\ スタイルのタイトルブロックを有効にします。例えば：

::

   Title:   タイトル
   Author:  ジョン・ドゥ
   Date:    September 1, 2008
   Comment: MMDタイトルブロックのサンプルです。
            複数行を置くことができます。

詳細はMultiMarkdownのドキュメンテーションを参照してください。
もし\ ``pandoc_title_block``\ または\ ``yaml_metadata_block``\ が指定された場合は、それらが\ ``mmd_title_block``\ よりも優先されます。

| **拡張: ``abbreviations``**
| PHP Markdown Extraの略語(abbreviation)記法を解釈します：

::

   *[HTML]: Hyper Text Markup Language

注意：Pandocの文書モデルは略語をサポートしません。よってこの拡張が有効な場合、略語のキーは単にスキップされます（段落として解釈されるのとは反対に）。

| **拡張: ``autolink_bare_uris``**
| リンクを\ ``<...>``\ で囲まない場合でも、全ての絶対参照URIをリンクに変換します。

| **拡張: ``ascii_identifiers``**
| ``auto_identifiers``\ により生成された識別子を純粋なASCII文字に変えます。アクセント記号の付いた英字はアクセント記号のない英字に置換され、非ラテン文字は削除されます。

| **拡張: ``link_attributes``**
| MultiMarkdownスタイルのような、リンクおよび画像の参照のkey-value属性を解釈します。
  注意：Pandocの文書モデルはこのタイプの属性をサポートしません。そのため現在のところ、これらは単に無視されます。

| **拡張: ``mmd_header_identifiers``**
| MultiMarkdownスタイルのヘッダ識別子（角括弧で囲まれたもの、その後にATX形式のヘッダが続く）を解釈します。

.. _markdown-variants:

Markdownの派生バージョン
------------------------

Pandocによる拡張Markdownに加え、下記の派生版Markdownがサポートされています：

``markdown_phpextra`` (PHP Markdown Extra)
   ``footnotes``, ``pipe_tables``, ``raw_html``, ``markdown_attribute``,
   ``fenced_code_blocks``, ``definition_lists``,
   ``intraword_underscores``, ``header_attributes``, ``abbreviations``.
``markdown_github`` (Github-flavored Markdown)
   ``pipe_tables``, ``raw_html``, ``tex_math_single_backslash``,
   ``fenced_code_blocks``, ``fenced_code_attributes``,
   ``auto_identifiers``, ``ascii_identifiers``,
   ``backtick_code_blocks``, ``autolink_bare_uris``,
   ``intraword_underscores``, ``strikeout``, ``hard_line_breaks``
``markdown_mmd`` (MultiMarkdown)
   ``pipe_tables`` ``raw_html``, ``markdown_attribute``,
   ``link_attributes``, ``raw_tex``, ``tex_math_double_backslash``,
   ``intraword_underscores``, ``mmd_title_block``, ``footnotes``,
   ``definition_lists``, ``all_symbols_escapable``,
   ``implicit_header_references``, ``auto_identifiers``,
   ``mmd_header_identifiers``
``markdown_strict`` (Markdown.pl)
   ``raw_html``

.. _extensions-with-formats-other-than-markdown:

Markdown以外のフォーマットにおける拡張
--------------------------------------

上記で議論した拡張のうちいくつかがMarkdown以外のフォーマットでも使用できます：

-  ``auto_identifiers`` は ``latex``, ``rst``, ``mediawiki``,
   ``textile``
   入力で使用できます（そしてこれはデフォルトで指定されます）。

-  ``tex_math_dollars``\ 、\ ``tex_math_single_backslash``\ 、そして
   ``tex_math_double_backslash`` は ``html`` 入力で使用できます。
   （例えば、MathJaxでフォーマットされたページを読むのに便利です。）

.. _producing-slide-shows-with-pandoc:

Pandocでスライドショーを作る
============================

Pandocを使ってHTML+JavaScriptのスライドショーを作ることができます。このスライドショーはWebブラウザで見ることができます。\ `S5 <http://meyerweb.com/eric/tools/s5/>`__,
`DZSlides <http://paulrouget.com/dzslides/>`__,
`Slidy <http://www.w3.org/Talks/Tools/Slidy/>`__,
`Slideous <http://goessner.net/articles/slideous/>`__,
`reveal.js <http://lab.hakim.se/reveal-js/>`__\ の5つの方法があります。また、LaTeX
`beamer <http://www.tex.ac.uk/CTAN/macros/latex/contrib/beamer>`__\ を用いて、PDFスライドショーを作ることもできます。

Markdownによるシンプルなスライドショーの例、\ ``habits.txt``\ を示します：

::

   % 毎日の習慣
   % ジャン・ドゥー
   % March 22, 2005

   # 朝にやること

   ## 起きる

   - アラームを止める
   - ベッドから出る

   ## 朝ご飯

   - 卵を食べる
   - コーヒーを飲む

   # 夜にやること

   ## 夜ご飯

   - スパゲッティを食べる
   - ワインを飲む

   ------------------

   ![スパゲッティの写真](images/spaghetti.jpg)

   ## 眠る

   - ベッドに入る
   - 羊を数える

HTML/JavaScriptスライドショーを生成するには以下をタイプしましょう：

::

   pandoc -t FORMAT -s habits.txt -o habits.html

ここで\ ``FORMAT``\ は\ ``s5``, ``slidy``, ``slideous``, ``dzslides``,
``revealjs``\ のいずれかです。

Slidy, Slideous, reveal.js,
S5については、Pandocによって\ ``-s/--standalone``\ オプションとともに出力されたファイルは、JavaScriptとCSSファイルへのリンクが埋め込まれます。それらのリンク先はある相対パスと見なされ、具体的には\ ``s5/default``
(S5), ``slideous``\ (Slideous), ``reveal.js`` (reveal.js), Slidy
Webサイト ``w3.org``
(Slidy)となります。（これらのパスはそれぞれ``slidy-url``,
``slideous-url``, ``revealjs-url``,
``s5-url``\ 変数によって変更できます。詳細は上記の\ ``--variable``\ を参照。）DZSlidesについては、（比較的短い）JavaScriptとCSSがファイルに含まれます。

全てのHTMLスライドショーフォーマットに対し、\ ``--self-contained``\ オプションが使用できます。これはスライドショー表示に必要な全てのデータ（スクリプト、CSS、画像、動画など）を1つのファイルにまとめるオプションです。

LaTeX Beamerを使ったPDFスライドショーを出力するには、下記を実行します：

::

   pandoc -t beamer habits.txt -o habits.pdf

メモ：reveal.jsスライドショーはブラウザ上でPDF出力することで、PDFに変換することもできます。

.. _structuring-the-slide-show:

スライドショーの構造を作る
--------------------------

デフォルトでは、\ *スライドレベル*\ は文書中で最も上位のヘッダレベルと同じです。ただしこのヘッダには何らかの（別のヘッダ以外の）コンテンツが続く必要があります。例えば、レベル1ヘッダの後には常にレベル2ヘッダが続き、そのレベル2ヘッダには何らかのコンテンツが続いている場合、2がスライドレベルになります。このデフォルト値は\ ``--slide-level``\ オプションで上書きすることができます。

スライドショー文書は下記のルールによりいくつかのスライドに分割することができます：

-  水平線は常に新しいスライドの始まりになります。

-  スライドレベル上のヘッダは常に新しいスライドの始まりになります。

-  スライドレベルより\ *下位の*\ ヘッダはスライド\ *内部に*\ ヘッダを生成します。

-  スライドレベルより\ *上位の*\ ヘッダは「タイトルスライド」を生成します。これはセクションのタイトルのみを含むもので、スライドショーをいくつかのセクションに分けるのに役立ちます。

-  タイトルページが（もし存在すれば）文書のタイトルブロックから自動的に生成されます。（Beamerの場合、デフォルトテンプレート内でこの部分をコメントアウトすることで無効にできます。）

これらのルールはスライドショーにおける多くの異なるスタイルをサポートするために設計されています。もしスライドショーをセクションやサブセクションに分けることを考えていなければ、単にレベル1ヘッダを全てのスライドに使用すればスライドショーを作成できます。（この場合は、レベル1がスライドレベルになります。）しかし、上記で説明したように、スライドショーをいくつかのセクションで分割した構造も作ることができます。

注意：reveal.jsスライドショーでは、スライドレベルが2の場合、2次元レイアウトが生成されます。レベル1ヘッダが水平に配置され、レベル2ヘッダが垂直に配置されます。もしreveal.jsで深いセクションレベルを作りたい場合には、このスライドレベルはお勧めしません。

.. _incremental-lists:

インクリメンタルリスト
----------------------

デフォルトでは、スライドショーのリストは「一気に」表示されます。リストを1つずつ（インクリメンタルに）表示したい場合は、\ ``-i``\ オプションを使用します。リストの一部分をデフォルトの動作と変えたい場合（つまり、\ ``-i``\ オプションを指定しないときに1つずつ表示したい場合、あるいは\ ``-i``\ オプション使用時に一気に表示したい場合）は、引用の中にリストを書きます：

::

   > - スパゲッティを食べる
   > - ワインを飲む

このようにすると、インクリメンタルと非インクリメンタルなリストを1つの文書に混在させることができます。

.. _inserting-pauses:

ポーズの挿入
------------

スペースで区切られた3つのドットを含んだ段落を作ることで、スライド中に「ポーズ」を入れることができます：

::

   # ポーズ入りスライド

   ポーズの前のコンテンツ

   . . .

   ポーズの後のコンテンツ

.. _styling-the-slides:

スライドのスタイルを整える
--------------------------

HTMLスライドのスタイルを変えるには、カスタマイズしたCSSファイルをユーザデータディレクトリに置きます。具体的には、\ ``$DATADIR/s5/default``
(S5), ``$DATADIR/slidy`` (Slidy), ``$DATADIR/slideous``
(Slideous)です。ただし、``$DATADIR``\ はユーザデータディレクトリです（上記の\ ``--data-dir``\ の節を参照）。
オリジナルのファイルはPandocのシステムデータディレクトリ（通常は\ ``$CABALDIR/pandoc-VERSION/s5/default``\ ）で見つかります。Pandocは、ユーザデータディレクトリから目的のファイルを探し出せなかった場合に、システムデータディレクトリを検索します。

dzslidesについては、CSSはHTMLファイル自身に含まれており、そのHTML内のCSSを変更することができます。

reveal.jsについては、変数\ ``theme``\ をセットすることでテーマを設定できます。例えば：

::

   -V theme=moon

または、カスタムスタイルシートを\ ``--css``\ オプションで指定することもできます。

Beamerスライドのスタイルについては、\ ``-V``\ オプションを用いてBeamerの“theme”または“colortheme”を設定できます：

::

   pandoc -t beamer habits.txt -V theme:Warsaw -o habits.pdf

メモ：ヘッダの属性は、HTMLスライドでは（\ ``<div>``\ または\ ``<section>``\ にて）スライドの属性に変わります。これにより個別のスライドにスタイルを設定することができます。Beamerでは、\ ``allowframebreaks``\ クラスのみがスライドに影響を与えるヘッダの属性になります。この属性を指定すると、フレームがコンテンツで一杯になったときに複数のスライドが作成されます。この属性は特に参考文献リストに対して推奨されます：

::

   # References {.allowframebreaks}

.. _speaker-notes:

発表者用ノート
--------------

reveal.jsでは嬉しいことに、発表者用ノートをサポートしています。Markdown文書に以下のようなノートをつけ加えることができます：

::

   <div class="notes">
   これはノートです。

   - リストのような
   - Markdownも含めることができます。

   </div>

発表者用ノートのウィンドウを表示するには、プレゼンテーションの表示中に\ ``s``\ を押してください。
他のスライドショーフォーマットでは発表者用ノートはサポートされていませんが、スライド自体にはこのノートは表示されません。

.. _epub-metadata:

EPUBメタデータ
==============

EPUBメタデータは\ ``--epub-metadata``\ オプションにより指定できます。しかし、入力文書がMarkdownの場合、YAMLメタデータブロックを使用する方がより良いでしょう。例を示します：

::

   ---
   title:
   - type: main
     text: My Book
   - type: subtitle
     text: An investigation of metadata
   creator:
   - role: author
     text: John Smith
   - role: editor
     text: Sarah Jones
   identifier:
   - scheme: DOI
     text: doi:10.234234.234/33
   publisher:  My Press
   rights:  (c) 2007 John Smith, CC BY-NC
   ...

以下のフィールドが認識されます：

``identifier``
   フィールド\ ``text``\ と\ ``scheme``\ を持った文字列値またはオブジェクト。
   ``scheme``\ に対する正当な値は以下の通り：\ ``ISBN-10``, ``GTIN-13``,
   ``UPC``, ``ISMN-10``, ``DOI``, ``LCCN``, ``GTIN-14``, ``ISBN-13``,
   ``Legal deposit number``, ``URN``, ``OCLC``, ``ISMN-13``, ``ISBN-A``,
   ``JP``, ``OLCC``. ``title``
   フィールド\ ``file-as``\ と\ ``type``\ を持った文字列値、オブジェクト、またはそれらのリスト。\ ``type``\ に対する正当な値は以下の通り：
   ``main``, ``subtitle``, ``short``, ``collection``, ``edition``,
   ``extended``. ``creator``
   フィールド\ ``role``\ と\ ``file-as``\ と\ ``text``\ を持った、文字列値、オブジェクト、またはそれらのリスト。\ ``role``\ に対する正当な値は\ `marc
   relators <http://www.loc.gov/marc/relators/relaterm.html>`__\ を参照。
   しかし、Pandocはヒューマン・リーダブルなバージョンからmarc
   relatorsへ翻訳しようと試みます（“author”や“editor”のように）。
   ``contributor``
   ``creator``\ と同様のフォーマット。 ``date``
   ``YYYY-MM-DD``\ 形式の文字列値。 (年のみが必須です)
   Pandocは他の標準的なフォーマットでも変換しようと試みます。
   ``language``
   `RFC5646 <http://tools.ietf.org/html/rfc5646>`__\ フォーマットの文字列値。
   何も設定されていない場合は、Pandocはローカルの言語をデフォルト値とします。
   ``subject``
   文字列値またはそのリスト。 ``description``
   文字列値。 ``type``
   文字列値。 ``format``
   文字列値。 ``relation``
   文字列値。 ``coverage``
   文字列値。 ``rights``
   文字列値。 ``cover-image``
   文字列値 (カバーイメージへのパス)。 ``stylesheet``
   文字列値 (CSSスタイルシートへのパス)。

.. _literate-haskell-support:

Literate Haskellのサポート
==========================

ある種の入力または出力フォーマット（\ ``markdown``, ``mardkown_strict``,
``rst``, ``latex``\ ）に ``+lhs``
（または\ ``+literate_haskell``\ ）を付け足した場合、Pandocはその文書をLiterate
Haskellのソースコードとして扱います。つまり、

-  Markdownの入力では、’\ ``>``\ ’で始まる行 (“bird track”セクション)
   は引用ではなく、Haskellのソースコードとして扱われます。\ ``\begin{code}``\ と\ ``\end{code}``\ で囲まれたテキストも同様にHaskellコードとして扱われます。

-  Markdown出力では、クラス\ ``haskell``\ と\ ``literate``\ の付いたコードブロックが、各行頭に’\ ``>``\ ’が付けられた状態で出力されます。引用は1つのスペースでインデントされて出力されるため、Haskellコードとしては取り扱われません。加えて、ヘッダはATXスタイル（\ ``#``\ のヘッダ）ではなくSetextスタイル（アンダーラインのヘッダ）が優先的に使用されます。（これは、GHCが1桁目の\ ``#``\ 記号を行番号の記号として扱うためです。）

-  reStructuredTextの入力では、’\ ``>``\ ’の部分がHaskellコードとして解釈されます。

-  reStructuredTextの出力では、クラス\ ``haskell``\ の付いたコードブロックが、各行頭に’\ ``>``\ ’が付けられた状態で出力されます。

-  LaTeX入力では、\ ``code``\ 環境で囲まれたテキストがHaskellコードとして解釈されます。

-  LaTeX出力では、クラス\ ``haskell``\ の付いたコードブロックが\ ``code``\ 環境の中に出力されます。

-  HTML出力では、クラス\ ``haskell``\ の付いたコードブロックがクラス\ ``literatehaskell``\ と’\ ``>``\ ’記号とともに出力されます。

例：

::

   pandoc -f markdown+lhs -t html

は、Markdown形式のLiterate
Haskellソースコードを読み込み、通常のHTML（’\ ``>``\ ’記号付き）を出力します。

::

   pandoc -f markdown+lhs -t html+lhs

は、’\ ``>``\ ’記号付きのHaskellソースコードが入ったHTMLを出力します。よって、これはLiterate
Haskellソースとしてコピー&ペーストができます。

.. _custom-writers:

カスタムWriter
==============

Pandocは\ `Lua <http://www.lua.org>`__\ で書かれたカスタムWriterによって拡張することができます。（PandocにはLuaインタプリタが内蔵されているため、個別にLuaをインストールする必要はありません。）

カスタムWriterを使用するには、単にLuaスクリプトへのパスを出力フォーマットとして指定するだけです。例えば：

::

   pandoc -t data/sample.lua

カスタムWriterを作成するには、Pandoc文書中の各要素(element)に対するLua関数を書く必要があります。変更の元になるサンプルを入手するには、以下のコマンドを実行してください：

::

   pandoc --print-default-data-file sample.lua

Authors
=======

© 2006-2013 John MacFarlane (jgm at berkeley dot edu). Released under
the `GPL <http://www.gnu.org/copyleft/gpl.html>`__, version 2 or
greater. This software carries no warranty of any kind. (See COPYRIGHT
for full copyright and warranty notices.) Other contributors include
Recai Oktaş, Paulo Tanimoto, Peter Wang, Andrea Rossato, Eric Kow,
infinity0x, Luke Plant, shreevatsa.public, Puneeth Chaganti, Paul
Rivier, rodja.trappe, Bradley Kuhn, thsutton, Nathan Gass, Jonathan
Daugherty, Jérémy Bobbio, Justin Bogner, qerub, Christopher Sawicki,
Kelsey Hightower, Masayoshi Takahashi, Antoine Latter, Ralf Stephan,
Eric Seidel, B. Scott Michel, Gavin Beatty, Sergey Astanin, Arlo
O’Keeffe, Denis Laxalde, Brent Yorgey, David Lazar, Jamie F. Olson,
Matthew Pickering, Albert Krewinkel, mb21, Jesse Rosenthal.

日本語版翻訳： Yuki Fujiwara (@sky_y), yubiquita, nilquebe,
shoulderpower

.. [1]
   このルールは、通常の段落において下記のような人物のイニシャルが

   ::

      B. Russell was an English philosopher.

   リストアイテムとして認識されないようにするためです。

   ただし、このルールは下記の文を

   ::

      (C) 2007 Joe Smith

   リストアイテムとして解釈されることまでは防ぎません。この場合、バックスラッシュをエスケープに使用することができます：

   ::

      (C\) 2007 Joe Smith

.. [2]
   私（訳注：John MacFarlane）は\ \ `David
   Wheeler <http://www.justatheory.com/computers/markup/modest-markdown-proposal.html>`__\ \ による提案の影響も受けています。

.. [3]
   この仕組みはMichel Fortinに由来します。彼はこれを `Markdown
   discussion
   list <http://six.pairlist.net/pipermail/markdown-discuss/2005-March/001097.html>`__
   にて提案しました。

.. [4]
   この機能はRTF, OpenDocument,
   ODTでは今のところ実装されていません。これらでは、1つの段落に置かれた画像が得られるだけで、キャプションは付きません。
