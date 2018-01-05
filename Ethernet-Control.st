'From Smalltalk 5.5k XM November 24 on 5 February 2037 at 11:23:01 pm.'
\g
"Etherworld"l15000z20000\gbf5 
Class new title: 'Etherworld'
	subclassof: Object
	fields: ''
	declare: '';
	sharing: EtherPool;
	asFollows\gbf5 

This is, of course, the class that controls all of the basic ethernet operations.  There should not be more than one EtherWorld, and one, E, has to be defined for the system to work.    

In this implementation, and due to timing considerations, it is expected that the transmitter will post quite quickly;  thus, we disable interrupts and busy wait for its completion.

In general, the interrupt is only armed when we have started the receiver.  The Etherworld currently uses these input processes in the PrioityScheduler: 
	IntProc, at IntProcLevel (14)  -- awakened when the device interrupts
	InputProc, at InputProcLevel (13) -- distributes packets to sockets, 
	allowing each  socket to then run.

Note that some of the timers may be on other levels.

The ethernet can be in one of several states:
	if E  nil, there is nothing
	if E ~ nil, etherState can be ethAwake, ethAsleep, ethDead.

ethDead means E created, and classInit done, but nothing else.
ethAsleep means all data structures created, but no attempt to start.
ethAwake means it is up and running.

The messages wakeup,  sleep and kill move to one of those states.
Other messages are used for single transitions from adjacent states.

If you just want to temporarily prevent the device from running use etherStop and etherStart.
Should go to ethAsleep (use E sleep) if you quit, since may come up on a different machine.

The lights on the right side of the screen are Etherworld signals.  They mean  Etherworld awakened; packet addressed to the Alto received; packet being processed; output being sent; and input rejected.
\gi

Initialization/Termination\gbf5 
classInit 
[
"if this needs to be filed in again, execute this first
	Smalltalk declare: EtherPool as: (SymbolTable new init: 32).

access variables from outside with (for example) with EtherPoolethAwake"

Smalltalk declare: (E).

EtherPool declare: ( ethInPacNext checkIncomingCS  
	IntProcLevel InputProcLevel ethIntBits
	etherState ethAwake ethAsleep ethDead)
	as: (false,false,14,13,020,0,3,1,0).

EtherPool declare: (  
	NETNUM ALTONUM 
	freeQ justArrivedQ   
	sockeTable routingTable routingHopCount routingUpdateUser
	IntProc InputProc broadcastFilter 
	IntLight InputLight OutputLight )]\gb11B
etherStart "allows ether to start running again"
	[
	"makes sure the interrupt is on, and kicks the device"
	etherState=ethAwake 
		[
		[mem0601=0 [mem0601_ethIntBits]]. 
		self SIO: 3.   "forces it to wake up again"
		].
	self notify: 'Attempt to etherStart when not awake!!.'.
	]\gb11B
etherStop "temporarily shuts off the ether stuff"
	[
		Top critical 
			[
			mem0601_0.
			self SIO: 3.
			mem0600 _ 0.
			].
	]\gb10B
Init | i "move from state ethDead to ethAsleep"
	[
	"if we were already running, bring it all down, just in case!!"
	[etherState=ethDead  [] self kill]. "now sure we are ethDead"
	NETNUM _ ALTONUM_0.  "may get reset later"
	self setLights.
	(justArrivedQ_(SafeQ new) of: (Vector new: 20)) enable.
	[freeQ [
		(freeQ_ (SafeQ new) of: (Vector new: 20)) enable.
		for i to: 10 do [freeQ next_ Pacbuf init]]
	justArrivedQ disable].

	ethInPacNext_ self freePacket.
	sockeTable_ Dictionary new init: 10. 
	routingTable_ String new: 255.
	routingTable all _ 0. "1-255, 0 is special"
	routingHopCount _ String new: 255.
	routingHopCount all _ 8.
	routingUpdateUser _ RoutingUpdater init.
	self installIntProc.
	self installInputProc.
	IntProc enable.
	InputProc enable.
	etherState _ ethAsleep.
	"we are still asleep, must do a wakeup to get numbers, start, etc."
	]\gb5B5i36I7i61I41i23I
kill | socket "shuts down ethernet and PUP world completely"
	[
		"Should free up all of the storage, etc.....
		Would need to wakeup or Init, to get started again.
		Device may have been running"
		etherState=ethDead[] "do nothing"
		[etherState=ethAwake  [self sleep]].
		"everything now shut down"
		for socket from: (sockeTable values) do
			[socketnil[] socket kill]. 
		Top terminate: IntProcLevel; terminate: InputProcLevel.
		[
		ethInPacNext 
			[
			ethInPacNextnil []
			ethInPacNext locked[ethInPacNext unlock]
			]
		].
		ethInPacNext _ false.
		"Release the PQueues to avoid circular data structures"
		[freeQ and freeQnil[freeQ release. freeQ _ nil]].
		[justArrivedQnil[justArrivedQ release. justArrivedQ _ nil]].
		[routingUpdateUser nil [] routingUpdateUser release].
		routingUpdateUser _ routingTable _ routingHopCount _ nil.
		etherState _ ethDead.
	]\gb14B
