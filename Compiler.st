'From Smalltalk 5.5k XM November 24 on 22 November 1980 at 2:57:08 am.'
\g
"Decompiler"l15000z20000\gbf5 
Class new title: 'Decompiler'
	subclassof: Object
	fields: 'method temps instvars literals stack isReference literalNames'
	declare: 'breakPC highlight ';
	sharing: ByteCodes;
	asFollows\gbf5 

This class has not yet been commented\gi

Initialization\gbf5 
decompile: sel class: class | strm block ignore p
	[method _ class method: sel.
	method length<8[self quickCode: sel class: class]
	self initSymbols: class.
	stack _ (Vector new: (method3)-(method5)) asStream.
	block _ self block: method6+1 to: method length
		pc ignore hasValue ignore.
	stack emptyfalse[user notify: 'stack not empty']
	self convertMacros: block sel: sel.
	strm _ Stream default.
	self printPattern: sel on: strm.
	strm crtab: 1.
	block printon: strm indent: 1 precedence: 0 forValue: false decompiler: self.
	[(p_method word: 1)0[strm append: ' primitive: '; print: p]].
	strm contents asParagraph makeBoldPattern]\gb28B
findPC: x [breakPC_ x. highlight_ 1 to: 1]\gb10B
highlight [highlight]\gb10B
highlight: x [highlight_ x]\gb13B

Symbols\gbf5 
initSymbols: class | i lit env
	["Init temps with made-up names"
	temps _ Vector new: method5.
	for i to: temps length do
		[tempsi _ 't' + i asString].
	instvars _ class instvars.
	literals _ MessageDict new literalsIn: method.
	literalNames _ Vector new: literals length.
	env _ class wholeEnvironment, Smalltalk, Undeclared.
	for i to: literals length do
		[lit _ literalsi.
		literalNamesi _
			[lit is: UniqueString[lit]
			lit is: ObjectReference[self invertRef: lit environment: env]
			litFieldReference['']
			lit asString]]]\gb19B15i29I
instvar: i
	[instvars(i-codeLoadField+1)]\gb12B
invertRef: ref environment: env | table n
	[for table from: env do
		[n_table invertRef: ref[n]].
	'unknown']\gb32B
literal: i | index lit str
	[index _ i-codeLoadLit+1.
	lit _ literalsindex.  str _ literalNamesindex.
	lit is: ObjectReference[str]
	(lit is: UniqueString) or (lit is: Vector)['' + str]
	str]\gb11B
literalIndirect: i
	[literalNames(i-codeLoadLitInd+1)]\gb20B
selector: i 
	[i>166 and i<208[SpecialOops(i-166)]
	literalNames(i-codeSendLit+1)]\gb14B
temp: i
	[temps(i-codeLoadTemp+1)]\gb9B

Byte Interpretation\gbf5 
block: start to: end pc pc hasValue v
		| block code byte j stackPos t
	["Decompile the method from start to end into a ParsedBlock and return the
		instance of ParsedBlock.  Assign to pc the value of the pc after leaving
		the block.  If at run time this block will leave a value on the stack,
		set hasValue to true."
	block _ ParsedBlock default. pc value_ end+1.
	stackPos _ stack position.
	code _ Stream new of: method from: start to: end.
	for byte from: code do
		[byte<0200[self loadByte: byte code: code]
		byte<0210[self controlByte: byte code: code block: block]
		byte<0214[self loadByte: byte code: code  "extended loads"]
		byte=0214[self selectorByte: byte code: code at: code position  "extended selector"]
		byte<0260
			[j_self jumpByte: byte code: code block: block.
			code end[pc value_j]]
		self selectorByte: byte code: code at: code position]
	"If there is an additional item on the stack, it will be the value
		of this block"
	stack position>stackPos
		[t_stack pop.  v value_true.
		block empty and (t is: ParsedBlock)[t]
		block next_ t.
		block]
	v value_false.
	[block empty[block next_ nil]].
	"pretend that returns jump to end of method"
	[block returns or (blockblock position) returns
		[pc value_ method length+1]].
	block]\gb42B
checkForRemoteCode: jump code: code block: block | m ignore t j b
"Check if this is a jump around remote code."
	[jump>code limit[false]
	"remote code should terminate with a toEnd, and then a jump back"
	method(jump-3)toEnd[false]
	t _ method(jump-2).
	t<0240 or t>0243[false]
	j _ t-0244*256+(method(jump-1)).
	jump+j  (code position+1) [false]
	m _ stack pop.
	((m isnt: ParsedMessage) or m rcvrtoLoadThisCtxtfalse) or
			(self selector: m op)remoteCopy
		[stack next_ m.  false]
	"it's a piece of remote code"
	b _ self block: code position+1 to: jump-4
		pc ignore hasValue ignore.
	stack next_ ParsedRemote new expr: b.
	code position_ jump-1]\gb49B18i43I31i36u5U22I303i27I
conditionalJump: elseStart code: code block: block
		| cond ifExpr thenExpr elseExpr thenJump elseJump ignore newBlock
			hasValue last
	[ifExpr _ stack pop.
	thenExpr _ self block: code position+1 to: elseStart-1
		pc thenJump hasValue hasValue.
	"ensure jump is within block (in case thenExpr returns)"
	thenJump _ thenJump min: code limit+1.
	"if jump goes back, then it's a loop"
	thenJump<elseStart
		[self loop: thenJump whileExpr: ifExpr doExpr: thenExpr
			code: code block: block doSize: elseStart-code position-1.
		code position_ elseStart-1]
	elseExpr _ self block: elseStart to: thenJump-1
		pc elseJump hasValue ignore.
	"if elseJump is backwards, it is not part of the elseExpr"
	[elseJump<code position
		[code position_ thenJump-3.  last_true] 
	code position_ thenJump-1].
	[thenJump+1=code limit  "still might be last"
			and (methodthenJump0240 and methodthenJump0247)
		[last_true]].
	[thenJump=code limit
			and (methodthenJump0220 and methodthenJump0227)
		[last_true]].
	"check for and or or"
	hasValue and (thenExpr position=1 and thenExpr1toLoadTrue)
		[stack next_ ParsedDisjunct new left: ifExpr right:
				[elseExpr position=1[elseExpr1] elseExpr] ]
	hasValue and (elseExpr position=1 and elseExpr1toLoadFalse)
		[stack next_ ParsedConjunct new left: ifExpr right:
				[thenExpr position=1[thenExpr1] thenExpr] ]
	"it's an if statement"
	cond _ ParsedConditional new
			ifExpr: ifExpr thenExpr: thenExpr elseExpr: elseExpr.
	"If the then part has a value, put the conditional in a block, and put the
		block on the stack.  (If the compiler is working right the else part will
		leave a value, too ... this is not checked)."
	hasValue
		[newBlock_ParsedBlock default.  newBlock next_ cond.
		stack next_ newBlock]
	"If the thenExpr jumps to the end of the current block,
		or to a jump backwards at the end of the current block,
		or to a self at the end of the method,
		append the cond
		to the current block.  Otherwise, embed it in a new block."
	(code end or lasttrue) or
	(thenJump+1=method length and methodthenJump=toLoadSelf)
		[block next_ cond]
	newBlock_ParsedBlock default.  newBlock next_ cond.
	block next_ newBlock]\gb53B198i54I44i35I257i3u8U45I126i19I174i21I343i20I91i196I94i233I
controlByte: byte code: code block: block | var t strm
	[byte=toSmashPop
		[var _ self makeLoad: code next code: code.
		block next_ ParsedAssignment new var: var expr: stack pop]
	byte=toSmash
		["smash no pop at the end of a block will require the next byte
			to be fetched from after the limit of the block"
		code end
			[strm _ Stream new of: method from: code limit+1 to: method length.
			var _ self makeLoad: strm next code: strm.
			block next_ ParsedAssignment new var: var expr: stack pop]
		var _ self makeLoad: code next code: code.
		block next_ ParsedAssignment new var: var expr: stack pop.
		"uncascade assignment statements"
		stack next_ var]
	byte=toPop
		[block next_ stack pop]
	byte=toReturn
		[t _ stack pop.
		stack emptyfalse[user notify: 'stack not empty']
		"elide final self"
		ttoLoadSelf and code position=method length[]
		block doesReturn.
		block next_ t]
	byte=toEnd
		[user notify: 'unexpected']
	byte=toLoadThisCtxt
		[stack next_ byte]
	byte=toSuper
		[stack pop.  "delete ref to self"
		stack next_ byte]
	user notify: 'unknown control byte']\gb42B158i112I302i31I150i17I207i18I
jumpByte: byte code: code block: block | offset j
"If this is an unconditional jump, return the position in the method to which it jumps.  If this is a conditional jump forward, parse a conditional statement.  Conditional jumps backward are not produced by the current compiler."
	[byte<0230["short unconditional jump forward"
		byte-0220+code position+2]
	byte<0240["short conditional jump forward"
		self conditionalJump: byte-0230+code position+2 code: code block: block.
		code position+1]
	byte<0250["long unconditional jump"
		offset _  code next.
		j _ byte-0244*256+offset+code position+1.
		self checkForRemoteCode: j code: code block: block.
		j]
	byte<0254[code skip: 1.  "long conditional jump backward"
		user notify: 'conditional jump backward not expected']
	byte<0260["long conditional jump forward"
		offset _ code next.
		self conditionalJump: byte-0254*256+offset+code position+1
			code: code block: block.
		code position+1]
	user notify: 'not a jump byte']\gb39B12i227I16i32I45i30I110i23I259i29I
