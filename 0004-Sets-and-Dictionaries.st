'From Smalltalk 5.5k XM November 24 on 22 November 1980 at 2:57:08 am.'

"ClassOrganizer" 
Class new title: 'ClassOrganizer'
	subclassof: Object
	fields: 'globalComment commentVector groupVector'
	declare: 'default ';
	asFollows 

ClassOrganizers contain the formatting information for printing classes.  Each String in commentVector describes a category comprising the messages contained in the Vector which is the corresponding entry in groupVector.

Initialization 
classInit
	[default ← 'As yet unclassified']
init: sortedVec
	[self globalComment ← 'This class has not yet been commented'.
	commentVector ← 'As yet unclassified' inVector.
	groupVector ← sortedVec inVector]

Access to parts 
asStream | v t
	[v ← Stream new of: (Vector new: 200).
	for⦂ t from: groupVector do⦂ [v append: t].
	⇑v contents asStream]
categories [⇑commentVector]
category: str | i
	[i ← commentVector find: str.
	i=0⇒[user notify: 'No such category: '+str]
	⇑groupVector◦i]
classify: selector under: heading | s h n
	[selector is: Vector⇒
		[for⦂ s from: selector do⦂
			[self classify: s under: heading]]
	s ← commentVector find: heading.
	s>0 and⦂ (groupVector◦s has: selector)⇒[⇑self]
	[h ← self invert: selector⇒
		[heading=default⇒[⇑self]
	 	 n ← commentVector find: h.
		 groupVector◦n ← groupVector◦n delete: selector]].
	[s=0⇒ [s ← self insert: heading]].
	groupVector◦s ← groupVector◦s insertSorted: selector.
	n ← commentVector find: default.
	n>0 and⦂ (groupVector◦n) length=0⇒
		[self deleteCategory: n]]
delete: selector | i		"delete this from all categories"
	[for⦂ i to: groupVector length do⦂
		[groupVector◦i has: selector⇒
			[groupVector◦i ← (groupVector◦i) delete: selector.
			(groupVector◦i) length=0 and⦂ commentVector◦i=default⇒
				[self deleteCategory: i]]
		]]
deleteCategory: index
	[groupVector ← groupVector without: index.
	commentVector ← commentVector without: index]
globalComment [⇑globalComment asParagraph text]
globalCommentItself [
	"used only by Class archiveOn:changesOnly:" ⇑globalComment]
globalComment ← globalComment "String or RemoteParagraph"
has: sel | t
	[for⦂ t from: groupVector do⦂
		[t has: sel⇒[⇑true]]
	⇑false]
insert: heading | di dgroup hi  "force default category to end, delete if empty"
	[[(di←commentVector find: default)>0⇒ [dgroup ← groupVector◦di]].
	commentVector ← (commentVector without: di), heading.
	groupVector ← (groupVector without: di), (Vector new: 0).
	hi ← commentVector length.
	di=0 or⦂ dgroup length=0⇒ [⇑hi]
	commentVector ← commentVector, default.
	groupVector ← groupVector, dgroup.
	⇑hi]
invert: selector | i
	[for⦂ i to: groupVector length do⦂
		[groupVector◦i has: selector⇒[⇑commentVector◦i]]
	⇑false]

Conversion to text 
asParagraph | s i
	[s ← Stream default.
	s print: self globalComment.
	for⦂ i to: commentVector length do⦂
		[s cr; print: ((commentVector◦i) inVector concat: groupVector◦i)]
	⇑s contents asParagraph]
fromParagraph: para | t i j g
	[user displayoffwhile⦂
	[t ← para asVector.
	self globalComment ← t◦1.
	commentVector ← Vector new: t length-1.
	groupVector ← Vector new: t length-1.
	for⦂ i to: t length-1 do⦂
		[g ← t◦(i+1).
		commentVector◦i ← g◦1.
		until⦂ 0=(j← g find: ↪←) do⦂		"reconstitute ← suffixes"
			[g ← g replace: j-1 to: j by: (g◦(j-1)+'←') unique inVector]
		groupVector◦i ← (g copy: 2 to: g length) sort]
	]]

