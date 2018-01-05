↪

The
New
Improved
SMALLTALK
System
Definition
June 12, 1977c(500)\f4g1f5bG47f0B13f5b


This is the new SYSDEFS\b
This is <INGALLS>bootstrap.st.  The read routine, compiler and file system(draft) appear in a separate file called bootstrap2.st.  The user interface(draft) is in userface.st.  The objects which are initially needed get created in the file launch.ft.  A complete simulator exists in simulate.ft, and old-system defs of the new classes are in genclass.ft↪l4269j\i353f4Ig1f0iG


↪RAW MATERIALS↪c(635)\1f4g1f5bG13f4Bg1f5bG

Class new title: 'Object';
	subclassof: nil;
	abstract
↪Object is the superclass of all classes.  It is an abstract class, meaning that it has no instance state, and its main function is to provide a foundation message protocol for its subclasses.  Three instances of this class are defined, namely: nil, true, and false.↪

↪primitives↪
Object understands: '≡ x [] primitive: 4'	↪test for identical pointers↪
	↪Font will be edited so this looks like W, meaning eq↪
Object understands: 'hash [] primitive: 46'	↪pointer as an Integer↪
Object understands: 'asOop [] primitive: 46'	↪Dont override this↪
Object understands: 'refct [] primitive: 45'	↪current reference count↪
Object understands: 'class [] primitive: 27'	↪class of this object↪
Object understands: 'instfield: n [] primitive: 38'	↪subscript any objct↪
Object understands: 'instfield: n ← val [] primitive: 39'

↪boolean connectives↪
Object understands: 'or: x [self?[!true] !x]'
Object understands: 'and: x [self?[!x] !false]'
Object understands: 'xor: x [x?[!self≡false] !self]'
Object understands: 'eqv: x [x?[!self] !self≡false]'

↪following don't evaluate their arg unless necessary.
They are built for comfort, not for speed.↪
Object understands: 'or⦂ x [self?[!true] !x eval]'
Object understands: 'and⦂ x [self?[!x eval] !false]'

↪default protocol↪
Object understands: 'printon: strm
	[self≡nil? [strm append: ''nil'']
	self≡false? [strm append: ''false'']
	self≡true? [strm append: ''true'']
	self class print: self on: strm]'
Object understands: 'asString | strm
	[strm ← Stream default.
	self printon: strm. !strm contents]'
Object understands: 'print
	[user show: self asString]'
Object understands: '= x [!self≡x]'
Object understands: '≠ x [!self=x≡false]'
Object understands: 'is: x [!self class≡x]'
Object understands: ', x | v
	[v ← Vector new: 2.
	v◦1 ← self. v◦2 ← x.  !v]'
Object understands: 'startup		↪loopless scheduling↪
	[self firsttime?
		[while⦂ self eachtime do⦂ [].
		!self lasttime]
	!false]'
Object understands: 'canunderstand: selector
	[!self class canunderstand: selector]'
Object understands: 'copy		↪create new copy of self↪
	[!self class copy: self]'
Object understands: 'recopy	↪recursively copy whole structure↪
	[!self class recopy: self]'
Object understands: 'error
	[user notify: ''Message not understood.'']'
Object understands: 'ⓢ code
	[self class understands: ''doit [!['' + code + '']]''.
	!self doit]'
\1f5b56f4Bg1f0iG265f4Ig1f0G2f4g1f0iG10f4Ig1f0G1f4g21u1U22f0iG27f4Ig4f0iG39f3Ig1f0iG12f4Ig1f0G1f4g21u4U21f0iG21f4Ig23u5U21f0iG18f4Ig23u5U21f0iG23f4Ig23u5U21f0iG20f4Ig23u10U23f0iG19f4Ig23u10U3u1U26f0iG19f4Ig23u3U44u4U45u4U50u4U31f0iG95f4Ig23u3U49u4U31f0iG16f4Ig23u8U172u8U93u5U52u1U36u1U42u3U42u1U209u14U72u4U3f0iG23f4Ig51u6U2f0iG32f4Ig53u5U146f0G
c

↪FUNDAMENTAL ORGANIZATION↪c\2f4g1f5bG24f4Bg1f5bG

Class new title: 'Class';
	fields: 'title	↪<String> for identification, printing↪
			myinstvars ↪<String> partnames for compiling, printing (includes comments)↪
			instsize ↪<Integer> for storage management↪
			messagedict ↪<MessageDict> for communication, compiling↪
			monitors ↪<Dictionary/nil> compiler checks here↪
			superclass ↪<Class> for execution of inherited behavior↪
			environment ↪<Vector of SymbolTables> for external references↪
			fieldtype'; ↪<Integer> encodes field size, if bits↪
	veryspecial: 1

↪order of messages, just to make things simpler:
	title insystem subclassof fields/abstract (required)
	sharing bytesize veryspecial (any order)↪
Class understands: 'title: title
	[self title: title insystem: Smalltalk]'
Class understands: 'title: title insystem: system
	[system define: title unique as: self.
	superclass ← Object]'
Class understands: 'subclassof: superclass'
Class understands: 'abstract
	[self fields: nullString]'
Class understands: 'fields: myinstvars		↪list of instance variables↪
	[fieldtype ← 16.
	instsize ← self instvars length.
	instsize>16?
		[user notify: ''too many instance variables'']
	messagedict ← MessageDict default.
	environment ← Vector new: 1. environment◦1 ← Smalltalk]'
Class understands: 'instvars
	[superclass≡nil ? [!myinstvars asVector]
	!superclass instvars concat: myinstvars asVector]'
Class understands: 'understands: code		↪install method↪
	[user displayoffwhile⦂ [Compiler new compile: code in: self]]'
Class understands: 'canunderstand: selector
	[!messagedict has: selector]'
Class understands: 'derstands: selector
	[messagedict ← messagedict delete: selector]'
Class understands: 'install: name method: method literals: literals
		code: code backpointers: backpointers
	[	[messagedict has: name? [CodeKeeper next← messagedict literals: name]].
	messagedict ← messagedict insert: name method: method
		literals: literals code: code backpointers: backpointers]'
Class understands: 'code: selector
	[!messagedict code: selector]'
Class understands: 'new [] primitive: 28'	↪creation of instances↪
Class understands: 'printon: strm
	[strm append: title]'
Class understands: 'allinstances [] primitive: 60'	↪enumeration↪
	↪If Ted cant do it, nobody can...↪
Class understands: 'bytesize: n	↪non-pointer declaration↪
	[fieldtype ← 32+ [n=8? [8] 16]]'	↪vanilla or chocolate only↪
Class understands: 'veryspecial: n		↪for ClassClasses↪
	[instsize ← instsize+n]'		↪secret freelist fields↪
Class understands: 'superclass [!superclass]'
Class understands: 'environment [!environment]'
Class understands: 'print: inst on: strm | ivars i
	[ivars ← myinstvars asVector.
	strm append: ''(''; append: title; append: '' new ''.
	for⦂ i to: instsize do⦂
		[strm append: ivars◦i; append: '': '';
			print: (inst instfield: i); space]
	strm append: '')'']'
Class understands: 'init		↪init and default get propagated to instances↪
	[!self new init]'
Class understands: 'default
	[!self new default]'
Class understands: 'copy: inst | t i
	[t ← self new.
	for⦂ i to: instsize do⦂
		[t instfield: i ← inst instfield: i]
	!t]'
Class understands: 'recopy: inst | t i
	[t ← self new.
	for⦂ i to: instsize do⦂
		[t instfield: i ← (inst instfield: i) recopy]
	!t]'