loadByte: byte code: code | t lit
	[t _ self makeLoad: byte code: code.
	tcodeLoadLit and t<codeLoadLitInd
		[lit _ literals(t-codeLoadLit+1).
		litFieldReference
			[self remoteReference: code]
		lit is: ObjectReference
			[stack next_ ParsedObjectReference new var: t]
		stack next_ t]
	stack next_ t]\gb26B
loop: jumpBack whileExpr: whileExpr doExpr: doExpr code: code block: block
doSize: doSize
		| n b ignore
	["jumpBack will jump to the beginning of whileExpr.  In the case of for statements or while's with a block in the condition, the whileExpr should include more than just the last expression.  Kludge: find all the statements needed by re-decompiling."
	n _ code position-doSize jmpSize.
	b _ self block: jumpBack to: n pc ignore hasValue ignore.
	"discard unwanted statements from block"
	block skip: 1-b position.
	block next_ ParsedLoop new 
		whileExpr: [b position=1[whileExpr] b] doExpr: doExpr]\gb92B16i246I100i38I
makeLoad: byte code: code | offset
	["check for extended loads"
	byte0210 and byte0213
		["extended reference codes:
		0210 - extended inst
		0211 - extended temp
		0212 - extended literal
		0213 - extended literal indirect"
		offset_256*(byte-0207).
		code next+offset]
	 byte asCompilerCode]\gb26B12i24I33i134I
remoteReference: code | i obj offset var
	[i _ stack pop.
	offset _ [i124[(0 1 2 10)(i-120)] literals(i-codeLoadLit+1)].
	obj _ stack pop.
	code skip: 2.  "skip new object:offset: "
	var _ [obj=toLoadTempframe[codeLoadTemp+offset-1]
				obj=toLoadSelf[codeLoadField+offset-1]
			user notify: 'bad remote reference'].
	stack next_ ParsedFieldReference new var: var]\gb22B139i5u3U1u14U1I
selectorByte: byte code: code at: p | op sel i nArgs args rcvr
	["check for extended selector codes"
	op _ [byte=toSendLitLong[code next+codeSendLit] byte asCompilerCode].
	"find the corresponding selector and the number of args it expects"
	sel _ self selector: op.
	nArgs _ sel numArgs.
	rcvr _ stack pop.
	[nArgs=0[args_false]
	 nArgs=1[args_stack pop]
	 args _ Vector new: nArgs.
	 for i from: nArgs to: 1 by: 1 do
		[argsi _ stack pop]].
	stack next_ ParsedMessage new rcvr: rcvr op: op args: args.
	p=breakPC[stack last hasPC]]\gb36B

Macros\gbf5 
convertMacros: block sel: sel | macros compilerTemps vec loc i
	["replace statement patterns with corresponding macros when possible"
	macros _ (Vector new: 10) asStream.
	"for each temp, compilerTemps is false if it is a user temp, true if it is a
		compiler temp, and nil if not yet known"
	compilerTemps _ Vector new: temps length.
	for i to: sel numArgs do
		[compilerTempsi _ false].
	block findMacros: macros compilerTemps: compilerTemps.
	"insert macros in reverse order to keep indices from being messed up"
	vec _ macros contents.
	for i from: vec length-1 to: 1 by: 2 do
		[vecinil[]
		veci insertMacro: vec(i+1) decompiler: self].
	"set names of compiler temps to empty string"
	for i to: temps length do
		[compilerTempsitrue[tempsi _ '']]]\gb30B36i66I41i117I160i67I138i43I

Printing\gbf5 
printPattern: sel on: strm | i n keywords
	[n_sel numArgs.
	[n=0[strm append: sel; space  "unary"]
	 keywords_sel keywords.
	 for i to: keywords length do
		[strm append: keywordsi; space; append: tempsi; space]].
	n=(method5)[]
	strm append: '| '.   "temps beyond args"
	for i from: n+1 to: method5 do [strm append: tempsi; space]]\gb27B65i5I162i17I
quickCode: sel class: class | t strm
	[method length=2[sel asParagraph makeBoldPattern]
	method length=5
		[t _ method5.
		strm _ Stream default.
		strm append: sel; append: ' ['; append: class instvars(t+1); append: ']'.
		strm contents asParagraph makeBoldPattern]
	'undeciperable method' asParagraph]\gb28B
\g
SystemOrganization classify: Decompiler under: 'Compiler'.\g

"Generator"l15000z20000\gbf5 
Class new title: 'Generator'
	subclassof: Object
	fields: 'literals nTemps maxTemp local environment parser supered root requestor sourceStream sourceParagraph'
	declare: '';
	sharing: ByteCodes;
	asFollows\gbf5 

I generate code parsed by parser.  The symbol tables I use are local and environment.  The run-time needs of the code are recorded in literals, nTemps, and maxTemp.  If a message was passed to super, then supered is true.  I remember my root context to abort in case of error.\gi

Services\gbf5 
compile: sourceParagraph in: class under: category notifying: requestor | selector
	[user displayoffwhile
		[sourceStream _ sourceParagraph asStream.
		selector _ self compileIn: class
			[class organization classify: selector under: category]].
	selector]\gb72B
evaluate: sourceStream in: context to: receiver notifying: requestor
		| method nvars value tframe
	[method _ user displayoffwhile [self evaluateIn: context to: receiver].
	roottruefalse [method] "compilation failed, return false or corrected value"
	nvars _ nTemps.
	context "frame copy here because interpret loses control"
		[tframe _ context tempframe(1 to: nvars) copyto: (Vector new: method3).
		value _ context interpret: method with: tframe.
		tframe(1 to: nvars) copyto: context tempframe.
		value]
	Context new have: receiver interpret: method]\gb71B130i53I28i49I

Errors\gbf5 
abortWith: errorString | mySender
	[[WhatFlag [user notify: errorString]].
	mySender _ thisContext swapSender: root sender.
	root sender _ nil. root _ nil. parser terminate.
	mySender release. mySender _ nil.
	user restoredisplay.
	requestor notify: errorString at: sourceStream position in: sourceStream]
"Parser notify"\gb23B285i
notify: errorString
	[parser notify: errorString]
"ParsedObjectReference remote"\gb21B29i
terminate
	[root _ nil]
"Parser terminate"\gb11B13i

Code generation\gbf5 
compileIn: class
		| block method nargs selector primitive
	[parser _ Parser new. root _ thisContext. parser from: sourceStream to: self.
	self initSymbols: class.
	block _ ParsedBlock default.
	selector _ parser pattern: block. nargs _ nTemps.
	parser temporaries: block. primitive _ parser body: block.
	parser mustBeDone. parser _ nil.
	block mustReturn: true "defaults to self".
		[method _ [primitive=0 and nargs=0 [block quickCode] false] []
		method _ self generate: block in: class.
		method2 _ primitive; 4 _ nargs].
	class install: selector method: method literals: literals
		code: [sourceParagraph is: Paragraph [sourceParagraph]
			sourceStream asArray] backpointers: nil.
	[HuhFlag [Huh_nil. Huh _ (self decompile: method onto: Stream default) contents. HuhFlag_false]].
	selector]
"compile"\gb19B344i19I423i
decompile: method onto: s
	[method length<6
		[s append: 'Quick code: '; append: method asBytes. s]
	s print: method4; append: ' args; ';
		print: method5; append: ' temps; ';
		print: (method3) - (method5); append: ' stack; ';
		print: (method6) -6 /2; append: ' literals; '.
	[(method2) > 0 [s append: ' primitive: '; print: method2; append: ';']].
	s print: method length; append: ' bytes total.'; cr.
	method2 = 40 [s]
	self decompileBytes: method onto: s]\gb27B
decompileBytes: method onto: s
		| dict x i c m t
	[dict _ Dictionary new init: 64.
	dict insertall: ((128 to: 131) copy, 125 concat: (144 to: 175) copy)
		with: (
			'_^' '_' '^' '' 'end'
			'jmp1' 'jmp2' 'jmp3 ' 'jmp4' 'jmp5' 'jmp6' 'jmp7' 'jmp8'
			'bfp1' 'bfp2' 'bfp3 ' 'bfp4' 'bfp5' 'bfp6' 'bfp7' 'bfp8'
			'jmp' 'jmp' 'jmp' 'jmp' 'jmp' 'jmp' 'jmp' 'jmp'
			'bfp' 'bfp' 'bfp' 'bfp' 'bfp' 'bfp' 'bfp' 'bfp').
	for x from: local contents do
		[i_localx. t _ i land: 255.
		[i>255 and t<16 [i_((i lshift: 8)-1 lshift: 4) + t]].
		dict insert: i with: x].
	for x from: stdSelectors contents do
		[dict insert: stdSelectorsx with: [x is: Integer [x inString] x]].
	for i to: 5 do [dict insert: toLoadConst+i-1 with: ('1' '0' '1' '2' '10')i].
	for t from: (m _ (method(method6 +1 to: method length)) asStream) do
		[[ttoLoadFieldLong and ttoSendLitLong [t_((t-0207) lshift: 8)+ m next]].
		 [c _ dict lookup: t [s append: c] s append: '#'. s append: t base8].
		 s space.
		 t < toLongJmp [] t  0260 []
		 s print: t\8 -4 *256 + m next; space].
	s cr.
	s]\gb33B
