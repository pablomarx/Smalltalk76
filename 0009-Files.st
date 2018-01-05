'From Smalltalk 5.5k XM November 24 on 22 November 1980 at 2:57:08 am.'
\g
"File"l15000z20000\gbf5 
Class new title: 'File'
	subclassof: Dict
	fields: 'directory type name serialNumber pageReaders pageBuffer lastpn error'
	declare: '';
	sharing: FilePool;
	asFollows\gbf5 

A collection of FilePages usually on some device external to the virtual memory, which can be viewed and modified. File is a generalization: some examples are AltoFile and WoodstockFile. FilePage and FileDirectory are related classes. FileStream provides Stream access to Files.

Subclasses should override any superclass message implemented as [self subError]\gi

Documentation\gbf5 
help "

A common way to access a File is through a FileStream.
	to create a FileStream on either an old or new file:
		<FileStream> ← <FileDirectory> file: <String>. (see also oldFile: and newFile:)
	e.g. f ← dp0 file: 'test'.

	The default access mode (readwriteshorten) allows you to read or write, and
	automatically shorten a File (to its current position) upon closing).  If you want to
	only read a file, readonly mode is faster and safer.

Some common ways to access a FileStream (see Stream and FileStream):
	reading a character (an Integer between 0 and 255)
		next, ◦
	reading a String of characters
		upto:	, next:, nextString, contents
	reading other kinds of objects
		nextword, word:, nextNumber:, nextParagraph

	writing characters
		next←, ◦←
	writing a String of characters
		append:, nextString←
	writing other kinds of objects
		nextword, word:←, print:

	finding position
		position, wordposition, length, end, positionSize:

	changing position (besides reading/writing)
		position←, skip:, skipTo:, reset, settoend, wordposition←, position:size:

When finished with a FileStream, <FileStream> close.

For information about using or creating other views of file organizations (Btree, file-based object dictionaries, Findit), about WFS and Juniper files, and general file problems, see Steve Weyer.
"\gb5B28b4B14b10B89b5B21b8B5b8B57b16B141b8B73b6B5b10B57b7B35b35B35b43B24b9B35b20B35b24B22b50B47b76B47b5B78b5B

Dictionary\gbf5 
close\gb
entryClass ["a subclass of FilePage" self subError]\gb11B2i22I
Find: page [⇑page pageNumber ≤ lastpn]\gb11B
found: page ["read an existing page" self subError]\gb12B2i21I
makeEntry: page [
	page is: self entryClass⇒ [page init; serialNumber: serialNumber. ⇑page]
	⇑[(self entryClass new) dictionary: self;
		init; pageNumber: page; serialNumber: serialNumber]]\gb16B
open ["compute lastpn" self findLastPage]\gb5B2i14I
release\gb
reopen [
	[self sameFile⇒ []
	"init and directory access"
	directory get: self init].
	self open]\gb7B24i25I

DictionaryEntry\gbf5 
dictionary [⇑directory]\gb11B
dictionary: directory\gb
init [lastpn ← false. error ← nullString. serialNumber ← String new: 4]\gb5B
match: entry [⇑self name match: entry name]\gb13B
name [⇑name]\gb5B
name: name\gb
printon: strm [strm append: name]\gb14B

Initialize\gbf5 
classInit [
	"subclasses of File may want to share variables in pools.
	execute before filin:
		Smalltalk declare: ↪XFilePool as: (SymbolTable new init: 16).
	in classInit: XFilePool declare: ↪() as: ↪()"

	FilePool declare: ↪(read write shorten) as: ↪(1 2 4)]\gb10B4i79I66i13I
sameFile "is File's current internal representation the same as what is stored externally? if so, usually can avoid some initialization, directory lookup"
	[⇑false]\gb9B1i143I

Name\gbf5 
serialNumber [⇑serialNumber]\gb13B
serialNumber: s [
	"stored as a String of 4 characters rather than as various Numbers"
	s is: String⇒ [serialNumber ← s]
	s is: Substring⇒ [serialNumber ← s copy]
	s is: Integer⇒ [serialNumber word: 1 ← 0; word: 2 ← s]
	"Vector of Integers"
	serialNumber word: 1 ← s◦1; word: 2 ← s◦2]\gb16B4i65I136i18I

FileDirectory\gbf5 
delete [⇑directory delete: self]\gb7B
directory [⇑directory]\gb10B
directory: directory\gb
rename: newName [⇑directory rename: self newName: newName]\gb16B
type [⇑type]\gb5B
type: type "used by different Files in different ways, e.g. read/write mode"\gb11B

