'From Smalltalk 5.5k XM November 24 on 22 November 1980 at 2:57:08 am.'

"File" 
Class new title: 'File'
	subclassof: Dict
	fields: 'directory type name serialNumber pageReaders pageBuffer lastpn error'
	declare: '';
	sharing: FilePool;
	asFollows 

A collection of FilePages usually on some device external to the virtual memory, which can be viewed and modified. File is a generalization: some examples are AltoFile and WoodstockFile. FilePage and FileDirectory are related classes. FileStream provides Stream access to Files.

Subclasses should override any superclass message implemented as [self subError]

Documentation 
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
"

Dictionary 
close
entryClass ["a subclass of FilePage" self subError]
Find: page [⇑page pageNumber ≤ lastpn]
found: page ["read an existing page" self subError]
makeEntry: page [
	page is: self entryClass⇒ [page init; serialNumber: serialNumber. ⇑page]
	⇑[(self entryClass new) dictionary: self;
		init; pageNumber: page; serialNumber: serialNumber]]
open ["compute lastpn" self findLastPage]
release
reopen [
	[self sameFile⇒ []
	"init and directory access"
	directory get: self init].
	self open]

DictionaryEntry 
dictionary [⇑directory]
dictionary: directory
init [lastpn ← false. error ← nullString. serialNumber ← String new: 4]
match: entry [⇑self name match: entry name]
name [⇑name]
name: name
printon: strm [strm append: name]

Initialize 
classInit [
	"subclasses of File may want to share variables in pools.
	execute before filin:
		Smalltalk declare: ↪XFilePool as: (SymbolTable new init: 16).
	in classInit: XFilePool declare: ↪() as: ↪()"

	FilePool declare: ↪(read write shorten) as: ↪(1 2 4)]
sameFile "is File's current internal representation the same as what is stored externally? if so, usually can avoid some initialization, directory lookup"
	[⇑false]

Name 
serialNumber [⇑serialNumber]
serialNumber: s [
	"stored as a String of 4 characters rather than as various Numbers"
	s is: String⇒ [serialNumber ← s]
	s is: Substring⇒ [serialNumber ← s copy]
	s is: Integer⇒ [serialNumber word: 1 ← 0; word: 2 ← s]
	"Vector of Integers"
	serialNumber word: 1 ← s◦1; word: 2 ← s◦2]

FileDirectory 
delete [⇑directory delete: self]
directory [⇑directory]
directory: directory
rename: newName [⇑directory rename: self newName: newName]
type [⇑type]
type: type "used by different Files in different ways, e.g. read/write mode"

File Length 
endFile: page [
	"make File end with this FilePage. false means delete all of File"
	self subError]
findLastPage [
	"the default definitions for findLastPage and length are circular.
	at least one of them must be defined by a subclass"

	⇑lastpn ← self pageFrom: self length]
lastFullPage [(self read: self lastPage) full⇒ [⇑lastpn] ⇑lastpn-1]
lastPage ["length in pages"
	lastpn⇒ [⇑lastpn] ⇑self findLastPage]
lastPage: lastpn "for those who know what they're doing"
length | page [
	"length in characters"
	page ← self read: self lastPage.
	⇑lastpn-1 * page dataLength + page length]
pageFrom: len [
	"compute page number for a character index"
	⇑(len-1 / self entryClass new dataLength) asSmall+ 1]

FilePage 
doCommand: com page: page error: s [
	"execute a File command on page. if an error occurs, include
	error ← 'some error message'.
	⇑self error: s
	if s is false, returns false.
	otherwise s is passed to an error routine" self subError]
error [⇑error]
error: e [
	e⇒ [e ← [(Stream default) append: name; append: ' in '; append: e;
			append: ', '; append: error; contents].
		error ← nullString.
		⇑super error: e]
	⇑false]
Get: page | p pn [
	pn ← page pageNumber.
	p ← self Read: page⇒ [⇑p]

	"current last page of the file is assumed full"
	for⦂ p from: lastpn+1 to: pn-1 do⦂ [
		page pageNumber: p.
		page ← self Write: page].

	"return an empty last page which is not written yet"
	page pageNumber: pn; length: 0.
	⇑page]
get: pn [⇑self Get: (self makeEntry: pn)]
newPage [⇑self makeEntry: 0]
newPage: pn [⇑self makeEntry: pn]
Read: page ["return page or false" self subError]
read: pn [⇑self Read: (self makeEntry: pn)]
Write: page [
	"update lastpn, write page and return result (maybe next page)"
	self subError]

FileStream 
asStream [⇑(FileStream new) on: [self open; get: 1]]

SystemOrganization classify: ↪File under: 'Files'.
File classInit

"FileDirectory" 
Class new title: 'FileDirectory'
	subclassof: Dict
	fields: 'directory fileReaders'
	declare: '';
	sharing: FilePool;
	asFollows 

A collection of Files. FileDirectory is a generalization: some examples are AltoFileDirectory and WoodstockFileDirectory

Dictionary 
checkName: s [
	"default behavior is to get rid of ending period.
	subclasses can do any kind of checking they want and
	return false if name is no good"

	s empty or⦂ s last ≠ ('.'◦1)⇒ [⇑s]
	⇑s copy: 1 to: s length-1]
close [
	self obsolete⇒ []
	externalViews delete: self.
	self release]
entryClass ["a subclass of File" self subError]
error: e entry: file [⇑file error: e]
Find: file | name [
	name ← self checkName: file name⇒ [
		file name: name.
		⇑self Position ← file]
	file error: 'illegal name']
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
	⇑file]
