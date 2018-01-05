'From Smalltalk 5.5k XM November 24 on 22 November 1980 at 2:57:08 am.'

"Object" 
Class new title: 'Object'
	subclassof: nil
	fields: ''
	declare: '';
	asFollows 

Object is the superclass of all classes.  It is an abstract class, meaning that it has no state, and its main function is to provide a foundation message protocol for its subclasses.  Three instances of this class are defined: nil, true, and false.

Comparison 
≤ x [⇑self>x≡false]
≡ x [⇑self≡x "In case this is reached by perform:"] primitive: 4
≠ x [⇑self=x≡false]
≥ x [⇑self<x≡false]
= x [⇑self≡x]
and⦂ x [self⇒[⇑x eval] ⇑false]
and: x [self⇒[⇑x] ⇑false]
empty [⇑self length = 0]
eqv: x [x⇒[⇑self] ⇑self≡false]
or⦂ x [self⇒[⇑true] ⇑x eval]
or: x [self⇒[⇑true] ⇑x]
sameAs: object
	[⇑self≡object]
xor: x [x⇒[⇑self≡false] ⇑self]

Classification 
class [user croak] primitive: 27
is: x [⇑self class≡x]
Is: x  "Is the class x a superclass or class of self"
	[self class ≡ x ⇒[⇑true]
	⇑self class Isa: x]
isArray
	[⇑false]
isnt: x [⇑(self class≡x) ≡ false]
Isnt: x
	[⇑(self Is: x)≡false]
isNumber
	[⇑false]

Construction 
, x | v
	[v ← Vector new: 2.
	v◦1 ← self. v◦2 ← x.  ⇑v]
asParagraph [⇑self asString asParagraph]
asStream [⇑self asVector asStream]
asVector | v
	[self≡nil⇒[⇑Vector new: 0]
	v ← Vector new: 1. v◦1 ← self. ⇑v]
copy		"create new copy of self"
	[self is: Object⇒[⇑self]
	⇑self class copy: self]
inVector | vec
	["Return me as the sole element of a new Vector."
	vec ← Vector new: 1.
	vec◦1 ← self.
	⇑vec]
recopy	"recursively copy whole structure"
	[self is: Object⇒[⇑self]
	⇑self class recopy: self]

Aspects 
asOop [user croak] primitive: 46
canunderstand: selector
	[⇑self class canunderstand: selector]
error: s [⇑user notify: s]
fields
	["Return an Array of all my field names or many of my subscripts."
	self class is: VariableLengthClass⇒
		[self length ≤ 50⇒ [⇑1 to: self length]
		⇑ (1 to: 20) concat: (self length-20 to: self length)]
	⇑self class instvars]
hash [user croak] primitive: 46
inspect
	[user leaveTop; restartup: (InspectWindow new of: self)]
inspectfield: n	"used by variable panes"
	[self class is: VariableLengthClass⇒ [⇑self◦(self fields◦n)]
	⇑self instfield: n]
instfield: n [user croak] primitive: 38
instfield: n ← val [user croak] primitive: 39
instfields | vec size  i
	["Return an Array of all my field values or many of my elements."
	self class is: VariableLengthClass⇒ [⇑self◦self fields]
	size ← self class instsize.
	vec ← Vector new: size.
	for⦂ i to: size do⦂ [vec◦i ← self instfield: i].
	⇑vec]
itself 
ref: index
	[⇑FieldReference new object: self offset: index]
subError [self error: 'message not defined by subclass']
title
	[⇑self class title + '.' + self asOop base8]

Printing 
asFullString | strm
	[strm ← (String new: 20) asStream.
	self fullprinton: strm. ⇑strm contents]
asString | strm
	[strm ← (String new: 16) asStream.
	self printon: strm. ⇑strm contents]
filout | file
	[⇑user displayoffwhile⦂ 
		[file ← dp0 file: self title asFileName.
		self fullprinton: file.
		file close]]
fullprint | strm
	[strm ← Stream default. self fullprinton: strm.
	user show: strm contents]
fullprinton: strm
	[self≡nil⇒ [strm append: 'nil']
	self≡false⇒ [strm append: 'false']
	self≡true⇒ [strm append: 'true']
	self class print: self on: strm]
print
	[user show: self asString]
printon: strm | t [
	strm append: [self≡nil⇒ ['nil']; ≡false⇒ ['false']; ≡true⇒ ['true']
		t ← self class title.
		strm append: ['AEIO' has: t◦1⇒ ['an '] 'a '].
		t]]

Compiler Defaults 
ⓢ code
	[⇑Generator new evaluate: code asStream in: false to: self notifying: self]
argsOff: stack
	[self⇒ [stack pop: 1]]
asRemoteCode: generator
	[⇑ParsedRemote new expr: self]
emitForEffect: code on: stack
emitForTruth: trueSkip falsity: falseSkip into: code on: stack
	[self emitForValue: code on: stack.
	(trueSkip jmpSize + falseSkip) emitBfp: code on: stack.
	trueSkip emitJmp: code on: stack]
emitForValue: code on: stack
emitsLoad
	[⇑false]
emittedReceiver
	[⇑false]
emittedVariable
	[⇑false]
findMacros: macros compilerTemps: compilerTemps
firstPush
	[⇑¬1]
interactive
	[⇑false]
isField
	[⇑false]
notify: errorString at: position in: stream
	[⇑self notify: errorString at: position in: stream for: self class]
notify: errorString at: position in: stream for: class | syntaxWindow
	[NotifyFlag⇒
		[syntaxWindow ← SyntaxWindow new of: errorString at: position in: stream for: class from: thisContext sender.
		thisContext sender ← nil.
		user restartup: syntaxWindow]
	 user notify: errorString. ⇑false]
printon: strm indent: level precedence: p forValue: v decompiler: decompiler
remote: generator
returns
	[⇑false]
sizeForEffect: nextPush 
	[⇑0]
sizeForTruth: trueSkip falsity: falseSkip
		| jump
	[jump ← trueSkip jmpSize.
	⇑self sizeForValue + (jump+falseSkip) bfpSize + jump]
sizeForValue
	[⇑0]

System Primitives 
error | sender op n args i		"after compiling execute: nil installError.  "
	[sender ← thisContext sender.
	op ← sender thisop.
	n ← op numArgs.
	args ← Vector new: n.
	for⦂ i from: (n to: 1 by: ¬1) do⦂
		[args◦i ← sender pop].
	⇑self messageNotUnderstood: op withArgs: args from: sender]
installError | code old
	[code ← Object md method: ↪error.
	old ← SpecialOops◦1.
	old asOop≠(mem◦3)⇒ [user notify: 'Object installError failed']
	Top critical⦂
		[mem◦3 ← code asOop.
		SpecialOops◦1 ← code]]
messageNotUnderstood: op withArgs: args from: sender
	[thisContext sender ← sender.
	user notify: 'Message not understood: '+op]
nail [user croak] primitive: 31		"Nail me in core and return my core address"
perform: selector 	"Send the unary message, selector, to self"
	[selector mustTake: 0. ⇑self performDangerously: selector]
perform: selector with: arg1 	"Send the 1-argument message, selector, to self"
	[selector mustTake: 1. ⇑self performDangerously: selector with: arg1]
perform: selector with: arg1 with: arg2 	"Send the 2-argument message, selector, to self"
	[selector mustTake: 2. ⇑self performDangerously: selector with: arg1 with: arg2]
perform: selector with: arg1 with: arg2 with: arg3 	"Send the 3-argument message, selector, to self"
	[selector mustTake: 3. ⇑self performDangerously: selector with: arg1 with: arg2 with: arg3]
perform: selector withArgs: vec
	[selector mustTake: vec length.
	⇑self performDangerously: selector withArgs: vec]
performDangerously: selector "Send self the message, selector; it had better be unary"
	[user notify: 'can''t perform: nil'] primitive: 102
performDangerously: selector with: arg1  "selector had better take 1 arg"
	[user notify: 'can''t perform: nil with:'] primitive: 102
performDangerously: selector with: arg1 with: arg2  "selector had better take 2 args"
	[user notify: 'can''t perform: nil with:with:'] primitive: 102
performDangerously: selector with: arg1 with: arg2 with: arg3  "selector had better take 3 args"
	[user notify: 'can''t perform: nil with:with:with:'] primitive: 102
performDangerously: selector withArgs: vec
	[vec length=0⇒ [⇑self performDangerously: selector];
		=1⇒ [⇑self performDangerously: selector with: vec◦1];
		=2⇒ [⇑self performDangerously: selector with: vec◦1 with: vec◦2];
		=3⇒ [⇑self performDangerously: selector with: vec◦1 with: vec◦2 with: vec◦3]
	user notify: 'More than 3 args for perform:']
PTR [] primitive: 46
refct [user croak] primitive: 45
startup		"loopless scheduling"
	[self firsttime⇒
		[while⦂ self eachtime do⦂ [].
		⇑self lasttime]
	⇑false]
swap⦂ variable | x  "assign me to variable and return its old value"
	[x ← variable value. variable value ← self. ⇑x]
unNail [user croak] primitive: 32		"Release me from being nailed"

SystemOrganization classify: ↪Object under: 'Kernel Classes'.

"Class" 
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
	asFollows 

Classes are the molecules of Smalltalk.  The instance fields specify the number and naming of fields for each instance, and the messages define the protocol with which these objects may be communicated.  Classes inherit the fields and message protocol of their superclass.  Locally defined messages will override inherited ones of the same name, and overriden ones may be accessed through the use of super in place of self.  A typical class definition looks like:
	Class new title: 'CodeEditor';
		subclassof: Window;
		fields: 'pared class selector';
		declare: 'editmenu'
This ordering is required, though the subclassof: and declare: messages are optional.  A class definition may be re-executed but, if the fields: clause has changed, all instances of the old class will become obsolete (they will fail to respond to any messages).

Initialization 
abstract
	[self fields: nullString]
bytesize: n	"non-pointer declaration"
	[self≠self realself⇒[self realself bytesize: n]
	fieldtype ← 32+ [n=8⇒ [8] 16]]
classInit		"gets propagated to a dummy instance"
	[self new classInit]
copyof: oldClass subclassof: newSubClass
	[title ← oldClass title.
	 self subclassof: newSubClass.
	 classvars ← oldClass classvars.
	 environment ← oldClass environment.
	 self newFieldsForSubClass: oldClass myinstvars]
declare: v | var recom
	[self≠self realself⇒[self realself declare: v]
	 [classvars≡nil⇒[classvars ← SymbolTable init]].
	 v is: String⇒[self declare: v asVector]
	 recom ← false.
	 [v is: Vector⇒
		[for⦂ var from: v do⦂
			[(Smalltalk has: var) or: (Undeclared has: var)⇒[recom ← true]]]
	  (Smalltalk has: v) or: (Undeclared has: v)⇒[recom ← true]].
	 [recom⇒
		[user notify: 'Methods recompile if you proceed, global became local']].
	 [v is: Vector⇒
		[for⦂ var from: v do⦂
			[classvars insert: var with: nil]]
	  classvars insert: v with: nil].
	 recom⇒[self compileall]]
