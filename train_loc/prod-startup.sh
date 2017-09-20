#!/bin/bash
source ~/.trainloc.keys
mkdir -p ../log
MIX_ENV=prod mix do deps.get --only prod, compile --force, run --no-halt >> ../log/trainloc.log
