'From Smalltalk 5.5k XM November 24 on 22 November 1980 at 2:57:08 am.'
\g
"JuniperFileController"l15000z20000\gbf5 
Class new title: 'JuniperFileController'
	subclassof: File
	fields: '
		fLongFileHandle
		fShortFileHandle
	'
	declare: '';
	sharing: gJuniperConstants;
	asFollows\gbf5 

JUNIPER FILE CONTROLLER\gi

DOCUMENTATION\gbf5 
implementationNotes
[
"
FIELDS
fLongFileHandle : a LongInteger representing the unique identifier for the file.
fShortFileHandle : an Integer representing the identifier for the file during a particular transaction.
"
]\gb20B11b15B66b16B

FILE REDEFINITIONS (restricted)\gbf5 
allocatePage
"...returns a new packet (Pacbuf) to be used as the data buffer in a JuniperPageBuffer."
[
	⇑ ((self interface) newPacket)
]\gb13B88b1B
close
"...closes the file on the Juniper file system."
[
	self doAction: sCloseFile requestPrs: nil.
]\gb6B48b1B
endFile: pPageBuffer
"...adjusts the file length, writes pPageBuffer (a JuniperPageBuffer) on the file, and returns pPageBuffer."
[
	self length: ( ((pPageBuffer pageNumber)-1)*(pPageBuffer dataLength)
						+ pPageBuffer length
					 ).  "1"
	self writePage: pPageBuffer.  "2"
	⇑ pPageBuffer
]
"
1. Set the file length to the total number of bytes in the file.
2. Write the page on Juniper.
"\gb21B
entryClass
"...returns the class of objects managed by JuniperFileController objects."
[
	⇑ JuniperPageBuffer
]\gb11B75b1B
Get: pPageBuffer
"...reads the data from the page whose number is that specified by pPageBuffer (a JuniperPageBuffer) if such a page exists.  Otherwise pPageBuffer should contains data to be written on the file at the appropriate place."
	| tNextPageNumber tNewPageNumber i
[
	tNewPageNumber ← pPageBuffer pageNumber.
	tNewPageNumber ≤ lastpn and⦂ (
		lastpn > 1 or⦂ self length > 0)⇒ [ ⇑ (self Read: pPageBuffer) ]
	
	tNextPageNumber ← lastpn + 1.
	[ tNewPageNumber = tNextPageNumber ⇒ [ ]
		self length: (tNewPageNumber-1) * (pPageBuffer dataLength).
		for⦂ i from: tNextPageNumber to: (tNewPageNumber-1) do⦂
			[ pPageBuffer pageNumber: i.
			pPageBuffer ← self writePage: pPageBuffer.
			].
	].

	pPageBuffer pageNumber: tNewPageNumber.
	pPageBuffer length: 0.
	⇑ pPageBuffer
]\gb17B220b2B
lastFullPage [⇑self length / self entryClass new dataLength]\gb13B
length
"...returns the number of bytes (an Integer) in the file."
	| tResult
[
	tResult ← self doAction: sReadLength requestPrs: nil.  "1"
	⇑ (tResult longInteger: 1)  "2"
]
"
1. Issue a 'read length' command to Juniper.
2. Return the length from the result parameter block.
"\gb7B58b2B9b1B
length: pLength
"...sets the number of bytes in the file to the integer pLength (an Integer)."
	| tRequest
[
	tRequest ← self newRequestParameterBlock.  "1"
	tRequest longInteger: 1 ← pLength.  "2"
	self doAction: sSetLength requestPrs: tRequest.  "3"
	lastpn ← self pageFrom: pLength.  "4"
]
"
1. Create a new request parameter block.
2. Set the length parameter to pLength.
3. Issue a 'set length' command to Juniper.
4. Determine the number of the last page of the file and assign it to the superClass field lastpn.
"\gb16B78b2B10b1B
open
"...opens the file on the Juniper file system."
	| tRequest tResult
[
	tRequest ← self newRequestParameterBlock.  "1"
	tRequest nextDataBlockString ← fLongFileHandle.  "2"
	tResult ← (self interface) doAction: sOpenFile requestPrs: tRequest.  "3"
	fShortFileHandle ← tResult parameter: 1.  "4"
	self findLastPage.  "5"
]
"
1. Create a new request parameter block.
2. Set the long file handle parameter.
3. Issue an 'open file' command to Juniper.
4. Set the superClass field serialNumber to the short file handle returned by Juniper in the result parameter block.
5. Set the number of the last page of the file.
"\gb5B47b2B
Read: pPageBuffer
"...returns false if the page number of pPageBuffer (a JuniperPageBuffer) is greater than the page number of the last page of the file; otherwise, the data for that page is read from the Juniper file system into the packet of pPageBuffer."
	| tRequest tResult pn
[
	[ (pn ← pPageBuffer pageNumber) > lastpn  ⇒  [ ⇑ false ]  "1"
			lastpn=1 and⦂ self empty⇒ [
				pPageBuffer length: 0. "⇑ self Get: pPageBuffer" ]
			tRequest ← self newRequestParameterBlock.  "2"
			tRequest parameter: 1 ← (pn - 1).  "3"
			tResult ← self doAction: sReadPage requestPrs: tRequest.  "4"
			pPageBuffer page: (tResult packet).  "5"
			pPageBuffer length: (tResult parameter: 1).  "6"
	].
	⇑ pPageBuffer  "7"
]
"
1. Return false if the page number of pPageBuffer is greater than that of the last page of the file.
2. Create a new request parameter block.
3. Set the page number parameter to that of pPageBuffer less 1.  Juniper page numbers start at 0.
4. Issue a 'read page' request.
5. Set the pPageBuffer packet to that of the result parameter block.
6. Set the length of pPageBuffer to that returned in the result parameter block.
7. Return pPageBuffer modified.
"\gb18B239b2B21b1B
Write: pPageBuffer
"...adjusts the length of the file if pPageBuffer is the last page, sends the data buffered in pPageBuffer (a JuniperPageBuffer) to the Juniper file system, and returns pPageBuffer."
	| tPageNumber
