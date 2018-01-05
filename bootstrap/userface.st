
TERMINAL I/Oc(635)\1f4g1f5bG12f4Bg1f5bG

Class new title: 'UserView';
	fields: 'screenrect <Rectangle> current screen size
		vtab <Integer=0mod2> offset from hardware top
		htab <Integer=0mod16> offset from hardware left
		scale <Integer=1 or 2> 2 means double bits mode
		color <Integer=0 or 1> 1 means reverse field
		screenfile <File> for saving current bitmap
		disp <Dispframe> default message stream
		sched <PriorityScheduler> tasks for this view'

screen overlays
UserView understands: 'install
	[user close.  self reconfigure.  user _ self open]'
UserView understands: 'reconfigure [] primitive: 62'	tell OOZE and others
UserView understands: 'close
	[screenfile open.		write out the old bitmap
	screenfile write: screenrect height*(screenrect width+15/16)/256
		from:   mem066.
	screenfile close]'
UserView understands: 'open
	[screenfile open.		read in the new bitmap
	screenfile read: screenrect height*(screenrect width+15/16)/256
		to:   mem066.
	screenfile close]'

terminal interaction
UserView understands: 'kbd [!kbMapself rawkbd]'
UserView understands: 'kbck
	[self rawkbck?[!kbMapself rawkbck] !false ]'
UserView understands: 'rawkbd [] primitive: 63'
UserView understands: 'rawkbck [] primitive: 64'
UserView understands: 'buttons
	[!7-(mem0177030 land: 7)]'
UserView understands: 'redbug [!self buttons=4]'
UserView understands: 'yellowbug [!self buttons=1]'
UserView understands: 'bluebug [!self buttons=2]'
UserView understands: 'anybug [!self buttons>0]'
UserView understands: 'keyset
	[!037-((mem0177030 lshift: 3) land: 37)]'
UserView understands: 'mp
	[!Point new x: mem0424-htab y: mem0425-vtab]'
UserView understands: 'cursorloc _ pt
	[mem0426 _ pt x+htab. mem0427 _ pt y+vtab]'

display control
UserView understands: 'loadcursorbitsfrom: bitstr | i
	[for i to: 16 do
		[mem(0430+i) _ bitstr word: i]]'
UserView understands: 'displayoffwhile expr | t v
	[t _ mem067. mem067 _ 60.
	v _ expr eval. mem067 _ t. !v]'
UserView understands: 'restoredisplay
	[mem067 _ screenrect height/2]'
UserView understands: 'screenextent: extent tab: tab
	[mem065 _ (0400*(tab x/16))+(extent x/16|2).
	mem067 _ extent y/2. mem063 _ tab y/2.
	htab _ tab x|16. vtab _ tab y|2.
	screenrect _ 0@0 rect: (extent x|32)@(extent y|2).
	self reconfigure]'

system messages
UserView understands: 'ev [disp ev]'
UserView understands: 'request: s [!disp request: s]'
UserView understands: 'show: str
	[disp append: str; show]'
UserView understands: 'cr [disp cr]'
UserView understands: 'clearshow: str
	[disp clear; append: str; show]'
UserView understands: 'notify: str
	[self restoredisplay. disp append: str; cr; show.
	disp append: thisContext sender trace; show.
	thisContext sender debug. self restart]'
UserView understands: 'restart
	[self restart [disp ev]]'
UserView understands: 'restart code
	[code sender _ nil.
	thisContext sender _ nil.		release caller chain
	CodeKeeper _ (Vector new: 10) asStream.		release held code
	disp cr; append: '' ** restart''; show.
	while true do [code eval]]'
UserView understands: 'screenrect [!screenrect]'

window scheduling
UserView understands: 'schedule: window
	[schednil?
		[(sched _ Vector new: 1)1 _ window]
	sched _ sched , window]'
UserView understands: 'unschedule: window
	[0<(t_ sched find: window)?
		[sched _ sched(1 to: t-1) concat: sched(t+1 to: sched length)]]'
UserView understands: 'sched [!sched]'
UserView understands: 'run | s
	[while (screenrect has: user mp) do
		[for s from: sched do [s startup]]]'
UserView understands: 'printon: strm
	[strm append: ''a UserView'']'

OOZE save/load
UserView understands: 'OutLd [] primitive: 85'
	returns true from call; false from OS resume
UserView understands: 'InLd: fileid
	[user notify: ''file problem''] primitive: 86'
UserView understands: 'overlay: fileid
	[self OutLd?[self InLd: fileid]]'
