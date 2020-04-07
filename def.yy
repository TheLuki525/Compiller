%{
#define INFILE_ERROR 1
#define OUTFILE_ERROR 2

#include <string>
#include <stack>
#include <map>
#include <vector>
#include <fstream>

struct Symbol
{
	std::string type, sVal, vName;
	int iVal;
	float fVal;
	Symbol(const char* val)
	:type("STRING")
	{
		sVal = val;
	}
	Symbol(int val)
	:type("INT")
	{
		iVal = val;
	}
	Symbol(float val)
	:type("FLOAT")
	{
		fVal = val;
	}
	Symbol(std::string name)
	:type("VARIABLE")
	{
		vName = name;
	}
	Symbol(){}
};
 
extern "C" int yylex();
extern "C" int yyerror(const char *msg, ...);

void createFloat(std::string id);
void createInt(std::string id);
void createString(std::string id);
void createIntArray(std::string name, int lenght);
void createFloatArray(std::string name, int lenght);
void modifyArray(std::string name, int index);
void modifyVariable(std::string variableName);
void triples(std::string text);
void read(std::string variableName);
void printText(bool newLine);
void printVariable();
void beginIf();
void elseIf();
void endIF();
void beginWhile();
void endWhile();

std::map<std::string, Symbol> symbolsMap;
std::stack<std::string> operators;
std::stack<Symbol> symbolsStack;
std::stack<std::string> labels;
std::vector<std::string> code;
std::string stringData;

int counter = 1;
%}
%union
{
	char* text;
	int ival;
	float fval;
};
%token <text> ID
%token <ival> LC
%token <fval> LR
%token INT FLOAT STRING IF WHILE KOM PR RD EQ NEQ LEQ GEQ ELSE PRN
%%
multiline
	:multiline line	{}
	|line		{}
	;
line
	:expr ';'			{}
	|function ';'		{}
	|if_expr			{}
	|if_else_expr_end	{}
	|while_expr			{}
	|arr_expr ';'		{}
	;
arr_expr
	:INT ID '[' LC ']'		{createIntArray($2, $4);}
	|FLOAT ID '[' LC ']'	{createFloatArray($2, $4);}
	|ID '[' LC ']' '=' exp	{modifyArray($1, $3);}
	;
if_else_expr_end
	:if_else_exp '{' multiline '}'	{endIF();}
	;
if_expr
	:if_pocz '{' multiline '}'	{endIF();}
	;
if_else_exp
	:if_pocz '{' multiline '}' ELSE	{elseIf();}
	;
if_pocz
	:IF '(' exp oper exp ')'	{beginIf();}
	;
while_expr
	:while_pocz '{' multiline '}' {endWhile();}  
	;
while_pocz
	:WHILE '(' exp oper exp ')'	{beginWhile();}  
	;
function
	:PR expInBrackets	{printVariable();}
	|PRN expInBrackets	{printVariable();}
	|PRN '(' str ')'	{printText(true);}
	|PR '(' str ')'		{printText(false);}
	|RD '(' ID ')'		{read($3);}
	;
str
	:'"' word '"'			{symbolsStack.push(("\"" + stringData + " \"").c_str()); stringData.clear();}
	|'"' /* empty */ '"'	{symbolsStack.push(("\"" + stringData + " \"").c_str()); stringData.clear();} 
	;
word
	:ID			{stringData += $1;}
	|word ID	{stringData += std::string(" ") + $2;}
	;
expr
	:INT ID '=' exp		{createInt($2);}
	|FLOAT ID '=' exp	{createFloat($2);}
	|STRING ID '=' str	{createString($2);}
	|ID '=' exp			{modifyVariable($1);}
	;
exp
	:component '+' exp	{triples("add");}
	|component '-' exp	{triples("sub");}
	|component			{} 
	;
component
	:component '*' factor	{triples("mul");}
	|component '/' factor	{triples("div");}
	|factor				{}
	;
oper
	:EQ		{operators.push("bne");}
	|NEQ	{operators.push("beq");}
	|GEQ	{operators.push("blt");}
	|LEQ	{operators.push("bgt");}
	|'>'	{operators.push("ble");}
	|'<'	{operators.push("bge");}
	;
factor
	:ID				{symbolsStack.push(Symbol(std::string($1)));}
	|LC				{symbolsStack.push(Symbol($1));}
	|LR				{symbolsStack.push(Symbol($1));}
	|expInBrackets	{}
	|ID '[' LC ']'	{symbolsStack.push(Symbol($1 + std::string("_") + std::to_string($3)));}
	;
