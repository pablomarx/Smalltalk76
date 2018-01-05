'From Smalltalk 5.5k XM November 24 on 22 November 1980 at 2:57:08 am.'
\g
"Object"l15000z20000\gbf5 
Class new title: 'Object'
	subclassof: nil
	fields: ''
	declare: '';
	asFollows\gbf5 

Object is the superclass of all classes.  It is an abstract class, meaning that it has no state, and its main function is to provide a foundation message protocol for its subclasses.  Three instances of this class are defined: nil, true, and false.\gi

Comparison\gbf5 
 x [self>xfalse]\gb4B
 x [selfx "In case this is reached by perform:"] primitive: 4\gb4B9i37I
 x [self=xfalse]\gb4B
 x [self<xfalse]\gb4B
= x [selfx]\gb4B
and x [self[x eval] false]\gb7B
and: x [self[x] false]\gb7B
empty [self length = 0]\gb6B
eqv: x [x[self] selffalse]\gb7B
or x [self[true] x eval]\gb6B
or: x [self[true] x]\gb6B
sameAs: object
	[selfobject]\gb16B
xor: x [x[selffalse] self]\gb7B

Classification\gbf5 
class [user croak] primitive: 27\gb6B
is: x [self classx]\gb6B
Is: x  "Is the class x a superclass or class of self"
	[self class  x [true]
	self class Isa: x]\gb7B
isArray
	[false]\gb9B
isnt: x [(self classx)  false]\gb8B
Isnt: x
	[(self Is: x)false]\gb9B
isNumber
	[false]\gb10B

Construction\gbf5 
, x | v
	[v _ Vector new: 2.
	v1 _ self. v2 _ x.  v]\gb4B
asParagraph [self asString asParagraph]\gb12B
asStream [self asVector asStream]\gb9B
asVector | v
	[selfnil[Vector new: 0]
	v _ Vector new: 1. v1 _ self. v]\gb9B
copy		"create new copy of self"
	[self is: Object[self]
	self class copy: self]\gb6Bi25I
inVector | vec
	["Return me as the sole element of a new Vector."
	vec _ Vector new: 1.
	vec1 _ self.
	vec]\gb9B8i48I
recopy	"recursively copy whole structure"
	[self is: Object[self]
	self class recopy: self]\gb7Bi34I

Aspects\gbf5 
asOop [user croak] primitive: 46\gb6B
canunderstand: selector
	[self class canunderstand: selector]\gb25B
error: s [user notify: s]\gb9B
fields
	["Return an Array of all my field names or many of my subscripts."
	self class is: VariableLengthClass
		[self length  50 [1 to: self length]
		 (1 to: 20) concat: (self length-20 to: self length)]
	self class instvars]\gb8B1i65I
hash [user croak] primitive: 46\gb5B
inspect
	[user leaveTop; restartup: (InspectWindow new of: self)]\gb9B
inspectfield: n	"used by variable panes"
	[self class is: VariableLengthClass [self(self fieldsn)]
	self instfield: n]\gb16Bi24I
instfield: n [user croak] primitive: 38\gb13B
instfield: n _ val [user croak] primitive: 39\gb19B
instfields | vec size  i
	["Return an Array of all my field values or many of my elements."
	self class is: VariableLengthClass [selfself fields]
	size _ self class instsize.
	vec _ Vector new: size.
	for i to: size do [veci _ self instfield: i].
	vec]\gb11B16i64I
itself \gb
ref: index
	[FieldReference new object: self offset: index]\gb12B
subError [self error: 'message not defined by subclass']\gb9B
title
	[self class title + '.' + self asOop base8]\gb7B

Printing\gbf5 
asFullString | strm
	[strm _ (String new: 20) asStream.
	self fullprinton: strm. strm contents]\gb13B
asString | strm
	[strm _ (String new: 16) asStream.
	self printon: strm. strm contents]\gb9B
filout | file
	[user displayoffwhile 
		[file _ dp0 file: self title asFileName.
		self fullprinton: file.
		file close]]\gb7B
fullprint | strm
	[strm _ Stream default. self fullprinton: strm.
	user show: strm contents]\gb10B
fullprinton: strm
	[selfnil [strm append: 'nil']
	selffalse [strm append: 'false']
	selftrue [strm append: 'true']
	self class print: self on: strm]\gb19B
print
	[user show: self asString]\gb7B
printon: strm | t [
	strm append: [selfnil ['nil']; false ['false']; true ['true']
		t _ self class title.
		strm append: ['AEIO' has: t1 ['an '] 'a '].
		t]]\gb14B

Compiler Defaults\gbf5 
 code
	[Generator new evaluate: code asStream in: false to: self notifying: self]\gb8B
argsOff: stack
	[self [stack pop: 1]]\gb16B
asRemoteCode: generator
	[ParsedRemote new expr: self]\gb25B
emitForEffect: code on: stack\gb
emitForTruth: trueSkip falsity: falseSkip into: code on: stack
	[self emitForValue: code on: stack.
	(trueSkip jmpSize + falseSkip) emitBfp: code on: stack.
	trueSkip emitJmp: code on: stack]\gb64B
emitForValue: code on: stack\gb
emitsLoad
	[false]\gb11B
emittedReceiver
	[false]\gb17B
emittedVariable
	[false]\gb17B
findMacros: macros compilerTemps: compilerTemps\gb
firstPush
	[1]\gb11B
interactive
	[false]\gb13B
isField
	[false]\gb9B
notify: errorString at: position in: stream
	[self notify: errorString at: position in: stream for: self class]\gb45B
notify: errorString at: position in: stream for: class | syntaxWindow
	[NotifyFlag
		[syntaxWindow _ SyntaxWindow new of: errorString at: position in: stream for: class from: thisContext sender.
		thisContext sender _ nil.
		user restartup: syntaxWindow]
	 user notify: errorString. false]\gb55B
printon: strm indent: level precedence: p forValue: v decompiler: decompiler\gb
remote: generator\gb
returns
	[false]\gb9B
sizeForEffect: nextPush 
	[0]\gb26B
sizeForTruth: trueSkip falsity: falseSkip
		| jump
	[jump _ trueSkip jmpSize.
	self sizeForValue + (jump+falseSkip) bfpSize + jump]\gb44B
sizeForValue
	[0]\gb14B

System Primitives\gbf5 
error | sender op n args i		"after compiling execute: nil installError.  "
	[sender _ thisContext sender.
	op _ sender thisop.
	n _ op numArgs.
	args _ Vector new: n.
	for i from: (n to: 1 by: 1) do
		[argsi _ sender pop].
	self messageNotUnderstood: op withArgs: args from: sender]\gb6B
installError | code old
	[code _ Object md method: error.
	old _ SpecialOops1.
	old asOop(mem3) [user notify: 'Object installError failed']
	Top critical
		[mem3 _ code asOop.
		SpecialOops1 _ code]]\gb13B
messageNotUnderstood: op withArgs: args from: sender
	[thisContext sender _ sender.
	user notify: 'Message not understood: '+op]\gb54B
nail [user croak] primitive: 31		"Nail me in core and return my core address"\gb5B
perform: selector 	"Send the unary message, selector, to self"
	[selector mustTake: 0. self performDangerously: selector]\gb19Bi43I
perform: selector with: arg1 	"Send the 1-argument message, selector, to self"
	[selector mustTake: 1. self performDangerously: selector with: arg1]\gb30Bi48I
perform: selector with: arg1 with: arg2 	"Send the 2-argument message, selector, to self"
	[selector mustTake: 2. self performDangerously: selector with: arg1 with: arg2]\gb41Bi48I
perform: selector with: arg1 with: arg2 with: arg3 	"Send the 3-argument message, selector, to self"
	[selector mustTake: 3. self performDangerously: selector with: arg1 with: arg2 with: arg3]\gb52Bi48I
perform: selector withArgs: vec
	[selector mustTake: vec length.
	self performDangerously: selector withArgs: vec]\gb33B
performDangerously: selector "Send self the message, selector; it had better be unary"
	[user notify: 'can''t perform: nil'] primitive: 102\gb29Bi57I
performDangerously: selector with: arg1  "selector had better take 1 arg"
	[user notify: 'can''t perform: nil with:'] primitive: 102\gb41Bi32I
performDangerously: selector with: arg1 with: arg2  "selector had better take 2 args"
	[user notify: 'can''t perform: nil with:with:'] primitive: 102\gb52Bi33I
performDangerously: selector with: arg1 with: arg2 with: arg3  "selector had better take 3 args"
	[user notify: 'can''t perform: nil with:with:with:'] primitive: 102\gb63Bi33I
performDangerously: selector withArgs: vec
	[vec length=0 [self performDangerously: selector];
		=1 [self performDangerously: selector with: vec1];
		=2 [self performDangerously: selector with: vec1 with: vec2];
		=3 [self performDangerously: selector with: vec1 with: vec2 with: vec3]
	user notify: 'More than 3 args for perform:']\gb44B
PTR [] primitive: 46\gb4B
refct [user croak] primitive: 45\gb6B
startup		"loopless scheduling"
	[self firsttime
		[while self eachtime do [].
		self lasttime]
	false]\gb9Bi21I
swap variable | x  "assign me to variable and return its old value"
	[x _ variable value. variable value _ self. x]\gb15B5i48I
unNail [user croak] primitive: 32		"Release me from being nailed"\gb7B
\g
SystemOrganization classify: Object under: 'Kernel Classes'.\g

"Class"l15000z20000\gbf5 
Class new title: 'Class'
	subclassof: Object
	fields: 'title	"<String> for identification, printing"
			myinstvars "<String> partnames for compiling, printing"
			instsize "<Integer> for storage management"
			messagedict "<MessageDict> for communication, compiling"
			classvars "<Dictionary/nil> compiler checks here"
			superclass "<Class> for execution of inherited behavior"
			environment "<Vector of SymbolTables> for external refs"
			fieldtype'
	declare: 'lastClass lastSelector lastParagraph ';
	veryspecial: 1;
	asFollows\gbf5 

Classes are the molecules of Smalltalk.  The instance fields specify the number and naming of fields for each instance, and the messages define the protocol with which these objects may be communicated.  Classes inherit the fields and message protocol of their superclass.  Locally defined messages will override inherited ones of the same name, and overriden ones may be accessed through the use of super in place of self.  A typical class definition looks like:
	Class new title: 'CodeEditor';
		subclassof: Window;
		fields: 'pared class selector';
		declare: 'editmenu'
This ordering is required, though the subclassof: and declare: messages are optional.  A class definition may be re-executed but, if the fields: clause has changed, all instances of the old class will become obsolete (they will fail to respond to any messages).\gi

Initialization\gbf5 
abstract
	[self fields: nullString]\gb10B
bytesize: n	"non-pointer declaration"
	[selfself realself[self realself bytesize: n]
	fieldtype _ 32+ [n=8 [8] 16]]\gb12Bi25I
classInit		"gets propagated to a dummy instance"
	[self new classInit]\gb11Bi37I
copyof: oldClass subclassof: newSubClass
	[title _ oldClass title.
	 self subclassof: newSubClass.
	 classvars _ oldClass classvars.
	 environment _ oldClass environment.
	 self newFieldsForSubClass: oldClass myinstvars]\gb42B
declare: v | var recom
	[selfself realself[self realself declare: v]
	 [classvarsnil[classvars _ SymbolTable init]].
	 v is: String[self declare: v asVector]
	 recom _ false.
	 [v is: Vector
		[for var from: v do
			[(Smalltalk has: var) or: (Undeclared has: var)[recom _ true]]]
	  (Smalltalk has: v) or: (Undeclared has: v)[recom _ true]].
	 [recom
		[user notify: 'Methods recompile if you proceed, global became local']].
	 [v is: Vector
		[for var from: v do
			[classvars insert: var with: nil]]
	  classvars insert: v with: nil].
	 recom[self compileall]]\gb11B11b2B
