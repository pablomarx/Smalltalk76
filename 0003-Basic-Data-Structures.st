'From Smalltalk 5.5k XM November 24 on 22 November 1980 at 2:57:08 am.'

"Array" 
Class new title: 'Array'
	subclassof: Object
	fields: ''
	declare: '';
	asFollows 

Array is an abstract class in the sense that it has no state, and instantiation is consequently not meaningful.  However it defines the default message set inherited by its subclasses, notably String, Vector, and UniqueString.  Notice that subscripting is not done here, except to handle the exceptional cases such as subscripting by other types as in a◦(1 to: 3).

Reading and Writing 
◦ x
	[⇑x subscripts: self]
◦ x ← val
	[⇑x subscripts: self ← val]
< v "for sorting vectors by first element"
	[⇑(self◦1)<(v◦1)]
= arg | x
	[arg isArray⇒
		[self length ≠ arg length⇒ [⇑false]
		for⦂ x to: self length do⦂ 
			[(self◦x) = (arg◦x)⇒ [] ⇑false]
		⇑true]
	⇑false]
> v "for sorting vectors by first element"
	[⇑(self◦1)>(v◦1)]
all ← val | i
	[for⦂ i to: self length do⦂
		[self◦i ← val]]
last
	[⇑self◦self length]
last ← val
	[⇑self◦self length ← val]
length  [user notify: 'message not understood.']

Copying and Altering 
+ arg [⇑self concat: arg]
concat: arg | x s [
	x ← self species new: self length + arg length.
	self copyto: (s ← x asStream).
	arg copyto: s.
	⇑x]
copy
	[⇑self copy: 1 to: self length]
copy: a to: b
	[⇑self copy: a to: b to: (self species new: b-a+1)]
copy: a to: b to: t | i s me
	[s ← t asStream.
	me ← Stream new of: self from: a to: b.
	for⦂ i from: a to: b do⦂		"general code wont stop at false"
		[s next ← me next]
	⇑t]
copyto: t
	[⇑self copy: 1 to: self length to: t]
delete: obj | s each
	[s ← (self species new: self length) asStream.
	for⦂ each from: self do⦂
		[obj=each⇒[] s next← each]
	⇑ s contents]
grow [⇑self growto: (4 max: self length*2)]
growby: n [⇑self growto: self length + n]
growto: n [⇑self "copyto:" copy: 1 to: self length to: (self species new: n)]
insertNonDescending: x		"self is assumed to be sorted"
	[⇑self insertSorted: x]
insertSorted: x | a c i		"self is assumed to be sorted"
	[i ← self findSorted: x.
	c ← (a ← self species new: self length+1) asStream.
	self◦(1 to: i) copyto: c. c next ← x. self◦(i+1 to: self length) copyto: c.
	⇑a]
notNil | t i  "copy self (which contains no falses) removing all nils"
	[t ← (self species new: (self length-(self count: nil))) asStream.
	for⦂ i from: self do⦂ [i≡nil ⇒[] t next← i].
	⇑t asArray]

replace: a to: b by: s | x xs
	[x ← self species new: self length+s length -(1+b-a).
	xs ← x asStream.
	self copy: 1 to: a-1 to: xs.
	s copy: 1 to: s length to: xs.
	self copy: b+1 to: self length to: xs.
	⇑x]
without: index | s me i  "if index in range, return self without ◦index"
	[index cansubscript: self⇒
		[s ← (self species new: self length-1) asStream.
		me ← self asStream.
		for⦂ i to: self length do⦂ [i=index⇒ [me next] s next ← me next].
		⇑s asArray]]

Searching 
all⦂ variable suchThat⦂ expr | s i x  "a copy of some of me"
	[s ← (self species new: self length) asStream.
	for⦂ i to: self length do⦂
		[x ← self◦i. variable value ← x.
		expr eval⇒ [s next ← x]].
	⇑s contents]
count: x | i n
	[n←0.
	for⦂ i to: self length do⦂
		[x=(self◦i)⇒ [n←n+1]].
	⇑n]
find⦂ x suchThat⦂ predicate | i
	[for⦂ i to: self length do⦂
		[x value ← self◦i. predicate eval⇒ [⇑i]].
	⇑0]
find: x | i
	[for⦂ i to: self length do⦂
		[self◦i=x⇒ [⇑i]].
	⇑0]
findnon: x | i
	[for⦂ i to: self length do⦂
		[self◦i≠x⇒ [⇑i]].
	⇑0]
findSorted: x | lo mid hi		" returns index of largest element ≤ x "
	[hi ← self length+1.  lo ← 1.
	while⦂ lo < hi do⦂		"binary search; self must be sorted"
		[self◦(mid←lo+hi/2) > x⇒[hi ← mid]  lo ← mid+1].
	⇑hi-1]		" 0≤result≤length "
first⦂ x suchThat⦂ predicate | i
	[for⦂ i to: self length do⦂
		[x value ← self◦i. predicate eval⇒ [⇑self◦i]].
	⇑false]
has: x [⇑(self find: x)≠0]

Permutation 
permutationToSort
	["Return a Vector, permutation, such that self◦permutation is sorted nondescending.  Do not alter self."
	⇑((self◦((1 to: self length) copy)) sort: 1 to: self length) map.]
promote: t | n
	[n ← self find: t. n=0⇒ []
	self◦(n to: 2 by: ¬1) ← self◦(n-1 to: 1 by: ¬1).
	self◦1 ← t]
reverse	
	[⇑Substring new data: self map: (self length to: 1 by: ¬1)]
sort
	["Permute my elements so they are sorted nondescending.  Note: if I am a substring, only my map will be permuted.  In certain situations, this may not be what you expect."
	self sort: 1 to: self length.]