expInBrackets
	:'(' exp ')'	{}
	;
%%

void createInt(std::string id)
{
	if(symbolsStack.top().type == "INT")
	{
		symbolsMap[id] = Symbol(symbolsStack.top().iVal);
		symbolsStack.pop();
	}
	else if(symbolsStack.top().type == "VARIABLE")
	{
		symbolsMap[id] = Symbol(0);
		modifyVariable(id);
	}
}

void createFloat(std::string id)
{
	if(symbolsStack.top().type == "FLOAT")
	{
		symbolsMap[id] = Symbol(symbolsStack.top().fVal);
		symbolsStack.pop();
	}
	else if(symbolsStack.top().type == "VARIABLE")
	{
		symbolsMap[id] = Symbol(0.0f);
		modifyVariable(id);
	}
}

void createString(std::string id)
{
	if(symbolsStack.top().type == "STRING")
	{
		symbolsMap[id] = Symbol(symbolsStack.top().sVal.c_str());
		symbolsStack.pop();
	}
}

void createIntArray(std::string name, int lenght)
{
	for(int i = 0; i < lenght; i++)
		symbolsMap[name + "_" + std::to_string(i)] = Symbol(0);
}

void createFloatArray(std::string name, int lenght)
{
	for(int i = 0; i < lenght; i++)
		symbolsMap[name + "_" + std::to_string(i)] = Symbol(0.0f);
}

void modifyArray(std::string name, int index)
{
	modifyVariable(name + "_" + std::to_string(index));
}

void modifyVariable(std::string variableName)
{
	Symbol sec = symbolsStack.top();
	symbolsStack.pop();
	Symbol first = symbolsMap[variableName];
	std::string first_variable_type, sec_variable_type;
	if(sec.type != "VARIABLE" && symbolsMap[variableName].type != sec.type)
		yyerror(("error: " + symbolsMap[first.vName].type + " - " + sec.type + " type mismatch\n").c_str());
	if(sec.type == "VARIABLE" && symbolsMap[variableName].type != symbolsMap[sec.vName].type)
		yyerror(("error: " + symbolsMap[first.vName].type + " - " + symbolsMap[sec.vName].type + " type mismatch\n").c_str());
	first_variable_type = symbolsMap[variableName].type;
	if(sec.type == "VARIABLE")
		sec_variable_type = symbolsMap[sec.vName].type;
	if(sec.type == "INT")
		code.push_back("# " + variableName + " = " + std::to_string(sec.iVal));
	else if(sec.type == "FLOAT")
		code.push_back("# " + variableName + " = " + std::to_string(sec.fVal));
	else if(sec.type == "VARIABLE")
		code.push_back("# " + variableName + " = " + sec.vName);
	else if(sec.type == "STRING")
		code.push_back("# " + variableName + " = " + sec.sVal);
	if(first_variable_type == "INT")
	{
		if(sec.type == "VARIABLE")
			code.push_back("lw $t0, " + sec.vName);
		else
			code.push_back("li $t0, " + std::to_string(sec.iVal));
		code.push_back("sw $t0, " + variableName);
	}
	else if(first_variable_type == "FLOAT")
	{
		if(sec.type == "VARIABLE")
			code.push_back("l.s $f0, " + sec.vName);
		else
		{
			std::string sec_tmp = "ftmp" + std::to_string(counter++);
			symbolsMap[sec_tmp] = Symbol(sec.fVal);
			code.push_back("l.s $f0, " + sec_tmp);
		}
		code.push_back("s.s $f0, " + variableName);
	}
	else if(first_variable_type == "STRING")
	{
		if(sec.type == "VARIABLE")
			code.push_back("la $a0, " + sec.sVal);
		else
		{
			std::string sec_tmp = "strtmp" + std::to_string(counter++);
			symbolsMap[sec_tmp] = Symbol(sec.sVal);
			code.push_back("la $a0, " + sec_tmp);
		}
		code.push_back("sa $a0, " + variableName);
	}
}

