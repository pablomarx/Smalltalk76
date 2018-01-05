'From Smalltalk 5.5k XM November 24 on 22 November 1980 at 2:57:08 am.'

"BitBlt" 
Class new title: 'BitBlt'
	subclassof: Object
	fields: 'function color destbase destraster destx desty
			width height sourcebase sourceraster sourcex sourcey
			sstrike dstrike '
	declare: 'pageOneCursor ';
	asFollows 

BitBlt copies bits from one rectangle to another in core.  x, y, width and height are in bits, raster is in words, and base is a core address.  Mode is storing, oring, xoring or erasing.  If source or destination is a Smalltalk object, then you have to lock it, as in copyToString, below.  The primitive does no bounds checking, so watch out.

Access to Parts 
color  [⇑color]
color ← color
destbase  [⇑destbase]
destbase ← destbase
destraster  [⇑destraster]
destraster ← destraster
destx  [⇑destx]
destx ← destx
desty  [⇑desty]
desty ← desty
dest ← pt [destx← pt x.  desty ← pt y]
dstrike [⇑dstrike]

dstrike ← dstrike

extent ← pt [width ← pt x.  height ← pt y]
function  [⇑function]
function ← function
height  [⇑height]
height ← height
sourcebase  [⇑sourcebase]
sourcebase ← sourcebase
sourceraster  [⇑sourceraster]
sourceraster ← sourceraster
sourcex  [⇑sourcex]
sourcex ← sourcex
sourcey  [⇑sourcey]
sourcey ← sourcey
source ← pt [sourcex← pt x.  sourcey ← pt y]
sstrike [⇑sstrike]

sstrike ← sstrike

width  [⇑width]
width ← width

Setup 
classInit 
	[pageOneCursor ← 0431. "location of hardware cursor"
	]
forCursor
	[function← color← 0.
	destbase← sourcebase← 0431.
	width← height← 16. destraster← sourceraster← 1.
	destx← desty← sourcex← sourcey← 0. sstrike ← dstrike ← false
	]
init 
	[function ← color ← destbase ← destraster ← destx ← desty ← width ←
	height ← sourcebase ← sourceraster ← sourcex ← sourcey ← 0. sstrike ← dstrike ← false
	]

Operations 
callBLT
	[user croak]  primitive: 33
checksandcall | destlocked sourcelocked	
	["checks if either base a string and/or strike and locks accordingly"
		function ← function land: 017.		"set up function to add XM stuff"
	[destbase class ≡ String ⇒
		[destbase◦1 ← destbase◦1.  "set the dirty bit"
		destlocked ← destbase.
			destbase ← ([dstrike ⇒ [((destlocked lock) + 9)]
															destlocked lock	 "strike header"])
		]
	[destbase ≠ pageOneCursor ⇒
	[function ← function + 020. "dest not string, then must be in display"]
		"unless doing cursor work in page one location"]
	].
	[sourcebase class ≡ String ⇒
		[sourcelocked ← sourcebase.
			sourcebase ← ([sstrike ⇒ [((sourcelocked lock) + 9)]
															sourcelocked lock	 "strike header"])
		]
	[sourcebase ≠ pageOneCursor ⇒
	[function ← function + 040. "source not string, then must be in display"]
		"unless doing cursor work in page one location"]
	].
	self callBLT.
	[destlocked ≡ nil ⇒ [] destbase ← destlocked unlock].
	[sourcelocked ≡ nil ⇒ [] sourcebase ← sourcelocked unlock].
	]
copy: mode 
	[function ← mode land: 3. self checksandcall]
copycomp: mode 
	[function ← 4 + (mode land: 3). self checksandcall]
fill: mode color: color 
	[function ← 12 + (mode land: 3). self checksandcall]
paint: mode 
	[function ← 8 + (mode land: 3). self checksandcall]
stringCopy: deststring from: start to: stop with: replacement from: rstart to: rstop
	["copies equal subranges from one string to another.
	works for BitBlt parameters up to 4096. maybe too much set up for short strings.
	currently, called by String copy:to:with:from:to:"
		
	width ← 1+stop-start.
	width = 0⇒ [⇑deststring]

	(start > 4096 or⦂ rstart > 4096) or⦂ width ≥ 4096⇒ [⇑false]
	(width < 0 or⦂ width ≠ (1+rstop-rstart)) or⦂ (
		(start < 1 or⦂ stop > deststring length) or⦂
		(rstart < 1 or⦂ rstop > replacement length))⇒ [
			user notify: 'illegal range or subscript']

	"self init."
	function ← color ← destraster ← desty ← sourceraster ← sourcey ← 0.
	sstrike ← dstrike ← false.
	height ← 1.

	width ← width*8.
	destbase ← deststring lock. 
	destx ← (start - 1) * 8.
	sourcebase ← replacement lock.
	sourcex ← (rstart - 1) * 8.

	self callBLT.

	replacement unlock.
	"mark dirty"
	deststring◦1 ← deststring◦1.
	deststring unlock.
	⇑deststring
	]
stringReplace: deststring with: sourcestring from: start to: stop and: replacement from: rstart to: rstop | slock [
	"works for BitBlt parameters less than 4096. replaces a subrange of a string.
	called only by String replace:to:by:from:to:.  concatenates into deststring:
		sourcestring◦(1 to: start-1)
		replacement◦(rstart to: rstop)
		sourcestring◦(stop+1 to: sourcestring length).
	assumes String arguments"

	deststring length = 0⇒ [⇑deststring]

	(replacement is: String)≡false⇒[⇑false]
	(stop ≥ 4096 or⦂ sourcestring length - stop ≥ 4096) or⦂
		(start+rstop-rstart ≥ 4096 or⦂ rstart > 4096)⇒ [⇑false]

	(start < 1 or⦂ stop > sourcestring length) or⦂
	(rstart < 1 or⦂ rstop > replacement length)⇒ [user notify: 'illegal subscript']

	"self init."
	function ← color ← destraster ← desty ← sourceraster ← sourcey ← 0.
	sstrike ← dstrike ← false.
	height ← 1.

	destbase ← deststring lock. 
	sourcebase ← slock ← sourcestring lock.
	width ← (start - 1) * 8.
	[width = 0⇒ []
	sourcex ← destx ← 0.
	self callBLT].

	destx ← width.
	width ← (1+rstop-rstart)*8.
	[width = 0⇒ []
	sourcex ← (rstart - 1) * 8.
	sourcebase ← replacement lock.
	self callBLT.
	replacement unlock].

	destx ← destx+ width.
	width ← (sourcestring length - stop) * 8.
	[width = 0⇒ []
	sourcebase ← slock.
	sourcex ← stop * 8.
	self callBLT].

	deststring◦1 ← deststring◦1.
	sourcestring unlock. deststring unlock.
	⇑deststring
	]

SystemOrganization classify: ↪BitBlt under: 'Primitive Access'.
BitBlt classInit

"CoreLocs" 
Class new title: 'CoreLocs'
	subclassof: Array
	fields: 'base length'
	declare: '';
	asFollows 

I am an array mapping a section of Alto memory

Initialization 
base: base length: length