evaluateIn: context to: receiver
		| block method class nvars
	[ "If context is false, receiver will evaluate in top level"
	block _ ParsedBlock default.
	parser _ Parser new. root _ thisContext.
	parser from: sourceStream to: self.
	[context
		[self initSymbols: (class _ context mclass).
		context variableNamesInto: self with: ParsedBlock default.
		nvars _ nTemps.
		root _ thisContext. "because variableNamesInto nil'ed it"]
	 self initSymbols: (class _ receiver class)].
	parser temporaries: block; statements: block; mustBeDone. parser _ nil.
	block mustReturn: false "returns last value".
	method _ self generate: block in: class.
	[HuhFlag [Huh_nil. Huh _ (self decompile: method onto: Stream default) contents. HuhFlag_false]].
	root _ true. "to signify success"
	nTemps _ nvars.
	method]
"evaluate"\gb35B30i58I269i37I147i20I158i20I28i
generate: block in: class
		| header method code lit stack
	[[(lit _ literals find: nil)>0 [literals _ (literals(1 to: lit-1)) copy]].
	[supered [literals _ literals, (Smalltalk ref: class title unique)]].
	header _ 6 + (2* literals length).
	code _ (method _ String new: header + block sizeForValue) asStream.
	code
		next _ 0; next _ 0; next _ 0;
		next _ 0; next _ maxTemp; next _ header.
	for lit from: literals do
		[code next _ lit PTR lshift: 8; next _ lit PTR land: 0377].
	stack _ ParseStack init.
	block emitForValue: code on: stack.
	[stack position1 [user notify: 'Compiler stack discrepancy']].
	[code positionmethod length [user notify: 'Compiler code size discrepancy']].
	method3 _ maxTemp + stack length.
	method] "compile|evaluate"\gb28B715i

Parse tree\gbf5 
assignment: var expr: expr
	[ParsedAssignment new var: var expr: expr]
"Parser expression"\gb28B44i
block
	[ParsedBlock default]
"Parser primary|Parser alternatives"\gb7B23i
evalKeyword: arg
	[arg]
"Parser keywordMessage"\gb18B7i
ifExpr: ifExpr thenExpr: thenExpr elseExpr: elseExpr
	[ParsedConditional new ifExpr: ifExpr thenExpr: thenExpr elseExpr: elseExpr]
"ifthen...|Parser alternatives"\gb54B78i
keywordMessage: rcvr selector: sel args: args
	[sel='and'
		[ParsedConjunct new left: rcvr right: args local];
	  = 'or'
		[ParsedDisjunct new left: rcvr right: args local]
	self rcvr: rcvr selector: sel args: (args remote: self)]
"Parser keywordMessage"\gb47B191i
noEvalKeyword: arg
	[arg asRemoteCode: self]
"Parser keywordMessage"\gb20B26i
nullStatement: block
	[block next _ toLoadNil. block]
"ifthen|Parser statements"\gb22B33i
rcvr: rcvr selector: sel args: args
	[[rcvrtoSuper [supered_true]].
	ParsedMessage new rcvr: rcvr op: (self encodeSel: sel) args: args]
"loop|keywordMessage|Parser binaryMessage|Parser unaryMessage"\gb37B102i
receivingVar: expr | rcvr var "who in expr is cascade recipient"
	[rcvr _ expr emittedReceiver
		[var _ rcvr emittedVariable [var]
		var _ self newTemp. "if a non-variable, compute it just once"
		expr emittedReceiver _ ParsedAssignment new var: var expr: rcvr.
		var]
	parser notify: 'MAY ONLY FOLLOW A MESSAGE']
"Parser cascade"\gb19B11i34I92i41I121i
variable: name
		| var global ref unq
	[var _ local lookup: name [var]
	[unq _ name hasBeenUniqued
		[for global from: environment do
			[ref _ global lookupRef: unq
				[codeLoadLitInd + (self litIndex: ref)]]]].
	requestor interactive
		[parser notify: 'Smalltalk declare: ' + name + ' as: nilTO DECLARE GLOBAL']
	user show: ' (' + name + ' is Undeclared) '.
	unq _ name unique.
	Undeclared declare: unq.
	codeLoadLitInd + (self litIndex: (Undeclared ref: unq))]
"Parser expression|Parser primary"\gb17B460i

Macros\gbf5 
for: var from: startMinus1 to: stop do: ritual on: block | temp
	[temp _ self newTempForMacro.
	"temp_stop. var_startMinus1. while temp(var _ 1+var) do ritual"
	block next _ ParsedAssignment new var: temp expr: stop;
		next _ ParsedAssignment new var: var expr: startMinus1;
		next _ ParsedLoop new
			whileExpr:
				(ParsedMessage new rcvr: temp op: toGeq args:
					(ParsedAssignment new var: var
						expr: (ParsedMessage new rcvr: toLoad1 op: toPlus args: var)))
			doExpr: ritual]
"for...todoargs"\gb57B39i66I328i
forfromdo: block args: args | var sequence ritual strm
	[var _ (args1) local. sequence _ args2. ritual _ (args3) local.
	strm _ self newTempForMacro.
	"strm _ sequence asStream. while (var _ strm next) do ritual"
	block next _ ParsedAssignment new var: strm
			expr: (ParsedMessage new rcvr: sequence op: toAsStream args: false);
		next _ ParsedLoop new
			whileExpr:
				(ParsedAssignment new var: var
					expr: (ParsedMessage new rcvr: strm op: toNext args: false))
			doExpr: ritual]
"macro (perform)"\gb28B126i63I276i
forfromtobydo: block args: args
	["for var from: (start to: stop by: step) do ritual"
	args2 _ self rcvr: args2 selector: 'to:by:' args: (args(3 to: 4)) copy.
	self forfromdo: block args: (args(1 2 5)) copy]
"macro (perform)"\gb33B1i53I128i
forfromtodo: block args: args
	[self for: (args1) local
		from: (ParsedMessage new rcvr: args2 op: toMinus args: toLoad1)
		to: args3
		do: (args4) local
		on: block]
"macro (perform)"\gb31B140i
fortodo: block args: args
	[self for: (args1) local
		from: toLoad0
		to: args2
		do: (args3) local
		on: block]
"macro (perform)"\gb27B89i
ifthen: block args: args
	[block next _ self ifExpr: (args1) local thenExpr: (args2) local elseExpr: (self nullStatement: ParsedBlock default)]
"macro (perform)"\gb26B120i
ifthenelse: block args: args
	[block next _ self ifExpr: (args1) local thenExpr: (args2) local elseExpr: (args3) local]
"macro (perform)"\gb30B93i
macro: block selector: sel args: args
		| special
	[special _ inLineMsgs lookup: sel
		[self perform: special with: block with: args]
	Context canunderstand: sel unique
		[block next _ self rcvr: toLoadThisCtxt selector: sel args: (args remote: self)]
	false]
"Parser keywordMessage"\gb40B223i
untildo: block args: args
	[block next _ ParsedLoop new whileExpr: (ParsedNegation new rcvr: (args1) local op: toEq args: toLoadFalse) doExpr: (args2) local]
"macro (perform)"\gb27B133i
whiledo: block args: args
	[block next _ ParsedLoop new whileExpr: (args1) local doExpr: (args2) local]
"macro (perform)"\gb27B79i

Table maintenance\gbf5 
balance
	[nTemps]
"Parser cascade"\gb9B10i
comment: s
"Class fieldNamesInto"\gb11Bi
contents
"Class fieldNamesInto"\gb9Bi
declaration: block name: name asArg: asArg
		| permVar tempVar
	[tempVar _ self newTemp.
	permVar _ local lookup: name 
		[asArg and permVar isField
			[block next _ ParsedAssignment new var: permVar expr: tempVar]
		parser notify: 'NAME ALREADY IN USE']
	local insert: name with: tempVar]
"Parser declaration|temporaries"\gb45B248i
encodeSel: sel
		| code
	[code _ stdSelectors lookup: sel [code]
	codeSendLit+ (self litIndex: [sel classInteger [UST1(sel+1)] sel unique])]
"rcvr|ParsedFieldReference remote|ParsedRemote remote"\gb17B130i
identifier: s
	[local insert: s with: (nTemps _ nTemps + 1)]