setLights
	[IntLight_ Rectangle new origin: 5760 extent: 1616.
	InputLight_ Rectangle new origin: 5920 extent: 1616.
	OutputLight_Rectangle new origin: 57616 extent: 1616]\gb11B
sleep | socket "be sure to do this before a user quit" 
	[
	etherState=ethDead  [self Init] "that is, go from dead to asleep"
	etherState=ethAsleep  [] "already asleep"
	etherState=ethAwake  
		["try to shut down gracefully"
		for socket from: (sockeTable values) do
			[socketnil[] socket sleep]. "warn the sockets, leaves them in table"
		self etherStop.
		etherState_ethAsleep.
		"when next we wake up, may be on a new machine/net"
		].
	"when next we wake up, may be on a new machine/net"
	]\gb6B
wakeup | socket "Try to get everything up and running" 
	[
	etherState=ethAwake  [self etherStart] "do nothing, kick the receiver".
	[etherState=ethDead  [self sleep]]. "that is, go from dead to asleep"
	etherState=ethAsleep 
		["this is the tricky one, need to get our machine # and routing table.
		may have come up on a different network and host, assume the worst"
		ALTONUM _ self getMachineID.
		self setMachineID: ALTONUM.
		NETNUM _ 0.
		for socket from: sockeTable values do [
			socketnil [] socket setOutAddBlock].

		etherState _ ethAwake.
		self etherStart.
		routingUpdateUser update.
		NETNUM = 0 [
			etherState _ ethAsleep.
			user notify: 'no routing tables']

		"tell leftover sockets current net&host, and that we are awake again"
		for socket from: (sockeTable values) do
			[socketnil[] socket setOutAddBlock; wakeup]. 
		].
	self notify: 'In wakeup, found Ethernet in some unknown state.'.
	]\gb7B

Input Interrupt Routines\gbf5 
copyinput: string [user croak] primitive: 108\gb18B
installInputProc | inBuf destSoc [
	InputProc _ Top install [
		while [true] do [  "infinite loop for process in scheduler"
			InputLight comp. 
			while [inBuf_justArrivedQ next] do [
				"process each incoming buffer, know it's a PUP"
				"verify the incoming checksum"
				checkIncomingCS and (inBuf checksumOK)false
					["reject it, done" self freePacket: inBuf]
				"To be honest, we should check the destNet and destHost,
				but they generally have to be OK.....
				OK to pass the packet on"
				(destSoc _ sockeTable lookup: inBuf destSocNum) 
					[ destSoc acceptPacbuf: inBuf].
				"couldn't find a socket for it, done"
				 self freePacket: inBuf]. 
			InputLight comp. 
			InputProc sleep   "last action in the loop"]] 
	at: InputProcLevel]\gb17B70i38I70i45I7i28I60i15I31i126I98i35I76i23I
installIntProc  [
	IntProc _ Top install [
		while [true] do [  "infinite loop for process in scheduler.
			Interrupt just happened, running at a high level, interface off.
			Something just happened, do the common cases first.
			Input is wired down below; only comes here if OK.
			Note: we can only come here if last action was to start the rec!!"

			IntLight comp. 
			"copy out the packet first"
			[ethInPacNext [self copyinput: ethInPacNext pupString]
			"user cr; show: 'warning, no packet pre-fetched. tell John'."
			ethInPacNext _ self freePacket [self copyinput: ethInPacNext pupString]
			"user cr; show: 'input lost'"].

			"start the receiver"
			self SIO: 2.
			[ethInPacNext [
				"now process this input"
				justArrivedQ next_ ethInPacNext. 
				ethInPacNext _ self freePacket.
				Top wakeup: InputProcLevel.  "all done"
				]].

			IntLight comp. 
			IntProc sleep    "last action in the loop"]]
	at: IntProcLevel]
\gb16B52i284I26i25I242i18I43i22I110i8I51i23I

Output Routines\gbf5 
doOutput: string [] primitive: 100\gb17B
sendOutput: ethOutPac | post
	[
			"This is the one and only place from which we  send output.
			Only one packet gets passed in to us at a time.
			For performance, we wait here for the transmitter to post!!!!
			Nominally, we are running at level 0;  thus, this must be run
			at a Top critical, to protect from multiple calls."
			[etherStateethAwake  
				[self wakeup. user show: 'starting Ethernet...']].
			Top critical
				[
				OutputLight comp. 
				mem0606_ (ethOutPac totLengthWords)."EthOutCntLoc"
				[(post _ self doOutput: ethOutPac pupString)  0777  
					[user cr; show: 'Warning, bad output post: '+ post base8]].
				OutputLight comp. 
				]. "end of the critical part"
	]\gb22B14i293I

User messages\gbf5 
awake [etherState = ethAwake]\gb6B
broadcastFilter: val
	[val  [broadcastFilter_true. self broadcastFilterSet: 1] 
			broadcastFilter _ false.  self broadcastFilterSet: 0.]\gb22B