UserView understands: 'quit | t
	[t _ Vector new: 5; all _ 0.  self overlay: t]'
UserView understands: 'Swat [] primitive: 90'
\f5b51f4Bg1f0iG31f4Ig1f5bG8f4Bg1f0iG40f4Ig1f5bG8f4Bg1f0iG42f4Ig1f5bG9f4Bg1f0iG41f4Ig1f5bG9f4Bg1f0iG38f4Ig1f0iG1f5bI13f4Bg1f0iG32f4Ig1f0iG1f5bI7f4Bg1f0iG34f4Ig1f5bG9f4Bg1f0iG39f4Ig1f5bG3f4Bg2f0iG15f4Ig25u7U78u11U21f0iG20f4Ig25u5U22f0iG24f4Ig131u4U22f0iG22f4Ig107f0iG20f4Ig25u3U47u4U72u6U43u7U43u7U54u6U44u9U44u7U44u6U44u6U70u2U74u9U56f0iG15f4Ig25u19U92u16U99u14U59u13U8u4U203f0iG15f4Ig25u2U91u5U56u2U7u2U27u10U63u7U168u7U53u8U56f0iG20f4Ig45f0iG17f4Ig98u10U19f0iG17f4Ig25u9U110u11U130u5U35u3U109u8U41f0iG14f4Ig25u5U91u5U80u8U67u4U78u4U

PARAGRAPH EDITORc(500)\f4g3f5b16f4B1f5b
Smalltalk define "Peditorstuff as "Peditorstuff _ SymbolTable new.
Peditorstuff insertall: "(bs del esc doit paste typing editmenu
		Scrap Deletion ctlchars runvals p1 p2 selon oldpara oldheight)
	with: "(010 0177 033 036 02 typing editmenu
		Scrap Deletion ctlchars runvals p1 p2 selon oldpara oldheight).e12\f4g
Class new title: 'ParagraphEditor';
	subclassof: Textframe;
	fields: 'loc1 loc2';
	sharing: 'Peditorstuff'
ParagraphEditor understands: 'enter: window
	[frame _ window inset: 4 @ 2 and: 2 @ 2.
	oldpara _ oldheight _ false. self show]'
ParagraphEditor understands: 'leave
	[self comp: p1 to: p2]'

ParagraphEditor understands: 'kbd: boss | more char
	[more _ Stream default.
	while user kbck do
		[(char _ user kbd)=del? []
		char=bs? [more empty?[loc1 _ 1 max: loc1-1].		backspace
				more skip: 1]
		more next_ char].
	self replace: more contents]'

ParagraphEditor understands: 'redbug: boss | a t drag2
	[t _ self charnearpt: user mp.
	t=loc1 and: loc1=loc2 ? [self selectword]		 double-bug 
		[loc1=t?[drag2 _ false]
		drag2 _ true. loc2=t?[]		 pick up old selection 
		self comp: p1 to: p2. loc1 _ loc2 _ t.		 start new selection 
		p2 _ 1@0 + (p1 _ reply1).
		self comp: p1 to: p2].
	while user redbug do					 draw out selection 
		[a _ reply1.
			[loc1=loc2?[drag2 _ tloc2]].
			[drag2? [ [t<loc1?[t_loc1. a_self ptofchar: t]].
					self comp: a to: p2. loc2 _ t. p2 _ a]
				[t>loc2?[t_loc2. a_self ptofchar: t]].
				self comp: p1 to: a. loc1 _ t. p1 _ a].
			[p1=p2?[self comp: p1 to: (p2 _ 1@0 + p1)]].
		t _ self charnearpt: user mp]]'

ParagraphEditor understands: 'replace: t
	[	[oldpara?[] oldpara _ para].
	para _ para replace: loc1 to: loc2-1 by: t.
	loc1 _ loc2 _ loc1 + t length.
	self show]'
ParagraphEditor understands: 'selection
	[!para copy: loc1 to: loc2-1]'

ParagraphEditor understands: 'show
	[super show.
	[loc1nil? [loc1_loc2_1]].
	user kbck?[] self select]'
ParagraphEditor understands: 'select
	[p1 _ self ptofchar: loc1.
	p2 _ [loc2=loc1?[1@0 + p1] self ptofchar: loc2].
	self comp: p1 to: p2]'

ParagraphEditor understands: 'comp: a to: b | t		complement from a to b
	[	[a y<b y?[] (a y=b y) and: (a x<b x)?[] t_a. a_b. b_t].		in case they were reversed
		[a y < b y?
			[(a rect: (window corner x-4) @ (a y+self lineheight)) comp.	top line
			 a _ (window origin x+4) @ (a y+self lineheight).
			 a y < b y?
				[(a rect: (window corner x-4) @ b y) comp]	middle (if any)
			]].
		a y > b y?[]
		(a x @ b y rect: b x @ (b y + self lineheight)) comp.	bottom (or only)]'