sort: i to: j | di dij dj tt ij k l n
	["Sort elements i through j of self to be nondescending."
	
	"The prefix d means the data at."
	(n←j+1-i)≤1⇒ ["Nothing to sort."]
	"Sort di,dj."
	di ← self◦i. dj ← self◦j.
	[di>dj⇒ [self swap: i with: j. tt←di. di←dj. dj←tt]].
	n=2⇒ ["They are the only two elements."]
	ij ← (i+j) lshift: ¬1. "ij is the midpoint of i and j."
	"Sort di,dij,dj.  Make dij be their median."
	dij ← self◦ij.
	[di>dij⇒ [self swap: i with: ij. dij←di] dj<dij⇒ [self swap: j with: ij. dij←dj]].
	n=3⇒ ["They are the only three elements."]
	"Find k>i and l<j such that dk,dij,dl are in reverse order.  Swap k and l.  Repeat this procedure until j and k pass each other."
	k ← i. l ← j.
	while⦂
		[
		while⦂ self◦(l←l-1) > dij do⦂ [].
		while⦂ self◦(k←k+1) < dij do⦂ [].
		k≤l
		]
	do⦂
		[self swap: k with: l].
	"Now l<k (either 1 or 2 less), and di through dl are all less than dk through dj.  Sort those two segments."
	self sort: i to: l.
	self sort: k to: j.]
swap: i with: j | t
	[t ← self◦i. self◦i ← self◦j. self◦j ← t]

Conversion 
asSet [⇑Set new of: self to: self length]
asStream
	[⇑Stream new of: self]
frequencies | d x  "return a sorted vector ((freq item) (freq item) ...)"
	[d ← Dictionary new init: 64.
	for⦂ x from: self do⦂
		[d tally: x].
	⇑d asInvertedVector sort]
sum [⇑self sumTo: 0]
sumTo: subTotal | x		"add all my elements to this subTotal (usually 0 or 0.0)"
	[for⦂ x from: self do⦂
		[subTotal← subTotal+x].
	⇑subTotal]
transform⦂ each to⦂ expr | s i  "a copy of me with each element transformed"
	[s ← (self species new: self length) asStream.
	for⦂ i to: self length do⦂
		[each value ← self◦i. s next ← expr eval].
	⇑s asArray]
viewer [⇑SetReader new of: self]

Mapping 
cansubscript: a | i
	[for⦂ i from: self do⦂ [i cansubscript: a⇒ [] ⇑false]]
subscripts: x			"subarrays"
	[⇑Substring new data: x map: self]
subscripts: x ← val		"subrange replacement"
	[self length≠val length⇒
		[user notify: 'lengths not commensurate']
	val copyto: (Substring new data: x map: self).
	⇑val]

Compatibility 
isArray
isIntervalBy1
	[⇑false]
species
	[⇑Vector]

Comparing 
hash "make sure = arrays hash =ly"
	[self length=0⇒[⇑17171]
	⇑(self◦1) hash + (self◦self length) hash]

SystemOrganization classify: ↪Array under: 'Basic Data Structures'.

"FieldReference" 
Class new title: 'FieldReference'
	subclassof: Object
	fields: 'object offset'
	declare: '';
	asFollows 

I reference a field of an instance

Initialization 
object: object offset: offset

Indirection 
eval 
	[⇑object instfield: offset]
value [⇑object instfield: offset]
value ← value
	[object instfield: offset ← value. ⇑value]

SystemOrganization classify: ↪FieldReference under: 'Basic Data Structures'.

"Interval" 
Class new title: 'Interval'
	subclassof: Array
	fields: 'start stop step length'
	declare: '';
	asFollows 

I am an arithmetic progression from start in steps of step, not exceeding stop

Initialization 
from: start to: stop by: step
	[length ← 1+(stop-start/step).
	step<0⇒[start<stop⇒[length← 0]]
	stop<start⇒[length← 0]
	]

Reading and Writing 
◦ x
	[x is: Integer⇒[x<1⇒ [⇑nil]
		x>length⇒ [⇑nil]
		⇑start+(step*(x-1))]
	⇑super◦x]
◦ x ← val
	[user notify: 'Intervals are not for writing into']
length [⇑length]
start [⇑start]
stop [⇑stop]

Compatibility 
= int [⇑start = int start and⦂ (stop = int stop and⦂ length = int length)]
cansubscript: a
	[⇑length≤0 or⦂ ((start cansubscript: a) and⦂ (length-1*step+start cansubscript: a))]
hash [⇑(((start lshift: 2) lxor: stop) lshift: 1) lxor: length]
isIntervalBy1
	[⇑step=1]

Random Numbers 
random		"See Lehmers linear congruential method, Knuth Vol. 1:
	modulus m=2^16
	a=27181 odd, and 5 = a mod 8
	c=13849 odd, and c/m around 0.21132"
	[step← (13849 + (27181*step)) asSmall.
	⇑(start + ((length asFloat*(32768.0+step))/65536.0)) asSmall]
randomInit [self randomInit: mem◦0430]
randomInit: x		"Call with const to get repeatable sequence"
	[step← x.		"step holds the current state"
	start is: Float⇒[length←stop-start]		"for Float intervals"]

SystemOrganization classify: ↪Interval under: 'Basic Data Structures'.

"ObjectReference" 
Class new title: 'ObjectReference'
	subclassof: Object
	fields: 'object'
	declare: '';
	asFollows 

I am an indirect reference

Initialization 
object: object

Indirection 
eval 
	[⇑object]
value [⇑object]
value ← object
	[⇑object]

Conversion 
printon: strm
	[strm append: '->'; print: object]

SystemOrganization classify: ↪ObjectReference under: 'Basic Data Structures'.

"RunVector" 
Class new title: 'RunVector'
	subclassof: Array
	fields: ' min max starts values offset'
	declare: '';
	asFollows 

RunVectors compactly store data which tends to be constant over much
of its domain.  They may have any range of subscript, but must be stored
into consecutively.

Reading and writing 
◦i | index
	[index← starts findSorted: i.
	offset← i-(starts◦index).		"distance into run"
	⇑values◦index]
◦i← val
	[offset← 0.
	min≡nil⇒[min← max← i. starts← i inVector. values← val inVector]
	i-1≠max⇒[user notify: 'RunVectors must be loaded sequentially'. ⇑val]
	max← i.
	val=values last⇒[offset← i-starts last. ⇑val]
	starts← starts , i.
	values← values , val. ⇑val]

