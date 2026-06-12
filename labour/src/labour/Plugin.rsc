module labour::Plugin

import IO;

import util::Reflective;
import util::IDEServices;
import util::LanguageServer;

import labour::Server;
import labour::Parser;
import labour::CST2AST;
import labour::Check;

/*
 * This function is defined to test the functionality of the whole assignment. It receives a file path as a parameter and returns true if the program satisfies the specification or false otherwise.
 * First, it calls the parser (Parser.rsc). Then, it transforms the resulting parse tree of the previous program and calls the function cst2ast (CST2AST.rsc), responsible for transforming a parse tree into an abstract syntax tree.
 * Finally, the resulting AST is used to evaluate the well-formedness of the labour program using the check function (Check.rsc).
 */
bool checkWellformedness(loc fil) {
  // Parsing
  &T resource = parseLaBouR(fil);
  // Transform the parse tree into an abstract syntax tree
  &T ast = cst2ast(resource);
  // Check the well-formedness of the program
  return checkBoulderWallConfiguration(ast);
}

/*
 * This is the main function of the project. This function enables the editor's syntax highlighting.
 * After calling this function from the terminal, all files with extension .labour will be parsed using the parser defined in module labour::Parser.
 * If there are syntactic errors in the program, no highlighting will be shown in the editor.
 */

int main() {
  // we register a new language to Rascal's LSP multiplexer
  // the multiplexer starts a new evaluator and loads this module and function
  registerLanguage(
    language(
      pathConfig(srcs=[|project://labour/src|]),
      "BoulderingWall",      // name of the language
      {"labour"},            // extension, e.g., example.lbr
      "labour::Server",      // module to import, this one
      "contributions"
    )
  );
  return 0;
}

/*
 * Use this function to clear all traces of your language from VS code.
 */
void clearLaBouR() {
  unregisterLanguage("BoulderingWall", {"labour"});
}

/*
 * Use this function to run your tests. It will show how many tests succeeded.
 * Note that an invalid test "succeeds" when the check fails
 */
void runTests() {
  int fails = 0;
  list[loc] validFiles = |project://labour/test/valid|.ls;
  list[loc] invalidFiles = |project://labour/test/invalid|.ls;

  println("\nValid tests");
  for (file <- validFiles) {
    try {
      if (checkWellformedness(file)) {
        println("SUCCESS: <file.path> returns true");
      } else {
        println("FAILURE: <file.path> returns false (Checker failed)");
        fails += 1;
      }
    } catch value e: {
      // If a valid file crashes, that is a real failure!
      println("FAILURE: <file.path> threw an error (Parse/AST Error): <e>");
      fails += 1;
    }
  }

  println("\nInvalid tests");

  for (file <- invalidFiles) {
    try {
      if (checkWellformedness(file)) {
        println("FAILURE: <file.path> returns true");
        fails +=1;
      } else {
        println("SUCCESS: <file.path> returns false (Checker failed)");
      }
    } catch value e: {
      // If an invalid file throws a parse error, it CORRECTLY failed!
      println("SUCCESS: <file.path> returns false (Syntax/Parse Error)");
    }
  }

  println("\n<fails> failed tests");
}
