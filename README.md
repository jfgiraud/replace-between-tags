![<https://github.com/jfgiraud/replace-between-tags/actions>](https://img.shields.io/github/actions/workflow/status/jfgiraud/replace-between-tags/main.yml?label=CI)

Description
===========

**rbt** Replace the text between begin and end tags

The destination directory will contain 3 sub-directories: `bin`, `share`
and `man`.

Installation
============

**Using git repo.**

    $ git clone https://github.com/jfgiraud/replace-between-tags.git
    $ cd replace-between-tags
    $ sudo make install DESTDIR=/usr/local

**Using latest tarball release.**

    $ curl -s -L https://api.github.com/repos/jfgiraud/replace-between-tags/releases/latest | grep browser_download_url | cut -d':' -f2- | tr -d ' ",' | xargs wget -O replace-between-tags.tgz
    $ sudo tar zxvf replace-between-tags.tgz -C /usr/local

Usage
=====

**Use man.**

    $ man rbt

**Use option.**

    $ rbt -h

TLDR
====

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