[
	tPageNumber ← pPageBuffer pageNumber.
	[ tPageNumber < lastpn ⇒ [ ]  "1"
		[ tPageNumber > (lastpn+1) ⇒
			[ ⇑ self error: 'invalid page number' ]  "2"
			self length:
				( (tPageNumber-1)*(pPageBuffer dataLength)+(pPageBuffer length)
				).  "3"
		].
	].
	self writePage: pPageBuffer.  "4"
	⇑ pPageBuffer  "5"
]
"
1. If the page number of pPageBuffer is less than the last page number of the file, do not readjust the file length.
2. If the page number of pPageBuffer is greater than the next available page number for the file, invoke error handling.
3. If pPageBuffer is the last page of the file or will immediately follow the last page of the file, adjust the file length.
4. Send the data to Juniper.
5. Return pPageBuffer unmodified.
"\gb19B182b2B
writePage: pPageBuffer
"...sends the data buffered in pPageBuffer (a JuniperPageBuffer) to the Juniper file system provided the buffer is not empty."
	| tRequest
[
	[ (pPageBuffer length = 0) ⇒ [ ]  "1"
		tRequest ← JuniperRequestParameterBlock new.  "2"
		tRequest
			packet ← pPageBuffer page;  "3"
			leader: 1 ← 0;
			leader: 2 ← 0;  "4"
			parameter: 1 ← ((pPageBuffer pageNumber) - 1).  "5"
		self doAction: sWritePage requestPrs: tRequest.  "6"
	].
]
"
1. If there is no data in pPageBuffer do nothing.
2. Create a new request parameter block.
3. Set the packet to that of pPageBuffer.  This contains the data to be written on the Juniper file.
4. Set the authentication key and reserved word to 0.
5. Set the page number parameter to that of pPageBuffer less 1.  Juniper page numbers start at 0.
6. Issue a 'write page' request.
"\gb23B

MISC (internal)\gbf5 
doAction: pAction requestPrs: pRequest
"...the specified request, pAction, (selected from gJuniperConstants) with its corresponding request parameter block, pRequest ( a JuniperRequestParameter Block), is issued to the Juniper file server (through the file interface).  If no errors are found, a JuniperResultParameterBlock is returned; otherwise, error handling is invoked.  If no request parameters are required, pRequest can be specified as nil."
[
	[ pRequest ≡ nil ⇒ [ pRequest ← self newRequestParameterBlock. ]  "1"
	].
	pRequest shortFileHandle ← fShortFileHandle.  "2"
	⇑ ((self interface) doAction: pAction requestPrs: pRequest)  "3"
]
"
1. Create a new request parameter block if one is not specified.
2. Set the short file handle parameter.
3. Issue the request to the Juniper interface and return the result parameter block.
"\gb39B410b1B
interface
"...returns the JuniperInterface controlling the file."
[
	⇑ directory
]\gb10B55b1B
longFileHandle: pLongFileHandle
"...sets the file's long file handle."
[
	fLongFileHandle ← pLongFileHandle.
]\gb32B38b1B
newRequestParameterBlock
"...initializes and returns a new JuniperRequestParameterBlock."
[
	⇑ ((self interface) newRequestParameterBlock)
]\gb25B64b1B
\g
SystemOrganization classify: ↪JuniperFileController under: 'Juniper'.\g

"JuniperInterface"l15000z20000\gbf5 
Class new title: 'JuniperInterface'
	subclassof: FileDirectory
	fields: ' 
		fName
		fPassword
		fDefaultDirectory
		fJuniperSocket
		fTimer
		fExceptionHandler
		fSpecialError
		fOpenIndicator
	'
	declare: '';
	sharing: gJuniperConstants;
	asFollows\gbf5 

JUNIPER INTERFACE\gi

DOCUMENTATION\gbf5 
implementationNotes
[
"
FIELDS
fName : a String representing the name of an account on the Juniper file system.
fPassword : a String representing the password of the same account.
fDefaultDirectory : a String representing the directory to be used as the default if one is not specified as part of a file name.
fJuniperSocket : a JuniperSocket used to interface to the etherWorld mechanism.
fTimer : a Timer used to periodically send noop commands when the interface is open to prevent timeout.
fExceptionHandler : an ExceptionHandler to invoke when a transaction is aborted.
fSpecialError : an error code to ignore on a command request.
fOpenIndicator : the interface status: true means open; nil means not open.
"
]\gb20B11b6B1b1B73b10B58b17B113b14B66b6B98b17B64b13B49b14B

USER CALLABLE\gbf5 
close
"...ends the current transaction and closes the interface."
	|  tResult
[
	[ fOpenIndicator ≡ nil ⇒ [ ]  "1"
		tResult ← self doAction: sLogout requestPrs: nil.  "2"
		user
			cr;
			show: (tResult nextDataBlockString).  "3"
		super close.  "4"
	].
]
"
1. If the interface is not open, do nothing.
2. Issue a logout command.
3. Display the logout message returned by Juniper.
4. delete self from externalViews, Release timers, fields, etc.
"\gb6B59b2B10b1B
closeTransaction
"...closes the current transaction leaving the user logged in with all open files still open, and all read and write locks still in effect."
[
	self doAction: sCloseTransaction requestPrs: nil.
]\gb17B140b1B
directory: pDirectory
"...specifies the directory name to be added to any file name that does not begin with a directory name."
[
	fDefaultDirectory ← pDirectory.
]\gb22B105b1B
exceptionHandler: pExceptionHandler
"...specifies an exception handler to be invoked if any subsequent request discovers that the expected transaction has been closed.  If no exception handler is set, a notify window is displayed."
[
	fExceptionHandler ← pExceptionHandler.
]\gb36B195b1B
name: pName password: pPassword
"...specifies the name and password of an account on the Juniper file system.  This account will be logged into whenever the interface is opened."
[
	fName ← pName.
	fPassword ← pPassword.
]\gb32B146b1B
obsolete [⇑fOpenIndicator ≡ nil]\gb9B
open
"...opens the interface allowing access to files on the Juniper file system.  A new transaction is started."
	| tResult
