#!/usr/bin/env zsh

binaries=('zoxide')

for bin in $binaries
do
  cargo install $bin --locked
done