ParagraphEditor understands: 'selectword | a b dir t level open close
	[self comp: p1 to: p2.
	a_ b_ dir_ 1.
	open _ ''([{< ''''
''.	close _ '')]}> ''''
''.		[loc1>para length?[]
			loc11?[dir_1]
			t_open find: (a_para(loc1-1)). t>0?		delim on left
				[dir_1. b_closet.		match to the right
				a=b?[a_2]]		non-nesting
			t_close find: (a_paraloc1). t>0?		delim on right
				[dir_1. b_opent.		match to the left
				a=b?[a_2]]		non-nesting
			a_ 1].		no delims - select a token
		t_loc1-1. level_1.
		until [t1?[] tpara length?[] level=0?[] false] do
			[para(t_ t+dir) = b? [level_ level-1];		leaving nest
			= a? [level_ level+1].		entering nest
			a=1?[(parat) tokenish?[]		token check goes left 
					dir=1?[loc1 _ t+1. dir_1. t_loc2]	then right
					level_ 0]]
	[dir=1?[loc2_ t] loc1_ t+1].
	self select]'
Integer understands: 'tokenish		test for token-chars
	[self isletter?[!true]	lower-case
	 self isdigit?[!true]	digits
	 !''.:'' has: self]'	also high-minus and dot
\f5bg108f4B30u6U123u5U58u4U256u7U703u8U156u9U65u4U102u6U135u5U3u3U48f0G17f4g410u10U236f0 2f4 129f0 2f4 288f0 2f4

CLASS EDITORc\f4g3f5b12f4B1f5b
Class new title: 'ClassEditor';
	subclassof: ParagraphEditor;
	fields: 'class selector'
ClassEditor understands: 'firsttime
	[window has: user mp?
		[window outline. self enter: window]
	!false]'
ClassEditor understands: 'eachtime
	[window has: user mp?
		[user kbck?[self kbd: nil]
		user anybug?
			[user redbug?[!self redbug: nil]
			user yellowbug?[self yellowbug: nil]
			user bluebug?[window _ Rectangle new fromuser.
					self firsttime]]]
	user yellowbug?[self close. !false]
	user anybug?[self leave. !false]]'
ClassEditor understands: 'lasttime
	[self leave]'

ClassEditor understands: 'class: class selector: selector
		para: para window: window
	[para _ para asParagraph. style _ DefaultTextStyle.
	self enter: window]'
ClassEditor understands: 'yellowbug: boss
	[class understands: para]'
ClassEditor understands: 'close
	[(window inset: 2 @ 2) clear: backround.
	user unschedule: self]'

Class understands: 'edit: selector
	[user schedule: (ClassEditor new class: self selector: selector
			para: (self code: selector) window: Rectangle new fromuser)]'

Dispframe understands: 'firsttime
	[text window has: user mp?
		[text window outline. self cr; append: ''''; show]
	!false]'
Dispframe understands: 'eachtime
	[text window has: user mp?
		[user kbck?[t_ self read.
			self print: [tnil?[self doit] nilt].
			self cr; append: ''''; show]]
	user anybug?[!false]]'
Dispframe understands: 'lasttime
	[self skip: [2 max: 0-position]; show]'
e12\f5bg89f4B26u9U100u8U317u8U44u6U7u9U12u5U6u7U110u10U61u5U92u5U

******  NOT DONE BEYOND HERE ******

OTHER PARAGRAPH STUFF
ParagraphEditor understands: 'kbdlook | t c
	[(c_ user rawkbck)>170?
		[t_ ctlchars find: c.
		t>0?[kbd. changed _ true.
				para changestyle: runvalst from: loc1+1 to: loc2]
		!false]
	!false]'
Peditorstuff insertall: "(ctlchars runvals) with: "(
		(226 233 224 173 242		ctl-  b i ... - r
			176 177 178 179 180 181 182 183 184 185	ctl-  0 thru 9
			193 194 195 196 197 198)					ctl-  A thru F
		(1 2 4 8 1
			0 1 2 3 4 5 6 7 8 9
			10 11 12 13 14 15)
		).
"t _ Peditorstuff"runvals.
	for i _ 6 to t length do
		(t[a] _ 16*t[a]).		font number left 4 bits

ParagraphEditor understands: 'readchange
	[self cleanup. changed_false. !para]'
ParagraphEditor understands: 'fixframe: x
	[!x]'
ParagraphEditor understands: 'close: x []'
ParagraphEditor understands: 'outside: x [!false]'
ParagraphEditor understands: 'asParagraph	[!para]'
ParagraphEditor understands: 'changed	[!changed]'
ParagraphEditor understands: 'selection	[!para copy: loc1 to: loc2-1]'

e12\f4g

WINDOW FRAME AND CONTROL
c\f4g3f5b24f4B
Class new title: 'UserWindow';
	fields: 'frame contents title';
	sharing: Userstuff
UserWindow understands: 'frame: f contents: contents
	[frame _ contents fixframe f. self show]'
UserWindow understands: 'of: c
	[self frame: Rectangle new fromuser contents: c]'
UserWindow understands: 'show
	[self showin: user screenrect]'
UserWindow understands: 'showin: r | a
		[(a _ frame intersect: r) empty? []
		a color: dkgray mode: storing.
		((frame inset: p1 and: p2) intersect: r) color: white mode: storing.
		contents enter: r.
		whitey show: contents title clipped: r]

UserWindow understands: 'firsttime
	[frame has: user mp? [self show] !false]'
UserWindow understands: 'eachtime
	[frame has: user mp?
		[user buttonck?
			[user redbug?[!contents redbug: self]
			user yellowbug?[!contents yellowbug: self]
			user bluebug?[!contents bluebug: self]]
		user kbck?[contents kbd: self]
		user keysetck?[contents keyset: self]]
	contents outside: self?[]
	user buttonck?[frame has mp?[] !false]
	user kbck?[user kbd; user flash] flush typing outside]'
UserWindow understands: 'lasttime
	[!contents leave]'

UserWindow understands: 'newframe
	[while user buttonck do [].
	frame _ Rectangle new origin: (a_ user mp) corner: a.
	while user buttonck do 
		[frame color: dkgray mode: xoring.
		frame _ contents fixframe: (frame growto: user mp). 
		frame color: dkgray mode: xoring].
	frame color: dkgray mode: storing.
	whitey show: contents title.
	windowSched fillholes: (oldframe nonintersect: frame).
	!frame]'
UserWindow understands: 'close
	[contents close: self]'
UserWindow understands: 'movegrow
	[frame color: white mode: storing.
	frame _ self newframe.
	"a _ frame inset p1 p2.
	a paint 12 white.
	contents enter a inset p3 p4]'
***
UserWindow evals ["p1 _ point 3 fontheight+4. "p2 _ point 3 3.
		"p3 _ point 4 2. "p4 _ point 4 0. "p5 _ point 3 2.
		"whitey _ textframe rectangle p1 p1]'
\f5bg85f4B

FORMATTED TEXT
c\f4g3f5b14f4B1f5b
Paragraph understands: 'runfind b | a			**index into run**
	[a_1.
	while true do
		[runsab? [!a , b]		return run, index
		b _ b-(runsa). a _ a+2]]'
Paragraph understands: 'runs		**subrange of run**
	[%[?["a _ :.		indexed by text, not run
			%to?
				["b _ [%end?["c_runs length-1. point c runs[c]]
						self runfind :]. %].
				a>text length?[!''] "a _ self runfind a.
				"c _ runs[a x to b x+1].		copy the sub-run
				c length=0?[!c]
				a x = b x?[0= c[1]_ 1+ b y-a y ?[!''] !c]
				c[1] _ 1+runs[a x] - a y.			trim the end lengths
				c[c length-1] _ b y.  !c]
			%]. !runs[self runfind a x+1]]
		!runs]'
string understands "runcat		**concatenate runs**
	["x_:. x length=0?[] self length=0?[!x]
		self[self length]=x[2]?
			[!self[1 to self length-2]+
				[makerun self[self length-1]+x[1] x[2]]+
				x[3 to x length]]
		!self + x]'
Paragraph understands: 'asString [!text]'
Paragraph understands: '[		**subranges and subscripting of text**
	["a_:.
		%to?["b_:. %].
			%replace?["c_:.	**alters self; doesn't copy
				"runs _ self runs[1 to a-1]
					runcat [c is string?[makerun c length self runs[b]] c runs]
					runcat self runs[b+1 to end].
				"text _ text[a to b] replace
					[c is string?[c] c text]]
			%changestyle?["c_:.
				"runs _ self runs[1 to a-1]
					runcat [self mergestyle c into self runs[a to b]]
					runcat self runs[b+1 to end]]
			%_?[%all?[text[a to b] _ all :]
					text[a to b] _ :]
			!paragraph with text[a to b] self runs[a to b]]**copy align**
		%]. %_?[!text[a]_:]
		!text[a]]'
Paragraph understands: 'mergestyle
	["a_:. %into. "b_:.
		for c_ 2 to b length by 2 do
			[b[c] _ [a=1? [0]			reset
				0<a017? [a &- b[c]]		toggle emphasis
				a+017 &* b[c]]].	new font
		!b]

"makerun _ function [run len str] ["len_:. "run_:.
		len=0?[!''] "str_stream. repeat do
			[run<256?[str_len. str_run. !str contents]
			str_255. str_run. "len_len-255]]'
paragraphinitcode _
	["alignment _ 0. %with?["text _ :.
			"runs _ [%onerun?[makerun text length :] :]]
		"text _ string 0]'
Paragraph understands: 'runshow | strm i		**print a run**
	[strm _ stream. for i from: (1 to: runs length by: 2) do
		[strm append: (runsi) asString; append: '.'.
		strm append: (runs(i+1)) asString; append: ', ']
	!strm contents]'
\f4g

MENUS
c\f4g3f5b5f4B1f5b
"menu _ class [[pt i bits][str text thisline frame but][pt2][]] [] [] []'

menuinitcode _
	["str_:. "but_:.
	"text _ textframe rectangle "pt_point 0 0 point 1000 1000 with str.
	for i to str length+1 do
		["pt _ pt max text ptofchar i]
	textframe growto pt+point 4 text fontheight.
	textpara center.
	"frame _ textframe inset "pt2_point 2 2 pt2.
	"thisline_rectangle text frameorigin
				point textframeextent x text fontheight]'
menu understands: 'bug
	["pt_mp-thisline center.		center prev item on mouse
		textframe moveby pt. thisline moveby pt.
		frame moveby pt. "bits _ frame makebuff.		save background
		frame paint 12 1. text show.
		0=mouse 7?[frame loadbuff bits. !0]			accidental bug returns 0
		thisline comp.
		repeat do [
			frame has "pt_mp?		in the menu
				[button but?			button still down
					[thisline has pt?[]
					text charnearpt pt. "pt_text reply.
					thisline comp. thisline moveto	selection follows mouse
						 point textframeorigin x pt y.
					thisline comp]
				frame loadbuff bits.	restore background, return index
				!1+[thislineorigin-frameorigin]y/text fontheight]
				thisline comp. 		he left the menu
			repeat do [button but?[frame has mp?[thisline comp. done]]
						frame loadbuff bits. !0]	return 0 for abort
		]]'
menu understands: 'rebug
	[showcursor [but=1?[bug2cursor] bug3cursor]
			repeat do [button but?[done]]		wait for button down again
		!self bug]'\f4g

BRAVO CONVERSION
c\f4g3f5b16f4B1f5b
"bravo2para _ function [a b c f ff i p q s st]
		["f_:. f end?[!false]
		"a _ f upto 26. f next.		pick up ascii
		"p _ paragraph.
		"b _ f upto 13. f next.			pick up trailer
		"s _ stream of b. "st _ stream.
		repeat do
			["c _ s next.				scan for useful para info
			c='c'[1]?[p center]
			c='j'[1]?[p justify]
			c='\'[1]?[done]
			st _ c]				stache rest for later bravo output
		ptrailer _ st contents. st reset.
		"ff_ "len _ "run _ 0. "q_1.
		repeat do
			[s end?[done]
			"c _ s next.
			0< "i_ 'bBiIuUnNfoy'[1 to 11] find c ?
			["[["run _ run+1]		["run _ run-1]		bold
				["run _ run+2]		["run _ run-2]		italic
				["run _ run+4]		["run _ run-4]		underline
				["run _ run+8]		["run _ run-8]		strikeout
				["run _ [run &* 017] + 16*"ff_ scannum s]	font
				["r_scannum s. "run _ [run &* 017] + 		super/sub script
					16*[r=0?[ff] r>128?[11] 10]]					later vary by font
				[scannum s]]		tab color
				[i] eval]
			060c071?[s skip 1. "r _ scannum s.	get run length
				"len _ len+r.		later merge across ignored changes
				st _ makerun r run]]
		[0< "r_ a length-len?
			[st _ makerun r run]]
		pchars _ a. pruns _ st contents.  !p]'
"scannum _ function [f c i] ["f_:. "i_0.
	repeat do
		["c_f next.
		060c071?["i_ [10*i] + c-060]
		f skip 1. done]
	!i]'

\f4g 