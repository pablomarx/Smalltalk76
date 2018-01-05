'From Smalltalk 5.5k XM November 24 on 22 November 1980 at 2:57:08 am.'
\g
"Array"l15000z20000\gbf5 
Class new title: 'Array'
	subclassof: Object
	fields: ''
	declare: '';
	asFollows\gbf5 

Array is an abstract class in the sense that it has no state, and instantiation is consequently not meaningful.  However it defines the default message set inherited by its subclasses, notably String, Vector, and UniqueString.  Notice that subscripting is not done here, except to handle the exceptional cases such as subscripting by other types as in a◦(1 to: 3).\gi

Reading and Writing\gbf5 
◦ x
	[⇑x subscripts: self]\gb5B
◦ x ← val
	[⇑x subscripts: self ← val]\gb11B
< v "for sorting vectors by first element"
	[⇑(self◦1)<(v◦1)]\gb4Bi38I
= arg | x
	[arg isArray⇒
		[self length ≠ arg length⇒ [⇑false]
		for⦂ x to: self length do⦂ 
			[(self◦x) = (arg◦x)⇒ [] ⇑false]
		⇑true]
	⇑false]\gb6B
> v "for sorting vectors by first element"
	[⇑(self◦1)>(v◦1)]\gb4Bi38I
all ← val | i
	[for⦂ i to: self length do⦂
		[self◦i ← val]]\gb10B
last
	[⇑self◦self length]\gb6B
last ← val
	[⇑self◦self length ← val]\gb12B
length  [user notify: 'message not understood.']\gb8B

Copying and Altering\gbf5 
+ arg [⇑self concat: arg]\gb6B
concat: arg | x s [
	x ← self species new: self length + arg length.
	self copyto: (s ← x asStream).
	arg copyto: s.
	⇑x]\gb12B
copy
	[⇑self copy: 1 to: self length]\gb6B
copy: a to: b
	[⇑self copy: a to: b to: (self species new: b-a+1)]\gb15B
copy: a to: b to: t | i s me
	[s ← t asStream.
	me ← Stream new of: self from: a to: b.
	for⦂ i from: a to: b do⦂		"general code wont stop at false"
		[s next ← me next]
	⇑t]\gb20B95i33I
copyto: t
	[⇑self copy: 1 to: self length to: t]\gb11B
delete: obj | s each
	[s ← (self species new: self length) asStream.
	for⦂ each from: self do⦂
		[obj=each⇒[] s next← each]
	⇑ s contents]\gb12B
grow [⇑self growto: (4 max: self length*2)]\gb5B
growby: n [⇑self growto: self length + n]\gb10B
growto: n [⇑self "copyto:" copy: 1 to: self length to: (self species new: n)]\gb10B
insertNonDescending: x		"self is assumed to be sorted"
	[⇑self insertSorted: x]\gb24Bi30I
insertSorted: x | a c i		"self is assumed to be sorted"
	[i ← self findSorted: x.
	c ← (a ← self species new: self length+1) asStream.
	self◦(1 to: i) copyto: c. c next ← x. self◦(i+1 to: self length) copyto: c.
	⇑a]\gb16B9i30I
notNil | t i  "copy self (which contains no falses) removing all nils"
	[t ← (self species new: (self length-(self count: nil))) asStream.
	for⦂ i from: self do⦂ [i≡nil ⇒[] t next← i].
	⇑t asArray]
\gb7B7i56I
replace: a to: b by: s | x xs
	[x ← self species new: self length+s length -(1+b-a).
	xs ← x asStream.
	self copy: 1 to: a-1 to: xs.
	s copy: 1 to: s length to: xs.
	self copy: b+1 to: self length to: xs.
	⇑x]\gb23B
without: index | s me i  "if index in range, return self without ◦index"
	[index cansubscript: self⇒
		[s ← (self species new: self length-1) asStream.
		me ← self asStream.
		for⦂ i to: self length do⦂ [i=index⇒ [me next] s next ← me next].
		⇑s asArray]]\gb15B10i47I

Searching\gbf5 
all⦂ variable suchThat⦂ expr | s i x  "a copy of some of me"
	[s ← (self species new: self length) asStream.
	for⦂ i to: self length do⦂
		[x ← self◦i. variable value ← x.
		expr eval⇒ [s next ← x]].
	⇑s contents]\gb29B9i22I
count: x | i n
	[n←0.
	for⦂ i to: self length do⦂
		[x=(self◦i)⇒ [n←n+1]].
	⇑n]\gb9B
find⦂ x suchThat⦂ predicate | i
	[for⦂ i to: self length do⦂
		[x value ← self◦i. predicate eval⇒ [⇑i]].
	⇑0]\gb28B
find: x | i
	[for⦂ i to: self length do⦂
		[self◦i=x⇒ [⇑i]].
	⇑0]\gb8B
findnon: x | i
	[for⦂ i to: self length do⦂
		[self◦i≠x⇒ [⇑i]].
	⇑0]\gb11B
findSorted: x | lo mid hi		" returns index of largest element ≤ x "
	[hi ← self length+1.  lo ← 1.
	while⦂ lo < hi do⦂		"binary search; self must be sorted"
		[self◦(mid←lo+hi/2) > x⇒[hi ← mid]  lo ← mid+1].
	⇑hi-1]		" 0≤result≤length "\gb14B
first⦂ x suchThat⦂ predicate | i
	[for⦂ i to: self length do⦂
		[x value ← self◦i. predicate eval⇒ [⇑self◦i]].
	⇑false]\gb29B
has: x [⇑(self find: x)≠0]\gb7B