SystemOrganization classify: ↪ClassOrganizer under: 'Sets and Dictionaries'.
ClassOrganizer classInit

"Dict" 
Class new title: 'Dict'
	subclassof: Object
	fields: ''
	declare: '';
	asFollows 

a model for dictionary-index classes

Initialize 
init: initialSize "default is to ignore"

Name-Value Access 
◦ name | entry ["find"
	entry ← self find: name⇒ [⇑entry value]
	⇑false]
◦ name ← value [ "replace or insert"
	⇑self write: (self newEntry name: name value: value)]
insert: name with: value [
	⇑self insert: (self newEntry name: name value: value)]
lookup: name [⇑self◦name]
replace: name with: value [
	⇑self replace: (self newEntry name: name value: value)]

Entry Access 
contents [⇑self match: '*']
create: entry [⇑self insert: entry]
delete: entry [
	self Find: (entry ← self makeEntry: entry)⇒ [
		self Delete: entry.
		⇑entry]
	⇑self error: 'not deleted (not found)' entry: entry]
exists: entry ["doesn't initialize too much"
	⇑self Find: (self makeEntry: entry)]
find: entry [
	self Find: (entry ← self makeEntry: entry)⇒ [⇑self found: entry]
	⇑self error: 'not found' entry: entry]
found: entry ["found, fill it in from dictionary" ⇑self nextEntry: entry]
get: entry ["find or insert"
	self Find: (entry ← self makeEntry: entry)⇒ [⇑self found: entry]
	self Insert: entry.
	⇑entry]
insert: entry [
	self Find: (entry ← self makeEntry: entry)⇒ [
		⇑self error: 'not inserted (already found)' entry: entry]
	self Insert: entry.
	⇑entry]
list [self list: '*']
list: entries [self match: entries to: user]
match: entries | set [
	set ← Set new vector: 50.
	self match: entries to: set.
	⇑set contents]
match: entries to: strm | entry nentries [
	"return a Set of entries which match those in entries
	(can include exact values and patterns and ranges)"
	[(entries is: Vector) or⦂ (entries Is: Set)⇒ [] entries ← entries inVector].
	nentries ← Set new vector: entries length.
	for⦂ entry from: entries do⦂ [nentries next ← self makeEntry: entry].
	⇑self Match: nentries to: strm]
read: entry [⇑self find: entry]
rename: entry newName: name | nentry ["not tested"
	self Find: (nentry ← self makeEntry: name)⇒ [
		⇑self error: 'already exists' error: nentry]
	self Find: (entry ← self makeEntry: entry)⇒ [
		self Rename: entry from: nentry.
		⇑entry]
	⇑self error: 'not found' entry: entry]
replace: entry [
	self Find: (entry ← self makeEntry: entry)⇒ [
		self Replace: entry.
		⇑entry]
	⇑self error: 'not replaced (not found)' entry: entry]
retrieve: entry [⇑self find: entry "match:?"]
store: entry [⇑self write: entry]
write: entry ["replace or insert"
	[self Find: (entry ← self makeEntry: entry)⇒ [self Replace: entry]
	self Insert: entry].
	⇑entry]

Stream Access 
append: dict | entry [for⦂ entry from: dict do⦂ [self write: entry]]
asStream "leave position where it is"
next [
	"return next entry or false" 
	⇑self nextEntry: self newEntry]
position ["current position (name)" self subError]
position ← name [⇑self Position ← self makeEntry: name]
Position ← entry [
	"position to name, or position to insert place and return false if not found.
	subclass had better define position← or Position← (preferably)
	otherwise circularity results!!!"
	⇑self position ← entry name]
reset ["position to beginning" self subError]

Entry Creation 
entryClass ["a subclass of DictionaryEntry" self subError]
makeEntry: entry "entry or name" | cl [
	cl ← self entryClass.
	cl≡false or⦂ (entry Is: cl)⇒ [
		"entry should not be converted or is the correct type" ⇑entry]

	"convert entry from a name to an entry with that name"
	⇑self newEntry name: entry]
