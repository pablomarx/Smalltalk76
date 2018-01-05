'From Smalltalk 5.5k XM November 24 on 5 February 2037 at 11:33:12 pm.'
\g
"BitImage"l15000z20000\gbf5 
Class new title: 'BitImage'
	subclassof: Image
	fields: 'strips nstrips'
	declare: 'brush aurora stripheightSPARE stripheight black white bitimagemenu erase SPARE color formmenu under reverse blankcursor over dotsetter ';
	asFollows\gbf5 

This class is a virtual bit map represented as a smalltalk String\gi

INIT\gbf5 
classInit 
	["sets up colors and effects for BITBLT."
	black _ 0-1.
	white _ 0.
	over _ 0.
	under _ 1.
	reverse _ 2.
	erase _ 3.
	brush _ Form new extent: 55. brush black.
	color _ 1.
	stripheight _ 20.
bitimagemenu _ Menu new string:
'size
figure
ground
newform
pasteform
arc
areafill
shade
vertical
horizontal
rotate
'.
	aurora _ "Aurora new" nil.
	]\gb12B
fromImage: image 
	["creates a virtual bit map with width = (image width) and height = (image height) with the bits in image."
	self fromrectangle: image rectangle.
	]
	\gb19B
fromrectangle: rect | r i leftover image yposition
	["creates a virtual bit map with width = (r width) , height = (r height)
	 and the bits in rect. The Image is  made up of forms that are stripheight high."
	super origin: rect origin extent: rect extent.
	nstrips _ (rect height + (stripheight -1))/stripheight.
	yposition _ 0.
	leftover _ rect height \ stripheight.
	[ (leftover = 0)  [leftover _ stripheight]].
	r _ Rectangle new origin: rect origin extent: (rect width)stripheight.
	for i to: nstrips do 
		[
		[ i = nstrips  [ r extent _ ((rect width)leftover)]].
		image _ Image new origin: (00) extent: rect extent.
		image form: (Form new fromrectangle: r) ; path: (0yposition).
		self addimage: image.
		yposition _ yposition + stripheight.
		r translate: (0stripheight).
		].
	

	]
	\gb20B2b30B
	fromuser  | r
	["create a new Form whose rectangle is specified by the user. "
	r _ Rectangle new fromuser.
	self fromrectangle: r
	]\gb16B
fromuserevenword  | r
	["create a new BitImage whose rectangle is specified by the user,
		truncated to nearest multiple of 16 (for Spruce printing). "
	r _ Rectangle new fromuserevenword.
	self fromrectangle: r.
	]\gb23B

PATTERN ACCESS\gbf5 
erase | i
	["sets all bits in the BitImage to white ( to zeros)"
	for i to: nstrips do [ (stripsi) white]
	]\gb6B
nstrips
	[
	 nstrips 
	]
\gb9B
nstrips: nstrips 
\gb
saveScreenBits
[
]\gb15B
strips 
	["return the set of Forms making up this BitImage)"
	 strips
	]\gb9B
strips: strips 
\gb

MODULE ACCESS\gbf5 
comment 
	["see class Image"
	]\gb10B
frame [  rectangle]\gb6B
moveto: pt  
	[self translateto: pt
	]\gb14B

FILING\gbf5 
read: filename | file subimage strip yposition i
	["Reads the Image in the format nstrips , Form(1) , Form(2) , Form(3) . . .
		Form(nstips). Where each Form is saved as width,height then bits.  "
		self origin: 00 extent: 11.
		yposition _ 0.
		file_ (dp0 oldFile: filename) readonly.
		nstrips _ file nextword.
		for i to: nstrips do
				[
				strip _ Form new fromInstance: file.  
				self addform: strip andpath: (0yposition).
				yposition_ yposition+ strip height.
				].
		file close.
	]\gb15B
write: filename | file subimage
	["Saves the Form in the format nstrips , Form(1) , Form(2) , Form(3) . . .
		Form(nstips). Where each Form is saved as width,height then bits.  "
		file _ (dp0 file: filename).
		file nextword_ nstrips.
		for subimage from: self do [ file append: (subimage form) asInstance. ]
		file close.
	]\gb16B

DISPLAY\gbf5 
displayat:  path effect: effect clippedBy: cliprect
	[
	super displayat: path effect: effect clippedBy: cliprect
	]\gb53B
show
	[
	super displayat: (00) effect: 0 clippedBy: user screenrect
	]\gb6B

SYSTEM\gbf5 
copy | t i
	["return a copy of myself"
	t _ BitImage new origin: (origin copy) extent: (self extent) copy.
	for i to: self length do [ t add: (selfi) copy].
	 t
	]\gb5B
pressCode [3]\gb10B
printon: strm | t
	[
	strm append: 'a Bitmage: '.
	]
\gb14B
title 
	[
	 ''
	]\gb8B