Permutation\gbf5 
permutationToSort
	["Return a Vector, permutation, such that self◦permutation is sorted nondescending.  Do not alter self."
	⇑((self◦((1 to: self length) copy)) sort: 1 to: self length) map.]\gb19B1i103I
promote: t | n
	[n ← self find: t. n=0⇒ []
	self◦(n to: 2 by: ¬1) ← self◦(n-1 to: 1 by: ¬1).
	self◦1 ← t]\gb11B
reverse	
	[⇑Substring new data: self map: (self length to: 1 by: ¬1)]\gb10B
sort
	["Permute my elements so they are sorted nondescending.  Note: if I am a substring, only my map will be permuted.  In certain situations, this may not be what you expect."
	self sort: 1 to: self length.]\gb6B1i170I
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
	self sort: k to: j.]\gb14B26i56I4i33I16i18I3i13I90i33I26i32I2i44I108i35I3i129I142i108I
swap: i with: j | t
	[t ← self◦i. self◦i ← self◦j. self◦j ← t]\gb16B

Conversion\gbf5 
asSet [⇑Set new of: self to: self length]\gb6B
asStream
	[⇑Stream new of: self]\gb10B
frequencies | d x  "return a sorted vector ((freq item) (freq item) ...)"
	[d ← Dictionary new init: 64.
	for⦂ x from: self do⦂
		[d tally: x].
	⇑d asInvertedVector sort]\gb12B7i54I
sum [⇑self sumTo: 0]\gb4B
sumTo: subTotal | x		"add all my elements to this subTotal (usually 0 or 0.0)"
	[for⦂ x from: self do⦂
		[subTotal← subTotal+x].
	⇑subTotal]\gb16B
transform⦂ each to⦂ expr | s i  "a copy of me with each element transformed"
	[s ← (self species new: self length) asStream.
	for⦂ i to: self length do⦂
		[each value ← self◦i. s next ← expr eval].
	⇑s asArray]\gb25B7i44I
viewer [⇑SetReader new of: self]\gb7B

Mapping\gbf5 
cansubscript: a | i
	[for⦂ i from: self do⦂ [i cansubscript: a⇒ [] ⇑false]]\gb16B
subscripts: x			"subarrays"
	[⇑Substring new data: x map: self]\gb16Bi11I
subscripts: x ← val		"subrange replacement"
	[self length≠val length⇒
		[user notify: 'lengths not commensurate']
	val copyto: (Substring new data: x map: self).
	⇑val]\gb21Bi22I

Compatibility\gbf5 
isArray\gb
isIntervalBy1
	[⇑false]\gb15B
species
	[⇑Vector]\gb9B

Comparing\gbf5 
hash "make sure = arrays hash =ly"
	[self length=0⇒[⇑17171]
	⇑(self◦1) hash + (self◦self length) hash]\gb5Bi29I
\g
SystemOrganization classify: ↪Array under: 'Basic Data Structures'.\g

"FieldReference"l15000z20000\gbf5 
Class new title: 'FieldReference'
	subclassof: Object
	fields: 'object offset'
	declare: '';
	asFollows\gbf5 

I reference a field of an instance\gi

Initialization\gbf5 
object: object offset: offset\gb

Indirection\gbf5 
eval 
	[⇑object instfield: offset]\gb7B
value [⇑object instfield: offset]\gb6B
value ← value
	[object instfield: offset ← value. ⇑value]\gb15B
\g
SystemOrganization classify: ↪FieldReference under: 'Basic Data Structures'.\g

"Interval"l15000z20000\gbf5 
Class new title: 'Interval'
	subclassof: Array
	fields: 'start stop step length'
	declare: '';
	asFollows\gbf5 

I am an arithmetic progression from start in steps of step, not exceeding stop\gi

Initialization\gbf5 
from: start to: stop by: step
	[length ← 1+(stop-start/step).
	step<0⇒[start<stop⇒[length← 0]]
	stop<start⇒[length← 0]
	]\gb31B

Reading and Writing\gbf5 
◦ x
	[x is: Integer⇒[x<1⇒ [⇑nil]
		x>length⇒ [⇑nil]
		⇑start+(step*(x-1))]
	⇑super◦x]\gb5B
◦ x ← val
	[user notify: 'Intervals are not for writing into']\gb11B
length [⇑length]\gb7B
start [⇑start]\gb6B
stop [⇑stop]\gb5B

Compatibility\gbf5 
= int [⇑start = int start and⦂ (stop = int stop and⦂ length = int length)]\gb6B
cansubscript: a
	[⇑length≤0 or⦂ ((start cansubscript: a) and⦂ (length-1*step+start cansubscript: a))]\gb17B
hash [⇑(((start lshift: 2) lxor: stop) lshift: 1) lxor: length]\gb5B
isIntervalBy1
	[⇑step=1]\gb15B

Random Numbers\gbf5 
random		"See Lehmers linear congruential method, Knuth Vol. 1:
	modulus m=2^16
	a=27181 odd, and 5 = a mod 8
	c=13849 odd, and c/m around 0.21132"
	[step← (13849 + (27181*step)) asSmall.
	⇑(start + ((length asFloat*(32768.0+step))/65536.0)) asSmall]\gb8Bi138bI2B
randomInit [self randomInit: mem◦0430]\gb11B
randomInit: x		"Call with const to get repeatable sequence"
	[step← x.		"step holds the current state"
	start is: Float⇒[length←stop-start]		"for Float intervals"]\gb15Bi44bI2B11i30I39i21I
\g
SystemOrganization classify: ↪Interval under: 'Basic Data Structures'.\g

"ObjectReference"l15000z20000\gbf5 
Class new title: 'ObjectReference'
	subclassof: Object
	fields: 'object'
	declare: '';
	asFollows\gbf5 