Class understands: 'ed: selector | c s
	[c← self code: selector. user clearshow: c.
	while⦂ (s← user request: ''substitute: '') do⦂
		[c ← c subst: s for: (user request: ''for: '').
		user clearshow: c]
	self understands: c]'


Class new title: 'VariableLengthClass';
	subclassof: Class;
	fields: '';
	veryspecial: 20
VariableLengthClass understands: 'new: length
	[length ≥ 020000 ?[length print. user notify: '' is too large'']
	length < 0 ?[length print. user notify: '' is too small'']
	!self new: length asInteger] primitive: 29'
VariableLengthClass understands: 'new
	[user notify: ''use new: <Integer=length> here.'']'
VariableLengthClass understands: 'copy: inst | t i
	[t ← self new: inst length.
	for⦂ i to: inst length do⦂
		[t◦i ← inst◦i]
	!t]'
VariableLengthClass understands: 'recopy: inst | t i
	[t ← self new: inst length.
	for⦂ i to: inst length do⦂
		[t◦i ← (inst◦i) recopy]
	!t]'


Class new title: 'Context';
	fields: 'sender ↪<Context> from which this message was sent↪
		receiver ↪<Object> to which this message was sent↪
		mclass ↪<Class> in which a method was found↪
		method ↪<String>, the encoded method↪
		tempframe ↪<Vector> to hold temporaries and a stack↪
		pc ↪<Integer> marks progress of execution in method↪
		stackptr ↪<Integer> offset of stack top in tempframe↪'
Context understands: 'eval [] primitive: 30'
Context understands: 'sender: sender receiver: receiver mclass: mclass
		method: method tempframe: tempframe pc: pc stackptr: stackptr'
Context understands: 'remoteCopy
	[!Context new sender: sender receiver: receiver mclass: mclass
		method: method tempframe: tempframe pc: pc+2 stackptr: stackptr]'
Context understands: 'sender [!sender]'
Context understands: 'sender← sender []'
Context understands: 'printon: strm
	[receiver class printon: strm. sender≡nil? []
		strm append: ''◦''; print: sender thisop]'
Context understands: 'trace | strm a
	[strm ← Stream default. self printon: strm.
	a ← sender. until⦂ a≡nil do⦂
		[strm cr. a printon: strm. a ← a sender]
	!strm contents]'
Context understands: 'thisop | a
	[a ← method◦pc.
	a≥0320? [!self litof: a-0320]
	a≥0260? [!self specialops◦(1+a-0260)]
	!"something]'
Context understands: 'litof: a
	[!(method word: a+4) asObject]'
Context understands: 'specialops
	[!"(+ - < > ≤ ≥ = ≠
		* / \ | min: max: land: lor:
		◦ ''◦←'' atomize) next ''next←'' atomize) length ≡ nil nil
		class and: or: new new: to: oneToMeAsStream asStream)]'
Context understands: 'debug | t
	[user cr. self print.
	while⦂ [t ← user request: ''
*''] do⦂ [user show: (selfⓢt) asString]]'
\1f5b42f4Bg1f0iG37f4Ig1f5bG15f4Bg1f0iG62f4Ig1f5bG13f4Bg1f0iG32f4Ig1f5bG16f4Bg1f0iG42f4Ig1f5bG13f4Bg1f0iG37f4Ig1f5bG15f4Bg1f0iG43f4Ig1f5bG16f4Bg1f0iG48f4Ig1f5bG16f4Bg1f0iG37f4Ig1f5bG18f0B1f4g1f0iG48I1u5U21u15U2u8U43f4g1f0G1f4g20u6U70u6U7u9U92u11U34u8U50u7U14f0iG26f4Ig232u8U116u12U8f0iG14f4Ig87u14U62u10U77u9U6u7U8u9U12u5U6u13U226u5U63u3U21f0iG21f4Ig22u8U50u12U21f0iG11f4Ig4f0iG32f4Ig22u9U4f0iG23f4Ig38f0iG25f4Ig1f0G1f4g20u12U5f0iG16f4Ig31f0iG22f4Ig22u10U37u11U38u6U6u3U178f0G1f4g17f0G1f4g52u4U3f0ui4U5u7U28f4I42u7U44u5U119u7U73f0G1f4g17f0G8f4g236f0G1b1f5 91f4Bg34u4U214u3U89u5U127u7U85f0G8f4g9f0G1b1f5 45f4Bg1f0iG42f4Ig1f5bG12f4Bg1f0iG39f4Ig1f5bG10f4Bg1f0iG35f4Ig1f5bG10f4Bg1f0iG28f4Ig1f5bG13f4Bg1f0iG40f4Ig1f5bG6f4Bg1f0iG47f4Ig1f5bG12f4Bg1f0iG42f4Ig1f5bG3f4Bg22u4U42u7U8u9U10u7U10u7U8u10U11u3U4u9U34u10U156u6U35u7U35u8U121u5U169u6U130u6U59u10U197u5U

↪NUMBERS↪c\2f4g1f5bG7f4Bg1f5bG
Class new title: 'Number';
	abstract		↪Numbers in general↪
Number understands: 'min: arg
	[self>arg?[!arg]]'
Number understands: 'max: arg
	[self<arg?[!arg]]'
Number understands: '@ y
	[!Point new x: self y: y]'
Number understands: 'to: x
	[!Interval new from: self to: x by: 1]'
Number understands: 'to: x by: y
	[!Interval new from: self to: x by: y]'
Number understands: 'subscripts: a
	[!a◦self asInteger]'
Number understands: 'subscripts: a ← val
	[!a◦self asInteger ← val]'


Class new title: 'Integer';			↪16-bit integers↪
	subclassof: Number;
	fields: '';
	bytesize: 16;
	veryspecial: 1	↪instance state not currently accessible↪
Integer understands: '+ arg
	[!self + arg asInteger] primitive: 6'
Integer understands: '- arg
	[!self - arg asInteger] primitive: 7'
Integer understands: '* arg
	[!self * arg asInteger] primitive: 21'
Integer understands: '/ arg
	[!self / arg asInteger] primitive: 22'
Integer understands: '< arg
	[!self < arg asInteger] primitive: 8'
Integer understands: '= arg
	[!self = arg asInteger] primitive: 9'
Integer understands: '> arg
	[!self > arg asInteger] primitive: 10'
Integer understands: '≤ arg
	[!self ≤ arg asInteger] primitive: 11'
Integer understands: '≠ arg
	[!self ≠ arg asInteger] primitive: 12'
Integer understands: '≥ arg
	[!self ≥ arg asInteger] primitive: 13'
Integer understands: 'lshift: arg
	[!self lshift: arg asInteger] primitive: 25'
Integer understands: 'land: arg
	[!self land: arg asInteger] primitive: 23'
Integer understands: 'lor: arg
	[!self lor: arg asInteger] primitive: 24'
Integer understands: 'xor: arg
	[!self xor: arg asInteger] primitive: 35'
Integer understands: 'field: fld
	[!self field: fld asInteger] primitive: 36'
Integer understands: 'field: fld ← val
	[!self field: fld asInteger ← val asInteger] primitive: 37'
Integer understands: '\ arg	↪mod↪
	[!self \ arg asInteger] primitive: 26'
Integer understands: '| arg	↪truncate↪
	[!self/arg*arg]'
Integer understands: 'printon: strm
	[self<0?[strm append: ''¬''. (0-self) absprinton: strm]
	self absprinton: strm]'
Integer understands: 'absprinton: strm | rem
	[rem ← self\10.
	[self>9? [self/10 absprinton: strm]].
	strm next ← rem+060]'