EDITING\gbf5 
arc | pt1 pt2 pt3 p pt
	["arc tool for forms."
	BlankCursor topage1.
	user clear; print: 'Redbug 3 points'; cr; print: 'Paints using current brush.' .
	user waitnobug.
	until user redbug do	[ pt1 _ self blinkbrush].
	brush displayat: pt1 effect: color clippedBy: user screenrect.
	user waitnobug.
	until user redbug do		[ pt2 _ self blinkbrush].
	brush displayat: pt2 effect: color clippedBy: user screenrect.
	user waitnobug.
	until user redbug do	[ pt3 _ self blinkbrush].
	brush displayat: pt3 effect: color clippedBy: user screenrect.
	XeqCursor show.
	p _ Path new init.
	p addarcfrom: pt1 via: pt2 to: pt3.
	for pt from: p do
					[ brush displayat: pt effect: color clippedBy: user screenrect].
	NormalCursor show
	]
\gb4B
blinkbrush | pt 
	["to show current position of brush in the BitImage."
		pt _ self mp + rectangle origin.
		brush displayat: pt
			effect: 2 clippedBy: user screenrect.
		brush displayat: pt
			effect: 2 clippedBy: user screenrect.
	 pt
	]
\gb11B
edit: superimage | bits 
	["uses the BitRect toolbox editor"
	XeqCursor show.
	dotsetter _ BitRectEditor new picture: self.
	dotsetter firsttime.
	NormalCursor show.
	while true do "forever"
		[
		(dotsetter lostMouse and: (user anybug)) 
					[	dotsetter outside []
						XeqCursor show.
						dotsetter lasttime.
						bits _ self fromrectangle: rectangle.
						NormalCursor show.
						 bits
					]
		dotsetter eachtime
		]
	]
\gb26B
grayEdit | a b c i d p r v bits "edit up a gray pattern and return it"
	["first a rectangle for it.  Then redbug is black, yellow is white,
	blue terminates"
	r _ Rectangle new fromuser. bits_0.
	a _ r extent. a_ (a x max:  a y) | 4. a _ aa.
	b _ r origin. r extent_ a; color: white mode: storing; moveby: 0(0-a y).
	c _ a/4.  d _ b rect: b+c.
	until user bluebug do [
	user redbug [p _ user mp -b /c.  i _ p y *4 +p x +1.
		i<1 or i>16 [r flash]
		d moveto: b+(c*p); color: black mode: storing.
		bits _ bits lor: (1 lshift: 16-i).
		r color: bits mode: storing. user waitnobug]
	user yellowbug [p _ user mp -b /c.  i _ p y *4 +p x +1.
		i<1 or i>16 [r flash]
		d moveto: b+(c*p); color: white mode: storing.
		bits _ (1 lxor:(1 lshift: 16-i)) land: bits.
		r color: bits mode: storing. user waitnobug]
	] bits]
"aa grayEdit base8 ."\gb9B
horizontalsymmetry | r f i 
	["horizontal symmetry tool"
	user clear; show: 'Define rectangle. Reflection will be around lower edge'.
	r _ Rectangle new fromuser.
	XeqCursor show.
	for i to: ( r height) do
		[
		f _ Form new fromrectangle: (Rectangle new origin: ((r origin x)((r bottom)-i)) extent: ((r width)1)).
		f displayat: (r origin x)((r bottom) +i) effect: 0 clippedBy: user screenrect.
		].
	NormalCursor show.
	]\gb19B
line | pt1 pt2 p pt
	["line tool for forms."
	BlankCursor topage1.
	until user redbug do	[ pt1 _ self blinkbrush].
	brush displayat: pt1 effect: color clippedBy: user screenrect.
	until user nobug do		[ pt2 _ self blinkbrush].
	brush displayat: pt2 effect: color clippedBy: user screenrect.
	p _ Path new init.
	p addlinefrom: pt1 to: pt2.
	for pt from: p do
					[ brush displayat: pt effect: color clippedBy: user screenrect].
	NormalCursor topage1
	]
\gb5B
newbrush |  pt rect
	[
	OriginCursor topage1.
	user waitbug.
	pt _ ( self mp)+ rectangle origin.
	rect _ pt rect: pt.	
	CornerCursor topage1.
	until user nobug do
			[rect reverse.
			rect reverse.
			pt _ 
			( self mp)+ rectangle origin.
			rect corner _ (rect origin) max: pt.
			]
 	brush _ Form new fromrectangle: rect.
	NormalCursor topage1.
	]
\gb9B
pastebrush | pt1 
	["one-copy tool for forms."
	user waitnobug.
	OriginCursor show.
	user waitbug.
	while user redbug do
		[ pt1 _ self blinkbrush].
	XeqCursor show.
	brush displayat: pt1 effect: (dotsetter tool mode) clippedBy: user screenrect.
	NormalCursor show]\gb11B
resize: superimage |  pt f
	[dotsetter leave.
	CornerCursor topage1.
	user waitbug. 
	until user nobug do
			[self reverse.
			self reverse.
			( pt _ 
			(superimage  mp)+
				 superimage rectangle origin).
			self corner_ pt max: ((self origin) + (1616)).
			]
 	self fromrectangle: rectangle.
 	self white ; display.
	NormalCursor topage1.
	self edit: superimage
	]