File Length\gbf5 
endFile: page [
	"make File end with this FilePage. false means delete all of File"
	self subError]\gb14B4i64I
findLastPage [
	"the default definitions for findLastPage and length are circular.
	at least one of them must be defined by a subclass"

	⇑lastpn ← self pageFrom: self length]\gb13B4i28bI12Bi5bI6Bi68I
lastFullPage [(self read: self lastPage) full⇒ [⇑lastpn] ⇑lastpn-1]\gb13B
lastPage ["length in pages"
	lastpn⇒ [⇑lastpn] ⇑self findLastPage]\gb9B2i15I
lastPage: lastpn "for those who know what they're doing"\gb17B1i37I
length | page [
	"length in characters"
	page ← self read: self lastPage.
	⇑lastpn-1 * page dataLength + page length]\gb7B11i20I
pageFrom: len [
	"compute page number for a character index"
	⇑(len-1 / self entryClass new dataLength) asSmall+ 1]\gb14B4i41I

FilePage\gbf5 
doCommand: com page: page error: s [
	"execute a File command on page. if an error occurs, include
	error ← 'some error message'.
	⇑self error: s
	if s is false, returns false.
	otherwise s is passed to an error routine" self subError]\gb35B4i61I47i72I
error [⇑error]\gb6B
error: e [
	e⇒ [e ← [(Stream default) append: name; append: ' in '; append: e;
			append: ', '; append: error; contents].
		error ← nullString.
		⇑super error: e]
	⇑false]\gb9B
Get: page | p pn [
	pn ← page pageNumber.
	p ← self Read: page⇒ [⇑p]

	"current last page of the file is assumed full"
	for⦂ p from: lastpn+1 to: pn-1 do⦂ [
		page pageNumber: p.
		page ← self Write: page].

	"return an empty last page which is not written yet"
	page pageNumber: pn; length: 0.
	⇑page]\gb10B62i45I93i50I
get: pn [⇑self Get: (self makeEntry: pn)]\gb8B
newPage [⇑self makeEntry: 0]\gb8B
newPage: pn [⇑self makeEntry: pn]\gb12B
Read: page ["return page or false" self subError]\gb11B2i20I
read: pn [⇑self Read: (self makeEntry: pn)]\gb9B
Write: page [
	"update lastpn, write page and return result (maybe next page)"
	self subError]\gb12B4i7bI6Bi48I

FileStream\gbf5 
asStream [⇑(FileStream new) on: [self open; get: 1]]\gb9B
\g
SystemOrganization classify: ↪File under: 'Files'.\g
File classInit\g

"FileDirectory"l15000z20000\gbf5 
Class new title: 'FileDirectory'
	subclassof: Dict
	fields: 'directory fileReaders'
	declare: '';
	sharing: FilePool;
	asFollows\gbf5 

A collection of Files. FileDirectory is a generalization: some examples are AltoFileDirectory and WoodstockFileDirectory\gi

Dictionary\gbf5 
checkName: s [
	"default behavior is to get rid of ending period.
	subclasses can do any kind of checking they want and
	return false if name is no good"

	s empty or⦂ s last ≠ ('.'◦1)⇒ [⇑s]
	⇑s copy: 1 to: s length-1]\gb13B4i135I
close [
	self obsolete⇒ []
	externalViews delete: self.
	self release]\gb6B
entryClass ["a subclass of File" self subError]\gb11B2i18I
error: e entry: file [⇑file error: e]\gb21B
Find: file | name [
	name ← self checkName: file name⇒ [
		file name: name.
		⇑self Position ← file]
	file error: 'illegal name']\gb11B
insert: file | old [
	"note: this changes the default behavior found in Dict.
	this creates a new version rather than generating an error if the name exists"

	file ← self makeEntry: file.
	[self versionNumbers⇒ [
		"ignore explicit version and directory will create a next version"
		file ← self makeEntry: (file name asStream upto: '!'◦1)]

	self Find: file⇒ [
		old ← self makeEntry: (file name + '$').
		"otherwise, if the file already exists,
		rename it to name$, deleting that file first if it exists"
		[self Find: old⇒ [self Delete: old]].
		self rename: file name newName: old name.
		"reposition to original name"
		self Find: file⇒ [self error: 'insert/rename ??' entry: file]]
	"file didn't exist"].

	self Insert: file.
	⇑file]\gb13B
open [externalViews insert: self]\gb5B
printon: strm [
	strm append: [self obsolete⇒ ['a closed '] 'an open '];
		append: self class title;
		append: ' on '.
	self server printon: strm]\gb14B

DictionaryEntry\gbf5 
dictionary [⇑directory]\gb11B
dictionary: directory\gb

Initialize\gbf5 
directory: directory\gb

File\gbf5 
allocateSN: file ["allocate a new serial number for a File" self subError]\gb17B2i39I
directory [⇑directory]\gb10B
newPage ["return a dummy FilePage from a dummy File"
	⇑(self makeEntry: nullString) newPage]\gb8B2i41I
versionNumbers ["generally, version numbers are not supported" ⇑false]\gb15B

FileStream\gbf5 
file: name [⇑(self get: name) asStream]\gb11B
filin: s [self filin: s format: 1]\gb9B
filin: s format: ft [
	"read Class definitions or Changes from FileStreams or PressFiles
	ft: 1 (FileStream=Bravo), 2 (Press)"

	user displayoffwhile⦂ [
	s is: Vector⇒ [for⦂ s from: s do⦂ [self filin: s format: ft]]

	"special case for Alto and patterns"
	(s is: String) and⦂ ((s has: '*'◦1) or⦂ (s has: '#'◦1))⇒ [
		self filin: (self filesMatching: s) format: ft]

	[s is: UniqueString⇒ ["Class name" s ← s + [ft=1⇒ ['.st'] '.press']]].

	([ft=1⇒ [self oldFile: s] self pressfile: s]) filin]]\gb20B4i101I94i34I137i10I
newFile: name [⇑(self insert: name) asStream]\gb14B
oldFile: name [⇑(self find: name) asStream]\gb14B
pressfile: name [⇑PressFile new of: (self file: name)]\gb16B
pressfilin: s [self filin: s format: 2]\gb14B

FTP\gbf5 
asFtpDirectory | ftp [
	"to allow convenient (kludgey) access to file servers (e.g. phylum, dpj) via Ftp"
	(ftp ← FtpDirectory new) server: self server; open.
	[ftp userName empty⇒ [ftp login: self userName password: self userPassword]].
	⇑ftp]\gb15B
login: name [⇑self login: name password: '' "or prompt?"]\gb12B33i10I
login: name password: pw [self subError]\gb25B
retrieve: s | t [
	s is: Vector⇒ [for⦂ t from: s do⦂ [self retrieve: t as: t]]
	⇑self retrieve: s as: s]\gb12B
retrieve: s1 as: s2 | f [
	[self exists: s1⇒ [f ← self oldFile: s1] ⇑false].
	f readonly.
	([s2 is: FileStream⇒ [s2] dp0 file: s2]) append: f; close.
	f close]\gb20B
server [⇑directory]\gb7B
server: directory\gb
store: s | t [
	s is: Vector⇒ [for⦂ t from: s do⦂ [self store: t as: t]]
	⇑self store: s as: s]\gb9B
store: s1 as: s2 | f [
	[s1 is: FileStream⇒ [f ← s1] dp0 exists: s1⇒ [f ← dp0 oldFile: s1] ⇑false].
	f readonly.
	(self file: s2) append: f; close.
	f close]\gb17B
userName [⇑[currentProfile≡nil⇒ [''] currentProfile userName: self server]]\gb9B
userPassword [⇑[currentProfile≡nil⇒ [''] currentProfile userPassword: self server]]\gb13B

Juniper\gbf5 
closeTransaction "default is to do nothing"\gb17B1i24I
exceptionHandler: eh "default is to do nothing"\gb21B1i24I
\g
SystemOrganization classify: ↪FileDirectory under: 'Files'.\g

"FilePage"l15000z20000\gbf5 
Class new title: 'FilePage'
	subclassof: Dict
	fields: 'file page'
	declare: '';
	sharing: FilePool;
	asFollows\gbf5 

A block, chunk, or page of information from some collection of pages (a File).  FilePage is a generalization: some examples are AltoFilePage and WoodstockFilePage\gi

Dictionary\gbf5 
◦i [⇑page◦(self checkIndex: i)]\gb3B
◦i ← v [⇑page◦(self checkIndex: i) ← v]\gb7B
asStream [⇑self asStream: Stream new]\gb9B
reopen [file reopen; makeEntry: self "self may have been released"]\gb7B31i27I

DictionaryEntry\gbf5 
dictionary [⇑file]\gb11B
dictionary: file\gb
init [
	[page≡nil⇒ ["self page:" page ← String new: self pageLength]].
	self length: 0"not sure who depends on this besides FileStream read:"]\gb5B
name: sp [self init; serialNumber: sp◦1; pageNumber: sp◦2]\gb9B

Initialize\gbf5 
file: file\gb
page: page\gb

File\gbf5 
doCommand: com error: s [⇑file doCommand: com page: self error: s]\gb24B
endFile [⇑file endFile: self]\gb8B
file [⇑file]\gb5B
get: pn ["recycle self" self pageNumber: pn; length: 0. ⇑file Get: self]\gb8B2i12I
read: pn ["recycle self" self pageNumber: pn; length: 0. ⇑file Read: self]\gb9B2i12I
write [
	"some files, e.g. AltoFile, will return a last empty page instead of a full one"
	⇑file Write: self]\gb6B4i78I

Page\gbf5 
address ["page address, e.g. on a disk" self subError]\gb8B2i28I
address: a [self subError]\gb11B
asStream: s | offset [
	offset ← self headerLength.
	⇑s of: self dataString from: offset+1 to: offset+self length "self dataEnd"]\gb12B
checkIndex: i [
	i > 0 and⦂ i ≤ self length⇒ [⇑i + self headerLength]
	self error: 'illegal index']\gb14B
dataBeginning [⇑self headerLength]\gb14B
dataEnd ["logical end of data in page" ⇑self headerLength + self length]\gb8B2i27I
dataEnd: pos [self length: pos - self headerLength]\gb13B
dataLength ["physical length of data in page. default" ⇑512]\gb11B2i40I
dataMaxEnd ["physical end of data in page" ⇑self headerLength + self dataLength]\gb11B2i28I
dataString [⇑page]\gb11B
full [⇑self length = self dataLength]\gb5B
header: n ["return n-th header word" ⇑page word: n]\gb10B2i23I
header: n ← v ["set and return n-th header word" ⇑page word: n ← v]\gb14B2i31I
headerLength ["length of stuff before data begins in page" ⇑0]\gb13B2i42I
lastPage ["is this last page in file?" ⇑self pageNumber ≥ file lastPage]\gb9B2i26I
length ["logical length of data in page" self subError]\gb7B2i30I
length: len [self subError]\gb12B
page [⇑page]\gb5B
pageLength ["physical size of page"
	⇑self headerLength + self dataLength + self trailerLength]\gb11B2i21I
pageNumber [self subError]\gb11B
pageNumber: pn [self subError]\gb15B
serialNumber [⇑file serialNumber]\gb13B
serialNumber: sn [self subError]\gb17B
trailerLength ["length of stuff after data ends in page" ⇑0]\gb14B2i39I
word: i ["no bounds checking" ⇑page word: self headerLength/2 + i]\gb8B2i18I
word: i ← v ["no bounds checking" ⇑page word: self headerLength/2 + i ← v]\gb12B2i18I
\g
SystemOrganization classify: ↪FilePage under: 'Files'.\g

"EtherFilePage"l15000z20000\gbf5 
Class new title: 'EtherFilePage'
	subclassof: FilePage
	fields: ''
	declare: '';
	asFollows\gbf5 

A FilePage which consists of an ethernet packet (Pacbuf) containing network information, header info and data\gi

FilePage\gbf5 
dataString [⇑page pupString]\gb11B
header: n [
	"for accessing information after pup header, e.g. file commands and parameters.
	n = 1 to (self headerLength-24)/2"
	⇑page word: 12+n]\gb10B4i113I
header: n ← v [⇑page word: 12+n ← v]\gb14B
headerLength [⇑44 "ethernet encap.(4), pup header(20), file label (20=default)"]\gb13B6i59I
init [
	[page≡nil⇒ ["self page:" page ← file allocatePage]].
	self length: 0]\gb5B
length [⇑page pupLength - (self headerLength - 2)]\gb7B
length: len [page pupLength ← len + self headerLength - 2]\gb12B
trailerLength [⇑2 "checksum"]\gb14B5i8I

Ether\gbf5 
packet [⇑page]\gb7B
pupType [⇑page pupType]\gb8B
pupType← p [⇑page pupType← p]\gb11B
\g
SystemOrganization classify: ↪EtherFilePage under: 'Files'.\g

"FileStream"l15000z20000\gbf5 
Class new title: 'FileStream'
	subclassof: Stream
	fields: 'page dirty rwmode'
	declare: '';
	sharing: FilePool;
	asFollows\gbf5 

A Stream which windows a File. see File example\gi

Dictionary\gbf5 
close [
	self obsolete⇒ []
	[self writing⇒ [
		rwmode anymask: shorten⇒ [self shorten]
		self flush]].
	"self release (sort of)"
	dirty ← limit ← 0.
	self file close.
	externalViews delete: self]\gb6B
file [⇑page file]\gb5B
obsolete [⇑dirty]\gb9B
release [
	self obsolete⇒ []
	dirty ← limit ← 0.
	self file release]\gb8B
reopen | pos [
	dirty "self obsolete"⇒ [
		"reopen to current position"
		pos ← position.
		self read: page pageNumber⇒ [position ← pos min: limit]
		"if that page doesn't exist, go to last one that does.
		note that settoend would be recursive"
		self read: (self file lastPage)⇒ [position ← limit]
		self error: 'cannot reopen or settoend']
	⇑false]\gb7B37i26I81i93I

Initialize\gbf5 
on: page "some page from a File, usually page 1, or another FileStream" [
	[page is: FileStream⇒ [page ← page page]].
	page asStream: self.
	externalViews insert: self.
	"obsolete flag"
	dirty ← false]\gb9Bi61I

Access Modes\gbf5 
readonly [self setMode: read]\gb9B
readwrite [
	"allow read and write but don't automatically shorten"
	self setMode: read + write]\gb10B4i52I
readwriteshorten ["allow read and write and shorten File upon closing"
	self setMode: read+write+shorten]\gb17B2i50I
setMode: m [
	rwmode = m⇒ []
	"don't flush if first time or not write mode or continuing write mode"
	[rwmode≡nil or⦂ ((rwmode nomask: write) or⦂ (m anymask: write))⇒ []
	self flush].
	rwmode ← m]
\gb11B20i68I
writeshorten ["allow write and shorten File upon closing. in general, this would be faster for overwriting Files since pages might not have to be read first. at present, treated same as readwriteshorten"
	self setMode: write+shorten]\gb13B2i171bI16B
writing [
	rwmode≡nil⇒ ["default mode. true" ⇑self readwriteshorten]
	⇑(rwmode land: write) = write]\gb8B17i18I

Stream\gbf5 
◦i [
	self position ← i-1.
	⇑self next]\gb3B
◦i ← v [
	self position ← i-1.
	⇑self next ← v]\gb7B
append: s [
	"try to make some special cases go much faster"
	[s is: String⇒ [
		s length > 80⇒ [self writeString: s from: 1 to: s length. ⇑s]]
	s is: Stream⇒ [
		(s limit - s position > 80) and⦂ (s asArray is: String)⇒ [
			self writeString: s asArray from: s position+1 to: s limit. ⇑s]]
	s is: FileStream⇒ [
		self writeFile: s for: nil. ⇑s]
	].

	⇑super append: s]\gb10B
contents | s ["read all of a File"
	self readonly; reset.
	s ← self next: self length.
	self close.
	⇑s]\gb9B6i18I
end [
	self reopen.
	position < limit⇒ [⇑false]
	self read: page pageNumber+1⇒ [⇑"page empty" position = limit]
	⇑true]\gb4B
into: s endError: err | charsRead len t [
	len ← s  length.
	[len > 80⇒ [
		charsRead ← len - (self readString: s from: 1 to: len)]

	"in line: super into: s endError: err"
	charsRead ← 0.
	"read until count or stream is exhausted"
	while⦂ (charsRead < len and⦂ (t ← self next)) do⦂ [s◦(charsRead ← charsRead+1) ←t]].

	err⇒ [
		charsRead = len⇒ [⇑s]
		user notify: 'only read first ' + charsRead asString]
	⇑charsRead]\gb22B
length [
	page lastPage⇒ [⇑page pageNumber-1 * page dataLength + page length]
	⇑self file length]\gb7B
next: n from: strm [
	n > 80 and⦂ (strm is: FileStream)⇒ [self writeFile: strm for: n]
	⇑super next: n from: strm]\gb19B
pastend [
	self reopen or⦂ (page lastPage≡false and⦂ self nextPage)⇒ [⇑self next]
	⇑false]\gb8B
pastend← v [
	self writing⇒ [
		self reopen⇒ [⇑self next ← v]
		[limit < page dataMaxEnd or⦂ [
			self nextPage⇒ [position=limit]
			self error: 'could not get page']⇒ [limit ← page dataMaxEnd]].
		⇑self next← v]
	self error: 'no writing allowed']\gb11B
position [⇑self positionSize: 1]\gb9B
position← p [⇑self position: p size: 1]\gb12B
printon: strm [
	super printon: strm.
	strm append: ' on '.
	self file printon: strm]\gb14B
reset ["self position ← 0"
	self read: 1⇒ []
	self error: 'reset']\gb6B
settoend ["self position ← self length"
	"make sure file is open so lastPage is correct"
	self reopen.
	"when writing on the last page, lastPage may be too small"
	self read: (self file lastPage max: page pageNumber)⇒ [position ← limit]
	self error: 'settoend???']\gb9B33i45I18i56I
skip: n | p plen [
	n=0⇒ []
	self reopen.
	p ← position + n.
	[n > 0⇒ [p ≥ limit]
	self fixEnd "important on last page".
	p < page dataBeginning]⇒ [
		"simply: self position ← self position + n.
		however, since we are incurable optimizers..."
		plen ← page dataLength.
		"assume p is not Large, otherwise use intdiv:"
		p ← p - page dataBeginning.
		self positionPage: (page pageNumber + [n < 0⇒ [(p+1)/plen - 1] p/plen])
			character: p \ plen⇒ []
		self error: 'cannot skip ' + n asString]

	"same page"
	position ← p]\gb8B88i22I34i90I31i44I179i9I
word: i [
	self wordposition ← i-1.
	⇑self nextword]\gb8B
word: i ← v [
	self wordposition ← i-1.
	⇑self nextword ← v]\gb12B
wordposition [⇑self positionSize: 2]\gb13B
wordposition← w [⇑self position: w size: 2]\gb16B

File\gbf5 
directory [⇑self file directory]\gb10B
fixEnd [
	self writing and⦂ position > page dataEnd⇒ [
		"fix the end of page"
		page dataEnd: (limit ← position)]]\gb7B51i19I
flush [
	self obsolete⇒ [⇑page]
	self fixEnd.
	⇑page write]\gb6B
name [⇑self file name]\gb5B
nextPage [⇑self read: page pageNumber+1]\gb9B
pad: size | rem [
	"skip to next boundary of size and return how many characters skipped"
	rem ← (([page dataLength \ size = 0⇒ [
		position - page dataBeginning] self position]) \ size) asSmall.
	rem = 0⇒ [⇑0]
	self skip: size - rem.
	⇑size - rem]\gb10B
pad: size with: val | rem [
	"pad to next boundary of size and return how many characters padded"
	rem ← (([page dataLength \ size = 0⇒ [
		position - page dataBeginning] self position]) \ size) asSmall.
	rem = 0⇒ [⇑0]
	self next: size - rem ← val.
	⇑size - rem]\gb20B
page [⇑page]\gb5B
position: objpos size: size | len pn c pos [
	"set the current character position and the current page
	from the position of an object of a given size (see positionSize:)"

	len ← page dataLength.
	[size = len⇒ ["page size" pn ← objpos+1. c ← 0]

	pos ← objpos.
	[size = 1⇒ []
	len \ size = 0⇒ ["page length is a multiple of size" len ← len / size]
	pos ← objpos * size.
	size ← 1].

	"obtain quotient (page) and remainder (position)"
	pos ← pos intdiv: len.
	pn ← 1 + (pos◦1) asSmall.
	c ← size * (pos◦2) asSmall].

	self positionPage: pn character: c⇒ [⇑objpos]
	self error: 'cannot read page ' + pn asString]\gb28B19i109bI13Bi1I43i9I74i33I57i47I
positionPage: pn character: c [
	"normally accessed by position:size:, skip:"
	self read: pn⇒ [
		"c assumed between 0 and page dataLength. position, limit were set in on:"
		position ← position + c.
		position ≤ limit or⦂ self writing⇒ [⇑true]
		position ← limit.
		⇑false]

	c=0⇒ [
		"try end of previous page"
		⇑self positionPage: pn-1 character: page dataLength]
	⇑false]\gb30B4i21bI21B23i69bI3B116i24I
positionSize: size | len pos [
	"compute the position for an object of a given size,
		e.g. characters (1), words (2), fixed length (n),
	from the current character position and the current page"

	len ← page dataLength.
	size = 1 or⦂ len \ size ≠ 0⇒ [
		pos ← page pageNumber-1 * len + (position - page dataBeginning).
		size=1⇒ [⇑pos]
		⇑pos / size]

	"page length is a multiple of size"
	⇑page pageNumber-1 * (len/size) + 
		(position - page dataBeginning / size)]\gb19B14i161I161i33I
read: pn | p [
	"normally accessed by nextPage, position:size:, reopen, reset, settoend"
	pn < 1⇒ [⇑false]
	self obsolete⇒ [
		"reopen the file, (re)read the page"
		page reopen.
		p ← page read: pn⇒ [self on: p]
		⇑false]

	pn = page pageNumber and⦂ (page length > 0 or⦂ position > page dataBeginning)⇒ [
		self fixEnd.
		page asStream: self]

	"current page has wrong page number or is empty (possibly from error)"
	[self writing⇒ [
		[[pn > page pageNumber and⦂ page full≡false⇒ [
			"fill up last page when positioning past it"
			position ← page dataMaxEnd]
		"otherwise, fixEnd" position > page dataEnd]⇒ [page dataEnd: (limit ← position)]].
		"write current page"
		p ← page write.
		p pageNumber = pn⇒ ["already have next page, e.g. at end of AltoFile"]
		"read it or create it"
		p ← page get: pn]
	p ← page read: pn].
	p⇒ [(page ← p) asStream: self]
	⇑false]\gb9B8i21bI49B41i34I185i68I73i42I36i17I68i18I43i47I6i20I
settopage: p char: c [
	"mainly for compatibility, since page sizes may vary.
	in general, use position←, wordposition←"
	self read: p asSmall⇒ [self skip: c asSmall]
	self error: 'no page']\gb21B4i70bI24B
shorten [
	"normally called by close and not directly by user"
	self on: [page dataEnd: (limit ← position); endFile].
	position ← limit]\gb8B4i19bI5Bi25I

Filin/Filout\gbf5 
asParagraphPrinter ["default format for filout etc." ⇑BravoPrinter init of: self]\gb19B2i30I
backup [
	"assume ivy open"
	self directory≡dp0⇒ [ivy replace: self name]]\gb7B4i15I
filin | p [
	user cr.
	self readonly.
	self end⇒ [self file error: 'empty file']
	while⦂ (p ← self nextParagraph) do⦂ [
		FilinSource ← self.
		user print: nilⓢ p text; space].
	self close.
	FilinSource ← nil]\gb6B
filout [self filout: Changes contents sort]\gb7B
filout: source [(self asParagraphPrinter) stamp; printchanges: source; close]\gb15B
filoutclass: class [(self asParagraphPrinter) stamp; printclass: class; close]\gb19B
nextParagraph | text [
	"Bravo format paragraph (or self contents if no trailer)"
	self end⇒ [⇑false]
	text ← self upto: 032 "ctrl-z".
	⇑text asParagraph applyBravo: self at: 1 to: text length]\gb14B11i55I46i6I

Print\gbf5 
asPressPrinter ["default format for printt etc." ⇑PressPrinter init of: self]\gb15B2i30I
printout: source [(self asPressPrinter) stamp; printchanges: source; close; toPrinter]\gb17B
printoutclass: class [(self asPressPrinter) stamp; printclass: class; close; toPrinter]\gb21B
toPrinter | pp p [
	"print an unformatted or Bravo file as a press file"
	user displayoffwhile⦂ [
	pp ← (self directory file: self name + 'Press') asPressPrinter.
	self readonly.
	while⦂ (p ← self nextParagraph) do⦂ [pp print: p].
	self close].
	pp close; toPrinter]\gb10B11i50I

CodePane Editor\gbf5 
edit [user restartup: (CodeWindow new file: self)]\gb5B

Fast Access\gbf5 
readPages: n | charsLeft len s [
	"read n pages of characters"
	len ← n * page dataLength.
	s ← String new: len.
	"charsRead ← self into: s endError: false."
	charsLeft ← self readString: s from: 1 to: len.
	charsLeft = 0⇒ ["read len chars" ⇑s]
	"return characters read only before end of file"
	⇑s copy: 1 to: len - charsLeft]\gb13B22i26I164i14I8i46I
readString: s from: start to: stop | len charsLeft [
	"for reading a subrange of a large String from a file (quickly, if BitBlt is used);
	called by FileStream into:endError:"

	self readonly; reopen.
	start ← start - 1.
	charsLeft ← stop - start.

	"keep going until all of the requested characters are copied or
	until end of file. if end of current page only, next page is read."
	while⦂ (charsLeft > 0 and⦂ self end ≡ false) do⦂ [

		"len = # characters of current page that will fit in String"
		len ← limit - position min: charsLeft.
		charsLeft ← charsLeft - len.

		"copy subrange of page into String"
		s copy: start+1 to: start+len
			with: array from: position+1 to: position+len.

		"update source and destination pointers"
		position ← position+ len.
		start ← start + len.
		].

	"return the number of characters not read"
	⇑charsLeft]\gb35B20i94bI25B77i130I58i58I78i33I88i38I61i40I
streamPosition [⇑position]\gb15B
streamPosition←position [⇑position]\gb24B
writeFile: fs for: charsLeft | start len maxLimit [
	"for copying part or all of one file to another (quickly, if BitBlt is used);
	charsLeft ≡ nil means copy until end, otherwise a number of characters.
	called by FileStream append:, next:from:"

	[self writing⇒ [] self error: 'read only!'].
	self reopen.
	fs readonly; reopen.
	maxLimit ← page dataMaxEnd.

	"keep going until all of the requested characters are copied or
	until end of file. if end of current page only, next page is read."
	while⦂ ((charsLeft≡nil or⦂ charsLeft > 0) and⦂ fs end ≡ false) do⦂ [

		"end of current destination page?"
		[position = maxLimit⇒ [self nextPage]].

		"len = # characters of source page that will fit in destination page"
		start ← fs streamPosition.
		len ← maxLimit - position min: fs limit - start.
		[charsLeft≡nil⇒ []
		len ← len min: charsLeft.
		charsLeft ← charsLeft - len].

		"copy subrange of source page into destination page"
		array copy: position+1 to: position+len
			with: fs asArray from: start+1 to: start+len.

		"update source and destination pointers"
		fs streamPosition ← start + len.
		position ← position + len.
		position > limit⇒ [limit ← position]
		].

	"return the number of characters not read"
	⇑[charsLeft ≡ nil⇒ [0] charsLeft]]\gb29B25i77I1i71I1i11bI30B117i130I76i32I48i67I167i50I97i38I113i40I
writeString: s from: start to: stop | len charsLeft maxLimit [
	"for writing a subrange of a large String onto a file (quickly, if BitBlt is used);
	called by FileStream append:"

	[self writing⇒ [] self error: 'read only!'].
	self reopen.
	start ← start - 1.
	charsLeft ← stop - start.
	maxLimit ← page dataMaxEnd.

	"keep going until all of the requested characters are copied"
	while⦂ charsLeft > 0 do⦂ [

		"end of current page?"
		[position = maxLimit⇒ [self nextPage]].

		"len = # characters of String that will fit in current page"
		len ← maxLimit - position min: charsLeft.
		charsLeft ← charsLeft - len.

		"copy subrange of String into page"
		array copy: position+1 to: position+len
			with: s from: start+1 to: start+len.

		"update source and destination pointers"
		start ← start + len.
		position ← position + len.
		position > limit⇒ [limit ← position]
		].
	⇑s]\gb36B29i94bI10Bi1bI7B142i59I34i20I48i58I81i33I88i38I
\g
SystemOrganization classify: ↪FileStream under: 'Files'.\g

"FtpDirectory"l15000z20000\gbf5 
Class new title: 'FtpDirectory'
	subclassof: FileDirectory
	fields: 'command'
	declare: '';
	asFollows\gbf5 

an interim(?) substitute for our own ftp server\gi

FileDirectory\gbf5 
close [self closeThen: 'Resume. Small.Boot']\gb6B
closeThen: s [
	command append: '; '; append: s.
	user quitThen: command contents.
	self open]\gb13B
commands [⇑command contents]\gb9B
connect: name password: pw [
	command append: ' Connect/C '; append: name; space; append: pw]\gb27B
delete: name [command append: ' Delete/C '; append: (self checkName: name)]\gb13B
directoryName: name [
	"this message should be directory:, but until rewriting..."
	command append: ' Directory/C '; append: name]\gb20B
login: name password: pw [
	name empty⇒ []
	command append: ' Login/C '; append: name; space; append: pw]\gb25B
open [
	command ← Stream new of: (String new: 100).
	command append: 'Ftp '; append: directory.
	self login: self userName password: self userPassword]\gb5B
rename: oldName newName: newName [
	command append: ' Rename/C ';
		append: (self checkName: oldName); space; append: (self checkName: newName)]\gb33B
replace: name | s [
	s ← self checkName: name.
	(directory compare: 'maxc') = 2⇒ [self delete: s; store: s]
	"store as highest version (ifs only)"
	command append: ' Store/S '; append: s; space; append: s; append: '!H']\gb14B96i35I
retrieve: s | t [
	s is: Vector⇒ [for⦂ t from: s do⦂ [self retrieve: t]]
	command append: ' Retrieve/C '; append: (self checkName: s)]\gb12B
retrieve: remote as: local [
	command append: ' Retrieve/S ';
		append: (self checkName: remote); space; append: (self checkName: local)]\gb27B
store: s | t [
	s is: Vector⇒ [for⦂ t from: s do⦂ [self store: t]]
	command append: ' Store/C '; append: (self checkName: s)]\gb9B
store: local as: remote [
	command append: ' Store/S ';
		append: (self checkName: local); space; append: (self checkName: remote)]\gb24B
\g
SystemOrganization classify: ↪FtpDirectory under: 'Files'.\g
