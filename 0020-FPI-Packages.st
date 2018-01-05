'From Smalltalk 5.5k XM November 24 on 22 November 1980 at 2:57:08 am.'

"BitImage" 
Class new title: 'BitImage'
	subclassof: Image
	fields: 'strips nstrips'
	declare: 'brush aurora stripheightSPARE stripheight black white bitimagemenu erase SPARE color formmenu under reverse blankcursor over dotsetter ';
	asFollows 

This class is a virtual bit map represented as a smalltalk String

INIT 
classInit 
	["sets up colors and effects for BITBLT."
	black ← 0-1.
	white ← 0.
	over ← 0.
	under ← 1.
	reverse ← 2.
	erase ← 3.
	brush ← Form new extent: 5⌾5. brush black.
	color ← 1.
	stripheight ← 20.
bitimagemenu ← Menu new string:
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
	aurora ← "Aurora new" nil.
	]
fromImage: image 
	["creates a virtual bit map with width = (image width) and height = (image height) with the bits in image."
	self fromrectangle: image rectangle.
	]
	
fromrectangle: rect | r i leftover image yposition
	["creates a virtual bit map with width = (r width) , height = (r height)
	 and the bits in rect. The Image is  made up of forms that are stripheight high."
	super origin: rect origin extent: rect extent.
	nstrips ← (rect height + (stripheight -1))/stripheight.
	yposition ← 0.
	leftover ← rect height \ stripheight.
	[ (leftover = 0) ⇒ [leftover ← stripheight]].
	r ← Rectangle new origin: rect origin extent: (rect width)⌾stripheight.
	for⦂ i to: nstrips do⦂ 
		[
		[ i = nstrips ⇒ [ r extent ← ((rect width)⌾leftover)]].
		image ← Image new origin: (0⌾0) extent: rect extent.
		image form: (Form new fromrectangle: r) ; path: (0⌾yposition).
		self addimage: image.
		yposition ← yposition + stripheight.
		r translate: (0⌾stripheight).
		].
	

	]
	
	fromuser  | r
	["create a new Form whose rectangle is specified by the user. "
	r ← Rectangle new fromuser.
	self fromrectangle: r
	]
fromuserevenword  | r
	["create a new BitImage whose rectangle is specified by the user,
		truncated to nearest multiple of 16 (for Spruce printing). "
	r ← Rectangle new fromuserevenword.
	self fromrectangle: r.
	]

PATTERN ACCESS 
erase | i
	["sets all bits in the BitImage to white ( to zeros)"
	for⦂ i to: nstrips do⦂ [ (strips◦i) white]
	]
nstrips
	[
	⇑ nstrips 
	]

nstrips: nstrips 

saveScreenBits
[
]
strips 
	["return the set of Forms making up this BitImage)"
	⇑ strips
	]
strips: strips 


MODULE ACCESS 
comment 
	["see class Image"
	]
frame [ ⇑ rectangle]
moveto: pt  
	[self translateto: pt
	]

FILING 
read: filename | file subimage strip yposition i
	["Reads the Image in the format nstrips , Form(1) , Form(2) , Form(3) . . .
		Form(nstips). Where each Form is saved as width,height then bits.  "
		self origin: 0⌾0 extent: 1⌾1.
		yposition ← 0.
		file← (dp0 oldFile: filename) readonly.
		nstrips ← file nextword.
		for⦂ i to: nstrips do⦂
				[
				strip ← Form new fromInstance: file.  
				self addform: strip andpath: (0⌾yposition).
				yposition← yposition+ strip height.
				].
		file close.
	]
write: filename | file subimage
	["Saves the Form in the format nstrips , Form(1) , Form(2) , Form(3) . . .
		Form(nstips). Where each Form is saved as width,height then bits.  "
		file ← (dp0 file: filename).
		file nextword← nstrips.
		for⦂ subimage from: self do⦂ [ file append: (subimage form) asInstance. ]
		file close.
	]

DISPLAY 
displayat:  path effect: effect clippedBy: cliprect
	[
	super displayat: path effect: effect clippedBy: cliprect
	]
show
	[
	super displayat: (0⌾0) effect: 0 clippedBy: user screenrect
	]

SYSTEM 
copy | t i
	["return a copy of myself"
	t ← BitImage new origin: (origin copy) extent: (self extent) copy.
	for⦂ i to: self length do⦂ [ t add: (self◦i) copy].
	⇑ t
	]
pressCode [⇑3]
printon: strm | t
	[
	strm append: 'a Bitmage: '.
	]

title 
	[
	⇑ ''
	]

EDITING 
arc | pt1 pt2 pt3 p pt
	["arc tool for forms."
	BlankCursor topage1.
	user clear; print: 'Redbug 3 points'; cr; print: 'Paints using current brush.' .
	user waitnobug.
	until⦂ user redbug do⦂	[ pt1 ← self blinkbrush].
	brush displayat: pt1 effect: color clippedBy: user screenrect.
	user waitnobug.
	until⦂ user redbug do⦂		[ pt2 ← self blinkbrush].
	brush displayat: pt2 effect: color clippedBy: user screenrect.
	user waitnobug.
	until⦂ user redbug do⦂	[ pt3 ← self blinkbrush].
	brush displayat: pt3 effect: color clippedBy: user screenrect.
	XeqCursor show.
	p ← Path new init.
	p addarcfrom: pt1 via: pt2 to: pt3.
	for⦂ pt from: p do⦂
					[ brush displayat: pt effect: color clippedBy: user screenrect].
	NormalCursor show
	]

