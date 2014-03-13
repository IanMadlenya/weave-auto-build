set -m
rm -f output-build output-doc
touch output-build output-doc
~/autobuild.sh &
tail -f output-build &
tail -f output-doc &

fg %1
kill %2
kill %3