broadcastFilterSet: val
	[user croak ] primitive: 107\gb25B
freePacket | p [
	"get a packet"
	freeQ [
		(p _ freeQ next)  [p]
		user show: 'Warning, empty freeQ, in Etherworld'.
		false]
	Pacbuf new init]\gb11B8i12I
freePacket: p [
	"put a used packet into free queue"
	[freeQ and p [freeQ next _ p]].
	false]\gb14B4i33I

Utility messages\gbf5 
error: str [user cr. user show: str]\gb11B
fill | "I want to replenish the freeQ" outstanding [
	freeQfalse or freeQnil []
	outstanding _ (Pacbuf howMany) - (freeQ length).
	user cr; show: (outstanding asString)+' packets outstanding'.
	until [freeQ length=10] do [freeQ next _ Pacbuf init].
	]\gb5B
getMachineID  [ (self SIO: 0) \ 256]\gb14B
notify: strng | "turn off the Ethernet before doing a user notify" 
	[self etherStop.
	user show: ' Etherworld stopped'.
	 [Top currentPriority  1[user cr; show: 'priority is ' + (Top currentPriority) asString.  ]].
	 user notify: strng]
	\gb14B
printon: s [
	etherState = ethDead  [s append: 'Etherworld,  etherState = ethDead.'].
	s append: 'Etherworld running on '; print: NETNUM;
		append: '#'+(ALTONUM base8)+'#' ; cr.
	[freeQ [s print: freeQ length; append: ' Pacbufs in freeQ']
		s append: 'no freeQ'].
	s cr; append: 'etherState = '.
	etherState = ethAsleep  [s append: 'etherAsleep'].
	etherState = ethAwake  [s append: 'etherAwake'].
	s print: etherState.
	]\gb11B
printRoutingTable | i 
	[
	for i from: 1 to: 255 do 
		[
		routingTablei  0 
			[
			user cr.  user show: 'To net ' + i asString + 
				' via host ' + (routingTablei) asString + ', hop count = ' +
				(routingHopCounti) asString.
			]
		]
	user cr.
	] \gb18B2b2B
printSocketTable | i [
	sockeTablenil[user cr; show: 'no socketTable']
	for i from: sockeTable objects do [
		inil[]
		user cr; print: i; show: ', '; print: sockeTablei
		]
	]
	\gb17B
setMachineID: ID [mem0610 _ ID]\gb17B
SIO: sioArg [] primitive: 91\gb12B
\g
SystemOrganization classify: Etherworld under: 'Ethernet Control'.\g
Etherworld classInit\g

"Int32"l15000z20000\gbf5 
Class new title: 'Int32'
	subclassof: Number
	fields: 'high low'
	declare: '';
	asFollows\gbf5 

This class should probably be part of Number rather than Etherworld.
NOTE THAT + AND - SHOULD BE FIXED TO RETURN TO SMALLTALK IF TYPE OF ARG IS NOT INT32\gi

Initialization\gbf5 
asInteger [high = 0  [ low] high*65536 + low]\gb10B
high: high low: low\gb

Info about self\gbf5 
hash [ low]\gb5B
high [ high]\gb5B
low [ low]\gb4B
printon: strm 
	[high printon: strm base: 8. strm append: '|'. low printon: strm base: 8 ]\gb16B

Arithmetic\gbf5 
 arg [ low  arg low or high  arg high]\gb6B
+ arg [self + arg asInt32] primitive: 93\gb6B
- arg [self - arg asInt32] primitive: 92\gb6B
< arg "revised M. Dolbec 6/25/80"
	[high = arg high 
		[low < 0  
			[arg low < 0  
				[low > arg low]
				false]
				arg low > 0 
					[low < arg low] 
					true]
		high < arg high]\gb6Bi27bI2B
= arg [low = arg low and high = arg high]\gb6B
> arg "revised M. Dolbec 6/25/80"
	[arg < self]\gb6Bi27bI2B
\g
SystemOrganization classify: Int32 under: 'Ethernet Control'.\g

"Pacbuf"l15000z20000\gbf5 
Class new title: 'Pacbuf'
	subclassof: Object
	fields: 'pupString locked'
	declare: '';
	asFollows\gbf5 

This is the basic unit for building and interpreting packets for the ethernet.
It contains the messages that allow fields of a packet to be filled and read.
Most users will prefer to use the socket mechanisms\gi

Initialization\gbf5 
init 
	[pupString _ String new: 558.
	locked _ false]\gb7B

Ethernet header\gbf5 
ethType [pupString word: 2]\gb8B
ethType_ eT [pupString word: 2 _ eT]\gb12B
imEthDestHost [pupString1]\gb14B
imEthDestHost_ iEDH [pupString1 _ iEDH]\gb20B
imEthSrcHost [pupString2]\gb13B
imEthSrcHost_ iESH [pupString2 _ iESH]\gb19B

PUP Header\gbf5 
addressBlock [pupString(13 to: 24) ]\gb13B
addressBlock_ addBlock "for quickly setting the 6 fields" [
	"pupString(13 to: 24) _ addBlock"
	pupString copy: 13 to: 24 with: addBlock from: 1 to: 12]\gb23B