blinkbrush | pt 
	["to show current position of brush in the BitImage."
		pt ← self mp + rectangle origin.
		brush displayat: pt
			effect: 2 clippedBy: user screenrect.
		brush displayat: pt
			effect: 2 clippedBy: user screenrect.
	⇑ pt
	]

edit: superimage | bits 
	["uses the BitRect toolbox editor"
	XeqCursor show.
	dotsetter ← BitRectEditor new picture: self.
	dotsetter firsttime.
	NormalCursor show.
	while⦂ true do⦂ "forever"
		[
		(dotsetter lostMouse and: (user anybug)) ⇒
					[	dotsetter outside⇒ []
						XeqCursor show.
						dotsetter lasttime.
						bits ← self fromrectangle: rectangle.
						NormalCursor show.
						⇑ bits
					]
		dotsetter eachtime
		]
	]

grayEdit | a b c i d p r v bits "edit up a gray pattern and return it"
	["first a rectangle for it.  Then redbug is black, yellow is white,
	blue terminates"
	r ← Rectangle new fromuser. bits←0.
	a ← r extent. a← (a x max:  a y) | 4. a ← a⌾a.
	b ← r origin. r extent← a; color: white mode: storing; moveby: 0⌾(0-a y).
	c ← a/4.  d ← b rect: b+c.
	until⦂ user bluebug do⦂ [
	user redbug ⇒[p ← user mp -b /c.  i ← p y *4 +p x +1.
		i<1 or⦂ i>16 ⇒[r flash]
		d moveto: b+(c*p); color: black mode: storing.
		bits ← bits lor: (1 lshift: 16-i).
		r color: bits mode: storing. user waitnobug]
	user yellowbug ⇒[p ← user mp -b /c.  i ← p y *4 +p x +1.
		i<1 or⦂ i>16 ⇒[r flash]
		d moveto: b+(c*p); color: white mode: storing.
		bits ← (¬1 lxor:(1 lshift: 16-i)) land: bits.
		r color: bits mode: storing. user waitnobug]
	] ⇑bits]
"aa grayEdit base8 ."
horizontalsymmetry | r f i 
	["horizontal symmetry tool"
	user clear; show: 'Define rectangle. Reflection will be around lower edge'.
	r ← Rectangle new fromuser.
	XeqCursor show.
	for⦂ i to: ( r height) do⦂
		[
		f ← Form new fromrectangle: (Rectangle new origin: ((r origin x)⌾((r bottom)-i)) extent: ((r width)⌾1)).
		f displayat: (r origin x)⌾((r bottom) +i) effect: 0 clippedBy: user screenrect.
		].
	NormalCursor show.
	]
line | pt1 pt2 p pt
	["line tool for forms."
	BlankCursor topage1.
	until⦂ user redbug do⦂	[ pt1 ← self blinkbrush].
	brush displayat: pt1 effect: color clippedBy: user screenrect.
	until⦂ user nobug do⦂		[ pt2 ← self blinkbrush].
	brush displayat: pt2 effect: color clippedBy: user screenrect.
	p ← Path new init.
	p addlinefrom: pt1 to: pt2.
	for⦂ pt from: p do⦂
					[ brush displayat: pt effect: color clippedBy: user screenrect].
	NormalCursor topage1
	]

newbrush |  pt rect
	[
	OriginCursor topage1.
	user waitbug.
	pt ← ( self mp)+ rectangle origin.
	rect ← pt rect: pt.	
	CornerCursor topage1.
	until⦂ user nobug do⦂
			[rect reverse.
			rect reverse.
			pt ← 
			( self mp)+ rectangle origin.
			rect corner ← (rect origin) max: pt.
			]
 	brush ← Form new fromrectangle: rect.
	NormalCursor topage1.
	]

pastebrush | pt1 
	["one-copy tool for forms."
	user waitnobug.
	OriginCursor show.
	user waitbug.
	while⦂ user redbug do⦂
		[ pt1 ← self blinkbrush].
	XeqCursor show.
	brush displayat: pt1 effect: (dotsetter tool mode) clippedBy: user screenrect.
	NormalCursor show]
resize: superimage |  pt f
	[dotsetter leave.
	CornerCursor topage1.
	user waitbug. 
	until⦂ user nobug do⦂
			[self reverse.
			self reverse.
			( pt ← 
			(superimage  mp)+
				 superimage rectangle origin).
			self corner← pt max: ((self origin) + (16⌾16)).
			]
 	self fromrectangle: rectangle.
 	self white ; display.
	NormalCursor topage1.
	self edit: superimage
	]

rotate | r f i j
	["90 degree rotation tool"
	r ← Rectangle new fromuser.
	for⦂ i to: ( r width) do⦂
		[
		for⦂ j to: ( r height) do⦂
			[
			f ← Form new fromrectangle: (Rectangle new origin: (((r origin x)+i)⌾(r top+j)) extent: (1⌾1)).
			f displayat: (((r corner x)+j))⌾((r top)+i) effect: 0 clippedBy: user screenrect.
			]
		]
	]
