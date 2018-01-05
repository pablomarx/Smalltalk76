READ ROUTINEc(635)\f4g1f5bG12f4Bg1f5bG
Smalltalk define "Readerstuff as "Readerstuff _ SymbolTable new.
Readerstuff insertall: "(typetable scantable dot
	separ letter digit notapos notcomnt notcr).

Class new title: 'Reader';
	fields: 'source sink token nextchar typetbl scantbl';
	sharing: 'Readerstuff'
Reader understands: 'of: source
	[typetbl _ typetable.  scantbl _ scantable.
	sink _ (Vector new: 10) asStream. token _ Stream default.
	self step]'
Reader understands: 'step
	[nextchar _ source next]'		nextchar avoids backing up
Reader understands: 'read | x 
	[while nextchar do
		[x _ typetbl(nextchar+1).
		x=1? [self scan: separ];			separators
		=2? [sink next _ (self scan: letter+digit) unique];	identifiers
		=3? [sink next _ (self scan: 0) unique]; 1-char tokens
		=4? [sink next _ self rdnum. dot?[sink next_ ".]];	Numbers
		=5? [sink next _ self rdstr];			Strings
		=6? [self step. sink next _ self subread];	sub-Vectors
		=7? [self step. !sink contents];	close-paren
		=8? [self rdcom];			comments
		=9? [self scan: notcr];			^Z format runs
		=10? [!sink contents];			null and DOIT
		]
	!sink contents]'
Reader understands: 'scan: mask | x
	[mask=0 ?[x _ String new: 1. x1 _ nextchar. self step. !x]
	token reset.
	while nextchar do
		[(mask land: scantbl(nextchar+1))=0? [!token contents]
		token next _ nextchar. nextchar _ source next]
	!token contents]'
Reader understands: 'subread | a b 
	[a _ sink.  sink _ (Vector new: 10) asStream.
	b _ self read.  sink _ a.  !b]'
Reader understands: 'rdnum | sign val d 
	[sign _ [nextchar=025? [self step. 1] 1].	sign
	d _ [nextchar=060? [8] 10].			base
	val _ self mknum: (self scan: digit) base: d.	integer part
	dot _ false.
	nextchar=056?		check for decimal point
		[self step.
		nextchar isdigitfalse?
			[dot _ true. !sign*val]		was <Integer> .  
		d _ self scan: digit.
		val _ (self mknum: d base: 10)asFloat / (10.0 ipow: d length) + val.
		nextchar=0145?		check for e<exponent> 
			[self step.  !val*(10.0 ipow: self rdnum)*sign]
		!val*sign]
 	!sign*val]'
Reader understands: 'mknum: str base: base | val c 
	[val _ [str length>4? [0.0] 0].
	for c from: str do
		[val _ val*base + (c-060)]
 	!val]'
Reader understands: 'rdstr | a 
	[self step. a _ self scan: notapos.
	nextchar  false? [user notify: ''Unmatched String quote'']
	self step.
	nextchar=047?	imbedded String-quote
		[token next _ 047. a_ token contents
		!a + self rdstr]
	!a]'
Reader understands: 'rdcom 
	[self step.  self scan: notcomnt.
	nextcharfalse? [user notify: ''Unmatched comment quote'']
	self step]'

"Readerinit _ function (type bit asc1 asc2 typetbl scantbl i)		init read tables in-line
	("type _ :. "bit _ . (bit=0?() "bit _ Readerstuffbit).
	"asc1 _ :. "asc2 _ (%to?(:) asc1).
	"typetbl _ Readerstuff"typetable. "scantbl _ Readerstuff"scantable.
	(type=0?() for i_ asc1+1 to asc2+1 do (typetbl[i]   _ type)).
	for i_ asc1+1 to asc2+1 do
		(scantbl[i] _ scantbl[i] &- bit)
	Readerstuff"typetable set typetbl. Readerstuff"scantable set scantbl.
	!nil).
Readerstuff insertall: "(separ letter digit notapos notcr notcomnt)
	with: "(1 2 4 8 16 32).
Readerstuff define "typetable as string 256.
Readerstuff"typetable[1 to 256] _ all 3.		1-char tokens
Readerstuff define "scantable as string 256.
Readerstuff"scantable[1 to 256] _ all 8+16+32.
Readerinit 0  notcr  015. cr
Readerinit 1  separ  011  separators: tab, 
Readerinit 1  separ  012   LF, 
Readerinit 1  separ  014   FF, 
Readerinit 1  separ  015   CR, 
Readerinit 1  separ  040   blank 
Readerinit 2  letter  0101 to 0132  letters
Readerinit 2  letter  0141 to 0172	lower-case
Readerinit 3  letter  072	colon
Readerinit 3  letter  03		open colon
Readerinit 4  digit  060 to 071  digits
Readerinit 4  0  025  high-minus
Readerinit 5  notapos  047  String-quote
Readerinit 6  0  050  left-paren
Readerinit 7  0  051  close-paren
Readerinit 8  notcomnt  017  comments
Readerinit 9  0  032 ^Z format runs
Readerinit 10  0  036  null and DOIT
\f4g161f5bG81f0B2f5b25f4Bg21u3U147u4U31f0iG26f4Ig23u4U87f0iG10f4Ig57f0iG11f4Ig46f0iG13f4Ig56f0iG7f4Ig37f0iG7f4Ig48f0iG11f4Ig38f0iG11f4Ig25f0iG8f4Ig31f0iG14f4Ig30f0iG13f4Ig46u5U250u7U110u5U60f0iG4f4Ig34f0iG4f4Ig50f0iG12f4Ig33f0iG23f4Ig71f0iG16f4Ig117f0iG21f4Ig103u6U5u5U130u5U132f0iG21f4Ig88u5U1577f0G

BYTE COMPILERc\2f4g1f5bG13f4Bg1f5bG
Smalltalk define "Compilerstuff as "Compilerstuff _ SymbolTable new.
Compilerstuff insertall: "(cdict opdict initcdict initopdict selector nargs ntemps maxtemp
		environment literals precode stack maxstack canoptpop).
Compilerstuff define "trace as false
Compilerstuff insertall: "(instcode tempcode litcode liticode areccode constcode selfcode nilcode
		smashpcode smashcode popcode returncode endcode curcode supercode
		shortjmp shortbfp jmpcode bfpcode minopcode opcode)
	with: "(0 16 32 64 112 120 113 125
		128 129 130 131 132 133 134
		144 152 160 168 176 208).