Reading and Writing 
◦ x [x isLarge⇒[⇑self◦(x asSmall)] user croak] primitive: 42
◦ x ← val [x isLarge⇒[⇑self◦(x asSmall) ← val] user croak] primitive: 43
base [⇑base]
length [⇑length]

SystemOrganization classify: ↪CoreLocs under: 'Primitive Access'.

"VirtualMemory" 
Class new title: 'VirtualMemory'
	subclassof: Object
	fields: 'map "Pclass Map"
		premap "block before map"
		FirstContextOop "oop of FirstContext"
		SpecialOopsOop "oop of SpecialOops"
		zip  "Zone Index of Pages"
		prezip  "block before zip"
		zadd   "file info"
		vmemfile "file for vmem" '
	declare: 'ZHB RCI PIN zfused zfree zjmpt pmint num00 pmend ZN zflen pmatm zlong PCL ZVPN CPT BSC ISC ZJMP zend ';
	asFollows 

A model of the OOZE virtual memory

Pclass Map 
CPT: oop | poma
	[poma ← 2*(oop field: PCL) +1.
	⇑map◦poma field: CPT]
freelist: object  | a
	["one-order index into freelists."
	object class is: Class ⇒[⇑1]
	a ← self ISC: object asOop.
	a < 024 ⇒[⇑1+a] ⇑1+ a-013]
freelistOffset: len "offset of freelist for this length in a variable length class"
	[⇑Class instsize + [len < 9 ⇒[len] (len-1) log2 + 6]]

highpm0: oop gets: val | poma
	[premap◦pmatm ← premap◦pmatm min: (oop field: PIN ← 0).
	poma ← 2*(oop field: PCL) +1.
	map◦poma ← val]
highPM: oop | pcl a
	[pcl ← oop field: PCL.
	a ← premap◦pmatm field: PCL.
	pcl < a ⇒[⇑false]
	⇑map◦(2*pcl +1)]
ISC: oop | poma
	[poma ← 2*(oop field: PCL) +1.
	⇑map◦poma field: ISC]
lowPM: oop | pcl a
	[pcl ← oop field: PCL.
	a ← premap◦pmend field: PCL.
	pcl ≥ a ⇒[⇑false]
	⇑map◦(2*pcl +1)]
newHighPM← pm0 | pcl a
	[a ← premap◦pmatm.
	premap◦pmatm ← (a ← a-0200).
	pcl ← a field: PCL.
	map◦(2*pcl +1) ← pm0.
	⇑a]
newLowPM← pm0 | poma a
	[map◦1 = pm0 ⇒["reserved pclasses for Class"
		map◦3 = 0 ⇒[map◦3 ← pm0. ⇑0200]
		map◦5 = 0 ⇒[map◦5 ← pm0. ⇑0400] ]
	"normal case"
	a ← premap◦pmend.
	premap◦pmend ← a+0200.
	poma ← (a field: PCL) *2 +1.
	map◦poma ≠ 0 ⇒["skip over already filled"
		⇑self newLowPM← pm0]
	map◦poma ← pm0.
	⇑a]
newZN: oop 
	[self ZN: oop gets: self newZone]
pclassesOf: cls | i clsoop n z p "find pclasses of this class (in order of ZHB)"
	["ignore small integers and nil"
	p ← (Vector new: 1) asStream.
	z ← (Vector new: 1) asStream.
	clsoop ← cls asOop.
	for⦂ i from: (1 to: 2*(0174000 field: PCL) by: 2) do⦂
		[map◦i = 0 ⇒[]
		(map◦i field: RCI) = clsoop ⇒[p next← i/2. z next← (map◦(i+1) field: ZHB)]].
	p ← p contents. z ← z contents.
	n ← p copy.
	for⦂ i to: z length do⦂
		[n◦(z◦i +1) ← p◦i].
	⇑n]
pclassesOf: cls length: len | i clsoop n z p isc pm0 "find pclasses of this class and length (in order of ZHB)"
	["ignore small integers and nil"
	p ← (Vector new: 1) asStream.
	z ← (Vector new: 1) asStream.
	isc ← [len < 9 ⇒[len] (len-1) log2 + 17].
	clsoop ← cls asOop.
	for⦂ i from: (1 to: 2*(0174000 field: PCL) by: 2) do⦂
		[(pm0 ← map◦i) = 0 ⇒[]
		(pm0 field: RCI) ≠ clsoop ⇒[]
		(pm0 field: ISC) = isc ⇒[p next← i/2. z next← (map◦(i+1) field: ZHB)]].
	p ← p contents. z ← z contents.
	n ← p copy.
	for⦂ i to: z length do⦂
		[n◦(z◦i +1) ← p◦i].
	⇑n]
pmatm [⇑premap◦pmatm]
ZHB: oop | poma
	[poma ← 2*(oop field: PCL) +1.
	⇑map◦(1+poma) field: ZHB]
ZHB: oop gets: val | poma i
	[poma ← 2*(oop field: PCL) +1.
	i ← map◦(1+poma).
	map◦(1+poma) ← (i field: ZHB ← val)]
ZN: oop | poma
	[poma ← 2*(oop field: PCL) +1.
	⇑map◦(1+poma) field: ZN]
ZN: oop gets: val | poma i
	[poma ← 2*(oop field: PCL) +1.
	i ← map◦(1+poma).
	map◦(1+poma) ← (i field: ZN ← val)]

Writing and Reading 
obwiz: oop | poma pm0 pm1 isc bsc i len zz pin zhb
	["find (zn, zp, zw, dlen)"
	zz ← Vector new: 4.
	poma ← (oop field: PCL)*2 +1.
	(pm0 ← map◦poma) = 0 ⇒ [user notify: 'bad oop']
	pm1 ← map◦(1+poma).
	isc ← pm0 field: ISC.
	bsc ← pm0 field: BSC.
	zhb ← pm1 field: ZHB.
	[isc < 024 ⇒[len ← ((isc max: 1)+ 1-bsc) / (2-bsc)]
		len ← 8. i ← isc+bsc.
		until⦂ 024 = i do⦂ [i ← i-1. len ← len*2]
		len ← len+1 "length word" ].
	zz◦4 ← len ← len+1. "dlen with refct"
	"w ← (dlen*128*zhb) +dlen*pin"
	pin ← oop field: PIN.
	zz◦2 "zp" ← (zhb/2 *len) +(len/256 *pin).
	zz◦3 "zw" ← (zhb\2 *128 *len) +(len\256 *pin).
	zhb\2 * len ≥ 512 ⇒[user notify: 'address overflow']
	zz◦2 "zp" ← zz◦2 + (zz◦3 field: 136 "highbyte").
	zz◦3 "zw" ← zz◦3 field: 128 "lowbyte".
	zz◦1 ← pm1 field: ZN.
	⇑zz]
readin: oop | zinfo
	[zinfo ← self obwiz: oop.
	⇑self read: zinfo◦4 at: zinfo]
systemNoHistory [] primitive: 82
writeout: oop with: image | zinfo
	[zinfo ← self obwiz: oop.
	[zinfo◦4 ≥ (image length /2) ⇒[]
		user notify: 'bad image length'].
	self write: image at: zinfo
	]

