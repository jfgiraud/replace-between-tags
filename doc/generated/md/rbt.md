NAME
====

rbt - Replace the text between begin and end tags

SYNOPSIS
========

**rbt** \[*OPTION*\] \[*FILE*\]

DESCRIPTION
===========

**rbt** is a small utility to replace the text between begin and end
tags

With no FILE, or when FILE is `-`, read standard input.

OPTIONS
=======

Select and sort items
---------------------

**-h**  
Display help.

**-b** *string*, **--begin-tag** *string*  
The begin tag to search.

**-r** *string*, **--replace** *string*  
The string used to replace.

**-R** *FILE*, **--replace-file** *FILE*  
The file used to replace.

**-s**, **--simulate**  
Force output to STDOUT.

EXAMPLES
========

**Replace between using stdout (`-s` option).**

    $ cat /tmp/lorem_ipsum
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. *BEGIN*Pellentesque maximus faucibus lectus, in ultricies lorem volutpat in.
    Sed rutrum risus et vehicula rhoncus. Nunc sed est et eros mollis vehicula. Pellentesque semper dignissim maximus.
    Praesent in justo et ante faucibus eleifend in ac est. Donec orci magna, pellentesque id libero nec, faucibus porta purus.
    Pellentesque luctus sollicitudin tortor sit amet accumsan. Nullam mauris felis, egestas in faucibus in, feugiat vel arcu.
    *END*Cras rhoncus aliquam tristique.
    $ rbt -s -b '*BEGIN*' -e '*END*' -r 'new text here' /tmp/lorem_ipsum
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. *BEGIN*new text here
    *END*Cras rhoncus aliquam tristique.

**Replace in file using the content of a file.**

    $ cat x
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. *BEGIN*Pellentesque maximus faucibus lectus, in ultricies lorem volutpat in.
    Sed rutrum risus et vehicula rhoncus. Nunc sed est et eros mollis vehicula. Pellentesque semper dignissim maximus.
    Praesent in justo et ante faucibus eleifend in ac est. Donec orci magna, pellentesque id libero nec, faucibus porta purus.
    Pellentesque luctus sollicitudin tortor sit amet accumsan. Nullam mauris felis, egestas in faucibus in, feugiat vel arcu.
    *END*Cras rhoncus aliquam tristique.
    $ cat y
    mon texte
    $ rbt -b '*BEGIN*' -e '*END*' -R y x
    Processed: x
    $ cat x
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. *BEGIN*mon texte
    *END*Cras rhoncus aliquam tristique.