\gb19B
rotate | r f i j
	["90 degree rotation tool"
	r _ Rectangle new fromuser.
	for i to: ( r width) do
		[
		for j to: ( r height) do
			[
			f _ Form new fromrectangle: (Rectangle new origin: (((r origin x)+i)(r top+j)) extent: (11)).
			f displayat: (((r corner x)+j))((r top)+i) effect: 0 clippedBy: user screenrect.
			]
		]
	]\gb7B
setfigure | t
	["for now just increment the figure color by 1 \ 12"
	figure _ (figure +1 ) \ 12.
	for t from: self do [ (t form) figure: figure].
	self display
]
\gb10B6i52I
setground | t
	["for now just increment the ground color by 1 \ 12"
	ground _ (ground +1 ) \ 12.
	for t from: self do [ (t form) ground: ground].
	self display
]
\gb10B6i52I
verticalsymmetry | r f i 
	["vertical symmetry tool"
	user clear; show: 'Define rectangle. Reflection will be around right-hand edge'.
	r _ Rectangle new fromuser.
	XeqCursor show.
	for i to: ( r width) do
		[
		f _ Form new fromrectangle: (Rectangle new origin: (((r origin x)+(r width)-i)(r top)) extent: (1(r height))).
		f displayat: ((r corner x) + i)(r top) effect: 0 clippedBy: user screenrect.
		].
	NormalCursor show.
	]\gb17B
yellowbug | 
	[
	bitimagemenu bug
				=1	[self resize: superimage
						]; "change size"
				=2	[self setfigure];		
				=3	[self setground];		
				=4	[self newbrush];		
				=5	[self pastebrush];		
				=6	[self arc ];
				=7	[Rectangle new fromuser fillin: ((dotsetter tool) tone)
							mode: ((dotsetter tool) mode) ];
				=8  [(dotsetter tool) shade];
				=9  [self verticalsymmetry];
				=10  [self horizontalsymmetry];
				=11  [self rotate]
	]\gb10B
\g
SystemOrganization classify: BitImage under: 'FPI Packages'.\g
BitImage classInit\g

"BorderedText"l15000z20000\gbf5 
Class new title: 'BorderedText'
	subclassof: TextImage
	fields: ''
	declare: '';
	asFollows\gbf5 

This class has not yet been commented\gi

DISPLAY\gbf5 
displayat: pt effect: effect clippedBy: cliprect | origin corner
	["display text and border around it "
	super displayat: pt effect: effect clippedBy: cliprect.
	origin _ frame origin.
	corner _ frame corner.
	(Rectangle new
		origin: origin-(11) corner: (corner x+1)origin y)
	color: 1 mode: effect;
	moveto: (origin x-1)corner y; color: 1 mode: effect;
	origin _ corner x(origin y-1); color: 1 mode: effect;
	moveto: origin-(11); color: 1 mode: effect
	]\gb66B

SYSTEM\gbf5 
copy | t
	[
	t _  BorderedText new paragraph: para copy frame: (frame copy) style: style copy.
	t c1_ c1 ; c2_ c2 ; begintypein _ begintypein.
	 t
	]\gb5B
pressCode [6]\gb10B
presson: press in: r | scale
	[
	scale _ press scale.
	press setp: (r origin x- scale)(r corner y-(3*scale)) ;
		showrectwidth: (scale*(2+self width)) height: scale.
	press setp: (r origin x- scale)(r corner y-((self height+5)*scale)) ;
		showrectwidth: (scale*(2+self width)) height: scale.
	press setp: (r origin x- scale)(r corner y-(scale*(self height+4))) ;
		showrectwidth: scale height: (scale*(self height+2)).
	press setp: (r origin x+(scale*(self width)))(r corner y-(scale*(self height+4))) ;
		showrectwidth: scale height: (scale*(self height+2)).

 para presson: press in: r.
	]\gb30B
\g
SystemOrganization classify: BorderedText under: 'FPI Packages'.\g

"Document"l15000z20000\gbf5 
Class new title: 'Document'
	subclassof: Image
	fields: 'displayorder style'
	declare: 'leading micasperinch ';
	asFollows\gbf5 

basic document class\gi

EDITING\gbf5 
bubbledelete: image | delta i k
	["delete image from the document  and subtracting images extent y from all subimages below it."
	i _ self find: image.
	i [
			self deleteI: i .
			delta _ image extent y.
			for k from: i to: self length do
				[
				(selfk) translate: (0(0-delta))
				]
		
		]
	]\gb20B
bubbleinsert: image | delta i k
	["insert image into the document keeping the document y-sorted and adding images extent y to all subimages below it."
	i _ self findindex: image.
	self insertI: i value: image.
	delta _ image extent y.
	for k from: i+1 to: self length do
		[
		(selfk) translate: (0delta)
		].
	
	]\gb20B
delete: image |  i 
	["delete image from the document and leave its space. "
	i _ self find: image.
	i [ self deleteI: i.]
	]\gb14B
edit 
	["Documents are edited with a DocumentEditor"
	DocumentEditor new init: self.
	]\gb7B
