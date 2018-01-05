'From Smalltalk 5.5k XM November 24 on 22 November 1980 at 2:57:08 am.'

"Cursor" 
Class new title: 'Cursor'
	subclassof: Object
	fields: 'bitstr offset'
	declare: '';
	asFollows 

I am a 16 x 16 dot matrix suitable for use as the Alto hardware cursor

Initialization 
fromString: bitstr [self fromString: bitstr offset: 0⌾0]
fromString: bitstr offset: offset
fromtext: str [self fromtext: str offset: 0⌾0]
fromtext: str offset: offset | i s n c [
	"Not great, but compatible with printon."
	bitstr ← String new: 32.
	s ← str asStream.  s next.
	for⦂ i to: 16 do⦂
		[n ← 0.
		while⦂ ((c ← s next)=060 or⦂ c=061) do⦂
			[n ← (n lshift: 1)+(c-060)].
		bitstr word: i ← n]]
offset: offset

Hardware cursor 
frompage1		"load this cursor from the hardware locations"
	[bitstr ← String new: 32.
	BitBlt new forCursor; sourcebase← 0431; destbase ← bitstr; copy: storing]

Conversion 
hardcopy: pf ["use current cursor position"
	self hardcopy: pf at: user mp - offset]
hardcopy: pf at: loc | rect [
	"print cursor image at some point location into a presssfile"
	rect ← loc extent: 16⌾16.
	pf setp: (pf transrect: rect) origin; bitmap: rect bits: bitstr]