environment ← environment [] "for resetting to reread sharing clauses"
fields: myinstvars | r a b s h		"list of instance variables"
	[messagedict ← MessageDict init.
	 r ← self realself.
	a ← self instvars.
	h← HashSet init.
	for⦂ s from: a do⦂
		[h has: s⇒
			[user notify: s+' is used already (maybe in superclass)']
		h insert: s].
	 self=r⇒[self initClass]
	 a=(b← r instvars)⇒
		[r environment← nil; myinstvars← myinstvars; subclassof: superclass]

	 [r howMany>0⇒[user notify: 'All '+title+'s become obsolete if you proceed...']].

	 classvars ← r classvars.
	 messagedict ← r md copy.

	 	[a length≤b length or⦂ a◦(1 to: b length)≠b⇒		"just adding new inst fields"
			[user notify: title+ ' methods recompile if you proceed...'.
			 self compileall]].

	 r md init.
	 self fixSubClassesOf: r.
	 r obsolete.
	 Smalltalk◦title unique ← self.
	 self initClass]
fixSubClassesOf: oldClass | n subClass
	[for⦂ n from: user classNames do⦂
		[subClass ← Smalltalk◦n.
		 subClass superclass≡oldClass⇒
			[Class new copyof: subClass subclassof: self]]]
initClass
	[fieldtype ← 16.
	instsize ← self instvars length.
	instsize>256⇒
		[user notify: 'too many instance variables']
	self organization]
myinstvars ← myinstvars
newFieldsForSubClass: myinstvars | r a b		"list of instance variables"
	[messagedict ← MessageDict init.
	 r ← self realself.
	 self=r⇒
		[user notify: 'problem in class redefinition. See coment at end of method']
	 (a← self instvars)=(b← r instvars)⇒
		[user notify: 'problem in class redefinition. See coment at end of method']
	 [r howMany>0⇒[user cr show: 'All '+title+'s are obsolete.']].
	 classvars ← r classvars.
	 messagedict ← r md copy.
	 r md init.
	 	[a length≤b length or⦂ a◦(1 to: b length)≠b⇒		"changing inst fields"
			[user cr show: title+ ' recompiled.'.
			 self compileall]].
	 self fixSubClassesOf: r.
	 r obsolete.
	 Smalltalk◦title unique ← self.
	 self initClass]
		"Regarding the notifys in this method: It is my understanding
		 that this method will only be invoked when the conditions
		 leading to the notifys are false. If I'm available, I'd like to see
		 any case that results in notification.
				Dave Robson"

obsolete		"invalidate further communication"
	[title ← 'AnObsolete'+title.
	classvars ← nil.		"recycle class variables"
	messagedict close.		"invalidate and recycle local messages"
	environment ← self.		"keep me around for old instances"
	superclass ← Object.		"invalidate superclass messages"]

realself [⇑Smalltalk◦title unique]		"as opposed to possible filin ghost"
rename: newtitle
		| name newname oldclass category
	[name ← title unique.  newname ← newtitle unique.
		[Smalltalk has: newname⇒
			[oldclass ← Smalltalk◦newname.
			user notify: 'All ' + newtitle + 's will become obsolete if you proceed'.
			oldclass obsolete]
		category ← SystemOrganization invert: name.
		AllClassNames ← AllClassNames insertSorted: newname.
		SystemOrganization classify: newname under: category].
	Smalltalk delete: name.
	AllClassNames ← AllClassNames delete: name.
	SystemOrganization delete: name.
	title ← newtitle.
	Smalltalk declare: newname as: self]

sharing: table
	[self≠self realself⇒[self realself sharing: table]
	environment ← environment asVector , table]
subclassof: superclass
	[(superclass isnt: Class) and⦂ (superclass isnt: VariableLengthClass)⇒
		[user notify: 'Superclass is not yet defined or not a Class']]
title: title
	[self title: (title ← title unique) insystem: Smalltalk]
title: name insystem: system | cl
	[superclass ← Object.
	[system has: name⇒
		[cl ← (system◦name) class.
		cl≡self class⇒ [⇑self]
		user notify: name + ' will change from a ' + cl title + ' to a ' + self class title + ' if you proceed...']].
	system declare: name as: self.
	AllClassNames ← AllClassNames insertSorted: name.
	SystemOrganization classify: name under: 'As yet unclassified']
title: t subclassof: s fields: f declare: d
	[t◦1≠((t◦1) asUppercase)⇒
		[user notify: 'Please capitalize each word in class title: ' + t. ⇑false]
	self title: t; subclassof: s; fields: f; declare: d]
veryspecial: n		"inaccessible fields"
	[instsize ← self instvars length + n]

Access to parts 
◦x [⇑classvars◦x]
◦x ← val [⇑classvars◦x ← val]
fieldNamesInto: collector
	[[superclass≡nil⇒ [] superclass fieldNamesInto: collector].
	⇑(Reader new of: myinstvars) readInto: collector]
instsize
["Return the number of user accessable instance fields (self instvars length)."
⇑[fieldtype≥32⇒ [0] 
	self≡Class⇒ [instsize-1]
	self≡VariableLengthClass ⇒[instsize-20]
	instsize]]
instvars
	[⇑self fieldNamesInto: FieldNameCollector default]
invertRef: refs "Refs may be a vector (to allow batching)" 
		| cl env source ref inv sym t
	[refs isnt: Vector⇒ [⇑(self invert: refs inVector)◦1]
	env ← (self wholeEnvironment concat: (Undeclared, Smalltalk)) asStream.
	source ← Dictionary init.
	⇑refs transform⦂ ref to⦂
		[cl ← self. env reset.
			until⦂
				[(sym ← env next)≡false⇒ [inv ← 'unknown ' concat: ref asOop base8]
				[cl≠nil and⦂ sym≡cl classvars⇒ [t ← cl title. cl ← cl superclass] t ← false].
				(inv ← sym invertRef: ref)≡false⇒ [false]
				[t⇒ []
				 t ← source lookup: sym⇒ []
				 source insert: sym with: (t ← Smalltalk invert: sym)].
				inv ← (t concat: ' ') concat: inv]
			 do⦂ [].
		inv]
	]
Isa: x  "is x on my superclass chain?"
	[superclass ≡ x ⇒[⇑true]; ≡ nil ⇒[⇑false]
	⇑superclass Isa: x]
md [⇑messagedict]
myinstvars
	[⇑myinstvars]
superclass [⇑superclass]
title [⇑title]

Organization 
classvars [⇑classvars]
clean | name	"release unreferenced classvars"
	[for⦂ name from: classvars do⦂
		[name≠↪ClassOrganization and⦂ (classvars ref: name) refct=1⇒
			[classvars delete: name]]]
environment
	[⇑environment]
organization | o
	[	[classvars ≡ nil⇒[self declare: ↪ClassOrganization]].
	o ← classvars lookup: ↪ClassOrganization.
	o is: ClassOrganizer⇒[⇑o]
	o ← ClassOrganizer new init: messagedict contents sort.
	classvars insert: ↪ClassOrganization with: o.  ⇑o]
wholeEnvironment
	[⇑(classvars asVector concat: environment asVector) concat:
		[superclass≡nil⇒ [↪()] superclass wholeEnvironment]]

Editing 
ed: selector | c s
	[c← self code: selector. user clearshow: c.
	while⦂ (s← user request: 'substitute: ') do⦂
		[c ← c subst: s for: (user request: 'for: ').
		user clearshow: c]
	self understands: c]
edit: selector | para s v
	[para ←
		[selector=↪ClassOrganization⇒
			[self organization asParagraph]
		messagedict has: selector⇒[self code: selector]
		nullString asParagraph].
	self edit: selector para: para formerly: false]
edit: selector para: para formerly: oldpara
	[user leaveTop.
	user restartup: (CodeWindow new class: self selector: selector para: para formerly: oldpara)]
execute: code		"disposable methods"
	[self understands: 'doit [⇑' + code + ']'.
	⇑self new doit]

Message access 
archiveOn: file changesOnly: ch | org m [
	"this should be called only by the system releaser
	(via UserView file:classes:changesOnly:) !!!

	if you want to archive your own classes (useful only if you have stable code
	and intend to clean up afterwards with a vmem write), see Steve.

	write comment and method text on a FileStream for some file.
	ch⇒ [write only changes (non-remote String/Paraagraphs)] write everything"

	user cr; show: title.
	org ← self organization.
	["org globalComment always yields a String, so a small kludge is in order"
	ch and⦂ (org globalCommentItself is: RemoteParagraph)⇒ []
	org globalComment ←
		(RemoteParagraph new on: file) fromString: org globalComment].

	"archive in category&alphabetical rather than hash order (messagedict)"
	for⦂ m from: org do⦂ [
		ch and⦂ ((messagedict code: m) is: RemoteParagraph)⇒ []
		messagedict code: m ←
			(RemoteParagraph new on: file) fromParagraph: (self code: m).
		ch⇒ [user space; show: m]]]
bytesof: sel
	[⇑(messagedict method: sel) asBytes]
canUnderstand: selector
	[messagedict has: selector⇒ [⇑self]
	superclass≡nil⇒ [⇑false]
	⇑superclass canUnderstand: selector]
canunderstand: selector
	[⇑messagedict has: selector]
code: sel [ 
	"last paragraph returned is cached (mainly for NotifyWindows)"
	[sel ≡ lastSelector and⦂ self ≡ lastClass ⇒ []
	lastParagraph ← ([
		sel = ↪ClassOrganization ⇒ [self organization]
		"if left shift key is down, decompile"	
		user leftShiftKey⇒ [self decompile: sel]
		"Paragraph or RemoteParagraph"
		messagedict code: sel]) asParagraph.

	lastClass ← self.
	lastSelector ← sel].
	⇑lastParagraph]
compileall | s c "does not modify code, just compiles it"
	[for⦂ s from: messagedict do⦂
		[c ← messagedict code: s.
		 self understands: c asParagraph.
		 messagedict code: s ← c "leave it as a remote paragraph"].
	 self≡Object⇒[nil installError]]
"to recompile the whole system (check out big changes) execute:
	| n [for⦂ n from: AllClassNames do⦂
		[user show: n; cr. (Smalltalk◦n) compileall.
		Changes init. MessageDict new freeMethods]] "
copy: sel from: class
	[self copy: sel from: class classified: nil]
copy: sel from: class classified: cat "Useful when modifying an existing class"
		| s code
	[sel is: Vector⇒ [for⦂ s from: sel do⦂ [self copy: s from: class classified: cat]]
	sel is: String⇒ [self copy: (class organization category: sel) from: class classified: cat]
	code ← class code: sel.  code≡nil⇒ []
	[cat≡nil⇒ [cat ← class organization invert: sel]].
	[messagedict has: sel⇒
		[code text=(self code: sel) text⇒ []
		user notify: title+' '+sel+' will be redefined if you proceed.']].
	self understands: code classified: cat]