findindex: image | y guess top bottom
	["binary search on the origins of the rectangles surrounding my subimages
		returns the index of the subimage just below image."
	position = 0  [  1]
	top _ 1.
	bottom _ position.
	y_ image rectangle origin y.
	y  ((self1) rectangle origin y)  [  1].
	y  ((selfposition) rectangle origin y)  [  position+1]
	guess _ position/2.
	until  bottom = (top+1) do
		[
			[((selfguess) rectangle origin y)  y  [ bottom _ guess ] top _ guess].
			guess _ (bottom + top) /2
		]
	 bottom
	
	]\gb17B
insert: image | i
	["insert image into the document keeping the document y-sorted."
	i _ self findindex: image.
	self insertI: i value: image.
	]\gb14B
resize | delta t
	["make sure the document does not have subimages that have negative y values and resize the document"
	[position  1 
		[
		(delta _ (self1) top)  0  
			[
			for t from: self do [ t translate: (0(0-delta)) ] 
			]
		]
	].
	super resize
	]\gb7B

INIT\gbf5 
classInit 
	[
	micasperinch _ 2540.
	]\gb12B
name
[   displayorder "returns the name of the document ( displayorder is currently used for name... note that name is a string."
 ] 
	
\gb23B108b5B
name: displayorder 
	["sets the name of the document ( displayorder is currently used for name... note that name is a string."
	]\gb21B

SYSTEM\gbf5 
copy | im i
[
	im _ Document new origin: origin copy rectangle: rectangle copy path: path copy form: form copy figure: figure copy ground: ground copy xgrid: xgrid copy  ygrid: ygrid copy.
	for i to: self length do 
		[im add: (selfi) copy].
	im name: (self name) copy.
	 im
]\gb5B
fromPress: displayorder | press s
	["retrieves an instance of class Document from a press file"
	user displayoffwhile 
		[
	self default.
	 press _ (dp0 pressfile: displayorder). press open.
	s _ (press nextControl) asStream.
	s next = self pressCode  [self fromPress: press value: s]
	user notify: 'error in pressfile'.
		]
	]\gb24B13i57I71b12B
fromPress: press value:  s | numberofsubimages t t1 i code 
	["builds an instance of class Document from a press file"
	numberofsubimages_ s nextword.
	origin _ s nextPoint.
	t _ s nextPoint.
	t1 _ s nextPoint.
	rectangle _ t rect: t1.
	xgrid _ s nextword.
	ygrid _ s nextword.
	displayorder_ s nextString.	
	for i to: numberofsubimages do
				[s _ (press nextControl) asStream.
				code _ s next. 
				t _ [code = 1 [Image new]; = 2 [Heading new];
					= 3 [BitImage new] false].
				t and code = t pressCode [
					self addimage: (t fromPress: press value: s)]
				user notify: 'illegal code or code mismatch']	
	 self
	]\gb27B
hardcopy |	p i press bottoms rect pressscale pageheight pagewidth  lastrect 				currentrect oldytop oldybottom 
	[
	oldytop _ 11*micasperinch.
	pageheight _ 11*micasperinch.
	pagewidth_ 8*micasperinch.
	
	user displayoffwhile 
	[
	press _ dp0 pressfile: (displayorder + '.doc').
	pressscale _ press scale.
	self hidePress: press complete: 1.
	p _ PressPrinter init.
	p press: press;
		frame _  ("in micas"
				((1*micasperinch)(1*micasperinch)) rect:
				((pagewidth-micasperinch)(pageheight-micasperinch))).

	lastrect _ ((self1) rectangle)*pressscale.
	rect _ ((lastrect leftside)(1*micasperinch))
	rect: ((lastrect rightside) (pageheight - (lastrect top))).
	oldybottom _ p print: self1 in: rect.
	for i from: (2 to: self length) do
			[
			[oldybottom > oldytop 
				["page break" oldytop _ pageheight-micasperinch.
				]].
			currentrect_ ((selfi) rectangle) * pressscale.
			[(currentrect top > lastrect bottom)
				[oldytop _ oldybottom+(lastrect bottom-currentrect top)"no overlap"]
				oldytop _ (oldytop+(lastrect top-currentrect top))"overlap"].
			rect _ ((currentrect leftside)(1*micasperinch))
			rect: ((currentrect rightside) (oldytop)).
			oldybottom _ p print: (selfi) in: rect.
			lastrect _ ((selfi) rectangle)*pressscale.
			].

	press close; toPrinter "send over ethernet to printer"]
	]\gb9B
hideData: complete | s
	["stores an instance of class Document from a press file"
	s _ Stream new of: (String new: 100).
	s nextword_ self length; "number of subimages"
		nextPoint_ origin;
		nextPoint_ rectangle origin;
		nextPoint_ rectangle corner;
		nextword_ xgrid;
		nextword_ ygrid;
		nextString_ displayorder.	
	 s contents]\gb19B
pressCode [0]\gb10B
printon: strm | t
	[
	strm append: 'a Document '.
	]\gb14B
\g
SystemOrganization classify: Document under: 'FPI Packages'.\g
Document classInit\g

