↪READ ROUTINE↪c(635)\f4g1f5bG12f4Bg1f5bG
Smalltalk define "Readerstuff as "Readerstuff ← SymbolTable new.
Readerstuff insertall: "(typetable scantable dot
	separ letter digit notapos notcomnt notcr).

Class new title: 'Reader';
	fields: 'source sink token nextchar typetbl scantbl';
	sharing: 'Readerstuff'
Reader understands: 'of: source
	[typetbl ← typetable.  scantbl ← scantable.
	sink ← (Vector new: 10) asStream. token ← Stream default.
	self step]'
Reader understands: 'step
	[nextchar ← source next]'		↪nextchar avoids backing up↪
Reader understands: 'read | x 
	[while⦂ nextchar do⦂
		[x ← typetbl◦(nextchar+1).
		x=1? [self scan: separ];			↪separators↪
		=2? [sink next ← (self scan: letter+digit) unique];	↪identifiers↪
		=3? [sink next ← (self scan: 0) unique]; ↪1-char tokens↪
		=4? [sink next ← self rdnum. dot?[sink next← ".]];	↪Numbers↪
		=5? [sink next ← self rdstr];			↪Strings↪
		=6? [self step. sink next ← self subread];	↪sub-Vectors↪
		=7? [self step. !sink contents];	↪close-paren↪
		=8? [self rdcom];			↪comments↪
		=9? [self scan: notcr];			↪^Z format runs↪
		=10? [!sink contents];			↪null and DOIT↪
		]
	!sink contents]'
Reader understands: 'scan: mask | x
	[mask=0 ?[x ← String new: 1. x◦1 ← nextchar. self step. !x]
	token reset.
	while⦂ nextchar do⦂
		[(mask land: scantbl◦(nextchar+1))=0? [!token contents]
		token next ← nextchar. nextchar ← source next]
	!token contents]'
Reader understands: 'subread | a b 
	[a ← sink.  sink ← (Vector new: 10) asStream.
	b ← self read.  sink ← a.  !b]'
Reader understands: 'rdnum | sign val d 
	[sign ← [nextchar=025? [self step. ¬1] 1].	↪sign↪
	d ← [nextchar=060? [8] 10].			↪base↪
	val ← self mknum: (self scan: digit) base: d.	↪integer part↪
	dot ← false.
	nextchar=056?		↪check for decimal point↪
		[self step.
		nextchar isdigit≡false?
			[dot ← true. !sign*val]		↪was <Integer> .  ↪
		d ← self scan: digit.
		val ← (self mknum: d base: 10)asFloat / (10.0 ipow: d length) + val.
		nextchar=0145?		↪check for e<exponent> ↪
			[self step.  !val*(10.0 ipow: self rdnum)*sign]
		!val*sign]
 	!sign*val]'
Reader understands: 'mknum: str base: base | val c 
	[val ← [str length>4? [0.0] 0].
	for⦂ c from: str do⦂
		[val ← val*base + (c-060)]
 	!val]'
Reader understands: 'rdstr | a 
	[self step. a ← self scan: notapos.
	nextchar ≡ false? [user notify: ''Unmatched String quote'']
	self step.
	nextchar=047?	↪imbedded String-quote↪
		[token next ← 047. a← token contents
		!a + self rdstr]
	!a]'
Reader understands: 'rdcom 
	[self step.  self scan: notcomnt.
	nextchar≡false? [user notify: ''Unmatched comment quote'']
	self step]'

"Readerinit ← function (type bit asc1 asc2 typetbl scantbl i)		↪init read tables in-line↪
	("type ← :. "bit ← ⦂. (bit=0?() "bit ← Readerstuff◦bit).
	"asc1 ← :. "asc2 ← (%to?(:) asc1).
	"typetbl ← Readerstuff◦"typetable. "scantbl ← Readerstuff◦"scantable.
	(type=0?() for i← asc1+1 to asc2+1 do (typetbl[i]   ← type)).
	for i← asc1+1 to asc2+1 do
		(scantbl[i] ← scantbl[i] &- bit)
	Readerstuff◦"typetable set typetbl. Readerstuff◦"scantable set scantbl.
	!nil).
Readerstuff insertall: "(separ letter digit notapos notcr notcomnt)
	with: "(1 2 4 8 16 32).
Readerstuff define "typetable as string 256.
Readerstuff◦"typetable[1 to 256] ← all 3.		↪1-char tokens↪
Readerstuff define "scantable as string 256.
Readerstuff◦"scantable[1 to 256] ← all 8+16+32.
Readerinit 0  notcr  015. ↪cr↪
Readerinit 1  separ  011  ↪separators: tab, ↪
Readerinit 1  separ  012  ↪ LF, ↪
Readerinit 1  separ  014  ↪ FF, ↪
Readerinit 1  separ  015  ↪ CR, ↪
Readerinit 1  separ  040  ↪ blank ↪
Readerinit 2  letter  0101 to 0132  ↪letters↪
Readerinit 2  letter  0141 to 0172	↪lower-case↪
Readerinit 3  letter  072	↪colon↪
Readerinit 3  letter  03		↪open colon↪
Readerinit 4  digit  060 to 071  ↪digits↪
Readerinit 4  0  025  ↪high-minus↪
Readerinit 5  notapos  047  ↪String-quote↪
Readerinit 6  0  050  ↪left-paren↪
Readerinit 7  0  051  ↪close-paren↪
Readerinit 8  notcomnt  017  ↪comments↪
Readerinit 9  0  032 ↪^Z format runs↪
Readerinit 10  0  036  ↪null and DOIT↪
\f4g161f5bG81f0B2f5b25f4Bg21u3U147u4U31f0iG26f4Ig23u4U87f0iG10f4Ig57f0iG11f4Ig46f0iG13f4Ig56f0iG7f4Ig37f0iG7f4Ig48f0iG11f4Ig38f0iG11f4Ig25f0iG8f4Ig31f0iG14f4Ig30f0iG13f4Ig46u5U250u7U110u5U60f0iG4f4Ig34f0iG4f4Ig50f0iG12f4Ig33f0iG23f4Ig71f0iG16f4Ig117f0iG21f4Ig103u6U5u5U130u5U132f0iG21f4Ig88u5U1577f0G

↪BYTE COMPILER↪c\2f4g1f5bG13f4Bg1f5bG
Smalltalk define "Compilerstuff as "Compilerstuff ← SymbolTable new.
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
	[self init: class.  a ← b asVector asStream.
	self compilepattern: a.				↪pattern and decls↪
	self compileblock: a. self push.		↪Smalltalk code↪
	[self nofixups?[]	↪no redundant return↪
		[stack=maxstack?[self popopt]].
		code next← selfcode. code next← returncode].
	[
	c ← [a %"primitive: ?[a next] 0].	↪primitive: <integer> clause↪
	a← self qcodeck: c ? []		↪ckeck for rd/wrt accessors↪
	a ← Stream default.							↪now make up code object↪
	a next← 0; next← c; next← maxtemp+maxstack.		↪header↪
	a next← nargs; next← maxtemp; next← 6+(2*literals length).
	for⦂ i from: literals do⦂								↪literals↪
		[a next← i PTR lshift: ¬8; next← i PTR land: 0377]
	a append: precode contents; append: code contents.			↪code body↪
	].
	class install: selector
		method: (code←a contents) literals: [literals length>0?[literals] nil]
		code: b backpointers: nil.
	!selector]'
Compiler understands: 'qcodeck: t | a b i		↪fast read/write accessors↪
	[t≠0?[!false] code loc≠2?[!false]
	a ← Stream default. a next← 0.
	code◦2≠returncode? [!false]
	code◦1≠selfcode?
		[code◦1<tempcode?
			[precode empty?
				[a next← 40; next← 0; next← 0; next← code◦1. !a]	↪quick !inst var↪
			!false]
		!false]
	precode empty?[a next← 1. !a]		↪quick !self↪
	b ← precode contents. nargs≠b length/3?[!false]
	a next← 41; next← 0; next←  b length/3.
	for⦂ i from: (3 to: b length by: 3) do⦂
		[b◦i<tempcode?[a next← b◦i] !false]		↪write inst vars↪
	!a]'
Compiler understands: 'init: class | a i
	[environment ← class environment.
	[initcdict≡nil?		↪initial symbol defs↪
		[initcdict ← Dictionary new init: 16.
		initcdict insertall: "(self thisContext super nil false true)
			with: "(113 133 134 125 126 127).
		initopdict ← Dictionary new init: 64.
		initopdict insertall: "(+ - < > ≤ ≥ = ≠
				* / \ | min: max: land: lor:
				◦ ''◦←''atomize) next ''next←''atomize) length ≡
				class and: or: new new: to: oneToMeAsStream asStream)
			with: "(176 177 178 179 180 181 182 183
				184 185 186 187 188 189 190 191
				192 193 194 195 196 197
				200 201 202 203 204 205 206 207)] ].
	cdict ← Dictionary new copyfrom: initcdict.
	opdict ← Dictionary new copyfrom: initopdict.
	a ← class instvars. for⦂ i to: a length do⦂
		[cdict insert: a◦i with: instcode+i-1].
	stack← ntemps← maxtemp← 0. maxstack← 1.
	precode ← Stream default.
	literals ← Vector new: 0]'