destHost [pupString14]\gb9B
destHost_ dH [pupString14 _ dH]\gb13B
destNet [pupString13]\gb8B
destNet_ dN [pupString13 _  dN]\gb12B
destSoc0 [pupString word: 8]\gb9B
destSoc0_ i [pupString word: 8_i]\gb12B
destSoc1 [pupString word: 9]\gb9B
destSoc1_ i [pupString word: 9_i]\gb12B
destSocNum [Int32 new high: (pupString word: 8) low: (pupString word: 9) ]\gb11B
destSocNum_ dSN [pupString word: 8 _ dSN high.
						 pupString word: 9 _ dSN low]\gb16B
pupID [Int32 new high: (pupString word: 5) low: (pupString word: 6) ]\gb6B
pupID0 [pupString word: 5 ]\gb7B
pupID0_ pID [pupString word: 5 _ pID ]\gb12B
pupID1 [pupString word: 6 ]\gb7B
pupID1_ pID [pupString word: 6 _ pID ]\gb12B
pupID_ pID [pupString word: 5 _ pID high.
						 pupString word: 6 _ pID low]\gb11B
pupLength [pupString word: 3]\gb10B
pupLength_ pL [pupString word: 3 _ pL]\gb14B
pupType [pupString8]\gb8B
pupType_ pT [pupString8 _ pT]\gb12B
sourceHost [pupString20]\gb11B
sourceHost_ sH [pupString20 _ sH]\gb15B
sourceNet [pupString19]\gb10B
sourceNet_ sN [pupString19 _ sN]\gb14B
sourceSoc0 [pupString word: 11]\gb11B
sourceSoc0_ i [pupString word: 11_i]\gb14B
sourceSoc1 [pupString word: 12]\gb11B
sourceSoc1_ i [pupString word: 12_i]\gb14B
sourceSocNum [Int32 new high: (pupString word: 11) low: (pupString word: 12)]\gb13B
sourceSocNum_ sSN [pupString word: 11 _ sSN high.
						 pupString word: 12 _ sSN low]\gb18B
swapPorts | i [
	for i from: 13 to: 18 do [pupString swap: i with: i+6]]\gb10B
totLengthWords [((self pupLength)+5)/2]\gb15B
transportControl [pupString7]\gb17B
transportControl_ tC [pupString7 _ tC]\gb21B

PUP Checksum\gbf5 
checksum  [pupString word: ((self pupLength+1)/2)+2]\gb10B
checksumOK "Boolean, returns true or false"
	["just look at the current packet"
	self checksum = self doChecksum]\gb11B
checksum_  cs 
	 [pupString word: (((self pupLength+1)/2)+2) _ cs]\gb17B46b2B
doChecksum | i cs 
	[
	cs _ 0. 
	for i from: (3 to: (((self length + 1)/2)+2)) do "does not work"
		[cs_cs+(pupString word: i). 				   "for packets with carries"
		[cs <0[cs _ (cs lshift: 1)+1] cs _ cs lshift: 1]].
	[cs=1[cs _ 0]]. 
	cs
	] primitive: 94 \gb11B

Data \gbf5 
dataLength [(pupString word: 3) "self pupLength" - 22]\gb11B
dataLength_ len [pupString word: 3 "self pupLength" _ len + 22]\gb16B
dataString [pupString copy: 25 to: 24+self dataLength]\gb11B
dataString_ str | i [
	i _ str length.
	i > 532  [user notify: 'Data string too big for single PUP']
	pupString copy: 25 to: 24 + i with: str from: 1 to: i.
	self dataLength _ i.
	str]\gb16B5b2B
dataWord: i [pupString word: i + 12]\gb12B
dataWord: i _ v [pupString word: i + 12 _ v]\gb16B

Etc\gbf5 
 i [pupStringi]\gb4B
 i _ v [pupStringi _ v]\gb8B
header [pupString(1 to: 24) ]\gb7B
lock [locked[E notify: 'trying to lock a buffer already locked']
			locked_true. pupString lock]\gb5B
locked [locked]\gb7B
lockwith: string [locked[E notify: 'trying to lock a buffer already locked']
			locked_string. pupString lock]\gb17B
pupString  [pupString]\gb11B
pupString _ pupString [pupString]\gb22B
unlock [locked[locked_false.  pupString unlock]
			user notify: 'trying to unlock a buffer not locked']\gb7B
word: i [pupString word: i]\gb8B
word: i _ v [pupString word: i _ v]\gb12B
\g
SystemOrganization classify: Pacbuf under: 'Ethernet Control'.\g

"SafeQ"l15000z20000\gbf5 
Class new title: 'SafeQ'
	subclassof: PQueue
	fields: 'enabled'
	declare: '';
	asFollows\gbf5 

checks all objects enqueued, to be sure not there already\gi

