#! /bin/bash
clear
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

/Users/aaron/Desktop/Dropbox/Development/Tools/Yacc/yacc.macosx -v -Jsemantic=Semantic Parser.y
javac Parser.java

java -jar /Users/aaron/Desktop/Dropbox/Development/Tools/JFlex/JFlex.jar /Users/aaron/Desktop/Dropbox/CS/CS540/Program4/Lexer.l
javac /Users/aaron/Desktop/Dropbox/CS/CS540/Program4/Lexer.java

java Parser /Users/aaron/Desktop/Dropbox/CS/CS540/Program4/Tests/test0.mc
echo
spim -f "output.s"