Integer understands: 'asInteger [!self]'
Integer understands: 'asFloat [] primitive: 34'
Integer understands: 'oneToMeAsStream		↪used by for-loops↪
	[!Stream new of: (Interval new from: 1 to: self by: 1)]'
Integer understands: 'copy [!self]'
Integer understands: 'recopy [!self]'
Integer understands: 'isletter
	[self ≥ 0141?	↪ a ↪
		[!self ≤ 0172]	↪ z ↪
	self ≥ 0101?	↪ A ↪
		[!self ≤ 0132]	↪ Z ↪
	!false]'
Integer understands: 'isdigit 
	[self ≥ 060?	↪ 0 ↪
		[!self ≤ 071]	↪ 9 ↪
	!false]'

↪Following two must be failures from Array subscripting: ↪
Integer understands: 'subscripts: a
	[user notify: ''Subscript out of bounds: '' + self asString]'
Integer understands: 'subscripts: a ← val
	[user notify: ''Subscript out of bounds: '' + self asString]'

Integer understands: 'purge [] primitive: 44'	↪write this oop to disk↪
	↪Warning: The Surgeon General has determined that the following message
	may be hazardous to the health of your system.↪
Integer understands: 'asObject [] primitive: 81'	↪makes a pointer↪


Class new title: 'Float';		↪Floating-Point↪
	subclassof: Number;
	fields: '';
	bytesize: 16;
	veryspecial: 3	↪instance state not currently accessible↪
Float understands: '+ arg
	[!self+arg asFloat] primitive: 67'
Float understands: '- arg
	[!self-arg asFloat] primitive: 68'
Float understands: '* arg
	[!self*arg asFloat] primitive: 69'
Float understands: '/ arg
	[!self/arg asFloat] primitive: 70'
Float understands: '< arg
	[!self<arg asFloat] primitive: 71'
Float understands: '= arg
	[!self=arg asFloat] primitive: 72'
Float understands: '≤ arg
	[!self≤arg asFloat] primitive: 73'
Float understands: '> arg
	[!self>arg asFloat] primitive: 74'
Float understands: '≥ arg
	[!self≥arg asFloat] primitive: 75'
Float understands: '≠ arg
	[!self≠arg asFloat] primitive: 76'
Float understands: 'fpart [] primitive: 77'
Float understands: 'ipart
	[!self-self fpart]'		↪NOTE this isnt an Integer↪
Float understands: 'asInteger [] primitive: 78'		↪this IS an Integer↪
Float understands: 'sqrt [] primitive: 79'
Float understands: 'ipow: x		↪fixed powers in log n steps↪
	[x=0? [!1.0]
	x=1? [!self]
	x>1? [!((self*self) ipow: x/2)*(self ipow: x\2)]
	!1.0/(self ipow: 0-x)]'
Float understands: 'epart: base | x	↪gives floor log.base self↪
	[self<base? [!0]		↪self assumed positive↪
	self<(base*base)? [!1]
	x ← 2*(self epart: base*base).	↪binary recursion like ipow↪
	!x + ((self/(base ipow: x)) epart: base)]'
Float understands: 'printon: strm
	[self<0.0? [strm append: ''¬''. (0.0-self) absprinton: strm]
	self absprinton: strm]'
Float understands: 'absprinton: strm | x y q i fuzz
	[fuzz ← 5.0e¬9.			↪fuzz tracks significance↪
	y ← [self<1.0? [0-(10.0/self epart: 10.0)] self epart: 10.0].
	x ← self/(10.0 ipow: y)+fuzz.			↪normalize x↪
	[x≥10.0? [y ← y+1. x ← x/10.0]].	↪y = exponent↪
	[y<6 and: y>¬4?
		[q ← 0.			↪decimal notation↪
		y<0? [strm append: ''0.0000''◦(1 to: 1-y)]
		fuzz ← fuzz * 10.0 ipow: y].
	q ← y. y ← 0].		↪scientific notation↪
	for⦂ i to: 9 do⦂
		[strm next ← 060+x ipart.
		x ← 10.0 * x fpart.
		0>(y ← y-1)?
			[x<(fuzz ← fuzz*10.0)?[↪done - fix↪]
			y=¬1? [strm append: ''.'']]]
	[y=¬1?[strm append: ''.0'']].
	q≠0?[strm append: ''e''; print: q]]'
Float understands: 'asFloat'
Float understands: 'copy [!self]'
Float understands: 'recopy [!self]'
\f5b36f0B3f4g1f0iG18f4Ig1f0G1f4g21u4U47u4U47u1U53u3U66u3U3u3U66u11U47u11U3u1U34f0G2f5b27f0B3f4g1f0iG15f4Ig1f0G1f5b66f4Bg1f0iG39f4Ig1f5bG1f4Bg22u1U67u1U67u1U68u1U68u1U67u1U67u1U68u1U68u1U68u1U68u7U74u5U72u4U71u4U71u6U73u6U95u1U74u1U57u8U111u11U113f0G1f4ug9U33u7U41f0G1f4ug15U102f0G1f4ug4U32f0G1f4ug6U33u8U121u8U136u11U89u11U3u1U92u5U21f0iG22f4Ig146u8U21f0iG15f4Ig2f0G2f5b24f0B3f4g1f0iG14f4Ig1f0G1f5b66f4Bg1f0iG39f4Ig1f5bG1f4Bg20u1U62u1U62u1U62u1U62u1U62u1U62u1U62u1U62u1U62u1U62u5U40u5U22f0G2f4g1f0iG25f4Ig1f0G1f4g20u9U19f0G2f4g1f0iG18f4Ig1f0G1f4g20u4U40u5U5f0iG27f4Ig126u6U11f0iG25f4Ig22f0iG21f4Ig59f0iG26f4Ig67u8U114u11U41f0iG24f4Ig99f0iG11f4Ig37f0iG12f4Ig32f0iG16f4Ig96f0iG19f4Ig247u7U1f0G2f4g19f0G1f4ug4U30f0G1f4ug6U11f0G

↪ARRAYS↪c\2f4g1f5bG6f4Bg1f5bG
Class new title: 'Array';
	abstract			↪arrays in general↪
Array understands: 'length [] primitive: 16'
Array understands: '◦ x
	[!x subscripts: self] primitive: 38'
Array understands: '◦ x ← val
	[!x subscripts: self ← val] primitive: 39'
↪Note that subscripting by an integer is primitive.  A subscript of another class will be called with the message subscripts: array, in the hopes that it knows how to behave as a subscript.↪
Array understands: 'subscripts: x			↪subarrays↪
	[!Substring new data: x map: self]'
Array understands: 'subscripts: x ← val		↪subrange replacement↪
	[self length≠val length?
		[user notify: ''lengths not commensurate'']
	val copyto: (Substring new data: x map: self).
	!val]'
Array understands: 'all ← val | i
	[for⦂ i to: self length do⦂
		[self◦i ← val]]'
Array understands: '= arg | x
	[self length ≠ arg length? [!false]
	for⦂ x to: self length do⦂ 
		[(self◦x) = (arg◦x)? [] !false]
	!true]'
Array understands: 'find: x | i
	[for⦂ i to: self length do⦂
		[self◦i=x? [!i]].
	!0]'
Array understands: 'findnon: x | i
	[for⦂ i to: self length do⦂
		[self◦i≠x? [!i]].
	!0]'
Array understands: 'has: x
	[!0≠(self find: x)]'
Array understands: 'reverse	
	[!Substring new data: self map: (self length to: 1 by: ¬1)]'