length [max≡nil⇒[⇑0]
	⇑max-min+1]
max [⇑max]
min [⇑min]

SystemOrganization classify: ↪RunVector under: 'Basic Data Structures'.

"Stream" 
Class new title: 'Stream'
	subclassof: Object
	fields: 'array position limit'
	declare: '';
	asFollows 

Streams provide fast sequential access to arrays (implemented in microcode for Strings and Vectors).  A subclass can handle end conditions if desired (disk files do this).

Initialization 
close
	[limit← position. position← 0]
default
	[self of: (String new: 16)]
of: array
	[position ← 0. limit ← array length]
of: array from: pos to: lim | len
	[limit ← [lim > (len ← array length)⇒ [len] lim].
	position ← [pos≤1⇒ [0] pos-1]]
release [array ← nil]

Sequential reading and writing 
∢ x | y
	[y← self next⇒		"peek for matching element"
		[x=y⇒ [⇑y]		"gobble it if found"
		position ← position-1. ⇑false]
	⇑false]
append: x | i	"Array arg"
	[for⦂ i from: x do⦂
		[self next ← i].
	⇑x]
dequeue		"use it as a FIFO"
	[⇑self dequeue: 1]
dequeue: n | t
	[position<n⇒ [⇑false]
	t ← (array◦(1 to: n)) copy.
	array◦(1 to: position-n) ← array◦(n+1 to: position).
	position ← position-n. ⇑t]
integerScan | sign base maxdigit c val [
	"get the next Integer or LargeInteger (Float?) from a Stream.
	copied from String asInteger"

	sign← [self∢025⇒[¬1] 1].
	base← [self∢060⇒[8] 10].
	maxdigit← 060+base.
	val← 0.

	while⦂ ((c ← self next) and⦂ (c ≥ 060 and⦂ c < maxdigit)) do⦂ [
		val← val*base+(c-060)].
	[c⇒ [self skip: ¬1]].

	"Some special maneuvering to keep 01ddddd and ¬32768 (and nothing else)
	from overflowing."
	base=8 and⦂ (val>077777 and⦂ (sign=1 and⦂ val<65536))⇒[⇑val asSmall]
	⇑(val*sign) asInteger]
into: x [
	"generate an error if the Stream is exhausted before x is filled"
	⇑self into: x endError: true]
into: x endError: err | i t len ["Array result"
	i ← 0.
	len ← x length.
	"read until count or stream is exhausted"
	while⦂ (i < len and⦂ (t ← self next)) do⦂ [x◦(i←i+1) ←t].

	err⇒ [
		t⇒ [⇑x]
		user notify: 'only read first ' + i asString]

	"return number that were read"
	⇑i]
next	"simple result"
	[self myend⇒ [⇑self pastend]
	⇑array◦(position ← position+1)] primitive: 17
next: n [⇑self into: (array species new: n) endError: true]
next: n from: strm [for⦂ n to: n do⦂ [self next ← strm next]]
next: n ← v [for⦂ n to: n do⦂ [self next ← v]]
nextNumber: n | i s t [
	"return next n characters s as a positive Integer or LargeInteger"
	s ← false.
	"scan for first non-zero byte, then collect rest appropriately"
	for⦂ i to: n do⦂ [
		t ← self next.
		s⇒ ["more LargeInteger: reverse order of significance" s◦(n+1-i) ← t]
		i=n⇒ [⇑t]
		t=0⇒ []
		i ≤ (n-2) or⦂ "i=n-1" (t land: 0200) ≠ 0⇒ [
			"LargeInteger of 2 or more bytes"
			s ← Natural new: n+1-i.
			s last ← t]
		"positive Integer"
		⇑(t lshift: 8) + self next].
	⇑LargeInteger new bytes: s neg: false]
nextNumber: n ← v | vlen [
	"write a positive Integer or LargeInteger as n characters"
	v ← v bytes.
	vlen ← v length.

	[n < vlen⇒ [user notify: 'number too big'];
		> vlen⇒ [
		"pad beginning with 0's"
		self next: n - vlen ← 0]].

	vlen = 1⇒ [self next ← v]
	vlen = 2 and⦂ (v is: Integer)⇒ [self nextword ← v]

	"LargeInteger (assume pos, no negative convention)"
	self append: v reverse]
nextPoint | x [
	x ← self nextword.
	⇑Point new x: x y: self nextword]
nextPoint←p [
	self nextword ← p x;
		nextword ← p y]
nextString | len [
	⇑self into: (String new: [
		(len ← self next)
			<192⇒[len]	"up to 191 chars (BCPL compat)"
		len-192*256 + self next]) endError: true]		"up to 16383 chars"
nextString← s | len [
	[(len ← s length) < 192⇒[self next← len]
	self next← len/256+192; next← len\256].
	self append: s.
	⇑s]
nextword | hi lo
	[hi ← self next⇒
		[lo ← self next⇒
			[⇑(hi lshift: 8)+lo]
		⇑false]
	⇑false]
nextword← val
	[self next← val lshift: ¬8.
	self next← val land: 0377. ⇑val]
next ← x		"simple arg"
	[self myend⇒ [⇑self pastend ← x]
	⇑array◦(position ← position+1) ← x] primitive: 18
padNext ["make position even (on word boundary), returning padding character if any"
	position even⇒ [⇑false]
	⇑self next]
padNext← c [
	position even⇒ [⇑false]
	⇑self next← c]
peek | x
	[x← self next⇒ [position ← position-1.  ⇑x]		"peek at next element"
	⇑false]
pop		"use it as a LIFO"
	[position<1⇒ [⇑false]
	position ← position-1. ⇑array◦(position+1)]
pop: n | t
	[position<n⇒ [⇑false]
	t ← self last: n.
	position ← position-n. ⇑t]
upto: x | y s
	[s ← (String new: 250) asStream.
	for⦂ y from: self do⦂
		[y=x⇒[⇑s contents]
		s next ← y].
	⇑s contents]