"DocumentEditor"l15000z20000\gbf5 
Class new title: 'DocumentEditor'
	subclassof: Window
	fields: 'document documentwindow screenimage firstindex lastindex
	indexofselection selection '
	declare: 'jumpcursor documentmenu scrap blankcursor ';
	asFollows\gbf5 

This class has not yet been commented\gi

INIT\gbf5 
buildscreenimage | i r delta  
	["This function copies the subimages intersecting the document window
		into the screen image."
	screenimage _ Image new origin: self frame origin extent: self frame extent.
	screenimage  xgrid: (document xgrid) ; ygrid: (document ygrid).
	delta _ documentwindow origin y.
	firstindex _ 1.
		" find the index of the first subimage that intersects the document window."
	until ((firstindex(document length)) or
		((((documentfirstindex) rectangle) bottom) > (documentwindow top))) do
		[firstindex _ firstindex+1].
	lastindex _ firstindex.
	for i from: (firstindex to: document length) do
		[
			((((documenti) rectangle) top) < (documentwindow bottom))
					[lastindex _ i. screenimage add: (((documenti) "copy")
													translate: 00 - (0delta))
					]  lastindex
		].
	
]\gb18B
classInit 
"  DocumentEditor classInit.    "
[	documentmenu _ Menu new string:
'move
erase
place
cut
paste
copy
top
bottom
jump
addspace
deletespace
show
'.
	jumpcursor _ Cursor new fromtext: '
1111111111111111
1111111111111111
0000000000000000
0000000000000000
0000000000000000
0000000000000000
0000001110000000
0000011111000000
0000011111000000
0000001110000000
0000000000000000
0000000000000000
0000000000000000
0000000000000000
1111111111111111
1111111111111111' offset: 21.
]

\gb11Bi34I
defaultdocument 
[
	self defaultdocument: 'document'
]\gb17B
defaultdocument: name | defaultdocument run r textimage f im dot heading head text char b image row
[" name is a string"
	defaultdocument _ Document new origin: 00
									extent: (user screenrect) extent.
	defaultdocument name: name.
	defaultdocument xgrid: DefaultTextStyle tab.
	defaultdocument ygrid: DefaultTextStyle lineheight.
	
	textimage _ BorderedText new.
	textimage text: 'Text that is bordered' width: 200.
	defaultdocument addform: textimage andpath: 00.

	textimage _ TextImage new.
	textimage text: 'This is a paragraph' width: 600.
	defaultdocument addform: textimage andpath: 00.
	
	b _ BitImage new fromrectangle:
				(Rectangle new origin: 0200 extent: 100100).
	defaultdocument insert: b.
	head _ Set new default.
	text _ 'HEADING'.
	for char from: text do [ head add: char ].
	heading _ Heading new origin: 0400 index: 9 charactercodes: head
		currentcharacter: 0.
	defaultdocument insert: heading.
	"defaultdocument insert: CurveIdiom new init."
	self init: defaultdocument.
]\gb22B
init: document | i 
	["This is the paragraph (subimage) level document editor."
	self fixedwidthfromuser: document width.
	documentwindow _ Rectangle new origin: document rectangle origin
									extent: (document width)  (self frame height).
	self buildscreenimage.
	selection _ false.
	user topWindow leave.
	self takeCursor; enter.
	user restartup: self
	]\gb15B

DEFAULT EVENT RESPONSES\gbf5 
close
[
	XeqCursor show.
	document close.
	document _ nil.
	screenimage _ Vector new: 0.
	NormalCursor show
]\gb6B
enter [selection _ false. self show]\gb6B
hardcopy
	["write a press file and hardcopy this document"
	self leave.
	self top.
	document hardcopy
	]\gb10B
kbd | c x y
[
	   c _ user kbd. 
 	c = 120
 		[ user clearshow: 'x gridding is '. document xgrid print.
 		user cr.
 		document xgrid: (x_
 		(user request: 'x gridding . . . ') asInteger).
		screenimage xgrid: x. 
 		] 
 	c = 121
 		[ user clearshow: 'y gridding is '. document ygrid print.
 		user cr.
 		document ygrid: (y_
 		(user request: 'y gridding . . . ') asInteger).
		screenimage ygrid: y.
 		] 
]
\gb14B
leave
	[
	document  nil  []
	[selection [ selection highlite]].
	self update ; buildscreenimage.
	selection _ false.
	]\gb7B
print 
	["write a press file and hardcopy this document"
	document hardcopy
	]\gb8B
redbug | pt rect newrect start t
	[pt _ user mp.
	start_pt.
	rect_newrect_(Rectangle new origin: start corner: start).
	[selection [selection highlite. self deselect. selection _ false.]]. 
	while user anybug do
		[rect_newrect.
		rect comp.
		t_user mp.
		newrect_(Rectangle new origin: (start min: t) corner: (start max: t)).
		rect comp].
	(rect width < 10) 
		[
		selection _
			screenimage smallestsubimageat:  pt- screenimage origin.
		selection
				[
				selection  translate: screenimage origin.
				selection edit: screenimage.
				selection translate: ((00) - screenimage origin).
				selection _ false.
				]
		]
		rect origin _ screenimage griddedpoint: (rect origin).
		selection _ screenimage subimageswithin: 
									(rect translate: ((00)- screenimage origin)).
		selection 
		[selection translate: screenimage origin ; highlite]
	]\gb34B