Compiler understands: 'compilepattern: a | c
	[ntemps ← 0. selector ← a peek.
	[selector iskeyword?		↪selector and args↪
		[c ← nullString.
		until⦂ [a end or: a peek iskeyword ≡ false] do⦂			↪keywords↪
			[c ← c+ a next.
			self compilearg: a next]
		selector ← c unique]
	a next.
	selector isinfix?		↪infix↪
		[self compilearg: a next]
	].
	[a % "← ?			↪possible ← phrase↪
		[selector ← (selector + ''←'') unique.
		self compilearg: a next]
	].
	nargs ← ntemps.
	a % "| ?			↪further temp declarations↪
		[until⦂ [a end or: "[=a peek] do⦂
			[self compiletemp: a next]]]'
Compiler understands: 'compilearg: a | b
	[b ← self newtemp.
	cdict has: a?
		[precode next← b.		↪compile assignments↪
		precode next← smashpcode.		↪for non-temp args↪
		precode next← cdict◦a.  maxstack ← 1]
	cdict insert: a with: b]'
Compiler understands: 'compiletemp: a | b
	[b ← self newtemp.
	cdict has: a?
		[user notify: ''temp name used elsewhere: ''+a asString]
	cdict insert: a with: b]'
Compiler understands: 'newtemp
	[maxtemp ← maxtemp max: (ntemps ← ntemps+1).
	!tempcode + ntemps-1]'

Compiler understands: 'compileblock: source | a b c inblock
	[cascading ← false.
	code ← Stream default. fixups ← (Vector new: 0) asStream.
	source end?[!nullString] a ← stack.
	[source %"[? [] 
		user notify: ''[ missing before: ''+source peek asString].
	while⦂ inblock do⦂
		[source end?[user notify: ''unbalanced brackets'']
		source %"] ?[code next← nilcode. self push. inblock ← false]
		source %"! ?[code append: (self compileexpr: source). self push.
			code next← returncode. source %". . source %"] ?[inblock ← false]
			 user show:  ''junk following return stmt''. 
			inblock ← false]
		self controlstmt ?[self uncascade. source %".]
		canoptpop ← true.
		code append: [cascading?[self compilecascade: source]
			self compileexpr: source]. self push.
		source %"] ?[inblock ← false]
		source %"? ?[self pop. c ← Compiler new.
			b ← c compileblock: source.
				[source %"; ?[self cascade]
				self uncascade. source %".].
			c nofixups?
				[code append: (self encodejmp: bfpcode by: b length); append: b]
			fixups next← code contents; next← b. code reset]
		[source %"; ?[self cascade]
		self uncascade.  source %".?[]
		 user show: ''per missing before: ''+source peek asString ].
		self pop. self popopt]		↪period pops stack↪
	self pop. stack≠a?[user notify: ''unbalanced stack'']
	fixups empty? [!code contents] canoptpop←false.
	self fixup: code contents and: fixups contents.
	!code contents]'
Compiler understands: 'popopt | t		↪append pop and optimize↪
	[2>(t←code loc)?[t=1?[code skip: ¬1]]
	canoptpop≡false? [code next← popcode]
	code◦t=nilcode?			↪jmp1-nil-pop -> pop↪
		[[code◦(t-1)=shortjmp?[code skip: ¬2]]. code next← popcode]
	code◦(t-1)=smashcode?
		[code◦(t-1) ← smashpcode]	↪sto-var-pop -> stopop var↪
	code next← popcode]'
Compiler understands: 'cascade | t
	[cascading?[]		↪cascading is either false↪
	(t ← code◦code loc)<minopcode?
		[user notify: ''improper cascading [...;].'']
	code◦(code loc-1)<areccode?
		[cascading ← code◦(code loc-1)]		↪or = temp code for receiver↪
	code skip: ¬1. code next← smashcode.		↪alloc temp if not simple↪
	code next← cascading ← self newtemp. code next← t]'
Compiler understands: 'uncascade
	[cascading?[cascading<areccode?[cascading ← false]
		ntemps ← ntemps-1. cascading ← false]]'
Compiler understands: 'nofixups	↪!true if no jmpout needed↪
	[fixups empty?			↪...meaning no internal branches↪
		[code loc=0?[!false]  !code◦code loc=returncode]	↪AND ends with !↪
	!false]'
Compiler understands: 'fixup: a and: b | c i t
		↪b◦odd=main code, c◦odd ← bfp around consequents,
		b◦even=consequents, c◦even ← jmp to end↪
	[c ← Vector new: b length. t ← a length.
	for⦂ i from: (b length-1 to: 1 by: ¬2) do⦂		↪compute the jumps↪
		[c◦(i+1) ← self encodejmp: jmpcode by: t.
		c◦i ← self encodejmp: bfpcode by: ((b◦(i+1)) length+(c◦(i+1)) length).
		t ← t+(b◦i) length+(b◦(i+1)) length+(c◦i) length+(c◦(i+1)) length]
	code reset. for⦂ i to: b length do⦂		↪collate all back into code↪
		[code append: b◦i; append: c◦i]
	code append: a]'
Compiler understands: 'controlstmt
	[source %"for⦂ ?[self compilefor]
	source %"until⦂ ?[self compileuntil: true]
	source %"while⦂ ?[self compileuntil: false]
	!false]'
Compiler understands: 'compilefactor: s [!self compilephrase: 1 from: s]'
Compiler understands: 'compileterm: s [!self compilephrase: 2 from: s]'
Compiler understands: 'compileexpr: s [!self compilephrase: 3 from: s]'
Compiler understands: 'compilecascade: s [!self compilephrase: 4 from: s]'
Compiler understands: 'compilephrase: level from: input | a b c i t stk more
	[a ← Stream default.
		[level=4? [a next← cascading. level←3]
		self track⦂ (self compileprimary: input into: a level: level)?[↪no assign↪]
		!(self compileexpr: input) + a contents].
	stk ← stack. b ← (Vector new: 4) asStream.		↪arg stack↪
	b next← a; next← stackused.  a ← Stream default.			↪operators↪
	for⦂ i to: level do⦂
		[more ← true.  while⦂ more do⦂
			[input end?[more ← false] c←input peek.
			(c is: UniqueString) ≡ false?
					[user notify: ''unexpected: ''+ c asString]
				[i=1?[c isinfix?[more ← false]
					c iskeyword?[more ← false]  c ← input next];
				=2?[c iskeyword?[more ← false]
					"( . ; ? [ ] ← !) has: c?[more ← false]
					c ← input next.
					b next← self track⦂ (self compilefactor: input).
					b next← stackused];
				=3?["(for⦂ until⦂ while⦂) has: c?[more ← false]
					while⦂ [input end?[false] (c←input peek) iskeyword] do⦂
						[t ← [t ≡ nil?[input next] t + input next].
						a append: [c isuneval?
								[self remote⦂ (self compileterm: input)]
							self compileterm: input].
						self push]
					t≡nil?[more ← false] c ← t unique]].
			more≡false?[]
				[level=3?[input %"← ?			↪check here for  ← clause↪
					[c←(c+''←'')unique.
					[i=2?[self exstack: b pop. a append: b pop. self push]].
					a append: (self compileexpr: input). self push]]].
			(b◦1) next← self encodeop: c. i=3?[more ← false]]]
	b◦1 ← (b◦1) contents.  until⦂ b empty do⦂
		[self exstack: b pop. a append: b pop. self push]
	stack ← stk. !a contents]'
Compiler understands: 'compileprimary: input into: a level: n | c
	["[ = input peek ?[c ← Compiler new. a append: (c compileblock: input)]
	c ← input next.
	c is: Vector?[a append: (self compileexpr: (c← Stream new of: c)).
		c end?[] user notify: ''extra suff in parens: ''+ a asString]
	c ← [""=c?[self encodelit: input next] self encoderef: c]. 
	[n=3?[input %"← ?				↪expr-level call checks for ← ↪
		[c<(areccode+8)?[a next← smashcode; next← c. !false]		↪assignment↪
		user notify: ''assigning into read-only field'']]].
	self exstack: 1.
	c=supercode?[a next← selfcode; next← supercode] a next← c]'
Compiler understands: 'encoderef: a | t
	[[trace?[user show: a asString]].
	a is: UniqueString?
		[t ← cdict lookup: a ? [!t]
		a isinfix or: a iskeyword?
			[user notify: ''missing receiver before: '' + a asString]
		cdict insert: a with: (t← self newref: a).  !t]
	!self encodelit: a]'
Compiler understands: 'newref: a | i
	[for⦂ i from: environment,Undeclared  do⦂
		[i has: a?
			[!liticode + (self addlit: (i ref: a))]]
	user show: a asString + '' is undeclared.''.
	Undeclared define: a  as: nil.
	!liticode + (self addlit: (Undeclared ref: a))]'
Compiler understands: 'encodelit: a | b i
	[	[a class≡Integer?[0≠(i← "(¬1 0 1 2 10) find: a)?
				[!constcode+i-1]
			for⦂ i to: (32 min: literals length) do⦂
				[literals◦i is: Integer?[literals◦i=a?[!litcode+i-1]]]];
		≡Float?[for⦂ i to: (32 min: literals length) do⦂
				[literals◦i is: Float?[literals◦i=a?[!litcode+i-1]]]]].
	literals length<32?[!litcode +(self addlit: a)]
	b ← ObjectReference new. b value← a.
	!liticode + (self addlit: b)]'
Compiler understands: 'addlit: a | b
	[b ← literals length.
	b≥48?[user notify: ''too many literals'']
	literals ← literals , a. !b]'
Compiler understands: 'encodeop: a
	[[trace?[user show: a asString]].
	opdict has: a?[!opdict◦a]
	opdict insert: a with: (opcode + (self addlit: a)).
	!opdict◦a]'
Compiler understands: 'remote⦂ b | a t
	[a←Stream default.
	self push. b ← b eval. self pop.		↪extra stack to push caller↪
	a next← curcode; next← self encodeop: "remoteCopy.
	t ← b length+3. a next← t/256+jmpcode+4; next← t\256.
	a append: b; next← endcode; append: (self encodejmp: jmpcode by: 0-t).
	!a contents]'
Compiler understands: 'push
	[maxstack ← maxstack max: (stack ← stack+1).
	trace?[stack print]]'
Compiler understands: 'pop
	[0>(stack ← stack-1)?[user notify: ''negative stack'']]'
Compiler understands: 'track⦂ expr | a b val
	[a←maxstack.  maxstack← b← stack.
	val ← expr eval.
	b≠stack?[user notify: ''unbalanced stack'']
	stackused ← maxstack-stack.  maxstack ← a.
	!val]'
Compiler understands: 'exstack: x
	[maxstack ← maxstack max: stack + x]'
Compiler understands: 'encodejmp: a by: n | b
	[1≤n and: n≤8?[b←String new: 1.
		b◦1 ← n+[a=bfpcode?[shortbfp] shortjmp]-1. !b]
	[n<0?[n←n+1024. n<0?[user notify: ''block too long.'']]
		a ← a+4. n>1023?[user notify: ''block too long.'']].
	b ← String new: 2.
	b◦1 ← n/256+ a.  b◦2 ← n\256.  !b]'
Compiler understands: 'compilefor | a b
	[a ← source next.
	[cdict has: a?[cdict◦a<litcode?[]
			user show: a asString+'' is not local.'']
	user show: a asString+'' is not local.''].
	[source %"to: ?
		[code append: (self compileterm: source). self push.
		code next← self encodeop: "oneToMeAsStream]
	source %"from: ?
		[code append: (self compileterm: source). self push.
		code next← self encodeop: "asStream]
	user notify: ''to: or from: expected at ''+source peek asString].
	code next← smashcode.
	b← code loc. code next← self newtemp. 	↪reentry point↪
	code next← self encodeop: "next; next← smashcode.
	code next← self encoderef: a. self compileloop: b.
	ntemps ← ntemps-1]'
Compiler understands: 'compileuntil: a | b
	[b ← code loc.
	code append: (self compileterm: source). self push.
	[a?[code next← self encoderef: "false. self push.
		code next← self encodeop: "≡. self pop]].
	self compileloop: b]'
Compiler understands: 'compileloop: b|a c
	[self pop.
	[source %"do⦂ ?[] 
		user notify: ''do⦂ expected before ''+source peek asString].
	c ← Compiler new. c compileblock: source.
	c popopt. a ← c code.		↪end with pop [opt]↪
	code append: (self encodejmp: bfpcode by: 2+a length).	↪2 for jmp ¬n↪
	code append: a; append: (self encodejmp: jmpcode by: b-code loc-2)]'
Compiler understands: 'code [!code contents]'

\f4g573f5bG79f0B2f5b27f4Bg23u8U3u3U908u8U549u5U905u15U559u11U225u12U152u7U96u13U1401u6U7f0iG23f4Ig100f0iG19f4Ig116f0iG25f4Ig48u7U22f0iG25f4Ig147f0iG27f4Ig42f0iG24f4Ig79u9U119u8U2f0iG25f4Ig157u6U3u4U542u11U159u14U61u12U61u12U61u15U61u14U7u5U1528u15U7u5U3u6U570u10U279u7U259u10U441u7U128u9U155u7U65f0i26f4I220u4U94u3U83u6U190u8U66u10U3u3U282u10U905u12U355u4U21f0G

↪SCHEDULING↪c\2f4g1f5bG10f4Bg1f5bG

Class new title:'PriorityScheduler';
fields: 'source	↪the source of power, ie the source from which
			this scheduler was spawned, and who therefore holds
			the suspension if it is suspended.↪
		processes ↪<Vector of Contexts> the suspended processes↪
		rootprocesses ↪<Vector of Contexts> root processes for restarting↪
		enabled ↪<Integer> bits for each level; bit0=level0=lowest prio↪
		active ↪<Integer> bits for each level; bit0=1, bit15=sign bit↪
		currentlevel ↪<Integer> this level is currently selected↪'
↪The underlying machine has a pointer to the top level scheduler, so that physical interrupts can also cause interrupts in Smalltalk.  This they do by calling their own copy of wakeup and reselect.  This copy is also invoked (primitive 65) when reselect is sent to the top-level scheduler, since its source is the virtual machine itself.↪
PriorityScheduler understands: 'install⦂ context at: level
	[context sender ← nil.  rootprocesses◦level ← context.
	processes◦level ← context copy]'
PriorityScheduler understands: 'enable: level
	[enabled ← enabled lor: biton◦level]'
PriorityScheduler understands: 'disable: level
	[enabled ← enabled land: bitoff◦level]'
PriorityScheduler understands: 'wakeup: level
	[active ← active lor: biton◦level.
	self reselect]'
PriorityScheduler understands: 'sleep: level
	[active ← active land: bitoff◦level.
	self reselect]'
PriorityScheduler understands: 'reset: level
	[processes◦level ← rootprocesses◦level copy.
	self sleep: level]'
PriorityScheduler understands: 'restart: level
	[processes◦level ← rootprocesses◦level copy.
	self wakeup: level]'
PriorityScheduler understands: 'terminate: level
	[active ← active land: bitoff◦level.
	processes◦level ← rootprocesses◦level ← nil.
	active ← active land: bitoff◦level.
	self reselect]'
PriorityScheduler understands: 'reselect
	[processes◦currentlevel ← source current.
	currentlevel ← (active land: enabled) hibit.
	source current ← processes◦currentlevel] primitive: 65'
PriorityScheduler understands: 'current
	[!processes◦currentlevel]'
PriorityScheduler understands: 'current ← context
	[!processes◦currentlevel ← context]'
PriorityScheduler understands: 'critical⦂ expr| t v
	[t ← self disable.
	v ← expr eval.			↪evaluate with no interrupts↪
	enabled ← t. !v]'
PriorityScheduler understands: 'disable | t
	[t ← enabled. enabled ← 0. !t] primitive: 66'
↪remaining here:
	wakeup source on wakeup
	sleep source on sleep
	arrange to sleep or restart when a process returns
	what does an empty scheduler do↪
(500)\f5b54f4Bg1f0iG138f4Ig1f5bG13f4Bg1f0iG44f4Ig1f5bG17f4Bg1f0iG50f4Ig1f5bG11f4Bg1f0iG54f4Ig1f5bG10f4Bg1f0iG53f4Ig1f5bG16f4Bg1f0iG42f4Ig1f5bG3f4Bg1f0iG176u6U5u8U49u8U84f4Ig34u8U9u3U130u7U79u8U81u7U93u6U95u6U107u8U108u10U178u8U143f0iG2f4Ig35u7U62u9U80u9U50f0iG27f4Ig54u7U 
