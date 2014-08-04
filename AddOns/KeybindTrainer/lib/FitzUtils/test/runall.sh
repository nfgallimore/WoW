# Simple shellscript to run unit tests.  Run from main addon directory.

# Note: replace with your installation of wow-lua
LUA=`which lua`

# Note: excludes tests from luaunit module
for TEST in `find test/ -name "test_*" | grep -v .svn | grep -v luaunit`
do 
  $LUA $TEST
done