I am an indirect reference\gi

Initialization\gbf5 
object: object\gb

Indirection\gbf5 
eval 
	[⇑object]\gb7B
value [⇑object]\gb6B
value ← object
	[⇑object]\gb16B

Conversion\gbf5 
printon: strm
	[strm append: '->'; print: object]\gb15B
\g
SystemOrganization classify: ↪ObjectReference under: 'Basic Data Structures'.\g

"RunVector"l15000z20000\gbf5 
Class new title: 'RunVector'
	subclassof: Array
	fields: ' min max starts values offset'
	declare: '';
	asFollows\gbf5 

RunVectors compactly store data which tends to be constant over much
of its domain.  They may have any range of subscript, but must be stored
into consecutively.\gi

Reading and writing\gbf5 
◦i | index
	[index← starts findSorted: i.
	offset← i-(starts◦index).		"distance into run"
	⇑values◦index]\gb10B
◦i← val
	[offset← 0.
	min≡nil⇒[min← max← i. starts← i inVector. values← val inVector]
	i-1≠max⇒[user notify: 'RunVectors must be loaded sequentially'. ⇑val]
	max← i.
	val=values last⇒[offset← i-starts last. ⇑val]
	starts← starts , i.
	values← values , val. ⇑val]
\gb9B
length [max≡nil⇒[⇑0]
	⇑max-min+1]\gb7B
max [⇑max]\gb4B
min [⇑min]\gb4B
\g
SystemOrganization classify: ↪RunVector under: 'Basic Data Structures'.\g

"Stream"l15000z20000\gbf5 
Class new title: 'Stream'
	subclassof: Object
	fields: 'array position limit'
	declare: '';
	asFollows\gbf5 

Streams provide fast sequential access to arrays (implemented in microcode for Strings and Vectors).  A subclass can handle end conditions if desired (disk files do this).\gi

Initialization\gbf5 
close
	[limit← position. position← 0]\gb7B
default
	[self of: (String new: 16)]\gb9B
of: array
	[position ← 0. limit ← array length]\gb11B
of: array from: pos to: lim | len
	[limit ← [lim > (len ← array length)⇒ [len] lim].
	position ← [pos≤1⇒ [0] pos-1]]\gb28B5b2B
release [array ← nil]\gb8B

Sequential reading and writing\gbf5 
∢ x | y
	[y← self next⇒		"peek for matching element"
		[x=y⇒ [⇑y]		"gobble it if found"
		position ← position-1. ⇑false]
	⇑false]\gb4B21i27I15i20I
append: x | i	"Array arg"
	[for⦂ i from: x do⦂
		[self next ← i].
	⇑x]\gb10B4i11I
dequeue		"use it as a FIFO"
	[⇑self dequeue: 1]\gb9Bi18I
dequeue: n | t
	[position<n⇒ [⇑false]
	t ← (array◦(1 to: n)) copy.
	array◦(1 to: position-n) ← array◦(n+1 to: position).
	position ← position-n. ⇑t]\gb11B
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
	⇑(val*sign) asInteger]\gb12B
into: x [
	"generate an error if the Stream is exhausted before x is filled"
	⇑self into: x endError: true]\gb8B
into: x endError: err | i t len ["Array result"
	i ← 0.
	len ← x length.
	"read until count or stream is exhausted"
	while⦂ (i < len and⦂ (t ← self next)) do⦂ [x◦(i←i+1) ←t].

	err⇒ [
		t⇒ [⇑x]
		user notify: 'only read first ' + i asString]

	"return number that were read"
	⇑i]j\gb22B11i14I
next	"simple result"
	[self myend⇒ [⇑self pastend]
	⇑array◦(position ← position+1)] primitive: 17\gb5Bi15I
next: n [⇑self into: (array species new: n) endError: true]\gb8B
next: n from: strm [for⦂ n to: n do⦂ [self next ← strm next]]\gb19B
next: n ← v [for⦂ n to: n do⦂ [self next ← v]]\gb12B
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
	⇑LargeInteger new bytes: s neg: false]\gb14B12i64I16i61I46i48I89i31I47i16I
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
	self append: v reverse]\gb18B11i56I95i22I114i49I
nextPoint | x [
	x ← self nextword.
	⇑Point new x: x y: self nextword]\gb10B
nextPoint←p [
	self nextword ← p x;
		nextword ← p y]\gb12B
nextString | len [
	⇑self into: (String new: [
		(len ← self next)
			<192⇒[len]	"up to 191 chars (BCPL compat)"
		len-192*256 + self next]) endError: true]		"up to 16383 chars"\gb11B70i31I46i
nextString← s | len [
	[(len ← s length) < 192⇒[self next← len]
	self next← len/256+192; next← len\256].
	self append: s.
	⇑s]\gb14B
nextword | hi lo
	[hi ← self next⇒
		[lo ← self next⇒
			[⇑(hi lshift: 8)+lo]
		⇑false]
	⇑false]\gb9B
nextword← val
	[self next← val lshift: ¬8.
	self next← val land: 0377. ⇑val]\gb15B
next ← x		"simple arg"
	[self myend⇒ [⇑self pastend ← x]
	⇑array◦(position ← position+1) ← x] primitive: 18\gb10Bi12I
padNext ["make position even (on word boundary), returning padding character if any"
	position even⇒ [⇑false]
	⇑self next]\gb8B
padNext← c [
	position even⇒ [⇑false]
	⇑self next← c]\gb11B
peek | x
	[x← self next⇒ [position ← position-1.  ⇑x]		"peek at next element"
	⇑false]\gb5B50i22I