Test and alter position 
empty		"for"
	[⇑position=0]
end
	[⇑position≥limit]
limit
	[⇑limit]
loc	"synonym for compiler"
	[⇑position]
myend
	[⇑position≥limit]
pastend
	[⇑false]
pastend ← x
	[array ← array grow. limit ← array length.
	⇑self next ← x]
position
	[⇑position]
position← position
reset
	[position ← 0]
settoend [position← limit]
skip: x
	[position ← position+x]
skipTo: x | y [
	for⦂ y from: self do⦂ [y=x⇒[⇑true]].
	⇑false]
skipwords: w [self skip: 2*w]
wordposition [⇑self position/2]
wordposition← w [self position← w*2]

Static reading and writing 
◦ x
	[⇑array◦x]
◦ x ← val
	[⇑array◦x ← val]
contents [⇑array copy: 1 to: position]
first
	[position ≠ 0 ⇒ [⇑array◦1] ⇑nil]
insert: x | i  "treat as LIFO queue, insert in front"
	["grow array if necessary"
	 [position=limit⇒
		[array←array grow.
		limit←array length]].
	for⦂ i to: position do⦂
		[array◦(position-i+2) ← array◦(position-i+1)].
	array◦1 ← x.
	position←position+1]
last
	[position≠ 0 ⇒ [⇑array◦position] ⇑nil]
last: n
	[⇑(array◦(position-n+1 to: position)) copy]
rest [⇑array copy: position+1 to: limit]

Character printing 
cr
	[self next ← 015]
crtab: n | i
	[self next←13.
	for⦂ i to: n do⦂ [self next←9]]
print: obj
	[obj printon: self]