yellowbug | pt
	[
	documentmenu bug
		=1[self move];
		=2[self delete];
		=3[self place];
		=4[self cut];
		=5[self paste];
		=6[self copyselection];
		=7[self top];
		=8[self bottom];
		=9[self jump];
		=10[self addspace];
		=11[self deletespace];
		=12[self deselect. selection _ false. self show]
	
	]\gb16B1b2B

FRAMING\gbf5 
newframe
	[self update.
	self fixedwidthfromuser: document width.
	self buildscreenimage ; show.
	]\gb10B
show [
	XeqCursor show.
	self outline .
	growing[]
	titleframe put: (Paragraph new text: self title runs: titlerun alignment: 0)
		at: frame origin+titleloc; window outline; show.
	screenimage  white.
	screenimage displayat: 00 effect: 1 clippedBy: self frame.
	selection  [ selection boxcomp].
	NormalCursor show

	]\gb5B
title [  document name] \gb6B

EDITING\gbf5 
addspace | image i k r delta
	["add whitespace to the document  ."
	self update. selection _ false.
	r _ document rectanglefromuser.
	i _ (document indexofsubimagebelow: (r top- screenimage top) + documentwindow top).
	[i 	[
			delta _ r height.
			for k from: i to: document length do
				[
				(documentk) translate: (0(delta))
				].
		document resize
		]
			].
	self buildscreenimage ; show.
	]\gb9B
bottom |  i delta 
	["translate the current selection to the bottom of the window and update the document to reflect any changes in the subimages which are scrolled out of the screenimage."
	selection
		[
		delta _ (selection rectangle corner - screenimage rectangle corner).
		self update. selection _ false.
		documentwindow translate: (0 (delta y)). "move window on document"
		self buildscreenimage ; show. 
			"reconstruct screen image, including reestablishing  first and last indices"
		]
		self update.
		documentwindow _ Rectangle new origin:
											(document rectangle corner-self frame height)
										extent: (document width)  (self frame height).
		self buildscreenimage ; show.
	]
\gb7B
closeScrap
	[
	scrap  nil []
	scrap close
	]\gb12B
copy | 
	["copy the selection and put it in scrap"
	self copyselection
	]\gb5B
copyselection | 
	["copy the selection and put it in scrap"
	selection
		[
		XeqCursor show.
		self closeScrap.
		scrap _ selection copy.
		NormalCursor show
		]
	frame flash
	]\gb14B
cut | t 
	["delete subimage (paragraph) from the screenimage and save it in the scrap"
	selection
		[
		XeqCursor show.
		self closeScrap.
		scrap _ selection.
		self update.
		for t from: selection do
			[
			document bubbledelete: t.
			].
		selection _ false.
		self buildscreenimage ; show.
		NormalCursor show
		]
	frame flash
	]\gb4B
delete | t
	["delete subimage (paragraph) from the screenimage and save it in the scrap"
	selection
		[
		XeqCursor show.
		self closeScrap.
		scrap _ selection.
		selection highlite ;  display: 3.
		for t from: selection do
		[screenimage delete: t
		]. 
		selection _ false.
		NormalCursor show.
		]
	frame flash
	]\gb12B
deletespace | image i k r delta
	["delete whitespace from the document  ."
	self update. selection _ false.
	r _ document rectanglefromuser.
	i _ (document indexofsubimagebelow: (r top - screenimage top) + documentwindow top).
	[i 	[
			delta _ r height.
			for k from: i to: document length do
				[
				(documentk) translate: (0(0-delta))
				].
		document resize
		]
			].
	self buildscreenimage ; show.
	]\gb12B
deselect | t
		[selection [
						selection translate: ((00) - screenimage origin).
						for t from: selection do
							[t translate: selection origin
							].

						 ]
		] \gb9B
editTitle
	[titlepara_document name asParagraph.
	super editTitle.
	document name: titlepara text]\gb11B
jump
	|  y deltay yprime deltayprime rect pt newY scal r
	[user waitnobug.
	XeqCursor show.
	self update.
	y _ document height.
	yprime _ frame height.
	deltay _ (documentwindow origin y) - (document  origin y).
	scal_yprime asFloat/y.
	deltayprime _ (scal*deltay) asInteger.
	pt _ ((screenimage leftside+((1.0-scal)*frame width/2))((screenimage top) + deltayprime)).
	document quickDisplayAt: 00 scale: scal offset: (frame minX + ((1.0-scal)*frame width/2))frame minY.
	rect_00 rect: 11.
	rect origin _ pt.
	rect corner x_pt x +(scal*frame width) asInteger.
	rect corner y_pt y + (scal*frame height) asInteger.
	user cursorloc_pt.
	OriginCursor show.
	user waitbug.
	[user redbug
			[rect comp.
			while user redbug do
				[r_rect copy.
				newY_user mp y.
				[newY<(frame minY- rect height)  [newY_frame minY-rect height]].
				[newY>frame maxY  [newY_frame maxY]].
				rect translateto: pt xnewY.
				r comp.
				rect comp].
			rect comp.
			XeqCursor show.
			deltayprime _ newY - (frame origin y).
			deltay _ y*deltayprime/yprime.
			documentwindow translateto: (0deltay).
			selection _ false]].
	self buildscreenimage.
	self show.
	NormalCursor show]\gb6B