As yet unclassified\gbf5 
disable [enabled _ false]\gb8B
enable [enabled _ true]\gb7B
length [position - readposition]
\gb7B
next _ arg | i "short comment" [[enabled
	[
	for i from: (readposition+1) to: position do
		[
		(arrayi)arg[E notify: 'putting same guy on Q twice']
		]]].
	arg locked[E notify: 'putting locked Pacbuf on Q']
	super next _ arg
	]\gb11B
status [enabled]\gb7B
\g
SystemOrganization classify: SafeQ under: 'Ethernet Control'.\g

"Socket"l15000z20000\gbf5 
Class new title: 'Socket'
	subclassof: Object
	fields: 'socNumber computeOutgoingCS filterInput outAddBlock
	lclSocNum frnNet frnHost frnSocNum'
	declare: '';
	sharing: EtherPool;
	asFollows\gbf5 

Sockets are used to do all communication through the net.  
It is expected that a specialized server or process can have
its own subclass of Socket with its own definitions of the
'Overwrite by Subclass' operations.  Note that subclasses will
have to access some global variables. 

Each socket is identified by a 32-bit lclSocNum, which really
defines who we are.
In addition, aspects of the lcl and frn addresses are used  to make
decisions about accepting
incoming packets, addressing outgoing packets, defaulting fields, etc.

The input distributor assures that an input was destined for our net
(not trying to
find a gateway) and our host (either explicitly or as broadcast, 
if not filtered), and found us by socket number.  Input need NOT be
filtered by the socket according to source, since the client may want
to see error messages from an intermediate address.

As a convenience, however, the socket can be asked to filterInput,
so it only accepts things which match the frnPort.
Thus, local and foreign attributes are primarily used to default
fields of an outgoing  packet.\gi

Initialization\gbf5 
default 
	["default local socket number and leave frn port open"
	self net: 0 host: 0 soc: (Int32 new high: 0 low: 0)
	]\gb10B
from: lclSocNum  
	["set lcl soc number, leave frnPort open -- useful for creating
	a well-known socket as a listener"
	self from: lclSocNum net: 0 host: 0 soc: (Int32 new high: 0 low: 0)
	]\gb19B
from: lclSocNum net: frnNet host: frnHost soc: frnSocNum 
	 [
	"this is the most general initialization, both lcl soc# and frnPort given"
	outAddBlock _ String new: 12.
	self setOutAddBlock.
	computeOutgoingCS _ filterInput _ false. 
	sockeTable insert: lclSocNum with: self.  "put me in socket table"
	self doMoreInit
	]\gb60B
hostName: name | a nh [
	"lookup name, then set net and host numbers (maybe socket?)"
	a _ NameUser init.
	nh _ a getAddressBlock: name.
	"since this socket may get many responses,
	make sure socket is not half deleted from sockeTable after first response"
	Top critical [a close].
	nh [self net: nh1 host: nh2]
	"invalid name?"
	false]\gb15B11i58I55i116I
net: frnNet host: frnHost soc: frnSocNum [
	"default the local socket number:
	use some memory dependent info (space) for the high word so that no two
		sockets (instances) can be the same, also non-zero.
	use time for low word, so that same instance will not usually have the
		same socket number (odds = 1/65536)"

	lclSocNum _ Int32 new high: self nail low: user ticks.
	self unNail; from: lclSocNum net: frnNet host: frnHost soc: frnSocNum
	]\gb41B1b2B
setOutAddBlock
	[
	outAddBlock1 _ frnNet. outAddBlock2 _ frnHost.
	outAddBlock word: 2 _ frnSocNum high.
	outAddBlock word: 3 _ frnSocNum low.
	outAddBlock7 _ NETNUM. outAddBlock8 _ ALTONUM.
	outAddBlock word: 5 _ lclSocNum high.
	outAddBlock word: 6 _ lclSocNum low.
	]\gb16B
to: h [
	"convenient default if on my net"
	self net: NETNUM host: h]\gb6B4i31I
wakeup | "when E goes from ethAsleep to ethAwak" 
	[  ]\gb7B

Process incoming packet\gbf5 
acceptPacbuf: Ipac | temp
	["if we get here, we know that the input distributer has verified the
	PUP dest as being us (or a broadcast, if broadcast filter is off).
	We do not have responsibility for verifying incoming checksum.
	First, check if we've been asked to filter by source:"
	filterInput and 
		(	(frnNet  Ipac sourceNet) or
			  ((frnHost  Ipac sourceHost) or (frnSocNum  Ipac sourceSocNum))
		)
		  [self socDispose: Ipac]
		"It's good, take it..."
		self socProcess: Ipac
	]\gb19B

Process outgoing packet\gbf5 
broadcast: packet to: socNumber| "I want to broadcast this packet" [
	self setAddresses: packet.
	packet
		destHost_0;
		destNet_0;
		destSoc0_socNumber high;
		destSoc1_socNumber low.
	"I assume that the length and type have been done"
	self completePup: packet.
	]\gb31B
