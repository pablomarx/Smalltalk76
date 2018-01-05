'From Smalltalk 5.5k XM November 24 on 22 November 1980 at 2:57:08 am.'

"ILFile" 
Class new title: 'ILFile'
	subclassof: File
	fields: ''
	declare: '';
	sharing: ILFilePool;
	asFollows 

An IFS file accessed through the Leaf protocol, 12/79

Dictionary 
entryClass [⇑ILFilePage]

File 
classInit | i sym names ["ILFile classInit."

	ILFilePool declare: ↪NotFound as: '207'.
	names ← ↪(
		1011 (BadLeafHandle)
		02000 (AnswerBit)
		0176000 (RequestBits)
		0260 (LeafType)
"5-bit operations for left field command block word"
		0 (Error Open Close Delete)
		6 (Read Write Reset)

"read/write modes"
		0140 (SetEof "no holes, set eof")
		0200 (NoExtend "don't extend file on read or write")
		0100 (NoHoles "for writing past end")

"open file modes"
		0163400 (WriteOld "read, write, extend, any explicit, highest")
		0103400 (ReadOld "read, any explicit, highest")
		0167600 (CreateNew "read, write, extend, create, any explicit, next")

"control codes for left half of pupID1 field"
		0 (Data Ack Noop)
		5 (OpenConnection "if Reset")
		9 (DestroyConnection Dally Quit BrokenConnection)) asStream.

	for⦂ i from: names do⦂ [
		for⦂ sym from: names next do⦂ [
			ILFilePool declare: sym as: i.
			i ← i+1]]]

close ["ignore errors if file was readonly" self close: [type = read⇒ [false] 'close']]
close: e | p ["close file, possibly ignoring errors"
	"for next open"
	type ← read.
	"shorten header block to first 2 words: command&length,  file handle"
	p ← self newPage.
	p length: ¬6.
	self doCommand: Close page: p error: e]
doCommand: com page: page error: e | in ecode [
	page command: com.
	while⦂ true do⦂ [
		"make sure connection is open"
		directory open.
		error ← nullString.

		[in ← directory socket sendPacket: page packet⇒ [
			in◦11 = BrokenConnection⇒ [ecode ← ¬1]
			"turn packet into a ILFilePage"
			in ← [(self entryClass new) dictionary: self; page: in].
			"check if answer is of same type as request"
			((page header: 1) land: RequestBits) + AnswerBit =
				((in header: 1) land: RequestBits)⇒ [⇑in]
			ecode ← in header: 2]
		"no response?"
		ecode ← false].

		"some kind of problem"
		com = Quit⇒ ["ignore" ⇑false]
		[ecode ≡ false or⦂ ecode = ¬1⇒ ["make new connection" directory release]].
		ecode = ¬1 or⦂ ecode = 1011⇒ [
			"try again after some reinitializing"
			"reopen file"
			self reopen.
			"init page with new handle only -- don't lose mode, length, etc."
			page serialNumber: serialNumber]

		error ← [ecode⇒ [e⇒ [self errorString: ecode] ecode asString]
			directory directory + ' not responding'].
		e⇒ [self error: e "proceeding tries again"]
		⇑false]]
endFile: page [
	"make sure we can write"
	self writeMode: page.
	"update length. this will end file with this page"
	lastpn ← page pageNumber.
	⇑self Write: page]
errorString: errorCode | ef ename errorString notfound dollar cr [
	[errorCode is: String⇒ [
		errorString ← errorCode.
		errorCode ← [(errorString◦1) isdigit⇒ [errorString asInteger] 0]]
	errorString ← errorCode asString].

	ename ← '<System>Ifs.Errors'.
	(self name compare: ename) = 2⇒ [
		"recursion" ⇑errorString + ' (cannot access Ifs.Errors !!!)']

	notfound ← errorString + '	(error code not found)'.
	errorCode ≤ 0⇒ [⇑notfound]

	dollar ← '$'◦1. cr ← 015.
	ef ← directory oldFile: ename.
	ef readonly.
	errorString ← false.

	"scan through the errors file looking for lines of the form:
$$nn	some message
"
	until⦂ errorString do⦂ [
		ef skipTo: dollar⇒ [
			ef next = dollar⇒ [
				"valid line"
				ef integerScan
					> errorCode⇒ ["since errors are ordered" errorString ← notfound];
					= errorCode⇒ [
						errorString ← (String new: 200) asStream.
						errorString print: errorCode.
						until⦂ (ef peek = dollar or⦂ ef peek = cr) do⦂ [
							errorString append: (ef upto: cr); space].
						errorString ← errorString contents]
			]]
		"end of file"
		errorString ← notfound].

	ef close.
	⇑errorString]