newEntry [⇑[(self entryClass new) dictionary: self; init]]
nextEntry: entry [
	"return next name and value in entry, or false.
	if insert or delete occurs after previous next, may be problem"
	⇑entry]

Entry Operations 
Delete: entry ["entry found (next), delete it" self subError]
entrySize: entry ["storage size of entry, constant or variable" self subError]
error: e entry: entry ["entry error: e" ⇑false]
Find: entry ["is entry in dictionary?" ⇑self Position ← entry]
Insert: entry ["entry not found, insert it (next)" self subError]
Match: entries to: strm | entry pat ents [
	"default (unordered) is to compare entire dictionary with entries"
	self reset.
	for⦂ entry from: self do⦂ [
		ents ← entries asStream.
		while⦂ (ents and⦂ (pat ← ents next)) do⦂ [
			pat match: entry⇒ [
				ents ← false.
				strm next ← entry
				]
		]]]
Rename: entry from: nentry [
	self Delete: entry; Insert: (entry name: nentry name)]
Replace: entry ["entry found (next), replace it's value" self subError]

File-Based dictionary 
close [
	self obsolete⇒ []
	"possible cleanup before a release"
	[self file⇒ [self file close]].
	self release]
file ["return my file" ⇑false]
obsolete ["is my information obsolete (should I regenerate it)?"
	self file⇒ [⇑self file obsolete]
	⇑false]
open
release "obsolete and deallocate storage, especially if connected to an external view,
	e.g. a File" [self file⇒ [self file release]]
reopen ["reinitialize, especially if a File is involved" self open]

SystemOrganization classify: ↪Dict under: 'Sets and Dictionaries'.

"DictionaryEntry" 
Class new title: 'DictionaryEntry'
	subclassof: Object
	fields: ''
	declare: '';
	asFollows 

a model for entries --what to retrieve with and store in dictionaries

Initialize 
dictionary: dict
init
name: name

Other 
dictionary ["what dictionary did I come from?" ⇑false]
match: entry [
	"does self (some kind of pattern) match entry?" self subError] 

Filing 
fileSize ["size in characters for filing" self subError]
readFrom: file ["inverse of storeOn:" self subError]
storeOn: file ["store self as fileSize characters on file" self subError]

SystemOrganization classify: ↪DictionaryEntry under: 'Sets and Dictionaries'.

"HashSet" 
Class new title: 'HashSet'
	subclassof: Object
	fields: 'objects'
	declare: '';
	asFollows 

HashSets are pure sets of objects with no associated values.  However, since they allow callers to determine the location of objects in the hash table, subclasses such as Dictionary and MessageDict can provide parallel tables to hold values.  Such subclasses must intercept growto: and reorder their own tables then.

Initialization 
copy "⇑ a copy of me"
	[⇑self class new copyfrom: self]
copyfrom: hset "take on state of hset"
	[objects ← hset objects copy]
init
	[self init: 4]
init: size
	[objects ← Vector new: (size max: 2)]

Access to parts 
asStream
	[⇑self contents asStream]
contents | obj strm
	[strm ← (Vector new: objects length) asStream.
	for⦂ obj from: objects do⦂
		[obj≡nil⇒[] strm next← obj]
	⇑strm contents]
size [⇑objects length]

Searching 
find: obj | i	"⇑index if found, else false"
	[i ← self findornil: obj.
	objects◦i=obj⇒[⇑i] ⇑false]
findorerror: name | i
	[i ← self findornil: name.
	objects◦i=name⇒ [⇑i]
	"allow the user to put a correct value into i"
	user notify: name asString+' cannot be found'. ⇑i]
has: obj
	[⇑objects◦(self findornil: obj)=obj]

Insertion and deletion 
delete: obj | i j l
	[obj is: Vector⇒[for⦂ i from: obj do⦂ [self delete: i]]
	i← self findorerror: obj.
	objects◦i← nil.
	l← objects length.
	until⦂ objects◦(i← [i=l⇒[1] i+1])≡nil do⦂
		[i=(j← self findornil: objects◦i)⇒[]
		self swap: i with: j]
	]