setfigure | t
	["for now just increment the figure color by 1 \ 12"
	figure ← (figure +1 ) \ 12.
	for⦂ t from: self do⦂ [ (t form) figure: figure].
	self display
]

setground | t
	["for now just increment the ground color by 1 \ 12"
	ground ← (ground +1 ) \ 12.
	for⦂ t from: self do⦂ [ (t form) ground: ground].
	self display
]

verticalsymmetry | r f i 
	["vertical symmetry tool"
	user clear; show: 'Define rectangle. Reflection will be around right-hand edge'.
	r ← Rectangle new fromuser.
	XeqCursor show.
	for⦂ i to: ( r width) do⦂
		[
		f ← Form new fromrectangle: (Rectangle new origin: (((r origin x)+(r width)-i)⌾(r top)) extent: (1⌾(r height))).
		f displayat: ((r corner x) + i)⌾(r top) effect: 0 clippedBy: user screenrect.
		].
	NormalCursor show.
	]
yellowbug | 
	[
	bitimagemenu bug
				=1⇒	[self resize: superimage
						]; "change size"
				=2⇒	[self setfigure];		
				=3⇒	[self setground];		
				=4⇒	[self newbrush];		
				=5⇒	[self pastebrush];		
				=6⇒	[self arc ];
				=7⇒	[Rectangle new fromuser fillin: ((dotsetter tool) tone)
							mode: ((dotsetter tool) mode) ];
				=8⇒  [(dotsetter tool) shade];
				=9⇒  [self verticalsymmetry];
				=10⇒  [self horizontalsymmetry];
				=11⇒  [self rotate]
	]

SystemOrganization classify: ↪BitImage under: 'FPI Packages'.
BitImage classInit

"BorderedText" 
Class new title: 'BorderedText'
	subclassof: TextImage
	fields: ''
	declare: '';
	asFollows 

This class has not yet been commented

DISPLAY 
displayat: pt effect: effect clippedBy: cliprect | origin corner
	["display text and border around it "
	super displayat: pt effect: effect clippedBy: cliprect.
	origin ← frame origin.
	corner ← frame corner.
	(Rectangle new
		origin: origin-(1⌾1) corner: (corner x+1)⌾origin y)
	color: ¬1 mode: effect;
	moveto: (origin x-1)⌾corner y; color: ¬1 mode: effect;
	origin ← corner x⌾(origin y-1); color: ¬1 mode: effect;
	moveto: origin-(1⌾1); color: ¬1 mode: effect
	]

SYSTEM 
copy | t
	[
	t ←  BorderedText new paragraph: para copy frame: (frame copy) style: style copy.
	t c1← c1 ; c2← c2 ; begintypein ← begintypein.
	⇑ t
	]
pressCode [⇑6]
presson: press in: r | scale
	[
	scale ← press scale.
	press setp: (r origin x- scale)⌾(r corner y-(3*scale)) ;
		showrectwidth: (scale*(2+self width)) height: scale.
	press setp: (r origin x- scale)⌾(r corner y-((self height+5)*scale)) ;
		showrectwidth: (scale*(2+self width)) height: scale.
	press setp: (r origin x- scale)⌾(r corner y-(scale*(self height+4))) ;
		showrectwidth: scale height: (scale*(self height+2)).
	press setp: (r origin x+(scale*(self width)))⌾(r corner y-(scale*(self height+4))) ;
		showrectwidth: scale height: (scale*(self height+2)).

⇑ para presson: press in: r.
	]

SystemOrganization classify: ↪BorderedText under: 'FPI Packages'.

"Document" 
Class new title: 'Document'
	subclassof: Image
	fields: 'displayorder style'
	declare: 'leading micasperinch ';
	asFollows 

basic document class

EDITING 
bubbledelete: image | delta i k
	["delete image from the document  and subtracting images extent y from all subimages below it."
	i ← self find: image.
	i⇒ [
			self deleteI: i .
			delta ← image extent y.
			for⦂ k from: i to: self length do⦂
				[
				(self◦k) translate: (0⌾(0-delta))
				]
		
		]
	]
bubbleinsert: image | delta i k
	["insert image into the document keeping the document y-sorted and adding images extent y to all subimages below it."
	i ← self findindex: image.
	self insertI: i value: image.
	delta ← image extent y.
	for⦂ k from: i+1 to: self length do⦂
		[
		(self◦k) translate: (0⌾delta)
		].
	
	]
delete: image |  i 
	["delete image from the document and leave its space. "
	i ← self find: image.
	i⇒ [ self deleteI: i.]
	]
edit 
	["Documents are edited with a DocumentEditor"
	DocumentEditor new init: self.
	]
findindex: image | y guess top bottom
	["binary search on the origins of the rectangles surrounding my subimages
		returns the index of the subimage just below image."
	position = 0 ⇒ [ ⇑ 1]
	top ← 1.
	bottom ← position.
	y← image rectangle origin y.
	y ≤ ((self◦1) rectangle origin y) ⇒ [ ⇑ 1].
	y ≥ ((self◦position) rectangle origin y) ⇒ [ ⇑ position+1]
	guess ← position/2.
	until⦂  bottom = (top+1) do⦂
		[
			[((self◦guess) rectangle origin y) ≥ y ⇒ [ bottom ← guess ] top ← guess].
			guess ← (bottom + top) /2
		]
	⇑ bottom
	
	]
