/* lexical grammar */
%lex
%%
\;[^\n\r]*              { /* console.log("COMMENT: "+yytext) */ }
(0x[0-9A-Fa-f][0-9A-Fa-f_]*)|([0-9][0-9_]*)          { yytext = Number(yytext.replace(/\_/g, "")); return 'NUMBER'; }
\$\$\{[^\}]*\}          { yytext = yytext.slice(3, -1); return "COMMAND"; }
(\$(\{[^\}]*\})?)       { yytext = yytext.length == 1 ? "" : yytext.slice(2, -1); return 'TAG'; }
[\r\n]+                 { return "LF";}
[ \t]+                  { /* console.log("Empty spaces"); */ }
HASH_LEFT               { return 'HASH_LEFT'; }
HASH_RIGHT              { return 'HASH_RIGHT'; }
OLD_ROOT                { return 'OLD_ROOT'; }
NEW_ROOT                { return 'NEW_ROOT'; }
VALUE_LOW               { return 'VALUE_LOW'; }
VALUE_HIGH              { return 'VALUE_HIGH'; }
SIBLING_VALUE_HASH      { return 'SIBLING_VALUE_HASH'; }
FREE                    { return 'FREE'; }
RKEY                    { return 'RKEY'; }
SIBLING_RKEY            { return 'SIBLING_RKEY'; }
RKEY_BIT                { return 'RKEY_BIT'; }
LEVEL                   { return 'LEVEL'; }
PC                      { return 'PC'; }
HASH0                   { return 'HASH0' }
HASH1                   { return 'HASH1' }
LATCH_SET               { return 'LATCH_SET' }
LATCH_GET               { return 'LATCH_GET' }
CLIMB_RKEY              { return 'CLIMB_RKEY' }
CLIMB_SIBLING_RKEY      { return 'CLIMB_SIBLING_RKEY' }
CLIMB_SIBLING_RKEY_N    { return 'CLIMB_SIBLING_RKEY_N' }
JMPZ                    { return 'JMPZ' }
JMP                     { return 'JMP' }
ROTATE_LEVEL            { return 'ROTATE_LEVEL' }
ROTL_VH                 { return 'ROTL_VH' }
INCLUDE                 { return 'INCLUDE' }
\"[^"]+\"               { yytext = yytext.slice(1,-1); return 'STRING'; }
[a-zA-Z_][a-zA-Z$_0-9\+\.\>\<\=\-\!]*  { return 'IDENTIFIER'; }
\:                      { return ':'; }
\,                      { return ','}
\(                      { return '('}
\)                      { return ')'}
\+\+                    { return '++'}
\-\-                    { return '--'}
\+                      { return '+'}
\-                      { return '-'}
\*\*                    { return '**'}
\*                      { return '*'}
\=\>                    { return '=>' }
<<EOF>>                 { return 'EOF'; }
.                       { /* console.log("INVALID: " + yytext); */ return 'INVALID'; }

/lex

%{
function setLine(dst, first) {
    dst.line = first.first_line;
}
%}

%start allStatments

%% /* language grammar */

allStatments
    : statmentList EOF
        {
            // console.log($1);
            $$ = $1;
            return $$;
        }
    ;

statmentList
    : statmentList statment
        {
            if ($2) $1.push($2);
            $$ = $1;
        }
    | statment
        {
            if ($1) {
                $$ = [$1];
            } else {
                $$=[];
            }
        }
    ;

statment
    : step
        {
            $$ = $1;
        }
    | label
        {
            $$ = $1;
        }
    | include
        {
            $$ = $1;
        }
    | command
        {
            $$ = $1;
        }
    | LF
        {
            $$ = null;
        }
    ;

step
    : assignment ':' opList LF
        {
            $$ = {type: "step", assignment: $1, ops: $3};
            setLine($$, @1)
        }
    | assignment LF
        {
            $$ = {type: "step", assignment: $1, ops: []};
            setLine($$, @1)
        }
    | ':' opList  LF
        {
            $$ = {type: "step", assignment: null, ops: $2}
            setLine($$, @1)
        }
    ;

label
    : IDENTIFIER ':'
        {
            $$ = {type: "label", identifier: $1};
            setLine($$, @1)
        }
    ;

command
    : COMMAND
        {
            $$ = {type: "command", cmd: $1}
        }
    ;


include
    : INCLUDE STRING
        {
            $$ = {type: "include", file: $2}
        }
    ;




assignment
    : inRegsSum '=>' regsList
        {
            $$ = {in: $1, out: $3}
        }
    | inRegsSum
        {
            $$ = {in: $1, out: []}
        }
    ;

inRegsSum
    : inRegsSum '+' inRegP
        {
            $$ = {type: 'add', values: [$1, $3]}
        }
    | inRegsSum '-' inRegP
        {
            $$ = {type: 'sub', values: [$1, $3]}
        }
    | '-' inRegP
        {
            $$ = {type: 'neg', values: [$2]}
        }
    | inRegP
        {
            $$ = $1
        }
    ;

inRegP
    : inRegP '*' inReg
        {
            $$ = {type: 'mul', values: [$1, $3]}
        }
    | inReg
        {
            $$ = $1
        }
    ;

inReg
    : TAG
        {
            $$ = {type: 'TAG' , tag: $1}
        }
    | reg
        {
            $$ = {type: 'REG' , reg: $1}
        }

    | NUMBER '**' NUMBER
        {
            $$ = {type: "exp", values: [$1, $3]}
        }
    | NUMBER
        {
            $$ = {type: 'CONST' , const: $1}
        }
    ;

regsList
    : regsList ',' reg
        {
            $1.push($3)
        }
    | reg
        {
            $$ = [$1]
        }
    ;

opList
    : opList ',' op
        {
            $1.push($3);
            $$ = $1
        }
    | op
        {
            $$ = [$1]
        }
    ;

op
    : JMP '(' IDENTIFIER ')'
        {
            $$ = {iJmp: 1n, addressLabel: $3}
        }
    | JMPZ '(' IDENTIFIER ')'
        {
            $$ = {iJmpz: 1n, addressLabel: $3}
        }
    | HASH0
        {
            $$ = {iHash: 1n, iHashType: 0}
        }
    | HASH1
        {
            $$ = {iHash: 1n, iHashType: 1}
        }
    | LATCH_SET
        {
            $$ = {iLatchSet: 1n}
        }
    | LATCH_GET
        {
            $$ = {iLatchGet: 1n}
        }
    | CLIMB_RKEY
        {
            $$ = {iClimbRkey: 1n}
        }
    | CLIMB_SIBLING_RKEY
        {
            $$ = { iClimbSiblingRkey: 1n}
        }
    | CLIMB_SIBLING_RKEY_N
        {
            $$ = { iClimbSiblingRkeyN: 1n}
        }
    | ROTATE_LEVEL
        {
            $$ = { iRotateLevel: 1n}
        }
    ;


reg
    : HASH_LEFT
    | HASH_RIGHT
    | OLD_ROOT
    | NEW_ROOT
    | VALUE_LOW
    | VALUE_HIGH
    | SIBLING_VALUE_HASH
    | RKEY
    | SIBLING_RKEY
    | RKEY_BIT
    | LEVEL
    | PC
    | ROTL_VH
    ;

