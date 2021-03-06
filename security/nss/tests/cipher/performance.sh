#!/bin/sh  
#
# ***** BEGIN LICENSE BLOCK *****
# Version: MPL 1.1/GPL 2.0/LGPL 2.1
#
# The contents of this file are subject to the Mozilla Public License Version
# 1.1 (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
# http://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS IS" basis,
# WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
# for the specific language governing rights and limitations under the
# License.
#
# The Original Code is the Netscape security libraries.
#
# The Initial Developer of the Original Code is
# Netscape Communications Corporation.
# Portions created by the Initial Developer are Copyright (C) 2000-2009
# the Initial Developer. All Rights Reserved.
#
# Contributor(s):
#
# Alternatively, the contents of this file may be used under the terms of
# either the GNU General Public License Version 2 or later (the "GPL"), or
# the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
# in which case the provisions of the GPL or the LGPL are applicable instead
# of those above. If you wish to allow use of your version of this file only
# under the terms of either the GPL or the LGPL, and not to allow others to
# use your version of this file under the terms of the MPL, indicate your
# decision by deleting the provisions above and replace them with the notice
# and other provisions required by the GPL or the LGPL. If you do not delete
# the provisions above, a recipient may use your version of this file under
# the terms of any one of the MPL, the GPL or the LGPL.
#
# ***** END LICENSE BLOCK *****
#
# This is just a quick script so we can still run our testcases.
# Longer term we need a scriptable test environment..
#
. ../common/init.sh
CURDIR=`pwd`
if [ "${OS_ARCH}" = "WINNT" -a "$OS_NAME" = "CYGWIN_NT" ]; then
	CURDIR=`cygpath -m ${CURDIR}`
fi

CIPHERDIR=${HOSTDIR}/cipher
SKTESTS=${CURDIR}/symmkey.txt
RSATESTS=${CURDIR}/rsa.txt
DSATESTS=${CURDIR}/dsa.txt
HASHTESTS=${CURDIR}/hash.txt
SKPERFOUT=${CIPHERDIR}/skperfout.data
RSAPERFOUT=${CIPHERDIR}/rsaperfout.data
DSAPERFOUT=${CIPHERDIR}/dsaperfout.data
HASHPERFOUT=${CIPHERDIR}/hashperfout.data
PERFRESULTS=${HOSTDIR}/performance.html

echo "<HTML><BODY>" >> ${PERFRESULTS}

mkdir -p ${CIPHERDIR}
cd ${CIPHERDIR}

if [ -z $1 ]; then
    TESTSET="all"
else
    TESTSET=$1
fi

if [ $TESTSET = "all" -o $TESTSET = "symmkey" ]; then
echo "<TABLE BORDER=1><TR><TH COLSPAN=6>Symmetric Key Cipher Performance</TH></TR>" >> ${PERFRESULTS}
echo "<TR bgcolor=lightGreen><TH>MODE</TH><TH>INPUT SIZE (bytes)</TH><TH>SYMMETRIC KEY SIZE (bits)</TH><TH>REPETITIONS (cx/op)</TH><TH>CONTEXT CREATION TIME (ms)</TH><TH>OPERATION TIME (ms)</TH></TR>" >> ${PERFRESULTS}

