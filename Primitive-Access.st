'From Smalltalk 5.5k XM November 24 on 5 February 2037 at 11:10:42 pm.'
\g
"BitBlt"l15000z20000\gbf5 
Class new title: 'BitBlt'
	subclassof: Object
	fields: 'function color destbase destraster destx desty
			width height sourcebase sourceraster sourcex sourcey
			sstrike dstrike '
	declare: 'pageOneCursor ';
	asFollows\gbf5 

BitBlt copies bits from one rectangle to another in core.  x, y, width and height are in bits, raster is in words, and base is a core address.  Mode is storing, oring, xoring or erasing.  If source or destination is a Smalltalk object, then you have to lock it, as in copyToString, below.  The primitive does no bounds checking, so watch out.\gi

Access to Parts\gbf5 
color  [color]\gb7B
color _ color\gb
destbase  [destbase]\gb10B
destbase _ destbase\gb
destraster  [destraster]\gb12B
destraster _ destraster\gb
destx  [destx]\gb7B
destx _ destx\gb
desty  [desty]\gb7B
desty _ desty\gb
dest _ pt [destx_ pt x.  desty _ pt y]\gb10B
dstrike [dstrike]
\gb8B
dstrike _ dstrike
\gb
extent _ pt [width _ pt x.  height _ pt y]\gb12B
function  [function]\gb10B
function _ function\gb
height  [height]\gb8B
height _ height\gb
sourcebase  [sourcebase]\gb12B
sourcebase _ sourcebase\gb
sourceraster  [sourceraster]\gb14B
sourceraster _ sourceraster\gb
sourcex  [sourcex]\gb9B
sourcex _ sourcex\gb
sourcey  [sourcey]\gb9B
sourcey _ sourcey\gb
source _ pt [sourcex_ pt x.  sourcey _ pt y]\gb12B
sstrike [sstrike]
\gb8B
sstrike _ sstrike
\gb
width  [width]\gb7B
width _ width\gb

Setup\gbf5 
classInit 
	[pageOneCursor _ 0431. "location of hardware cursor"
	]\gb12B
forCursor
	[function_ color_ 0.
	destbase_ sourcebase_ 0431.
	width_ height_ 16. destraster_ sourceraster_ 1.
	destx_ desty_ sourcex_ sourcey_ 0. sstrike _ dstrike _ false
	]\gb11B
init 
	[function _ color _ destbase _ destraster _ destx _ desty _ width _
	height _ sourcebase _ sourceraster _ sourcex _ sourcey _ 0. sstrike _ dstrike _ false
	]\gb7B

Operations\gbf5 
callBLT
	[user croak]  primitive: 33\gb9B
checksandcall | destlocked sourcelocked	
	["checks if either base a string and/or strike and locks accordingly"
		function _ function land: 017.		"set up function to add XM stuff"
	[destbase class  String 
		[destbase1 _ destbase1.  "set the dirty bit"
		destlocked _ destbase.
			destbase _ ([dstrike  [((destlocked lock) + 9)]
															destlocked lock	 "strike header"])
		]
	[destbase  pageOneCursor 
	[function _ function + 020. "dest not string, then must be in display"]
		"unless doing cursor work in page one location"]
	].
	[sourcebase class  String 
		[sourcelocked _ sourcebase.
			sourcebase _ ([sstrike  [((sourcelocked lock) + 9)]
															sourcelocked lock	 "strike header"])
		]
	[sourcebase  pageOneCursor 
	[function _ function + 040. "source not string, then must be in display"]
		"unless doing cursor work in page one location"]
	].
	self callBLT.
	[destlocked  nil  [] destbase _ destlocked unlock].
	[sourcelocked  nil  [] sourcebase _ sourcelocked unlock].
	]\gb14B29i68I35i33I187i15I65i42I1i50I156i15I67i44I1i50I
copy: mode 
	[function _ mode land: 3. self checksandcall]\gb13B
copycomp: mode 
	[function _ 4 + (mode land: 3). self checksandcall]\gb17B
fill: mode color: color 
	[function _ 12 + (mode land: 3). self checksandcall]\gb26B
paint: mode 
	[function _ 8 + (mode land: 3). self checksandcall]\gb14B
stringCopy: deststring from: start to: stop with: replacement from: rstart to: rstop
	["copies equal subranges from one string to another.
	works for BitBlt parameters up to 4096. maybe too much set up for short strings.
	currently, called by String copy:to:with:from:to:"
		
	width _ 1+stop-start.
	width = 0 [deststring]

	(start > 4096 or rstart > 4096) or width  4096 [false]
	(width < 0 or width  (1+rstop-rstart)) or (
		(start < 1 or stop > deststring length) or
		(rstart < 1 or rstop > replacement length)) [
			user notify: 'illegal range or subscript']

	"self init."
	function _ color _ destraster _ desty _ sourceraster _ sourcey _ 0.
	sstrike _ dstrike _ false.
	height _ 1.

	width _ width*8.
	destbase _ deststring lock. 
	destx _ (start - 1) * 8.
	sourcebase _ replacement lock.
	sourcex _ (rstart - 1) * 8.

	self callBLT.

	replacement unlock.
	"mark dirty"
	deststring1 _ deststring1.
	deststring unlock.
	deststring
	]\gb86B157b28B
stringReplace: deststring with: sourcestring from: start to: stop and: replacement from: rstart to: rstop | slock [
	"works for BitBlt parameters less than 4096. replaces a subrange of a string.
	called only by String replace:to:by:from:to:.  concatenates into deststring:
		sourcestring(1 to: start-1)
		replacement(rstart to: rstop)
		sourcestring(stop+1 to: sourcestring length).
	assumes String arguments"

	deststring length = 0 [deststring]

	(replacement is: String)false[false]
	(stop  4096 or sourcestring length - stop  4096) or
		(start+rstop-rstart  4096 or rstart > 4096) [false]

	(start < 1 or stop > sourcestring length) or
	(rstart < 1 or rstop > replacement length) [user notify: 'illegal subscript']

	"self init."
	function _ color _ destraster _ desty _ sourceraster _ sourcey _ 0.
	sstrike _ dstrike _ false.
	height _ 1.

	destbase _ deststring lock. 
	sourcebase _ slock _ sourcestring lock.
	width _ (start - 1) * 8.
	[width = 0 []
	sourcex _ destx _ 0.
	self callBLT].

	destx _ width.
	width _ (1+rstop-rstart)*8.
	[width = 0 []
	sourcex _ (rstart - 1) * 8.
	sourcebase _ replacement lock.
	self callBLT.
	replacement unlock].

	destx _ destx+ width.
	width _ (sourcestring length - stop) * 8.
	[width = 0 []
	sourcebase _ slock.
	sourcex _ stop * 8.
	self callBLT].

	deststring1 _ deststring1.
	sourcestring unlock. deststring unlock.
	deststring
	]\gb106B105b29B