Init 
AComment
	["VirtualMemory models the Pclass Map of Ooze.
	Vmem is one with CoreLocs on real system.
		(VirtualMemory new) thisvmem.
	Pmap is new one we are building.
		(VirtualMemory new) fakevmem.
	map is 1-order addressing.
	In init, set pmatm by searching PM for
	highest 0. (No LMAT)
	map RCI field is old class oop. only convert to 
		new with mapPM at end.
	Atoms may not cover more than half of the
		address space. (highpm0:gets:)
	(VirtualMemory new) giveBirth.
	Zone Index of Pages. works for both vector zip
	and corelocs of real zip.
	zip, zadd are one-order.
	zfree is 1-order in fake, core addr in this.
	zlong = 512.
	zend is not used (0 fake, core addr in this) 
	"]
fakevmem: vmemfile
	["this instance is a model of a new vmem, which is built on another file"
	self init.
	map ← Vector new: 1024.
	map all ← 0.
	premap ← (0176000, 0174000, 0, 0).
			"num00, pmint, pmatm, pmend"
	prezip ← (3, 01244, 0). "zfree, zlong, zend"
	zip ← Vector new: prezip◦zlong.
	zip all ← 0.
	zadd ← (1, 1).  "zfused, zflen"
	vmemfile readwrite.
	Smalltalk define: ↪Pmap as: self]
init  "common to both real and fake vmem"
	["field descriptors and indicies in tables"
	num00 ← 1. pmint ← 2. pmatm ← 3. pmend ← 4.
	RCI ← 151. CPT ← 22. BSC ← 21. ISC ← 80.
	ZHB ← 136. ZN ← 128. 
	PCL ← 151. PIN ← 112.
	ZJMP ← 76. ZVPN ← 16*12.
	zfree ← 1. zlong ← 2. zend ← 3.
	zfused ← 1. zflen ← 2.
	zjmpt ← (603, 570, 471, 410, 353, 300, 253, 
		210, 169, 132, 101, 72, 49, 30, 13)]
premap [⇑premap] "array of limits in Pclass Map"
thisvmem | c m "create Vmem, a VirtualMemory viewing this very system"
	[c ← self specialLocs.
	map ← CoreLocs new base: c◦2 -1 length: 1025.
	premap ← CoreLocs new base: c◦2 -5 length: 5.
	Smalltalk define: ↪Vmem  as: self.
	self init.
	m ← 1023.
	until⦂ (map◦m = 0) do⦂ [m ← m-2].
	premap◦pmatm ← (0 field: PCL ← m/2 +1).
	prezip ← CoreLocs new base: c◦3 -4 length: 4.
	zip ← CoreLocs new base: c◦3 -1 length: prezip◦zlong+1.
	zadd ← CoreLocs new base: c◦12 -3 length: 3.
	(vmemfile ← dp0 oldFile: 'small.boot') readonly.
	FirstContext ← Context new sender: nil 
		receiver: user
		method: (m ← UserView md method: ↪restart) 
		tempframe: (Vector new: (m◦3 max: m◦4)) pc: m◦6
		stackptr: m◦5 -1.
	SpecialOops◦1 ← Object md method: ↪error.
	FirstContextOop ← FirstContext asOop.
	SpecialOopsOop ← SpecialOops asOop]

Vmem Writing 
afterBirth [MethodKeeperKeeper ← nil]
giveBirth | pm0 vm "initialize map for early pclasses"
	[self preBirth.
	"small Integer, 16 pclasses, oops 0174000-0177777"
		pm0 ← Vmem highPM: 0176000. "size, class info for Integer"
		until⦂ (Pmap newHighPM← pm0) = 0174000 do⦂ []. 
	"first UniqueString"
		(vm ← Vmapper new) object: (0173600 asObject); touchoop.
	"Class oops 0-0177"
		vm object: Class; touchoop.
	"more Class oops 0200-0577"
		Pmap newLowPM← 0; newLowPM← 0.
	"VariableLengthClass oops 0600-0777"
		vm object: Vector; touchoop.
	"skip over some oops"
		until⦂ (Pmap newLowPM← 0) = 01600 do⦂ [].
	"Object oops 02000-02177, false=02000"
		(vm object: false) map ≠ 02000 ⇒[user notify: 'bad false oop']
	"set pointer back to oops skipped over"
		Pmap premap ◦ pmend ← 01000
	]
giveBirth2 | vm
	[vm ← Vmapper new.
	vm object: (Smalltalk ref: ↪FirstContext).
	FirstContextOop ← (vm readin word: 2). "new oop of FirstContext"
	vm reset; object: (Smalltalk ref: ↪SpecialOops).
	SpecialOopsOop ← (vm readin word: 2). "new oop of SpecialOops"]
giveBirth3 | vm p ["create a new Small.boot
	Write out all objects rooted at Smalltalk.
	Do not write the stack (rooted in R76, the current context).
		Pmap file close. Pmap ← nil.

	*** Below is the commmand to start a Vmem write on a Dorado
		(or Alto -- double disk O.S.).  edit and recompile the method if you don't
		want to use old UniqueStrings, or if newsmall.boot, smalltalk.run,
		smalltalk.syms, byterp.mb are not located on dp0i,
		i.e. dp1 oldFile: 'small.boot' instead of dp0 oldFile: 'newsmall.boot'.
		also delete rename: commands at the end.

		user displayoffwhile⦂ [(VirtualMemory new) giveBirth3]. user quit.

	***"

	user releaseExternalViews.
	[E≡nil⇒ [] E kill].
	Flushed← false.
	(Vmapper new) init; UseOldUniqueStrings: true.
	user show: 'init '.
	(VirtualMemory new) thisvmem.  "define Vmem, Pmap"
	(VirtualMemory new) fakevmem: (dp0 oldFile: 'newsmall.boot').
	self giveBirth.
	vm ← Vmapper new.
	user show: 'run '. vm object: Smalltalk; map.
	user show: 'USTable '. vm arefsRectify.
	user show: 'freelist '. vm writefreelists.
	user show: 'mrefs '. vm mrefsRectify.
	user show: 'PM '. Pmap mapPM; giveBirth2.

	"These work as many times as needed on dp0 or dp1"
	user show: 'surgery '.
	Pmap surgery: (dp0 oldFile: 'Smalltalk.Run').
	user show: 'ram '.
	Pmap ramwrite: (dp0 oldFile: 'Byterp.Mb').

	"adjust size of new file"
	p ← Pmap pagesUsed + 264 "boot & ram" + 250 "extra".
	user show: 'pages reclaimed '; print: (Pmap file) file lastPage - p.
	(Pmap file) readwriteshorten; settopage: p char: 0; close; readwrite.

	"rename files so that new file is small.boot"
	(Vmem file) file rename: 'oldsmall.boot'.
	(Pmap file) file rename: 'small.boot'.
	]
mapPM | c i v rci ctrans  "convert to new RCI"
	[ctrans ← (Vmapper new) classtrans.
	for⦂ c from: (1 to: 1023 by: 2) do⦂
		[(i ← map◦c) = 0 ⇒[]
		rci ← i field: RCI.
		(v ← ctrans lookup: rci) ⇒
			[map◦c ← (i field: RCI ← v◦1)]
		user notify: 'class not mapped']
	]
preBirth | v
	[MethodKeeperKeeper ← MessageDict new.
	MethodKeeperKeeper init: (v ← MethodKeeper contents) length *2; holdMethods: v]
ramwrite: source | s "write 8 pages of ram image into small.boot" [
	s ← source name.
	source readonly.
	[source directory ≡ dp0 ⇒[]
	(dp0 file: s) append: source; close "copy onto dp0"].
	source close.

	"cleanup vmem file before quit"
	vmemfile close.

	"go out to OS, packram, and come back"
	s ← s◦(1 to: s length-4) concat: '.br.'.
	user quitThen: [
		(Stream default) append: 'Packmu ';
			append: source name; space; append: s;
			append: '; Resume '; append: Vmem file name;
			contents].  

	"skip .br stuff and constants"
	(s ← dp0 oldFile: s) readonly; skipwords: 0421.
	"now write in ram image (8 pages of 512)"
	vmemfile settopage: 0400 char: 0; readwrite; next: 4096 from: s.
	s close.
	self ≡ Vmem ⇒[vmemfile readonly "does flush"]
	vmemfile flush]

Surgery 
dynaLocs: guide | l locs keys v i "Surgery - add core location and value pairs to guide dictionary to test after flush"
	[l ← self specialLocs.
	locs ← (premap base +pmend, (l◦11 -1), (l◦12 -2), (l◦4 +1)).
	keys ← (↪premaptest, ↪purgetest, ↪zaddtest, ↪loxtest).
	for⦂ i from: 1 to: keys length do⦂
		[v ← locs◦i, (mem◦(locs◦i)).
		guide insert: keys◦i with: v].
	(guide lookup: ↪loxtest)◦2 ← ¬1]
runLocs: f | guide i v locs keys offsets "Surgery - create dictionary of locations of key system tables in Smalltalk.run"
	[i ← f name.
	(v ← f directory oldFile: (i◦(1 to: i length-5) concat: '.syms.')) readonly.
	locs ← self symsFind: ('PMBASE', 'ZIP', 'ZADD', 'INITIALIZE', 'OOZIN', 'SAFID') on: v.
	v close.

	keys ← ↪(maprun ziprun zaddrun initrun zfps safid).
	offsets ← ↪(¬1 ¬1 ¬3 ¬3 ¬2 ¬1). "words offset"
	guide ← Dictionary new init: 16.
	for⦂ i from: 1 to: locs length do⦂
		[v ← (locs◦i lshift: ¬8), ((locs◦i land: 0377) -19 *2). "page, byte"
		"magic fudge factor of 19 words for .run file"
		v◦2 ← v◦2 +(offsets◦i *2). "bytes offset"
		guide insert: keys◦i with: v].
	v ← (guide lookup: ↪maprun) copy.
	v◦2 ← v◦2 +(¬4 *2).  "offset ¬5 total"
	guide insert: ↪premaprun with: v.
	v ← (guide lookup: ↪ziprun) copy.
	v◦2 ← v◦2 +(¬3 *2).  "offset ¬4 total"
	guide insert: ↪preziprun with: v.
	⇑guide]
specialLocs [] primitive: 84
"returns a vector containing the core addresses of:
	1 ROTBASE (the Resident Object Table)
	2 PMBASE (the Pclass Map)
	3 ZIP (the Zone Index of Pages)
	4 LOX (the table of LOcked objeX)
	5 FULL (loc of lowest addr used for resident data)
	6 ULIM (loc of highest addr used for resident data)
	7 ZFPT (the zone file Page Table)
	8 OVTAB (the Table of OVerflow ref counts)
	9 PURGE (a code label)
	10 DISPGLBS (Table of Display Globals)
	11 BACPUR (a code label)
	12 ZADD (.-2 has #pages req'd, .-1 has #pages in boot file; add 264 for real file length)
	13 SAFID (loc of file id (5-word block) for the .boot file)
"
staticTest: guide on: f | l locs offsets values names i v "Surgery - test known static constants in thisvmem and in smalltalk.run"
	[offsets ← (pmint, 2, 0, 0).
	values ← (0174000, 01244, 96, 031415).
	names ← (↪premaprun, ↪preziprun, ↪zaddrun, ↪initrun).
	for⦂ i to: names length do⦂
		[v ← guide lookup: names◦i.
		f settopage: v◦1 char: v◦2 +(offsets◦i *2).
		f nextword ≠ (values◦i)⇒
		[user notify: 'bad .run loc']].
	self ≡ Vmem ⇒
		[l ← self specialLocs.
		offsets◦4 ← 0.  values◦4 ← 014764.	
		locs ← (premap base, prezip base, zadd base, (l◦11) "bacpur").
		for⦂ i from: 1 to: locs length do⦂
			[values◦i ≠ (mem◦(locs◦i +(offsets◦i)))⇒
			[user notify: 'bad system loc']]]
	]
surgery: f | guide Etemp i v keys [
	"write virtual memory tables into Smalltalk.run using Smalltalk.syms.
	user displayoffwhile⦂ [Vmem ramwrite: (dp0 oldFile: 'byterp.mb')].
	user displayoffwhile⦂ [Vmem surgery: (dp0 oldFile: 'Smalltalk.run')]. "

	vmemfile close.
	user releaseExternalViews.
	[E ≡ nil ⇒[] E kill].

	[self ≡ Vmem ⇒[self thisvmem.
		Flushed ← true. Etemp ← Events]].
	f readwrite.
	guide ← self runLocs: f.
	self staticTest: guide on: f.
	[self ≡ Vmem ⇒[user clearshow: 'Wait for the safe light to flash, then hit any key'.
		until⦂ user kbck do⦂ []. user kbd.
		self dynaLocs: guide.
		user clearshow: 'Dont forget user systemStartup. in the new system to enable interrupts and get the display set up. '.
]].
	self tablewrt: guide on: f. "write in Smalltalk.run"
	f close.

	self ≡ Vmem ⇒
		[keys ← (↪premaptest, ↪purgetest, ↪zaddtest, ↪loxtest).
		for⦂ i to: keys length do⦂
			[v ← guide lookup: keys◦i.
			v◦2 ≠ (mem◦(v◦1))⇒[user notify: 'please surgery again']].
		Events ← nil. self systemVmemOut.
		Events ← Etemp.
		vmemfile close.
		user quit]
	]
symsFind: strs on: f1 | f2 S N L offset val str j i "find initial values of SRELs in smalltalk.syms"
	["S is start of string space (words)
	N is start of symbol table "
	(f2 ← f1 directory oldFile: f1 name) readonly.
	f1 wordposition ← 2.
	S ← f1 nextword.
	N ← f1 nextword.
	f1 wordposition ← N.
	L ← f1 nextword.
	for⦂ i to: L do⦂
		[offset ← f1 nextword. "next offset"
		f1 skip: 4.
		val ← f1 nextword.
		f2 wordposition ← S+offset.
		str ← f2 next: f2 next.
		for⦂ j to: strs length do⦂
			[(strs◦j) class ≡ String ⇒
				[strs◦j = str ⇒[strs◦j ← val]]].
		].
	f2 close.
	for⦂ j to: strs length do⦂
		[(strs◦j) class ≡ String ⇒
			[user notify: 'symbol not found']].
	⇑strs]
systemVmemOut [] primitive: 83
tablewrt: guide on: f | i v vfile "copy tables from self to .run file"
	[v ← guide lookup: ↪premaprun.
	f settopage: v◦1 char: v◦2 +(2*pmatm).
	f nextword← premap◦pmatm.
	f nextword← premap◦pmend.
	for⦂ i to: 1024 do⦂ [f nextword← map◦i].
	v ← guide lookup: ↪preziprun.
	f settopage: v◦1 char: v◦2 +(2*1 "zfree").
	i ← [self ≡ Vmem ⇒ [¬1-zip base "relative indexing"]¬1 "make 0-order"] .
	f nextword← prezip ◦1 +i. "zfree"
	v ← guide lookup: ↪zaddrun.
	f settopage: v◦1 char: v◦2 +(2*1 "zfused").
	f nextword← zadd ◦1. " zfused "
	v ← guide lookup: ↪ziprun.
	f settopage: v◦1 char: v◦2 +(2*1).
	for⦂ i to: prezip◦zlong do⦂ [f nextword← zip◦i]
	v ← guide lookup: ↪initrun.
	f settopage: v◦1 char: v◦2 +(2*1 "SpecialOops").
	f nextword← SpecialOopsOop.
	f nextword← FirstContextOop.

	"disk address of start of virtual memory"
	vfile ← vmemfile file.
	v ← guide lookup: ↪zfps.
	f settopage: v◦1 char: v◦2 +(2*1).
	f nextword← (vfile read: 0410) address.

	"swat file id of vmem file"
	v ← guide lookup: ↪safid.
	f settopage: v◦1 char: v◦2 + (2*1).
	f append: vfile serialNumber; skip: 4; nextword ← (vfile read: 1) address.
	]

Zone Pages 
cover: zz | pp zrp lpir zjmp vpn olpir
	[pp ← zz◦2 + 1. "zp 1-order"
	lpir ← 1. olpir ← 0. zrp ← zz◦1 *2 +1.
	until⦂ lpir ≥ pp do⦂ [
		0 = (zjmp ← zip◦zrp field: ZJMP) ⇒
			[self run: [lpir ≥ 32 ⇒[32] lpir +1] after: zrp.
			self cover: zz]
		zrp ← (zjmpt◦zjmp + zrp -1)\ (prezip◦zlong) +1.
		olpir ← lpir.
		lpir ← lpir + [lpir ≥ 32 ⇒[32] lpir +1] ].
	vpn ← (zip◦zrp field: ZVPN) +pp -(olpir +1).
	0 = vpn ⇒[user notify: 'pclass has no zone']
	vpn ← vpn + 0407.
	vmemfile settopage: vpn char: zz◦3 *2]
file [⇑vmemfile]
getpages: i | vpn
	[[zadd◦zflen < (zadd◦zfused + i) ⇒
		[zadd◦zflen ← zadd◦zflen + (i max: 20).
		vmemfile settopage: zadd◦zflen + 0407 char: 0]].
	vpn ← zadd◦zfused.
	zadd◦zfused ← vpn+i.
	⇑vpn]
newZone | zrp
	[zip is: Vector ⇒[
	zrp ← prezip◦zfree.
	until⦂ zip◦zrp = 0 do⦂ [zrp > (prezip◦zlong) ⇒
		[user notify: 'zip overflow']
		zrp ← zrp+2].
	prezip◦zfree ← 2+zrp.
	zip◦zrp ← self getpages: 1.
	⇑zrp/2]]
pagesUsed [⇑zadd◦zfused]
read: len at: zz | i str
	[i ← 256 - (zz◦3) "zw" min: len.
	self cover: zz.
	str ← vmemfile next: 2*i.
	i=len ⇒[⇑str]
	zz◦2 ← zz◦2 +1. "zp"
	zz◦3 ← 0. "zw"
	⇑str concat: (self read: len-i at: zz)]
run: n after: zrp | i j
	[for⦂ i to: 15 do⦂ 
		[j ← zjmpt◦i +zrp -1 \ (prezip◦zlong) +1.
		zip◦j = 0 ⇒
			[zip◦zrp ← zip◦zrp field: ZJMP ← i.
			zip◦j ← self getpages: n. ⇑zrp]
		].
	user notify: 'new zip is full']
write: str at: zz | i len
	[len ← str length /2.
	i ← 256 - (zz◦3) "zw" min: len.
	i = len ⇒[
		self cover: zz.
		vmemfile append: str]
	self write: str from: 1 at: zz]
write: str from: pos at: zz | i len
	[len ← str length +1 -pos.  "bytes yet to write"
	i ← len min: (256 - (zz◦3) "zw")*2.  "bytes in page"
	self cover: zz.
	vmemfile append: str◦(pos to: i+pos-1).
	i=len ⇒[]
	zz◦2 ← zz◦2 +1. "zp"
	zz◦3 ← 0. "zw"
	self write: str from: i+pos at: zz]

SystemOrganization classify: ↪VirtualMemory under: 'Primitive Access'.

"Vmapper" 
Class new title: 'Vmapper'
	subclassof: Object
	fields: 'object oop noop image'
	declare: 'classtrans PCL mapqueue clamp stopcount USTableOop mrefs arefs count UseOldUniqueStrings ';
	asFollows 

This class has not yet been commented

Mapping 
map | i
	[(i ← mrefs lookup: oop) ⇒[i◦1 ← i◦1 -1. ⇑i◦2]
	[user kbck ⇒ [user kbd; ev] self bump].
	object class = Integer ⇒[⇑self mapInteger];
	= UniqueString ⇒[⇑self mapUniqueString];
	= Vector ⇒[⇑self mapVector];
	= Float ⇒[⇑self mapFloat];
	= MessageDict ⇒[⇑self mapMdict]
	object Is: HashSet ⇒[⇑self mapHashSet]
	object Is: String ⇒[⇑self mapString]
	object class = Class ⇒[⇑self mapClass];
	= VariableLengthClass ⇒[⇑self mapClass];
	= Vmapper ⇒[⇑¬1]; "avoid recursion in writing"
	= VirtualMemory ⇒[⇑self mapVmem]; "avoid recursion in writing"
	"put any fixed octave class here"
	= Object ⇒[⇑self mapObject]
	⇑self mapNormal]
mapClass | nlen oadd i refs vm j
	[clamp find: object ⇒[⇑¬1 "don't write this class"]
	nlen ← 1 + object class instsize. "refct + normal fields"
	i ← [object is: Class ⇒[oadd ← 0. 1] oadd ← 1. 20].
	noop ← self newoop.
	[(vm ← classtrans lookup: oop) ⇒[vm◦1 ← noop]
		vm ← Vector new: i+1. vm◦1 ← noop.
		classtrans insert: oop with: vm].
	nlen ← nlen + i + oadd.
	image ← String new: 2*nlen.
	[(refs ← object refct) = 2 ⇒["exactly one reference"]
		mrefs insert: oop with: (refs-2, noop)].
	image word: 1 ← refs -2.
	[oadd=1 ⇒[image word: 2 ← nlen-2]].
	for⦂ j from: (2+oadd to: nlen-i) do⦂ 
		[vm ← Vmapper new object: (object instfield: j-1-oadd).
		image word: j ← vm map].
	self writeout.
	⇑noop]
mapFloat | refs i
	[image ← String new: 8.
	noop ← self newoop.
	[(refs ← object refct) = 2 ⇒["exactly one reference"]
		mrefs insert: oop with: (refs-2, noop)].
	image word: 1 ← refs-2.
	for⦂ i to: 3 do⦂ [image word: (i+1) ← object instfield: i].
	self writeout.
	⇑noop]
mapHashObs  | nlen oadd i refs vm trans ob
	[nlen ← object length. "in words"
	oadd ← [nlen≤8⇒[0]1].
	nlen ← oadd +1 +nlen.
	image ← String new: 2*nlen.
	[(refs ← object refct) = 2 "exactly one ref" ⇒
		[noop ← self newoop]
		(i ← mrefs lookup: oop) ⇒[i◦1 ← i◦1 -1. noop ← i◦2]
		noop ← self newoop.
		mrefs insert: oop with: (refs-2, noop)].
	image word: 1 ← refs -2.
	[oadd=1⇒[image word: 2 ← object length]].
	ob ← (trans ← self permHashSet) objects.  "translation dictionary"
	for⦂ i from: (2+oadd to: nlen) do⦂ 
		[vm ← ob◦(i-1-oadd).  "integer noops"
		vm ≡ nil ⇒[] image word: i ← vm].
	self writeout.
	⇑noop, trans values]
mapHashSet | nlen i refs vm perm  "all subclass on HashSet except Mdict"
	[mrefs asOop = oop ⇒[⇑¬1] "do not map"
	arefs asOop = oop ⇒[⇑¬1] "do not map"
	nlen ← 1 + (object class instsize). "refct + fields"
	image ← String new: 2*nlen.
	noop ← self newoop.
	[(refs ← object refct) = 2 ⇒["exactly one reference"]
		mrefs insert: oop with: (refs-2, noop)].
	image word: 1 ← refs -2.
	vm ← Vmapper new object: (object instfield: 1).
	i ← vm mapHashObs.  "(oop, perm)"
	image word: 2 ← i◦1.
	perm ← i◦2.  "permutation of other parts"
	for⦂ i from: (3 to: nlen) do⦂ 
		[vm ← Vmapper new object: (object instfield: i-1).
		image word: i ← (vm mapHashVals: perm)].
	self writeout.
	⇑noop]
mapHashVals: perm | nlen oadd i refs vm  "values vec of dictionary"
	[oop = ¬1 ⇒[⇑¬1]
	nlen ← object length. "in words"
	oadd ← [nlen≤8⇒[0]1].
	nlen ← oadd +1 +nlen.
	image ← String new: 2*nlen.
	[(refs ← object refct) = 2 "exactly one ref" ⇒
		[noop ← self newoop]
		(i ← mrefs lookup: oop) ⇒[i◦1 ← i◦1 -1. noop ← i◦2]
		noop ← self newoop.
		mrefs insert: oop with: (refs-2, noop)].
	image word: 1 ← refs -2.
	[oadd=1⇒[image word: 2 ← object length]].
	object ← object◦perm.
	for⦂ i from: (2+oadd to: nlen) do⦂ 
		[(vm ← Vmapper new) object: object◦ (i-1-oadd).
		image word: i ← vm map].
	self writeout.
	⇑noop]
mapInteger | refs
	[¬02000 ≤ object and: object < 01777 ⇒
		[⇑oop "small integer"]
	image ← String new: 4.
	noop ← self newoop.
	[(refs ← object refct) = 2 ⇒["exactly one reference"]
		mrefs insert: oop with: (refs-2, noop)].
	image word: 1 ← refs-2.
	image word: 2 ← object.
	self writeout.
	⇑noop]
mapMdict | i refs vm perm  " maps MessageDict instance "
	[image ← String new: 12.
	noop ← self newoop.
	[(refs ← object refct) = 2 ⇒["exactly one reference"]
		mrefs insert: oop with: (refs-2, noop)].
	image word: 1 ← refs -2.
	(vm ← Vmapper new) object: (object instfield: 1).
	i ← vm mapHashObs.  "(oop, perm)"
	image word: 2 ← i◦1.
	perm ← i◦2.  "permutation of other parts"
	for⦂ i from: (3 to: 6) do⦂ 
		[(vm ← Vmapper new) object: (object instfield: i-1).
		i = 3 ⇒[image word: 3 ← (vm mapMethodVec: perm)]
		image word: i ← (vm mapHashVals: perm)].
	self writeout.
	⇑noop]
mapMethod | nlen oadd refs i a vm b
	[oop = ¬1 ⇒[⇑¬1]
	nlen ← object length. "in bytes!!"
	oadd ← [nlen≤8⇒[0]1].
	nlen ← 2*oadd +2 +nlen.
	image ← String new: nlen+1 |2.
	[(refs ← object refct) = 2 "exactly one ref" ⇒
		[noop ← self newoop]
		(i ← mrefs lookup: oop) ⇒[i◦1 ← i◦1 -1. noop ← i◦2]
		noop ← self newoop.
		mrefs insert: oop with: (refs-2, noop)].
	image word: 1 ← refs -2.
	[oadd=1⇒[image word: 2 ← object length]].
	[nlen ≤ 8 or⦂ object◦6 = 6 ⇒
		[image◦(2*oadd +3 to: nlen) ← object]
		a ← 2*oadd +3. b ← object◦6.
		image◦(a to: a+5) ← object◦(1 to: 6).
		for⦂ i from: (4 to: b /2) do⦂
			[(vm ← Vmapper new) object: (object word: i) asObject.
			image word: (i+1+oadd) ← vm map].
		image◦(a+b to: nlen) ← object◦(b+1 to: object length)].
	self writeout.
	⇑noop]
mapMethodVec: perm | nlen oadd i refs vm
	[oop = ¬1 ⇒[⇑¬1]
	nlen ← object length. "in words"
	oadd ← [nlen≤8⇒[0]1].
	nlen ← oadd +1 +nlen.
	image ← String new: 2*nlen.
	[(refs ← object refct) = 2 "exactly one ref" ⇒
		[noop ← self newoop]
		(i ← mrefs lookup: oop) ⇒[i◦1 ← i◦1 -1. noop ← i◦2]
		noop ← self newoop.
		mrefs insert: oop with: (refs-2, noop)].
	image word: 1 ← refs -2.
	[oadd=1⇒[image word: 2 ← object length]].
	object ← object◦perm.
	for⦂ i from: (2+oadd to: nlen) do⦂ 
		[(vm ← Vmapper new) object: object◦ (i-1-oadd).
		image word: i ← vm mapMethod].
	self writeout.
	⇑noop]
mapNormal | nlen i refs vm oadd "all fixed, pointer type classes"
	[clamp find: object class ⇒[⇑¬1 "don't write the instance"]
	nlen ← object class instsize.
	oadd ← [nlen≤19⇒[0]1].
	nlen ← oadd+1 +nlen.
	image ← String new: 2*nlen.
	noop ← self newoop.
	[(refs ← object refct) = 2 ⇒["exactly one reference"]
		mrefs insert: oop with: (refs-2, noop)].
	image word: 1 ← refs-2.
	[oadd=1⇒[image word: 2 ← nlen-oadd-1]].
	for⦂ i from: (2+oadd to: nlen) do⦂ 
		[vm ← Vmapper new object: (object instfield: i-oadd-1).
		image word: i ← vm map].
	self writeout.
	⇑noop]
mapObject | refs  "nil, false, true"
	[object≡nil ⇒
		[mrefs insert: ¬1 with: (500, ¬1). "for speed of
		catching nil. watch out on cleanup" ⇑¬1]
	image ← String new: 4.
	noop ← self newoop.
	noop\128>1 ⇒
		[user notify: 'Unidentified flying Object']
	[(refs ← object refct) = 2 ⇒["exactly one reference"]
		mrefs insert: oop with: (refs-2, noop)].
	image word: 1 ← refs -2.
	self writeout.
	⇑noop]
mapString | nlen oadd refs
	[nlen ← object length. "in bytes!!"
	oadd ← [nlen≤8⇒[0]1].
	nlen ← 2*oadd +2 +nlen.
	image ← String new: nlen+1 |2.
	noop ← self newoop.
	[(refs ← object refct) = 2 ⇒["exactly one reference"]
		mrefs insert: oop with: (refs-2, noop)].
	image word: 1 ← refs -2.
	[oadd=1⇒[image word: 2 ← object length]].
	image◦((2*oadd +3) to: nlen) ← object.
	self writeout.
	⇑noop]
mapUniqueString | nlen oadd refs
	[[UseOldUniqueStrings ⇒[self UniStroop. noop ← oop]
		(refs ← arefs lookup: oop) ⇒[⇑refs]
		noop ← self newoop.
		arefs insert: oop with: noop].
	nlen ← object length. "in bytes!!"
	oadd ← [nlen≤8⇒[0]1].
	nlen ← 2*oadd +2 +nlen.
	image ← String new: nlen+1 |2.
	image word: 1 ← 1.
	[oadd=1⇒[image word: 2 ← object length]].
	image◦((2*oadd +3) to: nlen) ← object.
	self writeout.
	⇑noop]
mapVector | nlen oadd i refs vm
	[[UseOldUniqueStrings ⇒[] USTableOop = oop ⇒[⇑¬1]
		"do not map since new atom Oops"]. 
	nlen ← object length. "in words"
	oadd ← [nlen≤8⇒[0]1].
	nlen ← oadd +1 +nlen.
	image ← String new: 2*nlen.
	noop ← self newoop.
	[(refs ← object refct) = 2 ⇒["exactly one reference"]
		mrefs insert: oop with: (refs-2, noop)].
	image word: 1 ← refs-2.
	[oadd=1⇒[image word: 2 ← object length]].
	for⦂ i from: (2+oadd to: nlen) do⦂ 
		[vm ← Vmapper new object: (object◦ (i-1-oadd)).
		image word: i ← vm map].
	self writeout.
	⇑noop]
mapVmem | nlen i refs vm  "VirtualMemory, Vmem and Pmap"
	[nlen ← 1 + (object class instsize). "refct + fields"
	image ← String new: 2*nlen.
	noop ← self newoop.
	[(refs ← object refct) = 2 ⇒["exactly one reference"]
		mrefs insert: oop with: (refs-2, noop)].
	image word: 1 ← refs -2.
	for⦂ i from: (2 to: nlen) do⦂ 
		[image word: i ← ¬1]. "Vmem needed for purgealittle"
	self writeout.
	⇑noop]
permHashSet | ob i bb nili vm   "gets new atoms, returns dict of objects and permutation"
	[bb ← Dictionary new init: object length.
	i ← 1. while⦂ (object◦i ≡ nil and: i ≠ object length) do⦂ [i ← i+1].
	[((object◦i) class) ≡ Integer ⇒[false]; ≡ String ⇒[false] true] ⇒
		[for⦂ i to: object length do⦂
			[object◦i ≡ nil ⇒[nili ← i]
			vm ← Vmapper new object: object◦i.
			bb insert: vm map with: i].
		ob ← bb values.
		for⦂ i to: ob length do⦂
			[ob◦i ≡ nil ⇒[ob◦i ← nili] ].
		⇑bb]
	ob ← bb objects.
	for⦂ i to: ob length do⦂
		[vm ← Vmapper new object: object◦i.
		ob◦i ← vm map].
	ob ← bb values.
	for⦂ i to: ob length do⦂
		[ob◦i ← i].
	⇑bb]

Writing Out 
method: sel | v str a j i   "object is a class. find this method and construct vmapper"
	[(v ← classtrans lookup: oop) ≡ false ⇒[user notify: 'object not a class']
	str ← Pmap readin: v◦1. "class image"
	i ← Pmap readin: (str word: 1+4+(oop/0200)). "mdict image"
	str ← Pmap readin: (i word: 1+1). "objects vector image"
	a ← String new: 2. a word: 1 ← sel asOop. "selector"
	j ← str find: a◦2. 
	a◦1 ≠ (str◦(j-1)) ⇒[user notify: 'can not find']
	i ← Pmap readin: (i word: 1+2). "methods vector image"
	v ← Vmapper new object: (object md method: sel).
	v noop: (i word: (j/2)). v readin.
	⇑v]
newoop | v a i indx o "see if classtrans can help find new oop"
	[(v ← classtrans lookup: (i ← object class) asOop) ⇒
		[indx ← 1 + (Vmem freelist: object).
		 [i ≡ Class ⇒[oop ≤ 027 ⇒[⇑oop] "touchoop set it up"
				v◦indx ≤ 027 ⇒[v◦indx ← 027+1] ];
			≡ VariableLengthClass ⇒[o ← v◦indx. "in case pclass changes"
				v◦indx ← o max: o|128 +(oop\128) +1. 
				⇑ o|128 +(oop\128)] ].
		a ← self nextfree: v◦indx.
		v◦indx ← a◦2. ⇑a◦1]
	 a ← [i is: Class ⇒[1] 20].
	 v ← Vector new: a+1.
	 classtrans insert: (object class) asOop with: v.
	 ⇑self newoop]
newpcl: n | a pm0
	["object class = Foo ⇒[an exception]"
	pm0 ← Vmem lowPM: oop.
	a ← [pm0 ⇒[Pmap newLowPM← pm0]
			Pmap newHighPM← (Vmem highPM: oop)].
	n=¬1 ⇒[Pmap newZN: a. Pmap ZHB: a gets: 0. ⇑a]
	Pmap ZN: a gets: (Pmap ZN: n).
	Pmap ZHB: a gets: 1 + (Pmap ZHB: n).
	⇑a]
nextfree: n | a
	[n≡nil ⇒[n ← self newpcl: ¬1.
		⇑(n, (n+1))]
	n\0200 = 0177 ⇒[a ← self newpcl: n.
		⇑(n, a)]
	⇑(n, (n+1))]
object: object
	[oop ← object asOop]
readin | v  "read object off vmemfile and return image"
	[[noop ≡ nil ⇒[(v ← mrefs lookup: oop) ⇒[noop ← v◦2] 
		user notify: 'can not find new oop']].
	⇑image ← Pmap readin: noop]
writeout
	["write image of object on file"
	Pmap writeout: noop with: image]

Init and Exceptions 
Acomment
	["Vmapper writes objects out.
	watch out for abnormally high refcts.
	we trust map to catch all special cases (especially
	fixed octave classes (VariableLengthClass)).
		Vmapper edit: ↪mapObject.
	Vmem is VirtualMemory of this system.
	Pmap is VirtualMemory of new system.
	refct in mrefs is 1-order (0 = all done)
	mrefs - a Dictionary
		old oop  ->  (remaining refct, new oop)
	classtrans - a Dictionary
		old class oop  ->  (new oop, freelist oop)
				->  (new oop, 20 freelist oops)
	sequence of foreign object:
		map (put in mrefs) 
		newoop (classtrans lookup old class)
		not there⇒ create pclass, get zone, zip entry
			enter freelist, no new class in classtrans
		put nop in mrefs, write object out
		later: map class, fill in classtrans new class
		later: pass over PM, convert RCI

	To remap atoms:				To only copy atoms:
	giveBirth3 - arefsRectify		- don't call
	mapUniqueString -uniStrOop	-newoop, arefs
	mapVector - filter USTable	-don't
	writefreelists - don't freelistRectify		-call it
		(Speed only below)
	permHashSet - test objects		-force fail on test
	Now above done by setting UseOldUniqueStrings in giveBirth3.
	"]
arefsRectify | i ustable vm "create USTable and write out"
	[UseOldUniqueStrings ⇒[⇑nil "dont create if using old atoms"]
	ustable ← Vector new: USTable length.
	for⦂ i to: ustable length do⦂
		[ustable◦i ← Vector new: 2].
	i ← ustable.  ustable ← USTable. USTable ← i.
	for⦂ i from: arefs objects do⦂
		[i ≡ nil ⇒[]
		↪a intern: i asObject].
	i ← ustable.  ustable ← USTable. USTable ← i.
	vm ← Vmapper new.
	vm object: ustable.
	self reset; object: (Smalltalk ref: ↪USTable); readin.
	image word: 2 ← vm map. "ref new table"
	self writeout; reset]
bump  "count objects mapped, print"
	[count ← count + 1.
	count\ 100 = 0 ⇒[user clearshow: count asString; space;
		show: oop base8; cr.
		count = stopcount ⇒[user ev; show: stopcount asOop base8]]
	]
freelistRectify | i v  "fix bad atom freelist"
	[[UseOldUniqueStrings ⇒[] ⇑nil].  "dont rectify if new atom names created"
	for⦂ i from: (Vmem pmatm to: 0174000 - 0200 by: 0200) do⦂
		[(Vmapper new object: i asObject) UniStroop].
	v ← classtrans lookup: 0602.
	for⦂ i from: (2 to: 21) do⦂ [v◦i ≡ nil ⇒[]
		v◦i ← v◦i + 1]
	]
init   "set up class variables"
	[PCL ← 151.
	classtrans ← Dictionary new init: 32.
	mrefs ← Dictionary new init: 64.
	arefs ← Dictionary new init: 64.
	count ← 1.
	stopcount ← 5 "no stopping".
	clamp ← HashSet new init: 8. 
	"clamp insertall: (ClassA, ClassB, ClassC...).""ones to get rid of"
	USTableOop ← USTable asOop.
	"override this in VirtualMemory giveBirth3"
	UseOldUniqueStrings ← true]
mrefsRectify | v zz
	[for⦂ v from: mrefs values do⦂
		[v ≡ nil ⇒[]
		v◦1 = 0 ⇒["refct ok"]
		v◦2 = ¬1 ⇒["nil not on disk"]
		zz ← Pmap obwiz: v◦2.  "noop"
		image ← Pmap read: 2 at: zz.  "2 words"
		image word: 1 ← (image word: 1) - (v◦1).
		Pmap writeout: v◦2 with: image.
		self reset]
	]
noop: noop "give it noop for readin"
reset [noop ← image ← nil]
touchoop | v a i indx "claim pclass, zone, classtrans"
	[(v ← classtrans lookup: (object class) asOop) ⇒
		[indx ← 1 +(Vmem freelist: object).
		a ← self nextfree: v◦indx.
		v◦indx ← a◦1. "not take it" ⇑a◦1]
	 i ← [object class is: Class ⇒[1] 20].
	 v ← Vector new: i+1.
	 classtrans insert: (object class) asOop with: v.
	 ⇑self touchoop]
UniStroop | pm0 v indx
	["Unique Strings must get same oop and pclass"
	v ← classtrans lookup: 0602.
	indx ← 1+ (Vmem freelist: object).
	pm0 ← Pmap highPM: oop.
	pm0 and⦂ 0 ≠ pm0 ⇒["test for new max freelist"
		(oop field: PCL) = (v◦indx field: PCL) ⇒
		[v◦indx ← v◦indx max: oop]] 
	Pmap highpm0: oop gets: (Vmem highPM: oop).
	Pmap ZHB: oop gets: (Vmem ZHB: oop).
	v◦indx ≡ nil ⇒[Pmap newZN: oop.
		v◦indx ← oop]
	Pmap ZN: oop gets: (Pmap ZN: v◦indx).
	v◦indx ← oop min: v◦indx
	]
UseOldUniqueStrings: a [UseOldUniqueStrings ← a] "true if do not want atoms remapped"
writefreelists | v oadd i nlen str
	[self freelistRectify.
	nlen ← 1 + Class instsize. oadd ← 1.
	str ← String new: 4. 
	str word: 1 ← 1. str word: 2 ← ¬1. "refct=1, link = nil"
	for⦂ v from: classtrans values do⦂
		[v ≡ nil ⇒[]
		image ← Pmap readin: v◦1.  "noop"
		[v length = 2 ⇒
			["a Class" v◦2 ≡ nil ⇒[]
			image word: (1+nlen) ← v◦2.
			Pmap writeout: v◦2 with: str]
		"a Variable Length Class"
		for⦂ i to: 20 do⦂
			[v◦(1+i) ≡ nil ⇒ []
			image word: (i+nlen+oadd) ← v◦(1+i).
			Pmap writeout: v◦(1+i) with: str] ].
		Pmap writeout: v◦1 with: image].
	self reset]

As yet unclassified 
Addons
	[(dp0 file: 'VmapperAdd.st') filout: ↪(
	)]
arefs  "dictionary of UniqueString oops and noops"
	[⇑arefs]
classtrans [⇑classtrans]
image [⇑image]
mrefs "dictionary of multiple refct oops"
	[⇑mrefs]
noop [⇑noop]
object [⇑object]
oop [⇑oop]
printon: strm
	[oop ≡ nil ⇒[super printon: strm]
	strm append: 'Vmapper '; append: oop base8]
show | i  "show image of object in base8"
	[for⦂ i to: image length/2 do⦂
		[user show: (image base8: i); space.
		i\3 = 0 ⇒[user cr]]
	]

SystemOrganization classify: ↪Vmapper under: 'Primitive Access'.