pop		"use it as a LIFO"
	[position<1⇒ [⇑false]
	position ← position-1. ⇑array◦(position+1)]\gb5Bi18I
pop: n | t
	[position<n⇒ [⇑false]
	t ← self last: n.
	position ← position-n. ⇑t]\gb7B
upto: x | y s
	[s ← (String new: 250) asStream.
	for⦂ y from: self do⦂
		[y=x⇒[⇑s contents]
		s next ← y].
	⇑s contents]\gb8B

Test and alter position\gbf5 
empty		"for"
	[⇑position=0]\gb7Bi5I
end
	[⇑position≥limit]\gb5B
limit
	[⇑limit]\gb7B
loc	"synonym for compiler"
	[⇑position]\gb4Bi22I
myend
	[⇑position≥limit]\gb7B
pastend
	[⇑false]\gb9B
pastend ← x
	[array ← array grow. limit ← array length.
	⇑self next ← x]\gb13B
position
	[⇑position]\gb10B
position← position\gb
reset
	[position ← 0]\gb7B
settoend [position← limit]\gb9B
skip: x
	[position ← position+x]\gb9B
skipTo: x | y [
	for⦂ y from: self do⦂ [y=x⇒[⇑true]].
	⇑false]\gb10B
skipwords: w [self skip: 2*w]\gb13B
wordposition [⇑self position/2]\gb13B
wordposition← w [self position← w*2]\gb16B

Static reading and writing\gbf5 
◦ x
	[⇑array◦x]\gb5B
◦ x ← val
	[⇑array◦x ← val]\gb11B
contents [⇑array copy: 1 to: position]\gb9B
first
	[position ≠ 0 ⇒ [⇑array◦1] ⇑nil]\gb7B
insert: x | i  "treat as LIFO queue, insert in front"
	["grow array if necessary"
	 [position=limit⇒
		[array←array grow.
		limit←array length]].
	for⦂ i to: position do⦂
		[array◦(position-i+2) ← array◦(position-i+1)].
	array◦1 ← x.
	position←position+1]\gb10B5i38I4i23I
last
	[position≠ 0 ⇒ [⇑array◦position] ⇑nil]\gb6B
last: n
	[⇑(array◦(position-n+1 to: position)) copy]\gb9B
rest [⇑array copy: position+1 to: limit]\gb5B

Character printing\gbf5 
cr
	[self next ← 015]\gb4B
crtab: n | i
	[self next←13.
	for⦂ i to: n do⦂ [self next←9]]\gb9B3b2B
print: obj
	[obj printon: self]\gb12B