insert: obj | i
	[self findorinsert: obj. ⇑obj]
insertall: objs | x
	[for⦂ x from: objs do⦂ [self insert: x]]

Growing and shrinking 
packprobes | tot n l i obj t		"⇑(fullness, avg #probes)"
	[tot ← n ← 0. l ← objects length.
	for⦂ i to: l do⦂
		[(obj← objects◦i)≡nil⇒[]
		t ← obj hash \ l.
		tot ← tot + [i < t⇒ [l - t + i] i - t].
		n← n+1]
	n=0⇒[⇑(1,1)]
	⇑((n asFloat/l) , (tot asFloat/n))]
"Class md packprobes(0.4921875 2.53968255 )"
shrink | table oldtable
	[oldtable ← self.
	table ← oldtable growto: (2 max: oldtable size/2).
	until⦂ table size=oldtable size do⦂
		[(oldtable size-table size) print.  user show: ' '.
		oldtable ← table.
		table ← oldtable growto: (2 max: oldtable size/2)]
	⇑table]

Private 
findorinsert: obj | i		"insert if not found, "
	[i ← self findornil: obj.
	objects◦i=obj⇒[⇑i]  "found it"
	self sparse⇒[objects◦i ← obj. ⇑i]  "insert if room"
	self growto: objects length*2.	"grow"
	⇑self findorinsert: obj "and insert"]
findornil: obj | i loc	"⇑index if found or available slot"
	[loc ← obj hash\objects length.
	for⦂ i to: objects length do⦂
		[loc ← [loc=objects length⇒[1] loc+1].	
		objects◦loc ≡ nil⇒ [⇑loc]
		objects◦loc = obj⇒ [⇑loc]]
	⇑1 "table full - caller must check for hit"]
growto: t1 | t2 t3  "faster insert for growing"
	[t2 ← self class new init: t1.
	[t1 < objects length ⇒[
		for⦂ t3 from: self do⦂
			[t2 insert: t3]]
	for⦂ t3 from: self do⦂
		[t2 rawinsert: t3]].
	objects ← t2 objects]
objects [⇑objects]
objects← objects
rawinsert: t1 | t2 "assumes there is room for the new one"
	[t2 ← self findornil: t1.
	objects ◦ t2 ← t1.
	⇑t2]
rehash | i copy
	[copy ← HashSet new init: self size.	"create a copy"
	for⦂ i to: objects length do⦂
		[objects◦i≡nil⇒[]
		 copy insert: objects◦i]			"hash each entry into it"
	objects ← copy objects]
sparse | i n
	["⇑true if (1 max: 1/4 of table) is nil"
	n ← objects length.
	for⦂ i to: objects length do⦂
		[objects◦i≡nil⇒[(n←n-4)≤0⇒[⇑true]]]
	⇑false]
swap: i with: j
	[objects swap: i with: j]

SystemOrganization classify: ↪HashSet under: 'Sets and Dictionaries'.

"Dictionary" 
Class new title: 'Dictionary'
	subclassof: HashSet
	fields: 'values'
	declare: '';
	asFollows 

Dictionaries are sets with associated values.  They are very handy but not terribly efficient.  Most of their work is done by HashSet.

Initialization 
copyfrom: dict
	[self objects ← dict objects copy.
	values ← dict values copy]
init: size
	[values ← Vector new: size. super init: size]

Searching 
◦ name
	[⇑values◦(self findorerror: name)]
◦ name ← val
	[⇑values◦(self findorerror: name) ← val]
lookup: name | x
	[x ← self find: name⇒ [⇑values◦x] ⇑false]

Inserting and Deleting 
clean | name	"release unreferenced entries"
	[for⦂ name from: self do⦂		"slick, huh"
		[(self◦name) refct = 1 ⇒ [self delete: name]]]
delete: name
	[name is: Vector⇒[super delete: name]
	values◦(self findorerror: name)← nil.
	super delete: name]