Class new title: 'Compiler';
	fields: 'source code cascading stackused fixups';
	sharing: 'Compilerstuff'
Compiler understands: 'compile: b in: class | a c i t
	[self init: class.  a _ b asVector asStream.
	self compilepattern: a.				pattern and decls
	self compileblock: a. self push.		Smalltalk code
	[self nofixups?[]	no redundant return
		[stack=maxstack?[self popopt]].
		code next_ selfcode. code next_ returncode].
	[
	c _ [a %"primitive: ?[a next] 0].	primitive: <integer> clause
	a_ self qcodeck: c ? []		ckeck for rd/wrt accessors
	a _ Stream default.							now make up code object
	a next_ 0; next_ c; next_ maxtemp+maxstack.		header
	a next_ nargs; next_ maxtemp; next_ 6+(2*literals length).
	for i from: literals do								literals
		[a next_ i PTR lshift: 8; next_ i PTR land: 0377]
	a append: precode contents; append: code contents.			code body
	].
	class install: selector
		method: (code_a contents) literals: [literals length>0?[literals] nil]
		code: b backpointers: nil.
	!selector]'
Compiler understands: 'qcodeck: t | a b i		fast read/write accessors
	[t0?[!false] code loc2?[!false]
	a _ Stream default. a next_ 0.
	code2returncode? [!false]
	code1selfcode?
		[code1<tempcode?
			[precode empty?
				[a next_ 40; next_ 0; next_ 0; next_ code1. !a]	quick !inst var
			!false]
		!false]
	precode empty?[a next_ 1. !a]		quick !self
	b _ precode contents. nargsb length/3?[!false]
	a next_ 41; next_ 0; next_  b length/3.
	for i from: (3 to: b length by: 3) do
		[bi<tempcode?[a next_ bi] !false]		write inst vars
	!a]'
Compiler understands: 'init: class | a i
	[environment _ class environment.
	[initcdictnil?		initial symbol defs
		[initcdict _ Dictionary new init: 16.
		initcdict insertall: "(self thisContext super nil false true)
			with: "(113 133 134 125 126 127).
		initopdict _ Dictionary new init: 64.
		initopdict insertall: "(+ - < >   = 
				* / \ | min: max: land: lor:
				 ''_''atomize) next ''next_''atomize) length 
				class and: or: new new: to: oneToMeAsStream asStream)
			with: "(176 177 178 179 180 181 182 183
				184 185 186 187 188 189 190 191
				192 193 194 195 196 197
				200 201 202 203 204 205 206 207)] ].
	cdict _ Dictionary new copyfrom: initcdict.
	opdict _ Dictionary new copyfrom: initopdict.
	a _ class instvars. for i to: a length do
		[cdict insert: ai with: instcode+i-1].
	stack_ ntemps_ maxtemp_ 0. maxstack_ 1.
	precode _ Stream default.
	literals _ Vector new: 0]'