[
	[ fOpenIndicator ≡ true  ⇒ [ ]  "1"
		E wakeup.  "2"
		self release.  "3"
		fJuniperSocket ← JuniperSocket new hostName: self server.  "4"
		tResult ← self login: (self userName) password: (self userPassword).  "5"
		user
			cr;
			show: (tResult nextDataBlockString).  "6"
		self timerOn.  "7"
		super open.  "8"
		fOpenIndicator ← true.  "9"
	].
]
"
1. If the interface is already open, do nothing.
2. Make sure that the EtherWorld mechanism is in a valid state.
3. Release the interface to insure a valid initial state.  (An invalid state can occur from  an error on some statement in a previous invocation of 'open').
4. Create and initialize a JuniperSocket (parameterize server name?).
5. Issue a login command.
6. Display the login message that is returned by Juniper.
7. Turn on a timer to issue periodic noop commands to prevent timeout.
8. Do predefined open operations.
9. Set the interface status to 'open'.
"\gb5B108b2B9b1B
release
"...leaves the interface in a valid state after an error."
[
	fOpenIndicator ← nil.  "1"
	self timerOff.  "2"
	[ fJuniperSocket ≡ nil ⇒ [ ]
		fJuniperSocket close.  "3"
		fJuniperSocket ← nil.  "4"
	].
]
"
1. Set the interface status to 'not open'.
2. Turn off the timer.
3. Close the JuniperSocket if it exists.
4. Release the JuniperSocket field.
"\gb8B
versionNumbers [⇑true]\gb15B

FILE DIRECTORY (restricted)\gbf5 
Delete: pFile
"...deletes from the Juniper file system the file whose file name is specified by pFile (a JuniperFileController)."
	| tRequest
[
	tRequest ← self newRequestParameterBlock.  "1"
	tRequest nextDataBlockString ← (self checkDirectory: (pFile name)).  "2"
	self doAction: sDestroyFile requestPrs: tRequest.  "3"
]
"
1. Create a new request parameter block.
2. Get the file name from pFile, add the default directory name to it if necessary, and write it in the request parameter block.
3. Issue a 'destroy file' request.
"\gb14B115b2B10b1B
entryClass
"...returns the file class handled by the JuniperInterface."
[
	⇑ JuniperFileController
]\gb11B60b1B
Find: pFile
"...sends a 'look up file' request to the Juniper file server.  If the file is found, its name and long file handle are set in pFile (a JuniperFileController). Otherwise false is returned."
	| tRequest tResult
[
	fSpecialError ← sFileNotFound.  "1"
	tRequest ← self newRequestParameterBlock.  "2"
	tRequest nextDataBlockString ← (self checkDirectory: (pFile name)).  "3"
	tResult ← self doAction: sLookupFile requestPrs: tRequest.  "4"
	[ fSpecialError ≡ true ⇒ [ fSpecialError ← nil.  ⇑ false ]  "5"
		fSpecialError ← nil.  "6"
		pFile
			longFileHandle: tResult nextDataBlockString;
			name: tResult nextDataBlockString.  "7"
	].
]
"
1. Set the error handling mechanism to ignore a 'file not found' error.
2. Create a new request parameter block.
3. Get the file name from pFile, add the default directory name to it if necessary, and write it in the request parameter block.
4. Issue a 'look up file' request and get the result parameter block.
5. If a 'file not found' error was encountered, reset the error handling mechanism and return false.
6. (no error encountered) Reset the error handling mechanism.
7. Set the long file handle and name (from the result parameter block) in pFile.
"\gb12B189b2B18b1B
Insert: pFile
"...issues a 'create file' request to the Juniper file server and sets the returned long file handle and name in pFile (a JuniperFileController)."
	| tRequest tResult
[
	tRequest ← self newRequestParameterBlock.  "1"
	tRequest longInteger: 2 ← 0 "user rawtotalsecs".  "1.5"
	tRequest nextDataBlockString ← (self checkDirectory: (pFile name)).  "2"
	tRequest nextDataBlockString ← ''.  "3"
	tResult ← self doAction: sCreateFile requestPrs: tRequest.  "4"
	pFile
		longFileHandle: tResult nextDataBlockString;
		name: tResult nextDataBlockString.  "5"
]
"
1. Create a new request parameter block.
1.5 Set creation date (to default (current) -- later some specific date&time?)
2. Get the file name from pFile, add the default directory name to it if necessary, and write it in the request parameter block.
3. Blank the file server field of the request parameter block.
4. Issue a 'create file' request and get the result parameter block.
5. Set the long file handle and name (from the result parameter block) in pFile.
" \gb14B146b2B18b1B
Match: entries to: strm | entry pat ents name i p lastname [
	"search for Files matching patterns"
	for⦂ pat from: entries do⦂ [
		name ← self checkDirectory: pat name.
		i ← name find: '*'◦1. p ← name find: '#'◦1.
		i ← [p=0⇒ [i] i=0⇒ [p] i min: p].

		i=0⇒ [
			(self Find: pat)⇒ [
				"exact name found"
				strm next ← pat]]

		"pattern match over range of first to last possible matches"
		pat ← self makeEntry: name.
		entry ← self makeEntry: (name copy: 1 to: i-1).
		lastname ← name copy: 1 to: i.
		lastname◦i ← 0377.

		while⦂ ((entry ← self nextFile: entry) and⦂ entry name < lastname) do⦂ [
			pat match: entry⇒ [
				strm next ← entry.
				"copy entry since nextFile smashes into it"
				entry ← self makeEntry: entry name]
		].
	]]\gb24B