"Class fieldNamesInto"\gb15B46i
initSymbols: class | s
	[environment _ class wholeEnvironment, Smalltalk.
	local _ Dictionary new copyfrom: stdPrimaries.
	nTemps _ codeLoadField-1.
	for s from: class instvars do
		[local insert: s with: (nTemps _ nTemps + 1)].
	nTemps _ maxTemp _ 0. literals _ Vector new: 123. supered _ false]
"compile|evaluate"\gb24B158b2B115i
juggle | oldTemps
	[oldTemps _ maxTemp. maxTemp _ nTemps. oldTemps]
"Parser macro"\gb7B62i
literal: x  | i
	[[x classInteger [0(i_(1 0 1 2 10) find: x) [toLoadConst+i-1]]].
	codeLoadLit + (self litIndex: x)]
"Parser primary|ParsedFieldReference remote"\gb12B113i
litIndex: oop  | i t
	[for i to: 123 do
		[(t _ literalsi)nil [literalsi_oop. i-1]
		t classoop class [t sameAs: oop [i-1]]].
	parser notify: 'MORE THAN 123 LITERALS REFERENCED']
"encodeSel|literal"\gb15B175i
newTemp
	[(nTemps _ nTemps+1) > maxTemp and (maxTemp _ nTemps) > 256
		[parser notify: 'MORE THAN 256 TEMPS REQUIRED']
	codeLoadTemp + nTemps-1]
"receivingVar|declaration"\gb9B139i
newTempForMacro "juggle arranged that maxTemp are needed by args of macro"
	[nTemps _ maxTemp. self newTemp]
"forfromdo|forfromtodo"\gb16Bi58I36i
separator: c
"Class fieldNamesInto"\gb13Bi
trailer: s
"Class fieldNamesInto"\gb11Bi
unbalance: nTemps
"Parser cascade"\gb18Bi
unjuggle: oldTemps
	[maxTemp _ oldTemps max: maxTemp]
"Parser macro"\gb20B34i
\g
SystemOrganization classify: Generator under: 'Compiler'.\g

"ParsedAssignment"l15000z20000\gbf5 
Class new title: 'ParsedAssignment'
	subclassof: Object
	fields: 'var expr elide'
	declare: '';
	sharing: ByteCodes;
	asFollows\gbf5 

I am a node in a compiler parse tree.  I represent an assignment of an expression to a variable.\gi

Initialization\gbf5 
var: var expr: expr\gb

Code generation\gbf5 
emitForEffect: code on: stack
	[expr emitForValue: code on: stack. stack pop: 1.
	elide ["var begins the next statement" code next _ toSmash]
	code next _ toSmashPop.
	var emitBytes: code]\gb31B59i31I
emitForValue: code on: stack
	[expr emitForValue: code on: stack.
	code next _ toSmash.
	var emitBytes: code]\gb30B
emittedVariable
	[var]\gb17B
firstPush
	[expr firstPush]\gb11B
sizeForEffect: nextPush
	[expr sizeForValue + 1 + [elide _ nextPushvar [0] var sizeForValue]]\gb25B
sizeForValue
	[expr sizeForValue + 1 + var sizeForValue]\gb14B

Miscellaneous\gbf5 
printon: s
	[s append: '('; print: var; append: '_'; print: expr; append: ')']\gb12B

Decompiling\gbf5 
expr [expr]\gb5B
findMacros: macros compilerTemps: compilerTemps
	[var findMacros: macros compilerTemps: compilerTemps.
	expr findMacros: macros compilerTemps: compilerTemps]\gb49B
isForFromInit: loop | cond b nextMess
	["return true if I could be the first initialization statement for a 
		for from: loop."
	(expr isnt: ParsedMessage) or expr optoAsStream[false]
	loop isnt: ParsedLoop[false]
	b _ loop whileExpr.
	(b isnt: ParsedBlock) or b position2[false]
	b1 isnt: ParsedAssignment[false]
	nextMess _ (b1) expr.
	nextMess isnt: ParsedMessage[false]
	nextMess rcvrvar or nextMess optoNext[false]
	true]	\gb20B21i70u10U6I
isForFromToInit: start loop: loop | b incr test
	["return true if I could be the first initialization statement for a 
		for to: do or a for from: to: do loop"
	"I should set the upper bound, start should set the var to start-1"
	(start isnt: ParsedAssignment) or (loop isnt: ParsedLoop)[false]
	 [start exprtoLoad0[]
		start expr isnt: ParsedMessage[false]
		start expr optoMinus or start expr argstoLoad1[false]].
	"the loop condition should increment the var and compare it with the 
		upper bound"
	b _ loop whileExpr.
	(b isnt: ParsedBlock) or b position2[false]
	incr _ b1.
	incr isnt: ParsedAssignment[false]
	incr varstart var[false]
	(incr expr isnt: ParsedMessage) or incr expr optoPlus[false]
	incr expr rcvrtoLoad1 or incr expr argsstart var[false]
	test _ b2.
	test isnt: ParsedMessage[false]
	(test rcvrvar or test optoGeq) or test argsincr var[false]
	true]\gb34B17i70u12U6u18U5I4i65I203i82I
printon: strm indent: level precedence: p forValue: v decompiler: decompiler
	[ [p>1[strm append: '(']].
	var printon: strm indent: level precedence: 1
			forValue: true decompiler: decompiler.
	strm append: ' _ '.
	expr printon: strm indent: level+2 precedence: 1
			forValue: true decompiler: decompiler.
	p>1[strm append: ')']]\gb78B
var [var]\gb4B
\g
SystemOrganization classify: ParsedAssignment under: 'Compiler'.\g

"ParsedBlock"l15000z20000\gbf5 
Class new title: 'ParsedBlock'
	subclassof: Stream
	fields: 'returns'
	declare: '';
	sharing: ByteCodes;
	asFollows\gbf5 

I am a stream to collect the statements of a block and then to become a node in a compiler parse tree.\gi

Initialization\gbf5 
default
	[limit _ 1. array _ Vector new: 1. position _ 0. returns _ false]\gb9B
doesReturn
	[returns _ true]\gb12B
mustReturn: fromMethod
	[returns []
	[fromMethod
		[position>0 and (arrayposition) emitsLoad [arrayposition _ toLoadSelf] self next _ toLoadSelf]].
	self doesReturn]\gb24B

Code generation\gbf5 
emitForEffect: code on: stack
	[returns [self emitForValue: code on: stack. stack pop: 1]
	self emitExceptLast: code on: stack.
	(arrayposition) emitForEffect: code on: stack]\gb31B
emitForValue: code on: stack
	[self emitExceptLast: code on: stack.
	(arrayposition) emitForValue: code on: stack.
	returns [code next _ toReturn]]\gb30B
firstPush
	[(array1) firstPush]\gb11B
sizeForEffect: nextPush
	[returns [self sizeForValue]
	self sizeExceptLast + ((arrayposition) sizeForEffect: nextPush)]\gb25B
sizeForTruth: trueSkip falsity: falseSkip
	[returns [self sizeForValue]
	self sizeExceptLast + (arrayposition sizeForTruth: trueSkip falsity: falseSkip)]\gb43B
sizeForValue
	[self sizeExceptLast + (arrayposition) sizeForValue + [returns [1] 0]]\gb14B

Miscellaneous\gbf5 
printon: s | i
	[s append: '['.
	for i to: position-1 do [s print: (arrayi); append: '. '].
	[returns [s append: '']].
	[position>0 [s print: (arrayposition)]].
	s append: ']']\gb11B
quickCode | t v
	[position=1 and (returns and (v_array1) emitsLoad)
		[v=toLoadSelf [t _ String new: 2. t1_0; 2_1. t]
		v isField
			[t _ String new: 5. t1_0; 2_40; 3_0; 4_0; 5_v. t]
		false]
	false]\gb10B
returns
	[returns]\gb9B

Private\gbf5 
emitExceptLast: code on: stack
		| i
	[for i to: position-1 do [(arrayi) emitForEffect: code on: stack]]\gb33B
sizeExceptLast
		| i next nextPush size
	[size _ 0. next _ arrayposition.
	for i to: position-1 do
		[nextPush _ next firstPush. next _ array(position-i).
		size _ size + (next sizeForEffect: nextPush)].
	size]\gb17B

Decompiling\gbf5 
findMacros: macros compilerTemps: compilerTemps | i s t
"Look for for statements.  If one of my statements is the init statement for a for, append myself and the index of that statement to the stream macros.  Mark its compiler-generated temp.  If the temp is subsequently used before being re-assigned, the pattern can't be a for after all, and will be deleted from macros."
	[for i to: position do
		[s _ arrayi.
		(s isnt: ParsedAssignment) or
				(s var<codeLoadTemp or s var>(codeLoadTemp+255))  "not a for"
			[s findMacros: macros compilerTemps: compilerTemps]
		t _ s var-codeLoadTemp+1.
		i(position-2) and (s isForFromToInit: array(i+1) loop: array(i+2))
			[macros next_ self; next_ i.
			compilerTempst _ true.
			"check other parts of the for"
			s expr findMacros: macros compilerTemps: compilerTemps.
			array(i+1) findMacros: macros compilerTemps: compilerTemps.
			(array(i+2)) doExpr findMacros: macros compilerTemps: compilerTemps.
			i _ i+2]
		i(position-1) and (arrayi isForFromInit: array(i+1))
			[macros next_ self; next_ i.
			compilerTempst _ true.
			s expr findMacros: macros compilerTemps: compilerTemps.
			(array(i+1)) doExpr findMacros: macros compilerTemps: compilerTemps.
			i _ i+1]
		s findMacros: macros compilerTemps: compilerTemps]]\gb48B9i9u3U66u3U62u6U120u3U37u6U1I134i6u3IU222i28I
