'From Smalltalk 5.5k XM November 24 on 22 November 1980 at 2:57:08 am.'

"Decompiler" 
Class new title: 'Decompiler'
	subclassof: Object
	fields: 'method temps instvars literals stack isReference literalNames'
	declare: 'breakPC highlight ';
	sharing: ByteCodes;
	asFollows 

This class has not yet been commented

Initialization 
decompile: sel class: class | strm block ignore p
	[method ← class method: sel.
	method length<8⇒[⇑self quickCode: sel class: class]
	self initSymbols: class.
	stack ← (Vector new: (method◦3)-(method◦5)) asStream.
	block ← self block: method◦6+1 to: method length
		pc⦂ ignore hasValue⦂ ignore.
	stack empty≡false⇒[user notify: 'stack not empty']
	self convertMacros: block sel: sel.
	strm ← Stream default.
	self printPattern: sel on: strm.
	strm crtab: 1.
	block printon: strm indent: 1 precedence: 0 forValue: false decompiler: self.
	[(p←method word: 1)≠0⇒[strm append: ' primitive: '; print: p]].
	⇑strm contents asParagraph makeBoldPattern]
findPC: x [breakPC← x. highlight← 1 to: 1]
highlight [⇑highlight]
highlight: x [⇑highlight← x]

Symbols 
initSymbols: class | i lit env
	["Init temps with made-up names"
	temps ← Vector new: method◦5.
	for⦂ i to: temps length do⦂
		[temps◦i ← 't' + i asString].
	instvars ← class instvars.
	literals ← MessageDict new literalsIn: method.
	literalNames ← Vector new: literals length.
	env ← class wholeEnvironment, Smalltalk, Undeclared.
	for⦂ i to: literals length do⦂
		[lit ← literals◦i.
		literalNames◦i ←
			[lit is: UniqueString⇒[lit]
			lit is: ObjectReference⇒[self invertRef: lit environment: env]
			lit≡FieldReference⇒['']
			lit asString]]]
instvar: i
	[⇑instvars◦(i-codeLoadField+1)]
invertRef: ref environment: env | table n
	[for⦂ table from: env do⦂
		[n←table invertRef: ref⇒[⇑n]].
	⇑'unknown']
literal: i | index lit str
	[index ← i-codeLoadLit+1.
	lit ← literals◦index.  str ← literalNames◦index.
	lit is: ObjectReference⇒[⇑str]
	(lit is: UniqueString) or⦂ (lit is: Vector)⇒[⇑'↪' + str]
	⇑str]
literalIndirect: i
	[⇑literalNames◦(i-codeLoadLitInd+1)]
selector: i 
	[i>166 and⦂ i<208⇒[⇑SpecialOops◦(i-166)]
	⇑literalNames◦(i-codeSendLit+1)]
temp: i
	[⇑temps◦(i-codeLoadTemp+1)]

Byte Interpretation 
block: start to: end pc⦂ pc hasValue⦂ v
		| block code byte j stackPos t
	["Decompile the method from start to end into a ParsedBlock and return the
		instance of ParsedBlock.  Assign to pc the value of the pc after leaving
		the block.  If at run time this block will leave a value on the stack,
		set hasValue to true."
	block ← ParsedBlock default. pc value← end+1.
	stackPos ← stack position.
	code ← Stream new of: method from: start to: end.
	for⦂ byte from: code do⦂
		[byte<0200⇒[self loadByte: byte code: code]
		byte<0210⇒[self controlByte: byte code: code block: block]
		byte<0214⇒[self loadByte: byte code: code  "extended loads"]
		byte=0214⇒[self selectorByte: byte code: code at: code position  "extended selector"]
		byte<0260⇒
			[j←self jumpByte: byte code: code block: block.
			code end⇒[pc value←j]]
		self selectorByte: byte code: code at: code position]
	"If there is an additional item on the stack, it will be the value
		of this block"
	stack position>stackPos⇒
		[t←stack pop.  v value←true.
		block empty and⦂ (t is: ParsedBlock)⇒[⇑t]
		block next← t.
		⇑block]
	v value←false.
	[block empty⇒[block next← nil]].
	"pretend that returns jump to end of method"
	[block returns or⦂ (block◦block position) returns⇒
		[pc value← method length+1]].
	⇑block]
checkForRemoteCode: jump code: code block: block | m ignore t j b
"Check if this is a jump around remote code."
	[jump>code limit⇒[⇑false]
	"remote code should terminate with a toEnd, and then a jump back"
	method◦(jump-3)≠toEnd⇒[⇑false]
	t ← method◦(jump-2).
	t<0240 or⦂ t>0243⇒[⇑false]
	j ← t-0244*256+(method◦(jump-1)).
	jump+j ≠ (code position+1) ⇒[⇑false]
	m ← stack pop.
	((m isnt: ParsedMessage) or⦂ m rcvr≡toLoadThisCtxt≡false) or⦂
			(self selector: m op)≠↪remoteCopy⇒
		[stack next← m.  ⇑false]
	"it's a piece of remote code"
	b ← self block: code position+1 to: jump-4
		pc⦂ ignore hasValue⦂ ignore.
	stack next← ParsedRemote new expr: b.
	code position← jump-1]
conditionalJump: elseStart code: code block: block
		| cond ifExpr thenExpr elseExpr thenJump elseJump ignore newBlock
			hasValue last
	[ifExpr ← stack pop.
	thenExpr ← self block: code position+1 to: elseStart-1
		pc⦂ thenJump hasValue⦂ hasValue.
	"ensure jump is within block (in case thenExpr returns)"
	thenJump ← thenJump min: code limit+1.
	"if jump goes back, then it's a loop"
	thenJump<elseStart⇒
		[self loop: thenJump whileExpr: ifExpr doExpr: thenExpr
			code: code block: block doSize: elseStart-code position-1.
		code position← elseStart-1]
	elseExpr ← self block: elseStart to: thenJump-1
		pc⦂ elseJump hasValue⦂ ignore.
	"if elseJump is backwards, it is not part of the elseExpr"
	[elseJump<code position⇒
		[code position← thenJump-3.  last←true] 
	code position← thenJump-1].
	[thenJump+1=code limit  "still might be last"
			and⦂ (method◦thenJump≥0240 and⦂ method◦thenJump≤0247)⇒
		[last←true]].
	[thenJump=code limit
			and⦂ (method◦thenJump≥0220 and⦂ method◦thenJump≤0227)⇒
		[last←true]].
	"check for and⦂ or or⦂"
	hasValue and⦂ (thenExpr position=1 and⦂ thenExpr◦1≡toLoadTrue)⇒
		[stack next← ParsedDisjunct new left: ifExpr right:
				[elseExpr position=1⇒[elseExpr◦1] elseExpr] ]
	hasValue and⦂ (elseExpr position=1 and⦂ elseExpr◦1≡toLoadFalse)⇒
		[stack next← ParsedConjunct new left: ifExpr right:
				[thenExpr position=1⇒[thenExpr◦1] thenExpr] ]
	"it's an if statement"
	cond ← ParsedConditional new
			ifExpr: ifExpr thenExpr: thenExpr elseExpr: elseExpr.
	"If the then part has a value, put the conditional in a block, and put the
		block on the stack.  (If the compiler is working right the else part will
		leave a value, too ... this is not checked)."
	hasValue⇒
		[newBlock←ParsedBlock default.  newBlock next← cond.
		stack next← newBlock]
	"If the thenExpr jumps to the end of the current block,
		or to a jump backwards at the end of the current block,
		or to a ⇑self at the end of the method,
		append the cond
		to the current block.  Otherwise, embed it in a new block."
	(code end or⦂ last≡true) or⦂
	(thenJump+1=method length and⦂ method◦thenJump=toLoadSelf)⇒
		[block next← cond]
	newBlock←ParsedBlock default.  newBlock next← cond.
	block next← newBlock]
controlByte: byte code: code block: block | var t strm
	[byte=toSmashPop⇒
		[var ← self makeLoad: code next code: code.
		block next← ParsedAssignment new var: var expr: stack pop]
	byte=toSmash⇒
		["smash no pop at the end of a block will require the next byte
			to be fetched from after the limit of the block"
		code end⇒
			[strm ← Stream new of: method from: code limit+1 to: method length.
			var ← self makeLoad: strm next code: strm.
			block next← ParsedAssignment new var: var expr: stack pop]
		var ← self makeLoad: code next code: code.
		block next← ParsedAssignment new var: var expr: stack pop.
		"uncascade assignment statements"
		stack next← var]
	byte=toPop⇒
		[block next← stack pop]
	byte=toReturn⇒
		[t ← stack pop.
		stack empty≡false⇒[user notify: 'stack not empty']
		"elide final ⇑self"
		t≡toLoadSelf and⦂ code position=method length⇒[]
		block doesReturn.
		block next← t]
	byte=toEnd⇒
		[user notify: 'unexpected']
	byte=toLoadThisCtxt⇒
		[stack next← byte]
	byte=toSuper⇒
		[stack pop.  "delete ref to self"
		stack next← byte]
	user notify: 'unknown control byte']