printon: strm | i
	[strm append: 'Cursor new fromtext: '''.
	for⦂ i to: 16 do⦂
		[strm cr.
		(bitstr word: i) printon: strm base: 2]
	strm append: ''' offset: '; print: offset; append: '.']

Aspects 
offset [⇑offset]

Showing 
show	 [
	"copy this cursor into the page 1 hardware locations"
	BitBlt new forCursor; destbase← 0431; sourcebase ← bitstr; copy: storing.
	user currentCursor: self

	"the following statement will copy back if we ever need to"
	"BitBlt new forCursor; sourcebase← 0431; destbase ← bitstr; copy: storing"]
showwhile⦂ expr | oldcursor value [
	oldcursor ← user currentCursor.
	self show.
	value ← expr eval.
	oldcursor show.
	⇑value]

Compatibility 
topage1	[self show]

SystemOrganization classify: ↪Cursor under: 'Graphical Objects'.

"HalfToner" 
Class new title: 'HalfToner'
	subclassof: Object
	fields: 'lines pixelsPerLine black white errorString rect vect inpix outpix nlines npix strm inset'
	declare: '';
	asFollows 

This class converts ais image files to screen bits

AIS to Bits 
decode: str using: s | i j k x cascadeRight cascadeDiag val error r msk masks
	["Change 8-bit grey from str filling s"
	 masks←↪(128 64 32 16 8 4 2 1).
	 cascadeRight←0.
	 cascadeDiag←errorString◦1.
	 i←msk←j←k←1. x←0-outpix.
	 s◦1←0.
	 for⦂ i to: pixelsPerLine do⦂
		[while⦂ x<0 do⦂
			[val←(str◦i)-black.
			[(error←cascadeRight-val)≥0⇒
				["print Black" s◦j←masks◦msk+(s◦j). (error>white)⇒[error←white] ]
				"print White" (error←error+white)<0⇒[error←0] ].
			error←error/2.
			val←error/2.
			errorString◦k←cascadeDiag+val.
			cascadeRight←errorString◦(k+1)+error.
			cascadeDiag←val.
			[(msk←msk+1)>8⇒[msk←1. j←j+1. s◦j←0] ].
			x←x+inpix. k←k+1].
		x←x-outpix].
	⇑s]  primitive: 109
doFile | str i s2 r y skipsum
	[str←String new: pixelsPerLine.
	r←0⌾0 rect: (pixelsPerLine*outpix/inpix)⌾1. r moveto: rect origin copy.
	s2←String new: 1+((pixelsPerLine*outpix)/(8*inpix)).
	vect←Vector new: lines. strm reset; position←2048+(inset y*npix). "crop top"
	i←1. y←0-outpix. skipsum←0.
	while⦂ i≤lines do⦂
		[skipsum←skipsum+inset x. "inset left"
		strm skip: skipsum. skipsum←0. "do all tallied skips prior to next read"
		strm into: str endError: true.
		r bitsFromString: (self decode: str using: s2).
		skipsum←skipsum+npix-(pixelsPerLine+inset x).
		r origin y←r origin y+1. r corner y←r corner y+1.
		[(y←y+inpix)≥0⇒ "next line?"
			[i←i+1. y←y-outpix.
			while⦂ (y≥0 and⦂ i≤lines) do⦂ [i←i+1. y←y-outpix. skipsum←skipsum+npix] ]
			skipsum←skipsum-npix] ]. "not next line"
	strm close]
intoPress: p file: f | outrect "Creates an external file reference"
	[outrect←p transrect: rect.
	p setp: (outrect origin); dots⦂
		[p setcoding: 8 "byte samples" dots: npix lines: nlines;
		setmode: 3 "to right and to bottom of page";
		setwindowwidth: pixelsPerLine height: lines
			skipdots: (inset x) skiplines: (inset y);
		setsizewidth: (outrect width) height: (outrect height);
		dotsfromAIS: f] ]
"
	|p. p←dp0 pressfile: 'pix.press'.
	p pictureinit. (HalfToner new test) intoPress: p file: 'Rolfup.AIS'. p close.
"
setup | i r1 r2 inset done"set up default paramsHalfToner new doFile."
	[user print: 'Black? (0-255)'. black ← user read asVector◦1.
	 user print: 'White? (0-255)'. white ← user read asVector◦1.
	 white ← white-black max: 255.
	 [white>255⇒[white ← 255]].
	 r1 ← 0⌾0 rect: pixelsPerLine⌾lines. 
	 user print: 'Position whole '.
	 until⦂ user anybug do⦂ [r1 moveto: user mp. r1 comp. r1 comp].
	 user waitnobug. r1 comp. "show whole"
	 user print: ' Show cropping '.
	 r2 ← Rectangle new fromuser intersect: r1. r1 comp.
	 inset ← r2 origin - r1 origin. 
	 pixelsPerLine ← pixelsPerLine min: r2 width.
	 lines ← lines min: r2 height.
	 done ← false.
	until⦂ done do⦂
	 [user print: ' Position it '.
	 rect ← Rectangle new fromuser.
	 [rect width>r2 width⇒["blowup" inpix ← 8. outpix ← (8*rect width/r2 width)]
		"shrink" outpix ← 8. inpix ← (8*r2 width/rect width)].
	 rect extent ← r2 extent * outpix / inpix.
	 rect comp. user print: 'ok? (redbug)'.
	 until⦂ user anybug do⦂ []. [user redbug⇒[done ← true]]. user waitnobug.
	 rect comp].
	 errorString ← String new: pixelsPerLine*outpix / inpix+1.
	 for⦂ i to: errorString length do⦂ [errorString◦i ← 0].
	 ⇑inset "return inset"
	]

Init/Access 
nlines [⇑nlines]
npix [⇑npix]
rect [⇑rect]
rect←rect
setup: strm | inrect croprect
	[strm readonly.
	(strm word: 2)≠1024 or⦂ (strm word: 9)≠8⇒[user notify: 'bad file']
	nlines←lines←strm word: 4. npix←pixelsPerLine←strm nextword.
	black←0. white←255.
	inrect←0⌾0 rect: pixelsPerLine⌾lines. inrect moveto: rect origin.
	inrect usermove; comp. "show whole"
	croprect←rect copy. croprect moveto: inrect origin copy. croprect maxstretch: inrect.
	croprect userstretch: inrect. inrect comp.
	inset←croprect origin-inrect origin.
	pixelsPerLine←croprect width. lines←pixelsPerLine*rect height/rect width.
	[rect width>pixelsPerLine⇒
		["blowup" inpix←32. outpix←(32*rect width/pixelsPerLine)]
		"shrink" outpix←32. inpix←(32*pixelsPerLine/rect width)].
	errorString←String new: pixelsPerLine*outpix/inpix+2.
	errorString all←0]
strm [⇑strm]
test | files
	[files←(dp0 filesMatching: '*.ais.') sort.
	files empty⇒[user notify: 'no .ais files on disk']
	strm←dp0 file: (files◦(Menu new stringFromVector: files) zbug). strm readonly.
	rect←Rectangle new usersize. self setup: strm; doFile]
"
HalfToner new test.
"

SystemOrganization classify: ↪HalfToner under: 'Graphical Objects'.

"Turtle" 
Class new title: 'Turtle'
	subclassof: Object
	fields: 'pen ink width dir x xf y yf frame'
	declare: '';
	asFollows 

Turtles can crawl around the screen drawing and printing at any angle.
Dont forget to send them the message init before any drawing commands.

Initialization 
erase
	[frame clear: white]
frame [⇑frame]
frame: frame
init
	[pen ← width ← 1.
	x← y← xf← yf← 0.
	frame ← user screenrect.
	self black; home]

Pen Control 
black [ink ← black]
color: ignored  "Only implemented for PressTurtle"
ink: ink
pen: pen
pendn
	[pen ← 1]
penup
	[pen ← 0]
white [ink ← white]
width [⇑width]
width: width
xor [ink ← 2]

Drawing 
fillIn⦂ expr [⇑expr eval]  "Only implemented for PressTurtle"
go: length [user croak] primitive: 53
goto: pt
	[pt x is: Integer⇒[user croak]
	self goto: pt x asInteger⌾pt y asInteger] primitive: 54
home		
	[self up; place: frame center-frame origin. xf← yf← 0100000]
place [⇑x⌾y]
place: pt | p
	[p← pen. pen← 0. self goto: pt. pen← p]
pointAt: pt | diff "change direction so turtle points at pt."
	[diff ← (pt - (self place)).
	 dir ← ((diff theta) asInteger)]


stretchto: pt | t old
	[t ← Turtle init frame: frame. old ← x⌾y. 
	t xor; place: old; goto: pt; place: old; goto: pt]
turn: angle
	[dir← dir+angle\360]
up	 [dir ← 270]		"Point toward top of screen"


Text 
put: char font: font		"char=ascii Integer, font=font bits (String)"
	[user croak] primitive: 56
show: str font: font | a f		"str=text (String), font=font number (0-9)"
	[f← DefaultTextStyle fonts◦(font+1).
	for⦂ a from: str do⦂
		[self put: a font: f]]

Examples 
dragon: n
	[n=0⇒[self go: 10]
	n>0⇒[self dragon: n-1; turn: 90; dragon: 1-n]
			self dragon: ¬1-n; turn: ¬90; dragon: 1+n]
"
Turtle init dragon: 8
"
filberts: order side: s | i n2
	[n2← 1 lshift: order-1.
	self penup; go: 0-n2*s; pendn.
	for⦂ i to: 4 do⦂
		[self color: i-1*40.
		self fillIn⦂ [self hilbert: order side: s; go: s; hilbert: order side: s; go: s].
				self black; hilbert: order side: s; go: s; hilbert: order side: s; go: s.
		self penup; go: n2-1*s; turn: ¬90; go: n2*s; turn: 180; pendn]]
"
Turtle init erase filberts: 3 side: 10.

user displayoffwhile⦂
	[PressTurtle new init: 'try.press'; filberts: 4 side: 10; close].
"
hilbert: n side: s | a m
	[n=0⇒[self turn: 180]
	[n>0⇒[a←90. m←n-1] a←¬90. m←n+1].
	self turn: a; hilbert: 0-m side: s; turn: a.
	self go: s; hilbert: m side: s;
		turn: 0-a; go: s; turn: 0-a;
		hilbert: m side: s; go: s.
	self turn: a; hilbert: 0-m side: s; turn: a]
"
Turtle init hilbert: 3 side: 4
"

hilberts: n | i s
	[self penup; go: 128; pendn.
	for⦂ i to: n do⦂
		[s← 256 lshift: 0-i.  self color: n-i*40; width: n-i+1.
		self penup; go: 0-s/2; turn: ¬90; go: s/2; turn: 90; pendn.
		self hilbert: i side: s; go: s; hilbert: i side: s; go: s]]
"
Turtle init erase hilberts: 5.

user displayoffwhile⦂
	[PressTurtle new init: 'try2.press'; hilberts: 4; close].
"
mandala: npoints diameter: d | l points i j
	[l← (3.14*d/npoints) asInteger.
	self home; penup; turn: ¬90; go: d/2; turn: 90; go: 0-l/2.
	points← Vector new: npoints.
	for⦂ i to: npoints do⦂
		[points◦i← self place.
		self go: l; turn: 360/npoints].
	self pendn.
	for⦂ i from: npoints/2 to: 1 by: ¬1 do⦂
		[self color: (npoints/2)-i*20\250.
		for⦂ j to: npoints do⦂
			[self place: points◦j; goto: points◦(j+i-1\npoints+1)]]]
"
Turtle init mandala: 30 diameter: 400

user displayoffwhile⦂
	[PressTurtle new init: 'try.press'; mandala: 30 diameter: 500; close.]
"
spiral: n angle: a | i
	[for⦂ i to: n do⦂
		[self color: i*2\256; go: i; turn: a]]
"
 Turtle init spiral: 200 angle: 89; home; spiral: 200 angle: ¬89.

 user displayoffwhile⦂ [(PressTurtle new init: 'try.press')
		spiral: 403 angle: 89;
		home; spiral: 403 angle: ¬89; close.]
 "

SystemOrganization classify: ↪Turtle under: 'Graphical Objects'.

"PressTurtle" 
Class new title: 'PressTurtle'
	subclassof: Turtle
	fields: 'file fplace fdir filling'
	declare: '';
	asFollows 

I work with Pressfile to print high resolution pictures.
All inputs can be floating point for high resolution.
Complexity is limited to about 2k lines until multiple entity lists

Initialization 
close [file page. file close]
init: name 
	[file ← (dp0 pressfile: name).
	filling← false.
	file pictureinit. self black.
	super init]
initwithfile: name 
	[file ← name.
	filling← false.
	self black.
	super init]

Pen Control 
black 
	[file brightness: 0. super black]
blue [self color: 160]
color: h [file hue: h; brightness: 255; saturation: 255]
cyan [self color: 120]
green [self color: 80]
magenta [self color: 200]
place [⇑fplace]
red [self color: 0]
up [dir← 270. fdir← 270.0]
white 
	[file brightness: 255.
	file saturation: 0.
	super white]
yellow [self color: 40]

Drawing 
fillIn⦂ expr		"Code in expr must describe a closed figure"
	[filling← true.
	file object⦂ expr eval atScreen: fplace.
	filling← false]
go: dist | old
	[self goto: fplace + 
		(([fdir\90.0=0.0⇒		"optimize horiz and vert lines"
			[fdir/90.0=0⇒[1.0⌾0.0];
						=1⇒[0.0⌾1.0];
						=2⇒[¬1.0⌾0.0];
						=3⇒[0.0⌾¬1.0]]
		fdir asRadians asDirection])*dist)]
goto: p | old
	[old← fplace.
	fplace ← p x asFloat ⌾ p y asFloat.
	super goto: fplace x round ⌾ fplace y round.
	filling⇒[file objectGotoScreen: fplace pen: pen]
	pen=1⇒[file drawlinefromscreen: old to: fplace width: 0.46875*width]]
turn: angle [fdir← fdir+angle\360.0]

SystemOrganization classify: ↪PressTurtle under: 'Graphical Objects'. 
