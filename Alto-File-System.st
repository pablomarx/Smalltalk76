'From Smalltalk 5.5k XM November 24 on 5 February 2037 at 11:05:45 pm.'
\g
"AltoFile"l15000z20000\gbf5 
Class new title: 'AltoFile'
	subclassof: File
	fields: 'leader pageAddresses'
	declare: '';
	sharing: AltoFilePool;
	asFollows\gbf5 

A File found on an Alto Model 31(44) disk\gi

Dictionary\gbf5 
close ["to look at at reopen" type _ self updateLeader: (self read: 0)]\gb6B
entryClass [AltoFilePage]\gb11B
open ["don't find last page immediately.  for later close" type _ read]\gb5B2i50I

DictionaryEntry\gbf5 
fileSize ["sn, version, fn, leader, name" 11 + (name length lor: 1)]\gb9B
init [super init.
	pageAddresses _ AltoFileAddressTable new]\gb5B
readFrom: s [
	"read file description from SysDir"
	serialNumber _ s next: 4.
	s skip: 4 "self version: s nextword. s skip: 2".

	leader _ directory virtualToReal: s nextword.
	name _ s nextString.
	s padNext]\gb12B
storeOn: s [
	s append: serialNumber;
		nextword _ 1; nextword _ 0;
		nextword _ (directory realToVirtual: leader);
		nextString _ name; padNext _ 0]\gb11B

File\gbf5 
classInit [
	"before filing in:
		Smalltalk declare: AltoFilePool as: (SymbolTable new init: 32)"
	AltoFilePool
		declare: (CRR CCR CCW CWW "disk commands")
		as: (044100 044120 044130 044150);
		declare: (
			dfmask "bit means active directory entry"
			boffset "byte offset of bit table in DiskDescriptor"
			dirname) as: (02000 040 'SysDir.' );
		declare: (nextp backp numch pagen vn) as: (1 2 4 5 6)]\gb10B4i17I112i13I66i32I14i42I
doCommand: com page: page error: e [
	error _ nullString.
	self dskprim: directory diskNumber address: page address command: com
		page: page page [page]

	error _ self errorString: error "set by dskprim:...".
	self error: e]\gb35B156i7bI11B
endFile: page | nextPage pn [
	[pagefalse ["free all of file" pn _ 1]
	[page full [
		nextPage _ self Write: page.
		"if page was a full last page, next is an empty (and now last) page"
		nextPage lastPage [nextPage]
		page _ self read: page pageNumber+1.
		page empty [page]
		page length: 0]].
	"write last page"
	page header: nextp _ 0.
	self Write: page.
	"free rest of file"
	pn _ page pageNumber].

	lastpn _ false "reset by readPage:".
	while (lastpnfalse and (nextPage _ self read: (pn _ pn+1))) do [
		nextPage init; freePage;
			doCommand: CWW error: 'endFile:'.
		directory deallocate: nextPage].
	[page [pageAddresses position _ (lastpn _ page pageNumber)]].
	page]\gb14B32i16I60i66I118i15I48i17I44i18I
findLastPage [
	self read: 20000.
	lastpn]\gb13B
Get: page | p pn [
	pn _ page pageNumber.
	self Read: page [page]

	"page now contains last page"
	for p from: lastpn to: pn-1 do [
		page pageNumber: p; length: page dataLength.
		"this writes current and allocates next (empty) page"
		page _ self Write: page].
	page]\gb10B61i27I88i51I
Read: page | pn p palen [
	pn _ page pageNumber.
	[pageAddresses [palen _ pageAddresses length]
	pn = 0 [palen _ 0]
	false].

	for p from: (palen min: pn) to: pn do [
		"set up page for checking"
		page
			"zeroed by machine code
			header: nextp _ [p < palen [pageAddresses(p+1)] 0];
			header: backp _ [p=0 [0]; =1[leader] pageAddresses(p-1)];
			length: [p < palen [page dataLength] 0];"
			pageNumber: p;
			address: [p=0 [leader] pageAddressesp];
			doCommand: CCR error: 'readPage:'.
		page lastPage [(lastpn _ p) < pn [false]]
		p  palen and pageAddresses[pageAddresses(p+1) _ page header: nextp]
		"no need to store if already known or no page table"].
	page]\gb11B164i24I13i22I393i50I