jumpByte: byte code: code block: block | offset j
"If this is an unconditional jump, return the position in the method to which it jumps.  If this is a conditional jump forward, parse a conditional statement.  Conditional jumps backward are not produced by the current compiler."
	[byte<0230⇒["short unconditional jump forward"
		⇑byte-0220+code position+2]
	byte<0240⇒["short conditional jump forward"
		self conditionalJump: byte-0230+code position+2 code: code block: block.
		⇑code position+1]
	byte<0250⇒["long unconditional jump"
		offset ←  code next.
		j ← byte-0244*256+offset+code position+1.
		self checkForRemoteCode: j code: code block: block.
		⇑j]
	byte<0254⇒[code skip: 1.  "long conditional jump backward"
		user notify: 'conditional jump backward not expected']
	byte<0260⇒["long conditional jump forward"
		offset ← code next.
		self conditionalJump: byte-0254*256+offset+code position+1
			code: code block: block.
		⇑code position+1]
	user notify: 'not a jump byte']
loadByte: byte code: code | t lit
	[t ← self makeLoad: byte code: code.
	t≥codeLoadLit and⦂ t<codeLoadLitInd⇒
		[lit ← literals◦(t-codeLoadLit+1).
		lit≡FieldReference⇒
			[self remoteReference: code]
		lit is: ObjectReference⇒
			[stack next← ParsedObjectReference new var: t]
		stack next← t]
	stack next← t]
loop: jumpBack whileExpr: whileExpr doExpr: doExpr code: code block: block
doSize: doSize
		| n b ignore
	["jumpBack will jump to the beginning of whileExpr.  In the case of for statements or while's with a block in the condition, the whileExpr should include more than just the last expression.  Kludge: find all the statements needed by re-decompiling."
	n ← code position-doSize jmpSize.
	b ← self block: jumpBack to: n pc⦂ ignore hasValue⦂ ignore.
	"discard unwanted statements from block"
	block skip: 1-b position.
	block next← ParsedLoop new 
		whileExpr: [b position=1⇒[whileExpr] b] doExpr: doExpr]
makeLoad: byte code: code | offset
	["check for extended loads"
	byte≥0210 and⦂ byte≤0213⇒
		["extended reference codes:
		0210 - extended inst
		0211 - extended temp
		0212 - extended literal
		0213 - extended literal indirect"
		offset←256*(byte-0207).
		⇑code next+offset]
	 ⇑byte asCompilerCode]
remoteReference: code | i obj offset var
	[i ← stack pop.
	offset ← [i≤124⇒[↪(0 1 2 10)◦(i-120)] literals◦(i-codeLoadLit+1)].
	obj ← stack pop.
	code skip: 2.  "skip new object:offset: "
	var ← [obj=toLoadTempframe⇒[codeLoadTemp+offset-1]
				obj=toLoadSelf⇒[codeLoadField+offset-1]
			user notify: 'bad remote reference'].
	stack next← ParsedFieldReference new var: var]
selectorByte: byte code: code at: p | op sel i nArgs args rcvr
	["check for extended selector codes"
	op ← [byte=toSendLitLong⇒[code next+codeSendLit] byte asCompilerCode].
	"find the corresponding selector and the number of args it expects"
	sel ← self selector: op.
	nArgs ← sel numArgs.
	rcvr ← stack pop.
	[nArgs=0⇒[args←false]
	 nArgs=1⇒[args←stack pop]
	 args ← Vector new: nArgs.
	 for⦂ i from: nArgs to: 1 by: ¬1 do⦂
		[args◦i ← stack pop]].
	stack next← ParsedMessage new rcvr: rcvr op: op args: args.
	p=breakPC⇒[stack last hasPC]]

Macros 
convertMacros: block sel: sel | macros compilerTemps vec loc i
	["replace statement patterns with corresponding macros when possible"
	macros ← (Vector new: 10) asStream.
	"for each temp, compilerTemps is false if it is a user temp, true if it is a
		compiler temp, and nil if not yet known"
	compilerTemps ← Vector new: temps length.
	for⦂ i to: sel numArgs do⦂
		[compilerTemps◦i ← false].
	block findMacros: macros compilerTemps: compilerTemps.
	"insert macros in reverse order to keep indices from being messed up"
	vec ← macros contents.
	for⦂ i from: vec length-1 to: 1 by: ¬2 do⦂
		[vec◦i≡nil⇒[]
		vec◦i insertMacro: vec◦(i+1) decompiler: self].
	"set names of compiler temps to empty string"
	for⦂ i to: temps length do⦂
		[compilerTemps◦i≡true⇒[temps◦i ← '']]]

Printing 
printPattern: sel on: strm | i n keywords
	[n←sel numArgs.
	[n=0⇒[strm append: sel; space  "unary"]
	 keywords←sel keywords.
	 for⦂ i to: keywords length do⦂
		[strm append: keywords◦i; space; append: temps◦i; space]].
	n=(method◦5)⇒[]
	strm append: '| '.   "temps beyond args"
	for⦂ i from: n+1 to: method◦5 do⦂ [strm append: temps◦i; space]]
quickCode: sel class: class | t strm
	[method length=2⇒[⇑sel asParagraph makeBoldPattern]
	method length=5⇒
		[t ← method◦5.
		strm ← Stream default.
		strm append: sel; append: ' [⇑'; append: class instvars◦(t+1); append: ']'.
		⇑strm contents asParagraph makeBoldPattern]
	⇑'undeciperable method' asParagraph]

SystemOrganization classify: ↪Decompiler under: 'Compiler'.

"Generator" 
Class new title: 'Generator'
	subclassof: Object
	fields: 'literals nTemps maxTemp local environment parser supered root requestor sourceStream sourceParagraph'
	declare: '';
	sharing: ByteCodes;
	asFollows 

I generate code parsed by parser.  The symbol tables I use are local and environment.  The run-time needs of the code are recorded in literals, nTemps, and maxTemp.  If a message was passed to super, then supered is true.  I remember my root context to abort in case of error.

Services 
compile: sourceParagraph in: class under: category notifying: requestor | selector
	[user displayoffwhile⦂
		[sourceStream ← sourceParagraph asStream.
		selector ← self compileIn: class⇒
			[class organization classify: selector under: category]].
	⇑selector]
evaluate: sourceStream in: context to: receiver notifying: requestor
		| method nvars value tframe
	[method ← user displayoffwhile⦂ [self evaluateIn: context to: receiver].
	root≡true≡false⇒ [⇑method] "compilation failed, return false or corrected value"
	nvars ← nTemps.
	context⇒ "frame copy here because interpret loses control"
		[tframe ← context tempframe◦(1 to: nvars) copyto: (Vector new: method◦3).
		value ← context interpret: method with: tframe.
		tframe◦(1 to: nvars) copyto: context tempframe.
		⇑value]
	⇑Context new have: receiver interpret: method]

Errors 
abortWith: errorString | mySender
	[[WhatFlag⇒ [user notify: errorString]].
	mySender ← thisContext swapSender: root sender.
	root sender ← nil. root ← nil. parser terminate.
	mySender release. mySender ← nil.
	user restoredisplay.
	⇑requestor notify: errorString at: sourceStream position in: sourceStream]
"Parser notify"
notify: errorString
	[parser notify: errorString]
"ParsedObjectReference remote"
terminate
	[root ← nil]
"Parser terminate"

Code generation 
compileIn: class
		| block method nargs selector primitive
	[parser ← Parser new. root ← thisContext. parser from: sourceStream to: self.
	self initSymbols: class.
	block ← ParsedBlock default.
	selector ← parser pattern: block. nargs ← nTemps.
	parser temporaries: block. primitive ← parser body: block.
	parser mustBeDone. parser ← nil.
	block mustReturn: true "defaults to ⇑self".
		[method ← [primitive=0 and⦂ nargs=0⇒ [block quickCode] false]⇒ []
		method ← self generate: block in: class.
		method◦2 ← primitive; ◦4 ← nargs].
	class install: selector method: method literals: literals
		code: [sourceParagraph is: Paragraph⇒ [sourceParagraph]
			sourceStream asArray] backpointers: nil.
	[HuhFlag⇒ [Huh←nil. Huh ← (self decompile: method onto: Stream default) contents. HuhFlag←false]].
	⇑selector]
"compile"
decompile: method onto: s
	[method length<6⇒
		[s append: 'Quick code: '; append: method asBytes. ⇑s]
	s print: method◦4; append: ' args; ';
		print: method◦5; append: ' temps; ';
		print: (method◦3) - (method◦5); append: ' stack; ';
		print: (method◦6) -6 /2; append: ' literals; '.
	[(method◦2) > 0⇒ [s append: ' primitive: '; print: method◦2; append: ';']].
	s print: method length; append: ' bytes total.'; cr.
	method◦2 = 40⇒ [⇑s]
	⇑self decompileBytes: method onto: s]