completePup: pac | t
	[
	"the user must have set all 6 address fields,ID, length, and type"
	"Now route the packet appropriately, assuming we have Ethernet..."
		[
		NETNUM =  pac destNet   [pac imEthDestHost _pac destHost] 
			"most common case"
		0 = pac destNet  [pac imEthDestHost _ 0] "broadcast"
		0 = (t _ routingTable(pac destNet)) 
			[
			user show: '
Inaccessible destination net: ' + pac destNet asString+ ', packet not sent.'.
			pac.
			].
		pac imEthDestHost _ t.
		].
	pac imEthSrcHost _ ALTONUM.
	pac ethType _ 01000.
	pac transportControl_ 0. 

	"as a socket we have an option about computing outgoing checksums"
	pac checksum _ [computeOutgoingCS[pac doChecksum] 1].

	"Fix this up later......"
	E sendOutput: pac.
	pac
	]\gb17B2b3B
defaultAddresses: pac   "overwrites any fields which are 0"
	[
	[pac destNet = 0  [pac destNet _ frnNet]].
	[pac destHost = 0  [pac destHost _ frnHost]].
	[(pac destSoc0 = 0) and: (pac destSoc1=0)  
			[pac destSocNum _ frnSocNum]].
	[pac sourceNet = 0  [pac sourceNet _ NETNUM]].
	[pac sourceHost = 0  [pac sourceHost _ ALTONUM]].
	[(pac sourceSoc0 = 0) and: (pac sourceSoc1 = 0)  
			[pac sourceSocNum _ lclSocNum]].
	]\gb24B
defaultAndComplete: pac
	[
	self defaultAddresses: pac.
	self completePup: pac.
	]\gb25B
setAddresses: pac [pac addressBlock _ outAddBlock]\gb18B
setAddressesAndComplete: pac 
	[pac addressBlock _ outAddBlock.  self completePup: pac]\gb31B

Access to Parts\gbf5 
close [self release.
	sockeTable lookup: lclSocNum[sockeTable delete: lclSocNum]]\gb6B
computeOutgoingCS [computeOutgoingCS]\gb18B2b17B
computeOutgoingCS_ computeOutgoingCS [computeOutgoingCS]\gb37B2b17B
disable  	["left for compatibility" user show: 'unnecessary disable'.
	self close.]\gb10B
enable ["now a no-op" user show: 'someone did unnecessary enable'. self print]\gb7B
filterInput  [filterInput]\gb13B
filterInput_ filterInput [filterInput ]\gb25B
freePacket | p [
	"get a packet"
	freeQ [
		(p _ freeQ next) [p]
		user show: 'Warning, empty freeQ, in Socket'.
		false]
	Pacbuf new init]\gb11B8i12I
freePacket: p [
	"put a used packet into free queue"
	[freeQ and p [freeQ next _ p]].
	false]\gb14B4i33I
frnHost [frnHost]\gb8B
frnHost_ frnHost [frnHost]\gb17B
frnNet [frnNet]\gb7B
frnNet_ frnNet [frnNet]\gb15B
frnSocNum [frnSocNum]\gb10B
frnSocNum_ frnSocNum [frnSocNum]\gb21B
lclSocNum [lclSocNum]\gb10B
lclSocNum_ lclSocNum [lclSocNum]\gb21B

Overwrite by Subclasses\gbf5 
doMoreInit\gb
kill ["whole world about to go.  I don't care, but my subclasses might"]\gb5B
release "disable Timers, undo circular structures etc."\gb8B1i45I
sleep ["the user is quitting.  I don't care, but my subclasses might"]\gb6B
socDispose: Ipac [self freePacket: Ipac]\gb17B
socProcess: Ipac [self freePacket: Ipac]\gb17B
\g
SystemOrganization classify: Socket under: 'Ethernet Control'.\g

"RetransmitSocket"l15000z20000\gbf5 
Class new title: 'RetransmitSocket'
	subclassof: Socket
	fields: 'retransTimer retransMax retransCount'
	declare: '';
	asFollows\gbf5 

An abstract socket for handling retransmission behavior\gi

Socket\gbf5 
release [
	retransTimernil []
	"release circular structure"
	retransTimer disable. retransTimer _ nil]\gb8B26i26I