sameFile | page s [
	(page _ self newPage: 0) address: leader.
	"if any of following  tests fail, File will be reinitialized"

	("serial number match" (page doCommand: CCR error: false) and
		"correct page number" page pageNumber = 0) and
		[s _ page asStream.
		"last write was by us" type = (s next: 4) and
		[s skip: 8.
		"same name" (name compare: s nextString) = 2]]]\gb9B56i59I7i19I45i19I53i20I43i9I
Write: page | nextPage labelDirty returnPage [
	[(labelDirty _ page lastPage) and page full [
		"last page can't be full, so glue on another page"
		returnPage _ nextPage _ self newPage.
		directory allocate: nextPage after: (directory realToVirtual: page address).
		nextPage init;
			header: backp _ page address;
			pageNumber: (lastpn _ page pageNumber+1);
			serialNumber: serialNumber;
			doCommand: CWW error: 'writePage: (allocate)'.
		"link to current page"
		page header: nextp _ nextPage address.
		pageAddresses [pageAddresseslastpn _ nextPage address]
		"growSmalltalkBy:"]
	returnPage _ page].
	"whenever a last (or second last) page is written, write label also"
	self doCommand: [labelDirty [CWW] CCW] page: page error: 'writePage:'.
	type _ read+write.
	returnPage]\gb12B87i48I300i20I105b16B26i66I

Alto\gbf5 
dskprim: diskNumber "0/1"
	address: a "starting Alto disk address"
	command: com "disk command (usually CCR, CCW, CWW)"
	page: string "string containing label and data"

	["if disk routine encounters an error,
	error _ (DCB status, to be interpreted by errorString:).
	false"

	"if other error occurs, e.g. nil instead of Integer..."
	error _ 1.
	false] primitive: 80\gb20B1i3I3b10B2i26I3b12B2i36I3b12B2i32I6i36I44b12B15i53I
errorString: status | t s [
	"see Alto hardware manual for details on error word format"
	status=1 ['primitive failure, bad args?']
	s _ Stream default.
	s append: (''
		'hardware error or sector overflow'
		'check error'
		'disk command specified illegal sector')(1 + (status land: 3)).
	for t to: 6 do [
		status allmask: (0200 lshift: 1-t) [
			s space; append: (
				'seek failed, possible illegal track'
				'seek in progress'
				'disk unit not ready'
				'hardware late'
				'hardware not transferring'
				'checksum')t]].
	s space; append: status base8.
	s contents]\gb20B10i57I
leader [leader]\gb7B
leader: leader\gb
pageAddresses: pageAddresses\gb
updateLeader: page | s time lastwrite [ 
	"see <Alto>AltoFileSys.D, (p.3 leader page) for further info"
	time _ user timewords.
	s _ page asStream.
	[type anymask: write  [
		"set creation/write read date and name"
		directory flush.
		lastwrite _ time.
		s append: time; append: time; append: time.
		name empty []
		s nextString_ name]
	lastwrite _ s next: 4.
	s skip: 4; append: time].
	self Write: page.

	lastwrite]\gb19B24i59I75i37I
\g
SystemOrganization classify: AltoFile under: 'Alto File System'.\g
AltoFile classInit\g

"AltoFileAddressTable"l15000z20000\gbf5 
Class new title: 'AltoFileAddressTable'
	subclassof: RunVector
	fields: ''
	declare: '';
	asFollows\gbf5 

This class converts to virtual disk addrs which tend to come in consecutive
runs, and can thus use the compact representation of its superclass.\gi

Reading and writing\gbf5 
i | base [base_ superi. dp0 virtualToReal: base+offset]\gb3B
i_ val | virt [
	virt_ dp0 realToVirtual: val.
	starts  nil[superi_ virt. val]
	superi_ virt-i+(starts last).		"superclass tries for constant runs"
	offset>0[val]		"OK if same run"
	values last_ virt. val]		"else fix new run value base"\gb8B
position_ p | l		"shortens (for file shorten)"
	[p>max[user notify: 'invalid extension'] max_ p.
	(l_ starts findSorted: max)<starts length
		[starts_ starts copy: 1 to: l.  values_ values copy: 1 to: l]]\gb12B
\g
SystemOrganization classify: AltoFileAddressTable under: 'Alto File System'.\g