open [externalViews insert: self]
printon: strm [
	strm append: [self obsolete⇒ ['a closed '] 'an open '];
		append: self class title;
		append: ' on '.
	self server printon: strm]

DictionaryEntry 
dictionary [⇑directory]
dictionary: directory

Initialize 
directory: directory

File 
allocateSN: file ["allocate a new serial number for a File" self subError]
directory [⇑directory]
newPage ["return a dummy FilePage from a dummy File"
	⇑(self makeEntry: nullString) newPage]
versionNumbers ["generally, version numbers are not supported" ⇑false]

FileStream 
file: name [⇑(self get: name) asStream]
filin: s [self filin: s format: 1]
filin: s format: ft [
	"read Class definitions or Changes from FileStreams or PressFiles
	ft: 1 (FileStream=Bravo), 2 (Press)"

	user displayoffwhile⦂ [
	s is: Vector⇒ [for⦂ s from: s do⦂ [self filin: s format: ft]]

	"special case for Alto and patterns"
	(s is: String) and⦂ ((s has: '*'◦1) or⦂ (s has: '#'◦1))⇒ [
		self filin: (self filesMatching: s) format: ft]

	[s is: UniqueString⇒ ["Class name" s ← s + [ft=1⇒ ['.st'] '.press']]].

	([ft=1⇒ [self oldFile: s] self pressfile: s]) filin]]
newFile: name [⇑(self insert: name) asStream]
oldFile: name [⇑(self find: name) asStream]
pressfile: name [⇑PressFile new of: (self file: name)]
pressfilin: s [self filin: s format: 2]

FTP 
asFtpDirectory | ftp [
	"to allow convenient (kludgey) access to file servers (e.g. phylum, dpj) via Ftp"
	(ftp ← FtpDirectory new) server: self server; open.
	[ftp userName empty⇒ [ftp login: self userName password: self userPassword]].
	⇑ftp]
login: name [⇑self login: name password: '' "or prompt?"]
login: name password: pw [self subError]
retrieve: s | t [
	s is: Vector⇒ [for⦂ t from: s do⦂ [self retrieve: t as: t]]
	⇑self retrieve: s as: s]
retrieve: s1 as: s2 | f [
	[self exists: s1⇒ [f ← self oldFile: s1] ⇑false].
	f readonly.
	([s2 is: FileStream⇒ [s2] dp0 file: s2]) append: f; close.
	f close]
server [⇑directory]
server: directory
store: s | t [
	s is: Vector⇒ [for⦂ t from: s do⦂ [self store: t as: t]]
	⇑self store: s as: s]
store: s1 as: s2 | f [
	[s1 is: FileStream⇒ [f ← s1] dp0 exists: s1⇒ [f ← dp0 oldFile: s1] ⇑false].
	f readonly.
	(self file: s2) append: f; close.
	f close]
userName [⇑[currentProfile≡nil⇒ [''] currentProfile userName: self server]]
userPassword [⇑[currentProfile≡nil⇒ [''] currentProfile userPassword: self server]]

Juniper 
closeTransaction "default is to do nothing"
exceptionHandler: eh "default is to do nothing"

SystemOrganization classify: ↪FileDirectory under: 'Files'.

"FilePage" 
Class new title: 'FilePage'
	subclassof: Dict
	fields: 'file page'
	declare: '';
	sharing: FilePool;
	asFollows 

A block, chunk, or page of information from some collection of pages (a File).  FilePage is a generalization: some examples are AltoFilePage and WoodstockFilePage