insertMacro: loc decompiler: decompiler | macro n i
	["create a parsed for loop, and replace the old statements by it"
	macro _ ParsedForLoop new block: self loc: loc decompiler: decompiler.
	arrayloc _ macro.
	n _ macro nStatements.
	for i from: loc+n to: position do
		[array(i-n+1) _ arrayi].
	position _ position-n+1]\gb40B15i62I
printon: strm indent: level precedence: p forValue: v decompiler: decompiler | i
	["ignore precedence, since the block is enclosed in brackets"
	position=0[strm append: '[]' ]
	strm append: '['.
	for i to: position-1 do
		[arrayi printon: strm indent: level precedence: 0
			forValue: false decompiler: decompiler.
		strm append: '.'; crtab: level].
	 [returns[strm append: '']].
	arrayposition printon: strm indent: level precedence: 0
		forValue: (returns or v) decompiler: decompiler.
	strm append: ']' ]\gb77B7i58I

As yet unclassified\gbf5 
emitForTruth: trueSkip falsity: falseSkip into: code on: stack
	[returns [self emitForValue: code on: stack]
	self emitExceptLast: code on: stack.
	(arrayposition) emitForTruth: trueSkip falsity: falseSkip into: code on: stack]\gb64B
\g
SystemOrganization classify: ParsedBlock under: 'Compiler'.\g

"ParsedConditional"l15000z20000\gbf5 
Class new title: 'ParsedConditional'
	subclassof: Object
	fields: 'ifExpr thenExpr elseExpr thenSize elseSize jmpSize'
	declare: '';
	asFollows\gbf5 

I am a node in a compiler parse tree.  I represent a condition and two alternatives.\gi

Initialization\gbf5 
ifExpr: ifExpr thenExpr: thenExpr elseExpr: elseExpr\gb

Code generation\gbf5 
emitForEffect: code on: stack
	[ifExpr emitForValue: code on: stack.
	thenSize emitBfp: code on: stack.
	thenExpr emitForEffect: code on: stack.
	[jmpSize>0 [elseSize emitJmp: code on: stack]].
	elseExpr emitForEffect: code on: stack]\gb31B
emitForValue: code on: stack
	[ifExpr emitForValue: code on: stack.
	thenSize emitBfp: code on: stack.
	thenExpr emitForValue: code on: stack.
	stack pop: 1.
	[jmpSize>0 [elseSize emitJmp: code on: stack]].
	elseExpr emitForValue: code on: stack]\gb30B
firstPush
	[ifExpr firstPush]\gb11B
sizeForEffect: nextPush
	[elseSize _ elseExpr sizeForEffect: nextPush.
	jmpSize _ [thenExpr returns [0] elseSize jmpSize].
	thenSize _ (thenExpr sizeForEffect: 1) + jmpSize.
	ifExpr sizeForValue + thenSize bfpSize + thenSize + elseSize]\gb25B
sizeForValue
	[elseSize _ elseExpr sizeForValue.
	jmpSize _ [thenExpr returns [0] elseSize jmpSize].
	thenSize _ thenExpr sizeForValue + jmpSize.
	ifExpr sizeForValue + thenSize bfpSize + thenSize + elseSize]\gb14B

Miscellaneous\gbf5 
printon: s
	[s append: 'if '; print: ifExpr; append: 'then '; print: thenExpr; append: 'else '; print: elseExpr]\gb12B
returns
	[thenExpr returns and elseExpr returns]\gb9B

Decompiling\gbf5 
findMacros: macros compilerTemps: compilerTemps
	[ifExpr findMacros: macros compilerTemps: compilerTemps.
	thenExpr findMacros: macros compilerTemps: compilerTemps.
	elseExpr findMacros: macros compilerTemps: compilerTemps]\gb49B
printon: strm indent: level precedence: p forValue: v decompiler: decompiler
		| pos char
	[ifExpr printon: strm indent: level precedence: 0 
		forValue: true decompiler: decompiler.
	strm append: ' '.
	[thenExpr position>1 or (thenExpr1 is: ParsedConditional)
		[strm crtab: level+1] strm space].
	thenExpr printon: strm indent: level+1 precedence: 0 
		forValue: v decompiler: decompiler.
	elseExpr position=1 and elseExpr lastnil[]
	strm crtab: level.
	"Kludge!! Delete brackets around else block"
	pos_strm position.  char_strm pop.
	elseExpr printon: strm indent: level precedence: 0 
		forValue: v decompiler: decompiler.
	strm skip: 1.  strmpos_char]\gb79B385i42I
\g
SystemOrganization classify: ParsedConditional under: 'Compiler'.\g

"ParsedConjunct"l15000z20000\gbf5 
Class new title: 'ParsedConjunct'
	subclassof: Object
	fields: 'left right rightSize'
	declare: '';
	sharing: ByteCodes;
	asFollows\gbf5 

I am a node in a compiler parse tree.  I represent (left and right) and try to optimize the code generation thereof.\gi

Initialization\gbf5 
left: left right: right\gb

Code generation\gbf5 
emitForEffect: code on: stack
	[left emitForValue: code on: stack.
	rightSize emitBfp: code on: stack.
	right emitForEffect: code on: stack]\gb31B
emitForTruth: trueSkip falsity: falseSkip into: code on: stack
	[left emitForTruth: 0 falsity: rightSize+falseSkip into: code on: stack.
	right emitForTruth: trueSkip falsity: falseSkip into: code on: stack]
\gb64B
emitForValue: code on: stack
	[left emitForValue: code on: stack.
	rightSize emitBfp: code on: stack.
	right emitForValue: code on: stack.
	1 emitJmp: code on: stack.
	code next _ toLoadFalse]\gb30B
firstPush
	[left firstPush]\gb11B
sizeForEffect: nextPush
	[rightSize _ right sizeForEffect: 1.
	left sizeForValue + rightSize bfpSize + rightSize]\gb25B
sizeForTruth: trueSkip falsity: falseSkip
	[rightSize _ right sizeForTruth: trueSkip falsity: falseSkip.
	(left sizeForTruth: 0 falsity: rightSize+falseSkip) + rightSize]\gb43B
sizeForValue
	[rightSize _ right sizeForValue + 1.
	left sizeForValue + rightSize bfpSize + rightSize + 1]\gb14B

Miscellaneous\gbf5 
emittedReceiver
	[left]\gb17B
emittedReceiver _ left\gb
printon: s
	[s append: '('; print: left; append:  ' and '; print: right; append: ')']\gb12B

Decompiling\gbf5 
findMacros: macros compilerTemps: compilerTemps
	[left findMacros: macros compilerTemps: compilerTemps.
	right findMacros: macros compilerTemps: compilerTemps]\gb49B
printon: strm indent: level precedence: p forValue: v decompiler: decompiler
	[ [p2[strm append: '(']].
	left printon: strm indent: level precedence: 2
		forValue: true decompiler: decompiler.
	strm append: ' and '.
	right printon: strm indent: level precedence: 2
		forValue: v decompiler: decompiler.
	p2[strm append: ')']]\gb78B
\g
SystemOrganization classify: ParsedConjunct under: 'Compiler'.\g

"ParsedDisjunct"l15000z20000\gbf5 
Class new title: 'ParsedDisjunct'
	subclassof: Object
	fields: 'left right rightSize'
	declare: '';
	sharing: ByteCodes;
	asFollows\gbf5 

I am a node in a compiler parse tree.  I represent (left or right) and try to optimize the code generation thereof.\gi

Initialization\gbf5 
left: left right: right\gb

Code generation\gbf5 
emitForEffect: code on: stack
	[left emitForValue: code on: stack.
	rightSize jmpSize emitBfp: code on: stack.
	rightSize emitJmp: code on: stack.
	right emitForEffect: code on: stack]\gb31B
emitForTruth: trueSkip falsity: falseSkip into: code on: stack
	[left emitForTruth: rightSize+trueSkip falsity: 0 into: code on: stack.
	right emitForTruth: trueSkip falsity: falseSkip into: code on: stack]\gb64B
emitForValue: code on: stack
	[left emitForValue: code on: stack.
	(1 + rightSize jmpSize) emitBfp: code on: stack.
	code next _ toLoadTrue.
	rightSize emitJmp: code on: stack.
	right emitForValue: code on: stack]\gb30B
firstPush
	[left firstPush]\gb11B
sizeForEffect: nextPush
	[rightSize _ right sizeForEffect: 1.
	left sizeForValue + 1 + rightSize jmpSize + rightSize]\gb25B