insert: name with: value
	[self insert: name.
	values◦(self findorerror: name) ← value]
insertall: names		"default value is nil"
	[self insertall: names with: (Vector new: names length)]
insertall: names with: vals | i		"insert many entries"
	[for⦂ i to: names length do⦂
		[self insert: names◦i with: vals◦i]]
tally: name | x
	[x ← self find: name⇒ [⇑values◦x← values◦x+1]
	self insert: name with: 1. ⇑1]
with: names values: vals | i
	[for⦂ i to: names length do⦂
		[self insert: names◦i with: vals◦i]]

Private 
growto: size | name copy
	[copy ← self class new init: size.	"create a copy of the new size"
	for⦂ name from: self do⦂
		[copy insert: name with: self◦name]	"hash each entry into it"
	self copyfrom: copy]
rehash | i copy
	[copy ← Dictionary new init: self size.	"create a copy"
	for⦂ i to: objects length do⦂
		[objects◦i≡nil⇒[]
		 copy insert: objects◦i with: values◦i]	"hash each entry into it"
	self copyfrom: copy]
swap: i with: j
	[values swap: i with: j.
	super swap: i with: j]
values [⇑values]

Inversion 
asInvertedVector | s i v  "in form ((value, object), ...)"
	[s ← (Vector new: objects length) asStream.
	for⦂ i to: objects length do⦂
		[objects◦i≡nil⇒ []
		v ← Vector new: 2. v◦1←values◦i. v◦2←objects◦i.
		s next ← v].
	⇑s contents]
invert
	[⇑self invertto: (Dictionary new init: objects length)]
invert: obj | i
	[for⦂ i to: values length do⦂
		[values◦i=obj⇒ [⇑objects◦i]]
	⇑false]
invertto: dict | i
	[for⦂ i to: objects length do⦂
		[objects◦i≡nil⇒ []
		dict insert: values◦i with: objects◦i].
	⇑dict]

SystemOrganization classify: ↪Dictionary under: 'Sets and Dictionaries'.

"MessageDict" 
Class new title: 'MessageDict'
	subclassof: HashSet
	fields: 'methods "<Vector of Strings> which are the compiled methods for each message"
		literals "<Vector of Vectors> which hold pointers to literals used in the methods"
		code "<Vector of Strings> which are the source text for each message"
		backpointers "<Vector of Vectors> which are the tables of text location vs pc for each message"'
	declare: '';
	asFollows 

MessageDicts hold the source code and compiled methods for each message to a class.  The source code is a packed paragraph (see Paragraph packIntoString).  The methods contain pointers to literals, and must be specially freed.  If a method is being executed during its redefinition, its release must be delayed (its literals gets held in CodeKeeper).  Finally, MessageDicts must be copied to be grown, so that current use is not disturbed.

Initialization 
copyfrom: dict
	[self objects ← dict objects copy.
	methods ← dict methods copy.
	code ← dict code copy]
init: size
	[methods ← Vector new: size.
	code ← Vector new: size.
	super init: size]

Inserting and Deleting 
close | i		"recycle all code and literals pointed to"
	[for⦂ i to: methods length do⦂
		[methods◦i≡nil⇒[]
		self freeMethod: methods◦i]
	self init]
delete: name | i
	[i ← self findorerror: name.
	self freeMethod: methods◦i.
	methods◦i← code◦i← nil.
	super delete: name]
insert: name method: m literals: l
		code: c backpointers: b | i copy
	[i ← self find: name⇒		"if name is already there"
		[self freeMethod: methods◦i.
		self holdLiterals: l.
		methods◦i ← m. code◦i ← c]		"then insert it, and return self"
	copy ← [self sparse⇒[self] 
		self growto: methods length*2].		"Otherwise, copy if necessary"
	copy objects◦(copy findornil: name) ← name.	"and insert"
	⇑copy insert: name method: m literals: l
			code: c backpointers: b]
purge: sel ["demand purging invalidates checkpointing"]

Access to parts 
code
	[⇑code]