while read mode keysize bufsize reps cxreps
do
    if [ $mode != "#" ]; then
	echo "bltest -N -m $mode -b $bufsize -g $keysize -u $cxreps"
	${BINDIR}/bltest -N -m $mode -b $bufsize -g $keysize -u $cxreps >> ${SKPERFOUT}
	mv "tmp.in.0" "$mode.in"
	mv tmp.key $mode.key
	if [ -f tmp.iv ]; then
	    mv tmp.iv $mode.iv
	fi
	echo "bltest -E -m $mode -i ${CIPHERDIR}/$mode.in -k ${CIPHERDIR}/$mode.key -v ${CIPHERDIR}/$mode.iv -p $reps -o ${CIPHERDIR}/$mode.out"
	${BINDIR}/bltest -E -m $mode -i ${CIPHERDIR}/$mode.in -k ${CIPHERDIR}/$mode.key -v ${CIPHERDIR}/$mode.iv -p $reps -o ${CIPHERDIR}/$mode.out >> ${SKPERFOUT}
	echo "bltest -D -m $mode -i ${CIPHERDIR}/$mode.out -k ${CIPHERDIR}/$mode.key -v ${CIPHERDIR}/$mode.iv -p $reps -o ${CIPHERDIR}/$mode.inv"
	${BINDIR}/bltest -D -m $mode -i ${CIPHERDIR}/$mode.out -k ${CIPHERDIR}/$mode.key -v ${CIPHERDIR}/$mode.iv -p $reps -o ${CIPHERDIR}/$mode.inv >> ${SKPERFOUT}
    fi
done < ${SKTESTS} 

while read md buf sk rps cxrps cx op
do
    if [ $md != "#" ]; then
	echo "<TR><TH>$md</TH><TD align=right>$buf</TD><TD align=right>$sk</TD><TD align=right>$cxrps/$rps</TD><TD align=right>$cx</TD><TD align=right>$op</TD></TR>" >> ${PERFRESULTS}
    fi
done < ${SKPERFOUT} 

echo "</TABLE><BR>" >> ${PERFRESULTS}

fi

if [ $TESTSET = "all" -o $TESTSET = "rsa" ]; then
while read mode keysize bufsize exp reps cxreps
do
    if [ $mode != "#" ]; then
	echo "bltest -N -m $mode -b $bufsize -e $exp -g $keysize -u $cxreps"
	${BINDIR}/bltest -N -m $mode -b $bufsize -e $exp -g $keysize -u $cxreps >> ${RSAPERFOUT}
	mv "tmp.in.0" "$mode.in"
	mv tmp.key $mode.key
	echo "bltest -E -m $mode -i ${CIPHERDIR}/$mode.in -k ${CIPHERDIR}/$mode.key -p $reps -o ${CIPHERDIR}/$mode.out"
	${BINDIR}/bltest -E -m $mode -i ${CIPHERDIR}/$mode.in -k ${CIPHERDIR}/$mode.key -p $reps -o ${CIPHERDIR}/$mode.out >> ${RSAPERFOUT}
	echo "bltest -D -m $mode -i ${CIPHERDIR}/$mode.out -k ${CIPHERDIR}/$mode.key -p $reps -o ${CIPHERDIR}/$mode.inv"
	${BINDIR}/bltest -D -m $mode -i ${CIPHERDIR}/$mode.out -k ${CIPHERDIR}/$mode.key -p $reps -o ${CIPHERDIR}/$mode.inv >> ${RSAPERFOUT}
    fi
done < ${RSATESTS} 

echo "<TABLE BORDER=1><TR><TH COLSPAN=7>RSA Cipher Performance</TH></TR>" >> ${PERFRESULTS}
echo "<TR bgcolor=lightGreen><TH>MODE</TH><TH>INPUT SIZE (bytes)</TH><TH>KEY SIZE (bits)</TH><TH>PUBLIC EXPONENT</TH><TH>REPETITIONS (cx/op)</TH><TH>CONTEXT CREATION TIME (ms)</TH><TH>OPERATION TIME (ms)</TH></TR>" >> ${PERFRESULTS}

while read md buf mod pe rps cxrps cx op
do
    if [ $md != "#" ]; then
	echo "<TR><TH>$md</TH><TD align=right>$buf</TD><TD align=right>$mod</TD><TD align=right>$pe</TD><TD align=right>$cxrps/$rps</TD><TD align=right>$cx</TD><TD align=right>$op</TD></TR>" >> ${PERFRESULTS}
    fi
done < ${RSAPERFOUT} 

echo "</TABLE><BR>" >> ${PERFRESULTS}
fi

if [ $TESTSET = "all" -o $TESTSET = "dsa" ]; then

