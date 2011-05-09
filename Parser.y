%{
import java.io.*;
import java.util.*;

/**
 * @author Aaron Foltz
 * CS540 - Program 4
 *
 * Of Note:  The actual production items are on the same line as the closing curly brackets
 * 
 * This program outputs spim code both to standard out and to a file named 'output.s'
 * For some reason, the throws clause wouldn't work in the set-up code, so my code is riddled with try/catch clauses
 * 	which I could not remedy.


	Use instructions are included in the bash script file .  You simply need to run byacc on Parser.y and jflex on Lexer.l

	You can then run Parser with any MinC file as its input on the command line

	To then run the compiled MinC code, you must use “spim -f ‘output.s’”

	#! /bin/bash
	clear
	echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

	/Users/aaron/Desktop/Dropbox/Development/Tools/Yacc/yacc.macosx -v -Jsemantic=Semantic Parser.y
	javac Parser.java

	#java -jar /Users/aaron/Desktop/Dropbox/Development/Tools/JFlex/JFlex.jar /Users/aaron/Desktop/Dropbox/CS/CS540/Program4/Lexer.l
	#javac /Users/aaron/Desktop/Dropbox/CS/CS540/Program4/Lexer.java

	java Parser /Users/aaron/Desktop/Dropbox/CS/CS540/Program4/Tests/sort.mc
	echo
	spim -lstack 2000000 -f "output.s"
 */

%}
 
%token ID NUM IF ELSE WHILE TRUE FALSE BOOL INT TYPE_ID RETURN PRINTINT GETINT ASSIGN_OP LOGICAL_NOT LOGICAL_AND LOGICAL_OR
%token LESS LESS_EQUAL GREATER GREATER_EQUAL EQUAL NOT_EQUAL
 
%left LOGICAL_NOT
%left '+' '-'
%left '*'

%right SHIFT_ELSE
%right ELSE
 
%%            