decompileBytes: method onto: s
		| dict x i c m t
	[dict ← Dictionary new init: 64.
	dict insertall: ((128 to: 131) copy, 125 concat: (144 to: 175) copy)
		with: ↪(
			'←^' '←' '^' '⇑' 'end'
			'jmp1' 'jmp2' 'jmp3 ' 'jmp4' 'jmp5' 'jmp6' 'jmp7' 'jmp8'
			'bfp1' 'bfp2' 'bfp3 ' 'bfp4' 'bfp5' 'bfp6' 'bfp7' 'bfp8'
			'jmp' 'jmp' 'jmp' 'jmp' 'jmp' 'jmp' 'jmp' 'jmp'
			'bfp' 'bfp' 'bfp' 'bfp' 'bfp' 'bfp' 'bfp' 'bfp').
	for⦂ x from: local contents do⦂
		[i←local◦x. t ← i land: 255.
		[i>255 and⦂ t<16⇒ [i←((i lshift: ¬8)-1 lshift: 4) + t]].
		dict insert: i with: x].
	for⦂ x from: stdSelectors contents do⦂
		[dict insert: stdSelectors◦x with: [x is: Integer⇒ [x inString] x]].
	for⦂ i to: 5 do⦂ [dict insert: toLoadConst+i-1 with: ↪('¬1' '0' '1' '2' '10')◦i].
	for⦂ t from: (m ← (method◦(method◦6 +1 to: method length)) asStream) do⦂
		[[t≥toLoadFieldLong and⦂ t≤toSendLitLong⇒ [t←((t-0207) lshift: 8)+ m next]].
		 [c ← dict lookup: t⇒ [s append: c] s append: '#'. s append: t base8].
		 s space.
		 t < toLongJmp⇒ [] t ≥ 0260⇒ []
		 s print: t\8 -4 *256 + m next; space].
	s cr.
	⇑s]
evaluateIn: context to: receiver
		| block method class nvars
	[ "If context is false, receiver will evaluate in top level"
	block ← ParsedBlock default.
	parser ← Parser new. root ← thisContext.
	parser from: sourceStream to: self.
	[context⇒
		[self initSymbols: (class ← context mclass).
		context variableNamesInto: self with: ParsedBlock default.
		nvars ← nTemps.
		root ← thisContext. "because variableNamesInto nil'ed it"]
	 self initSymbols: (class ← receiver class)].
	parser temporaries: block; statements: block; mustBeDone. parser ← nil.
	block mustReturn: false "returns last value".
	method ← self generate: block in: class.
	[HuhFlag⇒ [Huh←nil. Huh ← (self decompile: method onto: Stream default) contents. HuhFlag←false]].
	root ← true. "to signify success"
	nTemps ← nvars.
	⇑method]
"evaluate"
generate: block in: class
		| header method code lit stack
	[[(lit ← literals find: nil)>0⇒ [literals ← (literals◦(1 to: lit-1)) copy]].
	[supered⇒ [literals ← literals, (Smalltalk ref: class title unique)]].
	header ← 6 + (2* literals length).
	code ← (method ← String new: header + block sizeForValue) asStream.
	code
		next ← 0; next ← 0; next ← 0;
		next ← 0; next ← maxTemp; next ← header.
	for⦂ lit from: literals do⦂
		[code next ← lit PTR lshift: ¬8; next ← lit PTR land: 0377].
	stack ← ParseStack init.
	block emitForValue: code on: stack.
	[stack position≠1⇒ [user notify: 'Compiler stack discrepancy']].
	[code position≠method length⇒ [user notify: 'Compiler code size discrepancy']].
	method◦3 ← maxTemp + stack length.
	⇑method] "compile|evaluate"

Parse tree 
assignment: var expr: expr
	[⇑ParsedAssignment new var: var expr: expr]
"Parser expression"
block
	[⇑ParsedBlock default]
"Parser primary|Parser alternatives"
evalKeyword: arg
	[⇑arg]
"Parser keywordMessage"
ifExpr: ifExpr thenExpr: thenExpr elseExpr: elseExpr
	[⇑ParsedConditional new ifExpr: ifExpr thenExpr: thenExpr elseExpr: elseExpr]
"ifthen...|Parser alternatives"
keywordMessage: rcvr selector: sel args: args
	[sel='and⦂'⇒
		[⇑ParsedConjunct new left: rcvr right: args local];
	  = 'or⦂'⇒
		[⇑ParsedDisjunct new left: rcvr right: args local]
	⇑self rcvr: rcvr selector: sel args: (args remote: self)]
"Parser keywordMessage"
noEvalKeyword: arg
	[⇑arg asRemoteCode: self]
"Parser keywordMessage"
nullStatement: block
	[block next ← toLoadNil. ⇑block]
"ifthen|Parser statements"
rcvr: rcvr selector: sel args: args
	[[rcvr≡toSuper⇒ [supered←true]].
	⇑ParsedMessage new rcvr: rcvr op: (self encodeSel: sel) args: args]
"loop|keywordMessage|Parser binaryMessage|Parser unaryMessage"
receivingVar: expr | rcvr var "who in expr is cascade recipient"
	[rcvr ← expr emittedReceiver⇒
		[var ← rcvr emittedVariable⇒ [⇑var]
		var ← self newTemp. "if a non-variable, compute it just once"
		expr emittedReceiver ← ParsedAssignment new var: var expr: rcvr.
		⇑var]
	parser notify: 'MAY ONLY FOLLOW A MESSAGE']
"Parser cascade"
variable: name
		| var global ref unq
	[var ← local lookup: name⇒ [⇑var]
	[unq ← name hasBeenUniqued⇒
		[for⦂ global from: environment do⦂
			[ref ← global lookupRef: unq⇒
				[⇑codeLoadLitInd + (self litIndex: ref)]]]].
	requestor interactive⇒
		[parser notify: '➲Smalltalk declare: ↪' + name + ' as: nil➲TO DECLARE GLOBAL']
	user show: ' (' + name + ' is Undeclared) '.
	unq ← name unique.
	Undeclared declare: unq.
	⇑codeLoadLitInd + (self litIndex: (Undeclared ref: unq))]
"Parser expression|Parser primary"

Macros 
for: var from: startMinus1 to: stop do: ritual on: block | temp
	[temp ← self newTempForMacro.
	"temp←stop. var←startMinus1. while⦂ temp≥(var ← 1+var) do⦂ ritual"
	block next ← ParsedAssignment new var: temp expr: stop;
		next ← ParsedAssignment new var: var expr: startMinus1;
		next ← ParsedLoop new
			whileExpr:
				(ParsedMessage new rcvr: temp op: toGeq args:
					(ParsedAssignment new var: var
						expr: (ParsedMessage new rcvr: toLoad1 op: toPlus args: var)))
			doExpr: ritual]
"for...todoargs"
forfromdo: block args: args | var sequence ritual strm
	[var ← (args◦1) local. sequence ← args◦2. ritual ← (args◦3) local.
	strm ← self newTempForMacro.
	"strm ← sequence asStream. while⦂ (var ← strm next) do⦂ ritual"
	block next ← ParsedAssignment new var: strm
			expr: (ParsedMessage new rcvr: sequence op: toAsStream args: false);
		next ← ParsedLoop new
			whileExpr:
				(ParsedAssignment new var: var
					expr: (ParsedMessage new rcvr: strm op: toNext args: false))
			doExpr: ritual]
"macro (perform)"
forfromtobydo: block args: args
	["for⦂ var from: (start to: stop by: step) do⦂ ritual"
	args◦2 ← self rcvr: args◦2 selector: 'to:by:' args: (args◦(3 to: 4)) copy.
	self forfromdo: block args: (args◦↪(1 2 5)) copy]
"macro (perform)"
forfromtodo: block args: args
	[self for: (args◦1) local
		from: (ParsedMessage new rcvr: args◦2 op: toMinus args: toLoad1)
		to: args◦3
		do: (args◦4) local
		on: block]
"macro (perform)"
fortodo: block args: args
	[self for: (args◦1) local
		from: toLoad0
		to: args◦2
		do: (args◦3) local
		on: block]
"macro (perform)"
ifthen: block args: args
	[block next ← self ifExpr: (args◦1) local thenExpr: (args◦2) local elseExpr: (self nullStatement: ParsedBlock default)]
"macro (perform)"
ifthenelse: block args: args
	[block next ← self ifExpr: (args◦1) local thenExpr: (args◦2) local elseExpr: (args◦3) local]
"macro (perform)"
macro: block selector: sel args: args
		| special
	[special ← inLineMsgs lookup: sel⇒
		[self perform: special with: block with: args]
	Context canunderstand: sel unique⇒
		[block next ← self rcvr: toLoadThisCtxt selector: sel args: (args remote: self)]
	⇑false]
"Parser keywordMessage"
untildo: block args: args
	[block next ← ParsedLoop new whileExpr: (ParsedNegation new rcvr: (args◦1) local op: toEq args: toLoadFalse) doExpr: (args◦2) local]
"macro (perform)"
whiledo: block args: args
	[block next ← ParsedLoop new whileExpr: (args◦1) local doExpr: (args◦2) local]
"macro (perform)"

Table maintenance 
balance
	[⇑nTemps]