Array understands: 'concat: arg | x
	[x ← self species new: self length + arg length.
	x◦(1 to: self length) ← self.
	x◦(self length+1 to: x length) ← arg.  !x]'
Array understands: 'copy
	[!self copyto: (self species new: self length)]'
Array understands: 'copyto: t | i s
	[s ← t asStream.
	for⦂ i from: self do⦂
		[s next← i]
	!t]'
Array understands: 'replace: a to: b by: s | x
	[x ← self species new: self length+s length -(1+b-a).
	x◦(1 to: a-1) ← self◦(1 to: a-1).  t←a+s length-1.
	x◦(a to: t) ← s.
	x◦(t+1 to: x length) ← self◦(b+1 to: self length).
	!x]'
Array understands: 'growby: n
	[!self copyto: (self species new: self length+n)]'
Array understands: 'grow
	[!self copyto: (self species new: (4 max: self length*2))]'
Array understands: 'last
	[!self◦self length]'
Array understands: 'last ← val
	[!self◦self length ← val]'
Array understands: 'species
	[!Vector]'
Array understands: 'read
	[!self new asStream read]'
Array understands: 'asStream
	[!Stream new of: self]'
Array understands: 'isIntervalBy1
	[!false]'
Array understands: 'swap: i with: j | t
	[t ← self◦i. self◦i ← self◦j. self◦j ← t]'\f5b36f0B3f4g1f0iG17f4Ig1f0bG1f4Bg20u6U40u1U62u1U3u1U51f0iG188f4Ig1f0iG1f4Ig20u11U75u11U3u1U178u5U78u1U139u5U83u8U83u4U46u7U85u7U156u4U72u7U91u8U3u3U3u3U211u7U76u4U83u4U44u6U54u7U34u5U49u8U47u13U33u5U3u5U


VariableLengthClass new title: 'Vector';		↪Array of objects↪
	subclassof: Array
Vector understands: ', x | v
	[v ← self growby: 1.	↪use a stream if youre in a hurry↪
	v last ← x. !v]'
Vector understands: 'printon: strm | i
	[strm append: ''(''.
	for⦂ i to: self length-1 do⦂
		[strm print: self◦i; append: '', ''].
	strm print: self last; append: '')'' ]'


VariableLengthClass new title: 'String';		↪Array of 8-bit bytes↪
	subclassof: Array;
	bytesize: 8
String understands: 'word: x		↪read word in String↪
	[!self◦(2*x) + (self◦(2*x-1) lshift: 8)]'
String understands: 'word: x ← y		↪write word in String↪
	[self◦(2*x) ← y land: 0377.
	self◦(2*x-1) ← y lshift: ¬8. !y]'
String understands: 'printon: strm | x	↪print inside string quotes↪
	[strm next← 047.
	for⦂ x from: self do⦂
		[strm next← x.
		x=047?[strm next← x]]		↪imbedded quotes get doubled↪
	strm next← 047]'
String understands: 'species
	[!String]'
String understands: 'asVector
	[!self asStream asVector]'
String understands: 'asParagraph
	[!Paragraph new text: self alignment: 0]'
String understands: 'recopy
	[!self copy]'
String understands: 'subst: repl for: key | key1 i nskip result
	[nskip ← 0. key1 ← key◦1. result ← Stream default.
	for⦂ i to: self length do⦂		↪ the Boyer Slow string replacement ↪
		[nskip>0? [nskip ← nskip-1]
		self◦i = key1?
			[self◦(i to: (self length min: i+key length-1)) = key?
				[result append: repl. nskip ← key length-1]
			result next← self◦i]
		result next← self◦i]
	!result contents]'
String understands: 'unique | u		↪copy and intern↪
	[u ← UniqueString new: self length.
	!u of: self]'
String understands: 'hash | x h		↪not great, but compatible with FT atom hashing↪
	[h ← 13131.
	for⦂ x from: self do⦂
		[h ← x * h.
		h ← (h lshift: ¬1)+(h lshift: 15)]
	!h]'


VariableLengthClass new title: 'UniqueString';		↪allows fast compare (eq) for tables↪
	subclassof: String;
	bytesize: 8
UniqueString understands: 'of: s | i a v 
	[a ← self intern: s hash: (i←s hash)? [!a]
	i ← 1+(i lshift: ¬8).
	v ← USTable◦i.
	USTable◦i ← Vector new: 2*v length.		↪grow that hash bucket↪
	for⦂ a from: v do⦂		↪copy all its contents↪
		[a≡nil? []
		self intern: a hash: a stringhash]
	!self of: s]'		↪and try again... ↪
UniqueString understands: 'intern: s hash: h| i j v n
	[v ← USTable◦(1+(h lshift: ¬8)).
	for⦂ i to: v length do⦂		↪interning compatible with FT atoms - change it soon↪
		[h ← h\v length+1.
		v◦h≡nil?		↪empty slot↪
			[s is: UniqueString? [!v◦h ← s]		↪(when growing)↪
			n← 0.  for⦂ j from: v do⦂
				[j≡nil? [n ← n+1]]		↪count # empty slots↪
			4*n < v length?[!false]	↪grow if not 1/4 ↪
			for⦂ j to: s length do⦂		↪copy string↪
				[super◦j ← s◦j]	↪where there-s a will there-s a way↪
			!v◦h ← self]		↪and install self as the atom↪
		s=(v◦h)?[!v◦h]]
	user notify: ''USTable jammed (UniqueString)'']'
UniqueString understands: 'stringhash
	[!super hash]'
UniqueString understands: '◦x ← val
	[user notify: ''UniqueStrings are not for writing into'']'
UniqueString understands: 'printon: strm
	[strm append: self]'
UniqueString understands: 'isinfix		↪one-char non-alpha↪
	[self length≠1? [!false]  !(self◦1) isletter≡false]'
UniqueString understands: 'iskeyword | x	↪ends with open or closed colon↪
	[self length≤1? [!false]
	x ← self◦self length.
	x=072?[!true] !x=03]'
UniqueString understands: 'isuneval		↪ends with open colon↪
	[!self◦self length=03]'
UniqueString understands: '= x [!self≡x]'	↪pointer compare↪
UniqueString understands: 'hash [] primitive: 46'	↪just the object pointer↪
UniqueString understands: 'unique'


Class new title: 'Substring';		↪Substrings and permutations↪
	subclassof: Array;
	fields: 'data map'
Substring understands: 'data: data map: map'
Substring understands: '◦ x
	[!data◦(map◦x)]'
Substring understands: '◦ x ← val
	[!data◦(map◦x) ← val]'
Substring understands: 'length
	[!map length]'
Substring understands: 'species
	[!data species]'
Substring understands: 'asStream
	[map isIntervalBy1?	↪direct stream for simple substrings↪
		[!Stream new of: data from: map start to: map stop]
	!Stream new of: self from: 1 to: map length]'


Class new title: 'Interval';		↪Intervals - Integer or Float↪
	subclassof: Array;
	fields: 'start stop step length'
Interval understands: 'from: start to: stop by: step
	[length ← 1+(stop-start/step)]'
Interval understands: '◦ x
	[x<1? [!nil]
	x>length? [!nil]
	!start+(x-1*step)]'
Interval understands: '◦ x ← val
	[user notify: ''Intervals are not for writing into'']'
