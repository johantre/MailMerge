DIR=$(dirname "$0")
source "$DIR/lib/lib.sh"
init

#gitPull  (when finished)

toLine=$(git diff -U0 HEAD^ -- "$jiraReleaseJson" | grep -o '\+.* @@' | sed -En 's/\+(.*) @@/\1/p')

getJsonChanged "$toLine"