"Parser cascade"
comment: s
"Class fieldNamesInto"
contents
"Class fieldNamesInto"
declaration: block name: name asArg: asArg
		| permVar tempVar
	[tempVar ← self newTemp.
	permVar ← local lookup: name ⇒
		[asArg and⦂ permVar isField⇒
			[block next ← ParsedAssignment new var: permVar expr: tempVar]
		parser notify: 'NAME ALREADY IN USE']
	local insert: name with: tempVar]
"Parser declaration|temporaries"
encodeSel: sel
		| code
	[code ← stdSelectors lookup: sel⇒ [⇑code]
	⇑codeSendLit+ (self litIndex: [sel class≡Integer⇒ [UST1◦(sel+1)] sel unique])]
"rcvr|ParsedFieldReference remote|ParsedRemote remote"
identifier: s
	[local insert: s with: (nTemps ← nTemps + 1)]
"Class fieldNamesInto"
initSymbols: class | s
	[environment ← class wholeEnvironment, Smalltalk.
	local ← Dictionary new copyfrom: stdPrimaries.
	nTemps ← codeLoadField-1.
	for⦂ s from: class instvars do⦂
		[local insert: s with: (nTemps ← nTemps + 1)].
	nTemps ← maxTemp ← 0. literals ← Vector new: 123. supered ← false]
"compile|evaluate"
juggle | oldTemps
	[oldTemps ← maxTemp. maxTemp ← nTemps. ⇑oldTemps]
"Parser macro"
literal: x  | i
	[[x class≡Integer⇒ [0≠(i←↪(¬1 0 1 2 10) find: x)⇒ [⇑toLoadConst+i-1]]].
	⇑codeLoadLit + (self litIndex: x)]
"Parser primary|ParsedFieldReference remote"
litIndex: oop  | i t
	[for⦂ i to: 123 do⦂
		[(t ← literals◦i)≡nil⇒ [literals◦i←oop. ⇑i-1]
		t class≡oop class⇒ [t sameAs: oop⇒ [⇑i-1]]].
	parser notify: 'MORE THAN 123 LITERALS REFERENCED']
"encodeSel|literal"
newTemp
	[(nTemps ← nTemps+1) > maxTemp and⦂ (maxTemp ← nTemps) > 256⇒
		[parser notify: 'MORE THAN 256 TEMPS REQUIRED']
	⇑codeLoadTemp + nTemps-1]
"receivingVar|declaration"
newTempForMacro "juggle arranged that maxTemp are needed by args of macro"
	[nTemps ← maxTemp. ⇑self newTemp]
"forfromdo|forfromtodo"
separator: c
"Class fieldNamesInto"
trailer: s
"Class fieldNamesInto"
unbalance: nTemps
"Parser cascade"
unjuggle: oldTemps
	[maxTemp ← oldTemps max: maxTemp]
"Parser macro"

SystemOrganization classify: ↪Generator under: 'Compiler'.

"ParsedAssignment" 
Class new title: 'ParsedAssignment'
	subclassof: Object
	fields: 'var expr elide'
	declare: '';
	sharing: ByteCodes;
	asFollows 

I am a node in a compiler parse tree.  I represent an assignment of an expression to a variable.

Initialization 
var: var expr: expr

Code generation 
emitForEffect: code on: stack
	[expr emitForValue: code on: stack. stack pop: 1.
	elide⇒ ["var begins the next statement" code next ← toSmash]
	code next ← toSmashPop.
	var emitBytes: code]
emitForValue: code on: stack
	[expr emitForValue: code on: stack.
	code next ← toSmash.
	var emitBytes: code]
emittedVariable
	[⇑var]
firstPush
	[⇑expr firstPush]
sizeForEffect: nextPush
	[⇑expr sizeForValue + 1 + [elide ← nextPush≡var⇒ [0] var sizeForValue]]
sizeForValue
	[⇑expr sizeForValue + 1 + var sizeForValue]

Miscellaneous 
printon: s
	[s append: '('; print: var; append: '←'; print: expr; append: ')']

Decompiling 
expr [⇑expr]
findMacros: macros compilerTemps: compilerTemps
	[var findMacros: macros compilerTemps: compilerTemps.
	expr findMacros: macros compilerTemps: compilerTemps]
isForFromInit: loop | cond b nextMess
	["return true if I could be the first initialization statement for a 
		for⦂ from: loop."
	(expr isnt: ParsedMessage) or⦂ expr op≠toAsStream⇒[⇑false]
	loop isnt: ParsedLoop⇒[⇑false]
	b ← loop whileExpr.
	(b isnt: ParsedBlock) or⦂ b position≠2⇒[⇑false]
	b◦1 isnt: ParsedAssignment⇒[⇑false]
	nextMess ← (b◦1) expr.
	nextMess isnt: ParsedMessage⇒[⇑false]
	nextMess rcvr≠var or⦂ nextMess op≠toNext⇒[⇑false]
	⇑true]	
isForFromToInit: start loop: loop | b incr test
	["return true if I could be the first initialization statement for a 
		for⦂ to: do⦂ or a for⦂ from: to: do⦂ loop"
	"I should set the upper bound, start should set the var to start-1"
	(start isnt: ParsedAssignment) or⦂ (loop isnt: ParsedLoop)⇒[⇑false]
	 [start expr≡toLoad0⇒[]
		start expr isnt: ParsedMessage⇒[⇑false]
		start expr op≠toMinus or⦂ start expr args≠toLoad1⇒[⇑false]].
	"the loop condition should increment the var and compare it with the 
		upper bound"
	b ← loop whileExpr.
	(b isnt: ParsedBlock) or⦂ b position≠2⇒[⇑false]
	incr ← b◦1.
	incr isnt: ParsedAssignment⇒[⇑false]
	incr var≠start var⇒[⇑false]
	(incr expr isnt: ParsedMessage) or⦂ incr expr op≠toPlus⇒[⇑false]
	incr expr rcvr≠toLoad1 or⦂ incr expr args≠start var⇒[⇑false]
	test ← b◦2.
	test isnt: ParsedMessage⇒[⇑false]
	(test rcvr≠var or⦂ test op≠toGeq) or⦂ test args≠incr var⇒[⇑false]
	⇑true]
printon: strm indent: level precedence: p forValue: v decompiler: decompiler
	[ [p>1⇒[strm append: '(']].
	var printon: strm indent: level precedence: 1
			forValue: true decompiler: decompiler.
	strm append: ' ← '.
	expr printon: strm indent: level+2 precedence: 1
			forValue: true decompiler: decompiler.
	p>1⇒[strm append: ')']]
var [⇑var]

SystemOrganization classify: ↪ParsedAssignment under: 'Compiler'.

"ParsedBlock" 
Class new title: 'ParsedBlock'
	subclassof: Stream
	fields: 'returns'
	declare: '';
	sharing: ByteCodes;
	asFollows 

I am a stream to collect the statements of a block and then to become a node in a compiler parse tree.

Initialization 
default
	[limit ← 1. array ← Vector new: 1. position ← 0. returns ← false]
doesReturn
	[returns ← true]
mustReturn: fromMethod
	[returns⇒ []
	[fromMethod⇒
		[position>0 and⦂ (array◦position) emitsLoad⇒ [array◦position ← toLoadSelf] self next ← toLoadSelf]].
	self doesReturn]

Code generation 
emitForEffect: code on: stack
	[returns⇒ [self emitForValue: code on: stack. stack pop: 1]
	self emitExceptLast: code on: stack.
	(array◦position) emitForEffect: code on: stack]
emitForValue: code on: stack
	[self emitExceptLast: code on: stack.
	(array◦position) emitForValue: code on: stack.
	returns⇒ [code next ← toReturn]]
firstPush
	[⇑(array◦1) firstPush]
sizeForEffect: nextPush
	[returns⇒ [⇑self sizeForValue]
	⇑self sizeExceptLast + ((array◦position) sizeForEffect: nextPush)]
sizeForTruth: trueSkip falsity: falseSkip
	[returns⇒ [⇑self sizeForValue]
	⇑self sizeExceptLast + (array◦position sizeForTruth: trueSkip falsity: falseSkip)]
sizeForValue
	[⇑self sizeExceptLast + (array◦position) sizeForValue + [returns⇒ [1] 0]]

Miscellaneous 
printon: s | i
	[s append: '['.
	for⦂ i to: position-1 do⦂ [s print: (array◦i); append: '. '].
	[returns⇒ [s append: '⇑']].
	[position>0⇒ [s print: (array◦position)]].
	s append: ']']
quickCode | t v
	[position=1 and⦂ (returns and⦂ (v←array◦1) emitsLoad)⇒
		[v=toLoadSelf⇒ [t ← String new: 2. t◦1←0; ◦2←1. ⇑t]
		v isField⇒
			[t ← String new: 5. t◦1←0; ◦2←40; ◦3←0; ◦4←0; ◦5←v. ⇑t]
		⇑false]
	⇑false]
returns
	[⇑returns]

Private 
emitExceptLast: code on: stack
		| i
	[for⦂ i to: position-1 do⦂ [(array◦i) emitForEffect: code on: stack]]
sizeExceptLast
		| i next nextPush size
	[size ← 0. next ← array◦position.
	for⦂ i to: position-1 do⦂
		[nextPush ← next firstPush. next ← array◦(position-i).
		size ← size + (next sizeForEffect: nextPush)].
	⇑size]