findLastPage ["already known from open" ⇑lastpn]
open "do nothing. lastpn set by ILFileDirectory Find:"
Read: page [
	page pageNumber > lastpn⇒ ["no page" ⇑false]
	"don't extend beyond eof. length of page is 0, but request is for 512 bytes"
	page mode: NoExtend; header: 5 ← 512 "self dataLength".
	⇑self doCommand: Read page: page error: 'Read:']
release [self close: false]
Write: page | pn [
	(pn ← page pageNumber) > (lastpn+1)⇒ [self error: 'illegal page number']

	"make sure we can write"
	self writeMode: page.

	page mode: [pn ≥ lastpn⇒ [SetEof] NoHoles].
	self doCommand: Write page: page error: 'Write:'.

	"file possibly extended"
	[pn = (lastpn+1)⇒ [lastpn ← pn]].
	⇑page]
writeMode: page [
	"make sure we can write on file"
	type = write⇒ []
	"turn on writing by closing and reopening file. eventually there might be
	a simpler way to change file mode"
	self close.
	type ← write.
	directory Find: self⇒ [
		"file handle changed"
		page serialNumber: serialNumber]
	self error: 'file failed to reopen']

IFS 
allocatePage [⇑directory allocatePage]

SystemOrganization classify: ↪ILFile under: 'IFS File System'.
ILFile classInit

"ILFileDirectory" 
Class new title: 'ILFileDirectory'
	subclassof: FileDirectory
	fields: 'userName userPassword isocket'
	declare: '';
	sharing: ILFilePool;
	asFollows 

IFS directory, 12/79

Dictionary 
Delete: file ["delete a file (highest version)
	shorten header block to 2 words: command&length,  file handle"
	(file newPage) length: ¬6; doCommand: Delete error: 'Delete:']
entryClass [⇑ILFile]
Find: file [
	"since there can be many readers but only one writer, default mode is for
	read only. writing will cause file to be closed and reopened for writing"
	⇑self openFile: file mode: [file type = write⇒ [WriteOld] ReadOld]]
Insert: file [
	file type: write.
	self openFile: file mode: CreateNew⇒ [⇑file]
	file error: 'Insert: cannot create']
obsolete [⇑isocket ≡ nil]
open | page [
	isocket ≡ nil "self obsolete"⇒ [
		[isocket ← ILSocket new hostName: directory "name of IFS/Leaf server"⇒ []
		isocket ← nil.
		user notify: directory + ' (name not found)'].

		super open.
		page ← self newPage.
		"treat packet in page as a parameter block"
		(ILParameterBlock new)
			packet ← page packet;
			nextword ← 0; "host number (0 = this, ¬1 = all)"
			nextString ← self userName;
			nextString  ← self userPassword.
		page doCommand: Reset error: false⇒ []
		isocket ← nil.
		user notify: 'open (reset)'
	]]
release [
	self obsolete⇒ []
	"shorten header block to 0 words.
	DestroyConnection. after this the connection is gone"
	(self newPage) length: ¬10; doCommand: Quit error: false.

	isocket close.
	isocket ← nil]
versionNumbers [⇑true]

IFS 
allocatePage [
	[isocket≡nil⇒ [self open]].
	"return a packet to be used by ILFilePage"
	⇑isocket freePacket]