\g
SystemOrganization classify: BitBlt under: 'Primitive Access'.\g
BitBlt classInit\g

"CoreLocs"l15000z20000\gbf5 
Class new title: 'CoreLocs'
	subclassof: Array
	fields: 'base length'
	declare: '';
	asFollows\gbf5 

I am an array mapping a section of Alto memory\gi

Initialization\gbf5 
base: base length: length\gb

Reading and Writing\gbf5 
 x [x isLarge[self(x asSmall)] user croak] primitive: 42\gb4B
 x _ val [x isLarge[self(x asSmall) _ val] user croak] primitive: 43\gb10B
base [base]\gb5B
length [length]\gb7B
\g
SystemOrganization classify: CoreLocs under: 'Primitive Access'.\g

"VirtualMemory"l15000z20000\gbf5 
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
	asFollows\gbf5 

A model of the OOZE virtual memory\gi

Pclass Map\gbf5 
CPT: oop | poma
	[poma _ 2*(oop field: PCL) +1.
	mappoma field: CPT]\gb9B
freelist: object  | a
	["one-order index into freelists."
	object class is: Class [1]
	a _ self ISC: object asOop.
	a < 024 [1+a] 1+ a-013]\gb18B6i33I
freelistOffset: len "offset of freelist for this length in a variable length class"
	[Class instsize + [len < 9 [len] (len-1) log2 + 6]]
\gb20Bi63I
highpm0: oop gets: val | poma
	[premappmatm _ premappmatm min: (oop field: PIN _ 0).
	poma _ 2*(oop field: PCL) +1.
	mappoma _ val]\gb23B
highPM: oop | pcl a
	[pcl _ oop field: PCL.
	a _ premappmatm field: PCL.
	pcl < a [false]
	map(2*pcl +1)]\gb12B
ISC: oop | poma
	[poma _ 2*(oop field: PCL) +1.
	mappoma field: ISC]\gb9B
lowPM: oop | pcl a
	[pcl _ oop field: PCL.
	a _ premappmend field: PCL.
	pcl  a [false]
	map(2*pcl +1)]\gb11B
newHighPM_ pm0 | pcl a
	[a _ premappmatm.
	premappmatm _ (a _ a-0200).
	pcl _ a field: PCL.
	map(2*pcl +1) _ pm0.
	a]\gb15B
newLowPM_ pm0 | poma a
	[map1 = pm0 ["reserved pclasses for Class"
		map3 = 0 [map3 _ pm0. 0200]
		map5 = 0 [map5 _ pm0. 0400] ]
	"normal case"
	a _ premappmend.
	premappmend _ a+0200.
	poma _ (a field: PCL) *2 +1.
	mappoma  0 ["skip over already filled"
		self newLowPM_ pm0]
	mappoma _ pm0.
	a]\gb14B25i29I72i13I90i26I
newZN: oop 
	[self ZN: oop gets: self newZone]\gb13B
pclassesOf: cls | i clsoop n z p "find pclasses of this class (in order of ZHB)"
	["ignore small integers and nil"
	p _ (Vector new: 1) asStream.
	z _ (Vector new: 1) asStream.
	clsoop _ cls asOop.
	for i from: (1 to: 2*(0174000 field: PCL) by: 2) do
		[mapi = 0 []
		(mapi field: RCI) = clsoop [p next_ i/2. z next_ (map(i+1) field: ZHB)]].
	p _ p contents. z _ z contents.
	n _ p copy.
	for i to: z length do
		[n(zi +1) _ pi].
	n]\gb16B17i47I3i31I
pclassesOf: cls length: len | i clsoop n z p isc pm0 "find pclasses of this class and length (in order of ZHB)"
	["ignore small integers and nil"
	p _ (Vector new: 1) asStream.
	z _ (Vector new: 1) asStream.
	isc _ [len < 9 [len] (len-1) log2 + 17].
	clsoop _ cls asOop.
	for i from: (1 to: 2*(0174000 field: PCL) by: 2) do
		[(pm0 _ mapi) = 0 []
		(pm0 field: RCI)  clsoop []
		(pm0 field: ISC) = isc [p next_ i/2. z next_ (map(i+1) field: ZHB)]].
	p _ p contents. z _ z contents.
	n _ p copy.
	for i to: z length do
		[n(zi +1) _ pi].
	n]\gb28B25i58I3i31I
pmatm [premappmatm]\gb6B
ZHB: oop | poma
	[poma _ 2*(oop field: PCL) +1.
	map(1+poma) field: ZHB]\gb9B
ZHB: oop gets: val | poma i
	[poma _ 2*(oop field: PCL) +1.
	i _ map(1+poma).
	map(1+poma) _ (i field: ZHB _ val)]\gb19B
ZN: oop | poma
	[poma _ 2*(oop field: PCL) +1.
	map(1+poma) field: ZN]\gb8B
ZN: oop gets: val | poma i
	[poma _ 2*(oop field: PCL) +1.
	i _ map(1+poma).
	map(1+poma) _ (i field: ZN _ val)]\gb18B

Writing and Reading\gbf5 
obwiz: oop | poma pm0 pm1 isc bsc i len zz pin zhb
	["find (zn, zp, zw, dlen)"
	zz _ Vector new: 4.
	poma _ (oop field: PCL)*2 +1.
	(pm0 _ mappoma) = 0  [user notify: 'bad oop']
	pm1 _ map(1+poma).
	isc _ pm0 field: ISC.
	bsc _ pm0 field: BSC.
	zhb _ pm1 field: ZHB.
	[isc < 024 [len _ ((isc max: 1)+ 1-bsc) / (2-bsc)]
		len _ 8. i _ isc+bsc.
		until 024 = i do [i _ i-1. len _ len*2]
		len _ len+1 "length word" ].
	zz4 _ len _ len+1. "dlen with refct"
	"w _ (dlen*128*zhb) +dlen*pin"
	pin _ oop field: PIN.
	zz2 "zp" _ (zhb/2 *len) +(len/256 *pin).
	zz3 "zw" _ (zhb\2 *128 *len) +(len\256 *pin).
	zhb\2 * len  512 [user notify: 'address overflow']
	zz2 "zp" _ zz2 + (zz3 field: 136 "highbyte").
	zz3 "zw" _ zz3 field: 128 "lowbyte".
	zz1 _ pm1 field: ZN.
	zz]\gb11B42i25I327i13I25i17I2i30I30i4I39i4I98i4I27i10I9i4I19i9I