semicrtab
	[self append: ';
	']\gb11B
space
	[self next ← 040]\gb7B
tab
	[self next ← 011]\gb5B

Coercions\gbf5 
asArray
	[⇑array]\gb9B
asReadStream [
	"an alternative to Set/SetReader.
	create another Stream which reads the contents of this one"
	⇑Stream new of: array from: 1 to: position]\gb13B
asStream\gb
asVector "Convert a string to a vector of tokens"
	[⇑(Reader new of: self) read]\gb9Bi40I
viewer [⇑SetReader new of: array from: 1 to: position]\gb7B

Compiler object code\gbf5 
emitLong: jmpOrBfp by: dist
	[[dist<0⇒ [dist←dist+1024]; >1023⇒ [dist←¬1] jmpOrBfp←jmpOrBfp+4].
	dist<0⇒ [user notify: 'A block compiles more than 1K bytes of code']
	self next ← dist/256 + jmpOrBfp. self next ← dist\256]\gb29B
\g
SystemOrganization classify: ↪Stream under: 'Basic Data Structures'.\g

"PQueue"l15000z20000\gbf5 
Class new title: 'PQueue'
	subclassof: Stream
	fields: 'readposition'
	declare: '';
	asFollows\gbf5 

A PQueue is a First In First Out list of objects implemented as an array and a read pointer and write pointer. PQueue is a subclass of Stream and uses Streamⓢstandard method for inserting a new item (next←, i.e. Streamⓢposition is the write pointer). A PQueue also has a read pointer which it uses for accessing objects with the messages next or dequeue (which are identical). All messages to a PQueue that change its state are declared as critical sections to avoid race conditions\gi

FIFO access\gbf5 
dequeue: num | n
	[Top critical⦂
		[position-readposition < num ⇒ [n ← false]
		 n ← (array◦(readposition+1 to: readposition + num)) copy.
		 readposition ← readposition + num].
	 ⇑n]\gb13B
length | l
	[Top critical⦂ [l ← position-readposition]. ⇑l]\gb7B
myend [⇑true]\gb6B
next | n
	[Top critical⦂
		[readposition≥position⇒ [readposition←position←0. n ← false]
		 n ← array◦(readposition ← readposition+1)].
	 ⇑n] primitive: 98\gb5B
pastend ← x	 | n i	"simple arg"
	[Top critical⦂
		[position≥limit⇒
			[readposition=0⇒[super pastend ← x]
			 n ← position-readposition.
			 for⦂ i to: n do⦂ [array◦i ← array◦(readposition+i)].
			 readposition ← 0. position ← n.
			 self next ← x]
		 array◦(position ← position+1) ← x].
	 ⇑x]\gb13B6i12I
peek | n
	[Top critical⦂
		[readposition≥position⇒ [readposition←position←0. n ← false]
		 n ← array◦(readposition + 1)].
	 ⇑n]\gb5B
skip: x
	[Top critical⦂ [readposition ← readposition+x]]\gb9B

LIFO access\gbf5 
push: x				"treat as LIFO queue"
	[Top critical⦂
		[readposition > 0 ⇒
			[array◦readposition ← x.
			 readposition ← readposition - 1]		"readpositon > 0, just jam it in"
		 self insert: x]]											"otherwise insert on front"\gb11Bi21I105i33I31i

Stream protocol\gbf5 
contents | n
	[Top critical⦂ [n ← (array◦(readposition+1 to: position)) copy]. ⇑n]\gb9B
empty | l
	[Top critical⦂ [l ← readposition≥position]. ⇑l] primitive: 99\gb6B
end | n
	[Top critical⦂ [n ← readposition≥position]. ⇑n]\gb4B
of: array
	[Top critical⦂ [position ← 0. readposition ← 0. limit ← array length]]\gb11B
of: array from: position to: limit
	[user notify: 'of:from:to: is not appropriate for PQueues']\gb36B
reset
	[Top critical⦂ [readposition ← position ← 0]]\gb7B
\g
SystemOrganization classify: ↪PQueue under: 'Basic Data Structures'.\g

"Queue"l15000z20000\gbf5 
Class new title: 'Queue'
	subclassof: Stream
	fields: 'readposition'
	declare: '';
	asFollows\gbf5 

A Queue is a First In First Out list of objects implemented as an array and a read pointer and write pointer. Queue is a subclass of Stream and uses Streamⓢstandard method for inserting a new item (next←, i.e. Streamⓢposition is the write pointer). A Queue also has a read pointer which it uses for accessing objects with the messages next or dequeue (which are identical)\gi

FIFO access\gbf5 
deQ1 | n	"A noninterruptable dequeue"
	[Top critical⦂ [n ← self dequeue].
	 ⇑n]\gb5B4i28I
dequeue
	[readposition≥position⇒ [readposition←position←0. ⇑false]
	 ⇑array◦(readposition ← readposition+1)]\gb9B
dequeue: num | n
	[position-readposition < num ⇒ [⇑false]
	 n ← (array◦(readposition+1 to: readposition + num)) copy.
	 readposition ← readposition + num.
	 ⇑n]\gb13B
enQ1: n	"A noninterruptable enqueue"
	[Top critical⦂ [super next← n].
	 ⇑n]\gb8Bi28I
length
	[⇑position-readposition]\gb8B
next
	[readposition≥position⇒ [readposition←position←0. ⇑false]
	 ⇑array◦(readposition ← readposition+1)]\gb6B
peek
	[readposition≥position⇒ [readposition←position←0. ⇑false]
	 ⇑array◦(readposition + 1)]\gb6B
skip: x
	[readposition ← readposition+x]\gb9B

LIFO access\gbf5 
push: x				"treat as LIFO queue"
	[readposition > 0 ⇒
	[array◦readposition ← x.  readposition ← readposition - 1]		"readpositon > 0, just jam it in"
	self insert: x]																"otherwise insert on front"\gb11Bi21I83i33I33i

Stream protocol\gbf5 
contents
	[⇑(array◦(readposition+1 to: position)) copy]\gb10B
empty
	[⇑readposition≥position]\gb7B
end
	[⇑readposition≥position]\gb5B
of: array
	[position ← 0. readposition ← 0. limit ← array length]\gb11B
of: array from: position to: limit
	[user notify: 'of:from:to: is not appropriate for Queues']\gb36B
pastend ← x | n
	[readposition=0⇒[⇑super pastend ← x]
	 n ← position-readposition.
	 array◦(1 to: n) ← array◦(readposition+1 to: position).
	 readposition ← 0.
	 position ← n.
	 ⇑self next ← x]\gb12B
reset
	[readposition ← position ← 0]\gb7B
\g
SystemOrganization classify: ↪Queue under: 'Basic Data Structures'.\g

"Set"l15000z20000\gbf5 
Class new title: 'Set'
	subclassof: Stream
	fields: 'views'
	declare: '';
	asFollows\gbf5 

For storing/collecting, read by a SetReader.
Use no messages from Stream except of:, empty, next←, contents, space, nextword←\gi

Initialization\gbf5 
default [self vector: 8]\gb8B
of: array to: position [limit ← array length]\gb23B
string: limit [self of: (String new: limit)]\gb14B
vector: limit [self of: (Vector new: limit)]\gb14B

Index operations\gbf5 
◦i [⇑array◦("self checkIndex:" i)]\gb3B
◦i ← val [
	position+1 = i⇒ [self next ← val]
	⇑array◦("self checkIndex:" i) ← val]\gb9B
deleteI: i | v j
	[
	v ← self◦i.
	for⦂ j from: i to: position-1 do⦂
		[array◦j ← array◦(j+1)
		].
	array◦position ← nil.
	position ← position-1.
	⇑v
	]\gb11B
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
	
	]\gb16B
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
	]\gb20B

Value operations\gbf5 
add: x  [self next ← x]\gb8B
append: x  [for⦂ x from: x do⦂ [self next ← x]]\gb11B
delete: x | i [
	for⦂ i to: position do⦂ [
		array◦i ≡ x⇒ [⇑self deleteI: i]].
	⇑false]\gb10B
find: v | i [
	for⦂ i to: position do⦂ [array◦i = v⇒ [⇑i]].
	⇑0]\gb8B
has: x [⇑(self find: x) > 0]\gb7B
insert: x [(self find: x) = 0⇒ [self next← x]]\gb10B

Viewing\gbf5 
asSet\gb
asStream [⇑self viewer]\gb9B
copy [⇑self viewer copy]\gb5B
initView: v [⇑v of: array to: position]\gb12B
length [⇑position]\gb7B
notViewed: v [
	views delete: v;
		empty⇒ [views ← nil]]\gb13B
printon: strm | t [
	strm append: 'a Set: '.
	array is: String⇒ [strm append: self]
	for⦂ t from: self do⦂ [strm space; print: t]]\gb14B