"AltoFileDirectory"l15000z20000\gbf5 
Class new title: 'AltoFileDirectory'
	subclassof: FileDirectory
	fields: 'dirFile bitsFile closed diskPages totalPages nSectors'
	declare: '';
	sharing: AltoFilePool;
	asFollows\gbf5 

\gi

Dictionary\gbf5 
close [
	self obsolete []
	dirFile close.
	[bitsFile  nil ["an interrupted open?"] bitsFile close].
	super close]\gb6B
Delete: file [
	(self deleteEntry: file) open; endFile: false.
	bitsFile flush]\gb13B
entryClass [AltoFile]\gb11B
entrySize: file ["entry size in words" 1 + (file fileSize / 2)]\gb16B
Insert: file | sn page [
	file serialNumber: (sn _ self allocateSN: file).
	"allocate a new page (more success after O.S. stuff, bittable etc.)"
	self allocate: (page _ file newPage) after: 800.
	"write 0th -- leader, in the process filling it in and then creating first page"
	page init; serialNumber: sn; length: page dataLength.
	file leader: page address; type: write; updateLeader: page.
	self addEntry: file]\gb13B64i66I54i78I
nextEntry: file | s elen [
	dirFilenil [
		(file name compare: dirname) = 2 [
			"return system directory file. known serialNumber and leader"
			file serialNumber: 0100000, 0144; leader: 010000.
			file]
		self error: 'directory not open']

	"return the next file entry, ignore deleted entries,
	and leave dirFile positioned before next entry"
	while (s _ dirFile nextword) do [
		elen _ s land: dfmask-1.
		s allmask: dfmask [
			file readFrom: dirFile.
			dirFile skip: elen*2 - (file fileSize + 2).
			file]
		"deleted entry, again"
		dirFile skipwords: elen-1].
	false]\gb16B69i59I104i99I176i20I
obsolete [dirFilenil]\gb9B
open | f s a page len elen type [
	nil  dirFile []

	"assume some defaults in case DSHAPE is not in SysDir leader page.
	these should only be needed if the disk is old (and not scavenged).
	they will not work if a 14 sector system is missing DSHAPE (unlikely) since addresses of first page of directory and of DiskDescriptor might be computed incorrectly.
	in a Smalltalk-76 system, nSectors, diskPages had better eventually match:
		| a. a _ Vmem specialLocs13. mem(a+5), (mem(a+6))
	"
	nSectors _ 12.
	diskPages _ 812*nSectors.
	totalPages _ 2*diskPages.

	"read SysDir leader page to find out file system configuration.  see AltoFileSys.D"
	f _ self find: dirname.

	"to prevent address of page 1 from being stored"
	f pageAddresses: false.

	"length of property list, in words"
	page _ f read: 0.
	len _ page494.

	[len  210 []
	"scan file properties for DSHAPE"
	s _ page asStream.
	s skipwords: page493.
	while len > 0 do [
		type _ s next.
		type = 0 [
			"0 terminates list.  property not found. try to read if from DiskDescriptor"
			len _ 0]

		elen _ s next.
		type = 1 and elen = 5 [
			"DSHAPE. read property"
			self configure: s.
			"set flags so configure and loop are not done again"
			s _ false. len _ 0]

		"skip over other property"
		len _ len - elen.
		s skipwords: elen-1]].

	"now, with the correct (or default) file system configuration,
	store the virtual address of next page (1), and create a FileStream on SysDir"
	a _ AltoFileAddressTable new.
	a1 _ page header: nextp.
	f pageAddresses: a.
	(dirFile _ f asStream) readonly.

	(bitsFile _ self oldFile: 'DiskDescriptor') readwrite.
	[s [
		"configuration not read from SysDir. this will work for 12 sector systems.
		14 sector systems should have had the DSHAPE property"
		self configure: bitsFile]].
	super open.
]\gb5B51i434I75i81I30i46I30i33I57i31I103i79I59i21I28i50I29i24I50i140I182i129I
Position _ entry | name elen s holepos holesize entrysize nlen sk [
	"entry format
		1	n (length in words, including this one) + undeleted bit (dfmask)
		2-3	serialNumber
		4	version
		5	0?
		6	virtual address of page 0
		7-n name as Bcpl string (extra 0 if length even)"

	name _ entry name.
	dirFilenil and (name compare: dirname) = 2 [true]
	self reset.
	holepos _ false.
	holesize _ dfmask.
	nlen _ name length.
	entrysize _ self entrySize: entry "desired entry size".

	while (s _ dirFile nextword) do [
		"entry length in words"
		elen _ s land: dfmask-1.

		[entrysize > elen ["entry too small" sk _ 2]

		s = elen [
			"deleted entry. check hole size for later inserting or renaming"
			sk _ 2.
			elen < holesize[
				"hole is the smallest so far"
				holesize _ elen. holepos _ dirFile position]]

		"normal entry, big enough"
		dirFile skip: 10.
		nlen  dirFile next ["name wrong size" sk _ 13]

		sk _ 13 - nlen.
		(name compare: (dirFile next: nlen)) = 2 [
			"name match, position back to beginning of entry"
			dirFile skip: sk.
			entry]].

		"sk is the character offset from the entry header word to the next entry"
		dirFile skip: elen*2 + sk].

	[holepos [dirFile position _ holepos-2] "at end of dirFile"].
	false]\gb17B53i200I186i18I44i21I53i15I30i62I40i27I56i24I47i15I82i47I40i71I76i17I