setAddressesAndComplete: pac [
	"this may need to be bracketed as critical?"
	pac addressBlock _ outAddBlock.
	"start timer"
	retransCount _ 0. retransTimer reset.
	self completePup: pac

	"self startTimer.
	super setAddressesAndComplete: pac"]\gb29B4i42I37i11I

Timer\gbf5 
retransmit: retransMax every: delay [
	retransTimer _ Timer new.
	retransTimer for: delay action [self timerFired]]\gb36B
startTimer [retransCount _ 0. retransTimer reset]\gb11B
timerOff [retransTimernil [] retransTimer disable]\gb9B
timerOn [
	"turn on timer if retry count has not been reached"
	(retransCount _ retransCount + 1)  retransMax  [retransTimer reset]
	false]\gb8B4i49I

Subclass\gbf5 
timerFired [
	"subclass should redefine this"
	self timerOn ["again, e.g. self completePup: pac"]
	"done"]\gb11B4i29I19i34I4i4I
\g
SystemOrganization classify: RetransmitSocket under: 'Ethernet Control'.\g

"NameUser"l15000z20000\gbf5 
Class new title: 'NameUser'
	subclassof: RetransmitSocket
	fields: 'resultType resultSet result outPac'
	declare: '';
	asFollows\gbf5 

Typical use: 
   foo _ NameUser init.
   foo getAddressBlock: string.  --- returns 6-byte string
	foo getAddressString.  --- returns string like 2#2#0
   foo close.\gi

Initialization\gbf5 
init 
	["create a NameUser, to socket 4, from a default local socket number"
	E wakeup.
	self net: 0 host: 0 soc: 4 asInt32.
	self retransmit: 2 every: 300]\gb7B

Output requests\gbf5 
getAddressBlock: str [
	"returns a string, 6 bytes: net/host/socket"
	result _ resultSet _ false.
	outPac _ self freePacket.
	outPac pupType_ 0220; dataString_ str.
	self setAddressesAndComplete: outPac.
	until resultSet do [].
	result]\gb21B4i42I
getAddressString: str | temp  "return string representation"
	[
	temp _ self getAddressBlock: str 
		[
		(temp1) base8 + '#' + (temp2) base8 + '#' +
		(temp word: 2) base8 + '|' +  (temp word: 3) base8.
		]
	false
	]\gb22B
getName: str | "convert string address back to host name"
	["not implemented yet"]\gb13B

Handle input\gbf5 
socProcess: Ipac | i j best bestHops "overwrite from Socket"
	[
	"called from Ether stuff, running at a very high level"
	["dummy block"
	resultSet  ["we are not waiting!!"]
	"must be the answer, or an error"
	self timerOff.
	resultSet _ true.
	0222 = Ipac pupType  "error"
		["user show: (Ipac dataString). "].
	0221  Ipac pupType  "error"
		["user show: 'unknown pup received by name user.'"].

	"an answer arrived"
	result _ Ipac dataString. "1 or more 6 byte blocks"
	result length = 6  ["all done"].
	"more than one, find the nearest address"
	best _ 1.  bestHops _ 16.
	for i from: 1 to: (result length) by: 6 do
		[
		NETNUM = (resulti)  [best _ i.  bestHops _ 0].
		j_ routingHopCount(resulti).
		j < bestHops  [best_i. bestHops_j].
		].
	result _ result copy: best to: (best+5).
	]"dummy block".
	"all done"
	self freePacket: Ipac.
	]\gb17B
timerFired  [
	self timerOn [self completePup: outPac]
	resultSet _ true]\gb12B
\g
SystemOrganization classify: NameUser under: 'Ethernet Control'.\g

"RoutingUpdater"l15000z20000\gbf5 
Class new title: 'RoutingUpdater'
	subclassof: RetransmitSocket
	fields: 'outPac resultSet'
	declare: '';
	asFollows\gbf5 

A specialized sub-class of Socket, designed to send out requests
for the current routing info, and update the routing table.\gi

Initialization\gbf5 
init [
	"create a new local soc number, broadcast to socket 2"
	super net: 0 host: 0 soc: 2 asInt32.
	outPac _ self freePacket.
	outPac pupType _ 0200.
	outPac dataString _ ''.
	self retransmit: 3 every: 300.
]\gb5B

Sending\gbf5 
update | i 
	[
	for i to: 255 do [routingTablei _ 0. routingHopCounti_8].
	resultSet _ false.
	self setAddressesAndComplete: outPac.
	until resultSet do []]\gb7B

Overwrite from Socket\gbf5 
socProcess: pac | block gateway net count i 
	[
	"an input has arrived, we are running at a higher level.
	Check the packet type"
	if pac pupType = 0201 then 
		[self timerOff.
		resultSet _ NETNUM _ pac sourceNet.

		block _ pac pupString.
		gateway _ pac sourceHost.
		for i from: 25 to: 24+pac dataLength by: 4 do 
			[
			net _ blocki. 
			count _ block(i+3) + 1.
			count < (routingHopCountnet)  
				[routingTablenet _ gateway. routingHopCountnet _ count]
			]
		].
	self freePacket: pac
	]\gb16B31b1B2i78I
timerFired [
	self timerOn [self completePup: outPac]
	resultSet _ true]\gb11B
\g
SystemOrganization classify: RoutingUpdater under: 'Ethernet Control'.\g

"RPPSocket"l15000z20000\gbf5 
Class new title: 'RPPSocket'
	subclassof: RetransmitSocket
	fields: 'seqNum outPac ackOK abortTransfer inQ ackType transaction myStream eof'
	declare: '';
	asFollows\gbf5 

I establish a reliable packet protocol for communication.
This is a sub-class of Socket, and uses many of its messages.\gi

Intialization\gbf5 
init [
	self retransmit: 10 every: 180.
	seqNum _ transaction _ 0.
	outPac _ ackOK  _ false.
	abortTransfer _ true. "stop an old timer from perhaps firing"]\gb5B

Termination\gbf5 
release [self reset. inQ _ false. super release]\gb8B
reset [
	outPac _ self freePacket: outPac.
	self timerOff]\gb6B

Sending Data\gbf5 
send: myStream 
	[
	"Sends a whole stream, and an end sequence.
	let the caller hand in a stream, or a file already opened"
	[outPac  [] outPac _ self freePacket].
	seqNum _ 0.
	abortTransfer _ eof _ false.
	until [eof or abortTransfer] do [self sendData].
	abortTransfer  [self reset. false]

	"We hit the end of file, do the end sequence and close the connection"
	self sendEndSequence  [myStream] false.  "all done!"
	]\gb17B48i57I
sendBlock: str 
	[
		"Take the data from a string (1-532 bytes), send it out; uses outPac"
		outPac dataString _ str.
		self sendPacket.  "tries to do it reliably"
		abortTransfer[false]
	]\gb17B
sendData | i t buf len [
	"send one packet of data from myStream"
	buf _ outPac pupString.
	i _ 24.
	"data bytes are 1-512, 25-536"
	[myStream is: FileStream [
		"read characters faster (should work especially well for the usual case:
		FileStreams starting on a page boundary, with page sizes of 512)"

		len _ 512 - (myStream readString: buf from: i+1 to: i+512)]

	"fill the buffer the slow, careful way"
	while (i < 536 and (t _ myStream next)) do [buf(i _i+1) _ t]
	len _ i-24].

	eof _ len < 512.

	len = 0 ["empty packet. don't send"]

	outPac pupType _ 030. "Data"
	"set the packet length"
	outPac dataLength _ len.

	"send packet reliably or abort, then return"
	self sendPacket. 
	]\gb9B
