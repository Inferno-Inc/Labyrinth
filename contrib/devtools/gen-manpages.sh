#!/usr/bin/env bash
# Copyright (c) 2016-2019 The Bitcoin Core developers
# Copyright (c) 2021-2022 The Labyrinth Core developers
# Distributed under the MIT software license, see the accompanying
# file COPYING or http://www.opensource.org/licenses/mit-license.php.

export LC_ALL=C
TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
BUILDDIR=${BUILDDIR:-$TOPDIR}

BINDIR=${BINDIR:-$BUILDDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

LABYRINTHD=${LABYRINTHD:-$BINDIR/labyrinthd}
LABYRINTHCLI=${LABYRINTHCLI:-$BINDIR/labyrinth-cli}
LABYRINTHTX=${LABYRINTHTX:-$BINDIR/labyrinth-tx}
WALLET_TOOL=${WALLET_TOOL:-$BINDIR/labyrinth-wallet}
LABYRINTHQT=${LABYRINTHQT:-$BINDIR/qt/labyrinth-qt}

[ ! -x $LABYRINTHD ] && echo "$LABYRINTHD not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
read -r -a LABVER <<< "$($LABYRINTHCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }')"

# Create a footer file with copyright content.
# This gets autodetected fine for labyrinthd if --version-string is not set,
# but has different outcomes for labyrinth-qt and labyrinth-cli.
echo "[COPYRIGHT]" > footer.h2m
$LABYRINTHD --version | sed -n '1!p' >> footer.h2m

for cmd in $LABYRINTHD $LABYRINTHCLI $LABYRINTHTX $WALLET_TOOL $LABYRINTHQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${LABVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${LABVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