readin: oop | zinfo
	[zinfo _ self obwiz: oop.
	self read: zinfo4 at: zinfo]\gb12B
systemNoHistory [] primitive: 82\gb16B
writeout: oop with: image | zinfo
	[zinfo _ self obwiz: oop.
	[zinfo4  (image length /2) []
		user notify: 'bad image length'].
	self write: image at: zinfo
	]\gb26B

Init\gbf5 
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
	"]\gb10B1i670I
fakevmem: vmemfile
	["this instance is a model of a new vmem, which is built on another file"
	self init.
	map _ Vector new: 1024.
	map all _ 0.
	premap _ (0176000, 0174000, 0, 0).
			"num00, pmint, pmatm, pmend"
	prezip _ (3, 01244, 0). "zfree, zlong, zend"
	zip _ Vector new: prezipzlong.
	zip all _ 0.
	zadd _ (1, 1).  "zfused, zflen"
	vmemfile readwrite.
	Smalltalk define: Pmap as: self]\gb20B1i72I91i28I26i20I65i15I
init  "common to both real and fake vmem"
	["field descriptors and indicies in tables"
	num00 _ 1. pmint _ 2. pmatm _ 3. pmend _ 4.
	RCI _ 151. CPT _ 22. BSC _ 21. ISC _ 80.
	ZHB _ 136. ZN _ 128. 
	PCL _ 151. PIN _ 112.
	ZJMP _ 76. ZVPN _ 16*12.
	zfree _ 1. zlong _ 2. zend _ 3.
	zfused _ 1. zflen _ 2.
	zjmpt _ (603, 570, 471, 410, 353, 300, 253, 
		210, 169, 132, 101, 72, 49, 30, 13)]\gb6Bi35bI2B1i42I
premap [premap] "array of limits in Pclass Map"\gb7B10i
thisvmem | c m "create Vmem, a VirtualMemory viewing this very system"
	[c _ self specialLocs.
	map _ CoreLocs new base: c2 -1 length: 1025.
	premap _ CoreLocs new base: c2 -5 length: 5.
	Smalltalk define: Vmem  as: self.
	self init.
	m _ 1023.
	until (mapm = 0) do [m _ m-2].
	premappmatm _ (0 field: PCL _ m/2 +1).
	prezip _ CoreLocs new base: c3 -4 length: 4.
	zip _ CoreLocs new base: c3 -1 length: prezipzlong+1.
	zadd _ CoreLocs new base: c12 -3 length: 3.
	(vmemfile _ dp0 oldFile: 'small.boot') readonly.
	FirstContext _ Context new sender: nil 
		receiver: user
		method: (m _ UserView md method: restart) 
		tempframe: (Vector new: (m3 max: m4)) pc: m6
		stackptr: m5 -1.
	SpecialOops1 _ Object md method: error.
	FirstContextOop _ FirstContext asOop.
	SpecialOopsOop _ SpecialOops asOop]\gb9B

Vmem Writing\gbf5 
afterBirth [MethodKeeperKeeper _ nil]\gb11B
giveBirth | pm0 vm "initialize map for early pclasses"
	[self preBirth.
	"small Integer, 16 pclasses, oops 0174000-0177777"
		pm0 _ Vmem highPM: 0176000. "size, class info for Integer"
		until (Pmap newHighPM_ pm0) = 0174000 do []. 
	"first UniqueString"
		(vm _ Vmapper new) object: (0173600 asObject); touchoop.
	"Class oops 0-0177"
		vm object: Class; touchoop.
	"more Class oops 0200-0577"
		Pmap newLowPM_ 0; newLowPM_ 0.
	"VariableLengthClass oops 0600-0777"
		vm object: Vector; touchoop.
	"skip over some oops"
		until (Pmap newLowPM_ 0) = 01600 do [].
	"Object oops 02000-02177, false=02000"
		(vm object: false) map  02000 [user notify: 'bad false oop']
	"set pointer back to oops skipped over"
		Pmap premap  pmend _ 01000
	]\gb10B9i35I19i50I31i30I52i20I61i19I32i27I35i36I33i21I46i38I67i39I
giveBirth2 | vm
	[vm _ Vmapper new.
	vm object: (Smalltalk ref: FirstContext).
	FirstContextOop _ (vm readin word: 2). "new oop of FirstContext"
	vm reset; object: (Smalltalk ref: SpecialOops).
	SpecialOopsOop _ (vm readin word: 2). "new oop of SpecialOops"]\gb11B109i25I90i24I
giveBirth3 | vm p ["create a new Small.boot
	Write out all objects rooted at Smalltalk.
	Do not write the stack (rooted in R76, the current context).
		Pmap file close. Pmap _ nil.

	*** Below is the commmand to start a Vmem write on a Dorado
		(or Alto -- double disk O.S.).  edit and recompile the method if you don't
		want to use old UniqueStrings, or if newsmall.boot, smalltalk.run,
		smalltalk.syms, byterp.mb are not located on dp0i,
		i.e. dp1 oldFile: 'small.boot' instead of dp0 oldFile: 'newsmall.boot'.
		also delete rename: commands at the end.

		user displayoffwhile [(VirtualMemory new) giveBirth3]. user quit.

	***"

	user releaseExternalViews.
	[Enil [] E kill].
	Flushed_ false.
	(Vmapper new) init; UseOldUniqueStrings: true.
	user show: 'init '.
	(VirtualMemory new) thisvmem.  "define Vmem, Pmap"
	(VirtualMemory new) fakevmem: (dp0 oldFile: 'newsmall.boot').
	self giveBirth.
	vm _ Vmapper new.
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
	p _ Pmap pagesUsed + 264 "boot & ram" + 250 "extra".
	user show: 'pages reclaimed '; print: (Pmap file) file lastPage - p.
	(Pmap file) readwriteshorten; settopage: p char: 0; close; readwrite.

	"rename files so that new file is small.boot"
	(Vmem file) file rename: 'oldsmall.boot'.
	(Pmap file) file rename: 'small.boot'.
	]\gb11B8i133I30i377I245i19I317i48I140i23I29i10I9i5I
