#!/usr/bin/env sh
# this is a simple utility script to test wf.sh to run FAILS_LEFT number of
# times exiting with a non-zero exit code until the last run

fails_left_file=fails_left

# we should probably do some verification here but this is just a test script
# utility so I don't care enough to
fails_left="$(cat "$fails_left_file")"

if [ "$fails_left" -gt 0 ]; then
  echo "$(($fails_left - 1))" > "$fails_left_file"
  echo "$fails_left left"
  exit "$fails_left"
else
  echo DONE
fi