insert: image | i
	["insert image into the document keeping the document y-sorted."
	i ← self findindex: image.
	self insertI: i value: image.
	]
resize | delta t
	["make sure the document does not have subimages that have negative y values and resize the document"
	[position ≥ 1 ⇒
		[
		(delta ← (self◦1) top) ≤ 0 ⇒ 
			[
			for⦂ t from: self do⦂ [ t translate: (0⌾(0-delta)) ] 
			]
		]
	].
	super resize
	]

INIT 
classInit 
	[
	micasperinch ← 2540.
	]
name
[ ⇑  displayorder "returns the name of the document ( displayorder is currently used for name... note that name is a string."
 ] 
	

name: displayorder 
	["sets the name of the document ( displayorder is currently used for name... note that name is a string."
	]

SYSTEM 
copy | im i
[
	im ← Document new origin: origin copy rectangle: rectangle copy path: path copy form: form copy figure: figure copy ground: ground copy xgrid: xgrid copy  ygrid: ygrid copy.
	for⦂ i to: self length do⦂ 
		[im add: (self◦i) copy].
	im name: (self name) copy.
	⇑ im
]
fromPress: displayorder | press s
	["retrieves an instance of class Document from a press file"
	user displayoffwhile⦂ 
		[
	self default.
	 press ← (dp0 pressfile: displayorder). press open.
	s ← (press nextControl) asStream.
	s next = self pressCode ⇒ [self fromPress: press value: s]
	user notify: 'error in pressfile'.
		]
	]
fromPress: press value:  s | numberofsubimages t t1 i code 
	["builds an instance of class Document from a press file"
	numberofsubimages← s nextword.
	origin ← s nextPoint.
	t ← s nextPoint.
	t1 ← s nextPoint.
	rectangle ← t rect: t1.
	xgrid ← s nextword.
	ygrid ← s nextword.
	displayorder← s nextString.	
	for⦂ i to: numberofsubimages do⦂
				[s ← (press nextControl) asStream.
				code ← s next. 
				t ← [code = 1⇒ [Image new]; = 2⇒ [Heading new];
					= 3⇒ [BitImage new] false].
				t and⦂ code = t pressCode⇒ [
					self addimage: (t fromPress: press value: s)]
				user notify: 'illegal code or code mismatch']	
	⇑ self
	]
hardcopy |	p i press bottoms rect pressscale pageheight pagewidth  lastrect 				currentrect oldytop oldybottom 
	[
	oldytop ← 11*micasperinch.
	pageheight ← 11*micasperinch.
	pagewidth← 8*micasperinch.
	
	user displayoffwhile⦂ 
	[
	press ← dp0 pressfile: (displayorder + '.doc').
	pressscale ← press scale.
	self hidePress: press complete: ¬1.
	p ← PressPrinter init.
	p press: press;
		frame ←  ("in micas"
				((1*micasperinch)⌾(1*micasperinch)) rect:
				((pagewidth-micasperinch)⌾(pageheight-micasperinch))).

	lastrect ← ((self◦1) rectangle)*pressscale.
	rect ← ((lastrect leftside)⌾(1*micasperinch))
	rect: ((lastrect rightside) ⌾(pageheight - (lastrect top))).
	oldybottom ← p print: self◦1 in: rect.
	for⦂ i from: (2 to: self length) do⦂
			[
			[oldybottom > oldytop⇒ 
				["page break" oldytop ← pageheight-micasperinch.
				]].
			currentrect← ((self◦i) rectangle) * pressscale.
			[(currentrect top > lastrect bottom)⇒
				[oldytop ← oldybottom+(lastrect bottom-currentrect top)"no overlap"]
				oldytop ← (oldytop+(lastrect top-currentrect top))"overlap"].
			rect ← ((currentrect leftside)⌾(1*micasperinch))
			rect: ((currentrect rightside) ⌾(oldytop)).
			oldybottom ← p print: (self◦i) in: rect.
			lastrect ← ((self◦i) rectangle)*pressscale.
			].

	press close; toPrinter "send over ethernet to printer"]
	]
hideData: complete | s
	["stores an instance of class Document from a press file"
	s ← Stream new of: (String new: 100).
	s nextword← self length; "number of subimages"
		nextPoint← origin;
		nextPoint← rectangle origin;
		nextPoint← rectangle corner;
		nextword← xgrid;
		nextword← ygrid;
		nextString← displayorder.	
	⇑ s contents]
pressCode [⇑0]
printon: strm | t
	[
	strm append: 'a Document '.
	]

SystemOrganization classify: ↪Document under: 'FPI Packages'.
Document classInit

"DocumentEditor" 
Class new title: 'DocumentEditor'
	subclassof: Window
	fields: 'document documentwindow screenimage firstindex lastindex
	indexofselection selection '
	declare: 'jumpcursor documentmenu scrap blankcursor ';
	asFollows 

