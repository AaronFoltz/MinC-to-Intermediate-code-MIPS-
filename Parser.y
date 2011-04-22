%{
import java.io.*;
import java.util.*;

/**
 * @author Aaron Foltz
 * CS540 - Program 4
 *
 * Of Note:  The actual production items are on the same line as the closing curly brackets
 */

/*
	TODO Work on Arrays/Records - LAST
	TODO Look for registers to be freed (expressions that take more than 2 registers) 
*/
%}
 
%token ID NUM IF ELSE WHILE TRUE FALSE BOOL INT TYPE_ID RETURN PRINTINT GETINT ASSIGN_OP LOGICAL_NOT LOGICAL_AND LOGICAL_OR
%token LESS LESS_EQUAL GREATER GREATER_EQUAL EQUAL NOT_EQUAL
 
//%left REL_OP
//%left LOGICAL_AND LOGICAL_OR
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
	{ 
		/*try {
			
			// out.write("\t.data\n");
			// System.out.println("\t.data");
		
		} catch ( IOException e) { 
			e.printStackTrace();
		}*/
		
	}
	| 	type_decl	
	;

fn_decl: type ID 
	{   
		local = true;
		insert($2, $1.name); 
		currentFunct = $2;
		enterScope(); 
		
		try {
			
			out.write("\n\t.text\n");
			System.out.println("\n\t.text");
			
			if($2.name.equals("main")){
				out.write("\n####################################\n");
				System.out.println("\n####################################");
				out.write("# Function: " + new String($2.name) + " starts here\n");
				System.out.println("# Function: " + new String($2.name) + " starts here");
				out.write("####################################\n");
				System.out.println("####################################");
				
				out.write(new String($2.name).toLowerCase() + ":\n\n");
				System.out.println(new String($2.name).toLowerCase() + ":\n");
				main = true;
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
			
			/*out.write("addi $sp, $sp, -104 # Allocates a new frame for the process\n");
			System.out.println("addi $sp, $sp, -104 # Allocates a new frame for the process");
			
			out.write("sw $fp, 4($sp)\n");
			System.out.println("sw $fp, 4($sp)");
			for(int i = 0, j = 8; i < 8; i++, j = j+4){
				out.write("sw $t" + i + ", " + j + "($sp)\n");
				System.out.println("sw $t" + i + ", " + j + "($sp)");
			}
			
			for(int i = 0, j = 40; i < 4; i++, j = j+4){		
				out.write("sw $a" + i + ", " + j + "($sp)\n");
				System.out.println("sw $a" + i + ", " + j + "($sp)");
			}*/
			
			out.write("\t.text\n");
			System.out.println("\t.text");

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		regNumber = 0;
		stackVars = 56;
	}params '{' 
	{
		
		
		
	}var_decls
	{
		currentFunct.position = stackVars;
		try {

			/*out.write("\n\t.text\n");
			System.out.println("\n\t.text");*/
			
			// Step 11 of the Stack Discipline - Save the return address of the calling function. 
			out.write("sw $ra, 0($sp)\t\t# Save the return address of the caller\n");
			System.out.println("sw $ra, 0($sp)\t\t# Save the return address of the caller");
			
			// Step 12 of the Stack Discipline - Save the parameters onto the stack
			for(int i = 0, j = 40; i < 4; i++, j = j+4){		
				out.write("sw $a" + i + ", " + j + "($sp)\n");
				System.out.println("sw $a" + i + ", " + j + "($sp)");
				freeArgReg(i);
			}
			
			for(int i = 0, j = 8; i < 8; i++, j = j+4){
				freeReg(i);
			}
			
			// Prints out a newline in the source code - aesthetic purposes
			out.write("\n");
			System.out.println();
			
			

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
	} statements '}'	
	
	{ 
		exitScope(); 
		local = false;
		
		try {
			if(!main){
				
				// Step 14 of the Stack Discipline - Load saved return address and jump to it
				out.write("lw $ra, 0($sp)\t\t# Load the return value of the calling function\n");
				System.out.println("lw $ra, 0($sp)\t\t# Load the return value of the calling function");
				
				// At the end of this procedure, make sure it returns to the calling function (at the statement after the calling) 
				out.write("jr $ra\t\t\t# Jump to the return address of the caller\n");
				System.out.println("jr $ra\t\t\t# Jump to the return address of the caller");
				
				
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
			
			try {
				/*out.write("local_" + $2.name + ": .word 0\n");
				System.out.println("local_" + $2.name + ": .word 0");*/
				
				out.write("sw $zero" + ", " +  stackVars + "($sp)\t# Save the local vars on the stack\n");
				System.out.println("sw $zero" + ", " +  stackVars + "($sp)\t# Save the local vars on the stack");
				regNumber++;
				stackVars = stackVars+4;
				
				
			} catch ( IOException e) { 
				e.printStackTrace();
			}
			currentFunct.variables.add($2.name);
			
		// Global Scope
		}else{
			if($1.type.equals("type")){
				typeCalled = lookupGlobal($1);
								
				try {

					out.write("global_" + $2.name + ": .space " + (typeCalled.typeSize) + "\t# Allocates space for the array\n");
					System.out.println("global_" + $2.name + ": .space " + (typeCalled.typeSize) + "\t# Allocates space for the array");

				} catch ( IOException e) { 
					e.printStackTrace();
				}
				
			} else {
				
				try {
				
					out.write("global_" + $2.name + ": .word 0\n");
					System.out.println("global_" + $2.name + ": .word 0");
				
				} catch ( IOException e) { 
					e.printStackTrace();
				}
			}
			
		}
		 
		insert($2, $1.name); 
		//$2.argRegister = -1;
	
	}
	;

type_decl:	type '[' NUM ']' TYPE_ID ';' 
	{ 	
		/*try {
			
			out.write("global_" + $5.name + ": .space " + (Integer.parseInt($3.name)*4) + "\t# Allocates space for the array\n");
			System.out.println("global_" + $5.name + ": .space " + (Integer.parseInt($3.name)*4) + "\t# Allocates space for the array");
			
		} catch ( IOException e) { 
			e.printStackTrace();
		}*/
		
		insert($5, $1.name);
		$5.typeSize = Integer.parseInt($3.name)*4;
	} 
	|	'{' type_list '}' TYPE_ID ';' { insert($5, "type_list"); }
	;

type_list:	type_list type ID ';' {	insert($3, $2.name); }
	|	type ID ';' { insert($2, $1.name); }
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
		insert($4, $3.name); 
		/*$4.argRegister = regNumber++;*/
		// $4.param = true;
		currentFunct.variables.add($4.name);
		//System.out.println("@@ REG: " + $4.name + " " + $4.argRegister);
		
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
		insert($2, $1.name); 
		//$2.argRegister = regNumber++;
		//$2.param = true;
		currentFunct.variables.add($2.name);
		//System.out.println("@@ REG " + $2.name + " " + $2.argRegister);
		
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
		//System.out.println("@@ TYPE : " + $1.type);
		if($1.type.equals("type")){
			type = true;
		} else {
			type = false;
		}
		freeReg($1.register);
	} ASSIGN_OP expression ';' 
	{
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
			
		} else {
			varCalled = lookup($1,1);
		
			varCalled.register = $4.register;
	
			//System.out.println("@@ " + lookup($1,1).name + " " + $4.register);
	
	
			try {

				if(local){
					out.write("sw $t" + $4.register + ", " + varCalled.position + "($sp)\n");
					System.out.println("sw $t" + $4.register + ", " + varCalled.position + "($sp)");
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
		System.out.println("@@ REGISTER: " + $3.register);
		
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
			
		/*	// Allocate the frame necessary for the calling function
			out.write("addi $sp, $sp, -104\t# Allocates a new frame for the caller\n");
			System.out.println("addi $sp, $sp, -104\t# Allocates a new frame for the caller");
		*/
			
			
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
			if ($1.name.equals("main")) {
				out.write("jal " + $1.name + "\t\t# Jump to the main function\n");
				System.out.println("jal " + $1.name + "\t\t# Jump to the main function");
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
				freeArgReg(i);
			}
			
			for(int i = 0, j = 8; i < 8; i++, j = j+4){
				out.write("lw $t" + i + ", " + j + "($sp)\n");
				System.out.println("lw $t" + i + ", " + j + "($sp)");
				freeReg(i);
			}	
			
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
	
		/*	// Allocate the frame necessary for the calling function
			out.write("addi $sp, $sp, -104\t# Allocates a new frame for the caller\n");
			System.out.println("addi $sp, $sp, -104\t# Allocates a new frame for the caller");
		*/				
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
			
			for(int i = 0, j = 8; i < 8; i++, j = j+4){
				out.write("lw $t" + i + ", " + j + "($sp)\n");
				System.out.println("lw $t" + i + ", " + j + "($sp)");
				freeReg(i);
			}
			
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
		try {
			
			out.write("j while_" + randomConditionalID + "\t\t# Jump back to the while condition\n");
			System.out.println("j while_" + randomConditionalID + "\t\t# Jump back to the while condition");
			
			out.write("skip_while_" + randomConditionalID + ":\t# End of the while loop\n");
			System.out.println("skip_while_" + randomConditionalID + ":\t# End of the while loop");

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
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
		try {

			out.write("end_if_" + randomConditionalID + ":\t\t# End of the if statement\n");
			System.out.println("end_if_" + randomConditionalID + ":\t\t# End of the if statement");

		} catch ( IOException e) { 
			e.printStackTrace();
		}
	} 
	|	if_first %prec SHIFT_ELSE
	{
		{
			try {

				out.write("skip_if_" + randomConditionalID + ":\n");
				System.out.println("skip_if_" + randomConditionalID + ":");
				
				out.write("end_if_" + randomConditionalID + ":\t\t# End of the if statement\n");
				System.out.println("end_if_" + randomConditionalID + ":\t\t# End of the if statement");
				

			} catch ( IOException e) { 
				e.printStackTrace();
			}

		}
	}
	|	RETURN '(' ')' ';' 
	|	RETURN '(' expression ')' ';' 
	{
		//System.out.println("@@ RETURN: " + $3.register + " " + $3.name);
		try {

			out.write("move $v0, $t" + $3.register + "\t\t# Move the return value to the return register\n");
			System.out.println("move $v0, $t" + $3.register + "\t\t# Move the return value to the return register");

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
	}
	;
if_first: IF '(' expression ')' 
	{
		{
			// Grabs a random ID of 5 characters.  The ID's are originally too long for this situation
			randomConditionalID = UUID.randomUUID().toString().substring(0,5);

			try {

				out.write("\nbeq $t" + $3.register + ", $zero, skip_if_" + randomConditionalID + "\t# Start of an if statement\n");
				System.out.println("\nbeq $t" + $3.register + ", $zero, skip_if_" + randomConditionalID + "\t# Start of an if statement");

			} catch ( IOException e) { 
				e.printStackTrace();
			}
		}
	} statement
	{
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
		
		// Looks up the variable's object
		varCalled = lookup($1,1);
		// Gathers a fre register number
		regNumber = getReg();
		
		try {

			if(local){
				out.write("lw $t" + regNumber + ", " + varCalled.position + "($sp)\n");
				System.out.println("lw $t" + regNumber + ", " + varCalled.position + "($sp)");
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
		// Gathers a fre register number
		regNumber = getReg();
		
		try {

			out.write("la $t" + regNumber + ", " + "global_" + $1.name+ "\n");
			System.out.println("la $t" + regNumber + ", " + "global_" + $1.name);
			
			out.write("mul $t" + $3.register + ", $t" + $3.register + ", 4\n");
			System.out.println("mul $t" + $3.register + ", $t" + $3.register +  ", 4");
			
			out.write("add $t" + regNumber + ", $t" + regNumber + ", $t" + $3.register + "\n");
			System.out.println("add $t" + regNumber + ", $t" + regNumber +  ", $t" + $3.register);
			
			// Gathers a fre register number
			typeRegNumber = getReg();
			
			out.write("lw $t" + typeRegNumber + ", 0($t" + regNumber + ")\n");
			System.out.println("lw $t" + typeRegNumber + ", 0($t" + regNumber +  ")");
			
			freeReg($3.register);
			freeReg(regNumber);

		} catch ( IOException e) { 
			e.printStackTrace();
		}
		
		$$.register = typeRegNumber;
		$$.typeRegister = regNumber;
		$$.type = "type";
	}
	|	ID '.' ID {$$.type = "type";}
	;

expression_list:	expression_list ',' expression
	{
		if(function){
			//System.out.println("@@ FUNCTION ARG: " + $3.name + " " + $3.register);
			
			try {
				regNumber = getArgReg();
				
				// Step 2 of the Stack Discipline - Move actual parameters to the $a registers
				out.write("move $a" + regNumber + ", $t" + $3.register + "\t\t# Loads arguments for the callee function\n");
				System.out.println("move $a" + regNumber + ", $t" + $3.register + "\t\t# Loads arguments for the callee function");

			} catch ( IOException e) { 
				e.printStackTrace();
			}
			
		}
	}
	|	expression
	{
		if(function){
			//System.out.println("@@ FUNCTION ARG: " + $1.name + " " + $1.register);
			
			try {
				regNumber = getArgReg();
				
				// Step 2 of the Stack Discipline - Move actual parameters to the $a registers
				out.write("move $a" + regNumber + ", $t" + $1.register + "\t\t# Loads arguments for the callee function\n");
				System.out.println("move $a" + regNumber + ", $t" + $1.register + "\t\t# Loads arguments for the callee function");

			} catch ( IOException e) { 
				e.printStackTrace();
			}
			
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

			out.write("beq $zero, $t" + $2.register + " false_branch_" + randomID + "\n");	
			System.out.println("beq $zero, $t" + $2.register + " false_branch_" + randomID);
			
			out.write("move $t" + $2.register + ", $zero\t# Make it false if it was true\n");
			System.out.println("move $t" + $2.register + ", $zero\t# Make it false if it was true");
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
		
		$$.register = regNumber;
		
	}
	| exp LESS_EQUAL exp 
	{
		// Gather a register number for the return variable to go in.
		regNumber = getReg();
		
		// Grabs a random ID of 5 characters.  The ID's are originally too long for this situation
		randomID = UUID.randomUUID().toString().substring(0,5);
		
		try {

			// If they really are not equal - branch
			out.write("ble $t" + $1.register + ", $t" + $3.register + ", less_equal_" + randomID + "\n");
			System.out.println("ble $t" + $1.register + ", $t" + $3.register + ", less_equal_" + randomID);
			
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
		// Gather a register number for the return variable to go in.
		regNumber = getReg();
		
		// Grabs a random ID of 5 characters.  The ID's are originally too long for this situation
		randomID = UUID.randomUUID().toString().substring(0,5);
		
		try {

			// If they really are not equal - branch
			out.write("ble $t" + $3.register + ", $t" + $1.register + ", less_equal_" + randomID + "\n");
			System.out.println("ble $t" + $3.register + ", $t" + $1.register + ", less_equal_" + randomID);
			
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

		freeReg($3.register);
		freeReg($1.register);
		$$.register = regNumber;
	}
	| exp NOT_EQUAL exp
	{
		// Gather a register number for the return variable to go in.
		regNumber = getReg();
		
		// Grabs a random ID of 5 characters.  The ID's are originally too long for this situation
		randomID = UUID.randomUUID().toString().substring(0,5);
		
		try {

			// If they really are not equal - branch
			out.write("bne $t" + $1.register + ", $t" + $3.register + ", not_equal_" + randomID + "\n");
			System.out.println("bne $t" + $1.register + ", $t" + $3.register + ", not_equal_" + randomID);
			
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
		// Gather a register number for the return variable to go in.
		regNumber = getReg();
		
		// Grabs a random ID of 5 characters.  The ID's are originally too long for this situation
		randomID = UUID.randomUUID().toString().substring(0,5);
		
		try {

			// If they really are not equal - branch
			out.write("bne $t" + $1.register + ", $t" + $3.register + ", not_equal_" + randomID + "\n");
			System.out.println("bne $t" + $1.register + ", $t" + $3.register + ", not_equal_" + randomID);
			
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
			
		/*	// Allocate the frame necessary for the calling function
			out.write("addi $sp, $sp, -104\t# Allocates a new frame for the caller\n");
			System.out.println("addi $sp, $sp, -104\t# Allocates a new frame for the caller");
		*/
			
			
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
			if ($1.name.equals("main")) {
				out.write("jal " + $1.name + "\t\t# Jump to the main function\n");
				System.out.println("jal " + $1.name + "\t\t# Jump to the main function");
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
	
		/*	// Allocate the frame necessary for the calling function
			out.write("addi $sp, $sp, -104\t# Allocates a new frame for the caller\n");
			System.out.println("addi $sp, $sp, -104\t# Allocates a new frame for the caller");
		*/				
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
			
			// Moves the input to the first free register.  I do not see a need for using labels here - it
			//	seems better to place this in a register instead of saving in memory.
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
		regNumber = getReg();
		try {

			out.write("li $t" + regNumber +", " + $1.name + "\n");	
			System.out.println("li $t" + regNumber +", " + $1.name);
			$$.register = regNumber;
		} catch ( IOException e) { 
			e.printStackTrace();
		}
	}
	|	TRUE
	{
		regNumber = getReg();
		try {

			out.write("li $t" + regNumber +", 1\t\t# 1 = true\n");	
			System.out.println("li $t" + regNumber +", 1\t\t# 1 = true");
			$$.register = regNumber;
		} catch ( IOException e) { 
			e.printStackTrace();
		}
	}
	|	FALSE	
	{
		regNumber = getReg();
		try {

			out.write("li $t" + regNumber +", 0\t\t# 0 = false\n");	
			System.out.println("li $t" + regNumber +", 0\t\t# 0 = false");
			$$.register = regNumber;
		} catch ( IOException e) { 
			e.printStackTrace();
		}
	}
	;
	
	
%%
	// LinkedList symbolTable - used to provide all the operations of a stack
	// 		with the added benefit of an easy search mechanism.  This holds 
	//		the current state of the Symbol Table tree.
	private LinkedList<LinkedList> symbolTable = new LinkedList<LinkedList>();
	
	// LinkedList scope - a LinkedList structure is used to hold the state of
	// 		the local(current) scope
	private LinkedList<Semantic> scope, global;
	
	// lexer - an instance of the lexical scanner
	private Lexer lexer;
	
	// registers - an array holding an abstract view of the temporary variables of the system.
	// argRegisters - an array holding the argument registers
	private int[] registers = new int[8];
	private int[] argRegisters = new int[4];
	
	// regNumber - number received from getReg()
	private int regNumber, typeRegNumber;
	private int stackVars = 56;
		
	// local - a boolean denoting if we are in local or global scope.
	// function - a boolean denoting if expression needs to keep track of formal parameters of procedures
	// main - are we inside the main function?
	// type - are we dealing with a type (array or record)?
	private boolean local, function, main, type= false;
	
	BufferedWriter out;
	
	// currentFunct - Holds the current function.  This is used for returns
	// functionCalled - Holds the function that was just looked up
	// structCalled - holds the struct that was looked up
	// arrayCalled - holds the array that was just looked up
	// varCalled - holds the variable that was just looked up
	// typeCalled - holds the type (array or struct) that was looked up
	private Semantic currentFunct, functionCalled, structCalled, arrayCalled, varCalled, typeCalled;

	// randomID - a random identifier used for labeling in expressions.
	// randomConditionalID - a random identifier used for labeling in conditionals
	String randomID, randomConditionalID;
	
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
	 * freeReg
	 */
	public void freeReg(int registerNumber) {
		registers[registerNumber] = 0;
	}
	
	/**
	 * getArgReg
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
	 * freeArgReg
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
		//private int argRegister; 		// Argument register where the value is being held (on function call)
		private int position;			// Position on the stack
		//private boolean param = false;	// Is the identifier a parameter in some function?
		private int typeSize;			// Size of the type being declared.
		// parameters - List which holds the parameters of a function
		public LinkedList<String> variables = new LinkedList<String>();
		
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
