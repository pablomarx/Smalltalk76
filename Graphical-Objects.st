'From Smalltalk 5.5k XM November 24 on 22 November 1980 at 2:57:08 am.'
\g
"Cursor"l15000z20000\gbf5 
Class new title: 'Cursor'
	subclassof: Object
	fields: 'bitstr offset'
	declare: '';
	asFollows\gbf5 

I am a 16 x 16 dot matrix suitable for use as the Alto hardware cursor\gi

Initialization\gbf5 
fromString: bitstr [self fromString: bitstr offset: 00]\gb19B
fromString: bitstr offset: offset\gb
fromtext: str [self fromtext: str offset: 00]\gb14B
fromtext: str offset: offset | i s n c [
	"Not great, but compatible with printon."
	bitstr _ String new: 32.
	s _ str asStream.  s next.
	for i to: 16 do
		[n _ 0.
		while ((c _ s next)=060 or c=061) do
			[n _ (n lshift: 1)+(c-060)].
		bitstr word: i _ n]]\gb29B13i41I
offset: offset\gb

Hardware cursor\gbf5 
frompage1		"load this cursor from the hardware locations"
	[bitstr _ String new: 32.
	BitBlt new forCursor; sourcebase_ 0431; destbase _ bitstr; copy: storing]\gb11Bi46I

Conversion\gbf5 
hardcopy: pf ["use current cursor position"
	self hardcopy: pf at: user mp - offset]\gb13B
hardcopy: pf at: loc | rect [
	"print cursor image at some point location into a presssfile"
	rect _ loc extent: 1616.
	pf setp: (pf transrect: rect) origin; bitmap: rect bits: bitstr]\gb21B
