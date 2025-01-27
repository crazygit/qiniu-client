#!/bin/bash
# Copyright 2012 The Go Authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# support functions for go cross compilation

# 交叉编译生成客户端, 使用请参考
#
# http://dave.cheney.net/2012/09/08/an-introduction-to-cross-compilation-with-go
# 
#
# 具体步骤:
#
# $ cd $GOROOT/src && ./all.bash
# $ source crosscompile.bash
# $ go-crosscompile-build-all
#


type setopt >/dev/null 2>&1 && setopt shwordsplit
PLATFORMS="darwin/386 darwin/amd64 freebsd/386 freebsd/amd64 freebsd/arm linux/386 linux/amd64 linux/arm windows/386 windows/amd64 openbsd/386 openbsd/amd64"

function go-alias {
    local GOOS=${1%/*}
    local GOARCH=${1#*/}
    eval "function go-${GOOS}-${GOARCH} { ( GOOS=${GOOS} GOARCH=${GOARCH} go \"\$@\" ) }"
}

function go-crosscompile-build {
    local GOOS=${1%/*}
    local GOARCH=${1#*/}
    cd $(go env GOROOT)/src ; GOOS=${GOOS} GOARCH=${GOARCH} ./make.bash --no-clean 2>&1
}

function go-crosscompile-build-all {
    local FAILURES=""
    for PLATFORM in $PLATFORMS; do
        local CMD="go-crosscompile-build ${PLATFORM}"
        echo "$CMD"
        $CMD || FAILURES="$FAILURES $PLATFORM"
    done
    if [ "$FAILURES" != "" ]; then
        echo "*** go-crosscompile-build-all FAILED on $FAILURES ***"
        return 1
    fi
}   

function go-all {
    local FAILURES=""
    for PLATFORM in $PLATFORMS; do
        local GOOS=${PLATFORM%/*}
        local GOARCH=${PLATFORM#*/}
        local CMD="go-${GOOS}-${GOARCH} $@"
        echo "$CMD"
        $CMD || FAILURES="$FAILURES $PLATFORM"
    done
    if [ "$FAILURES" != "" ]; then
        echo "*** go-all FAILED on $FAILURES ***"
        return 1
    fi
}

function go-build-all {
    local FAILURES=""
    for PLATFORM in $PLATFORMS; do
        local GOOS=${PLATFORM%/*}
        local GOARCH=${PLATFORM#*/}
        local SRCFILENAME=`echo $@ | sed 's/\.go//'`
        local CURDIRNAME=${PWD##*/}
        local OUTPUT=${SRCFILENAME:-$CURDIRNAME} # if no src file given, use current dir name
        local CMD="go-${GOOS}-${GOARCH} build -o $OUTPUT-${GOOS}-${GOARCH} $@"
        echo "$CMD"
        $CMD || FAILURES="$FAILURES $PLATFORM"
    done
    if [ "$FAILURES" != "" ]; then
        echo "*** go-build-all FAILED on $FAILURES ***"
        return 1
    fi
}

for PLATFORM in $PLATFORMS; do
    go-alias $PLATFORM
done

unset -f go-alias