release [dirFile _ bitsFile _ nil]\gb8B
reset [
	[self obsolete [self open] self flush].
	dirFile readonly; reset]\gb6B

FileDirectory\gbf5 
allocateSN: file | sn [
	bitsFile position _ 010.
	sn _ bitsFile next: 4.
	[(sn word: 2 _ (sn word: 2) + 1) = 0 [
		"overflow" sn word: 1 _ (sn word: 1) + 1]].
	bitsFile skip: 4; append: sn.
	sn]\gb17B101i8I
checkName: s [self checkName: s fixing: false]\gb13B
realToVirtual: adr ["see virtualToReal:.
	Alto address format is
	bits
	0-3	sector number (0 - 015, i.e. 12 or 14 sectors)
	4-12	cylinder number (0 - 0312, Model 31; 0-0625, Model 44)
	13		head number (0-1)
	14		disk number	(0-1)
	15		restore bit.

	in a system with two separable disks, addresses on disk 1 have a 0 disk bit, which is complemented by the disk primitive"

	"vadr _" ("sector: field" adr lshift: 12) +
	("cylinder and head: field*" nSectors * ((adr land: 07774) lshift: 2)) +
	("disk: field*pages per disk" [(adr land: 2) = 2 [diskPages] 0]
		"diskPages*(adr land: 2)/2")

	"vadr < 0 or vadr  totalPages [
		self error: 'illegal disk address']"]\gb19B6b14B3i328I16i13I24i25I50i26I
rename: file newName: newName | holesize pos [
	[newName _ self checkName: newName [
		self position _ newName [self error: 'new name already exists: ' + newName]
		"a possible insertion place"
		pos _ dirFile position]
	self error: 'illegal new name: ' + newName].

	self Find: (file _ self makeEntry: file) [
		holesize _ dirFile nextword land: dfmask-1.
		dirFile skip: 2.
		file name: newName.
		[(self entrySize: file "new size of entry")  holesize [
			"new entry will fit in current entry"
			pos _ dirFile position.
			"read and save entry"
			self nextEntry: file]
		"delete and save entry"
		self deleteEntry: file].

		"position to same entry or hole discovered earlier"
		dirFile position _ pos.
		self addEntry: (file name: newName).
		file type is: Integer [
			"file is open. defer leader page change until someone closes it"
			file type: write]
		"close file: updating name in leader page" file type: write; close]
		
	file error: 'rename: old name does not exist']\gb30B138i26I234i17I21i35I33i19I30i21I33i49I
virtualToReal: vadr | t2 d ["inverse of realToVirtual:"
	"vadr < 0 or vadr  totalPages [
		self error: 'illegal virtual address']"

	"faster to do /\ for normal Integers"
	"t _ vadr intdiv: diskPages.
	sec _ t2 intdiv: nSectors"

	[vadr < diskPages [
		d _ 0.
		t2 _ vadr]
	d _ 2.
	t2 _ vadr \ diskPages].

	("sector" (t2 \ nSectors) lshift: 12) +
	("cylinder & head" (t2 / nSectors) lshift: 2) +
	("disk" d "(vadr / diskPages) lshift: 1")]\gb20B9i11bI14B262i6I35i15I34i4I