nextFile: pFile
"same as LookupFile (Find:), but it pertains to the file whose name is lexically next after the fileName specified in the request.  If the file is found, its name and long file handle are set in pFile (a JuniperFileController). Otherwise (no next file) false is returned."
	| tRequest tResult
[
	fSpecialError ← sFileNotFound.  "1"
	tRequest ← self newRequestParameterBlock.  "2"
	tRequest nextDataBlockString ← (self checkDirectory: (pFile name)).  "3"
	tResult ← self doAction: sNextFile requestPrs: tRequest.  "4"
	[ fSpecialError ≡ true ⇒ [ fSpecialError ← nil.  ⇑ false ]  "5"
		fSpecialError ← nil.  "6"
		pFile
			longFileHandle: tResult nextDataBlockString;
			name: tResult nextDataBlockString.  "7"
		⇑pFile
	].
]\gb16B272b2B18b1B
Rename: oldFile from: newFile
"renames a file on Juniper"
	| tRequest newName
[
	tRequest ← self newRequestParameterBlock.
	tRequest nextDataBlockString ← oldFile name.
	tRequest nextDataBlockString ← (newName ← self checkDirectory: newFile name).
	self doAction: sRenameFile requestPrs: tRequest.
	oldFile name: newName.
]\gb30B27b2B18b1B
server ["should be an instance variable?" ⇑'Juniper']\gb7B

JUNIPER COMMAND INTERFACE (restricted)\gbf5 
checkResult: pResult
"...is sent by doAction and doLogin to check the result of a Juniper request.  pResult is a result parameter block (JuniperResultParameterBlock) containing the packet (Pacbuf) returned as a result of the request."
[
	[ 
		[ ((pResult packet) ≡ false or⦂ pResult pupType = 4) or⦂ (pResult resultCode = sCommandNak and⦂ (pResult parameter: 1) = sTransactionAborting) ⇒  "3"
			[ [ fExceptionHandler ≡ nil ⇒ [ ]
					fExceptionHandler trap.  "4"
			  ].
			self error: 'No Juniper Transaction'.  "5"
			]
		].
		[ (pResult resultCode)
			= sCommandAck ⇒ [ ⇑ true ];  "6"
			= sCommandNak ⇒  "7"
				[
				[ self checkRetry: (pResult parameter: 1) ⇒ [ ⇑ false ]  "8"
					[ (pResult parameter: 1) = fSpecialError ⇒
						[ fSpecialError ← true.  ⇑ true ]  "9"
						self error: (pResult nextDataBlockString).  "10"
					].
				].
				]
			⇑ true  "11"
		].
	].
]
"
1. JuniperSocket sendRequest: and sendLogin: return false if no response is received from Juniper.
2. Invoke error handling if there is no response from Juniper.
3. Juniper returns an error pup (packet pup type  = 4) if the transaction has been aborted.
4. If the transaction has been aborted and there is an exception handler, then trap to the handler.
5. Invoke error handling if control is returned or if there is no exception handler.
6. Return true if a 'command acknowledged' was returned (this means success with no result parameters).
7. If a 'command not acknowledged' was returned,  an error condition exists.
8. Check for a retryable error and return false if so.
9. If the error is the same as that specified in the special error indicator, then indicate it and return true.
10. If not, invoke error handling.
11. Return true if a 'command not acknowledged' was not returned (this means success with result parameters).
"\gb21B213b1B
checkRetry: pErrorCode
"...is sent by checkResult to test for a retryable error.  Returns true if so; false otherwise."
[
	[ pErrorCode
		= sSequenceNumberGap ⇒ [ ⇑ true ];
		= sRecoveryUnderWay ⇒ [ ⇑ true ];
		= sTransactionClosing ⇒ [ ⇑ true ];
		= sCongestion ⇒ [ ⇑ true ]
			⇑ false
	].
]j\gb23B96b1B
doAction: pAction requestPrs: pRequest
"...corresponds to the Pine Protocol function.  The specified request, pAction, (selected from gJuniperConstants) with its corresponding request parameter block, pRequest (a JuniperRequestParameterBlock), is issued to the Juniper file server (through JuniperSocket sendRequest:). A packet is returned and inserted into a result parameter block and checked for error conditions.  If no errors are found, the result parameter block (a JuniperResultParameterBlock) is returned; otherwise, error handling is invoked.  If no request parameters are required, pRequest can be specified as nil."
	| tResult
[
	[ fOpenIndicator ≡ nil ⇒ [ self open. ]  "1"
	].
	[ pRequest ≡ nil ⇒ [ pRequest ← self newRequestParameterBlock. ]  "2"
	].
	fTimer disable.  "3"
	pRequest opcode ← pAction.  "4"
	pRequest pupType ← sRequest.  "5"
	tResult ← JuniperResultParameterBlock new.  "6"
	tResult packet ← (fJuniperSocket sendRequest: (pRequest packet)).  "7"
	fTimer reset.  "8"
	[ self checkResult: tResult ⇒ [ ⇑ tResult ]  "9"
			⇑ (self doAction: pAction requestPrs: pRequest)  "10"
	].
]
"
1. Make sure the JuniperInterface is open.
2. Create a request parameter block if none was specified.
3. Disable the timer to insure that a noop command is not sent while the current request is in progress.
4. Set the command code in the packet.
5. Set the packet pup type to 'request'.
6. Create a result parameter block.
7. Send the request to the JuniperSocket with the packet from the request parameter block; set the result packet in the result parameter block.
8. Reset the timer.
9. Check the result; if valid, return it.
10. If false is returned, then a retryable error was encountered so retry the command.
" \gb39B587b2B9b1B
doLogin: pRequest
"...is sent by login:password: with pRequest (a JuniperRequestParameter Block) set.  doLogin: issues a login request, checks for errors, and retries if necessary.  If no error occurs, a JuniperResultParameterBlock is returned; otherwise, error handling is invoked."
	| tResult