species [⇑array species]\gb8B
viewer [
	⇑SetReader new of: array from: 1 to: position
	"self viewRange: 1 to: position"]\gb7B
viewer: v [
	[views≡nil⇒ [views ← Set default]].
	views next ← v]\gb10B
viewRange: i to: j [
	⇑"self viewer:" (
	SetReader new of: array from: (i "max: 1") to: (j "min: position"))]\gb19B

Private\gbf5 
checkIndex: i [
	i ≥ 1 and⦂ i ≤ position⇒ [⇑i]
	⇑user notify: 'illegal index']\gb14B
grow [
	"self grown and reset. returns another Set with old contents"
	⇑self growby: (10 max: limit/4)]\gb5B
growby: n | old [
	"grow and reset self. return old Set for copying"
	old ← Set new of: array to: position.
	self of: (array species new: limit+n) to: 0.
	⇑old]\gb16B
next [user notify: 'no direct reading of a Set']\gb5B
pastend ← x [
	⇑[self append: self grow; next ← x]]\gb12B

Arithmetic operations\gbf5 
dotproduct: s | i dotproduct
	["dot product of two sets ... sets must be of equal length"
	dotproduct ← 0.0.
	self length = s length ⇒
		[
	
		for⦂ i to: position do⦂ [dotproduct ← dotproduct + ((s◦i)*(self◦i))].
		⇑ dotproduct  
		]
	user notify: 'dot product undefined...sets are not of equal length'. 
	]\gb14B
product: s | product i
	["product of two sets ... sets must be of equal length"
	product ← Set new default.
	self length = s length ⇒
		[
	
		for⦂ i to: position do⦂ [product add: (s◦i)*(self◦i)].
		⇑ product
  
		]
	user notify: 'product undefined...sets are not of equal length'. 
	]\gb11B
summation| i summation
	["sum of the values in the set"
	summation ← 0.0.
	for⦂ i to: position do⦂ [summation ← summation + (self◦i)].
	⇑ summation
	]\gb9B
\g
SystemOrganization classify: ↪Set under: 'Basic Data Structures'.\g

"SetReader"l15000z20000\gbf5 
Class new title: 'SetReader'
	subclassof: Stream
	fields: ''
	declare: '';
	asFollows\gbf5 

Read a Set; no edits occur to set. (see Steve for ISetReader (interruptible))
Inherit of:from:to:, next, next:, end, pastend, skip:, ∢, asStream, viewer\gi

Initialization\gbf5 
of: array from: position for: n [
	position ← position-1.
	limit ← position+n]\gb32B

Reading\gbf5 
asSet [⇑self copy]\gb6B
copy "yield contents all at once as a Set" [
	⇑[Set new of: (array species new: limit-position); append: self]]\gb5B
length [
	"how much left"
	⇑limit-position]\gb7B
\g
SystemOrganization classify: ↪SetReader under: 'Basic Data Structures'.\g

"String"l15000z20000\gbf5 
VariableLengthClass new title: 'String'
	subclassof: Array
	fields: ''
	declare: 'StringBlter ';
	bytesize: 8;
	asFollows\gbf5 

I am an array of bytes, integers between 0 and 255 usually representing ascii characters\gi

Reading and Writing\gbf5 
all← val [self fill: 1 to: self length with: val]\gb9B
fill: a to: b with: val | i [
	"eventually use BitBlt?"
	for⦂ i from: a to: b do⦂ [self◦i ← val]]\gb24B
length [⇑self length "In case this is reached by perform:"]\gb7B14i37I
word: x		"read word in String"
	[⇑self◦(x+x) + (self◦(x+x-1) lshift: 8)]\gb9Bi21I
word: x ← y		"write word in String"
	[self◦(x+x-1) ← y lshift: ¬8.
	self◦(x+x) ← y land: 0377. ⇑y]\gb13Bi22I

Copying and Altering\gbf5 
concat: s | len [
	(len ← self length) + s length > 20 and⦂ (s Is: String)⇒ [
		"this concatenates more quickly if BitBlt is used"
		⇑self replace: len+1 to: len by: s from: 1 to: s length]
	⇑super concat: s]\gb10B
copy: a to: b [⇑(self species new: 1+b-a) copy: 1 to: 1+b-a with: self from: a to: b]\gb14B
copy: a to: b with: s from: c to: d | i [
	"like replace, except in place. self◦(a to: b) ← s◦(c to: d).
	use BitBlt unless size too small, StringBlter≡false, or index/sizes too large"

	(b-a > 12 and⦂ StringBlter) and⦂ (
		BitBlt new stringCopy: self from: a to: b with: s from: c to: d)⇒ []

	self ≡ s and⦂ (c < a and⦂ d ≥ a)⇒ [
		"overlap of second range with below first in same string.
		copy in reverse order: self◦(b to: a by: ¬1) ← self◦(d to: c by: ¬1)"
		for⦂ i from: b-a to: 0 by: ¬1 do⦂ [self◦(a+i) ← self◦(c+i)]]

	s copy: c to: d to: (Stream new of: self from: a to: b)]	\gb36B8i139I151i127I
findString: str startingAt: start | i t
	[str length=0⇒[⇑0] t← str◦1.
	for⦂ i from: start to: self length-str length+1 do⦂
		[self◦i=t⇒[self◦(i to: i+str length-1)=str⇒[⇑i]]]
	⇑0]\gb34B
growto: n | len [
	[(len ← self length) ≤ n⇒ [] len ← n].
	⇑(self species new: n) copy: 1 to: len with: self from: 1 to: len]\gb10B
recopy
	[⇑self copy]\gb8B