environment _ environment [] "for resetting to reread sharing clauses"\gb26B3i
fields: myinstvars | r a b s h		"list of instance variables"
	[messagedict _ MessageDict init.
	 r _ self realself.
	a _ self instvars.
	h_ HashSet init.
	for s from: a do
		[h has: s
			[user notify: s+' is used already (maybe in superclass)']
		h insert: s].
	 self=r[self initClass]
	 a=(b_ r instvars)
		[r environment_ nil; myinstvars_ myinstvars; subclassof: superclass]

	 [r howMany>0[user notify: 'All '+title+'s become obsolete if you proceed...']].

	 classvars _ r classvars.
	 messagedict _ r md copy.

	 	[a lengthb length or a(1 to: b length)b		"just adding new inst fields"
			[user notify: title+ ' methods recompile if you proceed...'.
			 self compileall]].

	 r md init.
	 self fixSubClassesOf: r.
	 r obsolete.
	 Smalltalktitle unique _ self.
	 self initClass]\gb19B13i28I511i29I
fixSubClassesOf: oldClass | n subClass
	[for n from: user classNames do
		[subClass _ Smalltalkn.
		 subClass superclassoldClass
			[Class new copyof: subClass subclassof: self]]]\gb26B
initClass
	[fieldtype _ 16.
	instsize _ self instvars length.
	instsize>256
		[user notify: 'too many instance variables']
	self organization]\gb11B
myinstvars _ myinstvars\gb
newFieldsForSubClass: myinstvars | r a b		"list of instance variables"
	[messagedict _ MessageDict init.
	 r _ self realself.
	 self=r
		[user notify: 'problem in class redefinition. See coment at end of method']
	 (a_ self instvars)=(b_ r instvars)
		[user notify: 'problem in class redefinition. See coment at end of method']
	 [r howMany>0[user cr show: 'All '+title+'s are obsolete.']].
	 classvars _ r classvars.
	 messagedict _ r md copy.
	 r md init.
	 	[a lengthb length or a(1 to: b length)b		"changing inst fields"
			[user cr show: title+ ' recompiled.'.
			 self compileall]].
	 self fixSubClassesOf: r.
	 r obsolete.
	 Smalltalktitle unique _ self.
	 self initClass]
		"Regarding the notifys in this method: It is my understanding
		 that this method will only be invoked when the conditions
		 leading to the notifys are false. If I'm available, I'd like to see
		 any case that results in notification.
				Dave Robson"
\gb33B9i29I439i22I
obsolete		"invalidate further communication"
	[title _ 'AnObsolete'+title.
	classvars _ nil.		"recycle class variables"
	messagedict close.		"invalidate and recycle local messages"
	environment _ self.		"keep me around for old instances"
	superclass _ Object.		"invalidate superclass messages"]
\gb10Bi34I50i25I22i39I23i34I24i32I
realself [Smalltalktitle unique]		"as opposed to possible filin ghost"\gb9B27i
rename: newtitle
		| name newname oldclass category
	[name _ title unique.  newname _ newtitle unique.
		[Smalltalk has: newname
			[oldclass _ Smalltalknewname.
			user notify: 'All ' + newtitle + 's will become obsolete if you proceed'.
			oldclass obsolete]
		category _ SystemOrganization invert: name.
		AllClassNames _ AllClassNames insertSorted: newname.
		SystemOrganization classify: newname under: category].
	Smalltalk delete: name.
	AllClassNames _ AllClassNames delete: name.
	SystemOrganization delete: name.
	title _ newtitle.
	Smalltalk declare: newname as: self]
\gb19B
sharing: table
	[selfself realself[self realself sharing: table]
	environment _ environment asVector , table]\gb16B
subclassof: superclass
	[(superclass isnt: Class) and (superclass isnt: VariableLengthClass)
		[user notify: 'Superclass is not yet defined or not a Class']]\gb24B
title: title
	[self title: (title _ title unique) insystem: Smalltalk]\gb14B
title: name insystem: system | cl
	[superclass _ Object.
	[system has: name
		[cl _ (systemname) class.
		clself class [self]
		user notify: name + ' will change from a ' + cl title + ' to a ' + self class title + ' if you proceed...']].
	system declare: name as: self.
	AllClassNames _ AllClassNames insertSorted: name.
	SystemOrganization classify: name under: 'As yet unclassified']\gb29B
title: t subclassof: s fields: f declare: d
	[t1((t1) asUppercase)
		[user notify: 'Please capitalize each word in class title: ' + t. false]
	self title: t; subclassof: s; fields: f; declare: d]\gb45B
veryspecial: n		"inaccessible fields"
	[instsize _ self instvars length + n]\gb16Bi21I

Access to parts\gbf5 
x [classvarsx]\gb3B
x _ val [classvarsx _ val]\gb9B
fieldNamesInto: collector
	[[superclassnil [] superclass fieldNamesInto: collector].
	(Reader new of: myinstvars) readInto: collector]\gb27B
instsize
["Return the number of user accessable instance fields (self instvars length)."
[fieldtype32 [0] 
	selfClass [instsize-1]
	selfVariableLengthClass [instsize-20]
	instsize]]\gb9B1i78I
instvars
	[self fieldNamesInto: FieldNameCollector default]\gb10B
invertRef: refs "Refs may be a vector (to allow batching)" 
		| cl env source ref inv sym t
	[refs isnt: Vector [(self invert: refs inVector)1]
	env _ (self wholeEnvironment concat: (Undeclared, Smalltalk)) asStream.
	source _ Dictionary init.
	refs transform ref to
		[cl _ self. env reset.
			until
				[(sym _ env next)false [inv _ 'unknown ' concat: ref asOop base8]
				[clnil and symcl classvars [t _ cl title. cl _ cl superclass] t _ false].
				(inv _ sym invertRef: ref)false [false]
				[t []
				 t _ source lookup: sym []
				 source insert: sym with: (t _ Smalltalk invert: sym)].
				inv _ (t concat: ' ') concat: inv]
			 do [].
		inv]
	]\gb16B
Isa: x  "is x on my superclass chain?"
	[superclass  x [true];  nil [false]
	superclass Isa: x]\gb8Bi30I
md [messagedict]\gb3B
myinstvars
	[myinstvars]\gb12B
superclass [superclass]\gb11B
title [title]\gb6B

Organization\gbf5 
classvars [classvars]\gb10B
clean | name	"release unreferenced classvars"
	[for name from: classvars do
		[nameClassOrganization and (classvars ref: name) refct=1
			[classvars delete: name]]]\gb6B
environment
	[environment]\gb13B
organization | o
	[	[classvars  nil[self declare: ClassOrganization]].
	o _ classvars lookup: ClassOrganization.
	o is: ClassOrganizer[o]
	o _ ClassOrganizer new init: messagedict contents sort.
	classvars insert: ClassOrganization with: o.  o]\gb13B
wholeEnvironment
	[(classvars asVector concat: environment asVector) concat:
		[superclassnil [()] superclass wholeEnvironment]]\gb18B

Editing\gbf5 
ed: selector | c s
	[c_ self code: selector. user clearshow: c.
	while (s_ user request: 'substitute: ') do
		[c _ c subst: s for: (user request: 'for: ').
		user clearshow: c]
	self understands: c]\gb13B
edit: selector | para s v
	[para _
		[selector=ClassOrganization
			[self organization asParagraph]
		messagedict has: selector[self code: selector]
		nullString asParagraph].
	self edit: selector para: para formerly: false]\gb15B
edit: selector para: para formerly: oldpara
	[user leaveTop.
	user restartup: (CodeWindow new class: self selector: selector para: para formerly: oldpara)]\gb45B
execute: code		"disposable methods"
	[self understands: 'doit [' + code + ']'.
	self new doit]\gb15Bi20I

Message access\gbf5 
archiveOn: file changesOnly: ch | org m [
	"this should be called only by the system releaser
	(via UserView file:classes:changesOnly:) !!!

	if you want to archive your own classes (useful only if you have stable code
	and intend to clean up afterwards with a vmem write), see Steve.

	write comment and method text on a FileStream for some file.
	ch [write only changes (non-remote String/Paraagraphs)] write everything"

	user cr; show: title.
	org _ self organization.
	["org globalComment always yields a String, so a small kludge is in order"
	ch and (org globalCommentItself is: RemoteParagraph) []
	org globalComment _
		(RemoteParagraph new on: file) fromString: org globalComment].

	"archive in category&alphabetical rather than hash order (messagedict)"
	for m from: org do [
		ch and ((messagedict code: m) is: RemoteParagraph) []
		messagedict code: m _
			(RemoteParagraph new on: file) fromParagraph: (self code: m).
		ch [user space; show: m]]]\gb32B12i56bI34Bi288I55i71I150i69I
bytesof: sel
	[(messagedict method: sel) asBytes]\gb14B
canUnderstand: selector
	[messagedict has: selector [self]
	superclassnil [false]
	superclass canUnderstand: selector]\gb25B
canunderstand: selector
	[messagedict has: selector]\gb25B
code: sel [ 
	"last paragraph returned is cached (mainly for NotifyWindows)"
	[sel  lastSelector and self  lastClass  []
	lastParagraph _ ([
		sel = ClassOrganization  [self organization]
		"if left shift key is down, decompile"	
		user leftShiftKey [self decompile: sel]
		"Paragraph or RemoteParagraph"
		messagedict code: sel]) asParagraph.

	lastClass _ self.
	lastSelector _ sel].
	lastParagraph]\gb10B5i60I122i36I49i28I
compileall | s c "does not modify code, just compiles it"
	[for s from: messagedict do
		[c _ messagedict code: s.
		 self understands: c asParagraph.
		 messagedict code: s _ c "leave it as a remote paragraph"].
	 selfObject[nil installError]]
"to recompile the whole system (check out big changes) execute:
	| n [for n from: AllClassNames do
		[user show: n; cr. (Smalltalkn) compileall.
		Changes init. MessageDict new freeMethods]] "\gb11B238i
copy: sel from: class
	[self copy: sel from: class classified: nil]\gb23B
copy: sel from: class classified: cat "Useful when modifying an existing class"
		| s code
	[sel is: Vector [for s from: sel do [self copy: s from: class classified: cat]]
	sel is: String [self copy: (class organization category: sel) from: class classified: cat]
	code _ class code: sel.  codenil []
	[catnil [cat _ class organization invert: sel]].
	[messagedict has: sel
		[code text=(self code: sel) text []
		user notify: title+' '+sel+' will be redefined if you proceed.']].
	self understands: code classified: cat]\gb38B
decompile: t1 
	[user displayoffwhile [Decompiler new decompile: t1 class: self]]\gb16B
derstands: selector | c		"overstands?  undersits? - forget it"
	[selector is: Vector[for c from: selector do [self derstands: c]]
	(messagedict has: selector)false[] 
	messagedict _ messagedict delete: selector.
	self organization delete: selector.
	lastClass _ lastSelector _ lastParagraph _ nil.
	[Changes has: (c_title+' '+selector) [Changes delete: c]].
	Changes insert: (c_'~'+c).
	c]\gb20B5i37I
describe: method on: strm | sel cls  "append mclass and selector"
	[cls _ self.
	until [clsnil [cls_self. sel_?] sel _ cls md invert: method] do
		[cls _ cls superclass].
	strm append: cls title; space; append: sel]\gb26B11i28I
