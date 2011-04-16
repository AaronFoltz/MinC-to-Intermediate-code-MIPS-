%{
import java.io.*;
import java.util.*;

/**
 * @author Aaron Foltz
 * CS540 - Program 4
 *
 * Of Note:
 */

%}
 
%token ID NUM IF ELSE WHILE TRUE FALSE BOOL INT TYPE_ID RETURN PRINTINT GETINT ASSIGN_OP REL_OP LOGICAL_OP
 
%left REL_OP
%left LOGICAL_AND LOGICAL_OR
%left LOGICAL_NOT
%left '+' '-'
%left '*'

%right SHIFT_ELSE
%right ELSE
 
%%            

start: {System.out.println();enterScope();} program
	{
		exitScope(); 
			
		try {

			out.write("li $v0, 10"); 
			out.newLine();
			System.out.println("li $v0, 10");
			out.write("syscall");
			out.newLine();
			System.out.println("syscall");
			out.close();

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		

		

		
	}
	;

program:	program  prog_decls 
	|		prog_decls
	;

prog_decls:	fn_decl	 { }  
	| 		var_decl 
	{ 
		try {
			
			out.write("\t.data");
			out.newLine();
			System.out.println("\t.data");
		
		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
	}
	| 		type_decl	
	;

fn_decl: type ID 
		{   
			local = true;
			
			try {
				
				out.write("\t.data");
				out.newLine();
				System.out.println("\t.data");
				out.write($2.name+"_RA: .word 0"); 
				out.newLine();
				System.out.println($2.name+"_RA: .word 0");
				
			} catch ( IOException e) { 
				e.printStackTrace();
			}
			
			
			
			insert($2, $1.name); 
			enterScope(); 
		} 
			params '{' var_decls statements '}'	
		{ 
			exitScope(); 
			local = false;
		}
	;

var_decl:	type ID ';' 
		{ 
			// Local scope
			if(local){
				
				try {
					out.write("local_" + $2.name + ": .word 0");
					out.newLine();
					System.out.println("local_" + $2.name + ": .word 0");
					
				} catch ( IOException e) { 
					e.printStackTrace();
				}
				
			// Global Scope
			}else{
				
				try {
					
					out.write("global_" + $2.name + ": .word 0");
					out.newLine();
					System.out.println("global_" + $2.name + ": .word 0");
					
				} catch ( IOException e) { 
					e.printStackTrace();
				}
				
			}
			 
			insert($2, $1.name); 
		
		}
	;

type_decl:	type '[' NUM ']' TYPE_ID ';' { 	insert($5, $1.name); } 
	|		'{' type_list '}' TYPE_ID ';' { insert($5, "type_list"); }
	;

type_list:	type_list type ID ';' {	insert($3, $2.name); }
	|		type ID ';' { insert($2, $1.name); }
	;

type:	INT	
	|	BOOL 
	|	TYPE_ID 
	;

params:	'(' ')'
	|		'(' param_list ')'
	;

param_list:	param_list ',' type ID { insert($4, $3.name); }
	|		type ID { insert($2, $1.name); }	
	;

statements:	statements statement
	|		statement	
	;

var_decls:	var_decls var_decl
	|		{/*EMPTY*/}
	;

statement:	'{' {enterScope();} var_decls statements '}' {exitScope();}

	|		var ASSIGN_OP expression ';' 
	|		PRINTINT '(' expression ')' ';' 
	|		ID '(' ')' ';' 
	|		ID '(' expression_list ')' ';' 
	|		WHILE '(' expression ')' statement 
	|		IF '(' expression ')' statement ELSE statement 
	|		IF '(' expression ')' statement %prec SHIFT_ELSE 
	|		RETURN '(' ')' ';' 
	|		RETURN '(' expression ')' ';' 
	;

var:	ID 
	|	ID '[' expression ']' 
	|	ID '.' ID 
	;

expression_list:	expression_list ',' expression
	|	expression
	;

expression:	bool1 LOGICAL_OP bool1 
	|	bool1 {$$.type = $1.type;}
	;
	
bool1:	LOGICAL_NOT bool1 
	|	bool2 {$$.type = $1.type;}
	;

bool2:	exp REL_OP exp 
	|	exp 
	;

exp:	exp '+' term 
		{
			
		}
	|	exp '-' term 
	|	term 
	;

term:	term '*' fact 
	|	fact 
	;

fact:	'-' fact 
	|	factor	
	;

factor:	'(' expression ')'	
	|	ID '(' ')' 
	|	ID '(' expression_list ')' 
	|	var    
	|	GETINT '(' ')'
	{
		
		try {
			out.write("li $v0, 5");
			out.newLine();
			System.out.println("li $v0, 5");
			out.write("syscall");
			out.newLine();
			System.out.println("syscall");
			out.write("sw $v0, $t" + getReg());	
			out.newLine();
			System.out.println("sw $v0, $t" + getReg());
		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
	}
	|	NUM 
	|	TRUE	
	|	FALSE	
	;
	
	
%%
	// LinkedList symbolTable - used to provide all the operations of a stack
	// 		with the added benefit of an easy search mechanism.  This holds 
	//		the current state of the Symbol Table tree.
	private LinkedList<LinkedList> symbolTable = new LinkedList<LinkedList>();
	
	// LinkedList scope - a LinkedList structure is used to hold the state of
	// 		the local(current) scope
	private LinkedList<Semantic> scope;
	
	// lexer - an instance of the lexical scanner
	private Lexer lexer;
	
	// registers - an array holding an abstract view of the temporary variables of the system.
	private int[] registers = new int[8];
		
	// local - a boolean denoting if we are in local or global scope.
	//	This is used for label naming conventions
	private boolean local = false;
	
	BufferedWriter out;
	
	
	/**
	 * Main method in order to call the parser
	 */
	public static void main (String [] args) throws IOException {
		Parser yyparser = new Parser(new FileReader(args[0]));
		yyparser.yyparse();
	} 
	
	/**
	 * Constructor for this Parser class.  It simply instantiates an instance of 
	 * the lexer scanner
	 */
	public Parser (Reader r) {
		lexer = new Lexer (r, this);
		try {
			out = new BufferedWriter(new FileWriter("output.s"));}
		catch ( IOException ioe) { 
			ioe.printStackTrace();
		}
	}
	
	/* Interfaces to the lexer */
	private int yylex() {
		int retVal = -1;
		try {
			retVal = lexer.yylex();
		} catch (IOException e) {
			System.err.println("IO Error:" + e);
		}
		return retVal;
	}
	
	/* error reporting */
	private void yyerror(String error) {
		System.err.println("Error: " + error + " at line " + lexer.getLine());
		System.err.println("String rejected");
	}
	
/***********************************************
 *   SYMBOL TABLE IMPLEMENTATION				*                                             
 ***********************************************/
	
 	/**
	 * Enters a new scope.  Creates a new linked list which will hold the symbols
	 */
	 private void enterScope(){
		 scope = new LinkedList<Semantic>();
		 symbolTable.addFirst(scope);	
	 }
	 
	 /**
	  * Exits the current scope 
	  */
	 private void exitScope(){
		 symbolTable.pop();
	 }
	 
	/**
	  * Inserts the identifier and its type into the current scope if it is not already there.
	  * @param id - the Semantic object associated with an identifier/function/type
	  * @param type - the Type associated with the identifier/function/type
	  * @return boolean - If the identifier is already in the current scope
	  */
	 
	 @SuppressWarnings("unchecked")
	 private boolean insert(Semantic id, String type){
		 // Set the identifiers type
		 id.type = type;	 	 
	
		 
		 // Grab the current local scope
		 scope = (LinkedList<Semantic>) symbolTable.peek();
		 
		 // Iterate through the identifiers already in the scope
		 for(Semantic identifier : scope){
		 	 
		 	 // If the identifier is already available - return true
			 if(identifier.name.equals(id.name)){
				 System.out.println("Line " + lexer.getLine() + ": Duplicate declaration of " + id.name);
				 return true;
			 }
		 }
		 
		 // If the identifier is not already available, add it.
		 scope.add(id);
		 return false;
	 }
	 
/*********************************************
 *		     REGISTER Helper Methods         *
 *********************************************/	

	/**
	 * getReg - returns a free register from $t0-$t7
	 */
	public int getReg() {
		for(int x = 0; x < registers.length; x++){
			if(registers[x] == 0){					
				return x;
			}
		}	
		return -1;	
	}
	
	/**
	 * freeReg
	 */
	public void freeReg(int registerNumber) {
		registers[registerNumber] = 0;
	}
	

/***********************************************
 *   Semantic object - in place of ParserVal   *                                          
 ***********************************************/
 
	 public static final class Semantic{
		
		private String name;			// Name of the identifier
		private String type;			// Type of the identifier
		private int register;			// Register where the value is being held

		public Semantic(){	 

		}

		public Semantic(String id, String type){
		this.name = id;
		this.type = type;
		}	 

		public Semantic(String value){
		 this.name = value;
		}

		public Semantic(int ival){
		}

		public Semantic(int ival, String sval){
		} 	 	 
		}