Compiler understands: 'compilepattern: a | c
	[ntemps _ 0. selector _ a peek.
	[selector iskeyword?		selector and args
		[c _ nullString.
		until [a end or: a peek iskeyword  false] do			keywords
			[c _ c+ a next.
			self compilearg: a next]
		selector _ c unique]
	a next.
	selector isinfix?		infix
		[self compilearg: a next]
	].
	[a % "_ ?			possible _ phrase
		[selector _ (selector + ''_'') unique.
		self compilearg: a next]
	].
	nargs _ ntemps.
	a % "| ?			further temp declarations
		[until [a end or: "[=a peek] do
			[self compiletemp: a next]]]'
Compiler understands: 'compilearg: a | b
	[b _ self newtemp.
	cdict has: a?
		[precode next_ b.		compile assignments
		precode next_ smashpcode.		for non-temp args
		precode next_ cdicta.  maxstack _ 1]
	cdict insert: a with: b]'
Compiler understands: 'compiletemp: a | b
	[b _ self newtemp.
	cdict has: a?
		[user notify: ''temp name used elsewhere: ''+a asString]
	cdict insert: a with: b]'
Compiler understands: 'newtemp
	[maxtemp _ maxtemp max: (ntemps _ ntemps+1).
	!tempcode + ntemps-1]'

Compiler understands: 'compileblock: source | a b c inblock
	[cascading _ false.
	code _ Stream default. fixups _ (Vector new: 0) asStream.
	source end?[!nullString] a _ stack.
	[source %"[? [] 
		user notify: ''[ missing before: ''+source peek asString].
	while inblock do
		[source end?[user notify: ''unbalanced brackets'']
		source %"] ?[code next_ nilcode. self push. inblock _ false]
		source %"! ?[code append: (self compileexpr: source). self push.
			code next_ returncode. source %". . source %"] ?[inblock _ false]
			 user show:  ''junk following return stmt''. 
			inblock _ false]
		self controlstmt ?[self uncascade. source %".]
		canoptpop _ true.
		code append: [cascading?[self compilecascade: source]
			self compileexpr: source]. self push.
		source %"] ?[inblock _ false]
		source %"? ?[self pop. c _ Compiler new.
			b _ c compileblock: source.
				[source %"; ?[self cascade]
				self uncascade. source %".].
			c nofixups?
				[code append: (self encodejmp: bfpcode by: b length); append: b]
			fixups next_ code contents; next_ b. code reset]
		[source %"; ?[self cascade]
		self uncascade.  source %".?[]
		 user show: ''per missing before: ''+source peek asString ].
		self pop. self popopt]		period pops stack
	self pop. stacka?[user notify: ''unbalanced stack'']
	fixups empty? [!code contents] canoptpop_false.
	self fixup: code contents and: fixups contents.
	!code contents]'
Compiler understands: 'popopt | t		append pop and optimize
	[2>(t_code loc)?[t=1?[code skip: 1]]
	canoptpopfalse? [code next_ popcode]
	codet=nilcode?			jmp1-nil-pop -> pop
		[[code(t-1)=shortjmp?[code skip: 2]]. code next_ popcode]
	code(t-1)=smashcode?
		[code(t-1) _ smashpcode]	sto-var-pop -> stopop var
	code next_ popcode]'
Compiler understands: 'cascade | t
	[cascading?[]		cascading is either false
	(t _ codecode loc)<minopcode?
		[user notify: ''improper cascading [...;].'']
	code(code loc-1)<areccode?
		[cascading _ code(code loc-1)]		or = temp code for receiver
	code skip: 1. code next_ smashcode.		alloc temp if not simple
	code next_ cascading _ self newtemp. code next_ t]'
Compiler understands: 'uncascade
	[cascading?[cascading<areccode?[cascading _ false]
		ntemps _ ntemps-1. cascading _ false]]'
Compiler understands: 'nofixups	!true if no jmpout needed
	[fixups empty?			...meaning no internal branches
		[code loc=0?[!false]  !codecode loc=returncode]	AND ends with !
	!false]'
Compiler understands: 'fixup: a and: b | c i t
		bodd=main code, codd _ bfp around consequents,
		beven=consequents, ceven _ jmp to end
	[c _ Vector new: b length. t _ a length.
	for i from: (b length-1 to: 1 by: 2) do		compute the jumps
		[c(i+1) _ self encodejmp: jmpcode by: t.
		ci _ self encodejmp: bfpcode by: ((b(i+1)) length+(c(i+1)) length).
		t _ t+(bi) length+(b(i+1)) length+(ci) length+(c(i+1)) length]
	code reset. for i to: b length do		collate all back into code
		[code append: bi; append: ci]
	code append: a]'
Compiler understands: 'controlstmt
	[source %"for ?[self compilefor]
	source %"until ?[self compileuntil: true]
	source %"while ?[self compileuntil: false]
	!false]'
Compiler understands: 'compilefactor: s [!self compilephrase: 1 from: s]'
Compiler understands: 'compileterm: s [!self compilephrase: 2 from: s]'
Compiler understands: 'compileexpr: s [!self compilephrase: 3 from: s]'
Compiler understands: 'compilecascade: s [!self compilephrase: 4 from: s]'
Compiler understands: 'compilephrase: level from: input | a b c i t stk more
	[a _ Stream default.
		[level=4? [a next_ cascading. level_3]
		self track (self compileprimary: input into: a level: level)?[no assign]
		!(self compileexpr: input) + a contents].
	stk _ stack. b _ (Vector new: 4) asStream.		arg stack
	b next_ a; next_ stackused.  a _ Stream default.			operators
	for i to: level do
		[more _ true.  while more do
			[input end?[more _ false] c_input peek.
			(c is: UniqueString)  false?
					[user notify: ''unexpected: ''+ c asString]
				[i=1?[c isinfix?[more _ false]
					c iskeyword?[more _ false]  c _ input next];
				=2?[c iskeyword?[more _ false]
					"( . ; ? [ ] _ !) has: c?[more _ false]
					c _ input next.
					b next_ self track (self compilefactor: input).
					b next_ stackused];
				=3?["(for until while) has: c?[more _ false]
					while [input end?[false] (c_input peek) iskeyword] do
						[t _ [t  nil?[input next] t + input next].
						a append: [c isuneval?
								[self remote (self compileterm: input)]
							self compileterm: input].
						self push]
					tnil?[more _ false] c _ t unique]].
			morefalse?[]
				[level=3?[input %"_ ?			check here for  _ clause
					[c_(c+''_'')unique.
					[i=2?[self exstack: b pop. a append: b pop. self push]].
					a append: (self compileexpr: input). self push]]].
			(b1) next_ self encodeop: c. i=3?[more _ false]]]
	b1 _ (b1) contents.  until b empty do
		[self exstack: b pop. a append: b pop. self push]
	stack _ stk. !a contents]'
Compiler understands: 'compileprimary: input into: a level: n | c
	["[ = input peek ?[c _ Compiler new. a append: (c compileblock: input)]
	c _ input next.
	c is: Vector?[a append: (self compileexpr: (c_ Stream new of: c)).
		c end?[] user notify: ''extra suff in parens: ''+ a asString]
	c _ [""=c?[self encodelit: input next] self encoderef: c]. 
	[n=3?[input %"_ ?				expr-level call checks for _ 
		[c<(areccode+8)?[a next_ smashcode; next_ c. !false]		assignment
		user notify: ''assigning into read-only field'']]].
	self exstack: 1.
	c=supercode?[a next_ selfcode; next_ supercode] a next_ c]'
Compiler understands: 'encoderef: a | t
	[[trace?[user show: a asString]].
	a is: UniqueString?
		[t _ cdict lookup: a ? [!t]
		a isinfix or: a iskeyword?
			[user notify: ''missing receiver before: '' + a asString]
		cdict insert: a with: (t_ self newref: a).  !t]
	!self encodelit: a]'
Compiler understands: 'newref: a | i
	[for i from: environment,Undeclared  do
		[i has: a?
			[!liticode + (self addlit: (i ref: a))]]
	user show: a asString + '' is undeclared.''.
	Undeclared define: a  as: nil.
	!liticode + (self addlit: (Undeclared ref: a))]'
Compiler understands: 'encodelit: a | b i
	[	[a classInteger?[0(i_ "(1 0 1 2 10) find: a)?
				[!constcode+i-1]
			for i to: (32 min: literals length) do
				[literalsi is: Integer?[literalsi=a?[!litcode+i-1]]]];
		Float?[for i to: (32 min: literals length) do
				[literalsi is: Float?[literalsi=a?[!litcode+i-1]]]]].
	literals length<32?[!litcode +(self addlit: a)]
	b _ ObjectReference new. b value_ a.
	!liticode + (self addlit: b)]'
Compiler understands: 'addlit: a | b
	[b _ literals length.
	b48?[user notify: ''too many literals'']
	literals _ literals , a. !b]'
Compiler understands: 'encodeop: a
	[[trace?[user show: a asString]].
	opdict has: a?[!opdicta]
	opdict insert: a with: (opcode + (self addlit: a)).
	!opdicta]'
Compiler understands: 'remote b | a t
	[a_Stream default.
	self push. b _ b eval. self pop.		extra stack to push caller
	a next_ curcode; next_ self encodeop: "remoteCopy.
	t _ b length+3. a next_ t/256+jmpcode+4; next_ t\256.
	a append: b; next_ endcode; append: (self encodejmp: jmpcode by: 0-t).
	!a contents]'
Compiler understands: 'push
	[maxstack _ maxstack max: (stack _ stack+1).
	trace?[stack print]]'
Compiler understands: 'pop
	[0>(stack _ stack-1)?[user notify: ''negative stack'']]'
Compiler understands: 'track expr | a b val
	[a_maxstack.  maxstack_ b_ stack.
	val _ expr eval.
	bstack?[user notify: ''unbalanced stack'']
	stackused _ maxstack-stack.  maxstack _ a.
	!val]'
Compiler understands: 'exstack: x
	[maxstack _ maxstack max: stack + x]'
Compiler understands: 'encodejmp: a by: n | b
	[1n and: n8?[b_String new: 1.
		b1 _ n+[a=bfpcode?[shortbfp] shortjmp]-1. !b]
	[n<0?[n_n+1024. n<0?[user notify: ''block too long.'']]
		a _ a+4. n>1023?[user notify: ''block too long.'']].
	b _ String new: 2.
	b1 _ n/256+ a.  b2 _ n\256.  !b]'
Compiler understands: 'compilefor | a b
	[a _ source next.
	[cdict has: a?[cdicta<litcode?[]
			user show: a asString+'' is not local.'']
	user show: a asString+'' is not local.''].
	[source %"to: ?
		[code append: (self compileterm: source). self push.
		code next_ self encodeop: "oneToMeAsStream]
	source %"from: ?
		[code append: (self compileterm: source). self push.
		code next_ self encodeop: "asStream]
	user notify: ''to: or from: expected at ''+source peek asString].
	code next_ smashcode.
	b_ code loc. code next_ self newtemp. 	reentry point
	code next_ self encodeop: "next; next_ smashcode.
	code next_ self encoderef: a. self compileloop: b.
	ntemps _ ntemps-1]'
Compiler understands: 'compileuntil: a | b
	[b _ code loc.
	code append: (self compileterm: source). self push.
	[a?[code next_ self encoderef: "false. self push.
		code next_ self encodeop: ". self pop]].
	self compileloop: b]'
Compiler understands: 'compileloop: b|a c
	[self pop.
	[source %"do ?[] 
		user notify: ''do expected before ''+source peek asString].
	c _ Compiler new. c compileblock: source.
	c popopt. a _ c code.		end with pop [opt]
	code append: (self encodejmp: bfpcode by: 2+a length).	2 for jmp n
	code append: a; append: (self encodejmp: jmpcode by: b-code loc-2)]'
Compiler understands: 'code [!code contents]'

\f4g573f5bG79f0B2f5b27f4Bg23u8U3u3U908u8U549u5U905u15U559u11U225u12U152u7U96u13U1401u6U7f0iG23f4Ig100f0iG19f4Ig116f0iG25f4Ig48u7U22f0iG25f4Ig147f0iG27f4Ig42f0iG24f4Ig79u9U119u8U2f0iG25f4Ig157u6U3u4U542u11U159u14U61u12U61u12U61u15U61u14U7u5U1528u15U7u5U3u6U570u10U279u7U259u10U441u7U128u9U155u7U65f0i26f4I220u4U94u3U83u6U190u8U66u10U3u3U282u10U905u12U355u4U21f0G

SCHEDULINGc\2f4g1f5bG10f4Bg1f5bG

Class new title:'PriorityScheduler';
fields: 'source	the source of power, ie the source from which
			this scheduler was spawned, and who therefore holds
			the suspension if it is suspended.
		processes <Vector of Contexts> the suspended processes
		rootprocesses <Vector of Contexts> root processes for restarting
		enabled <Integer> bits for each level; bit0=level0=lowest prio
		active <Integer> bits for each level; bit0=1, bit15=sign bit
		currentlevel <Integer> this level is currently selected'
The underlying machine has a pointer to the top level scheduler, so that physical interrupts can also cause interrupts in Smalltalk.  This they do by calling their own copy of wakeup and reselect.  This copy is also invoked (primitive 65) when reselect is sent to the top-level scheduler, since its source is the virtual machine itself.
PriorityScheduler understands: 'install context at: level
	[context sender _ nil.  rootprocesseslevel _ context.
	processeslevel _ context copy]'
PriorityScheduler understands: 'enable: level
	[enabled _ enabled lor: bitonlevel]'
PriorityScheduler understands: 'disable: level
	[enabled _ enabled land: bitofflevel]'
PriorityScheduler understands: 'wakeup: level
	[active _ active lor: bitonlevel.
	self reselect]'
PriorityScheduler understands: 'sleep: level
	[active _ active land: bitofflevel.
	self reselect]'
PriorityScheduler understands: 'reset: level
	[processeslevel _ rootprocesseslevel copy.
	self sleep: level]'
PriorityScheduler understands: 'restart: level
	[processeslevel _ rootprocesseslevel copy.
	self wakeup: level]'
PriorityScheduler understands: 'terminate: level
	[active _ active land: bitofflevel.
	processeslevel _ rootprocesseslevel _ nil.
	active _ active land: bitofflevel.
	self reselect]'
PriorityScheduler understands: 'reselect
	[processescurrentlevel _ source current.
	currentlevel _ (active land: enabled) hibit.
	source current _ processescurrentlevel] primitive: 65'
PriorityScheduler understands: 'current
	[!processescurrentlevel]'
PriorityScheduler understands: 'current _ context
	[!processescurrentlevel _ context]'
PriorityScheduler understands: 'critical expr| t v
	[t _ self disable.
	v _ expr eval.			evaluate with no interrupts
	enabled _ t. !v]'
PriorityScheduler understands: 'disable | t
	[t _ enabled. enabled _ 0. !t] primitive: 66'
remaining here:
	wakeup source on wakeup
	sleep source on sleep
	arrange to sleep or restart when a process returns
	what does an empty scheduler do
(500)\f5b54f4Bg1f0iG138f4Ig1f5bG13f4Bg1f0iG44f4Ig1f5bG17f4Bg1f0iG50f4Ig1f5bG11f4Bg1f0iG54f4Ig1f5bG10f4Bg1f0iG53f4Ig1f5bG16f4Bg1f0iG42f4Ig1f5bG3f4Bg1f0iG176u6U5u8U49u8U84f4Ig34u8U9u3U130u7U79u8U81u7U93u6U95u6U107u8U108u10U178u8U143f0iG2f4Ig35u7U62u9U80u9U50f0iG27f4Ig54u7U 