Interval understands: 'length [!length]'
Interval understands: 'isIntervalBy1
	[!step=1]'\b2f5 40f0B2f4g1f0G5i11f4Ig1f0bG1f5 20f4Bg21u1U30f0iG32f4Ig42u8U144f0G2f5b40f0B2f4g1f0iG20f4Ig1f0bG1f5 34f4Bg21u5U5f0iG19f4Ig67u5U3u1U5f0iG20f4Ig88u8U11f0iG26f4Ig86f0iG27f4Ig42u7U35u8U51u11U66u6U38u6U6u4U110f0iG33f4Ig245u6U7f0iG15f4Ig76u4U9f0iG46f4Ig96f0G2f5b47f0Bi1f4Ig1f0iG35f4Ig1f0bG1f5 33f0B1f5b1f4Bg27u3U134f0iG21f4Ig24f0iG21f4Ig70f0iG17f4Ig29u7U3u5U73f0iG51f4Ig36f0iG10f4Ig39f0iG14f4Ig56f0iG19f4Ig30f0iG15f4Ig32f0iG11f4Ig23f0iG34f4Ig20f0iG28f4Ig98u10U45u1U2u1U93u8U56u7U3f0iG18f4Ig84u9U6f0iG30f4Ig102u8U3f0iG20f4Ig55u1U16f0iG15f4Ig29u4U21f0iG23f4Ig29u6U3f0G2f5b30f0Bi1f4Ig10f0iG18f4Ig1f0bG1f5 38f0B2f5b1f4Bg24u5U6u4U31u1U46u1U3u1U54u6U42u7U44u8U23f0iG35f4Ig104f0G2f5b28f0B2f4g1f0iG28f4Ig1f0bG1f5 52f0B2f5b1f4Bg23u5U7u3U6u3U63u1U80u1U3u1U85u6U36u13U
Interval understands: 'start [!start]'
Interval understands: 'stop [!stop]'


Class new title: 'CoreLocs';		↪Proceed at your own risk...↪
	subclassof: Array;
	fields: 'base length'
CoreLocs understands: 'base: base length: length'\f4g23u5U35u4U11f0G2f5b28f0B2f4g1f0iG27f4Ig1f0bG1f5 41f0B2f5b1f4Bg23u5U6u7U
CoreLocs understands: '◦ x [] primitive: 42'	↪contents of memory location x↪\f4g23u1U23f0iG29f4Ig
CoreLocs understands: '◦ x ← val [] primitive: 43'	↪stores into memory location x↪\f4g23u1U3u5U21f0iG29f4Ig
CoreLocs understands: 'length [!length]'\f4g23u6U


↪STREAMS↪c\2f4g1f5bG7f4Bg1f5bG
Class new title: 'Stream';
	fields: 'array position limit'
Stream understands: 'of: array
	[position ← 0. limit ← array length]'
Stream understands: 'of: array from: position to: limit
	[position ← position-1]'
Stream understands: 'default
	[self of: (String new: 8)]'
Stream understands: 'next	↪simple result↪
	[self myend? [!self pastend]
	!array◦(position ← position+1)] primitive: 17'
Stream understands: 'next ← x		↪simple arg↪
	[self myend? [!self pastend ← x]
	!array◦(position ← position+1) ← x] primitive: 18'
Stream understands: 'append: x | i	↪Array arg↪
	[for⦂ i from: x do⦂
		[self next ← i].
	!x]'
Stream understands: 'myend
	[!position≥limit]'
Stream understands: 'pastend
	[!false]'
Stream understands: 'pastend ← x
	[array ← array grow. limit ← array length.
	!self next ← x]'
Stream understands: 'into: x | i		↪Array result↪
	[for⦂ i to: x length do⦂
		[x◦i ← self next].
	!x]'
Stream understands: 'contents
	[!(array◦(1 to: position)) copy]'
Stream understands: 'skip: x
	[position ← position+x]'
Stream understands: 'reset
	[position ← 0]'
Stream understands: 'end
	[!position≥limit]'
Stream understands: 'position
	[!position]'
Stream understands: 'loc	↪synonym for compiler↪
	[!position]'
Stream understands: 'empty
	[!position=0]'
Stream understands: 'peek | x
	[x← self next? [position ← position-1.  !x]		↪peek at next element↪
	!false]'
Stream understands: '% x | y
	[y← self next?		↪peek for matching element↪
		[x=y? [!y]		↪gobble it if found↪
		position ← position-1. !false]
	!false]'
Stream understands: 'pop		↪use it as a LIFO↪
	[position<1? [!false]
	position ← position-1. !array◦(position+1)]'
Stream understands: 'pop: n | t
	[position<n? [!false]
	t ← self last: n.
	position ← position-n. !t]'
Stream understands: 'last
	[!array◦position]'
Stream understands: 'last: n
	[!(array◦(position-n+1 to: position)) copy]'
Stream understands: 'dequeue		↪use it as a FIFO↪
	[!self dequeue: 1]'
Stream understands: 'dequeue: n | t
	[position<n? [!false]
	t ← (array◦(1 to: n)) copy.
	array◦(1 to: position-n) ← array◦(n+1 to: position).
	position ← position-n. !t]'
Stream understands: 'upto: x | y s
	[s ← Stream default.
	until⦂ [x = (y ← self next)] do⦂
		[s next ← y].
	self skip: ¬1.  !s contents]'
Stream understands: '◦ x ← val
	[!array◦x ← val]'
Stream understands: '◦ x
	[!array◦x]'
Stream understands: 'space
	[self next ← 040]'
Stream understands: 'tab
	[self next ← 011]'
Stream understands: 'cr
	[self next ← 015]'
Stream understands: 'print: obj
	[obj printon: self]'
Stream understands: 'asStream'
Stream understands: 'asVector
	[!(Reader new of: self) read]'
\f5b57f0B2f5b1f4Bg21u3U68u3U7u5U10u3U114u4U2f0iG13f4Ig102u6U5f0iG10f4Ig110u7U8f0iG9f4Ig70u5U43u7U34u9U87u5U9f0iG12f4Ig77u8U58u5U51u5U40u3U43u8U37u3U2f0iG20f4Ig38u5U39u4U52f0iG20f4Ig34u1U25f0iG25f4Ig17f0iG18f4Ig67u3U3f0iG16f4Ig56f0G1f4g10f0G1f4g25u4U100u4U43u5U71uG7Ug3f0iG16f4Ig45uG7g1U164u5U134u1U3u1U46u1U38u5U43u3U43u2U43u6U49u8U24u8U34f0G

↪GRAPHICAL OBJECTS↪c\2f4g1f5bG17f4Bg1f5bG
Class new title: 'Point';
	fields: 'x y'
Point understands: 'x: x y: y'
Point understands: 'x ← x'
Point understands: 'x	 [!x]'
Point understands: 'y ← y'
Point understands: 'y [!y]'
Point understands: '= pt
	[!x=pt x and: y=pt y]'
Point understands: '< pt
	[!x<pt x and: y<pt y]'
Point understands: '≤ pt
	[!x≤pt x and: y≤pt y]'
Point understands: '+ pt
	[!Point new x: x+pt x y: y+pt y]'
Point understands: '- pt
	[!Point new x: x-pt x y: y-pt y]'
Point understands: '* scale
	[!Point new x: x*scale y: y*scale]'
Point understands: '/ scale
	[!Point new x: x/scale y: y/scale]'
Point understands: '| grid
	[!Point new x: x|grid y: y|grid]'
Point understands: 'max: t
	[!Point new x: (x max: t x) y: (y max: t y)]'
Point understands: 'min: t
	[!Point new x: (x min: t x) y: (y min: t y)]'
Point understands: 'rect: p		↪infix creation of rectangles↪
	[!Rectangle new origin: self corner: p]'


Smalltalk insertall: "(black white gray ltgray dkgray backround 
		storing oring xoring erasing)
	with: "(0177777  0  055132  0101202  076575 055132  
		0 1 2 3).
