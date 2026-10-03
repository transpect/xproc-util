#!/bin/bash

# Invoke from a project that has https://github.com/transpect/calabash3 as a submodule
# (expected in a directory named calabash).
# Since this XML Calabash 3 distro does not contain Saxon HE (in contrast to the standard
# Calabash 3 distro zip), you need to have Saxon 12 in a directory named saxon.

# mkdir tmp && cd tmp
# git clone https://github.com/transpect/calabash3 calabash
# svn co https://subversion.le-tex.de/common/saxon-he12 saxon
# git clone https://github.com/transpect/xproc-util

CFG=none calabash/calabash.sh --explain -i:source=xproc-util/data-uri/test/dir.zip \
      -o:result=entry-name-data-uris.json -o:contents-map=entry-href-data-uris.json \
      xproc-util/data-uri/test/test-contents-data-uri-map.xpl name-keys-relative-to=index.html