install: name method: method literals: literals
		code: code backpointers: backpointers | c
	[messagedict _ messagedict insert: name method: method
		literals: literals code: code makeBoldPattern backpointers: backpointers.
	lastClass _ self.
	lastSelector _ name.
	lastParagraph _ code.
	Changes insert: (c_title+' '+name).
	Changes has: (c_'~'+c)[Changes delete: c]]\gb93B
messages [messagedict contents , ClassOrganization]\gb9B
method: sel
	[messagedict methodorfalse: sel]\gb13B
notify: errorString at: position in: stream
	[self notify: errorString at: position in: stream for: self]\gb45B
selectors		"Return a Vector of all my selectors."
	[self messages]\gb11Bi38I
shrink [messagedict _ messagedict shrink]\gb7B
space | a s
	[s _ 0. for a from: messagedict do
		[s _ s + (messagedict method: a) length]
	s]\gb6B
textLocal | s [
	"makes comment and methods local"
	s _ self organization.
	s globalComment _ s globalComment.
	for s from: messagedict do [messagedict code: s _ self code: s]]\gb10B8i31I
understands: code | selector old		"install method"
	[self understands: code classified: 'As yet unclassified']\gb18B16i16I
understands: code classified: heading		"compile and install method"
	[Generator new compile: code asParagraph
		in: self under: heading notifying: self]\gb39Bi28I
whosends: selector | s l a
	[s _ Stream default.
	for a from: messagedict do
		[for l from: (messagedict literals: a) do
			[selectorl[s append: a; space]]]
	s contents]\gb19B

Instance access\gbf5 
allInstances [self allInstancesEver notNil]\gb13B
allInstancesEver | indx vec PCLs i "returns a vector containing all instances of this class mixed with nils"
	["Works for all classes.  Some additional instances may be created after the
	vector is filled but before you get to use it."
	PCLs _ Vmem pclassesOf: self.  "vector of PCLs"
	vec _ Vector new: 128*PCLs length.
	for i to: PCLs length do 
		[(vec[i-1*128+1 to: i*128]) all_ PCLsi].
	thisContext destroyAndReturn: (self fromFreelist: Class instsize fill: vec)]\gb17B18i73I3i124I33i16I
copy: inst | t i
	[t _ self new.
	for i to: self instsize do
		[t instfield: i _ inst instfield: i]
	t]\gb11B
default
	[self new default]\gb9B
fromFreelist: i fill: vec "i = zero order index of freelist in class instance.
	vec = vector in pclasses of all possible instances."
	[user croak] primitive: 60\gb26Bi106I
howMany | v "how many instances of this class are in use now?"
	[v _ self allInstancesEver.
	thisContext destroyAndReturn: v length-(v count: nil)]\gb8B4i50I
init		"init and default get propagated to instances"
	[self new init]\gb6Bi46I
init: n		"init and default get propagated to instances"
	[self new init: n]\gb9Bi46I
instfield:	 i	"prevent user from getting freelist"
	[i > Class instsize [user notify: 'arg too big']
	super instfield: i]\gb14Bi36I
new [user croak] primitive: 28\gb4B
new: length "To allow fixed-length classes to simulate variable-length ones"
	[self new init: length] "By convention"\gb12B
print: inst on: strm | ivars i
	[ivars _ self instvars.
	strm append: '('; append: title; append: ' new '.
	for i to: instsize do
		[strm append: ivarsi; append: ': ';
			print: (inst instfield: i); space]
	strm append: ')']\gb21B
printon: strm
	[strm append: 'Class ' + title]\gb15B
recopy: inst | t i
	[t _ self new.
	for i to: self instsize do
		[t instfield: i _ (inst instfield: i) recopy]
	t]\gb13B

Filin and Filout\gbf5 
asFollows | s heading selector p [
	selfself realself[self realself asFollows]
	heading _ 'As yet unclassified'.

	"handles Bravo or Press (Smalltalk generated) files"
	while ((p _ FilinSource nextParagraph) and (s _ p text)  '') do [
		[s1 = 015 [
			"throw away initial cr before comment and headings"
			s _ s copy: 2 to: s length]].
		p runs2
			= 2 "italic" [self organization globalComment _ s];
			= 0121 "5, bold" [heading _ s]
		self canunderstand: (
			selector _ self understands: p classified: heading) [
				user show: selector; space. messagedict purge: selector]
		user show: '(an uncompiled method) ']]\gb10B108i50I94i49I54i6I53bf5 7Bf0 
changelist: cat [title unique, (self organization category: cat)]\gb16B
definition | strm		"return a string that defines me (Class new title etc.)"
	[strm _ (String new: 50) asStream.
	self printdefon: strm.
	strm contents]\gb11B8i56I
endCategoryOn: pstrm\gb
endChangesOn: pstrm
	[pstrm print: '' asParagraph]\gb21B
filout [user displayoffwhile [
	(dp1 file: title+'.st.') filoutclass: self.
	self noChanges]]\gb7B
filoutCategory: cat
	[(dp1 file: (title+'-'+cat+'.st') asFileName) filout: (self changelist: cat)]\gb21B
filoutOrganization	"So we can merge separate work on organization"
	[user show: title; cr.
	user displayoffwhile
		[(dp0 file: title+'.org.')
			append: title+' organization fromParagraph:'; cr;
			append: self organization asParagraph text asString;
			append: 'asParagraph'; close]]\gb19Bi47I
noChanges | s t
	[t_ title+' *'.
	for s from: Changes contents do
		[(s1=126 "~" and (t match: s(2 to: s length)))
		 or (t match: s)
			[Changes delete: s]]]\gb10B