Alto\gbf5 
addEntry: file | entrysize holesize [
	"called only by Insert: and rename:newName:"
	[holesize _ dirFile nextword [
		"either a deleted entry or rename entry"
		holesize _ holesize land: dfmask-1.
		dirFile skip: 2]
	"at end"].

	entrysize _ self entrySize: file.
	dirFile readwrite;
		nextword _ entrysize + dfmask.
	file storeOn: dirFile.

	[holesize and entrysize < holesize [
		"mark remaining hole"
		dirFile nextword _ holesize-entrysize]].
	dirFile readonly.
	bitsFile flush]\gb15B25i15bI7Bi5bI15B38i38I62i6I161i19I
allocate: nextPage after: address | index stop ch m vadr [
	index _ false.
	while true do [
		"go around bittable from address to end, and beginning to address.
		we start over again if the table appears full or bitsFile is out of sync"
		[index and stop  totalPages [
			"wrap around to where we started"
			stop _ address.	
			index _ 0]
		[index  false ["first time or bitsFile out of sync"]
		"disk probabbly full"
		user quitThen:
'//   YOUR DISK IS FULL - Please make some space available.
//   Then resume Smalltalk and interrupt or continue as desired...'].

		self open.
		"index by bits rather than bytes? close enough for now"
		index _ address land: 0177770.
		stop _ totalPages].

		bitsFile position _ index/8 + boffset.
		while (index and (index _ index+8)  stop) do [
			(ch _ bitsFile next) = 0377 ["8 full"]
			"check that bitsFile position is correct --
				possibly out of sync with index if  growSmalltalkBy: occurred?"
			bitsFile position  (index/8 + boffset) [index _ false]
	
			m _ 0200.
			for vadr from: index-8 to: index-1 do [
				[(ch land: "nomask:" m) = 0 [
					"page appears free. first update DiskDescriptor"
					bitsFile skip: 1; next _ ch _ ch lor: m.
					"then check if page is really free"
					vadr=0 ["O.S. boot"]
					([nextPage init; freePage;
						address: (self virtualToReal: vadr);
						doCommand: CCR error: false]) [vadr]
					"page not really free"]
				"page not free according to bit"].
				m _ m lshift: 1].
		].
	]]\gb34B63i140I40i37I51i34I6i19I166i53I186i6I7i109I163i46I54i35I16i9I129i20I8i30I
checkName: fname fixing: fixing | x copy special [
	fname empty[
		fixing ['$']
		"empty name" false]

	[fname length > 38
		[fixing [fname _ fname(1 to: 38)]
		"name too long" false]].

	copy _ (String new: fname length+1) asStream.
	special _ '.-+$!?'.
	for x from: fname do [
		"check characters: alphanumeric or 6 special"
		x isletter or ((special has: x) or x isdigit)  [copy next _ x]
		fixing [copy next _ special2]
		"illegal character" false].

	[fixing [fname last = (special1) [copy skip: 1]]
	fname last  (special1) [copy next _  special1]].
	copy contents]\gb32B
configure: s | nDisks nHeads nTracks [
	"read disk configuration from a Stream:
		either leader page of SysDir or beginning of DiskDescriptor"
	nDisks _ s nextword.
	nTracks _ s nextword.
	nHeads _ s nextword.
	nSectors _ s nextword.

	diskPages _ nTracks * nHeads * nSectors.
	totalPages _ nDisks * diskPages]\gb13B
deallocate: page | index ch m [
	[dirFilenil [self open]].
	index _ self realToVirtual: page address.
	"character position"
	bitsFile position _ index/8 + boffset.
	ch _ bitsFile next.
	"bit position"
	m _ 0200 lshift: 0-(index land: 7).
	"make page free by turning off bit in DiskDescriptor"
	(ch land: m) = m [bitsFile skip: 1; next_ ch - m]
	user cr; show: 'page already free (dealloc:)']\gb17B89i18I65i12I40i53I
deleteEntry: file | p [
	"called only by Delete: and rename:newName:
	read and save"
	p _ dirFile position.
	self nextEntry: file.
	dirFile position _ p.

	"delete it from directory (turn off bit in entry length word)"
	p _ dirFile nextword land: dfmask-1.
	dirFile skip: 2; readwrite; nextword _ p; readonly; skip: 2.
	file]\gb18B8i15bI7Bi5bI15Bi15I74i60I
diskID | f u [
	"return user name and disk name installed in O.S."
	(f _ self oldFile: 'sys.boot') readonly; position _ 512.
	u _ f nextString.
	f padNext.
	u _ u, f nextString.
	f close.
	u]\gb7B10i48I
diskNumber ["directory is: Integer [" directory "] directory diskNumber"]\gb11B
filesMatching: pattern | files v i [
	files _ self match: [pattern last = ('.'1) [pattern] pattern + '.'].
	v _ Vector new: files length.
	for i to: v length do [vi _ (filesi) name].
	v]\gb23B
flush [bitsFilenil [] bitsFile flush]\gb6B
freePages | npages ch i [
	self open.
	bitsFile position _ boffset.
	npages _ 0.
	for i from: 1 to: totalPages by: 8 do [
		(ch _ bitsFile next) =0377 ["all used"]
		"possibly up to 8 unused"
		npages _ npages+8.
		until ch = 0 do [
			npages _ npages - (ch land: 1).
			ch _ ch lshift: 1]].
	npages]\gb10B146i8I6i23I
growSmalltalkBy: n | zfpt i file page a zlen ["dp0 growSmalltalkBy: 100."
	"find and read last page of small.boot, then extend file"
	i _ 1. zlen_ 96.
	zfpt _ CoreLocs new base: (Vmem specialLocs7) length: zlen*2.
	until zfpt(i+zlen) = 0 do [i _ i+1].
	a _ (zfpt(i+zlen-1)) + (zfpti) - (zfpt(i-1)) - 1.

	self open.
	file _ self makeEntry: 'small.boot.'.
	page _ file newPage.
	page address: (self virtualToReal: a);
		doCommand: CRR error: 'cannot read last page. growSmalltalkBy:'.

	"bypass reading file and creating random access table, just extend it"
	page lastPage [
		file serialNumber: page serialNumber;
			lastPage: page pageNumber;
			pageAddresses: false "Read:, Write: check this";
			Get: (page pageNumber: page pageNumber+n).
			user space; print: self freePages; show: ' pages left.']
	self error: 'growSmalltalkBy:. last page not last or 2 successive user grows']\gb19B57i55I363i68I115b13Bi11I
stampBoot | a file page ["dp0 stampBoot."
	"update the time stamps in leader page of current boot file"

	"find SafeId for current boot file"
	a _ Vmem specialLocs13.
	file _ self makeEntry: ''.
	file serialNumber: mema, (mem(a+1)).

	"read page one of the boot file to find out the leader address"
	page _ file makeEntry: 1.
	page address: mem(a+4).

	"then set leader address and dirty flag, and close file
		thereby updating create/write/read dates, but not name"
	file doCommand: CCR page: page error: 'cannot read page 1 of boot file';
		leader: (page header: backp);
		type: write;
		close]\gb10B
\g
SystemOrganization classify: AltoFileDirectory under: 'Alto File System'.\g

"AltoFilePage"l15000z20000\gbf5 
Class new title: 'AltoFilePage'
	subclassof: FilePage
	fields: 'address'
	declare: '';
	sharing: AltoFilePool;
	asFollows\gbf5 

A FilePage from an AltoFile consists of a header (2 words), a label (8 words) and data (512 characters)\gi

FilePage\gbf5 
address [address]\gb8B
address: address\gb
headerLength [16]\gb13B
init [
	page  nil [super init]
	"nextp, backp, lnused, numch, pn"
	page fill: 1 to: 10 with: 0]\gb5B30i31I
lastPage [("self header:" page word: nextp) = 0]\gb9B
length ["self header:" page word: numch]\gb7B
length: len ["self header:" page word: numch _ len]\gb12B
pageNumber ["self header:" page word: pagen]\gb11B
pageNumber: pn ["self header:" page word: pagen _ pn]\gb15B
serialNumber [page(13 to: 16)]\gb13B
serialNumber: sn ["page(13 to: 16) _ sn"
	page copy: 13 to: 16 with: sn from: 1 to: 4.
	"self header:" page word: vn _ 1 "fixed version"]\gb17B

Alto\gbf5 
freePage [
	"label for a free page: version, sn1, sn2 = 1"
	page fill: 11 to: 16 with: 0377]\gb9B4i45I
\g
SystemOrganization classify: AltoFilePage under: 'Alto File System'.\g