Class new title: 'Rectangle';
	fields: 'origin corner'
Rectangle understands: 'origin: origin corner: corner'
Rectangle understands: 'origin [!origin]'
Rectangle understands: 'origin ← origin'
Rectangle understands: 'corner [!corner]'
Rectangle understands: 'corner ← corner'
Rectangle understands: 'extent
	[!corner-origin]'
Rectangle understands: 'extent ← extent
	[corner ← origin+extent. !extent]'
Rectangle understands: 'has: pt
	[!origin≤pt and: pt<corner]'
Rectangle understands: 'width
	[!corner x - origin x]'
Rectangle understands: 'height
	[!corner y - origin y]'
Rectangle understands: 'blt: dest mode: mode [] primitive: 47'
Rectangle understands: 'bltcomp: dest mode: mode [] primitive: 48'
Rectangle understands: 'brush: dest mode: mode color: color [] primitive: 49'
Rectangle understands: 'color: color mode: mode [] primitive: 50'
Rectangle understands: 'clear: color
	[self color: color mode: storing]'
Rectangle understands: 'clear		↪default is backround↪
	[self color: backround mode: storing]'
Rectangle understands: 'comp
	[self color: black mode: xoring]'
Rectangle understands: 'dragto: dest | b
	[self blt: dest mode: storing.		↪copy to new destination↪
	b ← corner+dest-origin.		↪and clear non-intersecting source↪
	[(origin max: dest) ≤ (corner min: b)?
		[[dest x>origin x?
			[(origin rect: dest x@corner y) clear]
		dest x<origin x?
			[(b x@origin y rect: corner) clear]].
		[dest y>origin y?
			[(origin rect: corner x@dest y) clear]
		dest y<origin y?
			[(origin x@b y rect: corner) clear]] ]
	self clear]
	origin ← dest. corner ← b]'
Rectangle understands: 'inset: p1 and: p2
	[!origin+p1 rect: corner-p2]'
Rectangle understands: 'inset: p1
	[!origin+p1 rect: corner-p1]'
Rectangle understands: 'moveto: pt
	[corner ← corner+pt-origin. origin←pt]'
Rectangle understands: 'moveby: pt
	[origin ← origin+pt. corner ← corner+pt]'
Rectangle understands: 'growto: corner '
Rectangle understands: 'center
	[!origin+corner/2]'
Rectangle understands: 'outline: thick | t
	[t ← (¬1@¬1)*thick.
	(self inset: t) clear: black.  self clear: white]'
Rectangle understands: 'outline 	↪default border is two thick↪
	[self outline: 2]'					↪one thick is two thin↪
Rectangle understands: 'bitsIntoString | extent str
	[extent ← corner-origin.
	str ← String new: 2 * extent y * (extent x+15/16).
	!self  bitsIntoString: str]'
Rectangle understands: 'bitsIntoString: str [] primitive: 51'
Rectangle understands: 'bitsFromString: str [] primitive: 52'
Rectangle understands: 'fromuser
	[↪redbugcursor showwhile⦂ [↪
	while⦂ user anybug do⦂ [].
	until⦂ user anybug do⦂ [origin ← user mp].
	while⦂ user anybug do⦂ [corner ← user mp. self comp. self comp].
	↪]↪ ]'

Class new title: 'Turtle';
	fields: 'pen ink width dir x xf y yf frame'
Turtle understands: 'init
	[ink ← ¬3. pen ← width ← 1. dir ← 270.
	frame ← user screenrect.
	self place: frame center]'
Turtle understands: 'go: length [] primitive: 53'
Turtle understands: 'goto: pt [] primitive: 54'
Turtle understands: 'turn: angle
	[dir ← dir+angle \ 360] primitive: 55'
Turtle understands: 'put: char font: font [] primitive: 56'
Turtle understands: 'show: str font: font | x
	[for⦂ x from: str do⦂
		[self put: x font: font]]'
Turtle understands: 'place: pt
	[x ← pt x. y ← pt y. xf ← yf ← 0]'
Turtle understands: 'width: width'
Turtle understands: 'pen: pen'
Turtle understands: 'ink: ink'
Turtle understands: 'up
	[dir ← 270]'
Turtle understands: 'pendn
	[pen ← 1]'
Turtle understands: 'penup
	[pen ← 0]'
Turtle understands: 'black
	[ink ← ¬3]'
Turtle understands: 'white
	[ink ← ¬1]'
Turtle understands: 'xor
	[ink ← ¬2]'
Turtle understands: 'home		
	[self place: frame center. dir ← 270]'
Turtle understands: 'erase
	[frame clear: 0]'
Turtle understands: 'frame: frame'
\f5b39f0B2f5b1f4Bg20u2U3u2U25u3U25u1U29u3U25u1U28u1U49u1U49u1U49u1U60u1U60u1U65u1U65u1U62u4U71u4U71u5U5f0iG28f4Ig45f0G2f4g164f5bG53f0B1f5b2f4Bg24u7U8u7U34u6U37u8U34u6U37u8U34u6U45u8U69u4U59u5U51u6U51u4U6u5U49u8U6u5U49u6U6u5U6u6U50u6U7u5U49u6U68u5U3f0iG20f4Ig67u4U61u7U44f0iG23f4Ig29f0iG33f4Ig67f0G1f4g28f0G1f4g31f0G1f4g25f0G1f4g63f0G1f4g31f0G1f4g25f0G1f4g78u6U4u4U60u6U60u7U70u7U72u7U35u6U47u8U109u7U3f0iG27f4Ig28f0iG21f4Ig26u14U147u15U48u15U48u8U178f0G1f5b70f0B2f5b1f4Bg21u4U117u3U48u5U44u5U69u4U6u5U46u5U5u5U84u6U62u6U30u4U28u4U28u2U37u5U35u5U35u5U36u5U36u3U36u4U65u5U42u6U9f0G

↪TEXT DISPLAY↪c\2f4g1f5bG12f4Bg1f5bG
Class new title: 'Textframe';
	fields: 'frame para style reply1 reply2 window'
Textframe understands: 'para: para frame: frame
	[window ← frame.
	reply1 ← reply1 ← 0.
	style ← DefaultTextStyle]'
Textframe understands: 'show [] primitive: 57'
Textframe understands: 'show: para
	[para ← para asParagraph. self show]'
Textframe understands: 'charofpt: pt [] primitive: 58'
Textframe understands: 'charnearpt: pt [] primitive: 58'	↪synonym↪
Textframe understands: 'selectchar: char
	[self selectchar: char asInteger] primitive: 59'
Textframe understands: 'ptofchar: char
	[self selectchar: char. !reply1]'
Textframe understands: 'rectofchar: char
	[self selectchar: char. !reply1 rect: reply2]'
Textframe understands: 'comp
	[window comp]'
Textframe understands: 'lineheight
	[!style lineheight]'
Textframe understands: 'scrolln: n
	[!self charofpt: frame origin+(0 @ (n+1*style lineheight))]'
Textframe understands: 'lastshown
	[!reply1]'
Textframe understands: 'window [!window]'
Textframe understands: 'put: para at: pt
	[self put: para at: pt centered: false]'
Textframe understands: 'put: para centered: pt
	[self put: para at: pt centered: true]'
Textframe understands: 'put: para at: pt centered: center
	[para ← para asParagraph.
	window← frame← pt rect: 1000◦1000.
	self ptofchar: para length+1.	↪find corner of text↪
	window growto: reply2.
	[center? [window moveby: pt-window center]].	↪center it↪
	self show]'
Textframe understands: 'printon: strm
	[strm append: ''a Textframe'']'