paraprinton: strm		"Strm is actually a ParagraphPrinter"
		| para frame s heading org
	[para _ ('"'+title+'"') asParagraph.
	para maskrunsunder: 0361 to: 0121.	"Font _ 5, Bold"
	frame _ strm defaultframe.
	strm frame _ 15000frame origin y rect: 20000frame corner y.
	strm print: para.
	strm frame _ frame.
	strm print: ((self definition+';
	asFollows') asParagraph maskrunsunder: 0361 to: 0121).
	org _ self organization.
	strm print: ('
'+org globalComment) asParagraph allItalic.
	for heading from: org categories do
		[self printCategory: heading on: strm]
	self endChangesOn: strm.
	strm print: ('SystemOrganization classify: '+title+' under: '''+
		(SystemOrganization invert: title unique)+'''.') asParagraph.
	[self  Class or: self  VariableLengthClass [] self canunderstand: classInit
		[strm print: (title+' classInit') asParagraph]].
	]\gb19Bi37I104i16I
printCategory: s on: pstrm | sel
	[self startCategory: s on: pstrm.
	for sel from: (self organization category: s) do
		[self printMethod: sel on: pstrm].
	self endCategoryOn: pstrm]\gb27B
printdefon: strm | s		"print my definition on strm"
	[strm append: self class title;
		append: ' new title: ';
		"title is probably unique, but make sure. then we want it as a 'String' "
		print: title unique asString.
	strm cr; tab; append: 'subclassof: ';
		append: [superclassnil['nil'] superclass title].
	strm cr; tab; append: 'fields: '; print: myinstvars.
	strm cr; tab; append: 'declare: '''.
	for s from: classvars contents do
			[s=ClassOrganization[]
			strm append: s; space]
	strm append: ''''.
	[fieldtype=16[]
		strm semicrtab; append: 'bytesize: '; print: fieldtype-32].
	[instsize = (s_ self instvars) length[]
		strm semicrtab; append: 'veryspecial: '; print: instsize-s length].
	[environmentnil[]
		for s from: environment do
			[strm semicrtab; append: 'sharing: '; append: (Smalltalk invert: s)]]]\gb17B5i29I
printMethod: sel on: pstrm
	[pstrm print: (self code: sel).
	messagedict purge: sel]\gb28B
printout [user displayoffwhile [
	(dp0 file: title+'.press.') printoutclass: self]]\gb9B
printoutCategory: cat
	[(dp0 file: (title+'-'+cat+'.press') asFileName) printout: (self changelist: cat)]\gb23B
readfrom: strm [self readfrom: strm format: nil]\gb15B
readfrom: strm format: f [
	self new readfrom: strm format: f]\gb25B
startCategory: s on: pstrm
	[pstrm print: (('
'+s) asParagraph maskrunsunder: 0361 to: 0121).		"Font 5, Bold"
	]\gb28B67i14I
startChangesOn: pstrm
	[pstrm print: (('
'+title+' asFollows') asParagraph maskrunsunder: 0361 to: 0121).		"Font 5, Bold"
	]\gb23B85i14I

System Organization\gbf5 
category [SystemOrganization invert: self title unique]\gb9B
category: cat
	[cat is: String [SystemOrganization add: self title unique under: cat]
		user notify: 'Category name must be a String']\gb15B
moveFromCat: cat1 to: cat2
	[(cat1 is: String) and (cat2 is: String) 
			[SystemOrganization move: self title unique from: cat1 to: cat2]
		user notify: 'Category name must be a String']\gb28B
\g
SystemOrganization classify: Class under: 'Kernel Classes'.\g

"Context"l15000z20000\gbf5 
Class new title: 'Context'
	subclassof: Object
	fields: 'sender "<Context> from which this message was sent"
		receiver "<Object> to which this message was sent"
		keep "<true, nil> nil means reclaimable"
		method "<String>, the encoded method"
		tempframe "<Vector> to hold temporaries and a stack"
		pc "<Integer> marks progress of execution in method"
		stackptr "<Integer> offset of stack top in tempframe"'
	declare: 'arrayFld positionFld limitFld ';
	asFollows\gbf5 

A context keeps track of the progress of a method\gi

Initialization\gbf5 
cleancopy
	[Context new
		sender: sender
		receiver: receiver
		method: method
		tempframe: tempframe copy
		pc: pc
		stackptr: stackptr]\gb11B
copy
[
	 Context new
			sender: sender
			receiver: receiver
			method: method
			tempframe: tempframe
			pc: pc
			stackptr: stackptr
]\gb5B
sender: sender receiver: receiver
		method: method tempframe: tempframe pc: pc stackptr: stackptr\gb

Access to parts\gbf5 
caller [sender]
\gb7B
getPT: i  [  tempframei ]\gb10B
mclass | selector mclass		"return the class in which method was found"
	[sender  nil  [receiver class]
	selector _ self selector.
	mclass _ receiver class.
	until mclass  nil do
		[(mclass method: selector)  method  [mclass]
		mclass _ mclass superclass].
	receiver class]\gb7B17i46I
method
	[method]\gb8B
pc [pc]\gb3B
receiver
	[receiver]\gb10B
selector | mclass selector		"return the selector for my method"
	[selector _ sender thisop.
	selector(1~19)='performDangerously:'
		[mclass _ receiver class.		"special work for perform"
		until [mclass  nil or (selector_mclass md invert: method)] do
			[mclass _ mclass superclass]
		selectorfalse[confused] selector]
	selector]\gb9B19i35I96i28I
sender [sender]\gb7B
sender_ sender []\gb15B
setPT: i to: n  [ tempframei _ n ]\gb16B
stackIndex "Return the subscript in tempframe of my top of stack."
	[stackptr+1]\gb11Bi55I
swapSender: coroutine | oldSender
	[oldSender _ sender. sender _ coroutine. oldSender]	\gb22B
tempframe
	[tempframe]\gb11B
totalPT [ (method5)+1 ]\gb8B

Control structures\gbf5 
for var1 from: expr1 with var2 from: expr2 do stmt | s1 s2
	[s1 _ expr1 asStream. s2 _ expr2 asStream.
	while [(var1 value _ s1 next) and (var2 value _ s2 next)] do stmt eval]
\gb54B

Debugging\gbf5 
debug | t v
	[self print.
	while [user cr. t _ user request: '*'] do  "until ctrl-d"
		[v _ Generator new evaluate: t asStream in: false to: self notifying: nil.
		debugret=v[self print] v print]
	debugret]\gb6B66i14I
printon: strm | mc
	["Print the selector which invoked this Context
	  and the class in which code was found for that selector"
	 mc _ self mclass.
	 strm append: mc title. sendernil []
	 [receiver is: mc[] strm append: '('+receiver class title+')'].
	 strm append: ''; print: self selector]\gb14B7i106I
restartWith: method
	[tempframe _ tempframe copy: 1 to: method3.
	self restart]\gb21B
stack | a strm
	["Return a Vector of me and all my derivative contexts."
	strm _ (Vector new: 20) asStream.
	strm next _ a _ self.
	"when user notifty is fixed, a sender can become a caller"
	until (a_a sender)nil do [strm next _ a].
	strm contents.]\gb6B11i55I61i27I10i10I
thisop | a		"return the message selector just sent"
	[a _ methodpc.
	a0320 [self litof: a-0320]
	a0260 [SpecialOops(10+a-0260)]
	method(pc-1)=0214 [self litof: a]
	confused]\gb7B3i41I
trace | strm a
	[strm _ Stream default. self printon: strm.
	a _ sender. until anil do
		[strm cr. a printon: strm. a _ a sender]
	strm contents]\gb6B
variableNamesInto: dest with: block | class selector parser
	["For each method variable name, call
			dest declaration: block name: string asArg: <true or false>
		If cant find source code, call dest notify: "
	class _ self mclass.
	selector _ class md invert: method
		[parser _ Parser new from: (class code: selector) asStream to: dest.
		parser pattern: block; temporaries: block; terminate]
	dest notify: 'thisContext is not running a currently defined method']\gb36B26i147I
verifyFrames  | c "be sure frames on stack aren't nil"
	[c _ self.
	 until cnil do
		[c tempframenil
			[user notify: 'Sorry, that stack has been released -- proceeding is impossible'; restart]
		 c _ c sender]]\gb14B4i36I

Simulation\gbf5 
docode: code toclass: class | i v
	[[(i_code2) 0 
		[i = 1   [self];
			= 30  [v _ self pop. v push: self. v];
			= 40  [v _ self pop instfield: code5 + 1. self push: v];
			= 41  [user notify: 'Field_ primitive unimplemented'];
			= 87  [ receiver "PriorityInterrupt run: newContext"];
			= 101  [user notify: 'Doprimitive unimplemented'];
			= 102  [self performing: code4 toclass: tempframe(stackptr+1)]
		 (v _ self doprimitive: code)  failed []
		 stackptr _ stackptr-(code4+1). self push: v]].
	 self newToRun: code]\gb28B
dojump: displacement
	[pc _ pc+displacement]\gb22B
dopop
	[stackptr _ stackptr-1]\gb7B
doprimitive: code
	[failed] primitive: 101\gb19B
doremotereturn | t f
	[t _ self pop. f _ self pop. f push: t]\gb15B
doreturn | t
	[t _ tempframe(stackptr+1). tempframe _ nil. sender push: t]\gb9B
dostore | byte
	[byte _ method(pc_ pc+1).
	 byte<020 [self smashField: byte];
			<040 [self smashTemp: byte-020];
			<0100 [user notify: 'Store into literal'];
			<0160 [self smashLitInd: byte-0100];
			<0170 [self instfield: (byte-0157) _ tempframe(stackptr+1)];
			=0210 [self smashField: self nextByte];
			=0211 [self smashTemp: self nextByte];
			=0213 [self smashLitInd: self nextByte]
	 user notify: 'Illegal store'
	]\gb8B
dosuper | byte
	[byte _ self nextByte.
	[byte=0214 [byte _ self nextByte+0320]].
	byte<0260 [user notify: 'non-selector after super']
	self sendmess: nil byte: byte toclass: 
		(self litof: method6-8/2) value superclass]\gb8B
doUnique | r e "cause  _ to be done for a UniqueString inside str: inside intern:"
	[r _ tempframe(2+stackptr). "receiver"
	"already know class is UniqueString"
	e _ 'bad special message in super'.
	(method  (UniqueString md method: str:))  false [user notify: e]
	"ours, now put result of str: on the stack"
	self push: (r _ r str: tempframe1 "arg").
	method(method length)  0203 "return" [user notify: e]
	"trick this method into returning"
	pc _ method length -1.
	self]\gb9B
help
	["Here is how to use the Smalltalk simulator.

	thisContext runsimulated [ place here the code you to simulate ].

	Some classes in Smalltalk may not be subclassed.  Some messages
	may not be overridden.  initSimulator tells the details. "]\gb6B76b35B
initSimulator | i "these class variables of Context are used by instfield: to simulate what the microcode does to objects."
	["  Context declare: 'positionFld arrayFld limitFld'.    "
	"Rules:  There may not be a subclass of Integer.
			(This is so +, -, <, >, , , =,  may not be overridden).
	The following messages may NOT be redefined by any class.
		 (from class Object).
		class (from class Object).
	The following messages may NOT be redefined by any VariableLengthClass.
		length (from Vector, String)"

	i _ Stream instvars.  "We need to peek inside instances of Stream"
	positionFld _ i find: 'position'.
	arrayFld _ i find: 'array'.
	limitFld _ i find: 'limit'.
	]\gb14B
litof: a
	[(method word: a+4) asObject]\gb10B
newToRun: code | r v i
	[r _ self pop. v _ Vector new: code3.
	 for i from: (code4 to: 1 by: 1) do "Move args to new tframe"
		[vi _ tempframe(2+(stackptr _ stackptr-1)).
		tempframe(stackptr+2) _ nil	"Nil args on caller's stack"
		].
	 self class new sender: self receiver: r method: code
		tempframe: v pc: code6 stackptr: code5 - 1. "Allocate a new Context"
	]\gb15B7b2B
nextByte
	[method(pc _ pc+1)]\gb10B
nonEmptyStack
	[(stackptr1)]\gb15B
performing: nargs toclass: class | i sel
	[i _ stackptr-nargs.
	sel _ tempframe(i+1).	"Selector is first arg"
	while i<stackptr do
		[tempframe(i+1) _ tempframe(i+2).
		i _ i+1].
	stackptr _ stackptr-1.
	self sendmess: sel byte: 0320 toclass: class]\gb33B
pop
	[tempframe(2+ (stackptr_ stackptr-1))]\gb5B
push: n "Push n on top of stack"
	[tempframe(1+(stackptr_stackptr+1)) _ n]\gb8B
pushField: i
	[tempframe(1+(stackptr_stackptr+1)) _ receiver instfield: i+1]\gb14B
pushLit: i
	[tempframe(1+(stackptr_stackptr+1)) _ (method word: i+4) asObject]\gb12B
pushLitInd: i
	[tempframe(1+(stackptr_stackptr+1)) _ (method word: i+4) asObject value]\gb15B
pushTemp: i
	[tempframe(1+(stackptr_stackptr+1)) _ tempframe(i+1)]\gb13B
restart
	[pc _ method6. stackptr _ method5-1]\gb9B
runsimulated cntxt | ctx b i "To use the simulator say...
		thisContext runsimulated [your code]. "
	["turn off use of BitBlt by Strings"
	b _ StringStringBlter.
	StringStringBlter _ false.

	cntxt push: self.  ctx _ cntxt.
	until ctxself do [ctx _ ctx step].

	"restore state of StringBlter"
	StringStringBlter _ b.
	self pop]\gb20B
sendmess: sel byte: byte toclass: class | cl code
	[cl _ class.  until clnil do
		[[byte<0320 "Is it a special message?"
			[self specialmess: byte toclass: cl [self] "Can we perform it?"
			 sel _ SpecialOops(byte-0246)] "Send the special message selector"
		  selnil [sel _ self litof: byte-0320]]. "Send the selector from the literals"
		 code _ cl md methodorfalse: sel [self docode: code toclass: cl]
	  	 cl _ cl superclass]. "Try up the superclass chain"
	 user notify: ('Simulated message not understood: ' concat: sel asString)]\gb40B9b2B297f1 1f0 
simulate cntxt
	[cntxt push: thisContext.  cntxt inspect]\gb17B
smashField: i
	[receiver instfield: i+1 _ tempframe(stackptr+1)]\gb15B
smashLitInd: i
	[(self litof: i) value _ tempframe(stackptr+1)]\gb16B
smashTemp: i
	[tempframe(i+1) _ tempframe(stackptr+1)]\gb14B
specialmess: byte toclass: class | "Return false if cannot do it here, else do exactly what the microcode does."
	[byte<0270  "+, -, <, >, , , =, "
		[self specialmess: byte toclassInteger: class];
		<0300[false];  "unused"
		<0304   " , _, next, next_ "
			[self specialmess: byte toclassArray: class];
		=0304 "length"
			[ [classString[] classVector[] false]. self push: (self pop length)];
		=0305 ""  [self push: self popself pop]
	false]\gb33B
specialmess: byte toclassArray: class | r n d i s l easy "cause , _, next, next_  to happen"
	[d _ stackptr.  r _ self pop.
	[byte=0301 or byte=0303 [n _ self pop]]. " _ or next_ "
	[byte<0302
			[   "  or _ "
			[classVector[] classString[] stackptr _ d. false].
			i _ self pop. l _ r length]
		classStream " next or next_ "
				[s _ r. i _ (s instfield: positionFld)+1.
				l _ (s instfield: limitFld). r _ (s instfield: arrayFld).
				 [r classVector[]; String[]; Interval[] stackptr _ d. false].
				]
		stackptr _ d. false].
	
	easy _ [r classVector[true]; String[true]; Interval[true] false].
	[(i class  Integer) and (l class  Integer)
				[1i and il  " bounds check "
					[[easy [byte=0301 or byte=0303 "in the easy case, we cheat for speed"
							[ri _ n]  " _ or next_ "
							n _ ri]  "  or next "
						"subclass of Vector or String"
						byte=0301 or byte =0303 [r instfield: i _ n] " _ or next_ "
								n _ r instfield: i].
					 self push: n.
					 [byte>0301[s instfield: positionFld _ i]]. self]]].
	stackptr _ d. false]\gb38B
specialmess: byte toclassInteger: class | r n "If class is Integer, do arithmetic"
	[class  Integer
			[r _ self pop. n _ self pop.
			 r class  Integer
				[self push: [byte
					=0260 [r+n];  =0261 [r-n];
					=0262 [r<n];  =0263 [r>n]; =0264 [rn];  =0265 [rn];
					=0266 [r=n];  =0267 [rn]]]
			 stackptr _ stackptr+2. false]
	false]\gb40B
step | byte t "Execute the next byte code and return the current Context"
	[byte _ method(pc _ pc+1).
	[byte<0200 "load"
			[byte<020 [self pushField: byte];
				<040 [self pushTemp: byte-020];
				<0100 [self pushLit: byte-040];
				<0160 [self pushLitInd: byte-0100];
				<0170 [self push: (self instfield: byte-0160+1)]
			 self push: SpecialOops(byte-0170+2)];
		<0220
			[byte=0200 [self dostore; dopop];
				=0201 [self dostore];
				=0202 [self dopop];
				=0203 [self doreturn];
				=0204 [self doremotereturn];
				=0205 [self push: self];
				=0206 [self dosuper];
				=0210 [self pushField: self nextByte];
				=0211 [self pushTemp: self nextByte];
				=0212 [self pushLit: self nextByte];
				=0213 [self pushLitInd: self nextByte];
				=0214 [self sendmess: nil byte: self nextByte+0320
								 toclass: (tempframe(stackptr+1)) class]
			 user notify: 'Unimplemented instruction code'];
		<0260 "jump"
			[t _ [byte<0240[(byte land: 7)+1]
					"short, just mask off bfp bit for displacement"
			 (byte land: 7)-4*256+self nextByte].	"long, calculate displacement"
			[(byte land: 010)0[self popfalse[self dojump: t]]
					"bfp, do branch if top is false"
			 self dojump: t].	"unconditional, do the branch"
			self]
	 self sendmess: nil byte: byte toclass: (tempframe(stackptr+1)) class]
	]\gb5B

Remote evaluation\gbf5 
eval [user croak] primitive: 30\gb5B
remoteCopy
	| tResult
[
	tResult _ RemoteContext new
		sender: sender
		receiver: receiver
		method: method
		tempframe: tempframe
		pc: pc+2
		stackptr: stackptr.
	tResult initialize.
	 tResult
]\gb12B9b1B

Interpretation\gbf5 
have: receiver interpret: method
	["Warning -- someone must be holding method literals."
	"Warning -- do not call as self have:interpret: or cycle will result"
	tempframe _ (Vector new: method3).
	self restart. self interpretFor: thisContext sender]\gb34B1i54I2i69I
interpret: objectCode with: tframe
	["interpret in new context with tempframe tframe"
	"Warning -- someone must be holding objectCode literals."
	"Warning -- do not call as self interpret:with: or cycle will result"
	(Context new
		sender: nil receiver: receiver
		method: objectCode tempframe: tframe
		pc: objectCode6 stackptr: objectCode5-1)
	  interpretFor: thisContext sender]\gb36B1i48I2i58I2i69I
interpretFor: sender  "resume execution"
	[PriorityInterrupt new run: self]\gb22Bi18I

Deallocation\gbf5 
destroyAndReturn: value
	[thisContext sender _ sender.
	tempframe all _ nil.
	value]\gb25B
eraseFully
	[tempframenil []
	tempframe all _ nil. tempframe _ nil]\gb12B
release | s		"release frames to break cycles"
	[ [tempframenil[] tempframe all_ nil. tempframe _ nil].
	receiver_ nil.
	sendernil[] 
	"not sure if this works correctly"
	"[sender Isnt: Context[
		until (sender Is: Context) do
			[s_ sender instfield: 1.
			sender instfield: 5_ nil.
			snil[self] sender_ s]]]."
	sender release]\gb13Bi32I94i32I
releaseFully | c 	"nullify frames to break cycles"
	[c _ self.
	 until cnil do [c eraseFully. c _ c sender]]\gb13B5i32I
releaseTo: pContext
[
	sender  pContext  [ sender _ nil. ]
		sender releaseTo: pContext.
		sender _ nil.
]\gb20B
\g
SystemOrganization classify: Context under: 'Kernel Classes'.\g

"RemoteContext"l15000z20000\gbf5 
Class new title: 'RemoteContext'
	subclassof: Context
	fields: ' 
		fSavedPC
		fSavedStackptr
	'
	declare: '';
	asFollows\gbf5 

CONTEXT FOR REMOTE CODE\gi

REMOTE CONTEXT\gbf5 
caller
[
	 tempframe  (fSavedStackptr+2)
]\gb7B
cleancopy
	| tResult
[
	tResult _ RemoteContext new
		sender: sender
		receiver: receiver
		method: method
		tempframe: tempframe copy
		pc: pc
		stackptr: stackptr.
	tResult initialize.
	 tResult
]\gb11B
initialize
[
	fSavedPC _ pc.
	fSavedStackptr _ stackptr.
]\gb11B
releaseTo: pContext
[
	tempframe  (fSavedStackptr+2)  pContext 
		[ tempframe  (fSavedStackptr+2) _ nil. ]
		tempframe  (fSavedStackptr+2) releaseTo: pContext.
		tempframe  (fSavedStackptr+2) _ nil.
]\gb20B
restart
[
	pc _ fSavedPC.
	stackptr _ fSavedStackptr.
]\gb8B
\g
SystemOrganization classify: RemoteContext under: 'Kernel Classes'.\g

"UserView"l15000z20000\gbf5 
Class new title: 'UserView'
	subclassof: Object
	fields: 'screenrect "<Rectangle> current screen size"
		vtab "<Integer=0mod2> offset from hardware top"
		htab "<Integer=0mod16> offset from hardware left"
		scale "<Integer=1 or 2> 2 means double bits mode"
		color "<Integer=0 or 1> 1 means reverse field"
		projectWindow "my representative in an overview"
		disp "<dispframe> default message stream"
		sched "<Vector> Windows in this view"'
	declare: 'currentCursor mxoffset myoffset screenMenu ';
	asFollows\gbf5 

This is a melting-pot, incorporating the notions of user interaction (mouse, keyboard), display context (current screen view), and global operations (reading the clock, leaving the system).\gi

Mouse, Cursor, Keys\gbf5 
anybug [self buttons >0 or (mem0177100) < 0]\gb7B
anykeys [self keyset>0]\gb8B
bluebug [self buttons=2]\gb8B
buttons
	[7-(mem0177030 land: 7)]\gb9B
currentCursor [currentCursor]\gb14B
currentCursor: c | coff oldpt [
	oldpt _ self mp.
	currentCursor _ c.
	coff _ c offset.
	mxoffset _ coff x - htab.
	myoffset _ coff y - vtab.
	self cursorloc _ oldpt]\gb17B
cursorloc _ pt 
	[mem0424 _ pt x - mxoffset*scale.
	mem0425 _ pt y - myoffset*scale]\gb17B
kbck | t
	[t _ self rawkbck[kbMapt] self purgealittle. false ]\gb5B
kbd [until self rawkbck do [self purgealittle]
	kbMapself rawkbd]\gb4B
kbd: char
	["stuff char into the event queue"
	[char is: String [char _ char1]].
	Events next _
		UserEvent new
		x:				self x										"event x"
		y:				self y									"event y"
		type:			1											"2=up, 1=down"
		stroke:		(kbMap find: char)					"1-336"
		elapsed:		Events	elapsedtime				"1-32767 sixtieths of a sec"
		time:			Events time + Events elapsedtime.]\gb11B1i33I93i9I24i9I23i14I35i7I35i28I
kbdnext | event [
	"returns next character (mapped) if any; otherwise false"
	while [
		(event _ Events dequeue) or
		(event _ Events primitiveDequeue)] do [
		event isKbdDown [kbMapevent stroke]].
	"self rawkbck [kbMapEvents next stroke]"
	false]\gb8B7b1B
keyset
	["Fix a bug in sysdefs."
	037 - ((mem0177030 lshift: 3) land: 037)]\gb8B1i23I
leftShiftKey ["left shift key down?" (mem0177036 land: 0100) = 0]\gb13B
mp
	[scale=2
		[Point new
		x: mem0424 + mxoffset / 2
		y: mem0425 + myoffset / 2]
	Point new
		x: mem0424 + mxoffset
		y: mem0425 + myoffset]\gb4B
mpnext [
	"return next mouse point if red button or tablet is down; otherwise false"
	self redbug [self mp]
	false]\gb7B4i72I
nobug
	[self anybug  false]\gb7B
rawkbck | event				"flush event queue until down keyboard event or queue empty."
			[while (event _ Events peek) do
				[event isKbdDown [event stroke] Events next].
			false							"if queue empty, return false"
			]\gb8B11i61I106i30I
rawkbd | stroke
			[until (stroke _ self rawkbck) do [].			"wait for activity"
			Events next.  stroke								"if key down, pop queue and return stroke"
			]\gb7B54i19I33i42I
redbug [self buttons=4 or (mem0177100) < 0]\gb7B
tablet [(mem0177100)  0]\gb7B
tabletabsolute [mem0126 _ 1]\gb15B
tabletbug [(mem0177100) < 0]\gb10B
tabletrelative [mem0126 _ 1]\gb15B
waitbug
	[until self anybug do [] self mp]\gb9B
waitclickbug
	[self waitnobug. self waitbug]\gb14B
waitnobug
	[while self anybug do [] self mp]\gb11B
waitnokey [until self keyset=0 do [self rawkbck]]\gb10B
x [mem0426 - htab		"cursorx, horiz tab adjusted"]\gb2B19i29I
y [mem0427 - vtab		"cursory, vert tab adjusted"]\gb2B19i28I
yellowbug [self buttons=1]\gb10B

Screen Views\gbf5 
bugScreenMenu
	["see classInit"
	screenMenu bug
		=1[projectWindownil[] projectWindow runParent];
		=2[user quit];
		=3[self restartup: ProjectWindow init];
		=4[self restartup: BrowseWindow default];
		=5[self restartup: (CodeWindow new class: UserView selector: workspace
				para: (UserView code: workspace) formerly: false)];
		=6[user displayoffwhile [self reclaim]]
	]\gb15B
color: color scale: scale	[self install]\gb26B
copyIn: p
	[UserView new
		screenrect: screenrect copy
		vtab: vtab htab: htab scale: scale color: color
		projectWindow: p
		disp: disp sched: ()]\gb11B
displayoffwhile expr | t v
	["t _ mem0420. mem0420 _ 0."
	t _ mem067. mem067 _ 58 "disp text frame maxY/2 ?".
	v _ expr eval.
	mem067 "0420" _ t. v]\gb22B
install
	[self screenextent: screenrect extent tab: htabvtab]\gb9B
projectWindow [
	[projectWindownil
		[projectWindow _ ProjectWindow new.
		projectWindow userview: self changes: Changes parent: projectWindow]].
	projectWindow]\gb14B
reconfigure [] primitive: 62\gb12B
restoredisplay
	[mem0420 _ 060. mem067 _ screenrect height/2]\gb16B
screenextent: extent tab: tab [
	mem065 _
		(color*040000)+[scale=2[0100000] 0]+(tab x/16*0400)+(extent x/16|2).
	mem067 _ extent y*scale/2.
	mem063 _ 1 max: tab y/2.
	htab _ tab x|16.
	vtab _ mem063*2.
	screenrect _ 00 rect: (extent x|32)(extent y|2).
	self currentCursor: currentCursor;
		reconfigure; restore]\gb30B
screenrect [screenrect]\gb11B
screenrect: screenrect vtab: vtab htab: htab scale: scale color: color projectWindow: projectWindow disp: disp sched: sched\gb

Window Scheduling\gbf5 
leaveTop		"leave the top window if there is one"
	[sched length=0[]
	(sched1) leave]\gb10B1i36I
promote: window
	[sched promote: window]\gb17B
restart | i 
			[[Events  nil 
				[Events _ EventQueue init. "Top init3.  initialize Event queue and Time interrupt"]].
			NormalCursor topage1.
			self restart [user run]]\gb8B56i55I
restart code | u
	[u _ code cleancopy. u sender _ nil.
	thisContext sender releaseFully.
	thisContext sender _ nil.	code _ nil. 	"release caller chain"
	MessageDict new freeMethods.		"release held code"
	disp frame flash.
	while true do [u eval]]\gb14B116i22I32i19I
restartup: window
	[ "Equivalent to schedule new window, restart, and redbug in window, except firsttime is already done."
	thisContext sender releaseFully. thisContext sender _ nil.
	NormalCursor topage1.
	self schedule: window.
	thisContext tempframe all _ nil.
	self run: true]\gb19B2i101I
restore | w
	[screenrect clear.
	[projectWindownil[] projectWindow putTitle].
	for w from: (sched length to: 1 by: 1) do
		[(schedw) show]]\gb8B
run
	[self run: false]\gb5B
run: topFlag | i w forward	"topFlag means sched1 already is awake"
	[forward _ [topFlag [w_sched1. while w eachtime do []. w lasttime] true].
	while true do
		[i_0.
		until [(i_i+1)>sched length[]
			w_ [forward[schedi] sched(sched length+1-i)].
			w firsttime] do []
		i>sched length		"check for bug in empty space"
				[user yellowbug[self bugScreenMenu]]
		sched promote: w.
		while w eachtime do []
		forward_ w lasttime]]\gb13B14i40I233i30I
sched [sched]\gb6B
schedule: window
	[schednil[sched _ window inVector]
	sched _ window inVector concat: sched]\gb18B
scheduleOnBottom: window
	[schednil[sched _ window asVector]
	sched _ sched concat: window asVector]\gb26B
topWindow [sched1]\gb10B
unschedule: window | t
	[0<(t_ sched find: window)
		[sched _ sched(1 to: t-1) concat: sched(t+1 to: sched length)]]\gb19B

Notify Window\gbf5 
notifier: titleString level: lev interrupt: flag
	["Restore the full display.  Schedule a one-paned window to notify the user that errorString happened."
	self restoredisplay.
	NotifyFlagfalse
		[disp cr;
			append: 'NotifyFlag is false...'; cr;
			append: ' top-blank shows stack, user restart aborts,'; cr;
			append: ' tempframe shows args, ctrl-d proceeds'; cr;
			append: titleString; cr; show.
		(Toplev) debug. false]
	NotifyWindow new of: titleString level: lev interrupt: flag]\gb50B1i102I
notifier: titleString stack: stack interrupt: flag
	["Restore the full display.  Schedule a one-paned window to notify the user that errorString happened."
	self restoredisplay.
	NotifyFlagfalse
		[disp cr;
			append: 'NotifyFlag is false...'; cr;
			append: ' sender debug shows stack, user restart aborts,'; cr;
			append: ' tempframe shows args, ctrl-d proceeds'; cr;
			append: titleString; cr; show.
		stack debug. false]
	NotifyWindow new of: titleString stack: stack interrupt: flag]\gb52B1i102I
notify: errorString | notifyWindow
	["Create a notify window looking at the Context stack"
	notifyWindow _ self notifier: errorString stack: thisContext sender interrupt: false.
	notifyWindow
		[thisContext sender _ nil.
		 Top currentPriority=1
			[self restartup: notifyWindow]
		 self scheduleOnBottom: notifyWindow.
		 Top errorReset]
	nil]\gb20B17i53I

Dialog Window\gbf5 
clear		"clear disp of debris and characters"
	[disp clear]\gb7Bi37I
clearshow: str
	[disp clear; append: str; show]\gb16B
cr [disp cr]\gb3B
croak
	[self notify: 'A primitive has failed.']\gb7B
ev
	[disp ev]\gb4B
frame		"return rectangle of dialogue window"
	[disp text frame]\gb7Bi37I
newdisp "for when some class associated with running Dispframe  changed"
	[
	self unschedule: disp.
	disp _ Dispframe new rect: (80 rect: 15096).
	self schedule: disp ; clearshow: 'New Dialogue window created.
']\gb8Bi64I
newdisploc: origin and: corner "for moving disp"
	["user newdisploc: 80 and: 15096"
	(disp text frame inset: 22) clear.
	disp text frame _ origin rect: corner.
	disp show]\gb31Bi17I3i34I
next _ x ["simulate a Vector Stream"	disp cr; print: x; show]\gb9B
print: x [disp print: x; show]\gb9B
read [disp read]\gb5B
request: s[disp request: s]\gb10B
show [disp outline; show]\gb5B
show: str
	[disp append: str; show]\gb11B
space
	[disp space]\gb7B
tab [disp tab]\gb4B

Time\gbf5 
convertTime: s returnSecs: format | d dd t dfirst dlast m570 m571 [
	"s is total seconds from midnight Jan 1 1901 GMT (Greenwich mean time).
	see maxc <AltoDocs>AltoTime.Press for details"

	"time zone specific parameters"
	m570 _ mem0570. m571 _ mem0571.

	"adjust for time zone"
	s _ s + (([m570  0 ["west" 1] "east" 1]) * (
		(3600 * ("hours" m570 bits: (1 to: 4))) +
		(60 * ("additonal minutes" m571 bits: (1 to: 6))))).

	t _ s intdiv: 86400.
	"current day (in local standard time)"
	d _ Date new fromDays: t1.
	[format [] t _ Time new fromSeconds: t2].

	"check for DST. correct DST parameters for nonleap years and
	round to previous Sunday if necessary"

	"day of the year on or before which DST takes effect"
	dfirst _ m570 land: 0777 "bits: (7 to: 15)".

	[[dfirst = 366 ["DST not in effect" false]
	(dd _ d day)  (dfirst _ dfirst + d leap - 1) [

		"day of the year on or before which DST ends"
		dlast _ (m571 land: 0777 "bits: (7 to: 15)") + d leap - 1.
		dd < dlast "if false, definitely after" and
		dd < ((Date new day: dlast year: d year) previous: 6) day]
	"possibly earlier than or at beginning of range"
	dd  ((Date new day: dfirst year: d year) previous: 6) day] [

		"daylight savings time in effect. add an hour"
		format [s _ s + 3600]
		t hours = 23 [
			d _ d+1.
			t hours: 0]
		t hours: t hours+1]].

	"return either total seconds or Date and Time"
	format [s] d,t]\gb34B36i117I5i29I40i20I26i4I7i4I22i5I37i17I53i36I79i98I5i51I68i17I63i43I77i26I70i46I70i44I99i44I
dateAndTime: secs [
	"secs is a String of 4 characters representing seconds (in GMT) since Jan 1 1901.
	convert it to a LargeInteger (rawtotalsecs:), then return a Vector (Date, Time),
	which is corrected for local time zone and daylight savings"

	self convertTime: (self rawtotalsecs: secs) returnSecs: false]\gb18B4i223I
now [self dateAndTime: self timewords]\gb4B
rawtotalsecs [self rawtotalsecs: self timewords]\gb13B
rawtotalsecs: secs | s [
	"secs is a String of 4 characters representing seconds (in GMT) since Jan 1 1901.
	copy (in reverse order) to a Natural string, then return a LargeInteger"

	s _ Natural new: 4.
	s1 _ secs4.
	s2 _ secs3.
	s3 _ secs2.
	s4 _ secs1.
	LargeInteger new bytes: s neg: false]\gb19B8i157I
ticks "Return the 38.08-millisecond interval timer"
	[mem0430]\gb6B
time [self now2]\gb5B
time expr | t
	[t _ self ticks.  expr eval.  self ticks-t]\gb11B
timewords | s [
	"seconds (in GMT) since Jan 1 1901: as a String"
	s _ String new: 4.
	s word: 1 _ mem0572; word: 2 _ mem0573.
	s]\gb10B8i46I
today [self now1]\gb6B
totalsecs [self totalsecs: self timewords]\gb10B
totalsecs: secs [
	"convert from GMT to local and correct for Daylight Savings"
	self convertTime: (self rawtotalsecs: secs) returnSecs: true]\gb16B4i58I

Changes\gbf5 
changedCategories | titles space str
	["return a vector of the names of class categories which have been changed"
	space _ ' '1.
	titles _ HashSet new init.
	for str from: Changes contents do
		[titles insert: (
			SystemOrganization invert: ((Stream new of: str) upto: space) unique)].
	titles contents
	]\gb18B
changedClasses | titles space str
	["return a vector of the names of classes which have been changed"
	space _ ' '1.
	titles _ HashSet new init.
	for str from: Changes contents do
		[titles insert: ((Stream new of: str) upto: space). "class title"].
	titles contents
	]\gb15B
changedMessages [Changes contents sort]\gb16B
noChanges [Changes init]\gb10B

System quit/resume\gbf5 
backup   "back up smalltalk on ivy and resume"
	[ivy open; delete: 'small.boot'; store: 'small.boot'; close]\gb9Bi37I
hasXM
	["return true if this is XM Smalltalk"
	(mem0147)0 "1 for XM, 0 for normal"
	]\gb7B54i24I
InLd: fileid  "write out the core image, then load in OS"
	[user notify: 'file problem'] primitive: 85\gb59B
overlay: fileid | t [
	dp0 stampBoot.
	self releaseExternalViews.

	"put the ethernet to sleep"
	[Enil [] E sleep].

	"turn off display during quit/resume"
	t _ mem0420. mem0420 _ 0.
	self InLd: fileid.

	"we start here after a resume"
	mem0420 _ t.
	while user keyset>0 do [user show: 'The keyset is stuck'; cr]]\gb16B53i25I27i35I54i28I
quit 
	[self quitFrom: self "yup"]\gb7B21i5I
quitFrom: controller
	[self overlay: (0 0 0 0 0).
	self hasXM[
		screenrect clear.
		controller restore]]\gb22B
quitThen: str | rem rest ["quit, then have OS execute str"
	rem _ (dp0 file: 'rem.cm') readonly.
	rest _ rem next: rem length.
	rem readwrite; reset; append: str; cr; append: rest; close.
	self quit]\gb14B13i30I
quitThen: s continue: r [
	[s [
		"something for O.S. to do"
		(dp0 oldFile: 'rem.cm.') settoend;
			append: s; append: '; ';
			append: [r ['Resume.~ small.boot'] 'Quit.~; Resume.~ small.boot'];
			cr; flush]].
	self quit]\gb24B12i24I
releaseExternalViews | t [
	"close some things that we know about, everything else gets released"
	Sources close. dp0 close. dp1 close.

	"release (obsolete) some external views, usually File related"
	for t from: externalViews length to: 1 by: 1 do [
		(externalViewst) release. externalViewst _ nil].
	externalViews reset]\gb21B8i67I43i60I
Swat [] primitive: 90\gb5B

Misc System Stuff\gbf5 
classInit [
	screenMenu _ Menu new string:
'exit to overview
quit
open a subview
open a browser
open a workspace
reclaim']\gb10B
classNames		"an alphabetized Vector of all Smalltalk class titles uniqued"
		| classes x c
	[
	AllClassNamesnil
		[
		classes _ (Vector new: 20) asStream.
		for x from: Smalltalk do
			[
			c _ Smalltalk  x.
			(c is: Class) or (c is: VariableLengthClass) [classes next _ x].
			].
		AllClassNames _ classes contents sort.
		].
	AllClassNames
	]\gb12Bi62I
file: file classes: classes changesOnly: ch | cl [
	"called by UserView release to write just changes or entire system on a
	new file.  also, see comment in Class archiveOn:changesOnly:.

	write class comment and message text onto a FileStream (which could refer
	to an AltoFile, ILFile, etc.). either just changes or everything are
	written and replaced with RemoteParagraph references"

	[ch [file settoend] file reset].
	file readwriteshorten.
	for cl from: classes do [Smalltalkcl archiveOn: file changesOnly: ch].
	file close; readonly]\gb44B9i10bI16Bi78bI28B1i47bI10Bi27bI16Bi74bI15Bi11I
growSmalltalk: numberofdiskpages
	"for preemptive growth of Small.boot on disk"
	[dp0 growSmalltalkBy: numberofdiskpages]\gb34B1i43I
initCompiler  "Initialize shared variables of parser and generators"
		| code sel c t
	[
	Smalltalk declare: (TokenCodes ByteCodes).
	[TokenCodesnil [TokenCodes_SymbolTable new init: 32]].
	[ByteCodesnil [ByteCodes_SymbolTable new init: 32. Integer sharing: ByteCodes]].
	TokenCodes
		declare:
			(aRightBrack aPeriod "First 2 in this order"
			aLeftPar aSemicolon aCondArrow aHand aReturnArrow
			aLeftBrack aRightPar aLeftArrow
			aBinary "All above must be less, all below must be greater"
			aNumber aString "All below must be in that order"
			aKeyword aGibberish aColon aDigit aWord)
		as:
			(1 2
			3 4 5 6 7
			8 9 10
			20
			30 31
			41 42 43 44 45
			).
	ByteCodes
		declare:
			(toLoadField toLoadTemp toLoadLit toLoadLitInd
			toLoadCtxt toLoadTempframe
			toLoadConst toLoad0 toLoad1 toLoadSelf toLoadNil toLoadFalse toLoadTrue
			toSmashPop toSmash toPop toReturn toEnd toLoadThisCtxt toSuper
			toShortJmp toShortBfp toLongJmp toLongBfp
			toPlus toMinus toGtr toGeq toNext toEq toNew toAsStream
			toSendLit)
		as:
			(0 16 32 64
				112 116
				120 121 122 113 125 126 127
				128 129 130 131 132 133 134
				144 152 160 168
				176 177 179 181 194 197 203 207
				208).
	c _ Dictionary new init: 16.
	c insertall: ('self' 'thisContext' 'super' 'nil' 'false' 'true')
		with: (113 133 134 125 126 127).
	ByteCodes declare: stdPrimaries as: c.
	c _ Dictionary new init: 64.
	code _ 175.
	for sel from: SpecialOops (10 to: SpecialOops length) do
		[ "Atoms not wanted here -- only strings and characters"
		code _ code+1.
		selnil  []
		sel _ [sel length=1 and (sel1) isletter  false  [sel1] sel asString].
		c insert: sel with: code.
		].
	ByteCodes declare: stdSelectors as: c.
	c _ Dictionary new init: 8.
	c insertall: ('whiledo' 'untildo' 'forto:do' 'forfrom:do' 'forfrom:to:by:do' 'forfrom:to:do' 'ifthenelse' 'ifthen')
		with: (whiledo:args: untildo:args: fortodo:args: forfromdo:args: forfromtobydo:args: forfromtodo:args: ifthenelse:args: ifthen:args:).
	ByteCodes declare: inLineMsgs as: c.
	for t from: ((toLoadFieldLong 0210) (toLoadTempLong 0211) (toLoadLitLong 0212)
			(toLoadLitIndLong 0213) (toSendLitLong 0214)
			(codeLoadField 0400) (codeLoadTemp 01000) (codeLoadLit 01400)
			(codeLoadLitInd 02000) (codeSendLit 02400)) do
		[ByteCodes declare: t1 as: t2]]\gb14Bi54I256i23I100i51I20i33I930i54I
oopsToFile | a c i t s cs f ts
	[f _ dp0 file: 'oops'.
	cs _ user classNames transform a to Smalltalka.
	t _ cs transform a to a asOop.
	ts _ t permutationToSort.
	for i from: ts do
		[f append: (ti) base8; tab; append: (csi) title; cr].
	for c from: csts do
		[f cr; append: c title; cr.
		s _ c md contents.	"selectors"
		t _ s transform a to (c md method: a) asOop.  "method oops"
		for i from: t permutationToSort do
			[f tab; append: (ti) base8; tab; append: si; cr]
		user show: c title; cr]
	f close]\gb11B311i11I51i13I
printCrossReference: classNames on: f | dict m md frame l each s class
"user displayoffwhile [
	user printCrossReference: user classNames
		on: (dp0 file: 'CrossReference.Press')].

		user classNames
		(SystemOrganization category: 'xyz')
		(class1 class2)"

	[dict _ Dictionary init: 200.
	for m to: 32 do
		[dict insert: SpecialOops(9+m) with: ((Primitives) ()) copy].
	classNames transform each to
		[user show: each; space.
		md_ (Smalltalkeach) md.
		for m from: md do			"Tally all the UniqueString literals"
			[	[s_ dict lookup: m[] dict insert: m with: (s_ (()()) copy)].
			s1 has: each[] s1_ s1, each.
			for l from: (md literals: m) do
				[l is: UniqueString
					[	[s_ dict lookup: l[] dict insert: l with: (s_ (()()) copy)].
					s2 has: each[] s2_ s2, (each,m)]]]].

	f_ f asPressPrinter.
	f stamp.
	frame_ f defaultframe.			"Print the messages out sorted"
	for m from: dict contents sort do
		[user show: m; space.
		f frame_ frame.
		md_ dictm.
		s_ (String new: 200) asStream.
		s append: m; append: [(md1) length=0[' ( - undefined -  '] ' ('].
		for l from: (md1) sort do [s append: l; append: ', '].
		s skip: 2; append: ')'.
		f print: (s contents asParagraph maskrun: 1 to: m length under: 1 to: 1).
		f frame_ (frame minX+500)frame minY rect: frame corner.
		s reset.
			[md1 has: Primitives[s append: 'untallied.'. md2_ ()]
			(md2) length=0[s append: '- unreferenced -']].
		class_ -.
		for l from: (md2) sort do
			[	[l1=class[s append: ', ']
				[class-[s cr]]. s append: '('; append: l1; append: ') '.
				class_ l1].
			s append: l2].
		f print: s contents asParagraph].
	f close; toPrinter]\gb38B449i37I342i31I
purgealittle [] primitive: 89\gb13B
reclaim | c cl cv		" Should only be called from bugScreenMenu !! "
	[user cr; show: 'Reclaiming... '.
	cl_ CodePane, ScrollBar, PanedWindow, ListPane, Generator, Parser, BitImage, Document, DocumentEditor, Image.
	cv_ Context allInstances.
	user print: cv length.
	for c from: cv do [cl has: c mclass[c release]]. cv all_ nil.
	user show: ' reduced to ' + Context howMany asString + '.']\gb8B
release | m [
	"prepare to release this version (after editing UserView version)
	and possibly copying Sources file (see writeSources:)"

	(m_ Undeclared contents) length>0
		[user notify: 'Undeclared contains '+ m asString]

	user displayoffwhile [
		"either create a new Sources file (write all messages) or append only changes"
		m _ Sources directory checkName:
			'<Smalltalk>Smalltalk.Sources.' + user versionName.
		"for repeated releases in same version.
		should also work for Sources local (if renamed)"
		user writeSources: [m = Sources name [Sources] Sources directory file: m].

		"make workspace local"
		UserView md code: workspace _ UserView code: workspace.
	
		user writeChangedMessages: (phylum file: '<Smalltalk>ChangedMessages').].

	user noChanges. user releaseMessage.]\gb8B8i31I2bu5BU9b16B42b13B121i76I267i20I
releaseMessage [user clearshow: 'Welcome to ' + user version]\gb15B
systemStartup "To do after system flush and installation of new core image"
	[Top top.
	Window classInit.

	"The following screen extent seems to really fill the screen in x,
	the Alto Hardware Manual to the contrary notwithstanding."
	[self hasXM ["XM" self screenextent: 640800 tab: 02]
	self screenextent: 640480 tab: 050].

	Sources release. dp0 release. dp1 release.
	self releaseExternalViews.
	[Enil [] "ignore broadcasts" E broadcastFilter: true].

	(VirtualMemory new) thisvmem.
	Vmem afterBirth]\gb14Bi61I33i126I17i2I165i17I
systemworkspace1		"for system releasers only!!!

this has been partitioned into three workspaces for editing convenience:
	systemworkspace1
		steps 0-4: general comments, handling Sources, creating a release.
	systemworkspace2
		steps 5-7: doing a vmem write or surgery, storing finished files on Phylum
	systemworkspace3
		step 8: after a release, e.g. updating press files


0. This boot file should be named small.boot for vmem writing, surgery, and command file purposes.  If you made changes to the Sources disk be sure to update the current versions of (Xm)Smalltalk.Run, (Xm)Smalltalk.Syms, and (Xm)Byterp.mb on [Ivy]<Smalltalk>. This procedure works best on a Dorado for speed and disk space reasons, and it also can be done on an Alto (double disk O.S. required for vmem write).  Microcode changes (including making non-xm versions) must(?) be done on an Alto.  Step 5 (vmem writing) assumes enough space for another boot file.  To turn off display during execution, hold down left shift key while selecting 'doit'.

For those who want to vmem write their own versions, do not execute steps 4, 7 or 8 without further editing of file and directory names. Underlined items are typical values and normally must be edited to be useful.


1. to create an xm version:  filin changes and selected goodies. Undeclared must be empty for release to work (step 4). copy the categories of classes which have changed to systemworkspace3 (for later printing) and recompile it.
	dp0 filin: ('changes.st').
	phylum filin: ('<Small-goodies>xx.st').
	Undeclared contents inVector, user changedCategories


2. update version number/letter and comments in UserView version


3. the Sources file will be ordinarily be created in step 4. if only a few changes are involved, it may be somewhat faster to copy the old sources file to the new sources file (this step). then step 4 will only append changes.
	phylum store: Sources reset as: 'Smalltalk.Sources.' + user versionName.


4. checks Undeclared, writes all or appends changed messages to Sources file, updates ChangedMessages, inits Changes, puts up greeting, and sets the default user name & password. note: this is only to be executed for releasing the Smalltalk system itself (supply the proper password!!). if you plan to do a vmem write next, better to do this as first line of step 5.
	user releaseExternalViews.
	phylum name: 'Smalltalk' password: 'password'.
	user release.
	phylum name: 'Smalltalk-User' password: 'Smalltalk'.

	to write out the sources for a private version, specify which directory to use (don't leave Smalltalk as the default) and which categories and/or classes are to be included.
	| c classes. user releaseExternalViews. classes _ (Vector new: 50) asStream.
	phylum name: 'name' password: 'password'.
	for c from: ('category1' class1) do [
		c is: String [classes append: (SystemOrganization category: c)]
		classes next _ c].
	user file: (phylum file: '<ddd>xx.Sources.' + user versionName)
		classes: classes contents changesOnly: false.
"\gb18B1i355I3b2Bi784u16U63I1b2Bi228I14u10U37u5U60b2Bi65bI2Bi225I75i1bI3Bi364I65u8U74i174I93u4U13u8U19u18U123u7U
systemworkspace2		"for system releasers only!!!


5. if no surgery or vmem write involved, skip to step 7. start here with an xm version to make a non-xm version.  specify option below:
	1 vmem write (includes xm surgery)
	2 xm surgery
	3 non-xm surgery
to make things totally automatic, edit in your valid Maxc name and password, otherwise Ftp will ask you later. in the case of surgery only, at the end you will have to hit a key after safing.

	| option prefix dir file.
option _ 1.
dir _ phylum asFtpDirectory.
dir directoryName: 'Smalltalk-76'.
prefix _ [option=3 [''] 'Xm'].
for file from: ('Smalltalk.Run' 'Smalltalk.Syms' 'Byterp.Mb') do [
	dir retrieve: prefix + file as: file].
dir closeThen: ([option=1 ['delete oldsmall.boot;
copy newsmall.boot _ small.boot; '] '']) + 
'ftp maxc Login/c yourname yourpassword directory/c alto retrieve/c packmu.run ramload.run;
Resume small.boot;
Ramload/N Byterp.mb/F 1000/A;
Smalltalk.run'.

option=1 [(VirtualMemory new) giveBirth3. user quit]
Vmem ramwrite: (dp0 oldFile: 'byterp.mb').
Vmem surgery: (dp0 oldFile: 'Smalltalk.run').


6. after a successful vmem write or surgery, execute this (selecting here is tricky or type in a Dispframe)
	user systemStartup.


7. edit lastversion (and Smalltalk password) and execute the following, then close this window (clean up screen for non-xm?), and quit. it then renames old versions of files, stores new versions of files, e.g. remote XmSmall.Boot becomes XmSmall.Boot.5.5g and local Small.Boot becomes remote XmSmall.Boot
	| lastversion dir file remotefile.
	lastversion _ '5.5j'.
	dir _ phylum asFtpDirectory.
	dir login: 'Smalltalk' password: 'password'.
	for file from: ('Small.Boot' 'Smalltalk.Syms') do [
		remotefile _ ([user hasXM ['Xm'] '']) + file.
		dir rename: remotefile newName: remotefile + '.' + lastversion;
			store: file as: remotefile].
	(dp0 file: 'rem.cm') append: dir commands; cr; close.
	user releaseMessage.
"\gb18B1i31bI2Bi394I37u1U321u21U264b1Bi107I23b1Bi304I52u4U68u8U
systemworkspace3		"for system releasers only!!!


8. to update press files for system categories or cross reference listing directly on Phylum, browse or spawn this window.  edit pf to specify a list of system categories to print, usually from step 1, e.g. user changedCategories: ('Basic Data Structures' ...) or SystemOrganization categories (for all); delete toPrinter if you don't want the press files printed. edit xref to be user classNames if you want to generate a cross reference listing.
	 | pf xref cat.
	pf _   ('Text Objects' 'Kernel Classes' 'Press File Support' 'IFS File System' 'Alto File System' 'Panes and Menus' 'Files' 'Juniper' 'Windows' 'Graphical Objects' 'Numbers' 'Basic Data Structures' ).
	xref _ ().

	user releaseExternalViews.
	phylum name: 'Smalltalk' password: 'password'.
	for cat from: pf do [
		((phylum file: (cat + '.Press') asFileName) asPressPrinter) stamp;
			printclass: (SystemOrganization category: cat); close; toPrinter].
	xref empty []
	user printCrossReference: xref on: (phylum file: 'CrossReference.Press').
"\gb18B1i29I2b2Bi447I23u195U10u3U68u8U153u11U
version ['Smalltalk 5.5k ' + [user hasXM ['XM '] ''] + 'November 24']
"user version

low level disk address calculations are more general (necessary for 14-sector Dorado/Dolphin file systems)
better error recovery for broken and timed out Leaf connections
AltoFileDirectory disk page allocation/deallocation bugs fixed
miscellaneous printing fixes
Juniper fixes (2)
goodie: again-del-forget.st
create/write dates on boot file are updated at quit time
primitives for reading/writing 3K CRAM
Phylum account changes 
	default Leaf connection is logged in to <Smalltalk-User>
	system release uses [Phylum]<Smalltalk-76> instead of [Ivy]<Smalltalk>
see UserView workspace for logging into your account on Phylum, changing default printer -- for information on [Phylum]<Smalltalk>Release-5.5k.Bravo, .Press

September 3, 5.5j
	duplicate packet fix
	fixes to ether (routing table, name lookup, phylum, Int32), printer names,
		files, UserView time messages, context simulation,
		replace in BitBlt & Paragraph, NotifyWindow cleanup,
		Class code: always decompiles with left shift key, window printing fixes,
		SystemOrganization globalComment contains no nulls
	the following changes files were included:
	[phylum]<small-goodies>
		5.5i.changes.st, notifychange.st, window-print-changes.st
	[phylum]<findit>5.5i.more.changes.st
	[maxc]<dolbec>int32change.st
	[maxc>ingalls>fixes.st
	[ivy]<kaehler>context-simulation.st
	[ivy]<borning>context-changes.st

May 1, 5.5i
	obscure file bugs eliminated; version features added (goody: File-version.st).
	Ifs multiple connections fixed; Ifs error numbers looked up in Ifs.Errors.
	duplicate packets eliminated at lowest level.
	Int32 primitive fix. Juniper retransmit parameters increased
	Integer compare: LargeInteger now works
	CodePane/FilePane 'print' (within a CodeWindow) now prints entire Paragraph
		rather than only part within window
	ScrollBars hide during CodePane again & cancel. cancel saves your old text, so
		an immediate undo will replace the current selection with your previous text.

April 11, 5.5h
	Alto file names limited to 39 characters ('somestring' asFileName will fix
		name, truncating if necessary). other misc. file, ether, simulator fixes.
	BitBlt fixed so that BitRects don't lose their bits
	BitBlt used to speedup reading&writing files, sending Press files to printers
	ParagraphScanner puts underlining into Press files
	printer names updated (PressFile classInit). hashing-changes.st included.
	after font cataclysm, get new version of Fonts.Widths before printing
	system release procedure modified

March 6, 5.5g
	ether, file, vmem writing fixes.  cursor clipping on screen boundary.
	BitBlt used for String growing, copying, replacing
	goodies included: display-off-after-notify.st, CodePane-doit.st,
		context-simfix2.st, ILchanges.st, string-changes.st

see [Phylum]<Smalltalk> for the following files.  () surround an optional prefix or suffix.
	Document.Press
		mini-guide to Smalltalk system and user interface
	VersionHistory
		information about versions up to 5.5g
	ChangedMessages
		a list of  messages which have changed
	xxx.Press
		press file for CrossReference or for system category 'xxx' in current version
		to save paper, consider consulting the LRG alcove copies
	(Xm)Small.Boot(.version)
	(Xm)Smalltalk.Syms(.version)
		older versions of .Boot and .Syms are explicitly named.
	Smalltalk.Sources.version
		all Smalltalk.Sources (including the current one) are explicitly named

[Phylum]<Small-Goodies> contains miscellaneous bug fixes and new features (and even some documentation: goodies.bravo, .press) offered by the community of Smalltalk Users.
"\gb8B13b4B33b11B735b18B628b12B454i14I2i6I40i4I62b15B518b13B
versionName | s [
	s _ self version asStream.
	"skip Smalltalk"
	s skipTo: 040.
	"return version identification, e.g. 5.5f"
	s upto: 040]\gb12B
workspace
	[user notify: 'Not meant to be executed']
"
XEROX - Learning Research Group
 
user screenextent: 640580 tab: 050.
NotifyFlag _ true.
Changes init.
user changedMessages
user changedClasses
user changedCategories
Undeclared contents

to set the default printer
PrinterName_'Menlo'.
PrinterName_(PressFile new) selectPrinter: PrinterName.

to change phylum to access your account
user releaseExternalViews. phylum name: 'name' password: 'password'.

dp0 filin: ('Changes.st').
(dp0 file: 'changes.st') filout.
(dp0 file: 'xxx') edit.
dp0 pressfilin: ('xxx.press').
(dp0 filesMatching: '*.st') sort
dp0 list. dp0 freePages
dp0 delete: 'old'
dp0 rename: 'old' newName: 'new'

for reinitializing Sources and phylum
Sources release. phylum release. Sources reopen.

to make Smalltalk Sources local
 | s. s _ 'Smalltalk.Sources.'.
(phylum asFtpDirectory) retrieve: '<Smalltalk>' + s + user versionName as: s; close.
Sources on: (dp0 file: s).

to switch back to remote Sources
Sources close; on: (phylum file: '<Smalltalk>Smalltalk.Sources.' + user versionName).


to filin a remote Smalltalk file
phylum filin: ('<Small-goodies>xxx.st').

to print a remote/local press file
(phylum pressfile: '<Smalltalk>xxx.press') toPrinter.
(dp0 pressfile: 'xxx.press') toPrinter: 'Lilac'.

File noChanges.
BitRect new fromuser; edit.
user schedule: (defaultBitRectEditor newframe).

DocumentEditor new defaultdocument: 'test'.
DocumentEditor new init: (Document new fromPress: 'test.document').


user releaseExternalViews.
E sleep. E kill. E _ nil.
E _ Etherworld new. E broadcastFilter: true. E wakeup.
Sources reopen.

for primary Smalltalk access to file servers and printers at other sites.
substitute yourserver for phylum above, compile this workspace
PrinterName _ 'name-of-your-printer'.
Smalltalk declare: yourserver.
yourserver _ ILFileDirectory new directory: 'name-of-your-server'.
yourserver name: 'Smalltalk-User' password: 'Smalltalk'.
Sources on: (yourserver file: '<Smalltalk>Smalltalk.Sources.' + user versionName).
Changes init.

user Swat.
"c\gb11B44f2 5f0 3b23B59i1I98i27I79i40I296i38I50i31I146i32I89i32I44i34I311i1I125i137I
writeChangedMessages: ChangedMessages | class m ms [
	"append changed messages to a file (usually on [phylum])"
	ChangedMessages settoend; cr; cr; asParagraphPrinter stamp.
	class _ ''.
	for m from: user changedMessages do
		[ms_ m asStream.
		(ms upto: 040)=class
			[ChangedMessages append: ', '; append: (ms upto: 040)]
		ChangedMessages cr; append: m.
		class_ m asStream upto: 040].
	ChangedMessages close]\gb38B
writeSources: newSources [
	"write a new Sources file (usually on [phylum]Smalltalk.Sources.xxx
		(i.e. xxx = user versionName))
	if it's a new file or empty, write all Sources. otherwise it better be a copy of
	the previous Sources file (only changes will be appended. do the copy with ftp)"

	user file: newSources classes: SystemOrganization
		changesOnly: (newSources end  false).
	Sources close.
	Sources _ newSources]
\gb25B
\g
SystemOrganization classify: UserView under: 'Kernel Classes'.\g
UserView classInit\g

"VariableLengthClass"l15000z20000\gbf5 
Class new title: 'VariableLengthClass'
	subclassof: Class
	fields: ''
	declare: '';
	veryspecial: 20;
	asFollows\gbf5 

I am a class whose instances have numbered elements instead of named fields.\gi

Initialization\gbf5 
classInit		"gets propagated to a dummy instance"
	[(self new: 1) classInit]\gb11Bi37I

Instance access\gbf5 
allInstances [user notify: 'use allInstances: instead to specify the length range'
	"the length ranges are 0,1,2,3,4,5,6,7,8 individually and groups 9 (to 16), 17 (to 32), 33 (to 64), 65, 129, 257, 513, 1025, 2049, and 4197"]\gb13B71i140I
allInstances: len [(self allInstancesEver: len) notNil]\gb18B
allInstancesEver: len | indx vec PCLs i "returns a vector containing all instances of this class and length mixed with nils"
	["for large lengths, instances come in groups with lengths within a single power of 2"
	PCLs _ Vmem pclassesOf: self length: len.  "vector of PCLs"
	vec _ Vector new: 128*PCLs length.
	for i to: PCLs length do 
		[(vec[i-1*128+1 to: i*128]) all_ PCLsi].
	thisContext destroyAndReturn:
		(self fromFreelist: (Vmem freelistOffset: len) fill: vec)]\gb22B18i84I3i85I45i16I
copy: inst | t i
	[t _ self new: inst length.
	for i to: inst length do
		[ti _ insti]
	t]\gb11B
howMany: len | v "how many instances of this class and length are in use now?"
	[v _ self allInstancesEver: len.
	thisContext destroyAndReturn: v length - (v count: nil)]\gb13B4i61I
new
	[user notify: 'use new: <Integer=length> here.']\gb5B
new: length
	[length>16384 [user notify: length asString+
												' is too big a String']
	length>8192 [user notify: length asString+
												' is too big a Vector']
	length<0 [user notify: length asString+
												' -- negative length is invalid']
	self new: length asInteger] primitive: 29\gb13B
recopy: inst | t i
	[t _ self new: inst length.
	for i to: inst length do
		[ti _ (insti) recopy]
	t]\gb13B
\g
SystemOrganization classify: VariableLengthClass under: 'Kernel Classes'.\g