Dictionary 
◦i [⇑page◦(self checkIndex: i)]
◦i ← v [⇑page◦(self checkIndex: i) ← v]
asStream [⇑self asStream: Stream new]
reopen [file reopen; makeEntry: self "self may have been released"]

DictionaryEntry 
dictionary [⇑file]
dictionary: file
init [
	[page≡nil⇒ ["self page:" page ← String new: self pageLength]].
	self length: 0"not sure who depends on this besides FileStream read:"]
name: sp [self init; serialNumber: sp◦1; pageNumber: sp◦2]

Initialize 
file: file
page: page

File 
doCommand: com error: s [⇑file doCommand: com page: self error: s]
endFile [⇑file endFile: self]
file [⇑file]
get: pn ["recycle self" self pageNumber: pn; length: 0. ⇑file Get: self]
read: pn ["recycle self" self pageNumber: pn; length: 0. ⇑file Read: self]
write [
	"some files, e.g. AltoFile, will return a last empty page instead of a full one"
	⇑file Write: self]

Page 
address ["page address, e.g. on a disk" self subError]
address: a [self subError]
asStream: s | offset [
	offset ← self headerLength.
	⇑s of: self dataString from: offset+1 to: offset+self length "self dataEnd"]
checkIndex: i [
	i > 0 and⦂ i ≤ self length⇒ [⇑i + self headerLength]
	self error: 'illegal index']
dataBeginning [⇑self headerLength]
dataEnd ["logical end of data in page" ⇑self headerLength + self length]
dataEnd: pos [self length: pos - self headerLength]
dataLength ["physical length of data in page. default" ⇑512]
dataMaxEnd ["physical end of data in page" ⇑self headerLength + self dataLength]
dataString [⇑page]
full [⇑self length = self dataLength]
header: n ["return n-th header word" ⇑page word: n]
header: n ← v ["set and return n-th header word" ⇑page word: n ← v]
headerLength ["length of stuff before data begins in page" ⇑0]
lastPage ["is this last page in file?" ⇑self pageNumber ≥ file lastPage]
length ["logical length of data in page" self subError]
length: len [self subError]
page [⇑page]
pageLength ["physical size of page"
	⇑self headerLength + self dataLength + self trailerLength]
pageNumber [self subError]
pageNumber: pn [self subError]
serialNumber [⇑file serialNumber]
serialNumber: sn [self subError]
trailerLength ["length of stuff after data ends in page" ⇑0]
word: i ["no bounds checking" ⇑page word: self headerLength/2 + i]
word: i ← v ["no bounds checking" ⇑page word: self headerLength/2 + i ← v]

SystemOrganization classify: ↪FilePage under: 'Files'.

"EtherFilePage" 
Class new title: 'EtherFilePage'
	subclassof: FilePage
	fields: ''
	declare: '';
	asFollows 

A FilePage which consists of an ethernet packet (Pacbuf) containing network information, header info and data

FilePage 
dataString [⇑page pupString]
header: n [
	"for accessing information after pup header, e.g. file commands and parameters.
	n = 1 to (self headerLength-24)/2"
	⇑page word: 12+n]
header: n ← v [⇑page word: 12+n ← v]
headerLength [⇑44 "ethernet encap.(4), pup header(20), file label (20=default)"]
init [
	[page≡nil⇒ ["self page:" page ← file allocatePage]].
	self length: 0]
length [⇑page pupLength - (self headerLength - 2)]
length: len [page pupLength ← len + self headerLength - 2]
trailerLength [⇑2 "checksum"]

Ether 
packet [⇑page]
pupType [⇑page pupType]
pupType← p [⇑page pupType← p]

SystemOrganization classify: ↪EtherFilePage under: 'Files'.

"FileStream" 
Class new title: 'FileStream'
	subclassof: Stream
	fields: 'page dirty rwmode'
	declare: '';
	sharing: FilePool;
	asFollows 

A Stream which windows a File. see File example

Dictionary 
close [
	self obsolete⇒ []
	[self writing⇒ [
		rwmode anymask: shorten⇒ [self shorten]
		self flush]].
	"self release (sort of)"
	dirty ← limit ← 0.
	self file close.
	externalViews delete: self]
file [⇑page file]
obsolete [⇑dirty]
release [
	self obsolete⇒ []
	dirty ← limit ← 0.
	self file release]