Decompiling 
findMacros: macros compilerTemps: compilerTemps | i s t
"Look for for statements.  If one of my statements is the init statement for a for, append myself and the index of that statement to the stream macros.  Mark its compiler-generated temp.  If the temp is subsequently used before being re-assigned, the pattern can't be a for after all, and will be deleted from macros."
	[for⦂ i to: position do⦂
		[s ← array◦i.
		(s isnt: ParsedAssignment) or⦂
				(s var<codeLoadTemp or⦂ s var>(codeLoadTemp+255))⇒  "not a for"
			[s findMacros: macros compilerTemps: compilerTemps]
		t ← s var-codeLoadTemp+1.
		i≤(position-2) and⦂ (s isForFromToInit: array◦(i+1) loop: array◦(i+2))⇒
			[macros next← self; next← i.
			compilerTemps◦t ← true.
			"check other parts of the for"
			s expr findMacros: macros compilerTemps: compilerTemps.
			array◦(i+1) findMacros: macros compilerTemps: compilerTemps.
			(array◦(i+2)) doExpr findMacros: macros compilerTemps: compilerTemps.
			i ← i+2]
		i≤(position-1) and⦂ (array◦i isForFromInit: array◦(i+1))⇒
			[macros next← self; next← i.
			compilerTemps◦t ← true.
			s expr findMacros: macros compilerTemps: compilerTemps.
			(array◦(i+1)) doExpr findMacros: macros compilerTemps: compilerTemps.
			i ← i+1]
		s findMacros: macros compilerTemps: compilerTemps]]
insertMacro: loc decompiler: decompiler | macro n i
	["create a parsed for loop, and replace the old statements by it"
	macro ← ParsedForLoop new block: self loc: loc decompiler: decompiler.
	array◦loc ← macro.
	n ← macro nStatements.
	for⦂ i from: loc+n to: position do⦂
		[array◦(i-n+1) ← array◦i].
	position ← position-n+1]
printon: strm indent: level precedence: p forValue: v decompiler: decompiler | i
	["ignore precedence, since the block is enclosed in brackets"
	position=0⇒[strm append: '[]' ]
	strm append: '['.
	for⦂ i to: position-1 do⦂
		[array◦i printon: strm indent: level precedence: 0
			forValue: false decompiler: decompiler.
		strm append: '.'; crtab: level].
	 [returns⇒[strm append: '⇑']].
	array◦position printon: strm indent: level precedence: 0
		forValue: (returns or⦂ v) decompiler: decompiler.
	strm append: ']' ]

As yet unclassified 
emitForTruth: trueSkip falsity: falseSkip into: code on: stack
	[returns⇒ [self emitForValue: code on: stack]
	self emitExceptLast: code on: stack.
	(array◦position) emitForTruth: trueSkip falsity: falseSkip into: code on: stack]

SystemOrganization classify: ↪ParsedBlock under: 'Compiler'.

"ParsedConditional" 
Class new title: 'ParsedConditional'
	subclassof: Object
	fields: 'ifExpr thenExpr elseExpr thenSize elseSize jmpSize'
	declare: '';
	asFollows 

I am a node in a compiler parse tree.  I represent a condition and two alternatives.

Initialization 
ifExpr: ifExpr thenExpr: thenExpr elseExpr: elseExpr

Code generation 
emitForEffect: code on: stack
	[ifExpr emitForValue: code on: stack.
	thenSize emitBfp: code on: stack.
	thenExpr emitForEffect: code on: stack.
	[jmpSize>0⇒ [elseSize emitJmp: code on: stack]].
	elseExpr emitForEffect: code on: stack]
emitForValue: code on: stack
	[ifExpr emitForValue: code on: stack.
	thenSize emitBfp: code on: stack.
	thenExpr emitForValue: code on: stack.
	stack pop: 1.
	[jmpSize>0⇒ [elseSize emitJmp: code on: stack]].
	elseExpr emitForValue: code on: stack]
firstPush
	[⇑ifExpr firstPush]
sizeForEffect: nextPush
	[elseSize ← elseExpr sizeForEffect: nextPush.
	jmpSize ← [thenExpr returns⇒ [0] elseSize jmpSize].
	thenSize ← (thenExpr sizeForEffect: ¬1) + jmpSize.
	⇑ifExpr sizeForValue + thenSize bfpSize + thenSize + elseSize]
sizeForValue
	[elseSize ← elseExpr sizeForValue.
	jmpSize ← [thenExpr returns⇒ [0] elseSize jmpSize].
	thenSize ← thenExpr sizeForValue + jmpSize.
	⇑ifExpr sizeForValue + thenSize bfpSize + thenSize + elseSize]

Miscellaneous 
printon: s
	[s append: 'if⦂ '; print: ifExpr; append: 'then⦂ '; print: thenExpr; append: 'else⦂ '; print: elseExpr]
returns
	[⇑thenExpr returns and⦂ elseExpr returns]

Decompiling 
findMacros: macros compilerTemps: compilerTemps
	[ifExpr findMacros: macros compilerTemps: compilerTemps.
	thenExpr findMacros: macros compilerTemps: compilerTemps.
	elseExpr findMacros: macros compilerTemps: compilerTemps]
printon: strm indent: level precedence: p forValue: v decompiler: decompiler
		| pos char
	[ifExpr printon: strm indent: level precedence: 0 
		forValue: true decompiler: decompiler.
	strm append: ' ⇒'.
	[thenExpr position>1 or⦂ (thenExpr◦1 is: ParsedConditional)⇒
		[strm crtab: level+1] strm space].
	thenExpr printon: strm indent: level+1 precedence: 0 
		forValue: v decompiler: decompiler.
	elseExpr position=1 and⦂ elseExpr last≡nil⇒[]
	strm crtab: level.
	"Kludge!! Delete brackets around else block"
	pos←strm position.  char←strm pop.
	elseExpr printon: strm indent: level precedence: 0 
		forValue: v decompiler: decompiler.
	strm skip: ¬1.  strm◦pos←char]

SystemOrganization classify: ↪ParsedConditional under: 'Compiler'.

"ParsedConjunct" 
Class new title: 'ParsedConjunct'
	subclassof: Object
	fields: 'left right rightSize'
	declare: '';
	sharing: ByteCodes;
	asFollows 

I am a node in a compiler parse tree.  I represent (left and⦂ right) and try to optimize the code generation thereof.

Initialization 
left: left right: right

Code generation 
emitForEffect: code on: stack
	[left emitForValue: code on: stack.
	rightSize emitBfp: code on: stack.
	right emitForEffect: code on: stack]
emitForTruth: trueSkip falsity: falseSkip into: code on: stack
	[left emitForTruth: 0 falsity: rightSize+falseSkip into: code on: stack.
	right emitForTruth: trueSkip falsity: falseSkip into: code on: stack]

emitForValue: code on: stack
	[left emitForValue: code on: stack.
	rightSize emitBfp: code on: stack.
	right emitForValue: code on: stack.
	1 emitJmp: code on: stack.
	code next ← toLoadFalse]
firstPush
	[⇑left firstPush]
sizeForEffect: nextPush
	[rightSize ← right sizeForEffect: ¬1.
	⇑left sizeForValue + rightSize bfpSize + rightSize]
sizeForTruth: trueSkip falsity: falseSkip
	[rightSize ← right sizeForTruth: trueSkip falsity: falseSkip.
	⇑(left sizeForTruth: 0 falsity: rightSize+falseSkip) + rightSize]
sizeForValue
	[rightSize ← right sizeForValue + 1.
	⇑left sizeForValue + rightSize bfpSize + rightSize + 1]

Miscellaneous 
emittedReceiver
	[⇑left]
emittedReceiver ← left
printon: s
	[s append: '('; print: left; append:  ' and⦂ '; print: right; append: ')']

Decompiling 
findMacros: macros compilerTemps: compilerTemps
	[left findMacros: macros compilerTemps: compilerTemps.
	right findMacros: macros compilerTemps: compilerTemps]
printon: strm indent: level precedence: p forValue: v decompiler: decompiler
	[ [p≥2⇒[strm append: '(']].
	left printon: strm indent: level precedence: 2
		forValue: true decompiler: decompiler.
	strm append: ' and⦂ '.
	right printon: strm indent: level precedence: 2
		forValue: v decompiler: decompiler.
	p≥2⇒[strm append: ')']]

SystemOrganization classify: ↪ParsedConjunct under: 'Compiler'.

"ParsedDisjunct" 
Class new title: 'ParsedDisjunct'
	subclassof: Object
	fields: 'left right rightSize'
	declare: '';
	sharing: ByteCodes;
	asFollows 

I am a node in a compiler parse tree.  I represent (left or⦂ right) and try to optimize the code generation thereof.

Initialization 
left: left right: right

Code generation 
emitForEffect: code on: stack
	[left emitForValue: code on: stack.
	rightSize jmpSize emitBfp: code on: stack.
	rightSize emitJmp: code on: stack.
	right emitForEffect: code on: stack]
