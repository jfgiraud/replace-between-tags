![<https://github.com/jfgiraud/occurrence-count/actions>](https://img.shields.io/github/actions/workflow/status/jfgiraud/occurrence-count/main.yml?label=CI)

Description
===========

**oc** is a small utility to count occurences of a string or pattern in
each line of files.

The destination directory will contain 3 sub-directories: `bin`, `share`
and `man`.

Installation
============

**Using git repo.**

    $ git clone https://github.com/jfgiraud/occurrence-count.git
    $ cd occurrence-count
    $ sudo make install DESTDIR=/usr/local

**Using latest tarball release.**

    $ curl -s -L https://api.github.com/repos/jfgiraud/occurrence-count/releases/latest | grep browser_download_url | cut -d':' -f2- | tr -d ' ",' | xargs wget -O occurrence-count.tgz
    $ sudo tar zxvf occurrence-count.tgz -C /usr/local

Usage
=====

**Use man.**

    $ man oc

**Use option.**

    $ oc -h

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