reopen | pos [
	dirty "self obsolete"⇒ [
		"reopen to current position"
		pos ← position.
		self read: page pageNumber⇒ [position ← pos min: limit]
		"if that page doesn't exist, go to last one that does.
		note that settoend would be recursive"
		self read: (self file lastPage)⇒ [position ← limit]
		self error: 'cannot reopen or settoend']
	⇑false]

Initialize 
on: page "some page from a File, usually page 1, or another FileStream" [
	[page is: FileStream⇒ [page ← page page]].
	page asStream: self.
	externalViews insert: self.
	"obsolete flag"
	dirty ← false]

Access Modes 
readonly [self setMode: read]
readwrite [
	"allow read and write but don't automatically shorten"
	self setMode: read + write]
readwriteshorten ["allow read and write and shorten File upon closing"
	self setMode: read+write+shorten]
setMode: m [
	rwmode = m⇒ []
	"don't flush if first time or not write mode or continuing write mode"
	[rwmode≡nil or⦂ ((rwmode nomask: write) or⦂ (m anymask: write))⇒ []
	self flush].
	rwmode ← m]

writeshorten ["allow write and shorten File upon closing. in general, this would be faster for overwriting Files since pages might not have to be read first. at present, treated same as readwriteshorten"
	self setMode: write+shorten]
writing [
	rwmode≡nil⇒ ["default mode. true" ⇑self readwriteshorten]
	⇑(rwmode land: write) = write]

Stream 
◦i [
	self position ← i-1.
	⇑self next]
◦i ← v [
	self position ← i-1.
	⇑self next ← v]
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

	⇑super append: s]
contents | s ["read all of a File"
	self readonly; reset.
	s ← self next: self length.
	self close.
	⇑s]
end [
	self reopen.
	position < limit⇒ [⇑false]
	self read: page pageNumber+1⇒ [⇑"page empty" position = limit]
	⇑true]
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
	⇑charsRead]
length [
	page lastPage⇒ [⇑page pageNumber-1 * page dataLength + page length]
	⇑self file length]
next: n from: strm [
	n > 80 and⦂ (strm is: FileStream)⇒ [self writeFile: strm for: n]
	⇑super next: n from: strm]
pastend [
	self reopen or⦂ (page lastPage≡false and⦂ self nextPage)⇒ [⇑self next]
	⇑false]
pastend← v [
	self writing⇒ [
		self reopen⇒ [⇑self next ← v]
		[limit < page dataMaxEnd or⦂ [
			self nextPage⇒ [position=limit]
			self error: 'could not get page']⇒ [limit ← page dataMaxEnd]].
		⇑self next← v]
	self error: 'no writing allowed']
position [⇑self positionSize: 1]
position← p [⇑self position: p size: 1]
printon: strm [
	super printon: strm.
	strm append: ' on '.
	self file printon: strm]
reset ["self position ← 0"
	self read: 1⇒ []
	self error: 'reset']
settoend ["self position ← self length"
	"make sure file is open so lastPage is correct"
	self reopen.
	"when writing on the last page, lastPage may be too small"
	self read: (self file lastPage max: page pageNumber)⇒ [position ← limit]
	self error: 'settoend???']
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
	position ← p]
word: i [
	self wordposition ← i-1.
	⇑self nextword]
word: i ← v [
	self wordposition ← i-1.
	⇑self nextword ← v]
wordposition [⇑self positionSize: 2]
wordposition← w [⇑self position: w size: 2]

File 
directory [⇑self file directory]
fixEnd [
	self writing and⦂ position > page dataEnd⇒ [
		"fix the end of page"
		page dataEnd: (limit ← position)]]
flush [
	self obsolete⇒ [⇑page]
	self fixEnd.
	⇑page write]
name [⇑self file name]
nextPage [⇑self read: page pageNumber+1]
pad: size | rem [
	"skip to next boundary of size and return how many characters skipped"
	rem ← (([page dataLength \ size = 0⇒ [
		position - page dataBeginning] self position]) \ size) asSmall.
	rem = 0⇒ [⇑0]
	self skip: size - rem.
	⇑size - rem]
pad: size with: val | rem [
	"pad to next boundary of size and return how many characters padded"
	rem ← (([page dataLength \ size = 0⇒ [
		position - page dataBeginning] self position]) \ size) asSmall.
	rem = 0⇒ [⇑0]
	self next: size - rem ← val.
	⇑size - rem]
page [⇑page]
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
	self error: 'cannot read page ' + pn asString]
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
	⇑false]
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
		(position - page dataBeginning / size)]
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
	⇑false]