sizeForTruth: trueSkip falsity: falseSkip
	[rightSize _ right sizeForTruth: trueSkip falsity: falseSkip.
	(left sizeForTruth: rightSize+trueSkip falsity: 0) + rightSize]\gb43B
sizeForValue
	[rightSize _ right sizeForValue.
	left sizeForValue + 2 + rightSize jmpSize + rightSize]\gb14B

Miscellaneous\gbf5 
emittedReceiver
	[left]\gb17B
emittedReceiver _ left\gb
printon: s
	[s append: '('; print: left; append: ' or '; print: right; append: ')']\gb12B

Decompiling\gbf5 
findMacros: macros compilerTemps: compilerTemps
	[left findMacros: macros compilerTemps: compilerTemps.
	right findMacros: macros compilerTemps: compilerTemps]\gb49B
printon: strm indent: level precedence: p forValue: v decompiler: decompiler
	[ [p2[strm append: '(']].
	left printon: strm indent: level precedence: 2
		forValue: true decompiler: decompiler.
	strm append: ' or '.
	right printon: strm indent: level precedence: 2
		forValue: v decompiler: decompiler.
	p2[strm append: ')']]\gb78B
\g
SystemOrganization classify: ParsedDisjunct under: 'Compiler'.\g

"ParsedFieldReference"l15000z20000\gbf5 
Class new title: 'ParsedFieldReference'
	subclassof: Object
	fields: 'var toLoadVar toLoadFieldReference toObjectOffset'
	declare: '';
	sharing: ByteCodes;
	asFollows\gbf5 

I am a node in a compiler parse tree.  I represent a remote argument which is a reference to a method or instance variable.\gi

Initialization\gbf5 
var: var\gb

Code generation\gbf5 
emitForValue: code on: stack
	[([var isField [toLoadSelf] toLoadTempframe]) emitForValue: code on: stack.
	toLoadVar emitForValue: code on: stack.
	toLoadFieldReference emitForValue: code on: stack.
	code next _ toNew. toObjectOffset emitBytes: code..
	stack pop: 2]\gb30B
local
	[var]\gb7B
remote: generator
	[toLoadVar _ generator literal: (var land: 0177)+1.
	toLoadFieldReference _ generator literal: FieldReference.
	toObjectOffset _ generator encodeSel: object:offset:]\gb19B
sizeForValue
	[ 2 + toLoadVar sizeForValue +
		toLoadFieldReference sizeForValue + toObjectOffset sizeForValue]\gb14B

Miscellaneous\gbf5 
printon: s
	[s append: 'FLD=> '; print: var]\gb12B

Decompiling\gbf5 
findMacros: macros compilerTemps: compilerTemps
	[var findMacros: macros compilerTemps: compilerTemps]\gb49B
printon: strm indent: level precedence: p forValue: v decompiler: decompiler
	[var printon: strm indent: level precedence: p
			forValue: true decompiler: decompiler]\gb78B
\g
SystemOrganization classify: ParsedFieldReference under: 'Compiler'.\g

"ParsedForLoop"l15000z20000\gbf5 
Class new title: 'ParsedForLoop'
	subclassof: Object
	fields: 'var source start stop step doExpr nStatements'
	declare: '';
	sharing: ByteCodes;
	asFollows\gbf5 

I represent a for loop.  I am used only by the decompiler, not the compiler.\gi

Decompiling\gbf5 
block: block loc: loc decompiler: decompiler | init1 init2 loop s
	["loc should point to the initialization statement for a for loop in block"
	init1 _ blockloc.
	block(loc+1) is: ParsedLoop
		[nStatements _ 2.
		loop _ block(loc+1).
		var _ loop whileExpr2.  doExpr _ loop doExpr.
		"init statement creates a stream ... see if its an interval"
		s _ init1 expr rcvr.
		(s is: ParsedMessage) and (decompiler selector: s op)to:by: 
			[start _ s rcvr.
			stop _ s args1.  step _ s args2]
		source _ s]
	"must be a forfrom:to:do.  init1 will set up the limit, and init2 will
		initialize var to start-1"
	nStatements _ 3.
	init2 _ block(loc+1).  loop _ block(loc+2).
	var _ init2 var.
	start _ [init2 exprtoLoad0	[toLoad1] init2 expr rcvr].
	stop _ init1 expr.  step _ toLoad1.
	doExpr _ loop doExpr]\gb45B24i55u3U14I149i58I166i28u5U28u5U19u3U11I
nStatements
	["return the number of statements in my expanded form"
	nStatements]\gb13B2i51I
printon: strm indent: level precedence: p forValue: v decompiler: decompiler
	[sourcenil
		[strm append: 'for '.
		var printon: strm indent: level precedence: 2
			forValue: true decompiler: decompiler.
		 [starttoLoad1[] strm append: ' from: '.
			start printon: strm indent: level precedence: 2
				forValue: true decompiler: decompiler].
		strm append: ' to: '.
		stop printon: strm indent: level precedence: 2
			forValue: true decompiler: decompiler.
		 [steptoLoad1[] strm append: ' by: '.
			step printon: strm indent: level precedence: 2
				forValue: true decompiler: decompiler].
		strm append: ' do'; crtab: level+1.
		doExpr printon: strm indent: level+1 precedence: 0 
			forValue: false decompiler: decompiler]
	"source is a stream"
	strm append: 'for '.
	var printon: strm indent: level precedence: 2
		forValue: true decompiler: decompiler.
	strm append: ' from: '.
	source printon: strm indent: level precedence: 2
		forValue: true decompiler: decompiler.
	strm append: ' do'; crtab: level+1.
	doExpr printon: strm indent: level+1 precedence: 0 
		forValue: false decompiler: decompiler]\gb78B657i18I
\g
SystemOrganization classify: ParsedForLoop under: 'Compiler'.\g

"ParsedLoop"l15000z20000\gbf5 
Class new title: 'ParsedLoop'
	subclassof: Object
	fields: 'whileExpr doExpr whileSize doSize'
	declare: '';
	sharing: ByteCodes;
	asFollows\gbf5 

I am a node in a compiler parse tree.  I represent that part of an in-line loop statement that can be expressed in the while-do form.\gi

Initialization\gbf5 
whileExpr: whileExpr doExpr: doExpr\gb

Code generation\gbf5 
emitForEffect: code on: stack
	["optimization removed to make things easier for decompiler --
	whileExpr emitForTruth: 0 falsity: doSize into: code on: stack."
	whileExpr emitForValue: code on: stack.
	doSize emitBfp: code on: stack.
	doExpr emitForEffect: code on: stack.
	0 - doSize - whileSize - doSize jmpSize emitJmp: code on: stack]\gb31B2i125I
emitForValue: code on: stack
	[self emitForEffect: code on: stack.
	toLoadNil emitForValue: code on: stack]\gb30B
firstPush
	[whileExpr firstPush]\gb11B
sizeForEffect: nextPush
	[doSize _ (doExpr sizeForEffect: 1) + 2.
	"whileSize _ whileExpr sizeForTruth: 0 falsity: doSize."
	whileSize _ whileExpr  sizeForValue.
	whileSize + doSize + doSize jmpSize]\gb25B44i54I
sizeForValue
	[(self sizeForEffect: 1) + 1]\gb14B

Miscellaneous\gbf5 
printon: s
	[s append: 'while '; print: whileExpr; append: 'do '; print: doExpr]\gb12B

Decompiling\gbf5 
doExpr [doExpr]\gb7B
findMacros: macros compilerTemps: compilerTemps
	[whileExpr findMacros: macros compilerTemps: compilerTemps.
	doExpr findMacros: macros compilerTemps: compilerTemps]\gb49B
printon: strm indent: level precedence: p forValue: v decompiler: decompiler
	[[whileExpr is: ParsedNegation
		[strm append: 'until '.
		whileExpr negated printon: strm indent: level precedence: 2
			forValue: true decompiler: decompiler]
	 strm append: 'while '.
	 whileExpr printon: strm indent: level precedence: 2
		forValue: true decompiler: decompiler].
	strm append: ' do'; crtab: level+1.
	doExpr printon: strm indent: level+1 precedence: 0 
		forValue: false decompiler: decompiler]\gb78B
whileExpr [whileExpr]\gb10B
\g
SystemOrganization classify: ParsedLoop under: 'Compiler'.\g

"ParsedMessage"l15000z20000\gbf5 
Class new title: 'ParsedMessage'
	subclassof: Object
	fields: 'rcvr op args "false if no args, Vector if many args" hasPC'
	declare: '';
	sharing: ByteCodes;
	asFollows\gbf5 

I am a node in a compiler parse tree.  I represent an expression consisting of a receiver (rcvr), a selector byte code (op), and an argument list (args) which is false for no arguments, a vector of parse trees for 2 or more arguments, or the argument parse tree for one argument.\gi

Initialization\gbf5 
hasPC [hasPC_ true]\gb6B
rcvr: rcvr op: op args: args
	[hasPC_ false.
	op=toEq and ((toLoadFalsercvr) or (toLoadFalseargs))
		[ParsedNegation new rcvr: rcvr op: op args: args]]\gb30B

