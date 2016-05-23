#!/bin/bash
# Fix output format.
for i in *result-pool.json; do
echo "{ \"index\": 0,
  \"configs\": `cat $i`
}" > $i
done