sendEndSequence
	[
		"This will do the 3-way handshake, and close the connection.
		send end, wait for ack"
		outPac pupType _ 032. "end"
		"set the packet length"
		outPac pupLength _ 22.
		self sendPacket. "gets sent reliably, we hope"
		abortTransfer[self reset. false].

		"send the last gratuitous end, do not try to retransmit"
		self sendPacketOnce.
		self reset.
		true.
	]\gb17B
sendPacket | 
	"general routine to send the outPac packet, maybe retransmit, get ack" 
	[
	ackOK _ abortTransfer _ false.
	outPac pupID1 _ seqNum. 
	outPac pupID0 _ transaction. "pupID0 can be used by one of my subclasses"
	self setAddressesAndComplete: outPac.
	until [abortTransfer or ackOK] do [].
	seqNum _ seqNum + 1.
	]\gb11B
sendPacketOnce | 
	"special routine to send the outPac packet, no retransmission" 
	[
	outPac pupID1 _ seqNum. 
	outPac pupID0 _ transaction. "pupID0 can be used by one of my subclasses"
	self setAddressesAndComplete: outPac; timerOff.
	]\gb15B

Receiving Data\gbf5 

Handle Input\gbf5 
process: packet ["my subclasses use this" self freePacket: packet]\gb16B2i22I
socProcess: Ipac "I have received a packet" [
	Ipac pupType = ackType [
		[Ipac pupID1 = seqNum and Ipac pupID0 = transaction[
			"a legal acknowledgement"
			self timerOff.
			ackOK _ true]
		"an old acknowledgement"].
		self freePacket: Ipac]
	"must be a trasmission started elsewhere"
	self process: Ipac.]\gb17B1i24I92i23I40i22I31i39I

Timer Interupts\gbf5 
timerFired [
	"This piece of code only runs when a Timer fires;  
	Don't do an active return"
	ackOK or abortTransfer ["This transaction has been terminated"]
	self timerOn [
		"retransmit"
		self completePup: outPac]
	user show: 'Excessive retransmits in RPP retransmit' .
	abortTransfer _ true]\gb11B
\g
SystemOrganization classify: RPPSocket under: 'Ethernet Control'.\g

"EFTPSender"l15000z20000\gbf5 
Class new title: 'EFTPSender'
	subclassof: RPPSocket
	fields: ' '
	declare: '';
	asFollows\gbf5 

A specialized sub-class of RPPSocket, designed to send files to an
EFTP receiver.  By convention, the receiver will be on socket 020
There can only be one outstanding packet at a time, called outPac.\gi

Initialization\gbf5 
net: n host: h
	[
	"Each instance of an EFTPSender has a unique lclSocket, but
		always goes to socket 020 of the receiver"
	super net: n host: h soc: (Int32 new high: 0 low: 020).
	"unlike plain sockets, we only want acks from this dest."
	filterInput _ true.
	self retransmit: 5 every: 180.
	outPac _ false.
	transaction _ 0.
	ackType _ 031.
	]\gb16B

Receiving\gbf5 
process: packet | error "The printer is trying to tell me something" [
	packet pupType = 033[
		"error 33!!!" error _ packet dataString.
		self freePacket: packet.
		user show: 'remote server aborted: '; show: error(3 to: error length).
		abortTransfer_true]]\gb16B
\g
SystemOrganization classify: EFTPSender under: 'Ethernet Control'.\g