Code generation\gbf5 
emitForEffect: code on: stack
	[self emitForValue: code on: stack. code next _ toPop. stack pop: 1]\gb31B
emitForValue: code on: stack
	[args emitForValue: code on: stack.
	rcvr emitForValue: code on: stack.
	[rcvrtoSuper [code next_rcvr]].
	op emitBytes: code. args argsOff: stack]\gb30B
firstPush
	[([args [args] rcvr]) firstPush]\gb11B
sizeForEffect: nextPush
	[self sizeForValue+1]\gb25B
sizeForValue
	[args sizeForValue + rcvr sizeForValue + op sizeForValue + [rcvrtoSuper [1] 0]]\gb14B

Miscellaneous\gbf5 
args [args]\gb5B
args_args\gb
emittedReceiver
	[rcvr]\gb17B
emittedReceiver _ rcvr\gb
op [op]\gb3B
printon: s
	[s append: '('; print: rcvr; space; print: op.
	[args [s space; print: args]].
	s append: ')']\gb12B
rcvr [rcvr]\gb5B

Decompiling\gbf5 
findMacros: macros compilerTemps: compilerTemps | vec a
	[vec _ [argsnil[()] args is: Vector[args] args inVector].
	for a from: vec do
		[a findMacros: macros compilerTemps: compilerTemps].
	rcvr findMacros: macros compilerTemps: compilerTemps]\gb48B
printon: strm indent: level precedence: p forValue: v decompiler: decompiler
		| sel keywords i parens myP vec char1
	[sel _ decompiler selector: op.
	myP _ [sel isinfix[3]; iskeyword[2]; isarrow[1] 4].
	"check if parens are needed"
	parens _ [myP<p or (p=2 and myP=2)].
	 [parens[strm append: '(']].
	char1_ strm position.
	rcvr printon: strm indent: level precedence: myP
			forValue: true decompiler: decompiler.
	 [myP=4[strm space; append: sel  "unary selector"]
	 keywords _ sel keywords.
	vec _ [argsnil[()] args is: Vector[args] args inVector].
	 for i to: keywords length do
		[strm space; append: keywordsi; space.
		veci printon: strm indent: level 
				precedence: [myP=3[4] myP]
				forValue: true decompiler: decompiler]].
	[hasPC[decompiler highlight: (char1+1 to: strm position+1)]].
	parens[strm append: ')']]\gb79B
\g
SystemOrganization classify: ParsedMessage under: 'Compiler'.\g

"ParsedNegation"l15000z20000\gbf5 
Class new title: 'ParsedNegation'
	subclassof: ParsedMessage
	fields: ''
	declare: '';
	sharing: ByteCodes;
	asFollows\gbf5 

I am a node in a compiler parse tree.  I am a parsed messsage in which the selector is  and one of the participants is false.\gi

Initialization\gbf5 
rcvr: rcvr op: op args: args\gb

Code generation\gbf5 
emitForTruth: trueSkip falsity: falseSkip into: code on: stack
	[([toLoadFalsercvr [args] rcvr]) emitForTruth: falseSkip falsity: trueSkip into: code on: stack]\gb64B
sizeForTruth: trueSkip falsity: falseSkip
	[([toLoadFalsercvr [args] rcvr]) sizeForTruth: falseSkip falsity: trueSkip]\gb43B

Miscellaneous\gbf5 
negated [toLoadFalsercvr[args] rcvr]\gb8B
printon: s
	[s append: '(negation)'. super printon: s]\gb12B
\g
SystemOrganization classify: ParsedNegation under: 'Compiler'.\g

"ParsedObjectReference"l15000z20000\gbf5 
Class new title: 'ParsedObjectReference'
	subclassof: Object
	fields: 'var'
	declare: '';
	sharing: ByteCodes;
	asFollows\gbf5 

I am a node in a compiler parse tree.  I represent a remote argument which is a reference to a class or pool variable.\gi

Initialization\gbf5 
var: var\gb

Code generation\gbf5 
emitForValue: code on: stack  "Turn literal indirect into literal direct"
	[(var-256) emitForValue: code on: stack]\gb30Bi43bI2B
local
	[var]\gb7B
remote: generator\gb
sizeForValue
	[(var-256) sizeForValue]\gb14B

Miscellaneous\gbf5 
printon: s
	[s append: 'OBJ=> '; print: var]\gb12B

Decompiling\gbf5 
findMacros: macros compilerTemps: compilerTemps
	[var findMacros: macros compilerTemps: compilerTemps]\gb49B
printon: strm indent: level precedence: p forValue: v decompiler: decompiler
	[strm append: (decompiler literal: var)]\gb78B
\g
SystemOrganization classify: ParsedObjectReference under: 'Compiler'.\g

"ParsedRemote"l15000z20000\gbf5 
Class new title: 'ParsedRemote'
	subclassof: Object
	fields: 'expr esize toRemoteCopy'
	declare: '';
	sharing: ByteCodes;
	asFollows\gbf5 

I am a node in a compiler parse tree.  I represent an argument that is to be passed unevaluated.\gi

Initialization\gbf5 
expr: expr\gb

Code generation\gbf5 
emitForValue: code on: stack
	[toLoadThisCtxt emitForValue: code on: stack.
	toRemoteCopy emitBytes: code.
	code emitLong: toLongJmp by: esize.
	expr emitForValue: code on: stack.
	code next _ toEnd. stack pop: 1.
	(0-esize) emitJmp: code on: stack]\gb30B
local
	[expr]\gb7B
remote: generator
	[toRemoteCopy _ generator encodeSel: remoteCopy]\gb19B
sizeForValue
	[esize _ expr sizeForValue + 3.
	esize + toRemoteCopy sizeForValue + 3]\gb14B

Miscellaneous\gbf5 
printon: s
	[s append: ''; print: expr]\gb12B

Decompiling\gbf5 
findMacros: macros compilerTemps: compilerTemps
	[expr findMacros: macros compilerTemps: compilerTemps]\gb49B
printon: strm indent: level precedence: p forValue: v decompiler: decompiler
	[[(expr is: ParsedBlock) and 
			(expr position>1 or (expr1 is: ParsedConditional))
		[strm crtab: level+1]].
	expr printon: strm indent: level+1 precedence: p
			forValue: true decompiler: decompiler]\gb78B
\g
SystemOrganization classify: ParsedRemote under: 'Compiler'.\g

"Parser"l15000z20000\gbf5 
Class new title: 'Parser'
	subclassof: Object
	fields: 'source dest oppositeCourt type token mark keep'
	declare: '';
	sharing: TokenCodes;
	asFollows\gbf5 

I parse tokens from source (a stream).  I report each parse node to dest (e.g., a code generator).  When an error occurs, I back up source to mark and notify dest.  I have two kinds of methods, token suppliers and token consumers, which coroutine with each other.  The coroutine that is not in control is suspended in the context, oppositeCourt.  Token suppliers are driven by an instance of class Reader that scans source and classifies each token by type.  Token consumers analyze the syntax and report it to dest.  The variable "keep" is no longer used.\gi

Initialization\gbf5 
from: source to: dest
	[oppositeCourt _ thisContext.
	mark _ source position. type _ 1.
	(Reader new of: source) readInto: self]
"Generator compile|Generator evaluate"\gb23B106i

Token suppliers\gbf5 
comment: s
	[mark _ source position]\gb12B
contents
	[type _ 0. mark _ source position + 1.
	thisContext sender _ nil.
	while true do [self resume. self notify: 'MORE EXPECTED']]\gb10B
float: i fraction: f exp: e
	[token _ (i+'.'+f+'e'+e) asFloat.
	type _ aNumber. self resume]\gb29B
identifier: token
	[type _ aWord. self resume]\gb19B
integer: s
	[token _ s asInteger.
	type _ aNumber. self resume]\gb12B
keyword: token
	[type _ aKeyword. self resume]\gb16B
leftparen
	[type _ aLeftPar. self resume]\gb11B
onechar: token
	[type _
		[token=056 [aPeriod];
			=0133 [aLeftBrack];
			=0135 [aRightBrack];
			=033 [aCondArrow];
			=0137 [aLeftArrow];
			=021 [aReturnArrow];
			=073 [aSemicolon];
			=017 [aHand]
		aBinary].
	self resume]\gb16B
otheratom: token
	[type _ aGibberish. self resume]\gb18B
rightparen
	[type _ aRightPar. self resume]\gb12B
separator: c\gb
string: token
	[type _ aString. self resume]\gb15B
trailer: s
	[mark _ source position]\gb12B

Method syntax\gbf5 
body: block  | p  "return the primitive number, or 0"
	[type=aLeftBrack
		[self block: block.
		type=aKeyword and token='primitive:'
			[self advance. type=aNumber [p _ token. self advance. p]
			self notify: 'EXPECTED A NUMBER']
		0]
	0]
"Generator compile"\gb13B5i35I193i
declaration: block
	[typeaWord [self notify: 'EXPECTED AN ARGUMENT NAME']
	dest declaration: block name: token asArg: true.
	self advance]