This class has not yet been commented

INIT 
buildscreenimage | i r delta  
	["This function copies the subimages intersecting the document window
		into the screen image."
	screenimage ← Image new origin: self frame origin extent: self frame extent.
	screenimage  xgrid: (document xgrid) ; ygrid: (document ygrid).
	delta ← documentwindow origin y.
	firstindex ← 1.
		" find the index of the first subimage that intersects the document window."
	until⦂ ((firstindex≥(document length)) or⦂
		((((document◦firstindex) rectangle) bottom) > (documentwindow top))) do⦂
		[firstindex ← firstindex+1].
	lastindex ← firstindex.
	for⦂ i from: (firstindex to: document length) do⦂
		[
			((((document◦i) rectangle) top) < (documentwindow bottom))⇒
					[lastindex ← i. screenimage add: (((document◦i) "copy")
													translate: 0⌾0 - (0⌾delta))
					] ⇑ lastindex
		].
	
]
classInit 
"  DocumentEditor classInit.    "
[	documentmenu ← Menu new string:
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
	jumpcursor ← Cursor new fromtext: '
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
1111111111111111' offset: 2⌾1.
]


defaultdocument 
[
	self defaultdocument: 'document'
]
defaultdocument: name | defaultdocument run r textimage f im dot heading head text char b image row
[" name is a string"
	defaultdocument ← Document new origin: 0⌾0
									extent: (user screenrect) extent.
	defaultdocument name: name.
	defaultdocument xgrid: DefaultTextStyle tab.
	defaultdocument ygrid: DefaultTextStyle lineheight.
	
	textimage ← BorderedText new.
	textimage text: 'Text that is bordered' width: 200.
	defaultdocument addform: textimage andpath: 0⌾0.

	textimage ← TextImage new.
	textimage text: 'This is a paragraph' width: 600.
	defaultdocument addform: textimage andpath: 0⌾0.
	
	b ← BitImage new fromrectangle:
				(Rectangle new origin: 0⌾200 extent: 100⌾100).
	defaultdocument insert: b.
	head ← Set new default.
	text ← 'HEADING'.
	for⦂ char from: text do⦂ [ head add: char ].
	heading ← Heading new origin: 0⌾400 index: 9 charactercodes: head
		currentcharacter: 0.
	defaultdocument insert: heading.
	"defaultdocument insert: CurveIdiom new init."
	self init: defaultdocument.
]
init: document | i 
	["This is the paragraph (subimage) level document editor."
	self fixedwidthfromuser: document width.
	documentwindow ← Rectangle new origin: document rectangle origin
									extent: (document width) ⌾ (self frame height).
	self buildscreenimage.
	selection ← false.
	user topWindow leave.
	self takeCursor; enter.
	user restartup: self
	]

DEFAULT EVENT RESPONSES 
close
[
	XeqCursor show.
	document close.
	document ← nil.
	screenimage ← Vector new: 0.
	NormalCursor show
]
enter [selection ← false. self show]
hardcopy
	["write a press file and hardcopy this document"
	self leave.
	self top.
	document hardcopy
	]
kbd | c x y
[
	   c ← user kbd. 
 	c = 120⇒
 		[ user clearshow: 'x gridding is '. document xgrid print.
 		user cr.
 		document xgrid: (x←
 		(user request: 'x gridding . . . ') asInteger).
		screenimage xgrid: x. 
 		] 
 	c = 121⇒
 		[ user clearshow: 'y gridding is '. document ygrid print.
 		user cr.
 		document ygrid: (y←
 		(user request: 'y gridding . . . ') asInteger).
		screenimage ygrid: y.
 		] 
]

leave
	[
	document ≡ nil ⇒ []
	[selection⇒ [ selection highlite]].
	self update ; buildscreenimage.
	selection ← false.
	]
print 
	["write a press file and hardcopy this document"
	document hardcopy
	]
redbug | pt rect newrect start t
	[pt ← user mp.
	start←pt.
	rect←newrect←(Rectangle new origin: start corner: start).
	[selection⇒ [selection highlite. self deselect. selection ← false.]]. 
	while⦂ user anybug do⦂
		[rect←newrect.
		rect comp.
		t←user mp.
		newrect←(Rectangle new origin: (start min: t) corner: (start max: t)).
		rect comp].
	(rect width < 10) ⇒
		[
		selection ←
			screenimage smallestsubimageat:  pt- screenimage origin.
		selection⇒
				[
				selection  translate: screenimage origin.
				selection edit: screenimage.
				selection translate: ((0⌾0) - screenimage origin).
				selection ← false.
				]
		]
		rect origin ← screenimage griddedpoint: (rect origin).
		selection ← screenimage subimageswithin: 
									(rect translate: ((0⌾0)- screenimage origin)).
		selection ⇒
		[selection translate: screenimage origin ; highlite]
	]
yellowbug | pt
	[
	documentmenu bug
		=1⇒[self move];
		=2⇒[self delete];
		=3⇒[self place];
		=4⇒[self cut];
		=5⇒[self paste];
		=6⇒[self copyselection];
		=7⇒[self top];
		=8⇒[self bottom];
		=9⇒[self jump];
		=10⇒[self addspace];
		=11⇒[self deletespace];
		=12⇒[self deselect. selection ← false. self show]
	
	]