decompile: t1 
	[⇑user displayoffwhile⦂ [Decompiler new decompile: t1 class: self]]
derstands: selector | c		"overstands?  undersits? - forget it"
	[selector is: Vector⇒[for⦂ c from: selector do⦂ [self derstands: c]]
	(messagedict has: selector)≡false⇒[] 
	messagedict ← messagedict delete: selector.
	self organization delete: selector.
	lastClass ← lastSelector ← lastParagraph ← nil.
	[Changes has: (c←title+' '+selector)⇒ [Changes delete: c]].
	Changes insert: (c←'~'+c).
	⇑c]
describe: method on: strm | sel cls  "append mclass and selector"
	[cls ← self.
	until⦂ [cls≡nil⇒ [cls←self. sel←↪?] sel ← cls md invert: method] do⦂
		[cls ← cls superclass].
	strm append: cls title; space; append: sel]
install: name method: method literals: literals
		code: code backpointers: backpointers | c
	[messagedict ← messagedict insert: name method: method
		literals: literals code: code makeBoldPattern backpointers: backpointers.
	lastClass ← self.
	lastSelector ← name.
	lastParagraph ← code.
	Changes insert: (c←title+' '+name).
	Changes has: (c←'~'+c)⇒[Changes delete: c]]
messages [⇑messagedict contents , ↪ClassOrganization]
method: sel
	[⇑messagedict methodorfalse: sel]
notify: errorString at: position in: stream
	[⇑self notify: errorString at: position in: stream for: self]
selectors		"Return a Vector of all my selectors."
	[⇑self messages]
shrink [messagedict ← messagedict shrink]
space | a s
	[s ← 0. for⦂ a from: messagedict do⦂
		[s ← s + (messagedict method: a) length]
	⇑s]
textLocal | s [
	"makes comment and methods local"
	s ← self organization.
	s globalComment ← s globalComment.
	for⦂ s from: messagedict do⦂ [messagedict code: s ← self code: s]]
understands: code | selector old		"install method"
	[⇑self understands: code classified: 'As yet unclassified']
understands: code classified: heading		"compile and install method"
	[⇑Generator new compile: code asParagraph
		in: self under: heading notifying: self]
whosends: selector | s l a
	[s ← Stream default.
	for⦂ a from: messagedict do⦂
		[for⦂ l from: (messagedict literals: a) do⦂
			[selector≡l⇒[s append: a; space]]]
	⇑s contents]

Instance access 
allInstances [⇑self allInstancesEver notNil]
allInstancesEver | indx vec PCLs i "returns a vector containing all instances of this class mixed with nils"
	["Works for all classes.  Some additional instances may be created after the
	vector is filled but before you get to use it."
	PCLs ← Vmem pclassesOf: self.  "vector of PCLs"
	vec ← Vector new: 128*PCLs length.
	for⦂ i to: PCLs length do⦂ 
		[(vec◦[i-1*128+1 to: i*128]) all← PCLs◦i].
	thisContext destroyAndReturn: (self fromFreelist: Class instsize fill: vec)]
copy: inst | t i
	[t ← self new.
	for⦂ i to: self instsize do⦂
		[t instfield: i ← inst instfield: i]
	⇑t]
default
	[⇑self new default]
fromFreelist: i fill: vec "i = zero order index of freelist in class instance.
	vec = vector in pclasses of all possible instances."
	[user croak] primitive: 60
howMany | v "how many instances of this class are in use now?"
	[v ← self allInstancesEver.
	thisContext destroyAndReturn: v length-(v count: nil)]
init		"init and default get propagated to instances"
	[⇑self new init]
init: n		"init and default get propagated to instances"
	[⇑self new init: n]
instfield:	 i	"prevent user from getting freelist"
	[i > Class instsize ⇒[user notify: 'arg too big']
	⇑super instfield: i]
new [user croak] primitive: 28
new: length "To allow fixed-length classes to simulate variable-length ones"
	[⇑self new init: length] "By convention"
print: inst on: strm | ivars i
	[ivars ← self instvars.
	strm append: '('; append: title; append: ' new '.
	for⦂ i to: instsize do⦂
		[strm append: ivars◦i; append: ': ';
			print: (inst instfield: i); space]
	strm append: ')']
printon: strm
	[strm append: 'Class ' + title]
recopy: inst | t i
	[t ← self new.
	for⦂ i to: self instsize do⦂
		[t instfield: i ← (inst instfield: i) recopy]
	⇑t]

Filin and Filout 
asFollows | s heading selector p [
	self≠self realself⇒[self realself asFollows]
	heading ← 'As yet unclassified'.

	"handles Bravo or Press (Smalltalk generated) files"
	while⦂ ((p ← FilinSource nextParagraph) and⦂ (s ← p text) ≠ '') do⦂ [
		[s◦1 = 015⇒ [
			"throw away initial cr before comment and headings"
			s ← s copy: 2 to: s length]].
		p runs◦2
			= 2 "italic"⇒ [self organization globalComment ← s];
			= 0121 "5, bold"⇒ [heading ← s]
		self canunderstand: (
			selector ← self understands: p classified: heading)⇒ [
				user show: selector; space. messagedict purge: selector]
		user show: '(an uncompiled method) ']] 7Bf0 
changelist: cat [⇑title unique, (self organization category: cat)]
definition | strm		"return a string that defines me (Class new title etc.)"
	[strm ← (String new: 50) asStream.
	self printdefon: strm.
	⇑strm contents]
endCategoryOn: pstrm
endChangesOn: pstrm
	[pstrm print: '' asParagraph]
filout [user displayoffwhile⦂ [
	(dp0 file: title+'.st.') filoutclass: self.
	self noChanges]]
filoutCategory: cat
	[(dp0 file: (title+'-'+cat+'.st') asFileName) filout: (self changelist: cat)]
filoutOrganization	"So we can merge separate work on organization"
	[user show: title; cr.
	user displayoffwhile⦂
		[(dp0 file: title+'.org.')
			append: title+' organization fromParagraph:'; cr;
			append: self organization asParagraph text asString;
			append: 'asParagraph'; close]]
noChanges | s t
	[t← title+' *'.
	for⦂ s from: Changes contents do⦂
		[(s◦1=126 "~" and⦂ (t match: s◦(2 to: s length)))
		 or⦂ (t match: s)⇒
			[Changes delete: s]]]