mapPM | c i v rci ctrans  "convert to new RCI"
	[ctrans _ (Vmapper new) classtrans.
	for c from: (1 to: 1023 by: 2) do
		[(i _ mapc) = 0 []
		rci _ i field: RCI.
		(v _ ctrans lookup: rci) 
			[mapc _ (i field: RCI _ v1)]
		user notify: 'class not mapped']
	]\gb6B20i20I
preBirth | v
	[MethodKeeperKeeper _ MessageDict new.
	MethodKeeperKeeper init: (v _ MethodKeeper contents) length *2; holdMethods: v]\gb9B
ramwrite: source | s "write 8 pages of ram image into small.boot" [
	s _ source name.
	source readonly.
	[source directory  dp0 []
	(dp0 file: s) append: source; close "copy onto dp0"].
	source close.

	"cleanup vmem file before quit"
	vmemfile close.

	"go out to OS, packram, and come back"
	s _ s(1 to: s length-4) concat: '.br.'.
	user quitThen: [
		(Stream default) append: 'Packmu ';
			append: source name; space; append: s;
			append: '; Resume '; append: Vmem file name;
			contents].  

	"skip .br stuff and constants"
	(s _ dp0 oldFile: s) readonly; skipwords: 0421.
	"now write in ram image (8 pages of 512)"
	vmemfile settopage: 0400 char: 0; readwrite; next: 4096 from: s.
	s close.
	self  Vmem [vmemfile readonly "does flush"]
	vmemfile flush]\gb17B4i43I107i13I22i29I22i36I209i28I53i39I112i10I

Surgery\gbf5 
dynaLocs: guide | l locs keys v i "Surgery - add core location and value pairs to guide dictionary to test after flush"
	[l _ self specialLocs.
	locs _ (premap base +pmend, (l11 -1), (l12 -2), (l4 +1)).
	keys _ (premaptest, purgetest, zaddtest, loxtest).
	for i from: 1 to: keys length do
		[v _ locsi, (mem(locsi)).
		guide insert: keysi with: v].
	(guide lookup: loxtest)2 _ 1]\gb16B
runLocs: f | guide i v locs keys offsets "Surgery - create dictionary of locations of key system tables in Smalltalk.run"
	[i _ f name.
	(v _ f directory oldFile: (i(1 to: i length-5) concat: '.syms.')) readonly.
	locs _ self symsFind: ('PMBASE', 'ZIP', 'ZADD', 'INITIALIZE', 'OOZIN', 'SAFID') on: v.
	v close.

	keys _ (maprun ziprun zaddrun initrun zfps safid).
	offsets _ (1 1 3 3 2 1). "words offset"
	guide _ Dictionary new init: 16.
	for i from: 1 to: locs length do
		[v _ (locsi lshift: 8), ((locsi land: 0377) -19 *2). "page, byte"
		"magic fudge factor of 19 words for .run file"
		v2 _ v2 +(offsetsi *2). "bytes offset"
		guide insert: keysi with: v].
	v _ (guide lookup: maprun) copy.
	v2 _ v2 +(4 *2).  "offset 5 total"
	guide insert: premaprun with: v.
	v _ (guide lookup: ziprun) copy.
	v2 _ v2 +(3 *2).  "offset 4 total"
	guide insert: preziprun with: v.
	guide]\gb11B
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
"\gb12B
staticTest: guide on: f | l locs offsets values names i v "Surgery - test known static constants in thisvmem and in smalltalk.run"
	[offsets _ (pmint, 2, 0, 0).
	values _ (0174000, 01244, 96, 031415).
	names _ (premaprun, preziprun, zaddrun, initrun).
	for i to: names length do
		[v _ guide lookup: namesi.
		f settopage: v1 char: v2 +(offsetsi *2).
		f nextword  (valuesi)
		[user notify: 'bad .run loc']].
	self  Vmem 
		[l _ self specialLocs.
		offsets4 _ 0.  values4 _ 014764.	
		locs _ (premap base, prezip base, zadd base, (l11) "bacpur").
		for i from: 1 to: locs length do
			[valuesi  (mem(locsi +(offsetsi)))
			[user notify: 'bad system loc']]]
	]\gb24B
surgery: f | guide Etemp i v keys [
	"write virtual memory tables into Smalltalk.run using Smalltalk.syms.
	user displayoffwhile [Vmem ramwrite: (dp0 oldFile: 'byterp.mb')].
	user displayoffwhile [Vmem surgery: (dp0 oldFile: 'Smalltalk.run')]. "

	vmemfile close.
	user releaseExternalViews.
	[E  nil [] E kill].

	[self  Vmem [self thisvmem.
		Flushed _ true. Etemp _ Events]].
	f readwrite.
	guide _ self runLocs: f.
	self staticTest: guide on: f.
	[self  Vmem [user clearshow: 'Wait for the safe light to flash, then hit any key'.
		until user kbck do []. user kbd.
		self dynaLocs: guide.
		user clearshow: 'Dont forget user systemStartup. in the new system to enable interrupts and get the display set up. '.
]].
	self tablewrt: guide on: f. "write in Smalltalk.run"
	f close.

	self  Vmem 
		[keys _ (premaptest, purgetest, zaddtest, loxtest).
		for i to: keys length do
			[v _ guide lookup: keysi.
			v2  (mem(v1))[user notify: 'please surgery again']].
		Events _ nil. self systemVmemOut.
		Events _ Etemp.
		vmemfile close.
		user quit]
	]\gb11B27i69I652i22I
symsFind: strs on: f1 | f2 S N L offset val str j i "find initial values of SRELs in smalltalk.syms"
	["S is start of string space (words)
	N is start of symbol table "
	(f2 _ f1 directory oldFile: f1 name) readonly.
	f1 wordposition _ 2.
	S _ f1 nextword.
	N _ f1 nextword.
	f1 wordposition _ N.
	L _ f1 nextword.
	for i to: L do
		[offset _ f1 nextword. "next offset"
		f1 skip: 4.
		val _ f1 nextword.
		f2 wordposition _ S+offset.
		str _ f2 next: f2 next.
		for j to: strs length do
			[(strsj) class  String 
				[strsj = str [strsj _ val]]].
		].
	f2 close.
	for j to: strs length do
		[(strsj) class  String 
			[user notify: 'symbol not found']].
	strs]\gb22B