FRAMING 
newframe
	[self update.
	self fixedwidthfromuser: document width.
	self buildscreenimage ; show.
	]
show [
	XeqCursor show.
	self outline .
	growing⇒[]
	titleframe put: (Paragraph new text: self title runs: titlerun alignment: 0)
		at: frame origin+titleloc; window outline; show.
	screenimage  white.
	screenimage displayat: 0⌾0 effect: 1 clippedBy: self frame.
	selection ⇒ [ selection boxcomp].
	NormalCursor show

	]
title [ ⇑ document name] 

EDITING 
addspace | image i k r delta
	["add whitespace to the document  ."
	self update. selection ← false.
	r ← document rectanglefromuser.
	i ← (document indexofsubimagebelow: (r top- screenimage top) + documentwindow top).
	[i⇒ 	[
			delta ← r height.
			for⦂ k from: i to: document length do⦂
				[
				(document◦k) translate: (0⌾(delta))
				].
		document resize
		]
			].
	self buildscreenimage ; show.
	]
bottom |  i delta 
	["translate the current selection to the bottom of the window and update the document to reflect any changes in the subimages which are scrolled out of the screenimage."
	selection⇒
		[
		delta ← (selection rectangle corner - screenimage rectangle corner).
		self update. selection ← false.
		documentwindow translate: (0⌾ (delta y)). "move window on document"
		self buildscreenimage ; show. 
			"reconstruct screen image, including reestablishing  first and last indices"
		]
		self update.
		documentwindow ← Rectangle new origin:
											(document rectangle corner-self frame height)
										extent: (document width) ⌾ (self frame height).
		self buildscreenimage ; show.
	]

closeScrap
	[
	scrap ≡ nil⇒ []
	scrap close
	]
copy | 
	["copy the selection and put it in scrap"
	self copyselection
	]
copyselection | 
	["copy the selection and put it in scrap"
	selection⇒
		[
		XeqCursor show.
		self closeScrap.
		scrap ← selection copy.
		NormalCursor show
		]
	frame flash
	]
cut | t 
	["delete subimage (paragraph) from the screenimage and save it in the scrap"
	selection⇒
		[
		XeqCursor show.
		self closeScrap.
		scrap ← selection.
		self update.
		for⦂ t from: selection do⦂
			[
			document bubbledelete: t.
			].
		selection ← false.
		self buildscreenimage ; show.
		NormalCursor show
		]
	frame flash
	]
delete | t
	["delete subimage (paragraph) from the screenimage and save it in the scrap"
	selection⇒
		[
		XeqCursor show.
		self closeScrap.
		scrap ← selection.
		selection highlite ;  display: 3.
		for⦂ t from: selection do⦂
		[screenimage delete: t
		]. 
		selection ← false.
		NormalCursor show.
		]
	frame flash
	]
deletespace | image i k r delta
	["delete whitespace from the document  ."
	self update. selection ← false.
	r ← document rectanglefromuser.
	i ← (document indexofsubimagebelow: (r top - screenimage top) + documentwindow top).
	[i⇒ 	[
			delta ← r height.
			for⦂ k from: i to: document length do⦂
				[
				(document◦k) translate: (0⌾(0-delta))
				].
		document resize
		]
			].
	self buildscreenimage ; show.
	]
deselect | t
		[selection⇒ [
						selection translate: ((0⌾0) - screenimage origin).
						for⦂ t from: selection do⦂
							[t translate: selection origin
							].

						 ]
		] 
editTitle
	[titlepara←document name asParagraph.
	super editTitle.
	document name: titlepara text]
jump
	|  y deltay yprime deltayprime rect pt newY scal r
	[user waitnobug.
	XeqCursor show.
	self update.
	y ← document height.
	yprime ← frame height.
	deltay ← (documentwindow origin y) - (document  origin y).
	scal←yprime asFloat/y.
	deltayprime ← (scal*deltay) asInteger.
	pt ← ((screenimage leftside+((1.0-scal)*frame width/2))⌾((screenimage top) + deltayprime)).
	document quickDisplayAt: 0⌾0 scale: scal offset: (frame minX + ((1.0-scal)*frame width/2))⌾frame minY.
	rect←0⌾0 rect: 1⌾1.
	rect origin ← pt.
	rect corner x←pt x +(scal*frame width) asInteger.
	rect corner y←pt y + (scal*frame height) asInteger.
	user cursorloc←pt.
	OriginCursor show.
	user waitbug.
	[user redbug
		⇒	[rect comp.
			while⦂ user redbug do⦂
				[r←rect copy.
				newY←user mp y.
				[newY<(frame minY- rect height) ⇒ [newY←frame minY-rect height]].
				[newY>frame maxY ⇒ [newY←frame maxY]].
				rect translateto: pt x⌾newY.
				r comp.
				rect comp].
			rect comp.
			XeqCursor show.
			deltayprime ← newY - (frame origin y).
			deltay ← y*deltayprime/yprime.
			documentwindow translateto: (0⌾deltay).
			selection ← false]].
	self buildscreenimage.
	self show.
	NormalCursor show]