paraprinton: strm		"Strm is actually a ParagraphPrinter"
		| para frame s heading org
	[para ← ('"'+title+'"') asParagraph.
	para maskrunsunder: 0361 to: 0121.	"Font ← 5, Bold"
	frame ← strm defaultframe.
	strm frame ← 15000⌾frame origin y rect: 20000⌾frame corner y.
	strm print: para.
	strm frame ← frame.
	strm print: ((self definition+';
	asFollows') asParagraph maskrunsunder: 0361 to: 0121).
	org ← self organization.
	strm print: ('
'+org globalComment) asParagraph allItalic.
	for⦂ heading from: org categories do⦂
		[self printCategory: heading on: strm]
	self endChangesOn: strm.
	strm print: ('SystemOrganization classify: ↪'+title+' under: '''+
		(SystemOrganization invert: title unique)+'''.') asParagraph.
	[self ≡ Class or: self ≡ VariableLengthClass⇒ [] self canunderstand: ↪classInit⇒
		[strm print: (title+' classInit') asParagraph]].
	]
printCategory: s on: pstrm | sel
	[self startCategory: s on: pstrm.
	for⦂ sel from: (self organization category: s) do⦂
		[self printMethod: sel on: pstrm].
	self endCategoryOn: pstrm]
printdefon: strm | s		"print my definition on strm"
	[strm append: self class title;
		append: ' new title: ';
		"title is probably unique, but make sure. then we want it as a 'String' "
		print: title unique asString.
	strm cr; tab; append: 'subclassof: ';
		append: [superclass≡nil⇒['nil'] superclass title].
	strm cr; tab; append: 'fields: '; print: myinstvars.
	strm cr; tab; append: 'declare: '''.
	for⦂ s from: classvars contents do⦂
			[s=↪ClassOrganization⇒[]
			strm append: s; space]
	strm append: ''''.
	[fieldtype=16⇒[]
		strm semicrtab; append: 'bytesize: '; print: fieldtype-32].
	[instsize = (s← self instvars) length⇒[]
		strm semicrtab; append: 'veryspecial: '; print: instsize-s length].
	[environment≡nil⇒[]
		for⦂ s from: environment do⦂
			[strm semicrtab; append: 'sharing: '; append: (Smalltalk invert: s)]]]
printMethod: sel on: pstrm
	[pstrm print: (self code: sel).
	messagedict purge: sel]
printout [user displayoffwhile⦂ [
	(dp0 file: title+'.press.') printoutclass: self]]
printoutCategory: cat
	[(dp0 file: (title+'-'+cat+'.press') asFileName) printout: (self changelist: cat)]
readfrom: strm [⇑self readfrom: strm format: nil]
readfrom: strm format: f [
	⇑self new readfrom: strm format: f]
startCategory: s on: pstrm
	[pstrm print: (('
'+s) asParagraph maskrunsunder: 0361 to: 0121).		"Font 5, Bold"
	]
startChangesOn: pstrm
	[pstrm print: (('
'+title+' asFollows') asParagraph maskrunsunder: 0361 to: 0121).		"Font 5, Bold"
	]

System Organization 
category [⇑SystemOrganization invert: self title unique]
category: cat
	[cat is: String ⇒[SystemOrganization add: self title unique under: cat]
		user notify: 'Category name must be a String']
moveFromCat: cat1 to: cat2
	[(cat1 is: String) and⦂ (cat2 is: String) ⇒
			[SystemOrganization move: self title unique from: cat1 to: cat2]
		user notify: 'Category name must be a String']

SystemOrganization classify: ↪Class under: 'Kernel Classes'.

"Context" 
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
	asFollows 

A context keeps track of the progress of a method

Initialization 
cleancopy
	[⇑Context new
		sender: sender
		receiver: receiver
		method: method
		tempframe: tempframe copy
		pc: pc
		stackptr: stackptr]
copy
[
	⇑ Context new
			sender: sender
			receiver: receiver
			method: method
			tempframe: tempframe
			pc: pc
			stackptr: stackptr
]
sender: sender receiver: receiver
		method: method tempframe: tempframe pc: pc stackptr: stackptr

Access to parts 
caller [⇑sender]

getPT: i  [ ⇑ tempframe◦i ]
mclass | selector mclass		"return the class in which method was found"
	[sender ≡ nil ⇒ [⇑receiver class]
	selector ← self selector.
	mclass ← receiver class.
	until⦂ mclass ≡ nil do⦂
		[(mclass method: selector) ≡ method ⇒ [⇑mclass]
		mclass ← mclass superclass].
	⇑receiver class]
method
	[⇑method]
pc [⇑pc]
receiver
	[⇑receiver]
selector | mclass selector		"return the selector for my method"
	[selector ← sender thisop.
	selector◦(1~19)='performDangerously:'⇒
		[mclass ← receiver class.		"special work for perform"
		until⦂ [mclass ≡ nil or⦂ (selector←mclass md invert: method)] do⦂
			[mclass ← mclass superclass]
		selector≡false⇒[⇑↪confused] ⇑selector]
	⇑selector]
sender [⇑sender]
sender← sender []
setPT: i to: n  [ tempframe◦i ← n ]
stackIndex "Return the subscript in tempframe of my top of stack."
	[⇑stackptr+1]
swapSender: coroutine | oldSender
	[oldSender ← sender. sender ← coroutine. ⇑oldSender]	
tempframe
	[⇑tempframe]
totalPT [⇑ (method◦5)+1 ]

Control structures 
for⦂ var1 from: expr1 with⦂ var2 from: expr2 do⦂ stmt | s1 s2
	[s1 ← expr1 asStream. s2 ← expr2 asStream.
	while⦂ [(var1 value ← s1 next) and⦂ (var2 value ← s2 next)] do⦂ stmt eval]


Debugging 
debug | t v
	[self print.
	while⦂ [user cr. t ← user request: '*'] do⦂  "until ctrl-d"
		[v ← Generator new evaluate: t asStream in: false to: self notifying: nil.
		↪debugret=v⇒[self print] v print]
	⇑↪debugret]
printon: strm | mc
	["Print the selector which invoked this Context
	  and the class in which code was found for that selector"
	 mc ← self mclass.
	 strm append: mc title. sender≡nil⇒ []
	 [receiver is: mc⇒[] strm append: '('+receiver class title+')'].
	 strm append: '⇒'; print: self selector]
restartWith: method
	[tempframe ← tempframe copy: 1 to: method◦3.
	self restart]
stack | a strm
	["Return a Vector of me and all my derivative contexts."
	strm ← (Vector new: 20) asStream.
	strm next ← a ← self.
	"when user notifty is fixed, a sender can become a caller"
	until⦂ (a←a sender)≡nil do⦂ [strm next ← a].
	⇑strm contents.]
thisop | a		"return the message selector just sent"
	[a ← method◦pc.
	a≥0320⇒ [⇑self litof: a-0320]
	a≥0260⇒ [⇑SpecialOops◦(10+a-0260)]
	method◦(pc-1)=0214⇒ [⇑self litof: a]
	⇑↪confused]
trace | strm a
	[strm ← Stream default. self printon: strm.
	a ← sender. until⦂ a≡nil do⦂
		[strm cr. a printon: strm. a ← a sender]
	⇑strm contents]
variableNamesInto: dest with: block | class selector parser
	["For each method variable name, call
			dest declaration: block name: string asArg: <true or false>
		If cant find source code, call dest notify: "
	class ← self mclass.
	selector ← class md invert: method⇒
		[parser ← Parser new from: (class code: selector) asStream to: dest.
		parser pattern: block; temporaries: block; terminate]
	dest notify: 'thisContext is not running a currently defined method']
verifyFrames  | c "be sure frames on stack aren't nil"
	[c ← self.
	 until⦂ c≡nil do⦂
		[c tempframe≡nil⇒
			[user notify: 'Sorry, that stack has been released -- proceeding is impossible'; restart]
		 c ← c sender]]

Simulation 
docode: code toclass: class | i v
	[[(i←code◦2)≠ 0 ⇒
		[i = 1  ⇒ [⇑self];
			= 30 ⇒ [v ← self pop. v push: self. ⇑v];
			= 40 ⇒ [v ← self pop instfield: code◦5 + 1. ⇑self push: v];
			= 41 ⇒ [user notify: 'Field← primitive unimplemented'];
			= 87 ⇒ [⇑ receiver "PriorityInterrupt run: newContext"];
			= 101 ⇒ [user notify: 'Doprimitive unimplemented'];
			= 102 ⇒ [⇑self performing: code◦4 toclass: tempframe◦(stackptr+1)]
		 (v ← self doprimitive: code) ≡ ↪failed ⇒[]
		 stackptr ← stackptr-(code◦4+1). ⇑self push: v]].
	 ⇑self newToRun: code]
dojump: displacement
	[pc ← pc+displacement]
dopop
	[stackptr ← stackptr-1]
doprimitive: code
	[⇑↪failed] primitive: 101
doremotereturn | t f
	[t ← self pop. f ← self pop. ⇑f push: t]
doreturn | t
	[t ← tempframe◦(stackptr+1). tempframe ← nil. ⇑sender push: t]
dostore | byte
	[byte ← method◦(pc← pc+1).
	 byte<020⇒ [self smashField: byte];
			<040⇒ [self smashTemp: byte-020];
			<0100⇒ [user notify: 'Store into literal'];
			<0160⇒ [self smashLitInd: byte-0100];
			<0170⇒ [self instfield: (byte-0157) ← tempframe◦(stackptr+1)];
			=0210⇒ [self smashField: self nextByte];
			=0211⇒ [self smashTemp: self nextByte];
			=0213⇒ [self smashLitInd: self nextByte]
	 user notify: 'Illegal store'
	]
dosuper | byte
	[byte ← self nextByte.
	[byte=0214⇒ [byte ← self nextByte+0320]].
	byte<0260⇒ [user notify: 'non-selector after super']
	⇑self sendmess: nil byte: byte toclass: 
		(self litof: method◦6-8/2) value superclass]
doUnique | r e "cause ◦ ← to be done for a UniqueString inside str: inside intern:"
	[r ← tempframe◦(2+stackptr). "receiver"
	"already know class is UniqueString"
	e ← 'bad special message in super'.
	(method ≡ (UniqueString md method: ↪str:)) ≡ false ⇒[user notify: e]
	"ours, now put result of str: on the stack"
	self push: (r ← r str: tempframe◦1 "arg").
	method◦(method length) ≠ 0203 "return" ⇒[user notify: e]
	"trick this method into returning"
	pc ← method length -1.
	⇑self]
help
	["Here is how to use the Smalltalk simulator.

	thisContext runsimulated⦂ [ place here the code you to simulate ].

	Some classes in Smalltalk may not be subclassed.  Some messages
	may not be overridden.  initSimulator tells the details. "]
initSimulator | i "these class variables of Context are used by instfield: to simulate what the microcode does to objects."
	["  Context declare: 'positionFld arrayFld limitFld'.    "
	"Rules:  There may not be a subclass of Integer.
			(This is so +, -, <, >, ≤, ≥, =, ≠ may not be overridden).
	The following messages may NOT be redefined by any class.
		≡ (from class Object).
		class (from class Object).
	The following messages may NOT be redefined by any VariableLengthClass.
		length (from Vector, String)"

	i ← Stream instvars.  "We need to peek inside instances of Stream"
	positionFld ← i find: 'position'.
	arrayFld ← i find: 'array'.
	limitFld ← i find: 'limit'.
	]
litof: a
	[⇑(method word: a+4) asObject]
newToRun: code | r v i
	[r ← self pop. v ← Vector new: code◦3.
	 for⦂ i from: (code◦4 to: 1 by: ¬1) do⦂ "Move args to new tframe"
		[v◦i ← tempframe◦(2+(stackptr ← stackptr-1)).
		tempframe◦(stackptr+2) ← nil	"Nil args on caller's stack"
		].
	 ⇑self class new sender: self receiver: r method: code
		tempframe: v pc: code◦6 stackptr: code◦5 - 1. "Allocate a new Context"
	]
nextByte
	[⇑method◦(pc ← pc+1)]
nonEmptyStack
	[⇑(stackptr≠¬1)]
performing: nargs toclass: class | i sel
	[i ← stackptr-nargs.
	sel ← tempframe◦(i+1).	"Selector is first arg"
	while⦂ i<stackptr do⦂
		[tempframe◦(i+1) ← tempframe◦(i+2).
		i ← i+1].
	stackptr ← stackptr-1.
	⇑self sendmess: sel byte: 0320 toclass: class]
pop
	[⇑tempframe◦(2+ (stackptr← stackptr-1))]
push: n "Push n on top of stack"
	[tempframe◦(1+(stackptr←stackptr+1)) ← n]
pushField: i
	[tempframe◦(1+(stackptr←stackptr+1)) ← receiver instfield: i+1]
pushLit: i
	[tempframe◦(1+(stackptr←stackptr+1)) ← (method word: i+4) asObject]
pushLitInd: i
	[tempframe◦(1+(stackptr←stackptr+1)) ← (method word: i+4) asObject value]
pushTemp: i
	[tempframe◦(1+(stackptr←stackptr+1)) ← tempframe◦(i+1)]
restart
	[pc ← method◦6. stackptr ← method◦5-1]
runsimulated⦂ cntxt | ctx b i "To use the simulator say...
		thisContext runsimulated⦂ [your code]. "
	["turn off use of BitBlt by Strings"
	b ← String◦↪StringBlter.
	String◦↪StringBlter ← false.

	cntxt push: self.  ctx ← cntxt.
	until⦂ ctx≡self do⦂ [ctx ← ctx step].

	"restore state of StringBlter"
	String◦↪StringBlter ← b.
	⇑self pop]
sendmess: sel byte: byte toclass: class | cl code
	[cl ← class.  until⦂ cl≡nil do⦂
		[[byte<0320⇒ "Is it a special message?"
			[self specialmess: byte toclass: cl⇒ [⇑self] "Can we perform it?"
			 sel ← SpecialOops◦(byte-0246)] "Send the special message selector"
		  sel≡nil⇒ [sel ← self litof: byte-0320]]. "Send the selector from the literals"
		 code ← cl md methodorfalse: sel⇒ [⇑self docode: code toclass: cl]
	  	 cl ← cl superclass]. "Try up the superclass chain"
	 user notify: ('Simulated message not understood: ' concat: sel asString)] 1f0 
simulate⦂ cntxt
	[cntxt push: thisContext.  ⇑cntxt inspect]
smashField: i
	[receiver instfield: i+1 ← tempframe◦(stackptr+1)]
smashLitInd: i
	[(self litof: i) value ← tempframe◦(stackptr+1)]
smashTemp: i
	[tempframe◦(i+1) ← tempframe◦(stackptr+1)]
specialmess: byte toclass: class | "Return false if cannot do it here, else do exactly what the microcode does."
	[byte<0270⇒  "+, -, <, >, ≤, ≥, =, ≠"
		[⇑self specialmess: byte toclassInteger: class];
		<0300⇒[⇑false];  "unused"
		<0304⇒   " ◦, ◦←, next, next← "
			[⇑self specialmess: byte toclassArray: class];
		=0304⇒ "length"
			[ [class≡String⇒[] class≡Vector⇒[] ⇑false]. self push: (self pop length)];
		=0305⇒ "≡"  [self push: self pop≡self pop]
	⇑false]
specialmess: byte toclassArray: class | r n d i s l easy "cause ◦, ◦←, next, next←  to happen"
	[d ← stackptr.  r ← self pop.
	[byte=0301 or⦂ byte=0303 ⇒[n ← self pop]]. " ◦← or next← "
	[byte<0302⇒
			[   " ◦ or ◦← "
			[class≡Vector⇒[] class≡String⇒[] stackptr ← d. ⇑false].
			i ← self pop. l ← r length]
		class≡Stream⇒ " next or next← "
				[s ← r. i ← (s instfield: positionFld)+1.
				l ← (s instfield: limitFld). r ← (s instfield: arrayFld).
				 [r class≡Vector⇒[]; ≡String⇒[]; ≡Interval⇒[] stackptr ← d. ⇑false].
				]
		stackptr ← d. ⇑false].
	
	easy ← [r class≡Vector⇒[true]; ≡String⇒[true]; ≡Interval⇒[true] false].
	[(i class ≡ Integer) and⦂ (l class ≡ Integer)⇒
				[1≤i and⦂ i≤l⇒  " bounds check "
					[[easy ⇒[byte=0301 or⦂ byte=0303⇒ "in the easy case, we cheat for speed"
							[r◦i ← n]  " ◦← or next← "
							n ← r◦i]  " ◦ or next "
						"subclass of Vector or String"
						byte=0301 or⦂ byte =0303 ⇒[r instfield: i ← n] " ◦← or next← "
								n ← r instfield: i].
					 self push: n.
					 [byte>0301⇒[s instfield: positionFld ← i]]. ⇑self]]].
	stackptr ← d. ⇑false]
specialmess: byte toclassInteger: class | r n "If class is Integer, do arithmetic"
	[class ≡ Integer⇒
			[r ← self pop. n ← self pop.
			 r class ≡ Integer⇒
				[⇑self push: [byte
					=0260⇒ [r+n];  =0261⇒ [r-n];
					=0262⇒ [r<n];  =0263⇒ [r>n]; =0264⇒ [r≤n];  =0265⇒ [r≥n];
					=0266⇒ [r=n];  =0267⇒ [r≠n]]]
			 stackptr ← stackptr+2. ⇑false]
	⇑false]
step | byte t "Execute the next byte code and return the current Context"
	[byte ← method◦(pc ← pc+1).
	⇑[byte<0200⇒ "load"
			[byte<020⇒ [self pushField: byte];
				<040⇒ [self pushTemp: byte-020];
				<0100⇒ [self pushLit: byte-040];
				<0160⇒ [self pushLitInd: byte-0100];
				<0170⇒ [self push: (self instfield: byte-0160+1)]
			 self push: SpecialOops◦(byte-0170+2)];
		<0220⇒
			[byte=0200⇒ [self dostore; dopop];
				=0201⇒ [self dostore];
				=0202⇒ [self dopop];
				=0203⇒ [self doreturn];
				=0204⇒ [self doremotereturn];
				=0205⇒ [self push: self];
				=0206⇒ [self dosuper];
				=0210⇒ [self pushField: self nextByte];
				=0211⇒ [self pushTemp: self nextByte];
				=0212⇒ [self pushLit: self nextByte];
				=0213⇒ [self pushLitInd: self nextByte];
				=0214⇒ [self sendmess: nil byte: self nextByte+0320
								 toclass: (tempframe◦(stackptr+1)) class]
			 user notify: 'Unimplemented instruction code'];
		<0260⇒ "jump"
			[t ← [byte<0240⇒[(byte land: 7)+1]
					"short, just mask off bfp bit for displacement"
			 (byte land: 7)-4*256+self nextByte].	"long, calculate displacement"
			[(byte land: 010)≠0⇒[self pop≡false⇒[self dojump: t]]
					"bfp, do branch if top is false"
			 self dojump: t].	"unconditional, do the branch"
			self]
	 self sendmess: nil byte: byte toclass: (tempframe◦(stackptr+1)) class]
	]

Remote evaluation 
eval [user croak] primitive: 30
remoteCopy
	| tResult
[
	tResult ← RemoteContext new
		sender: sender
		receiver: receiver
		method: method
		tempframe: tempframe
		pc: pc+2
		stackptr: stackptr.
	tResult initialize.
	⇑ tResult
]

Interpretation 
have: receiver interpret: method
	["Warning -- someone must be holding methodⓢ literals."
	"Warning -- do not call as self have:interpret: or cycle will result"
	tempframe ← (Vector new: method◦3).
	self restart. ⇑self interpretFor: thisContext sender]
interpret: objectCode with: tframe
	["interpret in new context with tempframe tframe"
	"Warning -- someone must be holding objectCodeⓢ literals."
	"Warning -- do not call as self interpret:with: or cycle will result"
	⇑(Context new
		sender: nil receiver: receiver
		method: objectCode tempframe: tframe
		pc: objectCode◦6 stackptr: objectCode◦5-1)
	  interpretFor: thisContext sender]
interpretFor: sender  "resume execution"
	[PriorityInterrupt new run: self]

Deallocation 
destroyAndReturn: value
	[thisContext sender ← sender.
	tempframe all ← nil.
	⇑value]
eraseFully
	[tempframe≡nil⇒ []
	tempframe all ← nil. tempframe ← nil]
release | s		"release frames to break cycles"
	[ [tempframe≡nil⇒[] tempframe all← nil. tempframe ← nil].
	receiver← nil.
	sender≡nil⇒[] 
	"not sure if this works correctly"
	"[sender Isnt: Context⇒[
		until⦂ (sender Is: Context) do⦂
			[s← sender instfield: 1.
			sender instfield: 5← nil.
			s≡nil⇒[⇑self] sender← s]]]."
	sender release]
releaseFully | c 	"nullify frames to break cycles"
	[c ← self.
	 until⦂ c≡nil do⦂ [c eraseFully. c ← c sender]]
releaseTo: pContext
[
	sender ≡ pContext ⇒ [ sender ← nil. ]
		sender releaseTo: pContext.
		sender ← nil.
]

SystemOrganization classify: ↪Context under: 'Kernel Classes'.

"RemoteContext" 
Class new title: 'RemoteContext'
	subclassof: Context
	fields: ' 
		fSavedPC
		fSavedStackptr
	'
	declare: '';
	asFollows 

CONTEXT FOR REMOTE CODE

REMOTE CONTEXT 
caller
[
	⇑ tempframe ◦ (fSavedStackptr+2)
]
cleancopy
	| tResult
[
	tResult ← RemoteContext new
		sender: sender
		receiver: receiver
		method: method
		tempframe: tempframe copy
		pc: pc
		stackptr: stackptr.
	tResult initialize.
	⇑ tResult
]
initialize
[
	fSavedPC ← pc.
	fSavedStackptr ← stackptr.
]
releaseTo: pContext
[
	tempframe ◦ (fSavedStackptr+2) ≡ pContext ⇒
		[ tempframe ◦ (fSavedStackptr+2) ← nil. ]
		tempframe ◦ (fSavedStackptr+2) releaseTo: pContext.
		tempframe ◦ (fSavedStackptr+2) ← nil.
]
restart
[
	pc ← fSavedPC.
	stackptr ← fSavedStackptr.
]

SystemOrganization classify: ↪RemoteContext under: 'Kernel Classes'.

"UserView" 
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
	asFollows 

This is a melting-pot, incorporating the notions of user interaction (mouse, keyboard), display context (current screen view), and global operations (reading the clock, leaving the system).

Mouse, Cursor, Keys 
anybug [⇑self buttons >0 or⦂ (mem◦0177100) < 0]
anykeys [⇑self keyset>0]
bluebug [⇑self buttons=2]
buttons
	[⇑7-(mem◦0177030 land: 7)]
currentCursor [⇑currentCursor]
currentCursor: c | coff oldpt [
	oldpt ← self mp.
	currentCursor ← c.
	coff ← c offset.
	mxoffset ← coff x - htab.
	myoffset ← coff y - vtab.
	self cursorloc ← oldpt]
cursorloc ← pt 
	[mem◦0424 ← pt x - mxoffset*scale.
	mem◦0425 ← pt y - myoffset*scale]
kbck | t
	[t ← self rawkbck⇒[⇑kbMap◦t] self purgealittle. ⇑false ]
kbd [until⦂ self rawkbck do⦂ [self purgealittle]
	⇑kbMap◦self rawkbd]
kbd: char
	["stuff char into the event queue"
	[char is: String ⇒[char ← char◦1]].
	Events next ←
		UserEvent new
		x:				self x										"event x"
		y:				self y									"event y"
		type:			1											"2=up, 1=down"
		stroke:		(kbMap find: char)					"1-336"
		elapsed:		Events	elapsedtime				"1-32767 sixtieths of a sec"
		time:			Events time + Events elapsedtime.]
kbdnext | event [
	"returns next character (mapped) if any; otherwise false"
	while⦂ [
		(event ← Events dequeue) or⦂
		(event ← Events primitiveDequeue)] do⦂ [
		event isKbdDown⇒ [⇑kbMap◦event stroke]].
	"self rawkbck⇒ [⇑kbMap◦Events next stroke]"
	⇑false]
keyset
	["Fix a bug in sysdefs."
	⇑037 - ((mem◦0177030 lshift: ¬3) land: 037)]
leftShiftKey ["left shift key down?" ⇑(mem◦0177036 land: 0100) = 0]
mp
	[scale=2⇒
		[⇑Point new
		x: mem◦0424 + mxoffset / 2
		y: mem◦0425 + myoffset / 2]
	⇑Point new
		x: mem◦0424 + mxoffset
		y: mem◦0425 + myoffset]
mpnext [
	"return next mouse point if red button or tablet is down; otherwise false"
	self redbug⇒ [⇑self mp]
	⇑false]
nobug
	[⇑self anybug ≡ false]
rawkbck | event				"flush event queue until down keyboard event or queue empty."
			[while⦂ (event ← Events peek) do⦂
				[event isKbdDown ⇒[⇑event stroke] Events next].
			⇑false							"if queue empty, return false"
			]
rawkbd | stroke
			[until⦂ (stroke ← self rawkbck) do⦂ [].			"wait for activity"
			Events next.  ⇑stroke								"if key down, pop queue and return stroke"
			]
redbug [⇑self buttons=4 or⦂ (mem◦0177100) < 0]
tablet [⇑(mem◦0177100) ≠ 0]
tabletabsolute [mem◦0126 ← 1]
tabletbug [⇑(mem◦0177100) < 0]
tabletrelative [mem◦0126 ← ¬1]
waitbug
	[until⦂ self anybug do⦂ [] ⇑self mp]
waitclickbug
	[self waitnobug. ⇑self waitbug]
waitnobug
	[while⦂ self anybug do⦂ [] ⇑self mp]
waitnokey [until⦂ self keyset=0 do⦂ [self rawkbck]]
x [⇑mem◦0426 - htab		"cursorx, horiz tab adjusted"]
y [⇑mem◦0427 - vtab		"cursory, vert tab adjusted"]
yellowbug [⇑self buttons=1]

Screen Views 
bugScreenMenu
	["see classInit"
	screenMenu bug
		=1⇒[projectWindow≡nil⇒[] projectWindow runParent];
		=2⇒[user quit];
		=3⇒[self restartup: ProjectWindow init];
		=4⇒[self restartup: BrowseWindow default];
		=5⇒[self restartup: (CodeWindow new class: UserView selector: ↪workspace
				para: (UserView code: ↪workspace) formerly: false)];
		=6⇒[user displayoffwhile⦂ [self reclaim]]
	]
color: color scale: scale	[self install]
copyIn: p
	[⇑UserView new
		screenrect: screenrect copy
		vtab: vtab htab: htab scale: scale color: color
		projectWindow: p
		disp: disp sched: ↪()]
displayoffwhile⦂ expr | t v
	["t ← mem◦0420. mem◦0420 ← 0."
	t ← mem◦067. mem◦067 ← 58 "disp text frame maxY/2 ?".
	v ← expr eval.
	mem◦067 "0420" ← t. ⇑v]
install
	[self screenextent: screenrect extent tab: htab⌾vtab]
projectWindow [
	[projectWindow≡nil⇒
		[projectWindow ← ProjectWindow new.
		projectWindow userview: self changes: Changes parent: projectWindow]].
	⇑projectWindow]
reconfigure [] primitive: 62
restoredisplay
	[mem◦0420 ← 060. mem◦067 ← screenrect height/2]
screenextent: extent tab: tab [
	mem◦065 ←
		(color*040000)+[scale=2⇒[0100000] 0]+(tab x/16*0400)+(extent x/16|2).
	mem◦067 ← extent y*scale/2.
	mem◦063 ← 1 max: tab y/2.
	htab ← tab x|16.
	vtab ← mem◦063*2.
	screenrect ← 0⌾0 rect: (extent x|32)⌾(extent y|2).
	self currentCursor: currentCursor;
		reconfigure; restore]
screenrect [⇑screenrect]
screenrect: screenrect vtab: vtab htab: htab scale: scale color: color projectWindow: projectWindow disp: disp sched: sched

Window Scheduling 
leaveTop		"leave the top window if there is one"
	[sched length=0⇒[]
	(sched◦1) leave]
promote: window
	[sched promote: window]
restart | i 
			[[Events ≡ nil ⇒
				[Events ← EventQueue init. "Top init3.  initialize Event queue and Time interrupt"]].
			NormalCursor topage1.
			self restart⦂ [user run]]
restart⦂ code | u
	[u ← code cleancopy. u sender ← nil.
	thisContext sender releaseFully.
	thisContext sender ← nil.	code ← nil. 	"release caller chain"
	MessageDict new freeMethods.		"release held code"
	disp frame flash.
	while⦂ true do⦂ [u eval]]
restartup: window
	[ "Equivalent to schedule new window, restart, and redbug in window, except firsttime is already done."
	thisContext sender releaseFully. thisContext sender ← nil.
	NormalCursor topage1.
	self schedule: window.
	thisContext tempframe all ← nil.
	self run: true]
restore | w
	[screenrect clear.
	[projectWindow≡nil⇒[] projectWindow putTitle].
	for⦂ w from: (sched length to: 1 by: ¬1) do⦂
		[(sched◦w) show]]
run
	[self run: false]
run: topFlag | i w forward	"topFlag means sched◦1 already is awake"
	[forward ← [topFlag⇒ [w←sched◦1. while⦂ w eachtime do⦂ []. w lasttime] true].
	while⦂ true do⦂
		[i←0.
		until⦂ [(i←i+1)>sched length⇒[]
			w← [forward⇒[sched◦i] sched◦(sched length+1-i)].
			w firsttime] do⦂ []
		i>sched length⇒		"check for bug in empty space"
				[user yellowbug⇒[self bugScreenMenu]]
		sched promote: w.
		while⦂ w eachtime do⦂ []
		forward← w lasttime]]
sched [⇑sched]
schedule: window
	[sched≡nil⇒[sched ← window inVector]
	sched ← window inVector concat: sched]
scheduleOnBottom: window
	[sched≡nil⇒[sched ← window asVector]
	sched ← sched concat: window asVector]
topWindow [⇑sched◦1]
unschedule: window | t
	[0<(t← sched find: window)⇒
		[sched ← sched◦(1 to: t-1) concat: sched◦(t+1 to: sched length)]]

Notify Window 
notifier: titleString level: lev interrupt: flag
	["Restore the full display.  Schedule a one-paned window to notify the user that errorString happened."
	self restoredisplay.
	NotifyFlag≡false⇒
		[disp cr;
			append: 'NotifyFlag is false...'; cr;
			append: ' top-blank shows stack, user restart aborts,'; cr;
			append: ' tempframe shows args, ctrl-d proceeds'; cr;
			append: titleString; cr; show.
		(Top◦lev) debug. ⇑false]
	⇑NotifyWindow new of: titleString level: lev interrupt: flag]
notifier: titleString stack: stack interrupt: flag
	["Restore the full display.  Schedule a one-paned window to notify the user that errorString happened."
	self restoredisplay.
	NotifyFlag≡false⇒
		[disp cr;
			append: 'NotifyFlag is false...'; cr;
			append: ' sender debug shows stack, user restart aborts,'; cr;
			append: ' tempframe shows args, ctrl-d proceeds'; cr;
			append: titleString; cr; show.
		stack debug. ⇑false]
	⇑NotifyWindow new of: titleString stack: stack interrupt: flag]
notify: errorString | notifyWindow
	["Create a notify window looking at the Context stack"
	notifyWindow ← self notifier: errorString stack: thisContext sender interrupt: false.
	notifyWindow⇒
		[thisContext sender ← nil.
		 Top currentPriority=1⇒
			[self restartup: notifyWindow]
		 self scheduleOnBottom: notifyWindow.
		 Top errorReset]
	⇑nil]

Dialog Window 
clear		"clear disp of debris and characters"
	[disp clear]
clearshow: str
	[disp clear; append: str; show]
cr [disp cr]
croak
	[self notify: 'A primitive has failed.']
ev
	[disp ev]
frame		"return rectangle of dialogue window"
	[⇑disp text frame]
newdisp "for when some class associated with running Dispframe  changed"
	[
	self unschedule: disp.
	disp ← Dispframe new rect: (8⌾0 rect: 150⌾96).
	self schedule: disp ; clearshow: 'New Dialogue window created.
']
newdisploc: origin and: corner "for moving disp"
	["user newdisploc: 8⌾0 and: 150⌾96"
	(disp text frame inset: ¬2⌾¬2) clear.
	disp text frame ← origin rect: corner.
	disp show]
next ← x ["simulate a Vector Stream"	disp cr; print: x; show]
print: x [disp print: x; show]
read [⇑disp read]
request: s[⇑disp request: s]
show [disp outline; show]
show: str
	[disp append: str; show]
space
	[disp space]
tab [disp tab]

Time 
convertTime: s returnSecs: format | d dd t dfirst dlast m570 m571 [
	"s is total seconds from midnight Jan 1 1901 GMT (Greenwich mean time).
	see maxc <AltoDocs>AltoTime.Press for details"

	"time zone specific parameters"
	m570 ← mem◦0570. m571 ← mem◦0571.

	"adjust for time zone"
	s ← s + (([m570 ≥ 0⇒ ["west" ¬1] "east" 1]) * (
		(3600 * ("hours" m570 bits: (1 to: 4))) +
		(60 * ("additonal minutes" m571 bits: (1 to: 6))))).

	t ← s intdiv: 86400.
	"current day (in local standard time)"
	d ← Date new fromDays: t◦1.
	[format⇒ [] t ← Time new fromSeconds: t◦2].

	"check for DST. correct DST parameters for nonleap years and
	round to previous Sunday if necessary"

	"day of the year on or before which DST takes effect"
	dfirst ← m570 land: 0777 "bits: (7 to: 15)".

	[[dfirst = 366⇒ ["DST not in effect" false]
	(dd ← d day) ≥ (dfirst ← dfirst + d leap - 1)⇒ [

		"day of the year on or before which DST ends"
		dlast ← (m571 land: 0777 "bits: (7 to: 15)") + d leap - 1.
		dd < dlast "if false, definitely after" and⦂
		dd < ((Date new day: dlast year: d year) previous: 6) day]
	"possibly earlier than or at beginning of range"
	dd ≥ ((Date new day: dfirst year: d year) previous: 6) day]⇒ [

		"daylight savings time in effect. add an hour"
		format⇒ [s ← s + 3600]
		t hours = 23⇒ [
			d ← d+1.
			t hours: 0]
		t hours: t hours+1]].

	"return either total seconds or Date and Time"
	format⇒ [⇑s] ⇑d,t]
dateAndTime: secs [
	"secs is a String of 4 characters representing seconds (in GMT) since Jan 1 1901.
	convert it to a LargeInteger (rawtotalsecs:), then return a Vector (Date, Time),
	which is corrected for local time zone and daylight savings"

	⇑self convertTime: (self rawtotalsecs: secs) returnSecs: false]
now [⇑self dateAndTime: self timewords]
rawtotalsecs [⇑self rawtotalsecs: self timewords]
rawtotalsecs: secs | s [
	"secs is a String of 4 characters representing seconds (in GMT) since Jan 1 1901.
	copy (in reverse order) to a Natural string, then return a LargeInteger"

	s ← Natural new: 4.
	s◦1 ← secs◦4.
	s◦2 ← secs◦3.
	s◦3 ← secs◦2.
	s◦4 ← secs◦1.
	⇑LargeInteger new bytes: s neg: false]
ticks "Return the 38.08-millisecond interval timer"
	[⇑mem◦0430]
time [⇑self now◦2]
time⦂ expr | t
	[t ← self ticks.  expr eval.  ⇑self ticks-t]
timewords | s [
	"seconds (in GMT) since Jan 1 1901: as a String"
	s ← String new: 4.
	s word: 1 ← mem◦0572; word: 2 ← mem◦0573.
	⇑s]
today [⇑self now◦1]
totalsecs [⇑self totalsecs: self timewords]
totalsecs: secs [
	"convert from GMT to local and correct for Daylight Savings"
	⇑self convertTime: (self rawtotalsecs: secs) returnSecs: true]

Changes 
changedCategories | titles space str
	["return a vector of the names of class categories which have been changed"
	space ← ' '◦1.
	titles ← HashSet new init.
	for⦂ str from: Changes contents do⦂
		[titles insert: (
			SystemOrganization invert: ((Stream new of: str) upto: space) unique)].
	⇑titles contents
	]
changedClasses | titles space str
	["return a vector of the names of classes which have been changed"
	space ← ' '◦1.
	titles ← HashSet new init.
	for⦂ str from: Changes contents do⦂
		[titles insert: ((Stream new of: str) upto: space). "class title"].
	⇑titles contents
	]
changedMessages [⇑Changes contents sort]
noChanges [Changes init]

System quit/resume 
backup   "back up smalltalk on ivy and resume"
	[ivy open; delete: 'small.boot'; store: 'small.boot'; close]
hasXM
	["return true if this is XM Smalltalk"
	⇑(mem◦0147)≠0 "1 for XM, 0 for normal"
	]
InLd: fileid  "write out the core image, then load in OS"
	[user notify: 'file problem'] primitive: 85
overlay: fileid | t [
	dp0 stampBoot.
	self releaseExternalViews.

	"put the ethernet to sleep"
	[E≡nil⇒ [] E sleep].

	"turn off display during quit/resume"
	t ← mem◦0420. mem◦0420 ← 0.
	self InLd: fileid.

	"we start here after a resume"
	mem◦0420 ← t.
	while⦂ user keyset>0 do⦂ [user show: 'The keyset is stuck'; cr]]
quit 
	[self quitFrom: self "yup"]
quitFrom: controller
	[self overlay: ↪(0 0 0 0 0).
	self hasXM⇒[
		screenrect clear.
		controller restore]]
quitThen: str | rem rest ["quit, then have OS execute str"
	rem ← (dp0 file: 'rem.cm') readonly.
	rest ← rem next: rem length.
	rem readwrite; reset; append: str; cr; append: rest; close.
	self quit]
quitThen: s continue: r [
	[s⇒ [
		"something for O.S. to do"
		(dp0 oldFile: 'rem.cm.') settoend;
			append: s; append: '; ';
			append: [r⇒ ['Resume.~ small.boot'] 'Quit.~; Resume.~ small.boot'];
			cr; flush]].
	self quit]
releaseExternalViews | t [
	"close some things that we know about, everything else gets released"
	Sources close. dp0 close. dp1 close.

	"release (obsolete) some external views, usually File related"
	for⦂ t from: externalViews length to: 1 by: ¬1 do⦂ [
		(externalViews◦t) release. externalViews◦t ← nil].
	externalViews reset]
Swat [] primitive: 90

Misc System Stuff 
classInit [
	screenMenu ← Menu new string:
'exit to overview
quit
open a subview
open a browser
open a workspace
reclaim']
classNames		"an alphabetized Vector of all Smalltalk class titles uniqued"
		| classes x c
	[
	AllClassNames≡nil⇒
		[
		classes ← (Vector new: 20) asStream.
		for⦂ x from: Smalltalk do⦂
			[
			c ← Smalltalk ◦ x.
			(c is: Class) or⦂ (c is: VariableLengthClass)⇒ [classes next ← x].
			].
		AllClassNames ← classes contents sort.
		].
	⇑AllClassNames
	]
file: file classes: classes changesOnly: ch | cl [
	"called by UserView release to write just changes or entire system on a
	new file.  also, see comment in Class archiveOn:changesOnly:.

	write class comment and message text onto a FileStream (which could refer
	to an AltoFile, ILFile, etc.). either just changes or everything are
	written and replaced with RemoteParagraph references"

	[ch⇒ [file settoend] file reset].
	file readwriteshorten.
	for⦂ cl from: classes do⦂ [Smalltalk◦cl archiveOn: file changesOnly: ch].
	file close; readonly]
growSmalltalk: numberofdiskpages
	"for preemptive growth of Small.boot on disk"
	[dp0 growSmalltalkBy: numberofdiskpages]
initCompiler  "Initialize shared variables of parser and generators"
		| code sel c t
	[
	Smalltalk declare: ↪(TokenCodes ByteCodes).
	[TokenCodes≡nil⇒ [TokenCodes←SymbolTable new init: 32]].
	[ByteCodes≡nil⇒ [ByteCodes←SymbolTable new init: 32. Integer sharing: ByteCodes]].
	TokenCodes
		declare:
			↪(aRightBrack aPeriod "First 2 in this order"
			aLeftPar aSemicolon aCondArrow aHand aReturnArrow
			aLeftBrack aRightPar aLeftArrow
			aBinary "All above must be less, all below must be greater"
			aNumber aString "All below must be in that order"
			aKeyword aGibberish aColon aDigit aWord)
		as:
			↪(1 2
			3 4 5 6 7
			8 9 10
			20
			30 31
			41 42 43 44 45
			).
	ByteCodes
		declare:
			↪(toLoadField toLoadTemp toLoadLit toLoadLitInd
			toLoadCtxt toLoadTempframe
			toLoadConst toLoad0 toLoad1 toLoadSelf toLoadNil toLoadFalse toLoadTrue
			toSmashPop toSmash toPop toReturn toEnd toLoadThisCtxt toSuper
			toShortJmp toShortBfp toLongJmp toLongBfp
			toPlus toMinus toGtr toGeq toNext toEq toNew toAsStream
			toSendLit)
		as:
			↪(0 16 32 64
				112 116
				120 121 122 113 125 126 127
				128 129 130 131 132 133 134
				144 152 160 168
				176 177 179 181 194 197 203 207
				208).
	c ← Dictionary new init: 16.
	c insertall: ↪('self' 'thisContext' 'super' 'nil' 'false' 'true')
		with: ↪(113 133 134 125 126 127).
	ByteCodes declare: ↪stdPrimaries as: c.
	c ← Dictionary new init: 64.
	code ← 175.
	for⦂ sel from: SpecialOops ◦(10 to: SpecialOops length) do⦂
		[ "Atoms not wanted here -- only strings and characters"
		code ← code+1.
		sel≡nil ⇒ []
		sel ← [sel length=1 and⦂ (sel◦1) isletter ≡ false ⇒ [sel◦1] sel asString].
		c insert: sel with: code.
		].
	ByteCodes declare: ↪stdSelectors as: c.
	c ← Dictionary new init: 8.
	c insertall: ↪('while⦂do⦂' 'until⦂do⦂' 'for⦂to:do⦂' 'for⦂from:do⦂' 'for⦂from:to:by:do⦂' 'for⦂from:to:do⦂' 'if⦂then⦂else⦂' 'if⦂then⦂')
		with: ↪(whiledo:args: untildo:args: fortodo:args: forfromdo:args: forfromtobydo:args: forfromtodo:args: ifthenelse:args: ifthen:args:).
	ByteCodes declare: ↪inLineMsgs as: c.
	for⦂ t from: ↪((toLoadFieldLong 0210) (toLoadTempLong 0211) (toLoadLitLong 0212)
			(toLoadLitIndLong 0213) (toSendLitLong 0214)
			(codeLoadField 0400) (codeLoadTemp 01000) (codeLoadLit 01400)
			(codeLoadLitInd 02000) (codeSendLit 02400)) do⦂
		[ByteCodes declare: t◦1 as: t◦2]]
oopsToFile | a c i t s cs f ts
	[f ← dp0 file: 'oops'.
	cs ← user classNames transform⦂ a to⦂ Smalltalk◦a.
	t ← cs transform⦂ a to⦂ a asOop.
	ts ← t permutationToSort.
	for⦂ i from: ts do⦂
		[f append: (t◦i) base8; tab; append: (cs◦i) title; cr].
	for⦂ c from: cs◦ts do⦂
		[f cr; append: c title; cr.
		s ← c md contents.	"selectors"
		t ← s transform⦂ a to⦂ (c md method: a) asOop.  "method oops"
		for⦂ i from: t permutationToSort do⦂
			[f tab; append: (t◦i) base8; tab; append: s◦i; cr]
		user show: c title; cr]
	f close]
printCrossReference: classNames on: f | dict m md frame l each s class
"user displayoffwhile⦂ [
	user printCrossReference: user classNames
		on: (dp0 file: 'CrossReference.Press')].

		user classNames
		(SystemOrganization category: 'xyz')
		↪(class1 class2)"

	[dict ← Dictionary init: 200.
	for⦂ m to: 32 do⦂
		[dict insert: SpecialOops◦(9+m) with: ↪((Primitives) ()) copy].
	classNames transform⦂ each to⦂
		[user show: each; space.
		md← (Smalltalk◦each) md.
		for⦂ m from: md do⦂			"Tally all the UniqueString literals"
			[	[s← dict lookup: m⇒[] dict insert: m with: (s← ↪(()()) copy)].
			s◦1 has: each⇒[] s◦1← s◦1, each.
			for⦂ l from: (md literals: m) do⦂
				[l is: UniqueString⇒
					[	[s← dict lookup: l⇒[] dict insert: l with: (s← ↪(()()) copy)].
					s◦2 has: each⇒[] s◦2← s◦2, (each,m)]]]].

	f← f asPressPrinter.
	f stamp.
	frame← f defaultframe.			"Print the messages out sorted"
	for⦂ m from: dict contents sort do⦂
		[user show: m; space.
		f frame← frame.
		md← dict◦m.
		s← (String new: 200) asStream.
		s append: m; append: [(md◦1) length=0⇒[' ( - undefined -  '] ' ('].
		for⦂ l from: (md◦1) sort do⦂ [s append: l; append: ', '].
		s skip: ¬2; append: ')'.
		f print: (s contents asParagraph maskrun: 1 to: m length under: 1 to: 1).
		f frame← (frame minX+500)⌾frame minY rect: frame corner.
		s reset.
			[md◦1 has: ↪Primitives⇒[s append: 'untallied.'. md◦2← ↪()]
			(md◦2) length=0⇒[s append: '- unreferenced -']].
		class← ↪-.
		for⦂ l from: (md◦2) sort do⦂
			[	[l◦1=class⇒[s append: ', ']
				[class≠↪-⇒[s cr]]. s append: '('; append: l◦1; append: ') '.
				class← l◦1].
			s append: l◦2].
		f print: s contents asParagraph].
	f close; toPrinter]
purgealittle [] primitive: 89
reclaim | c cl cv		" Should only be called from bugScreenMenu !! "
	[user cr; show: 'Reclaiming... '.
	cl← CodePane, ScrollBar, PanedWindow, ListPane, Generator, Parser, BitImage, Document, DocumentEditor, Image.
	cv← Context allInstances.
	user print: cv length.
	for⦂ c from: cv do⦂ [cl has: c mclass⇒[c release]]. cv all← nil.
	user show: ' reduced to ' + Context howMany asString + '.']
release | m [
	"prepare to release this version (after editing UserView version)
	and possibly copying Sources file (see writeSources:)"

	(m← Undeclared contents) length>0⇒
		[user notify: 'Undeclared contains '+ m asString]

	user displayoffwhile⦂ [
		"either create a new Sources file (write all messages) or append only changes"
		m ← Sources directory checkName:
			'<Smalltalk>Smalltalk.Sources.' + user versionName.
		"for repeated releases in same version.
		should also work for Sources local (if renamed)"
		user writeSources: [m = Sources name⇒ [Sources] Sources directory file: m].

		"make workspace local"
		UserView md code: ↪workspace ← UserView code: ↪workspace.
	
		user writeChangedMessages: (phylum file: '<Smalltalk>ChangedMessages').].

	user noChanges. user releaseMessage.]
releaseMessage [user clearshow: 'Welcome to ' + user version]
systemStartup "To do after system flush and installation of new core image"
	[Top top.
	Window classInit.

	"The following screen extent seems to really fill the screen in x,
	the Alto Hardware Manual to the contrary notwithstanding."
	[self hasXM⇒ ["XM" self screenextent: 640⌾800 tab: 0⌾2]
	self screenextent: 640⌾480 tab: 0⌾50].

	Sources release. dp0 release. dp1 release.
	self releaseExternalViews.
	[E≡nil⇒ [] "ignore broadcasts" E broadcastFilter: true].

	(VirtualMemory new) thisvmem.
	Vmem afterBirth]
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
	dp0 filin: ↪('changes.st').
	phylum filin: ↪('<Small-goodies>xx.st').
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
	| c classes. user releaseExternalViews. classes ← (Vector new: 50) asStream.
	phylum name: 'name' password: 'password'.
	for⦂ c from: ↪('category1' class1) do⦂ [
		c is: String⇒ [classes append: (SystemOrganization category: c)]
		classes next ← c].
	user file: (phylum file: '<ddd>xx.Sources.' + user versionName)
		classes: classes contents changesOnly: false.
"
systemworkspace2		"for system releasers only!!!


5. if no surgery or vmem write involved, skip to step 7. start here with an xm version to make a non-xm version.  specify option below:
	1 vmem write (includes xm surgery)
	2 xm surgery
	3 non-xm surgery
to make things totally automatic, edit in your valid Maxc name and password, otherwise Ftp will ask you later. in the case of surgery only, at the end you will have to hit a key after safing.

	| option prefix dir file.
option ← 1.
dir ← phylum asFtpDirectory.
dir directoryName: 'Smalltalk-76'.
prefix ← [option=3⇒ [''] 'Xm'].
for⦂ file from: ↪('Smalltalk.Run' 'Smalltalk.Syms' 'Byterp.Mb') do⦂ [
	dir retrieve: prefix + file as: file].
dir closeThen: ([option=1⇒ ['delete oldsmall.boot;
copy newsmall.boot ← small.boot; '] '']) + 
'ftp maxc Login/c yourname yourpassword directory/c alto retrieve/c packmu.run ramload.run;
Resume small.boot;
Ramload/N Byterp.mb/F 1000/A;
Smalltalk.run'.

option=1⇒ [(VirtualMemory new) giveBirth3. user quit]
Vmem ramwrite: (dp0 oldFile: 'byterp.mb').
Vmem surgery: (dp0 oldFile: 'Smalltalk.run').


6. after a successful vmem write or surgery, execute this (selecting here is tricky or type in a Dispframe)
	user systemStartup.


7. edit lastversion (and Smalltalk password) and execute the following, then close this window (clean up screen for non-xm?), and quit. it then renames old versions of files, stores new versions of files, e.g. remote XmSmall.Boot becomes XmSmall.Boot.5.5g and local Small.Boot becomes remote XmSmall.Boot
	| lastversion dir file remotefile.
	lastversion ← '5.5j'.
	dir ← phylum asFtpDirectory.
	dir login: 'Smalltalk' password: 'password'.
	for⦂ file from: ↪('Small.Boot' 'Smalltalk.Syms') do⦂ [
		remotefile ← ([user hasXM⇒ ['Xm'] '']) + file.
		dir rename: remotefile newName: remotefile + '.' + lastversion;
			store: file as: remotefile].
	(dp0 file: 'rem.cm') append: dir commands; cr; close.
	user releaseMessage.
"
systemworkspace3		"for system releasers only!!!


8. to update press files for system categories or cross reference listing directly on Phylum, browse or spawn this window.  edit pf to specify a list of system categories to print, usually from step 1, e.g. user changedCategories: ↪('Basic Data Structures' ...) or SystemOrganization categories (for all); delete toPrinter if you don't want the press files printed. edit xref to be user classNames if you want to generate a cross reference listing.
	 | pf xref cat.
	pf ← ↪  ('Text Objects' 'Kernel Classes' 'Press File Support' 'IFS File System' 'Alto File System' 'Panes and Menus' 'Files' 'Juniper' 'Windows' 'Graphical Objects' 'Numbers' 'Basic Data Structures' ).
	xref ← ↪().

	user releaseExternalViews.
	phylum name: 'Smalltalk' password: 'password'.
	for⦂ cat from: pf do⦂ [
		((phylum file: (cat + '.Press') asFileName) asPressPrinter) stamp;
			printclass: (SystemOrganization category: cat); close; toPrinter].
	xref empty⇒ []
	user printCrossReference: xref on: (phylum file: 'CrossReference.Press').
"
version [⇑'Smalltalk 5.5k ' + [user hasXM⇒ ['XM '] ''] + 'November 24']
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
"
versionName | s [
	s ← self version asStream.
	"skip Smalltalk"
	s skipTo: 040.
	"return version identification, e.g. 5.5f"
	⇑s upto: 040]
workspace
	[user notify: 'Not meant to be executed']
"
XEROX - Learning Research Group
 
user screenextent: 640⌾580 tab: 0⌾50.
NotifyFlag ← true.
Changes init.
user changedMessages
user changedClasses
user changedCategories
Undeclared contents

to set the default printer
PrinterName←'Menlo'.
PrinterName←(PressFile new) selectPrinter: PrinterName.

to change phylum to access your account
user releaseExternalViews. phylum name: 'name' password: 'password'.

dp0 filin: ↪('Changes.st').
(dp0 file: 'changes.st') filout.
(dp0 file: 'xxx') edit.
dp0 pressfilin: ↪('xxx.press').
(dp0 filesMatching: '*.st') sort
dp0 list. dp0 freePages
dp0 delete: 'old'
dp0 rename: 'old' newName: 'new'

for reinitializing Sources and phylum
Sources release. phylum release. Sources reopen.

to make Smalltalk Sources local
 | s. s ← 'Smalltalk.Sources.'.
(phylum asFtpDirectory) retrieve: '<Smalltalk>' + s + user versionName as: s; close.
Sources on: (dp0 file: s).

to switch back to remote Sources
Sources close; on: (phylum file: '<Smalltalk>Smalltalk.Sources.' + user versionName).


to filin a remote Smalltalk file
phylum filin: ↪('<Small-goodies>xxx.st').

to print a remote/local press file
(phylum pressfile: '<Smalltalk>xxx.press') toPrinter.
(dp0 pressfile: 'xxx.press') toPrinter: 'Lilac'.

File noChanges.
BitRect new fromuser; edit.
user schedule: (defaultBitRectEditor newframe).

DocumentEditor new defaultdocument: 'test'.
DocumentEditor new init: (Document new fromPress: 'test.document').


user releaseExternalViews.
E sleep. E kill. E ← nil.
E ← Etherworld new. E broadcastFilter: true. E wakeup.
Sources reopen.

for primary Smalltalk access to file servers and printers at other sites.
substitute yourserver for phylum above, compile this workspace
PrinterName ← 'name-of-your-printer'.
Smalltalk declare: ↪yourserver.
yourserver ← ILFileDirectory new directory: 'name-of-your-server'.
yourserver name: 'Smalltalk-User' password: 'Smalltalk'.
Sources on: (yourserver file: '<Smalltalk>Smalltalk.Sources.' + user versionName).
Changes init.

user Swat.
" 5f0 3b23B59i1I98i27I79i40I296i38I50i31I146i32I89i32I44i34I311i1I125i137I
writeChangedMessages: ChangedMessages | class m ms [
	"append changed messages to a file (usually on [phylum])"
	ChangedMessages settoend; cr; cr; asParagraphPrinter stamp.
	class ← ''.
	for⦂ m from: user changedMessages do⦂
		[ms← m asStream.
		(ms upto: 040)=class⇒
			[ChangedMessages append: ', '; append: (ms upto: 040)]
		ChangedMessages cr; append: m.
		class← m asStream upto: 040].
	ChangedMessages close]
writeSources: newSources [
	"write a new Sources file (usually on [phylum]Smalltalk.Sources.xxx
		(i.e. xxx = user versionName))
	if it's a new file or empty, write all Sources. otherwise it better be a copy of
	the previous Sources file (only changes will be appended. do the copy with ftp)"

	user file: newSources classes: SystemOrganization
		changesOnly: (newSources end ≡ false).
	Sources close.
	Sources ← newSources]


SystemOrganization classify: ↪UserView under: 'Kernel Classes'.
UserView classInit

"VariableLengthClass" 
Class new title: 'VariableLengthClass'
	subclassof: Class
	fields: ''
	declare: '';
	veryspecial: 20;
	asFollows 

I am a class whose instances have numbered elements instead of named fields.

Initialization 
classInit		"gets propagated to a dummy instance"
	[(self new: 1) classInit]

Instance access 
allInstances [user notify: 'use allInstances: instead to specify the length range'
	"the length ranges are 0,1,2,3,4,5,6,7,8 individually and groups 9 (to 16), 17 (to 32), 33 (to 64), 65, 129, 257, 513, 1025, 2049, and 4197"]
allInstances: len [⇑(self allInstancesEver: len) notNil]
allInstancesEver: len | indx vec PCLs i "returns a vector containing all instances of this class and length mixed with nils"
	["for large lengths, instances come in groups with lengths within a single power of 2"
	PCLs ← Vmem pclassesOf: self length: len.  "vector of PCLs"
	vec ← Vector new: 128*PCLs length.
	for⦂ i to: PCLs length do⦂ 
		[(vec◦[i-1*128+1 to: i*128]) all← PCLs◦i].
	thisContext destroyAndReturn:
		(self fromFreelist: (Vmem freelistOffset: len) fill: vec)]
copy: inst | t i
	[t ← self new: inst length.
	for⦂ i to: inst length do⦂
		[t◦i ← inst◦i]
	⇑t]
howMany: len | v "how many instances of this class and length are in use now?"
	[v ← self allInstancesEver: len.
	thisContext destroyAndReturn: v length - (v count: nil)]
new
	[user notify: 'use new: <Integer=length> here.']
new: length
	[length>16384 ⇒[user notify: length asString+
												' is too big a String']
	length>8192 ⇒[user notify: length asString+
												' is too big a Vector']
	length<0 ⇒[user notify: length asString+
												' -- negative length is invalid']
	⇑self new: length asInteger] primitive: 29
recopy: inst | t i
	[t ← self new: inst length.
	for⦂ i to: inst length do⦂
		[t◦i ← (inst◦i) recopy]
	⇑t]

SystemOrganization classify: ↪VariableLengthClass under: 'Kernel Classes'.