emitForTruth: trueSkip falsity: falseSkip into: code on: stack
	[left emitForTruth: rightSize+trueSkip falsity: 0 into: code on: stack.
	right emitForTruth: trueSkip falsity: falseSkip into: code on: stack]
emitForValue: code on: stack
	[left emitForValue: code on: stack.
	(1 + rightSize jmpSize) emitBfp: code on: stack.
	code next ← toLoadTrue.
	rightSize emitJmp: code on: stack.
	right emitForValue: code on: stack]
firstPush
	[⇑left firstPush]
sizeForEffect: nextPush
	[rightSize ← right sizeForEffect: ¬1.
	⇑left sizeForValue + 1 + rightSize jmpSize + rightSize]
sizeForTruth: trueSkip falsity: falseSkip
	[rightSize ← right sizeForTruth: trueSkip falsity: falseSkip.
	⇑(left sizeForTruth: rightSize+trueSkip falsity: 0) + rightSize]
sizeForValue
	[rightSize ← right sizeForValue.
	⇑left sizeForValue + 2 + rightSize jmpSize + rightSize]

Miscellaneous 
emittedReceiver
	[⇑left]
emittedReceiver ← left
printon: s
	[s append: '('; print: left; append: ' or⦂ '; print: right; append: ')']

Decompiling 
findMacros: macros compilerTemps: compilerTemps
	[left findMacros: macros compilerTemps: compilerTemps.
	right findMacros: macros compilerTemps: compilerTemps]
printon: strm indent: level precedence: p forValue: v decompiler: decompiler
	[ [p≥2⇒[strm append: '(']].
	left printon: strm indent: level precedence: 2
		forValue: true decompiler: decompiler.
	strm append: ' or⦂ '.
	right printon: strm indent: level precedence: 2
		forValue: v decompiler: decompiler.
	p≥2⇒[strm append: ')']]

SystemOrganization classify: ↪ParsedDisjunct under: 'Compiler'.

"ParsedFieldReference" 
Class new title: 'ParsedFieldReference'
	subclassof: Object
	fields: 'var toLoadVar toLoadFieldReference toObjectOffset'
	declare: '';
	sharing: ByteCodes;
	asFollows 

I am a node in a compiler parse tree.  I represent a remote argument which is a reference to a method or instance variable.

Initialization 
var: var

Code generation 
emitForValue: code on: stack
	[([var isField⇒ [toLoadSelf] toLoadTempframe]) emitForValue: code on: stack.
	toLoadVar emitForValue: code on: stack.
	toLoadFieldReference emitForValue: code on: stack.
	code next ← toNew. toObjectOffset emitBytes: code..
	stack pop: 2]
local
	[⇑var]
remote: generator
	[toLoadVar ← generator literal: (var land: 0177)+1.
	toLoadFieldReference ← generator literal: FieldReference.
	toObjectOffset ← generator encodeSel: ↪object:offset:]
sizeForValue
	[⇑ 2 + toLoadVar sizeForValue +
		toLoadFieldReference sizeForValue + toObjectOffset sizeForValue]

Miscellaneous 
printon: s
	[s append: 'FLD=> '; print: var]

Decompiling 
findMacros: macros compilerTemps: compilerTemps
	[var findMacros: macros compilerTemps: compilerTemps]
printon: strm indent: level precedence: p forValue: v decompiler: decompiler
	[var printon: strm indent: level precedence: p
			forValue: true decompiler: decompiler]

SystemOrganization classify: ↪ParsedFieldReference under: 'Compiler'.

"ParsedForLoop" 
Class new title: 'ParsedForLoop'
	subclassof: Object
	fields: 'var source start stop step doExpr nStatements'
	declare: '';
	sharing: ByteCodes;
	asFollows 

I represent a for loop.  I am used only by the decompiler, not the compiler.

Decompiling 
block: block loc: loc decompiler: decompiler | init1 init2 loop s
	["loc should point to the initialization statement for a for loop in block"
	init1 ← block◦loc.
	block◦(loc+1) is: ParsedLoop⇒
		[nStatements ← 2.
		loop ← block◦(loc+1).
		var ← loop whileExpr◦2.  doExpr ← loop doExpr.
		"init statement creates a stream ... see if its an interval"
		s ← init1 expr rcvr.
		(s is: ParsedMessage) and⦂ (decompiler selector: s op)≡↪to:by: ⇒
			[start ← s rcvr.
			stop ← s args◦1.  step ← s args◦2]
		source ← s]
	"must be a for⦂from:to:do⦂.  init1 will set up the limit, and init2 will
		initialize var to start-1"
	nStatements ← 3.
	init2 ← block◦(loc+1).  loop ← block◦(loc+2).
	var ← init2 var.
	start ← [init2 expr≡toLoad0	⇒[toLoad1] init2 expr rcvr].
	stop ← init1 expr.  step ← toLoad1.
	doExpr ← loop doExpr]
nStatements
	["return the number of statements in my expanded form"
	⇑nStatements]
printon: strm indent: level precedence: p forValue: v decompiler: decompiler
	[source≡nil⇒
		[strm append: 'for⦂ '.
		var printon: strm indent: level precedence: 2
			forValue: true decompiler: decompiler.
		 [start≡toLoad1⇒[] strm append: ' from: '.
			start printon: strm indent: level precedence: 2
				forValue: true decompiler: decompiler].
		strm append: ' to: '.
		stop printon: strm indent: level precedence: 2
			forValue: true decompiler: decompiler.
		 [step≡toLoad1⇒[] strm append: ' by: '.
			step printon: strm indent: level precedence: 2
				forValue: true decompiler: decompiler].
		strm append: ' do⦂'; crtab: level+1.
		doExpr printon: strm indent: level+1 precedence: 0 
			forValue: false decompiler: decompiler]
	"source is a stream"
	strm append: 'for⦂ '.
	var printon: strm indent: level precedence: 2
		forValue: true decompiler: decompiler.
	strm append: ' from: '.
	source printon: strm indent: level precedence: 2
		forValue: true decompiler: decompiler.
	strm append: ' do⦂'; crtab: level+1.
	doExpr printon: strm indent: level+1 precedence: 0 
		forValue: false decompiler: decompiler]

SystemOrganization classify: ↪ParsedForLoop under: 'Compiler'.

"ParsedLoop" 
Class new title: 'ParsedLoop'
	subclassof: Object
	fields: 'whileExpr doExpr whileSize doSize'
	declare: '';
	sharing: ByteCodes;
	asFollows 

I am a node in a compiler parse tree.  I represent that part of an in-line loop statement that can be expressed in the while-do form.

Initialization 
whileExpr: whileExpr doExpr: doExpr

Code generation 
emitForEffect: code on: stack
	["optimization removed to make things easier for decompiler --
	whileExpr emitForTruth: 0 falsity: doSize into: code on: stack."
	whileExpr emitForValue: code on: stack.
	doSize emitBfp: code on: stack.
	doExpr emitForEffect: code on: stack.
	0 - doSize - whileSize - doSize jmpSize emitJmp: code on: stack]
emitForValue: code on: stack
	[self emitForEffect: code on: stack.
	toLoadNil emitForValue: code on: stack]
firstPush
	[⇑whileExpr firstPush]
sizeForEffect: nextPush
	[doSize ← (doExpr sizeForEffect: ¬1) + 2.
	"whileSize ← whileExpr sizeForTruth: 0 falsity: doSize."
	whileSize ← whileExpr  sizeForValue.
	⇑whileSize + doSize + doSize jmpSize]
sizeForValue
	[⇑(self sizeForEffect: ¬1) + 1]

Miscellaneous 
printon: s
	[s append: 'while⦂ '; print: whileExpr; append: 'do⦂ '; print: doExpr]

Decompiling 
doExpr [⇑doExpr]
findMacros: macros compilerTemps: compilerTemps
	[whileExpr findMacros: macros compilerTemps: compilerTemps.
	doExpr findMacros: macros compilerTemps: compilerTemps]
printon: strm indent: level precedence: p forValue: v decompiler: decompiler
	[[whileExpr is: ParsedNegation⇒
		[strm append: 'until⦂ '.
		whileExpr negated printon: strm indent: level precedence: 2
			forValue: true decompiler: decompiler]
	 strm append: 'while⦂ '.
	 whileExpr printon: strm indent: level precedence: 2
		forValue: true decompiler: decompiler].
	strm append: ' do⦂'; crtab: level+1.
	doExpr printon: strm indent: level+1 precedence: 0 
		forValue: false decompiler: decompiler]
whileExpr [⇑whileExpr]

SystemOrganization classify: ↪ParsedLoop under: 'Compiler'.

"ParsedMessage" 
Class new title: 'ParsedMessage'
	subclassof: Object
	fields: 'rcvr op args "false if no args, Vector if many args" hasPC'
	declare: '';
	sharing: ByteCodes;
	asFollows 

I am a node in a compiler parse tree.  I represent an expression consisting of a receiver (rcvr), a selector byte code (op), and an argument list (args) which is false for no arguments, a vector of parse trees for 2 or more arguments, or the argument parse tree for one argument.