name: userName password: userPassword
noAck ["an optimization for intense ether activity" isocket noAck]
openFile: file mode: m | page [
	"open bit modes
	read
	write
	extend
	multiple (0)
	create name
	explicit version in name (2b)
		no, old, next or old, any
	default (if no version specified) (2b)
		no, lowest, highest, next
	unused (7b)"

	self open.
	page ← file newPage.
	"treat packet in page as a parameter block"
	(ILParameterBlock new)
		packet ← page packet;
		nextword ← 0; "file handle"
		nextword ← m; "modes"
		nextString ← self userName;
		nextString  ← self userPassword;
		nextString ← ''; "connect name"
		nextString ← ''; "connect password"
		nextString ← self checkName: file name.

	"answer bits (in page header: 5)
	same (5b)
	version (4b)
		bad, default lowest, default highest, default next, !*, !L, !H, !N, explicit old, explicit lowest, explicit highest, explicit next, explicit new, explicit-less, explicit between, explicit greater"

	page ← file doCommand: Open page: page error: false⇒ [
		file serialNumber: page serialNumber.
		"open returns file length"
		file lastPage: (page pageNumber - [
			((page header: 4) land: 0777) =0⇒ ["full last page" 1] 0] max: 1)]

	file error = NotFound⇒ [⇑false]
	⇑file error: 'open ' + (file errorString: file error)
]
socket [⇑isocket]
userName [
	userName ≡ nil or⦂ userName empty⇒ [⇑super userName]
	⇑userName]
userPassword [
	userPassword ≡ nil or⦂ userPassword empty⇒ [⇑super userPassword]
	⇑userPassword]

SystemOrganization classify: ↪ILFileDirectory under: 'IFS File System'.

"ILFilePage" 
Class new title: 'ILFilePage'
	subclassof: EtherFilePage
	fields: ''
	declare: '';
	sharing: ILFilePool;
	asFollows 

