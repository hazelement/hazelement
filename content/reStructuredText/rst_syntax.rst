reStructured Text Syntax
########################

:date: 2016-11-19 11:30
:tags: reStructured text, rst
:authors: Harry Zheng

============================================= 
A page with popular reStructured Text Syntax
=============================================
A page with popular reStructured Text Syntax 
---------------------------------------------
A page with popular reStructured Text Syntax

===== 
Title 
===== 
Subtitle 
-------- 
This is a paragraph.

Paragraphs line up at their left 
edges, and are normally separated 
by blank lines.

Plain text	Typical result

This is a normal text paragraph. The next paragraph is a code sample::

   It is not processed in any way, except
   that the indentation is removed.

   It can span multiple lines.

This is a normal text paragraph again.

Bullet lists:

- This is item 1 
- This is item 2

- Bullets are "-", "*" or "+". 
  Continuing text must be aligned 
  after the bullet and whitespace.

Note that a blank line is required 
before the first item and after the 
last, but is optional between items.

Enumerated lists:

3. This is the first item 
4. This is the second item 
5. Enumerators are arabic numbers, 
   single letters, or roman numerals 
6. List items should be sequentially 
   numbered, but need not start at 1 
   (although not all formatters will 
   honour the first index). 
#. This item is auto-enumerated

Definition lists: 

what 
  Definition lists associate a term with 
  a definition. 

how 
  The term is a one-line phrase, and the 
  definition is one or more paragraphs or 
  body elements, indented relative to the 
  term. Blank lines are not allowed 
  between term and definition.

:Authors: 
    Tony J. (Tibs) Ibbs, 
    David Goodger
    (and sundry other good-natured folks)

:Version: 1.0 of 2001/08/08 
:Dedication: To my father.


A paragraph containing only two colons 
indicates that the following indented 
or quoted text is a literal block. 

:: 

  Whitespace, newlines, blank lines, and 
  all kinds of markup (like *this* or 
  \this) is preserved by literal blocks. 

  The paragraph containing only '::' 
  will be omitted from the result. 

The ``::`` may be tacked onto the very 
end of any paragraph. The ``::`` will be 
omitted if it is preceded by whitespace. 
The ``::`` will be converted to a single 
colon if preceded by text, like this:: 

  It's very convenient to use this form. 

Literal blocks end when text returns to 
the preceding paragraph's indentation. 
This means that something like this 
is possible:: 

      We start here 
    and continue here 
  and end here. 

Per-line quoting can also be used on 
unindented literal blocks:: 

> Useful for quotes from email and 
> for Haskell literate programming.


Grid table:

+------------+------------+-----------+ 
| Header 1   | Header 2   | Header 3  | 
+============+============+===========+ 
| body row 1 | column 2   | column 3  | 
+------------+------------+-----------+ 
| body row 2 | Cells may span columns.| 
+------------+------------+-----------+ 
| body row 3 | Cells may  | - Cells   | 
+------------+ span rows. | - contain | 
| body row 4 |            | - blocks. | 
+------------+------------+-----------+


Simple table:

=====  =====  ====== 
   Inputs     Output 
------------  ------ 
  A      B    A or B 
=====  =====  ====== 
False  False  False 
True   False  True 
False  True   True 
True   True   True 
=====  =====  ======


.. _Python: http://www.python.org/

External hyperlinks, like Python_.


.. _example:

Internal crossreferences, like example_.


.. This is an example crossreference target.