move | pt t
	["used to place subimages (paragraphs) in the Image."
	selection
			[user waitnobug.
			OriginCursor show.
			user waitbug. 
			selection highlite ; displayat: 00 effect: 3 clippedBy: frame.
			while user redbug do
				[pt _screenimage mp + screenimage rectangle origin.
				selection translateto: pt.
				selection blink].
			XeqCursor show.
			selection displayat: 00 effect: 1 clippedBy: frame .
			self deselect.
			selection _ false.
			NormalCursor show]
		frame flash]\gb5B
paste | pt t

["add the subimage (paragraph) in the scrap to the screenimage."
		[
		selection [selection highlite]].
		self update.
		selection _ scrap copy.
		OriginCursor showwhile
		[
		user waitbug.
		until user nobug do
			[
			pt _screenimage mp + screenimage rectangle origin.
			selection  translateto: pt ; blink
			]
		selection displayat: 00 effect: 1 clippedBy: self frame .
		].
	self deselect.
	for t from: selection do
		[
		document bubbleinsert: (t translate: documentwindow origin).
		].
	selection _ false.
	self buildscreenimage ; show.
	]\gb6B2b4B
place | pt tempimage t

["add the image in the scrap to the screenimage."
	[selection[selection highlite]].
	self deselect.
	selection _ scrap copy.
		OriginCursor showwhile
		[
		user waitbug.
		until user nobug do
			[
			pt _screenimage mp + screenimage rectangle origin.
			selection translateto: pt ; blink
			]
		].
	selection  displayat: 00 effect: 1 clippedBy: self frame.
	self deselect.
	for t from: selection do
		[
			screenimage add: t.
		].
	selection _ false.
	
	]\gb6B
top |  i delta 
	["translate the current selection to the top of the window and update the document to reflect any changes in the subimages which are scrolled out of the screenimage."
	selection
		[
		delta _ (selection rectangle origin - screenimage rectangle origin).
		self update. selection _ false.
		documentwindow translate: (0 (delta y)). "move window on document"
		 self buildscreenimage ; show. 
			"reconstruct screen image, including reestablishing  first and last indices"
		]
	self update.
	documentwindow _ Rectangle new origin: document rectangle origin
									extent: (document width)  (self frame height).
	self buildscreenimage ; show.
	]
\gb4B
update |  i 
	["update the document to reflect any changes in the subimages ."
	XeqCursor topage1.
		[selection	[self deselect]].
		document deleteI: firstindex to: lastindex. "update document"
		for i to: screenimage length  do 
			[document insert: 
							(screenimagei translate: (0documentwindow origin y)).
			].
	document resize.
	NormalCursor topage1.
	]
\gb7B
\g
SystemOrganization classify: DocumentEditor under: 'FPI Packages'.\g
DocumentEditor classInit\g

"Heading"l15000z20000\gbf5 
Class new title: 'Heading'
	subclassof: Image
	fields: 'formset index charactercodes currentcharacter'
	declare: 'headingmenu ';
	asFollows\gbf5 

This class has not yet been commented\gi

INIT\gbf5 
classInit 
	["menu for the Heading edits."

headingmenu _ Menu new string:
'right
left
up
down
font
'.

	]\gb12B
origin: origin formset: formset currentcharacter: currentcharacter
	["initilization of a Heading (used in copy)"
	[formset is: Integer [ formset _ FormSet new fromstyle:
						DefaultTextStyle styleindex: formset.]].
	self origin: origin extent: (200formset height).
	]\gb68B
origin: origin index: index charactercodes: charactercodes
		currentcharacter: currentcharacter | char w delta
	["initilization of a Heading (used in copy)"
	formset _ FormSet new fromstyle:
						DefaultTextStyle styleindex: index.
	[ nil  charactercodes  [ charactercodes _ Set new default]].
	self origin: origin extent: (200formset height).
	w _ 0.
	delta _ origin copy.
	self translate: (00 - delta).		
	for char from: charactercodes do
		[	char _ formset asForm: char.
			self addpath: w0 andform: char.
			w _ w + char width.
		]
	self translate: delta.
	 self
	]\gb112B

EDIT\gbf5 
down | delta
	["move the current character down one bit."
	self boxcomp.
	(selfcurrentcharacter) translate: (01).
	delta _ origin copy.
	self translate: (00 - delta) ; resize ; translate: delta.
	self white ; display: 1.
	self boxcomp.
	]\gb14B