printon: strm | i
	[strm append: 'Cursor new fromtext: '''.
	for i to: 16 do
		[strm cr.
		(bitstr word: i) printon: strm base: 2]
	strm append: ''' offset: '; print: offset; append: '.']\gb14B

Aspects\gbf5 
offset [offset]\gb7B

Showing\gbf5 
show	 [
	"copy this cursor into the page 1 hardware locations"
	BitBlt new forCursor; destbase_ 0431; sourcebase _ bitstr; copy: storing.
	user currentCursor: self

	"the following statement will copy back if we ever need to"
	"BitBlt new forCursor; sourcebase_ 0431; destbase _ bitstr; copy: storing"]\gb6B3i55I
showwhile expr | oldcursor value [
	oldcursor _ user currentCursor.
	self show.
	value _ expr eval.
	oldcursor show.
	value]\gb16B

Compatibility\gbf5 
topage1	[self show]\gb8B
\g
SystemOrganization classify: Cursor under: 'Graphical Objects'.\g

"HalfToner"l15000z20000\gbf5 
Class new title: 'HalfToner'
	subclassof: Object
	fields: 'lines pixelsPerLine black white errorString rect vect inpix outpix nlines npix strm inset'
	declare: '';
	asFollows\gbf5 

This class converts ais image files to screen bits\gi

AIS to Bits\gbf5 
decode: str using: s | i j k x cascadeRight cascadeDiag val error r msk masks
	["Change 8-bit grey from str filling s"
	 masks_(128 64 32 16 8 4 2 1).
	 cascadeRight_0.
	 cascadeDiag_errorString1.
	 i_msk_j_k_1. x_0-outpix.
	 s1_0.
	 for i to: pixelsPerLine do
		[while x<0 do
			[val_(stri)-black.
			[(error_cascadeRight-val)0
				["print Black" sj_masksmsk+(sj). (error>white)[error_white] ]
				"print White" (error_error+white)<0[error_0] ].
			error_error/2.
			val_error/2.
			errorStringk_cascadeDiag+val.
			cascadeRight_errorString(k+1)+error.
			cascadeDiag_val.
			[(msk_msk+1)>8[msk_1. j_j+1. sj_0] ].
			x_x+inpix. k_k+1].
		x_x-outpix].
	s]  primitive: 109\gb21B60i37I226i13I56i13I246b2B
doFile | str i s2 r y skipsum
	[str_String new: pixelsPerLine.
	r_00 rect: (pixelsPerLine*outpix/inpix)1. r moveto: rect origin copy.
	s2_String new: 1+((pixelsPerLine*outpix)/(8*inpix)).
	vect_Vector new: lines. strm reset; position_2048+(inset y*npix). "crop top"
	i_1. y_0-outpix. skipsum_0.
	while ilines do
		[skipsum_skipsum+inset x. "inset left"
		strm skip: skipsum. skipsum_0. "do all tallied skips prior to next read"
		strm into: str endError: true.
		r bitsFromString: (self decode: str using: s2).
		skipsum_skipsum+npix-(pixelsPerLine+inset x).
		r origin y_r origin y+1. r corner y_r corner y+1.
		[(y_y+inpix)0 "next line?"
			[i_i+1. y_y-outpix.
			while (y0 and ilines) do [i_i+1. y_y-outpix. skipsum_skipsum+npix] ]
			skipsum_skipsum-npix] ]. "not next line"
	strm close]\gb7B250i10I78i12I34i41I202i12I129i15I
intoPress: p file: f | outrect "Creates an external file reference"
	[outrect_p transrect: rect.
	p setp: (outrect origin); dots
		[p setcoding: 8 "byte samples" dots: npix lines: nlines;
		setmode: 3 "to right and to bottom of page";
		setwindowwidth: pixelsPerLine height: lines
			skipdots: (inset x) skiplines: (inset y);
		setsizewidth: (outrect width) height: (outrect height);
		dotsfromAIS: f] ]
"
	|p. p_dp0 pressfile: 'pix.press'.
	p pictureinit. (HalfToner new test) intoPress: p file: 'Rolfup.AIS'. p close.
"\gb21B10i36I81i14I40i32I
setup | i r1 r2 inset done"set up default paramsHalfToner new doFile."
	[user print: 'Black? (0-255)'. black _ user read asVector1.
	 user print: 'White? (0-255)'. white _ user read asVector1.
	 white _ white-black max: 255.
	 [white>255[white _ 255]].
	 r1 _ 00 rect: pixelsPerLinelines. 
	 user print: 'Position whole '.
	 until user anybug do [r1 moveto: user mp. r1 comp. r1 comp].
	 user waitnobug. r1 comp. "show whole"
	 user print: ' Show cropping '.
	 r2 _ Rectangle new fromuser intersect: r1. r1 comp.
	 inset _ r2 origin - r1 origin. 
	 pixelsPerLine _ pixelsPerLine min: r2 width.
	 lines _ lines min: r2 height.
	 done _ false.
	until done do
	 [user print: ' Position it '.
	 rect _ Rectangle new fromuser.
	 [rect width>r2 width["blowup" inpix _ 8. outpix _ (8*rect width/r2 width)]
		"shrink" outpix _ 8. inpix _ (8*r2 width/rect width)].
	 rect extent _ r2 extent * outpix / inpix.
	 rect comp. user print: 'ok? (redbug)'.
	 until user anybug do []. [user redbug[done _ true]]. user waitnobug.
	 rect comp].
	 errorString _ String new: pixelsPerLine*outpix / inpix+1.
	 for i to: errorString length do [errorStringi _ 0].
	 inset "return inset"
	]\gb26B

Init/Access\gbf5 
nlines [nlines]\gb7B1b7B
npix [npix]\gb5B1b5B
rect [rect]\gb5B1b5B
rect_rect\gb
setup: strm | inrect croprect
	[strm readonly.
	(strm word: 2)1024 or (strm word: 9)8[user notify: 'bad file']
	nlines_lines_strm word: 4. npix_pixelsPerLine_strm nextword.
	black_0. white_255.
	inrect_00 rect: pixelsPerLinelines. inrect moveto: rect origin.
	inrect usermove; comp. "show whole"
	croprect_rect copy. croprect moveto: inrect origin copy. croprect maxstretch: inrect.
	croprect userstretch: inrect. inrect comp.
	inset_croprect origin-inrect origin.
	pixelsPerLine_croprect width. lines_pixelsPerLine*rect height/rect width.
	[rect width>pixelsPerLine
		["blowup" inpix_32. outpix_(32*rect width/pixelsPerLine)]
		"shrink" outpix_32. inpix_(32*pixelsPerLine/rect width)].
	errorString_String new: pixelsPerLine*outpix/inpix+2.
	errorString all_0]\gb12B277i12I276i8I51i8I
strm [strm]\gb5B1b5B
test | files
	[files_(dp0 filesMatching: '*.ais.') sort.
	files empty[user notify: 'no .ais files on disk']
	strm_dp0 file: (files(Menu new stringFromVector: files) zbug). strm readonly.
	rect_Rectangle new usersize. self setup: strm; doFile]
"
HalfToner new test.
"\gb5B
\g
SystemOrganization classify: HalfToner under: 'Graphical Objects'.\g

"Turtle"l15000z20000\gbf5 
Class new title: 'Turtle'
	subclassof: Object
	fields: 'pen ink width dir x xf y yf frame'
	declare: '';
	asFollows\gbf5 

Turtles can crawl around the screen drawing and printing at any angle.
Dont forget to send them the message init before any drawing commands.\gi

Initialization\gbf5 
erase
	[frame clear: white]\gb7B
frame [frame]\gb6B
frame: frame\gb
init
	[pen _ width _ 1.
	x_ y_ xf_ yf_ 0.
	frame _ user screenrect.
	self black; home]\gb6B

Pen Control\gbf5 
black [ink _ black]\gb6B
color: ignored  "Only implemented for PressTurtle"\gb16B
ink: ink\gb
pen: pen\gb
pendn
	[pen _ 1]\gb7B
penup
	[pen _ 0]\gb7B
white [ink _ white]\gb6B
width [width]\gb6B
width: width\gb
xor [ink _ 2]\gb4B

Drawing\gbf5 
fillIn expr [expr eval]  "Only implemented for PressTurtle"\gb13B
go: length [user croak] primitive: 53\gb11B
goto: pt
	[pt x is: Integer[user croak]
	self goto: pt x asIntegerpt y asInteger] primitive: 54\gb10B
home		
	[self up; place: frame center-frame origin. xf_ yf_ 0100000]\gb8B
place [xy]\gb6B
place: pt | p
	[p_ pen. pen_ 0. self goto: pt. pen_ p]\gb10B3b2B
pointAt: pt | diff "change direction so turtle points at pt."
	[diff _ (pt - (self place)).
	 dir _ ((diff theta) asInteger)]

\gb12B
stretchto: pt | t old
	[t _ Turtle init frame: frame. old _ xy. 
	t xor; place: old; goto: pt; place: old; goto: pt]\gb14B
turn: angle
	[dir_ dir+angle\360]\gb13B
up	 [dir _ 270]		"Point toward top of screen"
\gb4B12b1Bi28bI

Text\gbf5 
put: char font: font		"char=ascii Integer, font=font bits (String)"
	[user croak] primitive: 56\gb20i2B45bI2B
show: str font: font | a f		"str=text (String), font=font number (0-9)"
	[f_ DefaultTextStyle fonts(font+1).
	for a from: str do
		[self put: a font: f]]\gb21B7i43I

Examples\gbf5 
dragon: n
	[n=0[self go: 10]
	n>0[self dragon: n-1; turn: 90; dragon: 1-n]
			self dragon: 1-n; turn: 90; dragon: 1+n]
"
Turtle init dragon: 8
"\gb11B
filberts: order side: s | i n2
	[n2_ 1 lshift: order-1.
	self penup; go: 0-n2*s; pendn.
	for i to: 4 do
		[self color: i-1*40.
		self fillIn [self hilbert: order side: s; go: s; hilbert: order side: s; go: s].
				self black; hilbert: order side: s; go: s; hilbert: order side: s; go: s.
		self penup; go: n2-1*s; turn: 90; go: n2*s; turn: 180; pendn]]
"
Turtle init erase filberts: 3 side: 10.

user displayoffwhile
	[PressTurtle new init: 'try.press'; filberts: 4 side: 10; close].
"\gb24B
hilbert: n side: s | a m
	[n=0[self turn: 180]
	[n>0[a_90. m_n-1] a_90. m_n+1].
	self turn: a; hilbert: 0-m side: s; turn: a.
	self go: s; hilbert: m side: s;
		turn: 0-a; go: s; turn: 0-a;
		hilbert: m side: s; go: s.
	self turn: a; hilbert: 0-m side: s; turn: a]
"
Turtle init hilbert: 3 side: 4
"
\gb19B
hilberts: n | i s
	[self penup; go: 128; pendn.
	for i to: n do
		[s_ 256 lshift: 0-i.  self color: n-i*40; width: n-i+1.
		self penup; go: 0-s/2; turn: 90; go: s/2; turn: 90; pendn.
		self hilbert: i side: s; go: s; hilbert: i side: s; go: s]]
"
Turtle init erase hilberts: 5.

user displayoffwhile
	[PressTurtle new init: 'try2.press'; hilberts: 4; close].
"\gb12B
mandala: npoints diameter: d | l points i j
	[l_ (3.14*d/npoints) asInteger.
	self home; penup; turn: 90; go: d/2; turn: 90; go: 0-l/2.
	points_ Vector new: npoints.
	for i to: npoints do
		[pointsi_ self place.
		self go: l; turn: 360/npoints].
	self pendn.
	for i from: npoints/2 to: 1 by: 1 do
		[self color: (npoints/2)-i*20\250.
		for j to: npoints do
			[self place: pointsj; goto: points(j+i-1\npoints+1)]]]
"
Turtle init mandala: 30 diameter: 400

user displayoffwhile
	[PressTurtle new init: 'try.press'; mandala: 30 diameter: 500; close.]
"\gb29B
spiral: n angle: a | i
	[for i to: n do
		[self color: i*2\256; go: i; turn: a]]
"
 Turtle init spiral: 200 angle: 89; home; spiral: 200 angle: 89.

 user displayoffwhile [(PressTurtle new init: 'try.press')
		spiral: 403 angle: 89;
		home; spiral: 403 angle: 89; close.]
 "\gb19B
\g
SystemOrganization classify: Turtle under: 'Graphical Objects'.\g

"PressTurtle"l15000z20000\gbf5 
Class new title: 'PressTurtle'
	subclassof: Turtle
	fields: 'file fplace fdir filling'
	declare: '';
	asFollows\gbf5 

I work with Pressfile to print high resolution pictures.
All inputs can be floating point for high resolution.
Complexity is limited to about 2k lines until multiple entity lists\gi

Initialization\gbf5 
close [file page. file close]\gb6B
init: name 
	[file _ (dp0 pressfile: name).
	filling_ false.
	file pictureinit. self black.
	super init]\gb13B
initwithfile: name 
	[file _ name.
	filling_ false.
	self black.
	super init]\gb21B

Pen Control\gbf5 
black 
	[file brightness: 0. super black]\gb8B
blue [self color: 160]\gb5B
color: h [file hue: h; brightness: 255; saturation: 255]\gb9B
cyan [self color: 120]\gb5B
green [self color: 80]\gb6B
magenta [self color: 200]\gb8B
place [fplace]\gb6B
red [self color: 0]\gb4B
up [dir_ 270. fdir_ 270.0]\gb3B
white 
	[file brightness: 255.
	file saturation: 0.
	super white]\gb8B
yellow [self color: 40]\gb7B

Drawing\gbf5 
fillIn expr		"Code in expr must describe a closed figure"
	[filling_ true.
	file object expr eval atScreen: fplace.
	filling_ false]\gb14Bi44bI2B
go: dist | old
	[self goto: fplace + 
		(([fdir\90.0=0.0		"optimize horiz and vert lines"
			[fdir/90.0=0[1.00.0];
						=1[0.01.0];
						=2[1.00.0];
						=3[0.01.0]]
		fdir asRadians asDirection])*dist)]\gb9B5b2B
goto: p | old
	[old_ fplace.
	fplace _ p x asFloat  p y asFloat.
	super goto: fplace x round  fplace y round.
	filling[file objectGotoScreen: fplace pen: pen]
	pen=1[file drawlinefromscreen: old to: fplace width: 0.46875*width]]\gb8B5b2B
turn: angle [fdir_ fdir+angle\360.0]\gb12B
\g
SystemOrganization classify: PressTurtle under: 'Graphical Objects'.\g 