Class new title: 'Paragraph';
	subclassof: Array;
	fields: 'text runs alignment'
Paragraph understands: 'text: text'
Paragraph understands: 'text: text runs: runs'
Paragraph understands: 'text: text alignment: alignment'
Paragraph understands: 'text: text runs: runs alignment: alignment'
Paragraph understands: 'flushleft
	[alignment ← 0]'
Paragraph understands: 'justify
	[alignment ← 1]'
Paragraph understands: 'center
	[alignment ← 2]'
Paragraph understands: 'flushright
	[alignment ← 4]'
Paragraph understands: 'asParagraph'
Paragraph understands: 'replace: a to: b by: s		↪no run support↪
	[text ← text replace: a to: b by: s.
	runs ← nil]'
Paragraph understands: 'copy: a to: b		↪no run support↪
	[!(text◦(a to: b)) copy]'
Paragraph understands: 'asVector [!text asVector]'
Paragraph understands: 'length
	[!text length]'
Paragraph understands: '◦x
	[!text◦x]'


Class new title: 'TextStyle';
	fields: 'fonts ↪<Vector of Strings or Integers> which are the fonts.
			An integer entry has a vertical offset in the high 8 bits, a 1 in
			the 200-bit for descent, and another font number (zero-relative)
			in the bottom 4 bits↪
		tabandspace ↪<Integer> =256*tabwidth + spacewidth↪
		maxascent ↪<Integer> max ascent for this fontset↪
		maxdescent ↪<Integer> max descent for this fontset↪
		mode ↪<Integer> =0 for normal, =4 for white-on-black↪
		fontnames ↪<Vector of Strings> corresponding to the fonts↪'
TextStyle understands: 'fonts [!fonts]'
TextStyle understands: 'lineheight
	[!maxascent+maxdescent]'
TextStyle understands: 'default
	[self mode: 0; tab: 20; space: 5]'
TextStyle understands: 'tab: t
	[tabandspace ← tabandspace field: leftbyte ← t]'
TextStyle understands: 'space: t
	[tabandspace ← tabandspace field: rightbyte ← t]'
TextStyle understands: 'mode: mode'
TextStyle understands: 'setfont: n name: str | name f	↪should update max-a/de-scent↪
	[FontDict has: (name← str unique)? [fonts◦n ← FontDict◦name]
	f ← File new old named: str + ''.strike''.
	f? [FontDict insert: name with: (fonts◦n ← f intostring)]
	user notify: ''Font '' + str + ''.strike not on this disk'']'
TextStyle understands: 'setoffsetfont: n from: m by: d
	[fonts◦n ← m + [d<0? [0200] 0] + (d lshift: 8)]'


Class new title: 'Dispframe';
	subclassof: Stream;
	fields: 'text'
Dispframe understands: 'rect: r
	[text ← Textframe new para: nil frame: r.
	self of: (String new: 16). self clear]'
Dispframe understands: 'show
	[text show: self contents.
	until⦂ text lastshown≥self position do⦂
		[self dequeue: (text scrolln: 2).
		text show: self contents]]'
Dispframe understands: 'ev | t
	[while⦂ [t ← self request: ''
''] do⦂
		[t≡nil? [self print: nil doit; show]	↪redo↪
		self print: nil ⓢt; show]
	!false]'
Dispframe understands: 'request: s
	[self append: s. !self read]'