void triples(std::string text)
{
	Symbol sec = symbolsStack.top();
	symbolsStack.pop();
	Symbol first = symbolsStack.top();
	symbolsStack.pop();
	std::string first_variable_type, sec_variable_type;
	if(first.type != "VARIABLE" && sec.type != "VARIABLE" && first.type != sec.type)
		yyerror(("error: " + first.type + " - " + sec.type + " type mismatch\n").c_str());
	if(first.type == "VARIABLE" && sec.type != "VARIABLE" && symbolsMap[first.vName].type != sec.type)
		yyerror(("error: " + symbolsMap[first.vName].type + " - " + sec.type + " type mismatch\n").c_str());
	if(first.type != "VARIABLE" && sec.type == "VARIABLE" && symbolsMap[sec.vName].type != first.type)
		yyerror(("error: " + first.type + " - " + symbolsMap[sec.vName].type + " type mismatch\n").c_str());
	if(first.type == "VARIABLE" && sec.type == "VARIABLE" && symbolsMap[first.vName].type != symbolsMap[sec.vName].type)
		yyerror(("error: " + symbolsMap[first.vName].type + " - " + symbolsMap[sec.vName].type + " type mismatch\n").c_str());
	if(first.type == "VARIABLE")
		first_variable_type = symbolsMap[first.vName].type;
	if(sec.type == "VARIABLE")
		sec_variable_type = symbolsMap[sec.vName].type;
	if(first.type == "INT" || first_variable_type == "INT")
	{
		if(first.type == "VARIABLE")
			code.push_back("lw $t0, " + first.vName);
		else
			code.push_back("li $t0, " + std::to_string(first.iVal));
		if(sec.type == "VARIABLE")
			code.push_back("lw $t1, " + sec.vName);
		else
			code.push_back("li $t1, " + std::to_string(sec.iVal));
		symbolsMap["result" + std::to_string(counter)] = Symbol(0);
		code.push_back(text + " $t0, $t0, $t1");
		code.push_back("sw $t0, result" + std::to_string(counter));
		symbolsStack.push(Symbol("result" + std::to_string(counter++)));
	}
	else if(first.type == "FLOAT" || first_variable_type == "FLOAT")
	{
		std::string first_tmp, sec_tmp, fresult = "fresult" + std::to_string(counter++);
		if(first.type != "VARIABLE")
		{
			first_tmp = "ftmp" + std::to_string(counter++);
			symbolsMap[first_tmp] = Symbol(first.fVal);
		}
		if(sec.type != "VARIABLE")
		{
			sec_tmp = "ftmp" + std::to_string(counter++);
			symbolsMap[sec_tmp] = Symbol(sec.fVal);
		}
		if(first.type == "VARIABLE")
			code.push_back("l.s $f0, " + first.vName);
		else
			code.push_back("l.s $f0, " + first_tmp);
		if(sec.type == "VARIABLE")
			code.push_back("l.s $f1, " + sec.vName);
		else
			code.push_back("l.s $f1, " + sec_tmp);
		symbolsMap[fresult] = Symbol(0.0f);
		code.push_back(text + ".s $f0, $f0, $f1");
		code.push_back("s.s $f0, " + fresult);
		symbolsStack.push(Symbol(fresult));
	}
}

void beginIf()
{
	code.push_back("# IF");
	if(symbolsStack.top().type == "INT")
		code.push_back("li $t1, " + std::to_string(symbolsStack.top().iVal));
	else if(symbolsStack.top().type == "VARIABLE")
		code.push_back("lw $t1, " + symbolsStack.top().vName);  
	symbolsStack.pop();
	if(symbolsStack.top().type == "INT")
		code.push_back("li $t0, " + std::to_string(symbolsStack.top().iVal));
	else if(symbolsStack.top().type == "VARIABLE")
		code.push_back("lw $t0, " + symbolsStack.top().vName);  
	symbolsStack.pop();
	code.push_back(operators.top() + " $t0, $t1, label" + std::to_string(counter));
	operators.pop();
	labels.push("label" + std::to_string(counter++));
}

void elseIf()
{
	code.push_back("b label" + std::to_string(counter));
	code.push_back(labels.top() + ":");
	labels.pop();
	labels.push("label" + std::to_string(counter++));
}

void endIF()
{
	code.push_back(labels.top() + ":");
	labels.pop();
	code.push_back("##");
}