replace: a to: b by: s 
	[s Is: String ⇒[
		⇑self replace: a to: b by: s from: 1 to: s length]
	⇑self replace: a to: b by: s asArray from: 1 to: s position]\gb25B
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
	⇑s]\gb37B7b2B54i60I108i17I
subst: repl for: key | key1 i nskip result
	[nskip ← 0. key1 ← key◦1. result ← Stream default.
	for⦂ i to: self length do⦂		" the Boyer Slow string replacement "
		[nskip>0⇒ [nskip ← nskip-1]
		self◦i = key1⇒
			[self◦(i to: (self length min: i+key length-1)) = key⇒
				[result append: repl. nskip ← key length-1]
			result next← self◦i]
		result next← self◦i]
	⇑result contents]\gb21B103i37I

Comparison\gbf5 
- s | i c ldiff	 [
	"Return a negative, zero, or positive integer as I compare < = or > s"
	"The collation sequence is ascii with case differences ignored."
	for⦂ i to: [
		(ldiff ← self length-s length) < 0⇒ [self length] s length] do⦂ [
		(c← UpperCase◦(self◦i + 1) -(UpperCase◦(s◦i + 1)))
			≠0⇒ [⇑c]].
	⇑ldiff]\gb4B16i70I2i64I
< s
	["Return true iff I collate before s.  The collation sequence is ascii with case differences ignored."
	⇑(self compare: s) = 1]\gb5B1i101I
> s
	["Return true iff I collate after s.  The collation sequence is ascii with case differences ignored."
	⇑(self compare: s) = 3]\gb5B1i100I
compare: s | i len lcomp u1 u2 [
	lcomp ← [self length < (len ← s length)⇒ [len ← self length. 1]; =len⇒ [2] 3].
	for⦂ i to: len do⦂ [
		(u1 ← UpperCase◦(self◦i + 1)) = (u2 ← UpperCase◦(s◦i + 1))⇒ []
		u1 < u2⇒ [⇑1]
		⇑3]
	⇑lcomp]\gb11B
hash | l m
	[[(l← m← self length)≤2⇒
		[l=2⇒[m←3]; =1⇒[⇑((self◦1) land: 0177)*0152] ⇑052525]].
	 ⇑(self◦1)*060+(self◦(m-1)+l)]\gb5B
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
		⇑false]]\gb12B
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
			 loop ← left next]]]\gb13B83b1B1b5B

Conversion\gbf5 
asBytes | s c
	[s ← Stream default.
	for⦂ c from: self do⦂
		[s append: c base8; space]
	⇑s contents]\gb8B
asDecimalDigits "Not asInteger, because the result may be a Float if it's too big"
		| strm sign c val
	[strm← Stream new of: self.
	sign← strm∢025.
	val← [self length>4⇒[0.0]0].
	for⦂ c from: strm do⦂
		[c<060 or: c>071⇒[user notify: self + ' isn''t a valid integer']
		val← val*10+(c-060)]
	sign⇒[⇑val*¬1]
	⇑val]\gb16Bi66I
asFileName [⇑dp0 checkName: self fixing: true]\gb11B
asFloat | strm int frac exp
	[strm← Stream new of: self.
	int← strm upto: 056.
	frac← strm upto: 0145.
	exp← strm rest asInteger - frac length.
	int← (int concat: frac) asDecimalDigits asFloat.
	exp=0⇒[⇑int];
		>0⇒[⇑int*(10.0 ipow: exp)].
	⇑int/(10.0 ipow: 0-exp)
	]\gb8B
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
	⇑(val*sign) asInteger]\gb10B261i90I
asLarge "convert to a LargeInteger"
	| neg i large large10
	[[self◦1=025⇒[neg←true] neg←false].
	 large ← 0 asLarge. large10 ← 10 asLarge.
	 for⦂ i from: [neg⇒[2]1] to: self length do⦂
		[large ← (large*large10)+(self◦i-060)].
	 neg⇒[⇑large negated] ⇑large]\gb8B
asParagraph
	[⇑Paragraph new text: self alignment: 0]\gb13B
asUppercase | s c
	[s ← Stream default.
	for⦂ c from: self do⦂
		[s next ← UpperCase◦(c+1)]
	⇑s contents]\gb12B
asVector
	[⇑self asStream asVector]\gb10B
base8: i  "word: i  in base 8 as a String"
	[⇑(self word: i) base8]\gb10Bi32I
hasBeenUniqued
	[⇑↪a hasInterned: self]\gb16B
printon: strm | x	"print inside string quotes"
	[strm next← 047.
	for⦂ x from: self do⦂
		[strm next← x.
		x=047⇒[strm next← x]]		"imbedded quotes get doubled"
	strm next← 047]\gb14B4i28I84i29I
unique | u		"copy and intern"
	[⇑↪a intern: self]\gb7B5i17I

Compatibility\gbf5 
species
	[⇑String]\gb9B

System primitives\gbf5 
lock [] primitive: 31\gb5B
unlock [] primitive: 32\gb7B
\g
SystemOrganization classify: ↪String under: 'Basic Data Structures'.\g

"Substring"l15000z20000\gbf5 
Class new title: 'Substring'
	subclassof: Array
	fields: 'data map'
	declare: '';
	asFollows\gbf5 

I am an array that consists of a set of elements (specified by map) of an array (data)\gi

Initialization\gbf5 
data: data map: map\gb

Reading and Writing\gbf5 
◦ x
	[⇑data◦(map◦x)]\gb5B
◦ x ← val
	[⇑data◦(map◦x) ← val]\gb11B
length
	[⇑map length]\gb8B
map
	["Return my map."
	⇑map]\gb5B1i16I