Initialization 
hasPC [hasPC← true]
rcvr: rcvr op: op args: args
	[hasPC← false.
	op=toEq and⦂ ((toLoadFalse≡rcvr) or⦂ (toLoadFalse≡args))⇒
		[⇑ParsedNegation new rcvr: rcvr op: op args: args]]

Code generation 
emitForEffect: code on: stack
	[self emitForValue: code on: stack. code next ← toPop. stack pop: 1]
emitForValue: code on: stack
	[args emitForValue: code on: stack.
	rcvr emitForValue: code on: stack.
	[rcvr≡toSuper⇒ [code next←rcvr]].
	op emitBytes: code. args argsOff: stack]
firstPush
	[⇑([args⇒ [args] rcvr]) firstPush]
sizeForEffect: nextPush
	[⇑self sizeForValue+1]
sizeForValue
	[⇑args sizeForValue + rcvr sizeForValue + op sizeForValue + [rcvr≡toSuper⇒ [1] 0]]

Miscellaneous 
args [⇑args]
args←args
emittedReceiver
	[⇑rcvr]
emittedReceiver ← rcvr
op [⇑op]
printon: s
	[s append: '('; print: rcvr; space; print: op.
	[args⇒ [s space; print: args]].
	s append: ')']
rcvr [⇑rcvr]

Decompiling 
findMacros: macros compilerTemps: compilerTemps | vec a
	[vec ← [args≡nil⇒[↪()] args is: Vector⇒[args] args inVector].
	for⦂ a from: vec do⦂
		[a findMacros: macros compilerTemps: compilerTemps].
	rcvr findMacros: macros compilerTemps: compilerTemps]
printon: strm indent: level precedence: p forValue: v decompiler: decompiler
		| sel keywords i parens myP vec char1
	[sel ← decompiler selector: op.
	myP ← [sel isinfix⇒[3]; iskeyword⇒[2]; isarrow⇒[1] 4].
	"check if parens are needed"
	parens ← [myP<p or⦂ (p=2 and⦂ myP=2)].
	 [parens⇒[strm append: '(']].
	char1← strm position.
	rcvr printon: strm indent: level precedence: myP
			forValue: true decompiler: decompiler.
	 [myP=4⇒[strm space; append: sel  "unary selector"]
	 keywords ← sel keywords.
	vec ← [args≡nil⇒[↪()] args is: Vector⇒[args] args inVector].
	 for⦂ i to: keywords length do⦂
		[strm space; append: keywords◦i; space.
		vec◦i printon: strm indent: level 
				precedence: [myP=3⇒[4] myP]
				forValue: true decompiler: decompiler]].
	[hasPC⇒[decompiler highlight: (char1+1 to: strm position+1)]].
	parens⇒[strm append: ')']]

SystemOrganization classify: ↪ParsedMessage under: 'Compiler'.

"ParsedNegation" 
Class new title: 'ParsedNegation'
	subclassof: ParsedMessage
	fields: ''
	declare: '';
	sharing: ByteCodes;
	asFollows 

I am a node in a compiler parse tree.  I am a parsed messsage in which the selector is ≡ and one of the participants is false.

Initialization 
rcvr: rcvr op: op args: args

Code generation 
emitForTruth: trueSkip falsity: falseSkip into: code on: stack
	[([toLoadFalse≡rcvr⇒ [args] rcvr]) emitForTruth: falseSkip falsity: trueSkip into: code on: stack]
sizeForTruth: trueSkip falsity: falseSkip
	[⇑([toLoadFalse≡rcvr⇒ [args] rcvr]) sizeForTruth: falseSkip falsity: trueSkip]

Miscellaneous 
negated [toLoadFalse≡rcvr⇒[⇑args] ⇑rcvr]
printon: s
	[s append: '(negation)'. super printon: s]

SystemOrganization classify: ↪ParsedNegation under: 'Compiler'.

"ParsedObjectReference" 
Class new title: 'ParsedObjectReference'
	subclassof: Object
	fields: 'var'
	declare: '';
	sharing: ByteCodes;
	asFollows 

I am a node in a compiler parse tree.  I represent a remote argument which is a reference to a class or pool variable.

Initialization 
var: var

Code generation 
emitForValue: code on: stack  "Turn literal indirect into literal direct"
	[(var-256) emitForValue: code on: stack]
local
	[⇑var]
remote: generator
sizeForValue
	[⇑(var-256) sizeForValue]

Miscellaneous 
printon: s
	[s append: 'OBJ=> '; print: var]

Decompiling 
findMacros: macros compilerTemps: compilerTemps
	[var findMacros: macros compilerTemps: compilerTemps]
printon: strm indent: level precedence: p forValue: v decompiler: decompiler
	[strm append: (decompiler literal: var)]

SystemOrganization classify: ↪ParsedObjectReference under: 'Compiler'.

"ParsedRemote" 
Class new title: 'ParsedRemote'
	subclassof: Object
	fields: 'expr esize toRemoteCopy'
	declare: '';
	sharing: ByteCodes;
	asFollows 

I am a node in a compiler parse tree.  I represent an argument that is to be passed unevaluated.

Initialization 
expr: expr

Code generation 
emitForValue: code on: stack
	[toLoadThisCtxt emitForValue: code on: stack.
	toRemoteCopy emitBytes: code.
	code emitLong: toLongJmp by: esize.
	expr emitForValue: code on: stack.
	code next ← toEnd. stack pop: 1.
	(0-esize) emitJmp: code on: stack]
local
	[⇑expr]
remote: generator
	[toRemoteCopy ← generator encodeSel: ↪remoteCopy]
sizeForValue
	[esize ← expr sizeForValue + 3.
	⇑esize + toRemoteCopy sizeForValue + 3]

Miscellaneous 
printon: s
	[s append: '⦂'; print: expr]

Decompiling 
findMacros: macros compilerTemps: compilerTemps
	[expr findMacros: macros compilerTemps: compilerTemps]
printon: strm indent: level precedence: p forValue: v decompiler: decompiler
	[[(expr is: ParsedBlock) and⦂ 
			(expr position>1 or⦂ (expr◦1 is: ParsedConditional))⇒
		[strm crtab: level+1]].
	expr printon: strm indent: level+1 precedence: p
			forValue: true decompiler: decompiler]

SystemOrganization classify: ↪ParsedRemote under: 'Compiler'.

"Parser" 
Class new title: 'Parser'
	subclassof: Object
	fields: 'source dest oppositeCourt type token mark keep'
	declare: '';
	sharing: TokenCodes;
	asFollows 

I parse tokens from source (a stream).  I report each parse node to dest (e.g., a code generator).  When an error occurs, I back up source to mark and notify dest.  I have two kinds of methods, token suppliers and token consumers, which coroutine with each other.  The coroutine that is not in control is suspended in the context, oppositeCourt.  Token suppliers are driven by an instance of class Reader that scans source and classifies each token by type.  Token consumers analyze the syntax and report it to dest.  The variable "keep" is no longer used.

Initialization 
from: source to: dest
	[oppositeCourt ← thisContext.
	mark ← source position. type ← 1.
	(Reader new of: source) readInto: self]
"Generator compile|Generator evaluate"

Token suppliers 
comment: s
	[mark ← source position]
contents
	[type ← 0. mark ← source position + 1.
	thisContext sender ← nil.
	while⦂ true do⦂ [self resume. self notify: 'MORE EXPECTED']]
float: i fraction: f exp: e
	[token ← (i+'.'+f+'e'+e) asFloat.
	type ← aNumber. self resume]
identifier: token
	[type ← aWord. self resume]
integer: s
	[token ← s asInteger.
	type ← aNumber. self resume]
keyword: token
	[type ← aKeyword. self resume]
leftparen
	[type ← aLeftPar. self resume]
onechar: token
	[type ←
		[token=056⇒ [aPeriod];
			=0133⇒ [aLeftBrack];
			=0135⇒ [aRightBrack];
			=033⇒ [aCondArrow];
			=0137⇒ [aLeftArrow];
			=021⇒ [aReturnArrow];
			=073⇒ [aSemicolon];
			=017⇒ [aHand]
		aBinary].
	self resume]
otheratom: token
	[type ← aGibberish. self resume]
rightparen
	[type ← aRightPar. self resume]
separator: c
string: token
	[type ← aString. self resume]
trailer: s
	[mark ← source position]

Method syntax 
body: block  | p  "return the primitive number, or 0"
	[type=aLeftBrack⇒
		[self block: block.
		type=aKeyword and⦂ token='primitive:'⇒
			[self advance. type=aNumber⇒ [p ← token. self advance. ⇑p]
			self notify: 'EXPECTED A NUMBER']
		⇑0]
	⇑0]
"Generator compile"
declaration: block
	[type≠aWord⇒ [self notify: 'EXPECTED AN ARGUMENT NAME']
	dest declaration: block name: token asArg: true.
	self advance]
"pattern"
pattern: block
		| selector
	[selector ← Stream default.
	[type=aWord⇒
			[selector append: token. self advance];
		=aBinary⇒
			[selector append: (UST1◦(token+1)). self advance; declaration: block]
	while⦂ type = aKeyword do⦂ [selector append: token. self advance; declaration: block].
	selector empty⇒ [self notify: 'EXPECTED A SELECTOR']].
	[type=aLeftArrow⇒
		[selector append: '←'. self advance; declaration: block]].
	⇑selector contents unique]