code: name
	[⇑code◦(self findorerror: name)]
code: name ← str
	[⇑code◦(self findorerror: name) ← str]
invert: method | i
	[for⦂ i to: methods length do⦂
		[methods◦i≡method⇒ [⇑objects◦i]].
	⇑false]
literals: name
	[⇑self literalsIn: methods◦(self findorerror: name)]
method: name
	[⇑methods◦(self findorerror: name)]
methodorfalse: name | i
	[i ← self find: name⇒[⇑methods◦i] ⇑false]
methods
	[⇑methods]

Code aspect of Strings 
freeLiterals: v | m i t		"lower refct of all literals"
	[v length=0⇒[]
	m ← v nail.
	for⦂ i to: v length do⦂
		[t ← mem◦(m+i-1). v◦i ← nil. mem◦(m+i-1) ← t]
	v unNail]
freeMethod: m | v c i t		"method pointed to by some vector (dict or keeper)
		and (upon entry) by m.  If any other owners, refct will be >2.
		*Expects Interpreter to nil args on callers stack*"
	[m refct>2⇒[MethodKeeper next← m]		"keep it"
	v← self literalsIn: m.		"free its literals"
	v length=0⇒[]
	c ← v nail.		"fasten seat belts"
	for⦂ i to: v length do⦂		"lower refct of each literal"
		[t ← mem◦(c+i-1). v◦i ← nil. mem◦(c+i-1) ← t]
	v unNail]
freeMethods | v i		"Free kept methods no longer used"
	[v← MethodKeeper contents.
	MethodKeeper← (Vector new: 10) asStream.
	for⦂ i to: v length do⦂
		[self freeMethod: v◦i]
	]
holdLiterals: v | m i t		"raise refct of all literals"
	[v≡nil⇒[] v length=0⇒[]
	m ← v nail.
	for⦂ i to: v length do⦂
		[t ← v◦i. mem◦(m+i-1) ← ¬1. v◦i ← t]
	v unNail]
holdMethods: v | i "a random insertion just to make it legal form"
	[for⦂ i to: v length do⦂
		[self insert: i method: v◦i literals: nil code: nil backpointers: nil]]
literalsIn: method | i v		"return the literal vector imbedded in this method"
	[method≡nil⇒[⇑Vector new: 0]
	method length<8⇒[⇑Vector new: 0]
	method◦2=41⇒[⇑Vector new: 0]
	v ← Vector new: method◦6-6/2.
	for⦂ i to: v length do⦂
		[v◦i ← (method word: 3+i) asObject]
	⇑v]

Private 
growto: size | name copy i
	[copy ← MessageDict new init: size.	"create a copy of the new size"
	for⦂ name from: self do⦂
		[i ← self findorerror: name.		"hash each entry into it"
		copy ← copy insert: name method: methods◦i
			literals: [literals≡nil⇒[nil] literals◦i]  code: code◦i backpointers: nil]
	⇑copy]
swap: i with: j
	[methods swap: i with: j.
	code swap: i with: j.
	super swap: i with: j]

SystemOrganization classify: ↪MessageDict under: 'Sets and Dictionaries'.

"SymbolTable" 
Class new title: 'SymbolTable'
	subclassof: Dictionary
	fields: ''
	declare: '';
	asFollows 

I associate each of my objects with an object reference

Access to parts 
ref: name
	[⇑super◦name]
ref: name ← val
	[⇑super◦name ← val]

Searching 
◦ name
	[⇑(super◦name) value]
allCallsOn: selector from: classNames | className s w cl sel
	[[selector is: Vector⇒ [] selector ← selector inVector].
	s ← Stream default.
	user displayoffwhile⦂
		[for⦂ className from: classNames do⦂
			[cl ← self◦className.
			for⦂ sel from: selector do⦂
				[w ← cl whosends: sel. w length=0⇒ []
				s append: className; append: '⇒'; append: w asString; cr]]].
	⇑s contents]
allRefs  "what methods reference my variables (I am probably 'Undeclared')"
	[⇑self allRefsTo: self contents from: user classNames]