settopage: p char: c [
	"mainly for compatibility, since page sizes may vary.
	in general, use position←, wordposition←"
	self read: p asSmall⇒ [self skip: c asSmall]
	self error: 'no page']
shorten [
	"normally called by close and not directly by user"
	self on: [page dataEnd: (limit ← position); endFile].
	position ← limit]

Filin/Filout 
asParagraphPrinter ["default format for filout etc." ⇑BravoPrinter init of: self]
backup [
	"assume ivy open"
	self directory≡dp0⇒ [ivy replace: self name]]
filin | p [
	user cr.
	self readonly.
	self end⇒ [self file error: 'empty file']
	while⦂ (p ← self nextParagraph) do⦂ [
		FilinSource ← self.
		user print: nilⓢ p text; space].
	self close.
	FilinSource ← nil]
filout [self filout: Changes contents sort]
filout: source [(self asParagraphPrinter) stamp; printchanges: source; close]
filoutclass: class [(self asParagraphPrinter) stamp; printclass: class; close]
nextParagraph | text [
	"Bravo format paragraph (or self contents if no trailer)"
	self end⇒ [⇑false]
	text ← self upto: 032 "ctrl-z".
	⇑text asParagraph applyBravo: self at: 1 to: text length]

Print 
asPressPrinter ["default format for printt etc." ⇑PressPrinter init of: self]
printout: source [(self asPressPrinter) stamp; printchanges: source; close; toPrinter]
printoutclass: class [(self asPressPrinter) stamp; printclass: class; close; toPrinter]
toPrinter | pp p [
	"print an unformatted or Bravo file as a press file"
	user displayoffwhile⦂ [
	pp ← (self directory file: self name + 'Press') asPressPrinter.
	self readonly.
	while⦂ (p ← self nextParagraph) do⦂ [pp print: p].
	self close].
	pp close; toPrinter]

CodePane Editor 
edit [user restartup: (CodeWindow new file: self)]

Fast Access 
readPages: n | charsLeft len s [
	"read n pages of characters"
	len ← n * page dataLength.
	s ← String new: len.
	"charsRead ← self into: s endError: false."
	charsLeft ← self readString: s from: 1 to: len.
	charsLeft = 0⇒ ["read len chars" ⇑s]
	"return characters read only before end of file"
	⇑s copy: 1 to: len - charsLeft]
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
	⇑charsLeft]
streamPosition [⇑position]
streamPosition←position [⇑position]
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
	⇑[charsLeft ≡ nil⇒ [0] charsLeft]]
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
	⇑s]

SystemOrganization classify: ↪FileStream under: 'Files'.

"FtpDirectory" 
Class new title: 'FtpDirectory'
	subclassof: FileDirectory
	fields: 'command'
	declare: '';
	asFollows 

an interim(?) substitute for our own ftp server

FileDirectory 
close [self closeThen: 'Resume. Small.Boot']
closeThen: s [
	command append: '; '; append: s.
	user quitThen: command contents.
	self open]
commands [⇑command contents]
connect: name password: pw [
	command append: ' Connect/C '; append: name; space; append: pw]
delete: name [command append: ' Delete/C '; append: (self checkName: name)]
directoryName: name [
	"this message should be directory:, but until rewriting..."
	command append: ' Directory/C '; append: name]
login: name password: pw [
	name empty⇒ []
	command append: ' Login/C '; append: name; space; append: pw]
open [
	command ← Stream new of: (String new: 100).
	command append: 'Ftp '; append: directory.
	self login: self userName password: self userPassword]
rename: oldName newName: newName [
	command append: ' Rename/C ';
		append: (self checkName: oldName); space; append: (self checkName: newName)]
replace: name | s [
	s ← self checkName: name.
	(directory compare: 'maxc') = 2⇒ [self delete: s; store: s]
	"store as highest version (ifs only)"
	command append: ' Store/S '; append: s; space; append: s; append: '!H']
retrieve: s | t [
	s is: Vector⇒ [for⦂ t from: s do⦂ [self retrieve: t]]
	command append: ' Retrieve/C '; append: (self checkName: s)]
retrieve: remote as: local [
	command append: ' Retrieve/S ';
		append: (self checkName: remote); space; append: (self checkName: local)]
store: s | t [
	s is: Vector⇒ [for⦂ t from: s do⦂ [self store: t]]
	command append: ' Store/C '; append: (self checkName: s)]
store: local as: remote [
	command append: ' Store/S ';
		append: (self checkName: local); space; append: (self checkName: remote)]

SystemOrganization classify: ↪FtpDirectory under: 'Files'.