[
	tResult ← JuniperResultParameterBlock new.  "1"
	tResult packet ← (fJuniperSocket sendLogin: (pRequest packet)).  "2"
	[ self checkResult: tResult ⇒ [ ⇑ tResult ]  "3"
			⇑ (self doLogin: pRequest)  "4"
	].
]
"
1. Create a new result parameter block.
2. Issue a login request and set the result packet in the result parameter block.
3. Check the result and return it if there is no error.
4. Retry the request if there is a retryable error.
"\gb18B265b2B
error:  pMessage
"...is sent by checkResult if an error is encountered on a Juniper request.  (pMessage is a String containing an appropriate error message.)  The error message is formed and a notify window is displayed."
	| tMessage
[
	tMessage ← Stream default.
	tMessage append: pMessage.
	super error: (tMessage contents).
]\gb17B204b2B
newPacket
"...returns a new packet (Pacbuf) from the JuniperSocket."
[
	[ fJuniperSocket ≡ nil ⇒ [ self open. ]
	].
	⇑ (fJuniperSocket freePacket)
]\gb10B58b1B
newRequestParameterBlock
"...initializes and returns a new JuniperRequestParameterBlock."
	| tRequestParameterBlock
[
	[ fJuniperSocket ≡ nil ⇒ [ self open. ]  "1"
	].
	tRequestParameterBlock ← JuniperRequestParameterBlock new.  "2"
	tRequestParameterBlock
		packet ← (fJuniperSocket freePacket);  "3"
		dataBlockLength ← 0;  "4"
		leader: 1 ← 0;
		leader: 2 ← 0.  "5"
	⇑ tRequestParameterBlock  "6"
]
"
1. Open the interface if it is not already.
2. Create a new request parameter block.
3. Create a new packet and set it in the request parameter block.
4. Set the data block length to 0.
5. Set the authentication key and reserved word to 0.
6. Return the initialized request parameter block.
"\gb25B64b2B24b1B

TIMER (internal)\gbf5 
noOp	
"...sends a noop command to the Juniper file server.  It's only effect is to reset the timout mechanism of the server."
	| tPacket
[
	tPacket ← fJuniperSocket freePacket.  "1"
	tPacket pupType ← sNoop.  "2"
	tPacket dataString ← ''.  "3"
	fJuniperSocket setAddressesAndComplete: tPacket; timerOff.  "4"
]
"
1. Get a new packet (Pacbuf).
2. Set packet pup type to 'noop'.
3. Set the dataString to the empty string.  This has the necessary effect of setting the packet length to 0.
4. Send the packet.  It is necessary to bypass the normal JuniperSocket interface (sendRequest:) because no acknowledgement is returned for the noop.
"\gb6B
timerOff
"...disables fTimer and sets it to nil."
[
	[ fTimer ≡ nil ⇒ [ ]
		fTimer disable.
		fTimer ← nil.
	].
]\gb9B
timerOn
"...assigns fTimer to a new timer object that wakes up every 100 seconds (6000 1/60 seconds) and issues a 'noop' command to Juniper.  This  is used to prevent Juniper from timing out during periods of inactivity."
[
	self timerOff.  "1"
	fTimer ← Timer new.  "2"  
	fTimer for: 6000 action⦂ [ self noOp.  user show: '.'.  fTimer reset. ].  "3"
	user cr.
	fTimer reset.  "4"
]
"
1. Make sure that the current timer is released.
2. Create a new timer.
3. Set the timer interval to 100 seconds.  The action of the timer is to send a noop, show a dot in the dispFrame, and reset.
4. Activate the timer.
" \gb8B

MISC (internal)\gbf5 
checkDirectory: pFileName | ps 
"...returns a string that has the default directory name added to the beginning of pFileName (a String) unless pFileName already begins with a directory name in which case it is returned unchanged. max length of ~58"
[
	ps ← (String new: 60) asStream.

	[pFileName length > 0 and⦂ (pFileName◦1) = ('<'◦1)⇒ []
	ps append: '<'; append: self directory; append: '>'].

	ps append: pFileName.
	[ps last = ('.'◦1)⇒ [ps skip: ¬1]].
	⇑ps contents
]\gb26B5b1B216b1B
directory
"...Returns a string specifying the default file name directory.  The default directory is fDefaultDirectory if it is not nil, otherwise it is self name"
[
	[ fDefaultDirectory ≡ nil ⇒
		[ ⇑ self userName
		]
		⇑ fDefaultDirectory
	].
]\gb10B153b1B
hash: pString
"...returns a hash value for pString (a String)."
	| tHash1 tHash2 i
[
	tHash1 ← 0.  tHash2 ← 0.
	for⦂ i from: 1 to: (pString length) by: 2 do⦂
		[ tHash1 ← tHash1 lxor: (UpperCase◦(pString◦i+1)).
		tHash2 ← tHash2 lxor:
			[ i = (pString length) ⇒ [ 040 ]
				UpperCase◦(pString◦(i+1)+1)
			].
		].
	⇑ (tHash1*256 + tHash2)
]\gb14B49b2B
login: pName password: pPassword
"...sets the necessary request parameters and invokes doLogin to issue a login request.  pName (a String) specifies the name of an account on the Juniper file system.  pPassword (a String) specifies the password of the account."
	| tRequest