Dispframe understands: 'read | n t
	[self show. n ← 0.
	while⦂ true do⦂
		[t ← user kbd.
		t=4? [self skip: 0-n; append: ''done''; show. !false]	↪ctl-d for done↪
		t=8? [n=0?[self show]. self skip: ¬1. n ← n-1.
				user kbck?[]. self show]	↪backspace↪
		t=2? [self skip: ¬1-n. !nil]	↪redo↪
		t=30? [t ← self last: n.	↪do-it↪
			self next ← 30; cr; show. !t]
		t=24?[self reset; append: ''''; show. n←0]
		self next ← t. n ← n+1.
		user kbck? [] self show]]'
Dispframe understands: 'clear
	[self reset. self show]'
Dispframe understands: 'outline
	[text window outline]'
Dispframe understands: 'moveto: pt
	[(text window inset: ¬2@¬2) dragto: pt-(¬2@¬2)]'
\f5b77f0B2f5b1f4Bg24u5U6u6U100u4U44u5U70u9U47u11U57u11U81u9U66u11U79u4U42u10U48u8U90u9U38u6U37u4U6u3U71u4U6u9U70u4U6u3U4u9U103f0iG19f4Ig73f0iG9f4Ig40u8U40f0G2f5b79f0B2f5b1f4Bg24u5U32u5U6u5U32u5U6u10U37u5U6u5U6u10U37u9U44u7U44u6U44u10U44u11U27u8U3u3U3u3U98u5U3u3U73u8U44u6U44u1U15f0G2f5b45f0Bi1f4Ig1f0iG213f4Ig1f0iG3f5bI11f0Bi1f4Ig1f0iG36f4Ig1f0iG3f5bI9f0Bi1f4Ig1f0iG37f4Ig1f0iG3f5bI10f0Bi1f4Ig1f0iG38f4Ig1f0iG3f5bI4f0Bi1f4Ig1f0iG46f4Ig1f0iG3f5bI9f0Bi1f4Ig1f0iG46f4Ig1f0G2f5b1f4Bg24u5U36u10U52u7U62u4U78u6U79u5U32u8U3u5U15f0iG28f4Ig18f0G1f4g16f0G1f4g155f0G1f4g5f0G1f4g57u14U3u5U3u3U37f0G1f4g11f0G1f4g4f0G2f5b65f0B2f5b1f4Bg24u5U56f0G1f4g14f0G1f4g40u4U161u2U154u8U59u4U119f0iG14f4Ig81f0iG9f4Ig34f0iG4f4Ig30f0iG5f4Ig161u5U52u7U50u7U55f0G

↪SETS AND DICTIONARIES↪c\2f4g1f5bG21f4Bg1f5bG
Class new title: 'HashSet';
	fields: 'objects'
HashSet understands: 'default
	[self init: 4]'	↪default initial size↪
HashSet understands: 'init
	[self init: 4]'	↪obsolete↪
HashSet understands: 'init: size
	[objects ← Vector new: (size max: 4)]'
HashSet understands: 'insert: obj | i
	[self findorinsert: obj. !obj]'
HashSet understands: 'has: obj
	[self find: obj? [!true] !false]'
HashSet understands: 'findorinsert: obj | i		↪insert if not found, ↪
	[i ← self findornil: obj? [objects◦i ← obj. !i]
	self growto: objects length*2.	↪may cause table to grow↪
	!self findorinsert: obj]'
HashSet understands: 'find: obj | i	↪!index if found, else false↪
	[i ← self findornil: obj?
		[objects◦i≡nil? [!false] !i]
	!false]'
HashSet understands: 'findornil: obj | i loc	↪!index if found or if room, else false↪
	[loc ← obj hash\objects length+1.	↪does this match the ucode↪
	objects◦loc ≡ nil? [!loc]
	objects◦loc = obj? [!loc]	↪first probe cheap↪
	for⦂ i to: (4 max: objects length / 4) do⦂
		[loc ← loc\objects length+1.		↪better delta later if necess↪
		objects◦loc ≡ nil? [!loc]
		objects◦loc = obj? [!loc]]
	!false]'
HashSet understands: 'delete: obj | i
	[i ← self find: obj?
		[objects◦i ← nil.	↪delete, then rehash↪
		!self growto: objects length]]'	↪returns result of growto↪
HashSet understands: 'growto: size | copy i
	[copy ← self class new init: size.	↪create a copy↪
	for⦂ i from: self do⦂
		[copy insert: i]	↪hash each entry into it↪
	objects ← copy objects]'	↪then take on all its state↪
HashSet understands: 'objects [!objects]'
HashSet understands: 'objects← objects'
HashSet understands: 'contents | obj strm
	[strm ← (Vector new: objects length) asStream.
	for⦂ obj from: objects do⦂
		[obj≡nil? [] strm next← obj]
	!strm contents]'
HashSet understands: 'asStream
	[!self contents asStream]'
HashSet understands: 'notthere: name
	[user notify: name asString+'' not found.'']'


Class new title: 'Dictionary';
	subclassof: HashSet;
	fields: 'values'
↪Dictionaries have the same lookup properties as Sets, except that they also associate a value with each object present.↪
Dictionary understands: 'init: size
	[values ← Vector new: size. super init: size]'
Dictionary understands: 'insert: name with: value
	[self insert: name.  values◦(self find: name) ← value]'
Dictionary understands: '◦ name | x
	[x ← self find: name? [!values◦x]
	self notthere: name]'
Dictionary understands: '◦ name ← value | x
	[x ← self find: name? [!values◦x ← value]
	self notthere: name]'
Dictionary understands: 'lookup: name | x
	[x ← self find: name? [!values◦x] !false]'
Dictionary understands: 'growto: size | name copy
	[copy ← self class new init: size.	↪create a copy of the new size↪
	for⦂ name from: self do⦂
		[copy insert: name with: self◦name]	↪hash each entry into it↪
	self copyfrom: copy]'	↪then take on all its state↪
Dictionary understands: 'copyfrom: dict
	[self objects ← dict objects copy.
	values ← dict values copy]'
Dictionary understands: 'values [!values]'
Dictionary understands: 'clean | name	↪release unreferenced entries↪
	[for⦂ name from: self do⦂		↪slick, huh↪
		[(self◦name) refct = 1 ? [self delete: name]]]'
Dictionary understands: 'insertall: names with: vals | i		↪insert many entries↪
	[for⦂ i to: names length do⦂
		[self insert: names◦i with: vals◦i]]'
Dictionary understands: 'insertall: names		↪default value is nil↪
	[self insertall: names with: (Vector new: names length)]'


Class new title: 'SymbolTable';
	subclassof: Dictionary;
	fields:''
↪SymbolTables have the same properties as Dictionaries, except that an indirect reference is interposed between the value entries and the actual values.  This allows compiled code to point directly at a reference which remains valid although the value changes.  Notice that the define message checks in Undefined for unresolved references which the compiler may have placed there previously.↪
SymbolTable understands: 'insert: name with: x
	[super insert: name with: (ObjectReference new value← x)]'
SymbolTable understands: '◦ name
	[!(super◦name) value]'
SymbolTable understands: '◦ name ← x
	[!(super◦name) value ← x]'
SymbolTable understands: 'ref: name
	[!super◦name]'
SymbolTable understands: 'define: name as: x
	[self has: name? [self◦name ← x]
	Undeclared has: name?
		[super insert: name with: (Undeclared ref: name).
		self◦name ← x.
		Undeclared delete: name]
	self insert: name with: x]'


Class new title: 'MessageDict';
	subclassof: HashSet;
	fields: 'methods ↪<Vector of Strings> which are the compiled methods for each message↪
		literals ↪<Vector of Vectors> which hold pointers to literals used in the methods↪
		code ↪<Vector of Strings> which are the source text for each message↪
		backpointers ↪<Vector of Vectors> which are the tables of text location vs pc for each message↪'
↪Note that insertion and deletion return the updated dictionary.  This is because Smalltalk may be executing out of the dictionary.  The final switch to the new dictionary is made in Class with one atomic assignment.↪
MessageDict understands: 'init: size
	[methods ← Vector new: size.  literals ← Vector new: size.
	code ← Vector new: size.  	backpointers ← Vector new: size.
	super init: size]'
MessageDict understands: 'insert: name method: m literals: l
		code: c backpointers: b | i copy
	[i ← self findornil: name?		↪if name is already there↪
		[methods◦i ← m. literals◦i ← l. code◦i ← c. backpointers◦i ← b.
		self objects◦i ← name]		↪then do it, and return self↪
	copy ← self growto: methods length*2.		↪Otherwise, copy↪
	copy insert: name method: m literals: l
			code: c backpointers: b.	↪and insert↪
	!copy]'		↪and return the new dict without altering old↪
MessageDict understands: 'method: name
	[!methods◦(self find: name)]'
MessageDict understands: 'literals: name
	[!literals◦(self find: name)]'
MessageDict understands: 'code: name
	[!code◦(self find: name)]'
MessageDict understands: 'backpointers: name
	[!backpointers◦(self find: name)]'
MessageDict understands: 'growto: size | name copy i
	[copy ← self class new init: size.	↪create a copy of the new size↪
	for⦂ name from: self do⦂
		[i ← self find: name.	↪hash each entry into it↪
		copy insert: name method: methods◦i literals: literals◦i
				code: code◦i backpointers: backpointers◦i]
	!copy]'	↪copy new parts↪

\f5b48f4Bg22u7U20f0iG20f4Ig24u4U20f0iG8f4Ig24u5U69u7U65u4U63u13U11f0iG21f4Ig84f0iG23f4Ig52u5U10f0iG27f4Ig93u10U14f0iG38f4Ig38f0iG25f4Ig57f0iG17f4Ig79f0iG28f4Ig92u7U52f0iG19f4Ig38f0iG24f4Ig24u7U52f0iG13f4Ig45f0iG23f4Ig30f0iG26f4Ig24u7U36u8U33u8U160u8U52u9U54f0G2f5b72f4Bg1f0iG119f4Ig1f0iG1f4Ig25u5U80u7U6u5U90u1U94u1U6u1U103u7U80u7U254u9U97u6U38u5U9f0iG28f4Ig31f0iG10f4Ig78u10U7u5U12f0iG19f4Ig98u10U9f0iG20f4Ig62f0G2f5b69f4Bg1f0iG390f4Ig1f0iG1f4Ig26u7U6u5U30f0G1f4g28f0G1f4g30u1U57u1U6u1U58u4U49u7U6u3U89f0G1f4g19f0G1f4g76f0G2f5b72f4Bg1f0iG67f4Ig1f5bG12f4Bg1f0iG71f4Ig1f5bG8f4Bg1f0iG62f4Ig1f5bG16f4Bg1f0iG80f4Ig1f5bG3f4Bg1f0iG215f4Ig28u5U174u7U6u7U3u9U5u5U3u13U42f0iG24f4Ig95f0iG27f4Ig43f0iG15f4Ig72f0iG10f4Ig14f0iG44f4Ig28u7U64u9U65u5U61u13U69u7U57f0iG29f4Ig53f0iG23f4Ig119f0iG14f4Ig3f0G

↪INDIRECT REFERENCES↪c\2f4g1f5bG19f4Bg1f5bG

Class new title: 'ObjectReference'
	fields: 'object'
ObjectReference understands: 'value [!object]'
ObjectReference understands: 'value ← object'
ObjectReference understands: 'printon: strm
	[strm append: ''->''; space; print: object class]'

Class new title: 'FieldReference'
	fields: 'object offset'
FieldReference understands: 'value [!object instfield: offset]'
FieldReference understands: 'value ← value
	[!object instfield: offset ← value]'
\1f5b54f4Bg30u5U43u7U40u8U59f0G1f5b60f4Bg29u5U60u7U46f0G
(500)