systemVmemOut [] primitive: 83\gb14B
tablewrt: guide on: f | i v vfile "copy tables from self to .run file"
	[v _ guide lookup: premaprun.
	f settopage: v1 char: v2 +(2*pmatm).
	f nextword_ premappmatm.
	f nextword_ premappmend.
	for i to: 1024 do [f nextword_ mapi].
	v _ guide lookup: preziprun.
	f settopage: v1 char: v2 +(2*1 "zfree").
	i _ [self  Vmem  [1-zip base "relative indexing"]1 "make 0-order"] .
	f nextword_ prezip 1 +i. "zfree"
	v _ guide lookup: zaddrun.
	f settopage: v1 char: v2 +(2*1 "zfused").
	f nextword_ zadd 1. " zfused "
	v _ guide lookup: ziprun.
	f settopage: v1 char: v2 +(2*1).
	for i to: prezipzlong do [f nextword_ zipi]
	v _ guide lookup: initrun.
	f settopage: v1 char: v2 +(2*1 "SpecialOops").
	f nextword_ SpecialOopsOop.
	f nextword_ FirstContextOop.

	"disk address of start of virtual memory"
	vfile _ vmemfile file.
	v _ guide lookup: zfps.
	f settopage: v1 char: v2 +(2*1).
	f nextword_ (vfile read: 0410) address.

	"swat file id of vmem file"
	v _ guide lookup: safid.
	f settopage: v1 char: v2 + (2*1).
	f append: vfile serialNumber; skip: 4; nextword _ (vfile read: 1) address.
	]\gb22B349i13I3i2I130i10I423b2B

Zone Pages\gbf5 
cover: zz | pp zrp lpir zjmp vpn olpir
	[pp _ zz2 + 1. "zp 1-order"
	lpir _ 1. olpir _ 0. zrp _ zz1 *2 +1.
	until lpir  pp do [
		0 = (zjmp _ zipzrp field: ZJMP) 
			[self run: [lpir  32 [32] lpir +1] after: zrp.
			self cover: zz]
		zrp _ (zjmptzjmp + zrp -1)\ (prezipzlong) +1.
		olpir _ lpir.
		lpir _ lpir + [lpir  32 [32] lpir +1] ].
	vpn _ (zipzrp field: ZVPN) +pp -(olpir +1).
	0 = vpn [user notify: 'pclass has no zone']
	vpn _ vpn + 0407.
	vmemfile settopage: vpn char: zz3 *2]\gb10B
file [vmemfile]\gb5B
getpages: i | vpn
	[[zaddzflen < (zaddzfused + i) 
		[zaddzflen _ zaddzflen + (i max: 20).
		vmemfile settopage: zaddzflen + 0407 char: 0]].
	vpn _ zaddzfused.
	zaddzfused _ vpn+i.
	vpn]\gb12B
newZone | zrp
	[zip is: Vector [
	zrp _ prezipzfree.
	until zipzrp = 0 do [zrp > (prezipzlong) 
		[user notify: 'zip overflow']
		zrp _ zrp+2].
	prezipzfree _ 2+zrp.
	zipzrp _ self getpages: 1.
	zrp/2]]\gb8B
pagesUsed [zaddzfused]\gb10B
read: len at: zz | i str
	[i _ 256 - (zz3) "zw" min: len.
	self cover: zz.
	str _ vmemfile next: 2*i.
	i=len [str]
	zz2 _ zz2 +1. "zp"
	zz3 _ 0. "zw"
	str concat: (self read: len-i at: zz)]\gb17B
run: n after: zrp | i j
	[for i to: 15 do 
		[j _ zjmpti +zrp -1 \ (prezipzlong) +1.
		zipj = 0 
			[zipzrp _ zipzrp field: ZJMP _ i.
			zipj _ self getpages: n. zrp]
		].
	user notify: 'new zip is full']\gb18B
write: str at: zz | i len
	[len _ str length /2.
	i _ 256 - (zz3) "zw" min: len.
	i = len [
		self cover: zz.
		vmemfile append: str]
	self write: str from: 1 at: zz]\gb18B
write: str from: pos at: zz | i len
	[len _ str length +1 -pos.  "bytes yet to write"
	i _ len min: (256 - (zz3) "zw")*2.  "bytes in page"
	self cover: zz.
	vmemfile append: str(pos to: i+pos-1).
	i=len []
	zz2 _ zz2 +1. "zp"
	zz3 _ 0. "zw"
	self write: str from: i+pos at: zz]\gb28B
\g
SystemOrganization classify: VirtualMemory under: 'Primitive Access'.\g

"Vmapper"l15000z20000\gbf5 
Class new title: 'Vmapper'
	subclassof: Object
	fields: 'object oop noop image'
	declare: 'classtrans PCL mapqueue clamp stopcount USTableOop mrefs arefs count UseOldUniqueStrings ';
	asFollows\gbf5 

This class has not yet been commented\gi

Mapping\gbf5 
map | i
	[(i _ mrefs lookup: oop) [i1 _ i1 -1. i2]
	[user kbck  [user kbd; ev] self bump].
	object class = Integer [self mapInteger];
	= UniqueString [self mapUniqueString];
	= Vector [self mapVector];
	= Float [self mapFloat];
	= MessageDict [self mapMdict]
	object Is: HashSet [self mapHashSet]
	object Is: String [self mapString]
	object class = Class [self mapClass];
	= VariableLengthClass [self mapClass];
	= Vmapper [1]; "avoid recursion in writing"
	= VirtualMemory [self mapVmem]; "avoid recursion in writing"
	"put any fixed octave class here"
	= Object [self mapObject]
	self mapNormal]\gb4B451i28I36i28I2i33I
mapClass | nlen oadd i refs vm j
	[clamp find: object [1 "don't write this class"]
	nlen _ 1 + object class instsize. "refct + normal fields"
	i _ [object is: Class [oadd _ 0. 1] oadd _ 1. 20].
	noop _ self newoop.
	[(vm _ classtrans lookup: oop) [vm1 _ noop]
		vm _ Vector new: i+1. vm1 _ noop.
		classtrans insert: oop with: vm].
	nlen _ nlen + i + oadd.
	image _ String new: 2*nlen.
	[(refs _ object refct) = 2 ["exactly one reference"]
		mrefs insert: oop with: (refs-2, noop)].
	image word: 1 _ refs -2.
	[oadd=1 [image word: 2 _ nlen-2]].
	for j from: (2+oadd to: nlen-i) do 
		[vm _ Vmapper new object: (object instfield: j-1-oadd).
		image word: j _ vm map].
	self writeout.
	noop]\gb9B112i23I279i23I