while read mode keysize bufsize reps cxreps
do
    if [ $mode != "#" ]; then
	echo "bltest -N -m $mode -b $bufsize -g $keysize -u $cxreps"
	${BINDIR}/bltest -N -m $mode -b $bufsize -g $keysize -u $cxreps >> ${DSAPERFOUT}
	mv "tmp.in.0" "$mode.in"
	mv tmp.key $mode.key
	echo "bltest -S -m $mode -i ${CIPHERDIR}/$mode.in -k ${CIPHERDIR}/$mode.key -p $reps -o ${CIPHERDIR}/$mode.out"
	${BINDIR}/bltest -S -m $mode -i ${CIPHERDIR}/$mode.in -k ${CIPHERDIR}/$mode.key -p $reps -o ${CIPHERDIR}/$mode.out >> ${DSAPERFOUT}
	echo "bltest -V -m $mode -f ${CIPHERDIR}/$mode.out -k ${CIPHERDIR}/$mode.key -p $reps -i ${CIPHERDIR}/$mode.in -o ${CIPHERDIR}/$mode.out"
	${BINDIR}/bltest -V -m $mode -f ${CIPHERDIR}/$mode.out -k ${CIPHERDIR}/$mode.key -p $reps -i ${CIPHERDIR}/$mode.in -o ${CIPHERDIR}/$mode.out >> ${DSAPERFOUT}
    fi
done < ${DSATESTS} 

echo "<TABLE BORDER=1><TR><TH COLSPAN=6>DSA Cipher Performance</TH></TR>" >> ${PERFRESULTS}
echo "<TR bgcolor=lightGreen><TH>MODE</TH><TH>INPUT SIZE (bytes)</TH><TH>KEY SIZE (bits)</TH><TH>REPETITIONS (cx/op)</TH><TH>CONTEXT CREATION TIME (ms)</TH><TH>OPERATION TIME (ms)</TH></TR>" >> ${PERFRESULTS}

while read md buf mod rps cxrps cx op
do
    if [ $md != "#" ]; then
	echo "<TR><TH>$md</TH><TD align=right>$buf</TD><TD align=right>$mod</TD><TD align=right>$cxrps/$rps</TD><TD align=right>$cx</TD><TD align=right>$op</TD></TR>" >> ${PERFRESULTS}
    fi
done < ${DSAPERFOUT} 

echo "</TABLE><BR>" >> ${PERFRESULTS}
fi

if [ $TESTSET = "all" -o $TESTSET = "hash" ]; then
while read mode bufsize reps
do
    if [ $mode != "#" ]; then
	echo "bltest -N -m $mode -b $bufsize"
	${BINDIR}/bltest -N -m $mode -b $bufsize
	mv "tmp.in.0" "$mode.in"
	echo "bltest -H -m $mode -i ${CIPHERDIR}/$mode.in -p $reps -o ${CIPHERDIR}/$mode.out"
	${BINDIR}/bltest -H -m $mode -i ${CIPHERDIR}/$mode.in -p $reps -o ${CIPHERDIR}/$mode.out >> ${HASHPERFOUT}
    fi
done < ${HASHTESTS} 

echo "<TABLE BORDER=1><TR><TH COLSPAN=6>Hash Cipher Performance</TH></TR>" >> ${PERFRESULTS}
echo "<TR bgcolor=lightGreen><TH>MODE</TH><TH>INPUT SIZE (bytes)</TH><TH>REPETITIONS</TH><TH>OPERATION TIME (ms)</TH></TR>" >> ${PERFRESULTS}

while read md buf rps cxrps cx op
do
    if [ $md != "#" ]; then
	echo "<TR><TH>$md</TH><TD align=right>$buf</TD><TD align=right>$rps</TD><TD align=right>$op</TD></TR>" >> ${PERFRESULTS}
    fi
done < ${HASHPERFOUT} 

echo "</TABLE><BR>" >> ${PERFRESULTS}
fi

#rm -f ${TEMPFILES}
cd ${CURDIR}

echo "</BODY></HTML>" >> ${PERFRESULTS}