[
	tRequest ← self newRequestParameterBlock.  "1"
	tRequest
		leader: 3 ← sLogin;  "2"
		leader: 4 ← 512;  "3"
		leader: 5 ← 7;  "4"
		leader: 6 ← (self hash: pPassword);  "5"
		nextDataBlockString ← pName;  "6"
		pupType ← sCustodian.  "7"
	⇑ (self doLogin: tRequest)  "8"
]
"
1. Create a new request parameter block.
2. Set the command to Login.
3. Set the number of bytes per page to 512.
4. Set the Juniper version number to 7 (Nov 80).
5. Set the hashed account password to pPassword hashed.
6. Set the account name to pName.
7. Set the packet pup type to custodian.
8. Issue the request and return the result.
"\gb33B228b2B10b1B
userName
"...returns the account name or a default (a String)."
[
	[ fName ≡ nil ⇒ [ ⇑ super userName ]
			⇑ fName
	].
]\gb9B54b1B
userPassword
"...returns the account password or a default (a String)."
[
	[ fPassword ≡ nil ⇒ [ ⇑ super userPassword ]
			⇑ fPassword
	].
]\gb13B58b1B

CLASS INIT\gbf5 
classInit
"...initializes the constants in gJuniperConstants
(see [ivy] <Juniper>4.4> CommonPineDefs.mesa).
Do the following to initialize:
Smalltalk declare: ↪gJuniperConstants as: (SymbolTable new init: 256).
JuniperInterface classInit."
	| tIndex tConstant
[
	for⦂ tConstant from: (self juniperConstants) do⦂
		[	[ tConstant is: Integer ⇒
				[ tIndex ← tConstant. ]
				gJuniperConstants declare: tConstant as: tIndex.
				tIndex ← tIndex+1.
			].
		].
]\gb10B
juniperConstants
"...returns the set of constants used to specify requests to and to  interpret results from the Juniper file system."
[
	⇑
	↪(
0250  "PineMsgType (Pup types)"
sRequest sResult sUnsolicited sCustodian sSync sPineAck sNoop

5  "DataRequest"
sReadPage sWritePage sSetLength sReadLength sCloseFile sDestroyAnonymousFile sReadData sWriteData sReadAttribute sWriteAttribute sSetWriteLock sSetReadLock sReleaseReadLock

32  "TransactionRequest"
sChangePassword sRoom sOpenFile sCreateAnonymousFile sFindFile sLockQuery sTransCompletionQuery

42  "ActivityRequest"
sLogout sCloseTransaction sAbortTransaction sLoginRequest

60  "DirectoryRequest"
sLookupFile sCreateFile sDestroyFile sRenameFile sNextFile sNextFewFiles

1  "ResultCode"
sCommandNak sCommandAck sHeresData sHeresEntry sHeresFileList sHeresLFH sHeresFile sHeresLength sLoginResponse sLogoutResponse sTransactionClosed sTransCompletionInfo sResourceData sHeresRoom

0  "Unsolicited Code"
sTransactionAborted sReadLockBroken

8  "CustodianCode"
sLogin sAddServer sResourceLocation

42  "PineErrorCode"

"TransTroubleCode"
sUnimplementedFeature sIllegalLoginAttempt sSoftwareVersionMismatch sNoSuchUser sPasswordMismatch sBytesPerPageUnacceptable sServerTooBusy sOutOfSpace sNoFilesHere sNoDirectoryHere sIllegalFileName sFileNotFound sFileAlreadyExists sTransactionAborting sNoSuchOpenFile sBigFilesNotImplemented sIllegalAttribute sReadAttributeProtectionError sUserAskedForIt sWriteAttributeProtectionError sPackNotOnDrive sTooManyOpenFiles sProtectionViolation sFileNotOnPack sPackFull sFileRefOutOfBounds sFileSizeExcessive sByteRangeExcessive sPackNotOnMachine sNoSuchTransaction sBrokenLock sInconvenientUnwind

"Retryable"
sSequenceNumberGap sRecoveryUnderWay sTransactionClosing sCongestion

120 "UserDetected"
sBlockTooLarge sNoRouteToServer sServerUnknown sBadBytesPerPage sInvalidRequest sPupGlitch sUnableToDecrypt sNoResponseToRequest sNewServerUnwilling sTransactionInUnknownState sBadTimeForRequests
	  )
]\gb17B