move | pt t
	["used to place subimages (paragraphs) in the Image."
	selection
		⇒	[user waitnobug.
			OriginCursor show.
			user waitbug. 
			selection highlite ; displayat: 0⌾0 effect: 3 clippedBy: frame.
			while⦂ user redbug do⦂
				[pt ←screenimage mp + screenimage rectangle origin.
				selection translateto: pt.
				selection blink].
			XeqCursor show.
			selection displayat: 0⌾0 effect: 1 clippedBy: frame .
			self deselect.
			selection ← false.
			NormalCursor show]
		frame flash]
paste | pt t

["add the subimage (paragraph) in the scrap to the screenimage."
		[
		selection⇒ [selection highlite]].
		self update.
		selection ← scrap copy.
		OriginCursor showwhile⦂
		[
		user waitbug.
		until⦂ user nobug do⦂
			[
			pt ←screenimage mp + screenimage rectangle origin.
			selection  translateto: pt ; blink
			]
		selection displayat: 0⌾0 effect: 1 clippedBy: self frame .
		].
	self deselect.
	for⦂ t from: selection do⦂
		[
		document bubbleinsert: (t translate: documentwindow origin).
		].
	selection ← false.
	self buildscreenimage ; show.
	]
place | pt tempimage t

["add the image in the scrap to the screenimage."
	[selection⇒[selection highlite]].
	self deselect.
	selection ← scrap copy.
		OriginCursor showwhile⦂
		[
		user waitbug.
		until⦂ user nobug do⦂
			[
			pt ←screenimage mp + screenimage rectangle origin.
			selection translateto: pt ; blink
			]
		].
	selection  displayat: 0⌾0 effect: 1 clippedBy: self frame.
	self deselect.
	for⦂ t from: selection do⦂
		[
			screenimage add: t.
		].
	selection ← false.
	
	]
top |  i delta 
	["translate the current selection to the top of the window and update the document to reflect any changes in the subimages which are scrolled out of the screenimage."
	selection⇒
		[
		delta ← (selection rectangle origin - screenimage rectangle origin).
		self update. selection ← false.
		documentwindow translate: (0⌾ (delta y)). "move window on document"
		 self buildscreenimage ; show. 
			"reconstruct screen image, including reestablishing  first and last indices"
		]
	self update.
	documentwindow ← Rectangle new origin: document rectangle origin
									extent: (document width) ⌾ (self frame height).
	self buildscreenimage ; show.
	]

update |  i 
	["update the document to reflect any changes in the subimages ."
	XeqCursor topage1.
		[selection⇒	[self deselect]].
		document deleteI: firstindex to: lastindex. "update document"
		for⦂ i to: screenimage length  do⦂ 
			[document insert: 
							(screenimage◦i translate: (0⌾documentwindow origin y)).
			].
	document resize.
	NormalCursor topage1.
	]


SystemOrganization classify: ↪DocumentEditor under: 'FPI Packages'.
DocumentEditor classInit

"Heading" 
Class new title: 'Heading'
	subclassof: Image
	fields: 'formset index charactercodes currentcharacter'
	declare: 'headingmenu ';
	asFollows 

This class has not yet been commented

INIT 
classInit 
	["menu for the Heading edits."

headingmenu ← Menu new string:
'right
left
up
down
font
'.

	]
origin: origin formset: formset currentcharacter: currentcharacter
	["initilization of a Heading (used in copy)"
	[formset is: Integer⇒ [ formset ← FormSet new fromstyle:
						DefaultTextStyle styleindex: formset.]].
	self origin: origin extent: (200⌾formset height).
	]
origin: origin index: index charactercodes: charactercodes
		currentcharacter: currentcharacter | char w delta
	["initilization of a Heading (used in copy)"
	formset ← FormSet new fromstyle:
						DefaultTextStyle styleindex: index.
	[ nil ≡ charactercodes ⇒ [ charactercodes ← Set new default]].
	self origin: origin extent: (200⌾formset height).
	w ← 0.
	delta ← origin copy.
	self translate: (0⌾0 - delta).		
	for⦂ char from: charactercodes do⦂
		[	char ← formset asForm: char.
			self addpath: w⌾0 andform: char.
			w ← w + char width.
		]
	self translate: delta.
	⇑ self
	]

EDIT 
down | delta
	["move the current character down one bit."
	self boxcomp.
	(self◦currentcharacter) translate: (0⌾1).
	delta ← origin copy.
	self translate: (0⌾0 - delta) ; resize ; translate: delta.
	self white ; display: 1.
	self boxcomp.
	]
edit: parentimage | pt 
	["Simple Heading (line) editor for now."
	self display: 0.
	until⦂ 1=2 do⦂ "forever for now"
		[
		user kbck⇒
		[ self typein ]
		user yellowbug ⇒	[
			headingmenu bug
				=1⇒	[self right]; "move current character right one bit"
				=2⇒	[self left]; "move current character left one bit"
				=3⇒	[self up]; "move current character up one bit"
				=4⇒	[self down]; "move current character down one bit"
				=5⇒	[self newfont] "change fonts"
									]
		user redbug ⇒ 		[(rectangle has: (pt← user mp))⇒
										[pt ← pt - (rectangle origin).
										currentcharacter← self indexofsubimageat: pt.
										currentcharacter⇒
											[
											self◦currentcharacter displayat: self origin
											effect: 2 clippedBy: user screenrect.
											self◦currentcharacter displayat: self origin
											effect: 2 clippedBy: user screenrect.
											]
										]
										⇑ self
									]
		user bluebug ⇒ 		[
									⇑ self.
									] "exit back to the parentimage" 
		]
	]