Copying and Altering\gbf5 
swap: i with: j | t
	["By permuting my map (a writable Array), swap elements i and j."
	t ← map◦i. map◦i ← map◦j. map◦j ← t.]\gb16B6i64I

Conversion\gbf5 
asStream
	[map isIntervalBy1⇒	"direct stream for simple substrings"
		[⇑Stream new of: data from: map start to: map stop]
	⇑Stream new of: self from: 1 to: map length]\gb10B20i37I

Compatability\gbf5 
species
	[⇑data species]\gb9B
\g
SystemOrganization classify: ↪Substring under: 'Basic Data Structures'.\g

"UniqueString"l15000z20000\gbf5 
VariableLengthClass new title: 'UniqueString'
	subclassof: String
	fields: ''
	declare: '';
	bytesize: 8;
	asFollows\gbf5 

I am a string that is unequal to every other instance of my subclass\gi

Initialization\gbf5 
classInit | i a v		"make up table of 1-char atoms"
	[v ← Vector new: 128. a ← String new: 1.
	for⦂ i to: 128 do⦂
		[a◦1 ← i-1. v◦i ← a unique]
	UST1 ← v]\gb10B9i31I
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
	user notify: 'USTable is jammed']\gb15B12i56I
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
	user notify: 'USTable is jammed']\gb10B195i12I73i27I85i25I89i19I
rehash | oldTable v i
	[oldTable ← USTable.
	 USTable ← Vector new: oldTable length.
	 for⦂ i to: USTable length do⦂
		[USTable◦i ← Vector new: 4].
	 for⦂ v from: oldTable do⦂
		[for⦂ i from: v do⦂
			[i≡nil⇒[] self intern: i]]]\gb7B
str: s | j
	[for⦂ j to: s length do⦂
		[super◦j ← s◦j]
	⇑self]\gb7B
unique\gb

Reading and Writing\gbf5 
◦x ← val
	[user notify: 'UniqueStrings are not for writing into']\gb10B

Selectors\gbf5 
isarrow	 "ends with ←"
	[self length≤1⇒ [⇑false]
	⇑self◦self length=95]\gb9Bi13I
isinfix | x
	[self length≠1⇒ [⇑false]  ⇑(self◦1) isletter≡false]\gb8B
iskeyword | x	"ends with colon"
	[self length≤1⇒ [⇑false]
	x ← self◦self length.
	x=072⇒[⇑true] ⇑x=03]\gb10B4i17I
isuneval | x		"ends with open colon"
	[⇑self◦self length=03]\gb9B5i22I
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
	⇑result contents]\gb10B1i47I
mustTake: nargs "fatal error if I am not a selector that takes nargs arguments"
	[self numArgs≠nargs⇒
		[user notify: self + ' does not take ' + nargs asString + ' arguments']]\gb16Bi63I
numArgs  | len n i "the number of arguments I take when I am a selector"
	[len ← self length.
	len=1⇒ [⇑[(self◦1) isletter⇒ [0] 1]]
	n ← 0. "count colons, dots, and arrows"
	for⦂ i to: len do⦂ [self◦i=072⇒ [n←n+1]; =03⇒ [n←n+1]; =0137⇒[n←n+1]; =07⇒[n←n+1]].
	⇑n]\gb9B10i53I68i32I

Comparison\gbf5 
= x [⇑self≡x]\gb4B
hash [] primitive: 46\gb5B
stringhash
	[⇑super hash]\gb12B

Compatibility\gbf5 
copy [⇑self]\gb5B
recopy [⇑self]\gb7B
species
	[⇑String]\gb9B

Conversion\gbf5 
asString
[⇑super copy]\gb9B
printon: strm
	[strm append: self]\gb15B
\g
SystemOrganization classify: ↪UniqueString under: 'Basic Data Structures'.\g
UniqueString classInit\g

"Vector"l15000z20000\gbf5 
VariableLengthClass new title: 'Vector'
	subclassof: Array
	fields: ''
	declare: '';
	asFollows\gbf5 

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
	⇑ super ◦ x ← val]\gi

Reading and Writing\gbf5 
length "This is actually done in microcode"
	[⇑self length "perform: needs this"]\gb7Bi36I16i21I

Copying and Altering\gbf5 
, x | v
	[v ← self growby: 1.	"use a stream if youre in a hurry"
	v last ← x. ⇑v]\gb4B26i34I

Searching\gbf5 
max| biggest i
	[biggest ← self◦1.	"return largest value in a vector"
	for⦂ i to: self length do⦂
		[(self◦i) > biggest ⇒[biggest ← self◦i]].
	 ⇑biggest]\gb3B32i34I

Conversion\gbf5 
asVector\gb
printon: strm | i
	[strm append: '('.
	for⦂ i to: self length do⦂
		[strm print: self◦i; space]
	strm append: ')' ]\gb14B

System primitives\gbf5 
nail [user croak] primitive: 31		"Nail me in core and return my core address"\gb5B28i
unNail [user croak] primitive: 32		"Release me from being nailed"\gb7B28i

Compiler argument list\gbf5 
argsOff: stack
	[stack pop: self length]\gb16B
emitForValue: code on: stack  | x
	[for⦂ x from: self do⦂ [x emitForValue: code on: stack]]\gb30B
firstPush
	[⇑(self◦1) firstPush]\gb11B
remote: generator  | x
	[for⦂ x from: self do⦂ [x remote: generator]]\gb19B
sizeForValue  | size x
	[size ← 0. for⦂ x from: self do⦂ [size ← size+ x sizeForValue]. ⇑size]\gb14B
\g
SystemOrganization classify: ↪Vector under: 'Basic Data Structures'.\g