allRefsTo: symbol from: classNames | s
	[[symbol is: Vector⇒ [] symbol ← symbol inVector].
	⇑Smalltalk allCallsOn: (symbol transform⦂ s to⦂ (self ref: s)) from: classNames]
invert: obj | i
	[for⦂ i to: values length do⦂
		[nil≡(values◦i)⇒[]
		obj ≡ (values◦i) value ⇒[⇑objects◦i]]
	⇑false]
invertRef: obj | i
	[for⦂ i to: values length do⦂
		[obj≡(values◦i)⇒[⇑objects◦i]]
	⇑false]
lookup: name | r
	[r←super lookup: name⇒[⇑r value] ⇑false]
lookupRef: name
	[⇑super lookup: name]

Insertion 
◦ name ← x
	[⇑(super◦name) value ← x]
declare: name	"Take ref(s) and value(s) from Undeclared, if name(s) there"
	[self declare: name from: Undeclared]
declare: name as: x | a s
	[name is: Vector⇒
		[s ← x asStream. for⦂ a from: name do⦂ [self declare: a as: s next]]
	self declare: name.
	self◦name ← x]
declare: name from: symTab | a "take name(s), ref(s) and value(s) from symTab"
	[name is: Vector⇒ [for⦂ a from: name do⦂ [self declare: a from: symTab]]
	self has: name⇒ []
	symTab has: name⇒
		[super insert: name with: (symTab ref: name).
		symTab delete: name]
	self insert: name with: nil]
define: name as: x		"synonym"
	[⇑self declare: name as: x]
insert: name with: x
	[	[self has: name⇒[]
		super insert: name with: ObjectReference new].
	self◦name ← x]
insert: name withref: ref
	[super insert: name with: ref]

Growing and shrinking 
growto: size | name copy
	[copy ← self class new init: size.	"create a copy of the new size"
	for⦂ name from: self do⦂
		[copy insert: name withref: (self ref: name)]	"hash each entry into it"
	self copyfrom: copy]
rehash | i copy
	[copy ← SymbolTable new init: self size.	"create a copy"
	for⦂ i to: objects length do⦂
		[objects◦i≡nil⇒[]
		 copy insert: objects◦i withref: values◦i]	"hash each entry into it"
	self copyfrom: copy]

SystemOrganization classify: ↪SymbolTable under: 'Sets and Dictionaries'.

"SystemOrganizer" 
Class new title: 'SystemOrganizer'
	subclassof: ClassOrganizer
	fields: ''
	declare: '';
	asFollows 

Provides an organization for the classes in the system just as ClassOrganizer organizes the messages within a class.  (In fact, the only difference is the filout/printing messages.)

Filout and printing 
filoutCategory: cat | all a [user displayoffwhile⦂ [
	all ← self superclassOrder: cat.
	(dp0 file: (cat+'.st.') asFileName) filoutclass: all.
	for⦂ a from: all do⦂ [(Smalltalk◦a) noChanges]]]
printAll | cat
	[for⦂ cat from: commentVector do⦂
		[self printCategory: cat]]
printCategory: cat [user displayoffwhile⦂ [
	(dp0 file: (cat+'.press') asFileName) printoutclass: (self superclassOrder: cat)]]
superclassOrder: cat | all lis a i c sup  "Arrange classes in superclass order so they can be filed in"
	[lis← (self category: cat) copy. all ← (Vector new: lis length) asStream.
	while⦂ lis length>0 do⦂
		[i← 1.
		until⦂
			[a← lis◦i. sup← c← Smalltalk◦a.
			until⦂ "Make sure it doesn't have an as yet unprinted superclass"
				[sup← sup superclass.
				sup≡nil⇒[true]
				lis has: sup title unique]
			do⦂ [].
			sup≡nil]
		do⦂ [i← i+1].
		all next ← a.
		lis← lis delete: a].
	⇑all contents]

SystemOrganization classify: ↪SystemOrganizer under: 'Sets and Dictionaries'. 