12/79, SAW.
Format of header is generally (for read/write)
1 operation (5 bits opcode, 1 bits request/answer, 10 bits inclusive byte length of block
2 file handle
3&4 byte address (mode in high 5 bits)
5 byte length

FilePage 
headerLength [⇑34 "4+20+10"]
length ["valid for read or write" ⇑self header: 5]
length: len [
	"10 bytes in a normal header block. ILParameterBlock can change things.
	also negative lengths can shorten it and change pupLength"

	"length of command block, including data"
	self header: 1 ← 10 + len.
	"number of data bytes to read/write"
	self header: 5 ← len.
	"set pupLength"
	super length: len]
pageNumber [
	"extract page number from 27-bit byte address. ignore high 5 mode bits.
	dividing byte adress (which may be a LargeInteger) by self dataLength (512)
	is the correct but slow way to do this. byte address 0 = page 1"
	⇑(((self header: 3) land: 03777) * 0200 "lshift: 7, maybe large") +
		((self header: 4) lshift: ¬9) + 1]
pageNumber: pn ["inverse of pageNumber. set 5 mode bits to 0"
	pn ← pn-1.
	self header: 3 ← pn / 0200 "lshift: ¬7, except for large pn".
	self header: 4 ← pn lshift: 9]
serialNumber | sn [
	sn ← String new: 4.
	sn◦1 ← sn◦2 ← 0.
	sn word: 2 ← self header: 2.
	⇑sn]
serialNumber: sn [self header: 2 ← sn word: 2]

IFS 
command: com [
	"operation word (header 1)
		0-4
			opcode
		5
			0 request
			1 answer
		6-15
			inclusive byte length of operation block"

	page pupType ← LeafType.

	"make operation a request, preserve length set earlier"
	page◦25 ← (page◦25 land: 3) + (com lshift: 3).

	"left half pupID1"
	page◦11 ← [
		com = Reset⇒ [OpenConnection]; = Quit⇒ [DestroyConnection] Data]]
mode: m [
	"current meaning of 5 read/write bits (from high to low):
		0-1
			0 read or write anywhere
			1 no holes (read or write) zeros past end
			2 don't extend on read or write
			3 check extend (Error)
		2
			1 set eof
		3-4
			0 undefined"

	"m is a byte which is already shifted"
	page◦29 ← (page◦29 land: 7) + m]

SystemOrganization classify: ↪ILFilePage under: 'IFS File System'.

"ILParameterBlock" 
Class new title: 'ILParameterBlock'
	subclassof: Object
	fields: 'packet position'
	declare: '';
	sharing: ILFilePool;
	asFollows 

for passing parameters to IFS. primarily used by ILFileDirectory open & openFile:

Initialization 
packet ← packet [
	"default is an empty (data) packet, except first header word"
	self position: 26]

Changing values 
nextString ← s | strm [
	strm ← packet pupString asStream.
	strm skip: position; nextword ← s length; append: s; padNext ← 0.
	self position: strm position]
nextword ← w | strm [
	strm ← packet pupString asStream.
	strm skip: position; nextword ← w.
	self position: strm position]
position: position [
	"changing length of data in packet"
	packet pupLength ← position - 2.
	"set inclusive byte length in first command word; rest set later"
	packet word: 13 ← position - 24]

SystemOrganization classify: ↪ILParameterBlock under: 'IFS File System'.

"ILSocket" 
Class new title: 'ILSocket'
	subclassof: RetransmitSocket
	fields: 'seqNum outPac result abortTransfer outAck'
	declare: '';
	sharing: ILFilePool;
	asFollows 

for communicating with a Leaf socket on an IFS server, 12/79

Socket 
net: n host: h ["usually called by hostName:"
	seqNum ← 0.
	super net: n host: h soc: 043 asInt32.
	self retransmit: 8 every: [n = NETNUM⇒ ["same net" 400] 1800].
	self setAck]
noAck ["if acknowledgements are not needed" outAck ← false]
sendPacket: outPac | nseq [
	"send a packet, wait for result, and acknowledge.
	RetransmitSocket setAddressesAndComplete: sets timer
	ILSocket socProcess: receives answers
	ILSocket timerFired handles retransmissions"

	result ← abortTransfer ← false.
	"alloc, receiver seq"
	outPac pupID0 ← 
	"command, send seq"
	outPac◦12 ← "pupID1 ← (outPac pupID1 land: 0177400) +" seqNum.
	self setAddressesAndComplete: outPac.

	"while waiting for packet to arrive, set up ack"
	nseq ← (seqNum +1) \ 256.
	[outPac◦11 = DestroyConnection⇒ [
		"assume reply will be Dally. send Quit to shut down connection a little faster"
		[outAck⇒ []
		"create ack"
		self setAck.
		outAck pupID0 ← outAck◦12 ← seqNum].

		outAck◦11 ← Quit.
		retransMax ← 0.
		"same sequence numbers as previous"]
			
	outAck⇒ ["acknowledgement for Open & Data"
		outAck pupID0 ← outAck◦12 ← nseq]

	"in rapid interchanges, the next request is an implicit ack, so it's faster not to send one. however, packets unacknowledged for ~5 secs. at the server end can cause degraded performance"].
 
	"now wait for socProcess: to set result, or timerFired to set abortTransfer"
	until⦂ (result or⦂ abortTransfer) do⦂ [].

	[result⇒ [
		seqNum ← nseq.
		outAck⇒ ["send ack" self completePup: outAck]]].
	⇑result]
setAck ["create acknowledgement packet"
	outAck ← self freePacket.
	outAck pupType ← LeafType.
	outAck dataString ← ''.
	"control code"
	outAck◦11 ← Ack.
	self setAddresses: outAck]
socProcess: Ipac [
	"check if this is a packet we want. normally left half of pupID1 = Data (0).
	in case of DestroyConnection, control code might be Dallying (10)"

	Ipac◦12 "pupID1" = seqNum and⦂ Ipac pupType = LeafType⇒ [
		"turn off timer, save result"
		self timerOff.
		result ← Ipac]

	"recycle packet"
	self freePacket: Ipac]
timerFired [
	"timer has fired -- retransmit or abort"

	result or⦂ abortTransfer⇒ ["bug?--timer may not have been disabled yet"]

	self timerOn⇒ ["retransmit" self completePup: outPac]

	"abort"
	abortTransfer ← true]

SystemOrganization classify: ↪ILSocket under: 'IFS File System'. 