mapFloat | refs i
	[image _ String new: 8.
	noop _ self newoop.
	[(refs _ object refct) = 2 ["exactly one reference"]
		mrefs insert: oop with: (refs-2, noop)].
	image word: 1 _ refs-2.
	for i to: 3 do [image word: (i+1) _ object instfield: i].
	self writeout.
	noop]\gb9B85i23I
mapHashObs  | nlen oadd i refs vm trans ob
	[nlen _ object length. "in words"
	oadd _ [nlen8[0]1].
	nlen _ oadd +1 +nlen.
	image _ String new: 2*nlen.
	[(refs _ object refct) = 2 "exactly one ref" 
		[noop _ self newoop]
		(i _ mrefs lookup: oop) [i1 _ i1 -1. noop _ i2]
		noop _ self newoop.
		mrefs insert: oop with: (refs-2, noop)].
	image word: 1 _ refs -2.
	[oadd=1[image word: 2 _ object length]].
	ob _ (trans _ self permHashSet) objects.  "translation dictionary"
	for i from: (2+oadd to: nlen) do 
		[vm _ ob(i-1-oadd).  "integer noops"
		vm  nil [] image word: i _ vm].
	self writeout.
	noop, trans values]\gb12B55i10I104i17I257i24I62i15I
mapHashSet | nlen i refs vm perm  "all subclass on HashSet except Mdict"
	[mrefs asOop = oop [1] "do not map"
	arefs asOop = oop [1] "do not map"
	nlen _ 1 + (object class instsize). "refct + fields"
	image _ String new: 2*nlen.
	noop _ self newoop.
	[(refs _ object refct) = 2 ["exactly one reference"]
		mrefs insert: oop with: (refs-2, noop)].
	image word: 1 _ refs -2.
	vm _ Vmapper new object: (object instfield: 1).
	i _ vm mapHashObs.  "(oop, perm)"
	image word: 2 _ i1.
	perm _ i2.  "permutation of other parts"
	for i from: (3 to: nlen) do 
		[vm _ Vmapper new object: (object instfield: i-1).
		image word: i _ (vm mapHashVals: perm)].
	self writeout.
	noop]\gb11B23i38I28i12I27i12I38i16I81i23I141i13I37i28I
mapHashVals: perm | nlen oadd i refs vm  "values vec of dictionary"
	[oop = 1 [1]
	nlen _ object length. "in words"
	oadd _ [nlen8[0]1].
	nlen _ oadd +1 +nlen.
	image _ String new: 2*nlen.
	[(refs _ object refct) = 2 "exactly one ref" 
		[noop _ self newoop]
		(i _ mrefs lookup: oop) [i1 _ i1 -1. noop _ i2]
		noop _ self newoop.
		mrefs insert: oop with: (refs-2, noop)].
	image word: 1 _ refs -2.
	[oadd=1[image word: 2 _ object length]].
	object _ objectperm.
	for i from: (2+oadd to: nlen) do 
		[(vm _ Vmapper new) object: object (i-1-oadd).
		image word: i _ vm map].
	self writeout.
	noop]\gb18B23i26I42i10I104i17I
mapInteger | refs
	[02000  object and: object < 01777 
		[oop "small integer"]
	image _ String new: 4.
	noop _ self newoop.
	[(refs _ object refct) = 2 ["exactly one reference"]
		mrefs insert: oop with: (refs-2, noop)].
	image word: 1 _ refs-2.
	image word: 2 _ object.
	self writeout.
	noop]\gb11B55i15I77i23I
mapMdict | i refs vm perm  " maps MessageDict instance "
	[image _ String new: 12.
	noop _ self newoop.
	[(refs _ object refct) = 2 ["exactly one reference"]
		mrefs insert: oop with: (refs-2, noop)].
	image word: 1 _ refs -2.
	(vm _ Vmapper new) object: (object instfield: 1).
	i _ vm mapHashObs.  "(oop, perm)"
	image word: 2 _ i1.
	perm _ i2.  "permutation of other parts"
	for i from: (3 to: 6) do 
		[(vm _ Vmapper new) object: (object instfield: i-1).
		i = 3 [image word: 3 _ (vm mapMethodVec: perm)]
		image word: i _ (vm mapHashVals: perm)].
	self writeout.
	noop]\gb9B18i29I78i23I143i13I37i28I
mapMethod | nlen oadd refs i a vm b
	[oop = 1 [1]
	nlen _ object length. "in bytes!!"
	oadd _ [nlen8[0]1].
	nlen _ 2*oadd +2 +nlen.
	image _ String new: nlen+1 |2.
	[(refs _ object refct) = 2 "exactly one ref" 
		[noop _ self newoop]
		(i _ mrefs lookup: oop) [i1 _ i1 -1. noop _ i2]
		noop _ self newoop.
		mrefs insert: oop with: (refs-2, noop)].
	image word: 1 _ refs -2.
	[oadd=1[image word: 2 _ object length]].
	[nlen  8 or object6 = 6 
		[image(2*oadd +3 to: nlen) _ object]
		a _ 2*oadd +3. b _ object6.
		image(a to: a+5) _ object(1 to: 6).
		for i from: (4 to: b /2) do
			[(vm _ Vmapper new) object: (object word: i) asObject.
			image word: (i+1+oadd) _ vm map].
		image(a+b to: nlen) _ object(b+1 to: object length)].
	self writeout.
	noop]\gb10B67i12I109i17I
mapMethodVec: perm | nlen oadd i refs vm
	[oop = 1 [1]
	nlen _ object length. "in words"
	oadd _ [nlen8[0]1].
	nlen _ oadd +1 +nlen.
	image _ String new: 2*nlen.
	[(refs _ object refct) = 2 "exactly one ref" 
		[noop _ self newoop]
		(i _ mrefs lookup: oop) [i1 _ i1 -1. noop _ i2]
		noop _ self newoop.
		mrefs insert: oop with: (refs-2, noop)].
	image word: 1 _ refs -2.
	[oadd=1[image word: 2 _ object length]].
	object _ objectperm.
	for i from: (2+oadd to: nlen) do 
		[(vm _ Vmapper new) object: object (i-1-oadd).
		image word: i _ vm mapMethod].
	self writeout.
	noop]\gb19B63i10I104i17I