"pattern"\gb20B121i
pattern: block
		| selector
	[selector _ Stream default.
	[type=aWord
			[selector append: token. self advance];
		=aBinary
			[selector append: (UST1(token+1)). self advance; declaration: block]
	while type = aKeyword do [selector append: token. self advance; declaration: block].
	selector empty [self notify: 'EXPECTED A SELECTOR']].
	[type=aLeftArrow
		[selector append: '_'. self advance; declaration: block]].
	selector contents unique]
"Generator compile|Context variableNamesInto"\gb17B434i
temporaries: block
	[type=aBinary and token=0174 "|"
		[self advance.
		while type=aWord do
			[dest declaration: block name: token asArg: false. self advance]]]
"Generator compile|Context variableNamesInto"\gb20B31i3I112i

Statement syntax\gbf5 
alternatives: ifExpr " [..] ..."
		| thenExpr elseExpr
	[self advance.
	typeaLeftBrack [self notify: 'EXPECTED A [BLOCK]']
	thenExpr _ self block: dest block. elseExpr _ dest block.
	[type=aSemicolon [self cascade: elseExpr after: ifExpr] self statements: elseExpr].
	dest ifExpr: ifExpr thenExpr: thenExpr elseExpr: elseExpr]
"cascade"\gb21Bi12I299i
block: block
	[self advance; statements: block.
	type=aRightBrack [self advance. block]
	self notify: 'PERIOD OR RIGHT BRACKET WAS EXPECTED']
"body|alternatives|expression|keywordMessage|binaryMessage"\gb14B130i
cascade: block after: expr  | val var oldTemps
	[var _ dest receivingVar: expr.
	oldTemps _ dest balance.
	while type=aSemicolon do
		[self advance.
		(val _ self messageChain: var)var
			[self notify: 'MESSAGE EXPECTED'].
		type=aCondArrow
			[block next _ self alternatives: val. dest unbalance: oldTemps. self]
		block next _ val].
	dest unbalance: oldTemps]
"statement|alternatives"\gb28B340i
loopStmt: block  | oldMark
	[oldMark _ mark. self keywordMessage: false loop: block [self]
	mark _ oldMark. self notify: 'UNKNOWN CONTROL MESSAGE']
"statement"\gb17B133i
macro: block  | oldMark oldTemps val
	[oldMark _ mark. oldTemps _ dest juggle.
	val _ self keywordMessage: false macro: block.
	dest unjuggle: oldTemps.
	val [block]
	mark _ oldMark. self notify: 'UNKNOWN CONTROL MESSAGE']
"statement"\gb14B211i
statement: block | expr
	[type=aReturnArrow
			[self advance. block next _ self expression. block doesReturn.
			[type=aPeriod [self advance]].
			typeaRightBrack [self notify:'SHOULDN''T FOLLOW RETURN']];
		= aKeyword [self macro: block. type>aPeriod [self statement: block]];
		aPeriod [dest nullStatement: block] "doit eof aRightBrack aPeriod"
	expr _ self expression.
	type=aCondArrow [block next _ self alternatives: expr]
	block next _ expr.
	type=aSemicolon [self cascade: block after: expr]]
"statements"\gb17B307i30I156i
statements: block
	[self statement: block.
	while type=aPeriod do
		[self advance. self statement: block]]
"alternatives|block|Generator evaluate"\gb19B90i

Expression syntax\gbf5 
binaryMessage: rcvr assign: assign "binarySelector ..."
		| sel args
	[sel _ token. self advance.
	args _ [type=aLeftBrack [self block: dest block] self factor].
	[assign and type=aLeftArrow
		[self advance.
		args _ [(Vector new: 2)1_args; 2_self expression; itself].
		sel _ [(String new: 2)1_sel; 2_0137"_"; itself]]].
	dest rcvr: rcvr selector: sel args: args]
"term|messageChain"\gb35Bi20I258i3I57i
expression
		| var
	[type=aLeftBrack [self block: dest block];
			=aKeyword [self macro: dest block];
			aWord [self messageChain: self primary]
	"It begins with a variable name" var _ dest variable: token. self advance.
	typeaLeftArrow [self messageChain: var]
	"It is a variable assignment" self advance.
	dest assignment: var expr: self expression]
"unaryMessage|binaryMessage|keywordMessage|statement|subExpression"\gb13B140i32I88i29I61i
factor
		| expr
	[expr _ self primary.
	while type=aWord do [expr _ self unaryMessage: expr assign: false].
	expr]
"term|binaryMessage"\gb9B109i
keywordMessage: rcvr macro: block "keyword ..."
		| sel args arg
	[sel _ Stream default. args _ (Vector new: 4) asStream.
	while type = aKeyword do
		[sel append: token. self advance.
		arg _ [type=aLeftBrack [self block: dest block] self term].
		args next _ [sel last=03 [dest noEvalKeyword: arg] dest evalKeyword: arg]].
	[type=aLeftArrow [sel append: '_'. args next _ [self advance; expression]]].
	sel _ sel contents. args _ [args position=1 [args last] args contents].
	block [dest macro: block selector: sel args: args]
	dest keywordMessage: rcvr selector: sel args: args]
"macro|messageChain"\gb34Bi13I542i
messageChain: rcvr
	[while type=aWord do [rcvr _ self unaryMessage: rcvr assign: true].
	while type=aBinary do [rcvr _ self binaryMessage: rcvr assign: true].
	[type = aKeyword [rcvr _ self keywordMessage: rcvr macro: false]].
	rcvr]
"cascade|expression"\gb20B220i
term  | rcvr
	[rcvr _ self factor.
	while type=aBinary do [rcvr _ self binaryMessage: rcvr assign: false].
	rcvr]
"keywordMessage"\gb6B111i
unaryMessage: rcvr assign: assign "word ..."
		| sel args
	[sel _ token. self advance.
	args _	[assign and type=aLeftArrow [sel _ sel + '_'. self advance; expression] false].
	dest rcvr: rcvr selector: sel args: args]
"factor|messageChain"\gb34Bi10I177i

Primary syntax\gbf5 
literal "A Vector, UniqueString, String, or Number"
		| t oldMark
	[type
		=aLeftPar
			[oldMark _ mark. self advance.
			t _ self read. type=aRightPar [self advance. t]
			mark _ oldMark. self notify: 'UNMATCHED']
	t _ [typeaKeyword [token unique]; aBinary [UST1(token+1)] token].
	self advance. t]
"primary|read"\gb8Bi43I258i
primary
		| t
	[type
		=aWord [t _ dest variable: token. self advance. t];
		=aLeftPar [self subExpression];
		=aNumber [t _ dest literal: token. self advance. t];
		=aString [t _ dest literal: token. self advance. t];
		=aHand [self advance.
			type=aRightPar or type=0 [self notify: 'EXPECTED LITERAL']
			dest literal: self literal]
	self notify: 'OBJECT EXPECTED']
"factor|expression"\gb10B371i
read "A sequence of literals"
		| s
	[s _ (Vector new: 10) asStream.
	until (type=aRightPar or type=0) do [s next _ self literal].
	s contents]
"literal"\gb5Bi24I119i
subExpression "(...)"
		| expr
	[self advance. expr _ self expression.
	type=aRightPar [self advance. expr]
	self notify: 'NOT EXPECTED IN A (SUBEXPRESSION)']
"primary"\gb14Bi7I140i

Suspension\gbf5 
advance "Switch from the parser to the reader to obtain another token."
	[mark _ source position- [type>aBinary [1] 0].
	oppositeCourt _ thisContext swapSender: oppositeCourt]\gb8Bi63I
mustBeDone
	[type=0 [self terminate] self notify: 'UNEXPECTED CONSTRUCT']
"Generator compile|Generator evaluate"\gb12B63i
notify: errorString | delims
	[source skip: mark - source position.
	delims _ (011 012  014 015 040).
	while (delims has: source peek) do [source next].
	[source myendfalse [source skip: 1]].
	dest abortWith: errorString]\gb20B
resume "The reader has supplied another token; resume the parser."
	[oppositeCourt _ thisContext swapSender: oppositeCourt]\gb7Bi59I
terminate
	[[destnil [] dest terminate. dest _ nil].
	[oppositeCourtnil [] oppositeCourt release. oppositeCourt _ nil]]
"mustBeDone|Generator abortWith|Context variableNamesInto"\gb11B113i
\g
SystemOrganization classify: Parser under: 'Compiler'.\g

"ParseStack"l15000z20000\gbf5 
Class new title: 'ParseStack'
	subclassof: Object
	fields: 'position length'
	declare: '';
	asFollows\gbf5 

I keep track of the current and high position of the stack that will be needed by code being compiled.\gi

Initialization\gbf5 
init
	[length _ position _ 0]\gb6B

Changes\gbf5 
pop: n
	[(position _ position - n) < 0 [user notify: 'Parse stack underflow']]\gb8B
push: n
	[(position _ position + n) > length [length _ position]]\gb9B

Results\gbf5 
length
	[length]\gb8B
position
	[position]\gb10B
\g
SystemOrganization classify: ParseStack under: 'Compiler'.\g