start: 
	{
		try {

			out.write("\t.data\n");
			System.out.println("\t.data");
			
			/*********************************************
			 *		       Simple Prompts    			 *
			 *********************************************/
			out.write("Newline: .asciiz \"\\n\"\n");
			System.out.println("Newline: .asciiz \"\\n\"");
			
			out.write("Enter: .asciiz \"Please enter an integer: \"\n\n");
			System.out.println("Enter: .asciiz \"Please enter an integer: \"\n");

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		enterScope();
	} program
	
	{
		exitScope(); 
			
		try {

			out.write("\nli $v0, 4\n");
			System.out.println("\nli $v0, 4");
			out.write("la $a0, Newline\n");
			System.out.println("la $a0, Newline");
			out.write("syscall\t\t\t# Simply prints out a newline for aesthetics \n");
			System.out.println("syscall\t\t\t# Simply prints out a newline for aesthetics ");
			
			out.write("li $v0, 10\n"); 
			System.out.println("li $v0, 10");
			out.write("syscall\t\t\t # Exit the program\n");
			System.out.println("syscall\t\t\t # Exit the program");
			out.close();

		} catch ( IOException e) { 
			e.printStackTrace();
		}	
	}
	;
 
program:	program  prog_decls 
	|	prog_decls
	;

prog_decls:	fn_decl	 { }  
	| 	var_decl 
	| 	type_decl	
	;

fn_decl: type ID 
	{   
		// We are in local scope now that we are inside a function
		local = true;
		
		// Insert the function onto the symbol table.
		insert($2, $1.name); 
		
		currentFunct = $2;
		enterScope(); 
		
		// Free all registers, nothing is needed at this point
		freeAll();
		freeAllArg();
		
		try {
			
			out.write("\n\t.text\n");
			System.out.println("\n\t.text");
			
			// We are inside main
			if($2.name.equals("main")){
				out.write("\n####################################\n");
				System.out.println("\n####################################");
				out.write("# Function: " + new String($2.name) + " starts here\n");
				System.out.println("# Function: " + new String($2.name) + " starts here");
				out.write("####################################\n");
				System.out.println("####################################");
				
				out.write(new String($2.name).toLowerCase() + ":\n\n");
				System.out.println(new String($2.name).toLowerCase() + ":\n");
				
				// We are inside main 
				main = true;
				
			// We are inside another function	
			}else {
				out.write("\n####################################\n");
				System.out.println("\n####################################");
				out.write("# Function: " + new String($2.name) + " starts here\n");
				System.out.println("# Function: " + new String($2.name) + " starts here");
				out.write("####################################\n");
				System.out.println("####################################");
				
				out.write(new String($2.name).toLowerCase() + "_fn:\n\n");
				System.out.println(new String($2.name).toLowerCase() + "_fn:\n");
			}

			out.write("\t.text\n");
			System.out.println("\t.text");

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		regNumber = 0;
		stackVars = 56;		// The parameters and local vars start at position 56 on the stack
		
	}params '{' var_decls
	{
		// Set the functions position as 56 - avoids null values
		currentFunct.position = stackVars;
		
		try {
			
			// Step 11 of the Stack Discipline - Save the return address of the calling function. 
			out.write("sw $ra, 0($sp)\t\t# Save the return address of the caller\n");
			System.out.println("sw $ra, 0($sp)\t\t# Save the return address of the caller");
			
			// Free all temporary registers at this point
			freeAll();
			
			// Prints out a newline in the source code - aesthetic purposes
			out.write("\n");
			System.out.println();
			
		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
	} statements '}'	
	
	{ 
		exitScope();
		
		// We are no longer in local scope 
		local = false;
		
		try {
			
			// We are inside a function other than main
			if(!main){
				
				// Step 14 of the Stack Discipline - Load saved return address and jump to it.
				//  This is to catch a function without a return
				out.write("lw $ra, 0($sp)\t\t# Load the return value of the calling function\n");
				System.out.println("lw $ra, 0($sp)\t\t# Load the return value of the calling function");
				
				// At the end of this procedure, make sure it returns to the calling function (at the statement after the calling) 
				out.write("jr $ra\t\t\t# Jump to the return address of the caller\n");
				System.out.println("jr $ra\t\t\t# Jump to the return address of the caller");
				
			// We are inside the main funciton, so we should not jump to the return address
			} else {
				out.write("# main should break through to exit the program\n");
				System.out.println("# main should break through to exit the program");
			}

		} catch ( IOException e) { 
			e.printStackTrace();
		}
	}
	;

var_decl:	type ID ';' 
	{ 
		// Local scope
		if(local){
			
			// Save a place on the stack for this local variable
			try {
				out.write("sw $zero" + ", " +  stackVars + "($sp)\t# Save the local vars on the stack\n");
				System.out.println("sw $zero" + ", " +  stackVars + "($sp)\t# Save the local vars on the stack");
				regNumber++;
				stackVars = stackVars+4;
				
			} catch ( IOException e) { 
				e.printStackTrace();
			}
			
			// Add the variable to the functions local variable list
			currentFunct.variables.add($2.name);
			
		// Global Scope
		}else{
			
			// The variable is a type
			if($1.type.equals("type")){
				
				// Lookup the type in the global scope
				typeCalled = lookupGlobal($1);
				
				// If there are variables, it must be a record, so make the declaration have that types variables as well
				if(typeCalled.variablesInRecord != null){
					$2.variablesInRecord = typeCalled.variablesInRecord;
				}
				
				// Allocate space for the declaration
				try {
					out.write("global_" + $2.name + ": .space " + (typeCalled.typeSize) + "\t# Allocates space for the type\n");
					System.out.println("global_" + $2.name + ": .space " + (typeCalled.typeSize) + "\t# Allocates space for the type");

				} catch ( IOException e) { 
					e.printStackTrace();
				}
				
			// The variable is either an int or bool
			} else {
				
				// Allocate space for the declaration
				try {
					out.write("global_" + $2.name + ": .word 0\n");
					System.out.println("global_" + $2.name + ": .word 0");
				
				} catch ( IOException e) { 
					e.printStackTrace();
				}
			}
		}
		
		// Add the variable to the symbol table
		insert($2, $1.name); 	
	}
	;

type_decl:	type '[' NUM ']' TYPE_ID ';' 
	{ 			
		// Insert the type declaration onto the symbol table
		insert($5, $1.name);
		
		// Set the size of this array
		$5.typeSize = Integer.parseInt($3.name)*4;
		
		// This is not a record, so there are no associated variables
		$5.variablesInRecord = null;
	} 
	|	'{' {recordDeclarations.clear(); numOfRecordTypes = 0;} type_list '}' TYPE_ID ';' 
	{ 
		// Insert the declaration onto the symbol table
		insert($5, "type_list"); 
		
		// Set the size of this record
		$5.typeSize = numOfRecordTypes * 4;
	
		$5.variablesInRecord = recordDeclarations;
	}
	;

type_list:	type_list type ID ';' 
	{	
		// Insert this variable in the symbol table
		insert($3, $2.name); 
		
		numOfRecordTypes++; // Add to the counter of variables declared inside the record
		
		// Add the declaration to the linkedlist of variables declared inside this record
		recordDeclarations.addLast($3);
	}
	|	type ID ';' 
	{ 
		// Insert this variable into the symbol table
		insert($2, $1.name); 
		
		numOfRecordTypes++; // Add to the counter of variables declared inside the record
		
		// Add the declaration to the linkedlist of variables declared inside this record
		recordDeclarations.addLast($3);
	}
	;

type:	INT		{$$.type = "int";}
	|	BOOL 	{$$.type = "bool";}
	|	TYPE_ID {$$.type = "type";}
	;

params:	'(' ')'
	|	'(' {regNumber = 0;} param_list ')'
	;

param_list:	param_list ',' type ID 
	{ 
		// Insert this variable onto the symbol table
		insert($4, $3.name); 
		
		// Add this variable to the current function
		currentFunct.variables.add($4.name);
		
		// Step 12 of the Stack Discipline - Save the parameters onto the stack
		try {
			out.write("sw $a" + regNumber + ", " +  stackVars + "($sp)\t\t# Save the parameters on the stack\n");
			System.out.println("sw $a" + regNumber + ", " +  stackVars + "($sp)\t\t# Save the parameters on the stack");
			regNumber++;
			stackVars = stackVars+4;
		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
	}
	|	type ID 
	{ 
		// Insert this variable onto the symbol table
		insert($2, $1.name); 
		
		// Add this variable to the current function
		currentFunct.variables.add($2.name);
		
		// Step 12 of the Stack Discipline - Save the parameters onto the stack
		try {
			out.write("sw $a" + regNumber + ", " + stackVars + "($sp)\t\t# Save the parameters on the stack\n");
			System.out.println("sw $a" + regNumber + ", " +  stackVars + "($sp)\t\t# Save the parameters on the stack");
			regNumber++;
			stackVars = stackVars+4;
		} catch ( IOException e) { 
			e.printStackTrace();
		}
	}	
	;

statements:	statements statement
	|	statement	
	;

var_decls:	var_decls var_decl
	|	{/*EMPTY*/}
	;

statement:	'{' {enterScope(); stackVars = currentFunct.position;} var_decls statements '}' {exitScope();}
	|	var 
	{
		// The object on the left side is a type (array or record)
		if($1.type.equals("type")){
			type = true;
			
		// The variable must be an int or bool
		} else {
			type = false;
		}
		
		freeReg($1.register);
	} ASSIGN_OP expression ';' 
	{
		// If the left side was a type
		if(type){
			
			try {
				out.write("sw $t" + $4.register + ", 0($t" + $1.typeRegister + ")\n");
				System.out.println("sw $t" + $4.register + ", 0($t" + $1.typeRegister + ")");

			} catch ( IOException e) { 
				e.printStackTrace();
			}
			
			type = false;
			freeReg($4.register);
			freeReg($1.typeRegister);
		
		// The left side was not an array or record
		} else {
			
			// Lookup the variable on the symbol table
			varCalled = lookup($1,1);
			
			// Set the variables register to the output of the expression
			varCalled.register = $4.register;
			
			try {
				
				// If we are in a function, then save the expression to the correct position on the stack
				if(local){
					out.write("sw $t" + $4.register + ", " + varCalled.position + "($sp)\n");
					System.out.println("sw $t" + $4.register + ", " + varCalled.position + "($sp)");
				
				// If we are not in local scope, save the expression to the static space
				} else {
					out.write("sw $t" + $4.register + ", " + "global_" + varCalled.name + "\n");
					System.out.println("sw $t" + $4.register + ", " + "global_" + varCalled.name);
				}

			} catch ( IOException e) { 
				e.printStackTrace();
			}
		
			freeReg($4.register);
		}
	}
	|	PRINTINT '(' expression ')' ';' 
	{		
		// Print out the expression and a following newline
		try {

			out.write("li $v0, 1\n");
			System.out.println("li $v0, 1");
			out.write("move $a0, $t" + $3.register + "\n");
			System.out.println("move $a0, $t" + $3.register);
			out.write("syscall\t\t\t# Prints output\n");
			System.out.println("syscall\t\t\t# Prints output");
			
			out.write("\nli $v0, 4\n");
			System.out.println("\nli $v0, 4");
			out.write("la $a0, Newline\n");
			System.out.println("la $a0, Newline");
			out.write("syscall\t\t\t# Simply prints out a newline \n");
			System.out.println("syscall\t\t\t# Simply prints out a newline");
			
			freeReg($3.register);

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
	}
	|	ID '(' ')' ';' 
	{
		try {
			
			out.write("\n#########################################\n");
			System.out.println("\n#########################################");
			out.write("# Stack maintenance for a function call #\n");
			System.out.println("# Stack maintenance for a function call #");
			out.write("#########################################\n");
			System.out.println("#########################################");			
			
			// Step 1 of the Stack Discipline - Save all pertinent registers needed by the calling function
			for(int i = 0, j = 8; i < 8; i++, j = j+4){
				out.write("sw $t" + i + ", " + j + "($sp)\n");
				System.out.println("sw $t" + i + ", " + j + "($sp)");
			}
			
			for(int i = 0, j = 40; i < 4; i++, j = j+4){		
				out.write("sw $a" + i + ", " + j + "($sp)\n");
				System.out.println("sw $a" + i + ", " + j + "($sp)");
			}
			
			// Step 3 of the Stack Discipline - Save the frame pointer of the calling function 
			out.write("sw $fp, 4($sp)\t\t# Saves the frame pointer of the caller\n");
			System.out.println("sw $fp, 4($sp)\t\t# Saves the frame pointer of the caller");
			
			// Step 4 of the Stack Discipline - Allocate a new frame on the stack for the callee function
			out.write("addi $sp, $sp, -104\t# Allocates a new frame for the callee\n");
			System.out.println("addi $sp, $sp, -104\t# Allocates a new frame for the callee");
			
			// Step 5 of the Stack Discipline -  Set the top of the frame of the callee
			out.write("addi $fp, $sp, 100\t# Sets the frame of the callee\n\n");
			System.out.println("addi $fp, $sp, 100\t# Sets the frame of the callee\n");
			
			// Step 6 of the Stack Discipline -  Jump to the start of the callee function
			// If the function is main, just use that name, otherwise we need to append _fn on the end.
			
			// We are in main, jump to that label only
			if ($1.name.equals("main")) {
				out.write("jal " + $1.name + "\t\t# Jump to the main function\n");
				System.out.println("jal " + $1.name + "\t\t# Jump to the main function");
			
			// We are not in main, append _fn to the end of all function labels.
			} else {
				out.write("jal " + $1.name + "_fn\t\t# Jump to the callee function\n");
				System.out.println("jal " + $1.name + "_fn\t\t# Jump to the callee function");
			}
			
			// Step 7 of the Stack Discipline -  Restore the stack pointer for the caller
			out.write("addi $sp, $sp, 104\t# Restores the stack pointer for the caller\n");
			System.out.println("addi $sp, $sp, 104\t# Restores the pointer for the caller");
			
			// Step 8 of the Stack Discipline - Restore the frame pointer for the caller
			out.write("lw $fp, 4($sp)\t\t# Restores the frame pointer of the caller\n");
			System.out.println("lw $fp, 4($sp)\t\t# Restores the frame pointer of the caller");
			
			// Step 9 of the Stack Discipline - Restore all necessary registers (in this case, $a and $t registers)
			for(int i = 0, j = 40; i < 4; i++, j = j+4){		
				out.write("lw $a" + i + ", " + j + "($sp)\n");
				System.out.println("lw $a" + i + ", " + j + "($sp)");
			}
			
			// Free all argument registers
			freeAllArg();
			
			for(int i = 0, j = 8; i < 8; i++, j = j+4){
				out.write("lw $t" + i + ", " + j + "($sp)\n");
				System.out.println("lw $t" + i + ", " + j + "($sp)");
			}	
			
			// Free all temorary registers
			freeAll();
					
			// Gather a register number for the return variable to go in.
			regNumber = getReg();
			
			// Step 10 of the Stack Discipline - Gather the return variable from the callee function
			out.write("move $t" + regNumber + ", $v0\t\t# Move the return variable to an available temp register\n");
			System.out.println("move $t" + regNumber + ", $v0\t\t# Move the return variable to an available temp register");

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
	}
	|	ID '('
	{
		try {

			out.write("\n#########################################\n");
			System.out.println("\n#########################################");
			out.write("# Stack maintenance for a function call #\n");
			System.out.println("# Stack maintenance for a function call #");
			out.write("#########################################\n");
			System.out.println("#########################################");
				
			// Step 1 of the Stack Discipline - Save all pertinent registers needed by the calling function
			for(int i = 0, j = 8; i < 8; i++, j = j+4){
				out.write("sw $t" + i + ", " + j + "($sp)\n");
				System.out.println("sw $t" + i + ", " + j + "($sp)");
			}
			
			for(int i = 0, j = 40; i < 4; i++, j = j+4){		
				out.write("sw $a" + i + ", " + j + "($sp)\n");
				System.out.println("sw $a" + i + ", " + j + "($sp)");
			}
			
			// Step 3 of the Stack Discipline - Save the frame pointer of the calling function 
			out.write("sw $fp, 4($sp)\t\t# Saves the frame pointer of the caller\n");
			System.out.println("sw $fp, 4($sp)\t\t# Saves the frame pointer of the caller");

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
		// Trigger to capture the arguments needed for the procedure.
		function = true;
		
		// Clear the argument registers
		freeAllArg();
		
	} expression_list ')' ';' 
	{
		try {
			
			// Step 4 of the Stack Discipline - Allocate a new frame on the stack for the callee function
			out.write("addi $sp, $sp, -104\t# Allocates a new frame for the callee\n");
			System.out.println("addi $sp, $sp, -104\t# Allocates a new frame for the callee");
			
			// Step 5 of the Stack Discipline - Set the top of the frame of the callee
			out.write("addi $fp, $sp, 100\t# Sets the frame of the callee\n");
			System.out.println("addi $fp, $sp, 100\t# Sets the frame of the callee\n");
			
			// Step 6 of the Stack Discipline -  Jump to the start of the callee function
			out.write("jal " + $1.name + "_fn\t\t# Jump to the callee function\n");
			System.out.println("jal " + $1.name + "_fn\t\t# Jump to the callee function");

			// Step 7 of the Stack Discipline -  Restore the stack pointer for the caller
			out.write("addi $sp, $sp, 104\t# Restores the stack pointer for the caller\n");
			System.out.println("addi $sp, $sp, 104\t# Restores the pointer for the caller");
			
			// Step 8 of the Stack Discipline - Restore the frame pointer for the caller
			out.write("lw $fp, 4($sp)\t\t# Restores the frame pointer of the caller\n");
			System.out.println("lw $fp, 4($sp)\t\t# Restores the frame pointer of the caller");
			
			// Step 9 of the Stack Discipline - Restore all necessary registers (in this case, $a and $t registers)
			for(int i = 0, j = 40; i < 4; i++, j = j+4){		
				out.write("lw $a" + i + ", " + j + "($sp)\n");
				System.out.println("lw $a" + i + ", " + j + "($sp)");
				freeArgReg(i);
			}
			
			// Free all argument registers
			freeAllArg();
			
			for(int i = 0, j = 8; i < 8; i++, j = j+4){
				out.write("lw $t" + i + ", " + j + "($sp)\n");
				System.out.println("lw $t" + i + ", " + j + "($sp)");
				freeReg(i);
			}
			
			// Free all registers, nothing is needed at this point
			freeAll();
			
			// Gather a register number for the return variable to go in.
			regNumber = getReg();
			
			// Step 10 of the Stack Discipline - Gather the return variable from the callee function
			out.write("move $t" + regNumber + ", $v0\t\t# Move the return variable to an available temp register\n");
			System.out.println("move $t" + regNumber + ", $v0\t\t# Move the return variable to an available temp register");
			
		} catch ( IOException e) { 
			e.printStackTrace();
		}
	}
	|	WHILE '(' 
	{	
		// Grabs a random ID of 5 characters.  The ID's are originally too long for this situation
		randomConditionalID = UUID.randomUUID().toString().substring(0,5);
		
		// Push the label onto the stack
		conditionalLabels.push(randomConditionalID);
		
		try {

			out.write("\nwhile_" + randomConditionalID + ":\t\t# Start of a while loop\n");
			System.out.println("\nwhile_" + randomConditionalID + ":\t\t# Start of a while loop");

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
	} expression ')'
	{
		
		try {
			
			out.write("beq $t" + $4.register + ", $zero, skip_while_" + randomConditionalID + "\t# While condition\n");
			System.out.println("beq $t" + $4.register + ", $zero, skip_while_" + randomConditionalID + "\t# While condition");

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
	} statement
	{
		// Pop the random ID off of the stack
		randomConditionalID = conditionalLabels.pop();
		
		try {
			
			out.write("j while_" + randomConditionalID + "\t\t# Jump back to the while condition\n");
			System.out.println("j while_" + randomConditionalID + "\t\t# Jump back to the while condition");
			
			out.write("skip_while_" + randomConditionalID + ":\t# End of the while loop\n");
			System.out.println("skip_while_" + randomConditionalID + ":\t# End of the while loop");

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
		freeAll();
	}
	|	if_first ELSE
	{
		try {

			out.write("skip_if_" + randomConditionalID + ":\t\t# Start of an else statement\n");
			System.out.println("skip_if_" + randomConditionalID + ":\t\t# Start of an else statement");

		} catch ( IOException e) { 
			e.printStackTrace();
		}

	}statement
	{
		// Pop the label off of the stack
		randomConditionalID = conditionalLabels.pop();
		try {

			out.write("end_if_" + randomConditionalID + ":\t\t# End of the if statement\n");
			System.out.println("end_if_" + randomConditionalID + ":\t\t# End of the if statement");

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
		freeAll();
	} 
	|	if_first %prec SHIFT_ELSE
	{
		// Need to pop the label off, it was peek() in if_first
		randomConditionalID = conditionalLabels.pop();
		
		try {

			out.write("skip_if_" + randomConditionalID + ":\n");
			System.out.println("skip_if_" + randomConditionalID + ":");
			
			out.write("end_if_" + randomConditionalID + ":\t\t# End of the if statement\n");
			System.out.println("end_if_" + randomConditionalID + ":\t\t# End of the if statement");
			

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
		freeAll();
	}
	|	RETURN '(' ')' ';' 
	{
		// Step 14 of the Stack Discipline - Load saved return address
		try {
						
			out.write("lw $ra, 0($sp)" + "\t\t# Load the return value\n");
			System.out.println("lw $ra, 0($sp)" + "\t\t# Load the return value");
			
			out.write("jr $ra" + "\t\t# Jump to the return register\n");
			System.out.println("jr $ra" + "\t\t# Jump to the return register");
			
		} catch ( IOException e) { 
			e.printStackTrace();
		}
	}
	|	RETURN '(' expression ')' ';' 
	{
				
		try {

			// Step 13 of the Stack Discipline - Move the return value to the return register
			out.write("move $v0, $t" + $3.register + "\t\t# Move the return value to the return register\n");
			System.out.println("move $v0, $t" + $3.register + "\t\t# Move the return value to the return register");
			
			// Step 14 of the Stack Discipline - Load saved return address
			out.write("lw $ra, 0($sp)" + "\t\t# Load the return value\n");
			System.out.println("lw $ra, 0($sp)" + "\t\t# Load the return value");
			
			out.write("jr $ra" + "\t\t# Jump to the return register\n");
			System.out.println("jr $ra" + "\t\t# Jump to the return register");
			

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
		freeReg($3.register);
	}
	;
	
if_first: IF '(' expression ')' 
	{
		
		// Grabs a random ID of 5 characters.  The ID's are originally too long for this situation
		randomConditionalID = UUID.randomUUID().toString().substring(0,5);

		// Push the label onto the stack
		conditionalLabels.push(randomConditionalID);
		
		try {

			out.write("\nbeq $t" + $3.register + ", $zero, skip_if_" + randomConditionalID + "\t# Start of an if statement\n");
			System.out.println("\nbeq $t" + $3.register + ", $zero, skip_if_" + randomConditionalID + "\t# Start of an if statement");	
			
		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
		freeReg($3.register);
		
	} statement
	{
		// Peek at the random ID that is sitting on the stack, we don't want to prematurely pop it here
		randomConditionalID = conditionalLabels.peek();
		try {

			out.write("\nj end_if_" + randomConditionalID + "\t\t# Jump to end of the if statement\n");
			System.out.println("\nj end_if_" + randomConditionalID + "\t\t# Jump to end of the if statement");

		} catch ( IOException e) { 
			e.printStackTrace();
		}
	}
	;
var:	ID 
	{	
		
		// Find the variable in the symbol table
		varCalled = lookup($1,1);
		
		// Gathers a free register number
		regNumber = getReg();
		
		try {
			
			// We are in the local scope, load it from the stack
			if(local){
				out.write("lw $t" + regNumber + ", " + varCalled.position + "($sp)\n");
				System.out.println("lw $t" + regNumber + ", " + varCalled.position + "($sp)");
			
			// We are in the global scope, prefix with "global_"
			} else {
				out.write("lw $t" + regNumber + ", " + "global_" + varCalled.name+ "\n");
				System.out.println("lw $t" + regNumber + ", " + "global_" + varCalled.name);
			}

		} catch ( IOException e) { 
			e.printStackTrace();
		}

		$$.register = regNumber;
		$$.type = "identifier";
	}
	|	ID '[' expression ']' 
	{
		// Gathers a free register number
		regNumber = getReg();
		
		try {

			out.write("la $t" + regNumber + ", " + "global_" + $1.name+ "\n");
			System.out.println("la $t" + regNumber + ", " + "global_" + $1.name);
			
			out.write("mul $t" + $3.register + ", $t" + $3.register + ", 4\n");
			System.out.println("mul $t" + $3.register + ", $t" + $3.register +  ", 4");
			
			out.write("add $t" + regNumber + ", $t" + regNumber + ", $t" + $3.register + "\n");
			System.out.println("add $t" + regNumber + ", $t" + regNumber +  ", $t" + $3.register);
			
			// Gathers a free register number
			typeRegNumber = getReg();
			
			out.write("lw $t" + typeRegNumber + ", 0($t" + regNumber + ")\n");
			System.out.println("lw $t" + typeRegNumber + ", 0($t" + regNumber +  ")");
			
			freeReg($3.register);
			
		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
		$$.register = typeRegNumber;
		$$.typeRegister = regNumber;
		$$.type = "type";
	}
	|	ID '.' ID 
	{	
		// Gathers a free register number
		regNumber = getReg();
		
		// Find the record in the global scope 
		recordCalled = lookupGlobal($1);
		
		// Iterate through all the variables contained in the record
		for(int i = 0; i < recordCalled.variablesInRecord.size(); i++){
			
			// If the variable referenced is found
			if(recordCalled.variablesInRecord.get(i).name.equals($3.name)){
				
				try {
					out.write("la $t" + regNumber + ", " + "global_" + $1.name+ "\n");
					System.out.println("la $t" + regNumber + ", " + "global_" + $1.name);

					out.write("addi $t" + regNumber + ", $t" + regNumber + ", " + (i*4) + "\n");
					System.out.println("addi $t" + regNumber + ", $t" + regNumber + ", " + (i*4));

					// Gathers a free register number
					typeRegNumber = getReg();

					out.write("lw $t" + typeRegNumber + ", 0($t" + regNumber + ")\n");
					System.out.println("lw $t" + typeRegNumber + ", 0($t" + regNumber +  ")");

				} catch ( IOException e) { 
					e.printStackTrace();
				}
			}
		}
		$$.register = typeRegNumber;
		$$.typeRegister = regNumber;
		$$.type = "type";
	}
	;

expression_list:	expression_list ',' expression
	{
		// We are inside a function
		if(function){			
			try {
				
				// Gather a new argument register
				regNumber = getArgReg();
				
				// Step 2 of the Stack Discipline - Move actual parameters to the $a registers
				out.write("move $a" + regNumber + ", $t" + $3.register + "\t\t# Loads arguments for the callee function\n");
				System.out.println("move $a" + regNumber + ", $t" + $3.register + "\t\t# Loads arguments for the callee function");

			} catch ( IOException e) { 
				e.printStackTrace();
			}
			
			freeReg($3.register);
		}
	}
	|	expression
	{
		// We are inside a function
		if(function){
			
			try {
				
				// Gather a new argument register
				regNumber = getArgReg();
				
				// Step 2 of the Stack Discipline - Move actual parameters to the $a registers
				out.write("move $a" + regNumber + ", $t" + $1.register + "\t\t# Loads arguments for the callee function\n");
				System.out.println("move $a" + regNumber + ", $t" + $1.register + "\t\t# Loads arguments for the callee function");

			} catch ( IOException e) { 
				e.printStackTrace();
			}
			freeReg($1.register);
		}
	}
	;

expression:	bool1 LOGICAL_AND bool1 
	{
		try {

			out.write("and $t" + $1.register + ", $t" + $1.register + ", $t" + $3.register + "\n");
			System.out.println("and $t" + $1.register + ", $t" + $1.register + ", $t" + $3.register);

		} catch ( IOException e) { 
			e.printStackTrace();
		}
	
		// Free the register
		freeReg($3.register);
		
		$$.register = $1.register;
		
	}
	| bool1 LOGICAL_OR bool1
	{
		try {

			out.write("or $t" + $1.register + ", $t" + $1.register + ", $t" + $3.register + "\n");
			System.out.println("or $t" + $1.register + ", $t" + $1.register + ", $t" + $3.register);

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
		// Free the register
		freeReg($3.register);
		
		$$.register = $1.register;
	}
	|	bool1 
	{ 
		
		$$.register = $1.register; 
	}
	;
	
bool1:	LOGICAL_NOT bool1 
	{
		// Grabs a random ID of 5 characters.  The ID's are originally too long for this situation
		randomID = UUID.randomUUID().toString().substring(0,5);
			
		try {
			
			// If bool1 is 0, jump to the false_branch and make it 1
			out.write("beq $zero, $t" + $2.register + " false_branch_" + randomID + "\n");	
			System.out.println("beq $zero, $t" + $2.register + " false_branch_" + randomID);
			
			out.write("move $t" + $2.register + ", $zero\t# Make it false if it was true\n");
			System.out.println("move $t" + $2.register + ", $zero\t# Make it false if it was true");
			
			// Jump to the end
			out.write("j end_" + randomID + "\n");
			System.out.println("j end_" + randomID);
			
			out.write("false_branch_" + randomID + ":\n");
			System.out.println("false_branch_" + randomID + ":");
			
			out.write("\taddi $t" + $2.register + ", $zero, 1\t# Make it true if it was false\n");
			System.out.println("\taddi $t" + $2.register + ", $zero, 1\t# Make it true if it was false");
			
			out.write("end_" + randomID + ":\n");
			System.out.println("end_" + randomID + ":");
			
			$$.register = $2.register;
		} catch ( IOException e) { 
			e.printStackTrace();
		}
	}
	|	bool2 { $$.register = $1.register; }
	;

bool2:	exp LESS exp 
	{
		// Gather a register number for the return variable to go in.
		regNumber = getReg();
		
		try {

			out.write("slt $t" + regNumber + ", $t" + $1.register + ", $t" + $3.register + "\n");
			System.out.println("slt $t" + regNumber + ", $t" + $1.register + ", $t" + $3.register);		

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
		// Free registers
		freeReg($1.register);
		freeReg($3.register);
		
		$$.register = regNumber;
		
	}
	| exp LESS_EQUAL exp 
	{

		// Grabs a random ID of 5 characters.  The ID's are originally too long for this situation
		randomID = UUID.randomUUID().toString().substring(0,5);
		
		try {

			// If they really are not equal - branch
			out.write("ble $t" + $1.register + ", $t" + $3.register + ", less_equal_" + randomID + "\n");
			System.out.println("ble $t" + $1.register + ", $t" + $3.register + ", less_equal_" + randomID);
			
			// Free registers
			freeReg($1.register);
			freeReg($3.register);
			
			// Gather a register number for the return variable to go in.
			regNumber = getReg();
			
			// Fall through if they are not less than or equal to
			out.write("addi $t" + regNumber + ", $zero, 0\n");
			System.out.println("addi $t" + regNumber + ", $zero, 0");
			
			// Jump past the less_equal branch
			out.write("j end_" + randomID + "\n");
			System.out.println("j end_" + randomID);
			
			// Label that will be used if they are not equal
			out.write("less_equal_" + randomID + ":\n");
			System.out.println("less_equal_" + randomID + ":");
			
			out.write("addi $t" + regNumber + ", $zero, 1\n");
			System.out.println("addi $t" + regNumber + ", $zero, 1");
			
			out.write("end_" + randomID + ":\n");
			System.out.println("end_" + randomID + ":");

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
		$$.register = regNumber;
	}
	| exp GREATER_EQUAL exp
	{
		
		// Grabs a random ID of 5 characters.  The ID's are originally too long for this situation
		randomID = UUID.randomUUID().toString().substring(0,5);
		
		try {

			// If they really are not equal - branch
			out.write("ble $t" + $3.register + ", $t" + $1.register + ", less_equal_" + randomID + "\n");
			System.out.println("ble $t" + $3.register + ", $t" + $1.register + ", less_equal_" + randomID);
			
			// Free registers
			freeReg($1.register);
			freeReg($3.register);
			
			// Gather a register number for the return variable to go in.
			regNumber = getReg();
			
			// Fall through if they are not less than or equal to
			out.write("addi $t" + regNumber + ", $zero, 0\n");
			System.out.println("addi $t" + regNumber + ", $zero, 0");
			
			// Jump past the less_equal branch
			out.write("j end_" + randomID + "\n");
			System.out.println("j end_" + randomID);
			
			// Label that will be used if they are not equal
			out.write("less_equal_" + randomID + ":\n");
			System.out.println("less_equal_" + randomID + ":");
			
			out.write("addi $t" + regNumber + ", $zero, 1\n");
			System.out.println("addi $t" + regNumber + ", $zero, 1");
			
			out.write("end_" + randomID + ":\n");
			System.out.println("end_" + randomID + ":");

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
		$$.register = regNumber;
	}
	| exp GREATER exp
	{
		// Gather a register number for the return variable to go in.
		regNumber = getReg();
		
		try {

			out.write("slt $t" + regNumber + ", $t" + $3.register + ", $t" + $1.register + "\n");
			System.out.println("slt $t" + regNumber + ", $t" + $3.register + ", $t" + $1.register);		

		} catch ( IOException e) { 
			e.printStackTrace();
		}

		// Free registers
		freeReg($3.register);
		freeReg($1.register);
		
		$$.register = regNumber;
	}
	| exp NOT_EQUAL exp
	{
		
		// Grabs a random ID of 5 characters.  The ID's are originally too long for this situation
		randomID = UUID.randomUUID().toString().substring(0,5);
		
		try {

			// If they really are not equal - branch
			out.write("bne $t" + $1.register + ", $t" + $3.register + ", not_equal_" + randomID + "\n");
			System.out.println("bne $t" + $1.register + ", $t" + $3.register + ", not_equal_" + randomID);
			
			// Free registers
			freeReg($1.register);
			freeReg($3.register);
			
			// Gather a register number for the return variable to go in.
			regNumber = getReg();
			
			// Fall through if they are equal
			out.write("addi $t" + regNumber + ", $zero, 0\n");
			System.out.println("addi $t" + regNumber + ", $zero, 0");
			
			// Jump past the not equal branch
			out.write("j end_" + randomID + "\n");
			System.out.println("j end_" + randomID);
			
			// Label that will be used if they are not equal
			out.write("not_equal_" + randomID + ":\n");
			System.out.println("not_equal_" + randomID + ":");
			
			out.write("addi $t" + regNumber + ", $zero, 1\n");
			System.out.println("addi $t" + regNumber + ", $zero, 1");
			
			out.write("end_" + randomID + ":\n");
			System.out.println("end_" + randomID + ":");

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
		$$.register = regNumber;
	}
	| exp EQUAL exp
	{
		
		// Grabs a random ID of 5 characters.  The ID's are originally too long for this situation
		randomID = UUID.randomUUID().toString().substring(0,5);
		
		try {

			// If they really are not equal - branch
			out.write("bne $t" + $1.register + ", $t" + $3.register + ", not_equal_" + randomID + "\n");
			System.out.println("bne $t" + $1.register + ", $t" + $3.register + ", not_equal_" + randomID);
			
			// Free registers
			freeReg($1.register);
			freeReg($3.register);
			
			// Gather a register number for the return variable to go in.
			regNumber = getReg();
			
			// Fall through if they are equal
			out.write("addi $t" + regNumber + ", $zero, 1\n");
			System.out.println("addi $t" + regNumber + ", $zero, 1");
			
			// Jump past the not equal branch
			out.write("j end_" + randomID + "\n");
			System.out.println("j end_" + randomID);
			
			// Label that will be used if they are not equal
			out.write("not_equal_" + randomID + ":\n");
			System.out.println("not_equal_" + randomID + ":");
			
			out.write("addi $t" + regNumber + ", $zero, 0\n");
			System.out.println("addi $t" + regNumber + ", $zero, 0");
			
			out.write("end_" + randomID + ":\n");
			System.out.println("end_" + randomID + ":");

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
		$$.register = regNumber;
	}
	|	exp { $$.register = $1.register; }
	;

exp:	exp '+' term 
	{		
		try {

			out.write("add $t" + $1.register + ", $t" + $1.register + ", $t" + $3.register + "\n");
			System.out.println("add $t" + $1.register + ", $t" + $1.register + ", $t" + $3.register);

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
		// Free the register
		freeReg($3.register);
		
		$$.register = $1.register;
	}
	|	exp '-' term 
	{		
		try {

			out.write("sub $t" + $1.register + ", $t" + $1.register + ", $t" + $3.register + "\n");
			System.out.println("sub $t" + $1.register + ", $t" + $1.register + ", $t" + $3.register);

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
		// Free the register
		freeReg($3.register);
		
		$$.register = $1.register;
	}
	|	term { $$.register = $1.register; }
	;

term:	term '*' fact 
	{		
		try {

			out.write("mul $t" + $1.register + ", $t" + $1.register + ", $t" + $3.register + "\n");
			System.out.println("mul $t" + $1.register + ", $t" + $1.register + ", $t" + $3.register);

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
		// Free the register
		freeReg($3.register);
		
		$$.register = $1.register;
	}
	|	fact { $$.register = $1.register; }
	;

fact:	'-' fact 
	{
		try {

			out.write("neg $t" + $2.register + ", $t" + $2.register + "\n");
			System.out.println("neg $t" + $2.register + ", $t" + $2.register);

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
		$$.register = $2.register;
		
	}
	|	factor { $$.register = $1.register; }
	;

factor:	'(' expression ')' {$$.register = $2.register;}
	|	ID '(' ')' 
	{
		try {
			
			out.write("\n#########################################\n");
			System.out.println("\n#########################################");
			out.write("# Stack maintenance for a function call #\n");
			System.out.println("# Stack maintenance for a function call #");
			out.write("#########################################\n");
			System.out.println("#########################################");
			
			// Step 1 of the Stack Discipline - Save all pertinent registers needed by the calling function
			for(int i = 0, j = 8; i < 8; i++, j = j+4){
				out.write("sw $t" + i + ", " + j + "($sp)\n");
				System.out.println("sw $t" + i + ", " + j + "($sp)");
			}
			
			for(int i = 0, j = 40; i < 4; i++, j = j+4){		
				out.write("sw $a" + i + ", " + j + "($sp)\n");
				System.out.println("sw $a" + i + ", " + j + "($sp)");
			}
			
			// Step 3 of the Stack Discipline - Save the frame pointer of the calling function 
			out.write("sw $fp, 4($sp)\t\t# Saves the frame pointer of the caller\n");
			System.out.println("sw $fp, 4($sp)\t\t# Saves the frame pointer of the caller");
			
			// Step 4 of the Stack Discipline - Allocate a new frame on the stack for the callee function
			out.write("addi $sp, $sp, -104\t# Allocates a new frame for the callee\n");
			System.out.println("addi $sp, $sp, -104\t# Allocates a new frame for the callee");
			
			// Step 5 of the Stack Discipline -  Set the top of the frame of the callee
			out.write("addi $fp, $sp, 100\t# Sets the frame of the callee\n\n");
			System.out.println("addi $fp, $sp, 100\t# Sets the frame of the callee\n");
			
			// Step 6 of the Stack Discipline -  Jump to the start of the callee function
			// If the function is main, just use that name, otherwise we need to append _fn on the end.
			
			// We are inside main, call the function as "main"
			if ($1.name.equals("main")) {
				out.write("jal " + $1.name + "\t\t# Jump to the main function\n");
				System.out.println("jal " + $1.name + "\t\t# Jump to the main function");
				
			// We are not in main, so append _fn to it
			} else {
				out.write("jal " + $1.name + "_fn\t\t# Jump to the callee function\n");
				System.out.println("jal " + $1.name + "_fn\t\t# Jump to the callee function");
			}
			
			// Step 7 of the Stack Discipline -  Restore the stack pointer for the caller
			out.write("addi $sp, $sp, 104\t# Restores the stack pointer for the caller\n");
			System.out.println("addi $sp, $sp, 104\t# Restores the pointer for the caller");
			
			// Step 8 of the Stack Discipline - Restore the frame pointer for the caller
			out.write("lw $fp, 4($sp)\t\t# Restores the frame pointer of the caller\n");
			System.out.println("lw $fp, 4($sp)\t\t# Restores the frame pointer of the caller");
			
			// Step 9 of the Stack Discipline - Restore all necessary registers (in this case, $a and $t registers)
			for(int i = 0, j = 40; i < 4; i++, j = j+4){		
				out.write("lw $a" + i + ", " + j + "($sp)\n");
				System.out.println("lw $a" + i + ", " + j + "($sp)");
			}
			
			for(int i = 0, j = 8; i < 8; i++, j = j+4){
				out.write("lw $t" + i + ", " + j + "($sp)\n");
				System.out.println("lw $t" + i + ", " + j + "($sp)");
			}	
			
			// Gather a register number for the return variable to go in.
			regNumber = getReg();
			
			// Step 10 of the Stack Discipline - Gather the return variable from the callee function
			out.write("move $t" + regNumber + ", $v0\t\t# Move the return variable to an available temp register\n");
			System.out.println("move $t" + regNumber + ", $v0\t\t# Move the return variable to an available temp register");

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
		$$.register = regNumber;
	}
	|	ID '(' 
	{
		try {

			out.write("\n#########################################\n");
			System.out.println("\n#########################################");
			out.write("# Stack maintenance for a function call #\n");
			System.out.println("# Stack maintenance for a function call #");
			out.write("#########################################\n");
			System.out.println("#########################################");
		
			// Step 1 of the Stack Discipline - Save all pertinent registers needed by the calling function
			for(int i = 0, j = 8; i < 8; i++, j = j+4){
				out.write("sw $t" + i + ", " + j + "($sp)\n");
				System.out.println("sw $t" + i + ", " + j + "($sp)");
			}
			
			for(int i = 0, j = 40; i < 4; i++, j = j+4){		
				out.write("sw $a" + i + ", " + j + "($sp)\n");
				System.out.println("sw $a" + i + ", " + j + "($sp)");
			}
			
			// Step 3 of the Stack Discipline - Save the frame pointer of the calling function 
			out.write("sw $fp, 4($sp)\t\t# Saves the frame pointer of the caller\n");
			System.out.println("sw $fp, 4($sp)\t\t# Saves the frame pointer of the caller");

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
		// Trigger to capture the arguments needed for the procedure.
		function = true;
		
		// Clear the argument registers
		freeAllArg();
		
	}expression_list ')' 
	{
		try {
			
			// Step 4 of the Stack Discipline - Allocate a new frame on the stack for the callee function
			out.write("addi $sp, $sp, -104\t# Allocates a new frame for the callee\n");
			System.out.println("addi $sp, $sp, -104\t# Allocates a new frame for the callee");
			
			// Step 5 of the Stack Discipline - Set the top of the frame of the callee
			out.write("addi $fp, $sp, 100\t# Sets the frame of the callee\n");
			System.out.println("addi $fp, $sp, 100\t# Sets the frame of the callee\n");
			
			// Step 6 of the Stack Discipline -  Jump to the start of the callee function
			out.write("jal " + $1.name + "_fn\t\t# Jump to the callee function\n");
			System.out.println("jal " + $1.name + "_fn\t\t# Jump to the callee function");

			// Step 7 of the Stack Discipline -  Restore the stack pointer for the caller
			out.write("addi $sp, $sp, 104\t# Restores the stack pointer for the caller\n");
			System.out.println("addi $sp, $sp, 104\t# Restores the pointer for the caller");
			
			// Step 8 of the Stack Discipline - Restore the frame pointer for the caller
			out.write("lw $fp, 4($sp)\t\t# Restores the frame pointer of the caller\n");
			System.out.println("lw $fp, 4($sp)\t\t# Restores the frame pointer of the caller");
			
			// Step 9 of the Stack Discipline - Restore all necessary registers (in this case, $a and $t registers)
			for(int i = 0, j = 40; i < 4; i++, j = j+4){		
				out.write("lw $a" + i + ", " + j + "($sp)\n");
				System.out.println("lw $a" + i + ", " + j + "($sp)");
			}
			
			for(int i = 0, j = 8; i < 8; i++, j = j+4){
				out.write("lw $t" + i + ", " + j + "($sp)\n");
				System.out.println("lw $t" + i + ", " + j + "($sp)");
			}

			// Gather a register number for the return variable to go in.
			regNumber = getReg();
			
			// Step 10 of the Stack Discipline - Gather the return variable from the callee function
			out.write("move $t" + regNumber + ", $v0\t\t# Move the return variable to an available temp register\n");
			System.out.println("move $t" + regNumber + ", $v0\t\t# Move the return variable to an available temp register");
			
		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
		$$.register = regNumber;
	}
	|	var { $$.register = $1.register; }
	|	GETINT '(' ')'
	{
		
		// Gather the input from the user
		try {
			
			out.write("li $v0, 4\n");
			System.out.println("li $v0, 4");
			out.write("la $a0, Enter\n");
			System.out.println("la $a0, Enter");
			out.write("syscall\t\t\t# Prints out prompt\n");
			System.out.println("syscall\t\t\t# Prints out prompt");
			
			
			out.write("li $v0, 5\n");
			System.out.println("li $v0, 5");
			out.write("syscall\n");
			System.out.println("syscall");
			
			// Grab a free register to the move the input to
			regNumber = getReg();
			
			out.write("move $t" + regNumber + ", $v0\t\t# Gathers input from user\n");	
			System.out.println("move $t" + regNumber + ", $v0\t\t# Gathers input from user");
			
			$$.register = regNumber;
		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
	}
	|	NUM 
	{
		// Grab a register
		regNumber = getReg();
		
		try {
			out.write("li $t" + regNumber +", " + $1.name + "\n");	
			System.out.println("li $t" + regNumber +", " + $1.name);
		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
		$$.register = regNumber;
	}
	|	TRUE
	{
		// Grab a free register
		regNumber = getReg();
		
		try {
			out.write("li $t" + regNumber +", 1\t\t# 1 = true\n");	
			System.out.println("li $t" + regNumber +", 1\t\t# 1 = true");
		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
		$$.register = regNumber;
	}
	|	FALSE	
	{
		// Grab a free register
		regNumber = getReg();
		
		try {
			out.write("li $t" + regNumber +", 0\t\t# 0 = false\n");	
			System.out.println("li $t" + regNumber +", 0\t\t# 0 = false");
		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
		$$.register = regNumber;
	}
	;
	
	
%%
	// symbolTable - used to provide all the operations of a stack
	// 		with the added benefit of an easy search mechanism.  This holds 
	//		the current state of the Symbol Table tree.
	private LinkedList<LinkedList> symbolTable = new LinkedList<LinkedList>();
	
	// scope - a LinkedList structure is used to hold the state of
	// 		the local(current) scope
	// global - holdes the state of the global scope
	private LinkedList<Semantic> scope, global;
	
	// lexer - an instance of the lexical scanner
	private Lexer lexer;
	
	// registers - an array holding an abstract view of the temporary variables of the system.
	// argRegisters - an array holding the argument registers
	private int[] registers = new int[8];
	private int[] argRegisters = new int[4];
	
	// regNumber - number received from getReg()
	// typeRegNumber - used to hold the register number of the type index
	// numOfRecordTypes - Holds the number of declarations inside a record
	// i - a simple iterator;
	private int regNumber, typeRegNumber, numOfRecordTypes, i;
	
	// stackVars - the starting position of variable saving on the stack
	private int stackVars = 56;
		
	// local - a boolean denoting if we are in local or global scope.
	// function - a boolean denoting if expression needs to keep track of formal parameters of procedures
	// main - are we inside the main function?
	// type - are we dealing with a type (array or record)?
	private boolean local, function, main, type= false;
	
	// out - writer which allows us to write to a file.
	private BufferedWriter out;
	
	// currentFunct - Holds the current function.  This is used for returns
	// functionCalled - Holds the function that was just looked up
	// recordCalled - holds the struct that was looked up
	// arrayCalled - holds the array that was just looked up
	// varCalled - holds the variable that was just looked up
	// typeCalled - holds the type (array or struct) that was looked up
	private Semantic currentFunct, functionCalled, recordCalled, arrayCalled, varCalled, typeCalled;

	// randomID - a random identifier used for labeling in expressions.
	// randomConditionalID - a random identifier used for labeling in conditionals
	private String randomID, randomConditionalID;
	
	// recordDeclarations - a linkedlist holding the declarations inside a record
	private LinkedList<Semantic> recordDeclarations = new LinkedList<Semantic>();
	private LinkedList<String> conditionalLabels = new LinkedList<String>();
	
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
	public Parser (Reader r){
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
	
	/**
	  * Finds the identifier in the symbol table, either in the local scope or its parent scopes
	  * @param value - an object with a value that we need to find
	  * @param error - decided by the calling method, used for error printing
	  * @return Semantic - an instance of the identifier that we were looking for 
	  */
	 @SuppressWarnings("unchecked")
	 private Semantic lookup(Semantic value, int error){
		local = true;
		 // Grab the current local scope
		 scope = (LinkedList) symbolTable.peek();
		
		int i = 0;
		// CurrentFunct will hold all variables within a function - even in subscopes.
		for(String identifier : currentFunct.variables){
			if(identifier.equals(value.name)){
				//System.out.println("@@ FOUND HERE: " + i + "\t" + value.name);
				value.position = (i*4) + 56;
				return value;
			}
			i++;
		}
		
		local = false;
		return value;
	 }

	 /**
	  * Find the function by checking the global scope only
	  * @param value - a Semantic object with a value (identifier) that we wish to lookup in the symbol table.
	  * @return Semantic - an instance of the found function
	  */
	 @SuppressWarnings("unchecked")
	 private Semantic lookupGlobal(Semantic value){	 	 

		 // Grab the global scope
		 global = (LinkedList) symbolTable.getLast();

		 // Iterate through the functions/types, returning if found
		 for(Semantic identifier : global){
			 if(identifier.name.equals(value.name)){
				return identifier;		 
			 }
		 }

		 // The function has not yet been declared
		 System.out.println("Line " + lexer.getLine() + ": Undeclared function " + value.name);

		 // If nothing is found, send back a default Semantic object
		 return new Semantic(null, "default");
	 }
	 
/*********************************************
 *		     REGISTER Helper Methods         *
 *********************************************/	

	/**
	 * getReg - returns a free register from $t0-$t7
	 * @return int - integer of a free register that can be used
	 */
	public int getReg() {
		for(int i = 0; i < registers.length; i++){
			if(registers[i] == 0){	
				registers[i] = 1;				
				return i;
			}
		}	
		return -1;	
	}
	
	/**
	 * freeReg - frees the temporary register
	 * @param registerNumber - a simple integer of the register to be freed
	 */
	public void freeReg(int registerNumber) {
		registers[registerNumber] = 0;
	}
	
	/**
	 * freeAll - frees all temporary registers
	 */
	public void freeAll() {
		for(int i = 0; i < 8; i++){
			freeReg(i);
		}
	}
	
	/**
	 * freeAllArg - free all argument registers
	 */
	public void freeAllArg() {
		for(int i = 0; i < 4; i++){
			freeArgReg(i);
		}
	}
	
	/**
	 * getArgReg - find a free argument register for use
	 * @return int - integer of a free argument register
	 */
	public int getArgReg() {
		for(int i = 0; i < argRegisters.length; i++){
			if(argRegisters[i] == 0){	
				argRegisters[i] = 1;				
				return i;
			}
		}	
		return -1;
	}
	
	/**
	 * freeArgReg - free the desired argument register
	 * @param registerNumber - an integer of the desired argument register to be freed
	 */
	public void freeArgReg(int registerNumber) {
		argRegisters[registerNumber] = 0;
	}

/***********************************************
 *   Semantic object - in place of ParserVal   *                                          
 ***********************************************/
 
	 public static final class Semantic{
		
		private String name;			// Name of the identifier
		private String type;			// Type of the identifier
		private int register;			// Register where the value is being held
		private int typeRegister;		// Register where the index of the type is being held
		private int position;			// Position on the stack
		private int typeSize;			// Size of the type being declared.
		
		
		// variables - List which holds the parameters of a function
		public LinkedList<String> variables = new LinkedList<String>();
		
		// variablesInRecord - List which holds the variables of a record
		public LinkedList<Semantic> variablesInRecord;
		
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