TEST / DIAGNOSTIC\gbf5 
test
["
	dpj ← nil.
	dpj ← JuniperInterface new.
	dpj release.
	dpj open.
	dpj close.
	| f  [ dpj open.  f ← dpj file: 'test.test'.
until⦂ [ f end ] do⦂ [ user show: (f next) inString. ]. f close. dpj close. ]

JuniperSocket howMany 2 1 2 2 2  11 Timer howMany  33  NameUser howMany 1 1 1
"] \gb5B
\g
SystemOrganization classify: ↪JuniperInterface under: 'Juniper'.\g
JuniperInterface classInit\g

"JuniperPageBuffer"l15000z20000\gbf5 
Class new title: 'JuniperPageBuffer'
	subclassof: EtherFilePage
	fields: '
		fLength
		fPageNumber
		fSerialNumber
	'
	declare: '';
	asFollows\gbf5 

JUNIPER PAGE BUFFER\gi

DOCUMENTATION\gbf5 
implementationNotes
[
"
FIELDS
fLength : an Integer specifiying the number of bytes in the page buffer.
fPageNumber : an Integer specifying the number of the page buffer.
fSerialNumber : an Integer specifying the serial number of the page buffer. 
"]\gb20B11b7B66b11B56b13B

FILE PAGE OPERATIONS\gbf5 
length
"...returns the number of bytes in the page buffer."
[
	⇑ fLength
]\gb7B
length: pLength
"...sets the number of bytes in the page buffer."
[
	fLength ← pLength.
	super length: pLength.
]\gb16B
pageNumber
"...returns the page number of the page buffer."
[
	⇑ fPageNumber
]\gb11B
pageNumber: pPageNumber
"...sets the page number of the page buffer."
[
	fPageNumber ← pPageNumber.
]\gb24B
serialNumber
"...returns the serial number of the page buffer."
[
	⇑ fSerialNumber
]\gb13B
serialNumber: pSerialNumber
"...sets the serial number of the page buffer."
[
	fSerialNumber ← pSerialNumber.
]\gb28B
\g
SystemOrganization classify: ↪JuniperPageBuffer under: 'Juniper'.\g

"JuniperParameterBlock"l15000z20000\gbf5 
Class new title: 'JuniperParameterBlock'
	subclassof: Object
	fields: '
		fPacket
		fDataBlockPosition
	'
	declare: '';
	asFollows\gbf5 

JUNIPER PARAMETER BLOCK\gi

DOCUMENTATION\gbf5 
implementationNotes
[
"
FIELDS
fPacket : a Pacbuf for sending request commands and parameters to the Juniper file server.
fDataBlockPosition : an Integer specifying the current position in the data block of fPacket.
"
]\gb20B11b7B84b18B

OPERATIONS\gbf5 
dataBlockAdvance: pIncrement
"...advances the data block position by pIncrement (an Integer)."
[
	fDataBlockPosition ← fDataBlockPosition + pIncrement.
]\gb29B
dataBlockGet
"...returns the current data block as a Stream."
[
	⇑ ( (Stream new)
			of: (fPacket pupString)
			from: fDataBlockPosition
			to: ( 4 + (fPacket pupLength) - 2 )
		)
]\gb13B
dataBlockLength
"...returns the number of bytes (an Integer) in the data block."
[
	⇑ ((fPacket pupLength) - 42)
]\gb16B
dataBlockLength ← pLength
"...sets the number of bytes in the data block to pLength (an Integer)."
[
	fPacket pupLength ← pLength + 42.
]\gb26B
leader: pIndex
"...returns the leader word (an Integer) specified by pIndex (an Integer) from the packet."
[
	⇑ (fPacket word: (12 + pIndex))
]\gb15B
leader: pIndex ← pValue
"...sets pValue (an Integer) in the packet at the leader word specified by pIndex (an Integer)."
[
	fPacket word: (12 + pIndex) ← pValue.
]\gb24B
packet
"...returns the packet (a Pacbuf)."
[
	⇑ fPacket
]\gb7B
packet ← pPacket
"...sets the packet to pPacket (a Pacbuf) and resets the data block position."
[
	fPacket ← pPacket.
	fDataBlockPosition ← 45.
]\gb17B
pupType
"...returns the pup type (an Integer) of the packet."
[
	⇑ (fPacket pupType)
]\gb8B
pupType ← pPupType
"...sets the pup type of the packet to pPupType (an Integer)."
[
	fPacket pupType ← pPupType.
]\gb19B
\g
SystemOrganization classify: ↪JuniperParameterBlock under: 'Juniper'.\g

"JuniperRequestParameterBlock"l15000z20000\gbf5 
Class new title: 'JuniperRequestParameterBlock'
	subclassof: JuniperParameterBlock
	fields: ''
	declare: '';
	asFollows\gbf5 

JUNIPER REQUEST PARAMETER BLOCK\gi

OPERATIONS\gbf5 
longInteger: pPosition ← pValue
"...sets pValue (4 bytes of long integer) in the packet at the parameter position specified by pPosition (an Integer)."
	| tString tPosition
[
	tString ← fPacket pupString.
	tPosition ← (pPosition + 16)*2 - 1.
	( (Stream new) of: tString from: tPosition to: (tPosition+3)
	) nextNumber: 4 ← pValue.
	tString
		swap: tPosition with: tPosition+2;
		swap: tPosition+1 with: tPosition+3.
]
"
1. the two words of a Juniper long integers are stored in reverse order from those in Smalltalk.
"\gb32B
nextDataBlockString ← pString
"...sets pString (a String) in the data block at the current position and advances the position."
	| tDataBlock tString tLength tMaxLength
[
	fPacket pupLength ← 554.  "1"
	tDataBlock ← self dataBlockGet.  "2"
	tLength ← pString length.  "3"
	tMaxLength ← (tLength+1) land: 0177776.  "4"
	tDataBlock
		nextword ← tLength;  "5"
		nextword ← tMaxLength;  "6"
		append: pString;  "7"
		next: (tMaxLength - tLength) ← 0.  "8"
	self dataBlockAdvance: (4 + tMaxLength).  "9"
]
"
1. Set the length of the packet to the maximum size.  The length of each string in the data block is specified in the data block itself.
2. Get the data block (as a Stream) from the current position to the end.
3. Get the length of pString.
4. Determine the length of pString including padding needed to make its length even.
5. Set the length of pString in the data block (2 bytes).
6. Set the length of pString with padding in the data block (2 bytes).
7. Set pString in the data block.
8. Add padding in the data block.
9. Advance the current data block position past length, maximum length, and pString.
"\gb30B
opcode ← pOpcode
"...sets the request opcode field in the packet to pOpcode (an Integer)."
[
	fPacket word: 16 ← pOpcode.
]\gb17B
parameter: pIndex ← pValue
"...sets pValue (an Integer) in the packet at the request parameter field specified by pIndex (an Integer)."
[
	fPacket word: (16+pIndex) ← pValue.
]\gb27B
shortFileHandle ← pShortFileHandle
"...sets the request short file handle field in the packet to pShortFileHandle (an Integer)."
[
	fPacket word: 15 ← pShortFileHandle.
]\gb35B
\g
SystemOrganization classify: ↪JuniperRequestParameterBlock under: 'Juniper'.\g

"JuniperResultParameterBlock"l15000z20000\gbf5 
Class new title: 'JuniperResultParameterBlock'
	subclassof: JuniperParameterBlock
	fields: ''
	declare: '';
	asFollows\gbf5 

JUNIPER RESULT PARAMETER BLOCK\gi

OPERATIONS\gbf5 
longInteger: pPosition
"...returns the 4 bytes of long integer in the packet at the parameter position specified by pPosition (an Integer)."
	| tArray tPosition
[
	tPosition ← (pPosition + 15)*2 - 1.
	tArray ←
		( (Stream new)
			of: (fPacket pupString) from: tPosition to: (tPosition+3)
		) next: 4.
	tArray
		swap: 1 with: 3;
		swap: 2 with: 4.  "1"
	⇑ ((tArray asStream) nextNumber: 4)
]
"
1. Juniper long integers are stored in reverse order from those in Smalltalk.
"\gb23B
nextDataBlockString
"...returns the string in the data block at the current position and advances the position."
	| tDataBlock tString tLength tMaxLength
[
	tDataBlock ← self dataBlockGet.  "1"
	tLength ← tDataBlock nextword.  "2"
	tMaxLength ← tDataBlock nextword.  "3"
	tString ← tDataBlock next: tLength.  "4"
	self dataBlockAdvance: (4 + tMaxLength).  "5"
	⇑ tString  "6"
]
"
1. Get the data block (as a Stream) from the current position to the end.
2. Get the length of the next string.
3. Get the length of the string including possible padding.
4. Get the next string from the data block.
5. Position the data block past the length, maximum length, string, and padding.
6. Return the string.
"\gb20B
parameter: pIndex
"...returns from the packet the result parameter (an Integer) specified by pIndex (an Integer)."
[
	⇑ (fPacket word: (15+pIndex))
]\gb18B
resultCode
"...returns the result code (an Integer) from the result packet."
[
	⇑ (fPacket word: 15)
]\gb11B
\g
SystemOrganization classify: ↪JuniperResultParameterBlock under: 'Juniper'.\g

"JuniperSocket"l15000z20000\gbf5 
Class new title: 'JuniperSocket'
	subclassof: RetransmitSocket
	fields: 'seqNum outPac loginPending notWaiting result outAck'
	declare: '';
	asFollows\gbf5 

A Socket for communicating with the Juniper File Server. 
Derived from the class WSocket, jfs, 2/79.
see Classes WoodstockFile, WoodstockFilePage, and WoodstockFileDirectory\gi

Initialization/Termination\gbf5 
net: pNet host: pHost 
"start with the well known Juniper listener, leave filterInput false"
[
	super net: pNet host: pHost soc: 0100 asInt32.
	self retransmit: 3 every: 500.  "8 sec"
	outAck ← self freePacket.  "for the outgoing pineAck"
	outAck pupType ← 0255.
	outAck pupID1 ← 0.
	outAck dataString ← ''.  "also sets length; need to set addresses later"
]\gb23B69b1B

Socket\gbf5 
sendLogin: outPac 
	[
	"Special routine to send login, wait for ack, retransmit.
	Need to reset seqNum, and get new Juniper socket number.
	Will return the Juniper response packet, or else a false."
	frnSocNum high: 0 low: 0100.
	self setOutAddBlock.  filterInput ← false.
	outPac pupID0 ← 0. outPac pupID1 ← seqNum ← 0.  
	notWaiting ← false.
	loginPending ← true.
	self setAddressesAndComplete: outPac.
	until⦂ [notWaiting] do⦂ [ ].
	"all done"
	⇑result.
	]\gb20B4i173I
sendRequest: outPac 
	[
	"General routine to send request packets, wait for ack, retransmit.
	Will return the Juniper response packet, or else a false."
	notWaiting ← false.
	outPac pupID0 ← (seqNum ← seqNum + 1).  
	self setAddressesAndComplete: outPac.
	until⦂ [notWaiting] do⦂ [ ].
	"all done"
	⇑result.
	]\gb22B4i125I
socProcess: Ipac | temp
	["Juniper has responded, we're running at a high level"
	loginPending ⇒ "handle this special case"
		["watch out, src has not been checked"
		((frnNet ≠ Ipac sourceNet) or⦂ (frnHost ≠ Ipac sourceHost)) or⦂
		((0251 ≠ Ipac pupType) or⦂ (0 ≠ Ipac pupID0)) ⇒
			["discard it"  "Ipac ← self freePacket: Ipac"]

		"this must be it!"
		frnSocNum high: Ipac sourceSoc0 low: Ipac sourceSoc1.
		self setOutAddBlock. self setAddresses: outAck.  "for later use"
		"generate an ack" outAck pupID0 ← 0.
		self completePup: outAck.
		loginPending←false.  notWaiting ← filterInput ← true.
		result ← Ipac.
		]

	"src. and dest. should have been checked ??)"

	Ipac pupType = 0251⇒ [
		"might be a retransmission of a previous Juniper response or what we want.
		acknowledge in either case then see whether we want to keep the result"
		outAck pupID0 ← Ipac pupID0.
		self completePup: outAck.
		notWaiting or⦂ seqNum ≠ Ipac pupID0⇒ ["Ipac ← self freePacket: Ipac"]
		notWaiting←true.
		result ← Ipac]

	"Ipac pupType = 0255 ⇒ [Ipac←self freePacket: Ipac]" "discard pineack"
	notWaiting≡false and⦂ ((Ipac pupType = 4) and⦂ (Ipac word: 23) = 2) ⇒ [
		"no socket at Juniper"
		self timerOff.  notWaiting←true.   result←Ipac. ].
	"Ipac ← self freePacket: Ipac."
	]\gb25B2i53I
timerFired  
	[
	"This piece of code only runs when a timer fires!
	Thus, there is mutual exclusion between this and other timer code.
	Runs below the ethernet input.   Don't do an active return
	Timer sometimes fires even though its been disabled!"

	notWaiting⇒ [] 
	self timerOn⇒ [
		"go ahead and retransmit....."
		self completePup: outPac
		]
	notWaiting ← true. result ← false.
	]\gb14B4i230I40i28I
\g
SystemOrganization classify: ↪JuniperSocket under: 'Juniper'.\g