edit: parentimage | pt 
	["Simple Heading (line) editor for now."
	self display: 0.
	until 1=2 do "forever for now"
		[
		user kbck
		[ self typein ]
		user yellowbug 	[
			headingmenu bug
				=1	[self right]; "move current character right one bit"
				=2	[self left]; "move current character left one bit"
				=3	[self up]; "move current character up one bit"
				=4	[self down]; "move current character down one bit"
				=5	[self newfont] "change fonts"
									]
		user redbug  		[(rectangle has: (pt_ user mp))
										[pt _ pt - (rectangle origin).
										currentcharacter_ self indexofsubimageat: pt.
										currentcharacter
											[
											selfcurrentcharacter displayat: self origin
											effect: 2 clippedBy: user screenrect.
											selfcurrentcharacter displayat: self origin
											effect: 2 clippedBy: user screenrect.
											]
										]
										 self
									]
		user bluebug  		[
									 self.
									] "exit back to the parentimage" 
		]
	]\gb18B
left | i delta
	["move the current character and all those to the right of it to the left one bit."
	self boxcomp.
	for i from: (currentcharacter to: self length) do
		[ (selfi) translate: (00) -(10) ].
	delta _ origin copy.
	self translate: (00 - delta) ; resize ; translate: delta.
	self white ; display: 1.
	self boxcomp.
	]\gb16B
newfont | w char charcount delta i
	[
	index _(user request: 'index of new font . .  ' ) asInteger.
	formset _ FormSet new fromstyle: DefaultTextStyle styleindex: index.
	self white.
	for i to: position do [ selfi _ nil ].
	position _ 0.
	w _ 0.
	charcount _ 0.
	delta _ origin copy.
	self translate: (00 - delta).		
	for char from: charactercodes do
		[nil char  []
		char _ formset asForm: char.
		char displayat: delta+ (w0) effect: 0 clippedBy: user screenrect.
		self addpath: w0 andform: char.
		w _ w + char width.
		charcount _ charcount+1.
		]
	self resize.
	self translate: delta.
	 self
	]\gb8B
right | i delta
	["move the current character and all those to the right of it to the right one bit."
	self boxcomp.
	for i from: (currentcharacter to: self length) do [ (selfi) translate: (10) ].
	delta _ origin copy.
	self translate: (00 - delta) ; resize ; translate: delta.
	self white ; display: 1.
	self boxcomp.
	]\gb17B
typein | w char charcount delta i
	[
	self white.
	for i to: position do [ selfi _ nil ].
	position _ 0.
	w _ 0.
	charcount _ 0.
	charactercodes _ Set new default.
	delta _ origin copy.
	self translate: (00 - delta).		
	until (char _ user kbd) = 13 do
		[			
			(char = 8) "back space" 
					[charcount   0  [ 
							 					w _ w - ( (selfcharcount) width).
												(selfcharcount) white.
												self deleteimage: charcount.
												charactercodes deleteI: charcount.
												charcount _ charcount -1.
												]
					]
			charactercodes add: char.
			char _ formset asForm: char.
			char displayat: delta+ (w0) effect: 0 clippedBy: user screenrect.
			self addpath: w0 andform: char.
			w _ w + char width.
			charcount _ charcount+1.
		]	
	self resize.
	self translate: delta.
	 self
	]\gb7B
up | delta
	["move the current character up one bit."
	self boxcomp.
	(selfcurrentcharacter) translate: (00) - (01).
	delta _ origin copy.
	self translate: (00 - delta) ; resize ; translate: delta.
	self white ; display: 1.
	self boxcomp.
	]\gb12B

SYSTEM\gbf5 
copy | h i
	[
	h_ Heading new origin: (rectangle origin) copy index: index charactercodes: (charactercodes copy)
		currentcharacter: currentcharacter copy.
	h rectangle: rectangle copy.
	for i to: self length do 
		[
		h add: (selfi) copy 
		]
	 h
	]\gb5B
fromPress: press value:  s | numberofcharacters  i 
	["retrieves and builds an instance of class Heading from a press file"
	numberofcharacters_ s nextword.
	origin _ s nextPoint.
	index _ s nextword.
	charactercodes _ Set new default.

	for i to: numberofcharacters do
				[ charactercodes add: s nextword ]	
	 self origin: origin index: index charactercodes: charactercodes
		currentcharacter: 1
	]\gb27B
hideData: complete | s i
	["stores an instance of class Heading on a press file"
	s _ Stream new of: (String new: 100).
	s nextword_ self length; "number of characters"
		nextPoint_ origin;
		nextword _ index.
	for i to: self length do [s nextword _ charactercodesi].
	 s contents]\gb19B
pressCode [2]\gb10B
presson: press in: r | hs y t i pressscale [
	(hs  _ press scale*self height) > r height [
		"not enough room left on current page.
		assume for now that it will at least fit on an entire page"
		 self]

	self hidePress: press complete: 1.
	pressscale _ press scale.
	press selectfont: (press fontindex: 16*index style: DefaultTextStyle) - 1.

	for i to: self length  do
		[
		press setx:  r leftside + ((selfi) leftside*pressscale).
		press sety: r bottom - ((selfi) top*pressscale).
		press showchar: (charactercodesi)
		].
	 r bottom - ((self height)*pressscale)]\gb21B
printon: strm | t [
	strm append: 'a Heading '.
	]\gb14B
\g
SystemOrganization classify: Heading under: 'FPI Packages'.\g
Heading classInit\g