left | i delta
	["move the current character and all those to the right of it to the left one bit."
	self boxcomp.
	for⦂ i from: (currentcharacter to: self length) do⦂
		[ (self◦i) translate: (0⌾0) -(1⌾0) ].
	delta ← origin copy.
	self translate: (0⌾0 - delta) ; resize ; translate: delta.
	self white ; display: 1.
	self boxcomp.
	]
newfont | w char charcount delta i
	[
	index ←(user request: 'index of new font . .  ' ) asInteger.
	formset ← FormSet new fromstyle: DefaultTextStyle styleindex: index.
	self white.
	for⦂ i to: position do⦂ [ self◦i ← nil ].
	position ← 0.
	w ← 0.
	charcount ← 0.
	delta ← origin copy.
	self translate: (0⌾0 - delta).		
	for⦂ char from: charactercodes do⦂
		[nil≡ char ⇒ []
		char ← formset asForm: char.
		char displayat: delta+ (w⌾0) effect: 0 clippedBy: user screenrect.
		self addpath: w⌾0 andform: char.
		w ← w + char width.
		charcount ← charcount+1.
		]
	self resize.
	self translate: delta.
	⇑ self
	]
right | i delta
	["move the current character and all those to the right of it to the right one bit."
	self boxcomp.
	for⦂ i from: (currentcharacter to: self length) do⦂ [ (self◦i) translate: (1⌾0) ].
	delta ← origin copy.
	self translate: (0⌾0 - delta) ; resize ; translate: delta.
	self white ; display: 1.
	self boxcomp.
	]
typein | w char charcount delta i
	[
	self white.
	for⦂ i to: position do⦂ [ self◦i ← nil ].
	position ← 0.
	w ← 0.
	charcount ← 0.
	charactercodes ← Set new default.
	delta ← origin copy.
	self translate: (0⌾0 - delta).		
	until⦂ (char ← user kbd) = 13 do⦂
		[			
			(char = 8) ⇒"back space" 
					[charcount ≠  0 ⇒ [ 
							 					w ← w - ( (self◦charcount) width).
												(self◦charcount) white.
												self deleteimage: charcount.
												charactercodes deleteI: charcount.
												charcount ← charcount -1.
												]
					]
			charactercodes add: char.
			char ← formset asForm: char.
			char displayat: delta+ (w⌾0) effect: 0 clippedBy: user screenrect.
			self addpath: w⌾0 andform: char.
			w ← w + char width.
			charcount ← charcount+1.
		]	
	self resize.
	self translate: delta.
	⇑ self
	]
up | delta
	["move the current character up one bit."
	self boxcomp.
	(self◦currentcharacter) translate: (0⌾0) - (0⌾1).
	delta ← origin copy.
	self translate: (0⌾0 - delta) ; resize ; translate: delta.
	self white ; display: 1.
	self boxcomp.
	]

SYSTEM 
copy | h i
	[
	h← Heading new origin: (rectangle origin) copy index: index charactercodes: (charactercodes copy)
		currentcharacter: currentcharacter copy.
	h rectangle: rectangle copy.
	for⦂ i to: self length do⦂ 
		[
		h add: (self◦i) copy 
		]
	⇑ h
	]
fromPress: press value:  s | numberofcharacters  i 
	["retrieves and builds an instance of class Heading from a press file"
	numberofcharacters← s nextword.
	origin ← s nextPoint.
	index ← s nextword.
	charactercodes ← Set new default.

	for⦂ i to: numberofcharacters do⦂
				[ charactercodes add: s nextword ]	
	⇑ self origin: origin index: index charactercodes: charactercodes
		currentcharacter: 1
	]
hideData: complete | s i
	["stores an instance of class Heading on a press file"
	s ← Stream new of: (String new: 100).
	s nextword← self length; "number of characters"
		nextPoint← origin;
		nextword ← index.
	for⦂ i to: self length do⦂ [s nextword ← charactercodes◦i].
	⇑ s contents]
pressCode [⇑2]
presson: press in: r | hs y t i pressscale [
	(hs  ← press scale*self height) > r height⇒ [
		"not enough room left on current page.
		assume for now that it will at least fit on an entire page"
		⇑ self]

	self hidePress: press complete: ¬1.
	pressscale ← press scale.
	press selectfont: (press fontindex: 16*index style: DefaultTextStyle) - 1.

	for⦂ i to: self length  do⦂
		[
		press setx:  r leftside + ((self◦i) leftside*pressscale).
		press sety: r bottom - ((self◦i) top*pressscale).
		press showchar: (charactercodes◦i)
		].
	⇑ r bottom - ((self height)*pressscale)]
printon: strm | t [
	strm append: 'a Heading '.
	]

SystemOrganization classify: ↪Heading under: 'FPI Packages'.
Heading classInit