void beginWhile()
{
	code.push_back("# WHILE");
	code.push_back("label" + std::to_string(counter) + ":");
	labels.push("label" + std::to_string(counter++));
	if(symbolsStack.top().type == "INT")
		code.push_back("li $t1, " + std::to_string(symbolsStack.top().iVal));
	else if(symbolsStack.top().type == "VARIABLE")
		code.push_back("lw $t1, " + symbolsStack.top().vName);
	symbolsStack.pop();
	if(symbolsStack.top().type == "INT")
		code.push_back("li $t0, " + std::to_string(symbolsStack.top().iVal));
	else if(symbolsStack.top().type == "VARIABLE")
		code.push_back("lw $t0, " + symbolsStack.top().vName);
	symbolsStack.pop();
	code.push_back(operators.top() + " $t0, $t1, label" + std::to_string(counter));
	labels.push("label" + std::to_string(counter++));
	operators.pop();
}

void endWhile()
{
	std::string while_end = labels.top();
	labels.pop();
	code.push_back("b " + labels.top());
	labels.pop();
	code.push_back(while_end + ":");
	code.push_back("##");
}

void printText(bool newLine)
{
	std::string str_name = "str" + std::to_string(counter++), str_txt = symbolsStack.top().sVal;
	if(newLine)
	{
		str_txt[str_txt.length()-1] = '\\';
		str_txt += "n\"";
	}
	symbolsMap[str_name] = Symbol(str_txt.c_str());
	symbolsStack.pop();
	code.push_back("li $v0, 4");
	code.push_back("la $a0, " + str_name);
	code.push_back("syscall");
}

void printVariable()
{
	if(symbolsStack.top().type == "INT")
	{
		code.push_back("# PRINT int: " + std::to_string(symbolsStack.top().iVal));
		code.push_back("li $v0, 1");
		code.push_back("li $a0, " + std::to_string(symbolsStack.top().iVal));
	}
	else if(symbolsStack.top().type == "FLOAT")
	{
		code.push_back("# PRINT float: " + std::to_string(symbolsStack.top().fVal));
		symbolsMap["ftmp" + std::to_string(counter)] = Symbol(symbolsStack.top().fVal);
		code.push_back("li $v0, 2");
		code.push_back("l.s $f12, ftmp" + std::to_string(counter++));
	}
	else if(symbolsStack.top().type == "STRING")
	{
		code.push_back("# PRINT string: " + symbolsStack.top().sVal);
		symbolsMap["stmp" + std::to_string(counter)] = Symbol(symbolsStack.top().sVal.c_str());
		code.push_back("li $v0, 4");
		code.push_back("la $a0, stmp" + std::to_string(counter++));
	}
	else if(symbolsStack.top().type == "VARIABLE")
	{
		if(symbolsMap[symbolsStack.top().vName].type == "INT")
		{
			code.push_back("# PRINT int: " + symbolsStack.top().vName);
			code.push_back("li $v0, 1");
			code.push_back("lw $a0, " + symbolsStack.top().vName);
		}
		else if(symbolsMap[symbolsStack.top().vName].type == "FLOAT")
		{
			code.push_back("li $v0, 2");
			code.push_back("l.s $f12, " + symbolsStack.top().vName);
		}
		else if(symbolsMap[symbolsStack.top().vName].type == "STRING")
		{
			code.push_back("li $v0, 4");
			code.push_back("la $a0, " + symbolsStack.top().vName);
		}
		else
			yyerror("error: printing variable of other type then int, float or string\n");
	}
	code.push_back("syscall");
	symbolsStack.pop();
}

void read(std::string variableName)
{
	if(symbolsMap[variableName].type == "INT")
	{
		code.push_back("li $v0, 5");
		code.push_back("syscall");
		code.push_back("sw $v0, " + variableName);
	}
	else if(symbolsMap[variableName].type == "FLOAT")
	{
		code.push_back("li $v0, 6");
		code.push_back("syscall");
		code.push_back("s.s $f0, " + variableName);
	}
}

void symbolsToFile()
{
	std::fstream outfile;
	outfile.open("code.asm", std::ios_base::app);
	outfile << ".data" << std::endl;
	for(std::map<std::string, Symbol>::iterator it = symbolsMap.begin(); it != symbolsMap.end(); it++)
	{
		if(it->second.type == "INT")
			outfile << it->first << ": .word " << it->second.iVal << std::endl;
		else if(it->second.type == "FLOAT")
			outfile << it->first << ": .float " << it->second.fVal << std::endl;
		else if(it->second.type == "STRING")
			outfile << it->first << ": .asciiz " << it->second.sVal << std::endl;
	}
	outfile << ".text" << std::endl;
	for(std::string line : code)
		outfile << line << std::endl;
	outfile.close();
}

int main(int argc, char *argv[])
{
	yyparse();
	symbolsToFile();
	return 0;
}