"Generator compile|Context variableNamesInto"
temporaries: block
	[type=aBinary and⦂ token=0174⇒ "|"
		[self advance.
		while⦂ type=aWord do⦂
			[dest declaration: block name: token asArg: false. self advance]]]
"Generator compile|Context variableNamesInto"

Statement syntax 
alternatives: ifExpr "⇒ [..] ..."
		| thenExpr elseExpr
	[self advance.
	type≠aLeftBrack⇒ [self notify: 'EXPECTED A [BLOCK]']
	thenExpr ← self block: dest block. elseExpr ← dest block.
	[type=aSemicolon⇒ [self cascade: elseExpr after: ifExpr] self statements: elseExpr].
	⇑dest ifExpr: ifExpr thenExpr: thenExpr elseExpr: elseExpr]
"cascade"
block: block
	[self advance; statements: block.
	type=aRightBrack⇒ [self advance. ⇑block]
	self notify: 'PERIOD OR RIGHT BRACKET WAS EXPECTED']
"body|alternatives|expression|keywordMessage|binaryMessage"
cascade: block after: expr  | val var oldTemps
	[var ← dest receivingVar: expr.
	oldTemps ← dest balance.
	while⦂ type=aSemicolon do⦂
		[self advance.
		(val ← self messageChain: var)≡var⇒
			[self notify: 'MESSAGE EXPECTED'].
		type=aCondArrow⇒
			[block next ← self alternatives: val. dest unbalance: oldTemps. ⇑self]
		block next ← val].
	dest unbalance: oldTemps]
"statement|alternatives"
loopStmt: block  | oldMark
	[oldMark ← mark. self keywordMessage: false loop: block⇒ [⇑self]
	mark ← oldMark. self notify: 'UNKNOWN CONTROL MESSAGE']
"statement"
macro: block  | oldMark oldTemps val
	[oldMark ← mark. oldTemps ← dest juggle.
	val ← self keywordMessage: false macro: block.
	dest unjuggle: oldTemps.
	val⇒ [⇑block]
	mark ← oldMark. self notify: 'UNKNOWN CONTROL MESSAGE']
"statement"
statement: block | expr
	[type=aReturnArrow⇒
			[self advance. block next ← self expression. block doesReturn.
			[type=aPeriod⇒ [self advance]].
			type≠aRightBrack⇒ [self notify:'SHOULDN''T FOLLOW RETURN']];
		= aKeyword⇒ [self macro: block. type>aPeriod⇒ [self statement: block]];
		≤aPeriod⇒ [dest nullStatement: block] "doit eof aRightBrack aPeriod"
	expr ← self expression.
	type=aCondArrow⇒ [block next ← self alternatives: expr]
	block next ← expr.
	type=aSemicolon⇒ [self cascade: block after: expr]]
"statements"
statements: block
	[self statement: block.
	while⦂ type=aPeriod do⦂
		[self advance. self statement: block]]
"alternatives|block|Generator evaluate"

Expression syntax 
binaryMessage: rcvr assign: assign "binarySelector ..."
		| sel args
	[sel ← token. self advance.
	args ← [type=aLeftBrack⇒ [self block: dest block] self factor].
	[assign and⦂ type=aLeftArrow⇒
		[self advance.
		args ← [(Vector new: 2)◦1←args; ◦2←self expression; itself].
		sel ← [(String new: 2)◦1←sel; ◦2←0137"←"; itself]]].
	⇑dest rcvr: rcvr selector: sel args: args]
"term|messageChain"
expression
		| var
	[type=aLeftBrack⇒ [⇑self block: dest block];
			=aKeyword⇒ [⇑self macro: dest block];
			≠aWord⇒ [⇑self messageChain: self primary]
	"It begins with a variable name" var ← dest variable: token. self advance.
	type≠aLeftArrow⇒ [⇑self messageChain: var]
	"It is a variable assignment" self advance.
	⇑dest assignment: var expr: self expression]
"unaryMessage|binaryMessage|keywordMessage|statement|subExpression"
factor
		| expr
	[expr ← self primary.
	while⦂ type=aWord do⦂ [expr ← self unaryMessage: expr assign: false].
	⇑expr]
"term|binaryMessage"
keywordMessage: rcvr macro: block "keyword ..."
		| sel args arg
	[sel ← Stream default. args ← (Vector new: 4) asStream.
	while⦂ type = aKeyword do⦂
		[sel append: token. self advance.
		arg ← [type=aLeftBrack⇒ [self block: dest block] self term].
		args next ← [sel last=03⇒ [dest noEvalKeyword: arg] dest evalKeyword: arg]].
	[type=aLeftArrow⇒ [sel append: '←'. args next ← [self advance; expression]]].
	sel ← sel contents. args ← [args position=1⇒ [args last] args contents].
	block⇒ [⇑dest macro: block selector: sel args: args]
	⇑dest keywordMessage: rcvr selector: sel args: args]
"macro|messageChain"
messageChain: rcvr
	[while⦂ type=aWord do⦂ [rcvr ← self unaryMessage: rcvr assign: true].
	while⦂ type=aBinary do⦂ [rcvr ← self binaryMessage: rcvr assign: true].
	[type = aKeyword⇒ [rcvr ← self keywordMessage: rcvr macro: false]].
	⇑rcvr]
"cascade|expression"
term  | rcvr
	[rcvr ← self factor.
	while⦂ type=aBinary do⦂ [rcvr ← self binaryMessage: rcvr assign: false].
	⇑rcvr]
"keywordMessage"
unaryMessage: rcvr assign: assign "word ..."
		| sel args
	[sel ← token. self advance.
	args ←	[assign and⦂ type=aLeftArrow⇒ [sel ← sel + '←'. self advance; expression] false].
	⇑dest rcvr: rcvr selector: sel args: args]
"factor|messageChain"

Primary syntax 
literal "A Vector, UniqueString, String, or Number"
		| t oldMark
	[type
		=aLeftPar⇒
			[oldMark ← mark. self advance.
			t ← self read. type=aRightPar⇒ [self advance. ⇑t]
			mark ← oldMark. self notify: 'UNMATCHED']
	t ← [type≥aKeyword⇒ [token unique]; ≤aBinary⇒ [UST1◦(token+1)] token].
	self advance. ⇑t]
"primary|read"
primary
		| t
	[type
		=aWord⇒ [t ← dest variable: token. self advance. ⇑t];
		=aLeftPar⇒ [⇑self subExpression];
		=aNumber⇒ [t ← dest literal: token. self advance. ⇑t];
		=aString⇒ [t ← dest literal: token. self advance. ⇑t];
		=aHand⇒ [self advance.
			type=aRightPar or⦂ type=0⇒ [self notify: 'EXPECTED LITERAL']
			⇑dest literal: self literal]
	self notify: 'OBJECT EXPECTED']
"factor|expression"
read "A sequence of literals"
		| s
	[s ← (Vector new: 10) asStream.
	until⦂ (type=aRightPar or⦂ type=0) do⦂ [s next ← self literal].
	⇑s contents]
"literal"
subExpression "(...)"
		| expr
	[self advance. expr ← self expression.
	type=aRightPar⇒ [self advance. ⇑expr]
	self notify: 'NOT EXPECTED IN A (SUBEXPRESSION)']
"primary"

Suspension 
advance "Switch from the parser to the reader to obtain another token."
	[mark ← source position- [type>aBinary⇒ [1] 0].
	oppositeCourt ← thisContext swapSender: oppositeCourt]
mustBeDone
	[type=0⇒ [self terminate] self notify: 'UNEXPECTED CONSTRUCT']
"Generator compile|Generator evaluate"
notify: errorString | delims
	[source skip: mark - source position.
	delims ← ↪(011 012  014 015 040).
	while⦂ (delims has: source peek) do⦂ [source next].
	[source myend≡false⇒ [source skip: 1]].
	dest abortWith: errorString]
resume "The reader has supplied another token; resume the parser."
	[oppositeCourt ← thisContext swapSender: oppositeCourt]
terminate
	[[dest≡nil⇒ [] dest terminate. dest ← nil].
	[oppositeCourt≡nil⇒ [] oppositeCourt release. oppositeCourt ← nil]]
"mustBeDone|Generator abortWith|Context variableNamesInto"

SystemOrganization classify: ↪Parser under: 'Compiler'.

"ParseStack" 
Class new title: 'ParseStack'
	subclassof: Object
	fields: 'position length'
	declare: '';
	asFollows 

I keep track of the current and high position of the stack that will be needed by code being compiled.

Initialization 
init
	[length ← position ← 0]

Changes 
pop: n
	[(position ← position - n) < 0⇒ [user notify: 'Parse stack underflow']]
push: n
	[(position ← position + n) > length⇒ [length ← position]]

Results 
length
	[⇑length]
position
	[⇑position]

SystemOrganization classify: ↪ParseStack under: 'Compiler'.