mapNormal | nlen i refs vm oadd "all fixed, pointer type classes"
	[clamp find: object class [1 "don't write the instance"]
	nlen _ object class instsize.
	oadd _ [nlen19[0]1].
	nlen _ oadd+1 +nlen.
	image _ String new: 2*nlen.
	noop _ self newoop.
	[(refs _ object refct) = 2 ["exactly one reference"]
		mrefs insert: oop with: (refs-2, noop)].
	image word: 1 _ refs-2.
	[oadd=1[image word: 2 _ nlen-oadd-1]].
	for i from: (2+oadd to: nlen) do 
		[vm _ Vmapper new object: (object instfield: i-oadd-1).
		image word: i _ vm map].
	self writeout.
	noop]\gb10B22i33I219i23I
mapObject | refs  "nil, false, true"
	[objectnil 
		[mrefs insert: 1 with: (500, 1). "for speed of
		catching nil. watch out on cleanup" 1]
	image _ String new: 4.
	noop _ self newoop.
	noop\128>1 
		[user notify: 'Unidentified flying Object']
	[(refs _ object refct) = 2 ["exactly one reference"]
		mrefs insert: oop with: (refs-2, noop)].
	image word: 1 _ refs -2.
	self writeout.
	noop]\gb10B8i18I53i51I141i23I
mapString | nlen oadd refs
	[nlen _ object length. "in bytes!!"
	oadd _ [nlen8[0]1].
	nlen _ 2*oadd +2 +nlen.
	image _ String new: nlen+1 |2.
	noop _ self newoop.
	[(refs _ object refct) = 2 ["exactly one reference"]
		mrefs insert: oop with: (refs-2, noop)].
	image word: 1 _ refs -2.
	[oadd=1[image word: 2 _ object length]].
	image((2*oadd +3) to: nlen) _ object.
	self writeout.
	noop]\gb10B41i12I132i23I
mapUniqueString | nlen oadd refs
	[[UseOldUniqueStrings [self UniStroop. noop _ oop]
		(refs _ arefs lookup: oop) [refs]
		noop _ self newoop.
		arefs insert: oop with: noop].
	nlen _ object length. "in bytes!!"
	oadd _ [nlen8[0]1].
	nlen _ 2*oadd +2 +nlen.
	image _ String new: nlen+1 |2.
	image word: 1 _ 1.
	[oadd=1[image word: 2 _ object length]].
	image((2*oadd +3) to: nlen) _ object.
	self writeout.
	noop]\gb16B186i12I
mapVector | nlen oadd i refs vm
	[[UseOldUniqueStrings [] USTableOop = oop [1]
		"do not map since new atom Oops"]. 
	nlen _ object length. "in words"
	oadd _ [nlen8[0]1].
	nlen _ oadd +1 +nlen.
	image _ String new: 2*nlen.
	noop _ self newoop.
	[(refs _ object refct) = 2 ["exactly one reference"]
		mrefs insert: oop with: (refs-2, noop)].
	image word: 1 _ refs-2.
	[oadd=1[image word: 2 _ object length]].
	for i from: (2+oadd to: nlen) do 
		[vm _ Vmapper new object: (object (i-1-oadd)).
		image word: i _ vm map].
	self writeout.
	noop]\gb10B75i32I27i10I127i23I
mapVmem | nlen i refs vm  "VirtualMemory, Vmem and Pmap"
	[nlen _ 1 + (object class instsize). "refct + fields"
	image _ String new: 2*nlen.
	noop _ self newoop.
	[(refs _ object refct) = 2 ["exactly one reference"]
		mrefs insert: oop with: (refs-2, noop)].
	image word: 1 _ refs -2.
	for i from: (2 to: nlen) do 
		[image word: i _ 1]. "Vmem needed for purgealittle"
	self writeout.
	noop]\gb8B
permHashSet | ob i bb nili vm   "gets new atoms, returns dict of objects and permutation"
	[bb _ Dictionary new init: object length.
	i _ 1. while (objecti  nil and: i  object length) do [i _ i+1].
	[((objecti) class)  Integer [false];  String [false] true] 
		[for i to: object length do
			[objecti  nil [nili _ i]
			vm _ Vmapper new object: objecti.
			bb insert: vm map with: i].
		ob _ bb values.
		for i to: ob length do
			[obi  nil [obi _ nili] ].
		bb]
	ob _ bb objects.
	for i to: ob length do
		[vm _ Vmapper new object: objecti.
		obi _ vm map].
	ob _ bb values.
	for i to: ob length do
		[obi _ i].
	bb]\gb12B20i57I

Writing Out\gbf5 
method: sel | v str a j i   "object is a class. find this method and construct vmapper"
	[(v _ classtrans lookup: oop)  false [user notify: 'object not a class']
	str _ Pmap readin: v1. "class image"
	i _ Pmap readin: (str word: 1+4+(oop/0200)). "mdict image"
	str _ Pmap readin: (i word: 1+1). "objects vector image"
	a _ String new: 2. a word: 1 _ sel asOop. "selector"
	j _ str find: a2. 
	a1  (str(j-1)) [user notify: 'can not find']
	i _ Pmap readin: (i word: 1+2). "methods vector image"
	v _ Vmapper new object: (object md method: sel).
	v noop: (i word: (j/2)). v readin.
	v]\gb12B16i59I102i13I47i13I36i22I44i10I105i22I
newoop | v a i indx o "see if classtrans can help find new oop"
	[(v _ classtrans lookup: (i _ object class) asOop) 
		[indx _ 1 + (Vmem freelist: object).
		 [i  Class [oop  027 [oop] "touchoop set it up"
				vindx  027 [vindx _ 027+1] ];
			 VariableLengthClass [o _ vindx. "in case pclass changes"
				vindx _ o max: o|128 +(oop\128) +1. 
				 o|128 +(oop\128)] ].
		a _ self nextfree: vindx.
		vindx _ a2. a1]
	 a _ [i is: Class [1] 20].
	 v _ Vector new: a+1.
	 classtrans insert: (object class) asOop with: v.
	 self newoop]\gb7B15i41I128i20I78i24I
newpcl: n | a pm0
	["object class = Foo [an exception]"
	pm0 _ Vmem lowPM: oop.
	a _ [pm0 [Pmap newLowPM_ pm0]
			Pmap newHighPM_ (Vmem highPM: oop)].
	n=1 [Pmap newZN: a. Pmap ZHB: a gets: 0. a]
	Pmap ZN: a gets: (Pmap ZN: n).
	Pmap ZHB: a gets: 1 + (Pmap ZHB: n).
	a]\gb10B10i36I
nextfree: n | a
	[nnil [n _ self newpcl: 1.
		(n, (n+1))]
	n\0200 = 0177 [a _ self newpcl: n.
		(n, a)]
	(n, (n+1))]\gb12B
object: object
	[oop _ object asOop]\gb16B
readin | v  "read object off vmemfile and return image"
	[[noop  nil [(v _ mrefs lookup: oop) [noop _ v2] 
		user notify: 'can not find new oop']].
	image _ Pmap readin: noop]\gb7B5i43I
writeout
	["write image of object on file"
	Pmap writeout: noop with: image]\gb10B1i31I

Init and Exceptions\gbf5 
Acomment
	["Vmapper writes objects out.
	watch out for abnormally high refcts.
	we trust map to catch all special cases (especially
	fixed octave classes (VariableLengthClass)).
		Vmapper edit: mapObject.
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
		not there create pclass, get zone, zip entry
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
	"]\gb10B1i1135I
arefsRectify | i ustable vm "create USTable and write out"
	[UseOldUniqueStrings [nil "dont create if using old atoms"]
	ustable _ Vector new: USTable length.
	for i to: ustable length do
		[ustablei _ Vector new: 2].
	i _ ustable.  ustable _ USTable. USTable _ i.
	for i from: arefs objects do
		[i  nil []
		a intern: i asObject].
	i _ ustable.  ustable _ USTable. USTable _ i.
	vm _ Vmapper new.
	vm object: ustable.
	self reset; object: (Smalltalk ref: USTable); readin.
	image word: 2 _ vm map. "ref new table"
	self writeout; reset]\gb13B15i30I30i32I391i15I
bump  "count objects mapped, print"
	[count _ count + 1.
	count\ 100 = 0 [user clearshow: count asString; space;
		show: oop base8; cr.
		count = stopcount [user ev; show: stopcount asOop base8]]
	]\gb6Bi29I
freelistRectify | i v  "fix bad atom freelist"
	[[UseOldUniqueStrings [] nil].  "dont rectify if new atom names created"
	for i from: (Vmem pmatm to: 0174000 - 0200 by: 0200) do
		[(Vmapper new object: i asObject) UniStroop].
	v _ classtrans lookup: 0602.
	for i from: (2 to: 21) do [vi  nil []
		vi _ vi + 1]
	]\gb16B7i23I36i40I
init   "set up class variables"
	[PCL _ 151.
	classtrans _ Dictionary new init: 32.
	mrefs _ Dictionary new init: 64.
	arefs _ Dictionary new init: 64.
	count _ 1.
	stopcount _ 5 "no stopping".
	clamp _ HashSet new init: 8. 
	"clamp insertall: (ClassA, ClassB, ClassC...).""ones to get rid of"
	USTableOop _ USTable asOop.
	"override this in VirtualMemory giveBirth3"
	UseOldUniqueStrings _ true]\gb7Bi24I148i13I132i43I
mrefsRectify | v zz
	[for v from: mrefs values do
		[v  nil []
		v1 = 0 ["refct ok"]
		v2 = 1 ["nil not on disk"]
		zz _ Pmap obwiz: v2.  "noop"
		image _ Pmap read: 2 at: zz.  "2 words"
		image word: 1 _ (image word: 1) - (v1).
		Pmap writeout: v2 with: image.
		self reset]
	]\gb13B66i10I15i17I27i6I33i9I
noop: noop "give it noop for readin"\gb11Bi
reset [noop _ image _ nil]\gb6B
touchoop | v a i indx "claim pclass, zone, classtrans"
	[(v _ classtrans lookup: (object class) asOop) 
		[indx _ 1 +(Vmem freelist: object).
		a _ self nextfree: vindx.
		vindx _ a1. "not take it" a1]
	 i _ [object class is: Class [1] 20].
	 v _ Vector new: i+1.
	 classtrans insert: (object class) asOop with: v.
	 self touchoop]\gb9B13i32I134i13I
UniStroop | pm0 v indx
	["Unique Strings must get same oop and pclass"
	v _ classtrans lookup: 0602.
	indx _ 1+ (Vmem freelist: object).
	pm0 _ Pmap highPM: oop.
	pm0 and 0  pm0 ["test for new max freelist"
		(oop field: PCL) = (vindx field: PCL) 
		[vindx _ vindx max: oop]] 
	Pmap highpm0: oop gets: (Vmem highPM: oop).
	Pmap ZHB: oop gets: (Vmem ZHB: oop).
	vindx  nil [Pmap newZN: oop.
		vindx _ oop]
	Pmap ZN: oop gets: (Pmap ZN: vindx).
	vindx _ oop min: vindx
	]\gb10B15i45I112i27I
UseOldUniqueStrings: a [UseOldUniqueStrings _ a] "true if do not want atoms remapped"\gb23B26i
writefreelists | v oadd i nlen str
	[self freelistRectify.
	nlen _ 1 + Class instsize. oadd _ 1.
	str _ String new: 4. 
	str word: 1 _ 1. str word: 2 _ 1. "refct=1, link = nil"
	for v from: classtrans values do
		[v  nil []
		image _ Pmap readin: v1.  "noop"
		[v length = 2 
			["a Class" v2  nil []
			image word: (1+nlen) _ v2.
			Pmap writeout: v2 with: str]
		"a Variable Length Class"
		for i to: 20 do
			[v(1+i)  nil  []
			image word: (i+nlen+oadd) _ v(1+i).
			Pmap writeout: v(1+i) with: str] ].
		Pmap writeout: v1 with: image].
	self reset]\gb15B141i21I81i6I23i9I81i25I

As yet unclassified\gbf5 
Addons
	[(dp0 file: 'VmapperAdd.st') filout: (
	)]\gb8B
arefs  "dictionary of UniqueString oops and noops"
	[arefs]\gb7Bi43I
classtrans [classtrans]\gb11B
image [image]\gb6B
mrefs "dictionary of multiple refct oops"
	[mrefs]\gb6Bi35I
noop [noop]\gb5B
object [object]\gb7B
oop [oop]\gb4B
printon: strm
	[oop  nil [super printon: strm]
	strm append: 'Vmapper '; append: oop base8]\gb15B
show | i  "show image of object in base8"
	[for i to: image length/2 do
		[user show: (image base8: i); space.
		i\3 = 0 [user cr]]
	]\gb5B5i31I
\g
SystemOrganization classify: Vmapper under: 'Primitive Access'.\g