semicrtab
	[self append: ';
	']
space
	[self next ← 040]
tab
	[self next ← 011]

Coercions 
asArray
	[⇑array]
asReadStream [
	"an alternative to Set/SetReader.
	create another Stream which reads the contents of this one"
	⇑Stream new of: array from: 1 to: position]
asStream
asVector "Convert a string to a vector of tokens"
	[⇑(Reader new of: self) read]
viewer [⇑SetReader new of: array from: 1 to: position]

Compiler object code 
emitLong: jmpOrBfp by: dist
	[[dist<0⇒ [dist←dist+1024]; >1023⇒ [dist←¬1] jmpOrBfp←jmpOrBfp+4].
	dist<0⇒ [user notify: 'A block compiles more than 1K bytes of code']
	self next ← dist/256 + jmpOrBfp. self next ← dist\256]

SystemOrganization classify: ↪Stream under: 'Basic Data Structures'.

"PQueue" 
Class new title: 'PQueue'
	subclassof: Stream
	fields: 'readposition'
	declare: '';
	asFollows 

A PQueue is a First In First Out list of objects implemented as an array and a read pointer and write pointer. PQueue is a subclass of Stream and uses Streamⓢstandard method for inserting a new item (next←, i.e. Streamⓢposition is the write pointer). A PQueue also has a read pointer which it uses for accessing objects with the messages next or dequeue (which are identical). All messages to a PQueue that change its state are declared as critical sections to avoid race conditions

FIFO access 
dequeue: num | n
	[Top critical⦂
		[position-readposition < num ⇒ [n ← false]
		 n ← (array◦(readposition+1 to: readposition + num)) copy.
		 readposition ← readposition + num].
	 ⇑n]
length | l
	[Top critical⦂ [l ← position-readposition]. ⇑l]
myend [⇑true]
next | n
	[Top critical⦂
		[readposition≥position⇒ [readposition←position←0. n ← false]
		 n ← array◦(readposition ← readposition+1)].
	 ⇑n] primitive: 98
pastend ← x	 | n i	"simple arg"
	[Top critical⦂
		[position≥limit⇒
			[readposition=0⇒[super pastend ← x]
			 n ← position-readposition.
			 for⦂ i to: n do⦂ [array◦i ← array◦(readposition+i)].
			 readposition ← 0. position ← n.
			 self next ← x]
		 array◦(position ← position+1) ← x].
	 ⇑x]
peek | n
	[Top critical⦂
		[readposition≥position⇒ [readposition←position←0. n ← false]
		 n ← array◦(readposition + 1)].
	 ⇑n]
skip: x
	[Top critical⦂ [readposition ← readposition+x]]

LIFO access 
push: x				"treat as LIFO queue"
	[Top critical⦂
		[readposition > 0 ⇒
			[array◦readposition ← x.
			 readposition ← readposition - 1]		"readpositon > 0, just jam it in"
		 self insert: x]]											"otherwise insert on front"

Stream protocol 
contents | n
	[Top critical⦂ [n ← (array◦(readposition+1 to: position)) copy]. ⇑n]
empty | l
	[Top critical⦂ [l ← readposition≥position]. ⇑l] primitive: 99
end | n
	[Top critical⦂ [n ← readposition≥position]. ⇑n]
of: array
	[Top critical⦂ [position ← 0. readposition ← 0. limit ← array length]]
of: array from: position to: limit
	[user notify: 'of:from:to: is not appropriate for PQueues']
reset
	[Top critical⦂ [readposition ← position ← 0]]

SystemOrganization classify: ↪PQueue under: 'Basic Data Structures'.

"Queue" 
Class new title: 'Queue'
	subclassof: Stream
	fields: 'readposition'
	declare: '';
	asFollows 

A Queue is a First In First Out list of objects implemented as an array and a read pointer and write pointer. Queue is a subclass of Stream and uses Streamⓢstandard method for inserting a new item (next←, i.e. Streamⓢposition is the write pointer). A Queue also has a read pointer which it uses for accessing objects with the messages next or dequeue (which are identical)

FIFO access 
deQ1 | n	"A noninterruptable dequeue"
	[Top critical⦂ [n ← self dequeue].
	 ⇑n]
dequeue
	[readposition≥position⇒ [readposition←position←0. ⇑false]
	 ⇑array◦(readposition ← readposition+1)]
dequeue: num | n
	[position-readposition < num ⇒ [⇑false]
	 n ← (array◦(readposition+1 to: readposition + num)) copy.
	 readposition ← readposition + num.
	 ⇑n]
enQ1: n	"A noninterruptable enqueue"
	[Top critical⦂ [super next← n].
	 ⇑n]
length
	[⇑position-readposition]
next
	[readposition≥position⇒ [readposition←position←0. ⇑false]
	 ⇑array◦(readposition ← readposition+1)]
peek
	[readposition≥position⇒ [readposition←position←0. ⇑false]
	 ⇑array◦(readposition + 1)]
skip: x
	[readposition ← readposition+x]

LIFO access 
push: x				"treat as LIFO queue"
	[readposition > 0 ⇒
	[array◦readposition ← x.  readposition ← readposition - 1]		"readpositon > 0, just jam it in"
	self insert: x]																"otherwise insert on front"

Stream protocol 
contents
	[⇑(array◦(readposition+1 to: position)) copy]
empty
	[⇑readposition≥position]
end
	[⇑readposition≥position]
of: array
	[position ← 0. readposition ← 0. limit ← array length]
of: array from: position to: limit
	[user notify: 'of:from:to: is not appropriate for Queues']
pastend ← x | n
	[readposition=0⇒[⇑super pastend ← x]
	 n ← position-readposition.
	 array◦(1 to: n) ← array◦(readposition+1 to: position).
	 readposition ← 0.
	 position ← n.
	 ⇑self next ← x]
reset
	[readposition ← position ← 0]

SystemOrganization classify: ↪Queue under: 'Basic Data Structures'.

"Set" 
Class new title: 'Set'
	subclassof: Stream
	fields: 'views'
	declare: '';
	asFollows 

For storing/collecting, read by a SetReader.
Use no messages from Stream except of:, empty, next←, contents, space, nextword←

Initialization 
default [self vector: 8]
of: array to: position [limit ← array length]
string: limit [self of: (String new: limit)]
vector: limit [self of: (Vector new: limit)]

Index operations 
◦i [⇑array◦("self checkIndex:" i)]
◦i ← val [
	position+1 = i⇒ [self next ← val]
	⇑array◦("self checkIndex:" i) ← val]
deleteI: i | v j
	[
	v ← self◦i.
	for⦂ j from: i to: position-1 do⦂
		[array◦j ← array◦(j+1)
		].
	array◦position ← nil.
	position ← position-1.
	⇑v
	]
deleteI: i to: j| n k
	[
	n ← j-i+1.
	for⦂ k from: i to: position-n do⦂
		[array◦k ← array◦(k+n)
		].
	for⦂ k from: position-n+1 to: position do⦂
		[array◦k ← nil
		].
	position ← position-n.
	
	]
insertI: i value: v | old j 
	[i > position ⇒ [ self next ← v ]
	old←array.
	[position = limit⇒
		[limit← limit+(10 max: limit/4).
		array ← array species new: limit.
		for⦂ j to: i-1 do⦂
			[array◦j ← old◦j
			]
		]
	].
	for⦂ j from: position  to: i by: ¬1 do⦂
		[array◦(j+1) ← old◦j
		].
	array◦i ← v.
	position  ← position +1
	]

Value operations 
add: x  [self next ← x]
append: x  [for⦂ x from: x do⦂ [self next ← x]]
delete: x | i [
	for⦂ i to: position do⦂ [
		array◦i ≡ x⇒ [⇑self deleteI: i]].
	⇑false]
find: v | i [
	for⦂ i to: position do⦂ [array◦i = v⇒ [⇑i]].
	⇑0]
has: x [⇑(self find: x) > 0]
insert: x [(self find: x) = 0⇒ [self next← x]]

Viewing 
asSet
asStream [⇑self viewer]
copy [⇑self viewer copy]
initView: v [⇑v of: array to: position]
length [⇑position]
notViewed: v [
	views delete: v;
		empty⇒ [views ← nil]]
printon: strm | t [
	strm append: 'a Set: '.
	array is: String⇒ [strm append: self]
	for⦂ t from: self do⦂ [strm space; print: t]]
species [⇑array species]
viewer [
	⇑SetReader new of: array from: 1 to: position
	"self viewRange: 1 to: position"]
viewer: v [
	[views≡nil⇒ [views ← Set default]].
	views next ← v]
viewRange: i to: j [
	⇑"self viewer:" (
	SetReader new of: array from: (i "max: 1") to: (j "min: position"))]

Private 
checkIndex: i [
	i ≥ 1 and⦂ i ≤ position⇒ [⇑i]
	⇑user notify: 'illegal index']
grow [
	"self grown and reset. returns another Set with old contents"
	⇑self growby: (10 max: limit/4)]
growby: n | old [
	"grow and reset self. return old Set for copying"
	old ← Set new of: array to: position.
	self of: (array species new: limit+n) to: 0.
	⇑old]
next [user notify: 'no direct reading of a Set']
pastend ← x [
	⇑[self append: self grow; next ← x]]

Arithmetic operations 
dotproduct: s | i dotproduct
	["dot product of two sets ... sets must be of equal length"
	dotproduct ← 0.0.
	self length = s length ⇒
		[
	
		for⦂ i to: position do⦂ [dotproduct ← dotproduct + ((s◦i)*(self◦i))].
		⇑ dotproduct  
		]
	user notify: 'dot product undefined...sets are not of equal length'. 
	]
product: s | product i
	["product of two sets ... sets must be of equal length"
	product ← Set new default.
	self length = s length ⇒
		[
	
		for⦂ i to: position do⦂ [product add: (s◦i)*(self◦i)].
		⇑ product
  
		]
	user notify: 'product undefined...sets are not of equal length'. 
	]
summation| i summation
	["sum of the values in the set"
	summation ← 0.0.
	for⦂ i to: position do⦂ [summation ← summation + (self◦i)].
	⇑ summation
	]

SystemOrganization classify: ↪Set under: 'Basic Data Structures'.

"SetReader" 
Class new title: 'SetReader'
	subclassof: Stream
	fields: ''
	declare: '';
	asFollows 

Read a Set; no edits occur to set. (see Steve for ISetReader (interruptible))
Inherit of:from:to:, next, next:, end, pastend, skip:, ∢, asStream, viewer

Initialization 
of: array from: position for: n [
	position ← position-1.
	limit ← position+n]

Reading 
asSet [⇑self copy]
copy "yield contents all at once as a Set" [
	⇑[Set new of: (array species new: limit-position); append: self]]
length [
	"how much left"
	⇑limit-position]

SystemOrganization classify: ↪SetReader under: 'Basic Data Structures'.

"String" 
VariableLengthClass new title: 'String'
	subclassof: Array
	fields: ''
	declare: 'StringBlter ';
	bytesize: 8;
	asFollows 

I am an array of bytes, integers between 0 and 255 usually representing ascii characters

Reading and Writing 
all← val [self fill: 1 to: self length with: val]
fill: a to: b with: val | i [
	"eventually use BitBlt?"
	for⦂ i from: a to: b do⦂ [self◦i ← val]]
length [⇑self length "In case this is reached by perform:"]
word: x		"read word in String"
	[⇑self◦(x+x) + (self◦(x+x-1) lshift: 8)]
word: x ← y		"write word in String"
	[self◦(x+x-1) ← y lshift: ¬8.
	self◦(x+x) ← y land: 0377. ⇑y]

Copying and Altering 
concat: s | len [
	(len ← self length) + s length > 20 and⦂ (s Is: String)⇒ [
		"this concatenates more quickly if BitBlt is used"
		⇑self replace: len+1 to: len by: s from: 1 to: s length]
	⇑super concat: s]
copy: a to: b [⇑(self species new: 1+b-a) copy: 1 to: 1+b-a with: self from: a to: b]
copy: a to: b with: s from: c to: d | i [
	"like replace, except in place. self◦(a to: b) ← s◦(c to: d).
	use BitBlt unless size too small, StringBlter≡false, or index/sizes too large"

	(b-a > 12 and⦂ StringBlter) and⦂ (
		BitBlt new stringCopy: self from: a to: b with: s from: c to: d)⇒ []

	self ≡ s and⦂ (c < a and⦂ d ≥ a)⇒ [
		"overlap of second range with below first in same string.
		copy in reverse order: self◦(b to: a by: ¬1) ← self◦(d to: c by: ¬1)"
		for⦂ i from: b-a to: 0 by: ¬1 do⦂ [self◦(a+i) ← self◦(c+i)]]

	s copy: c to: d to: (Stream new of: self from: a to: b)]	
findString: str startingAt: start | i t
	[str length=0⇒[⇑0] t← str◦1.
	for⦂ i from: start to: self length-str length+1 do⦂
		[self◦i=t⇒[self◦(i to: i+str length-1)=str⇒[⇑i]]]
	⇑0]
growto: n | len [
	[(len ← self length) ≤ n⇒ [] len ← n].
	⇑(self species new: n) copy: 1 to: len with: self from: 1 to: len]
recopy
	[⇑self copy]
replace: a to: b by: s 
	[s Is: String ⇒[
		⇑self replace: a to: b by: s from: 1 to: s length]
	⇑self replace: a to: b by: s asArray from: 1 to: s position]
replace: a to: b by: r from: c to: d | s t [
	s ← self species new: self length + (d-c) - (b-a).

	"use BitBlt unless StringBlter≡false or index/sizes too large"
	StringBlter and⦂ (
		BitBlt new stringReplace: s with: self from: a to: b and: r from: c to: d)⇒ [⇑s]

	"see Array concat:"
	t ← Stream new of: s.
	self copy: 1 to: a-1 to: t.
	r copy: c to: d to: t.
	self copy: b+1 to: self length to: t.
	⇑s]
subst: repl for: key | key1 i nskip result
	[nskip ← 0. key1 ← key◦1. result ← Stream default.
	for⦂ i to: self length do⦂		" the Boyer Slow string replacement "
		[nskip>0⇒ [nskip ← nskip-1]
		self◦i = key1⇒
			[self◦(i to: (self length min: i+key length-1)) = key⇒
				[result append: repl. nskip ← key length-1]
			result next← self◦i]
		result next← self◦i]
	⇑result contents]

Comparison 
- s | i c ldiff	 [
	"Return a negative, zero, or positive integer as I compare < = or > s"
	"The collation sequence is ascii with case differences ignored."
	for⦂ i to: [
		(ldiff ← self length-s length) < 0⇒ [self length] s length] do⦂ [
		(c← UpperCase◦(self◦i + 1) -(UpperCase◦(s◦i + 1)))
			≠0⇒ [⇑c]].
	⇑ldiff]
< s
	["Return true iff I collate before s.  The collation sequence is ascii with case differences ignored."
	⇑(self compare: s) = 1]
> s
	["Return true iff I collate after s.  The collation sequence is ascii with case differences ignored."
	⇑(self compare: s) = 3]
compare: s | i len lcomp u1 u2 [
	lcomp ← [self length < (len ← s length)⇒ [len ← self length. 1]; =len⇒ [2] 3].
	for⦂ i to: len do⦂ [
		(u1 ← UpperCase◦(self◦i + 1)) = (u2 ← UpperCase◦(s◦i + 1))⇒ []
		u1 < u2⇒ [⇑1]
		⇑3]
	⇑lcomp]
hash | l m
	[[(l← m← self length)≤2⇒
		[l=2⇒[m←3]; =1⇒[⇑((self◦1) land: 0177)*0152] ⇑052525]].
	 ⇑(self◦1)*060+(self◦(m-1)+l)]
match: text | star pound pattern scanning p t back [
	star ← 052 "*".  pound ← 043 "#".
	pattern ← self asStream.  text ← text asStream.
	scanning ← false.
	while⦂ true do⦂ [
		(p ← pattern next)
			=star⇒ [pattern end⇒ [⇑true] scanning ← pattern position]
		(t ← text next)
			≡false⇒ [⇑t≡p]
		p≡false⇒ [
			scanning⇒ [
				back ← scanning - pattern position.
				pattern skip: back. text skip: back]
			⇑false]
		UpperCase◦(t+1) = (UpperCase◦(p+1)) or⦂ p=pound⇒ []
		scanning⇒ [
			back ← scanning - pattern position.
			pattern skip: back. text skip: back+1]
		⇑false]]
systemRehash | dicts d left loop
	["change the meaning of hash for Strings"
	String understands:
'hash | l m
	[[(l← m← self length)≤2⇒
		[l=2⇒[m←3]; =1⇒[⇑((self◦1) land: 0177)*0152] ⇑052525]].
	 ⇑(self◦1)*060+(self◦(m-1)+l)]'.

	"rehash the atom table"
	 ↪a rehash.

	"rehash all dictionaries which have strings in them"
	 dicts ← HashSet allInstances+Dictionary allInstances
					+SymbolTable allInstances.
	 for⦂ d from: dicts do⦂
		[left ← d objects asStream. loop ← left next.
		 while⦂ loop do⦂
			[loop is: String⇒[d rehash. loop ← false]
			 loop ← left next]]]

Conversion 
asBytes | s c
	[s ← Stream default.
	for⦂ c from: self do⦂
		[s append: c base8; space]
	⇑s contents]
asDecimalDigits "Not asInteger, because the result may be a Float if it's too big"
		| strm sign c val
	[strm← Stream new of: self.
	sign← strm∢025.
	val← [self length>4⇒[0.0]0].
	for⦂ c from: strm do⦂
		[c<060 or: c>071⇒[user notify: self + ' isn''t a valid integer']
		val← val*10+(c-060)]
	sign⇒[⇑val*¬1]
	⇑val]
asFileName [⇑dp0 checkName: self fixing: true]
asFloat | strm int frac exp
	[strm← Stream new of: self.
	int← strm upto: 056.
	frac← strm upto: 0145.
	exp← strm rest asInteger - frac length.
	int← (int concat: frac) asDecimalDigits asFloat.
	exp=0⇒[⇑int];
		>0⇒[⇑int*(10.0 ipow: exp)].
	⇑int/(10.0 ipow: 0-exp)
	]
asInteger | strm sign base maxdigit c val
	[strm← Stream new of: self.
	sign← [strm∢025⇒[¬1]1].
	base← [strm∢060⇒[8]10]. maxdigit← 060+base.
	val← 0.
	for⦂ c from: strm do⦂
		[c<060 or: c≥maxdigit⇒[user notify: self + ' isn''t a valid Integer']
		val← val*base+(c-060)]
	"Some special maneuvering to keep 01ddddd and ¬32768 (and nothing else) from overflowing."
	[val>077777⇒[base=8⇒[sign=1⇒[val<65536⇒[⇑val asSmall]]]]].
	⇑(val*sign) asInteger]
asLarge "convert to a LargeInteger"
	| neg i large large10
	[[self◦1=025⇒[neg←true] neg←false].
	 large ← 0 asLarge. large10 ← 10 asLarge.
	 for⦂ i from: [neg⇒[2]1] to: self length do⦂
		[large ← (large*large10)+(self◦i-060)].
	 neg⇒[⇑large negated] ⇑large]
asParagraph
	[⇑Paragraph new text: self alignment: 0]
asUppercase | s c
	[s ← Stream default.
	for⦂ c from: self do⦂
		[s next ← UpperCase◦(c+1)]
	⇑s contents]
asVector
	[⇑self asStream asVector]
base8: i  "word: i  in base 8 as a String"
	[⇑(self word: i) base8]
hasBeenUniqued
	[⇑↪a hasInterned: self]
printon: strm | x	"print inside string quotes"
	[strm next← 047.
	for⦂ x from: self do⦂
		[strm next← x.
		x=047⇒[strm next← x]]		"imbedded quotes get doubled"
	strm next← 047]
unique | u		"copy and intern"
	[⇑↪a intern: self]

Compatibility 
species
	[⇑String]

System primitives 
lock [] primitive: 31
unlock [] primitive: 32

SystemOrganization classify: ↪String under: 'Basic Data Structures'.

"Substring" 
Class new title: 'Substring'
	subclassof: Array
	fields: 'data map'
	declare: '';
	asFollows 

I am an array that consists of a set of elements (specified by map) of an array (data)

Initialization 
data: data map: map

Reading and Writing 
◦ x
	[⇑data◦(map◦x)]
◦ x ← val
	[⇑data◦(map◦x) ← val]
length
	[⇑map length]
map
	["Return my map."
	⇑map]

Copying and Altering 
swap: i with: j | t
	["By permuting my map (a writable Array), swap elements i and j."
	t ← map◦i. map◦i ← map◦j. map◦j ← t.]

Conversion 
asStream
	[map isIntervalBy1⇒	"direct stream for simple substrings"
		[⇑Stream new of: data from: map start to: map stop]
	⇑Stream new of: self from: 1 to: map length]

Compatability 
species
	[⇑data species]

SystemOrganization classify: ↪Substring under: 'Basic Data Structures'.

"UniqueString" 
VariableLengthClass new title: 'UniqueString'
	subclassof: String
	fields: ''
	declare: '';
	bytesize: 8;
	asFollows 

I am a string that is unequal to every other instance of my subclass

Initialization 
classInit | i a v		"make up table of 1-char atoms"
	[v ← Vector new: 128. a ← String new: 1.
	for⦂ i to: 128 do⦂
		[a◦1 ← i-1. v◦i ← a unique]
	UST1 ← v]
hasInterned: s | h i v n
		"⇑false if String s hasnt been interned, else ⇑s unique"
	[	[s length=1⇒[s◦1<128⇒[⇑UST1◦(s◦1+1)]]].
	h← s hash.
	v ← USTable◦(h\USTable length+1).
	i← h\v length+1.
	for⦂ n to: v length do⦂
		[v◦i≡nil⇒	[⇑false]
		[s length=(v◦i) length⇒ [s=(v◦i)⇒[⇑v◦i]]].
		i← [i=v length⇒[1] i+1]]
	user notify: 'USTable is jammed']
intern: s | h i j v n	
	[	[s length=1⇒[s◦1<128⇒[⇑UST1◦(s◦1+1)]]].
	h← [s is: String⇒[s hash] s stringhash].
	v ← USTable◦(h\USTable length+1).
	i← h\v length+1.
	for⦂ n to: v length do⦂
		[v◦i≡nil⇒								"empty slot"
			[n← ¬4.  for⦂ j from: v do⦂ [j≡nil⇒ [n ← n+4]].
			n < v length⇒					"grow bucket if > 3/4 full"
				[USTable◦(h\USTable length+1) ← Vector new: 2*v length.
				for⦂ n from: v do⦂		"rehash all its contents"
					[n≡nil⇒ [] self intern: n]
				⇑self intern: s]
			⇑v◦i ← [s is: UniqueString⇒[s]		"install new entry"
						(UniqueString new: s length) str: s]]
		[s length=(v◦i) length⇒ [s=(v◦i)⇒[⇑v◦i]]].
		i← [i=v length⇒[1] i+1]]
	user notify: 'USTable is jammed']
rehash | oldTable v i
	[oldTable ← USTable.
	 USTable ← Vector new: oldTable length.
	 for⦂ i to: USTable length do⦂
		[USTable◦i ← Vector new: 4].
	 for⦂ v from: oldTable do⦂
		[for⦂ i from: v do⦂
			[i≡nil⇒[] self intern: i]]]
str: s | j
	[for⦂ j to: s length do⦂
		[super◦j ← s◦j]
	⇑self]
unique

Reading and Writing 
◦x ← val
	[user notify: 'UniqueStrings are not for writing into']

Selectors 
isarrow	 "ends with ←"
	[self length≤1⇒ [⇑false]
	⇑self◦self length=95]
isinfix | x
	[self length≠1⇒ [⇑false]  ⇑(self◦1) isletter≡false]
iskeyword | x	"ends with colon"
	[self length≤1⇒ [⇑false]
	x ← self◦self length.
	x=072⇒[⇑true] ⇑x=03]
isuneval | x		"ends with open colon"
	[⇑self◦self length=03]
keywords  "return a vector of the keywords that compose me"
		| result strm i l char colon ocolon
	['◦←'=self⇒[⇑↪('◦' '←')]
	result←(Vector new: 10) asStream.  strm←Stream default.
	colon←':'◦1.  ocolon←'⦂'◦1.
	i←1.  l←self length.
	while⦂ i≤l do⦂
		[char←self◦i.  strm append: char.
		 [(char=colon or⦂ char=ocolon) or⦂ i=l⇒
			[result next← strm contents.  strm reset]].
		i←i+1].
	⇑result contents]
mustTake: nargs "fatal error if I am not a selector that takes nargs arguments"
	[self numArgs≠nargs⇒
		[user notify: self + ' does not take ' + nargs asString + ' arguments']]
numArgs  | len n i "the number of arguments I take when I am a selector"
	[len ← self length.
	len=1⇒ [⇑[(self◦1) isletter⇒ [0] 1]]
	n ← 0. "count colons, dots, and arrows"
	for⦂ i to: len do⦂ [self◦i=072⇒ [n←n+1]; =03⇒ [n←n+1]; =0137⇒[n←n+1]; =07⇒[n←n+1]].
	⇑n]

Comparison 
= x [⇑self≡x]
hash [] primitive: 46
stringhash
	[⇑super hash]

Compatibility 
copy [⇑self]
recopy [⇑self]
species
	[⇑String]

Conversion 
asString
[⇑super copy]
printon: strm
	[strm append: self]

SystemOrganization classify: ↪UniqueString under: 'Basic Data Structures'.
UniqueString classInit

"Vector" 
VariableLengthClass new title: 'Vector'
	subclassof: Array
	fields: ''
	declare: '';
	asFollows 

Vector is a VariableLengthClass.  The length of a Vector may not be less than 0,
nor may it be greater than 8196.  
A field of a Vector may contain any other object.
A new Vector contains nil in every field.  
To create a new Vector of length 8, say:
	Vector new: 8

Microcode Primitives
◦ x   "subscript"
	[0 > x or: x > self length ⇒[user notify: 'Subscript out of bounds']
	x class ≡ Integer ⇒[Return the xth element of the Vector]
	⇑ super ◦ x]
◦ x ← val  "assign value to element"
	[0 > x or: x > self length ⇒[user notify: 'Subscript out of bounds']
	x class ≡ Integer ⇒[Store the value val as the xth element. ⇑val]
	⇑ super ◦ x ← val]

Reading and Writing 
length "This is actually done in microcode"
	[⇑self length "perform: needs this"]

Copying and Altering 
, x | v
	[v ← self growby: 1.	"use a stream if youre in a hurry"
	v last ← x. ⇑v]

Searching 
max| biggest i
	[biggest ← self◦1.	"return largest value in a vector"
	for⦂ i to: self length do⦂
		[(self◦i) > biggest ⇒[biggest ← self◦i]].
	 ⇑biggest]

Conversion 
asVector
printon: strm | i
	[strm append: '('.
	for⦂ i to: self length do⦂
		[strm print: self◦i; space]
	strm append: ')' ]

System primitives 
nail [user croak] primitive: 31		"Nail me in core and return my core address"
unNail [user croak] primitive: 32		"Release me from being nailed"

Compiler argument list 
argsOff: stack
	[stack pop: self length]
emitForValue: code on: stack  | x
	[for⦂ x from: self do⦂ [x emitForValue: code on: stack]]
firstPush
	[⇑(self◦1) firstPush]
remote: generator  | x
	[for⦂ x from: self do⦂ [x remote: generator]]
sizeForValue  | size x
	[size ← 0. for⦂ x from: self do⦂ [size ← size+ x sizeForValue]. ⇑size]

SystemOrganization classify: ↪Vector under: 'Basic Data Structures'.
