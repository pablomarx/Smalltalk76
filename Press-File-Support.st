'From Smalltalk 5.5k XM November 24 on 5 February 2037 at 11:13:21 pm.'
\g
"ParagraphScanner"l15000z20000\gbf5 
Class new title: 'ParagraphScanner'
	subclassof: Object
	fields: 'para "<Paragraph>"
		style "<TextStyle>"
		press "<PressFile> for output"
		runstrm "<Stream> of paragraph runs"
		textstrm "<Stream> of paragraph text"
		font "<WidthTable> current font"
		ascent "<Integer> max ascent"
		descent "<Integer> negative max descent"
		width "<Integer> total width"
		spaces "<Integer> number of spaces"
		rect "<Rectangle> for printing"
		tabpos "<Stream> (text position, new X position) of tabs"
		'
	declare: '';
	asFollows\gbf5 

Scans through a paragraph computing the dimensions of a partial line of text.\gi

Initialization\gbf5 
in: rect\gb
init
	[ascent _ descent _ width _ spaces _ 0. tabpos reset]\gb6B
of: para to: press style: style
	[textstrm _ '' asStream.
	runstrm _ para runs asStream.
	tabpos _ (Vector new: 10) asStream]\gb33B

Access\gbf5 
position [textstrm position]\gb9B
width [width]\gb6B

Scanning\gbf5 
backup
	[textstrm skip: 1]\gb8B
scan "Scan up to a zero-width character, back up to last blank if width exceeded"
		| maxw sp char t
			"Save state" spos slim srunpos sasc sdesc swidth ssp sfont stpos
	[textstrm end and self newrunfalse [false]
	maxw _ rect width.
	while
		[ascent _ ascent max: font ascent.
		descent _ descent max: font descent.
		sp _ font space.
		while [
			t _ font scan: textstrm until: width exceeds: maxw.
			[(char _ t1)  true [] width _ t2].
			char = 040] do
			["Save state"
				spos _ textstrm position. slim _ textstrm limit.
				srunpos _ runstrm position. stpos _ tabpos position.
				sasc _ ascent. sdesc _ descent.
				swidth _ width. ssp _ spaces. sfont _ font.
			spaces _ spaces+1.
			width _ width+sp].

		char
			[(chartrue and nilspos) and (2*ascent  rect height) [
				"Back up to just past last blank (if another line fits)"
				textstrm of: para text from: spos+1 to: slim.
				runstrm position _ srunpos. tabpos position _ stpos.
				ascent _ sasc. descent _ sdesc.
				width _ swidth. spaces _ ssp. font _ sfont.
				040]
			char]
		self newrun]
	 do [].
	false]\gb5Bi76I
tab
	[spaces _ 0.
	tabpos next _ textstrm position;
		next _ (width _ width + font tab | font tab)]\gb5B

Printing\gbf5 
printfrom: charpos aligned: align skip: n "Returns false if goes below bottom"
		| ybot a b ix iy px xs sp rs len tpos ts ntab rval ifont w ps [
	"this code basically writes the EL (entity list) for a line"
	"bottom of character -- ascent not really ascent but height"
	(ybot _ rect corner y - ascent) < rect origin y  [
		"won't fit" false]

	a _ charpos + 1.
	b _ textstrm position - n.
	[a > b  ["No text"]
	ts _ tabpos viewer.
	tpos _ ts next.

	px _ false.
	xs _ rect width - width.
	ix _ rect minX + ["left margin offset" align=2 [xs/2]; =4[xs] 0].
	"set baseline of character.  do setx before showchars"
	press sety: (iy _ ybot + descent).
	sp _ font space "kludge?".
	[align=1 ["do setspacex before showchars"] press setspacex: sp].

	rs _ (para run: a to: b) asStream.
	while (len _ rs next) do [
		press selectfont: (press fontindex: (rval _ rs next) style: style) - 1.
		b _ a+len.

		[(rval land: 4) = 0 ["no underlining"]
		"unfortunately, we must rescan this part of line to find out how wide it is"
		ifont _ press codefont: rval style: style "a WidthTable".
		ps _ (para(a to: b-1)) asStream.
		w _ true, 0.
		while w1 do [
			w _ ifont scan: ps until: w2 exceeds: rect width.
			w1 = 040 [w2 _ w2 + ifont space];
				=011 [w2 _ w2 + ifont tab | ifont tab]].

		[px ["use current x position"] press setx: ix].
		"change y position to show rectangle, then change y back again"
		press sety: iy-40; showrectwidth: w2 height: 30; sety: iy].

		ntab _ 0.
		while (tpos and tpos<b) do [	"Put out tabs"
			[tpos = a ["no text between this tab and last"]
			"put out accumulated tabs or initial x"
			[ntab> 0 [
				press skipchars: ntab; setx: px.
				ntab _ 0]
			px []
			press setx: (px _ ix)].
			press showchars: tpos-a].
			ntab _ ntab+1.
			px _ ix + ts next.
			a _ tpos+1.
			tpos _ ts next].
		[ntab> 0 [
			press skipchars: ntab;
				setx: px]
		px []
		press setx: (px _ ix)].

		[align=1 and tposfalse 		["Reset space width"
			[spaces=0 [] press setspacex: xs/spaces+sp].
			align _ 0]].
		rs end [
			"for more compactness, maybe"
			press showchars: b-a skip: n.
			ybot]
		press showchars: b-a.
		a _ b]].
	[n > 0 [
		"skip over ending blank or carriage return"
		press skipchars: n]].
	ybot]\gb42Bi36I69i58I120i9I68i9I100i18I33i52I79i29I802i14I17i33I7i37I330i19I82i27I94i41I

Private scanning\gbf5 
newrun | len pos [
	len _ runstrm next
		[pos _ textstrm position.
		textstrm of: para text from: pos+1 to: pos+len.
		font _ press codefont: (runstrm next) style: style]
	false]\gb7B
\g
SystemOrganization classify: ParagraphScanner under: 'Press File Support'.\g

"PressFile"l15000z20000\gbf5 
Class new title: 'PressFile'
	subclassof: Object
	fields: 'DL "<File> stores data list"
		EL "<Set> accumulates entity list"
		parts "<Set> accumulates part directory"
		DLstart "<Integer> position of current entity in DL"
		ELstart "<Integer> word position of current entity in EL"
		Pstart "<Integer> record position of current page in DL"
		eorigin "<Point>"
		scale "<Integer> micas per Alto screen dot"
		boundbox "<Rectangle> bounding box for current page"
		fontcodes "<Vector> of run codes corresponding to current fonts"
		fontdefs "<Vector of WidthTables> corresponding to fontcodes"
		estate "<Vector> of some entity state"
		FL "<Set> accumulates strings for Ext. File part" '
	declare: 'prevstyle SMentity recordsize printers printerMenu ';
	asFollows\gbf5 

There are two levels of code in this class: the low-level Press commands and the high level user commands.  At the moment, only text, lines and bitmaps are supported (see Paragraph presson:in: and class ParagraphScanner for the former).  ignores bounding box stuff. limited reading.

see <GR-DOCS>PressFormat.Press and PressFormat-figure.Press for more details\gi

Initialization\gbf5 
of: DL [
	EL _ Set new string: 200.
	FL _ Set new string: 40.
	parts _ Set new string: 40.
	fontcodes _ Vector new: 0.
	fontdefs _ Vector new: 0.
	estate _ Vector new: 3 "font, spacex, spacey, ...".
	prevstyle_ nil.
	self scale: PressScale;
		startPage]\gb7B
reset [
	DL readwriteshorten; reset.
	self of: DL]\gb6B
scale: scale\gb

Aspects\gbf5 
defaultPrinterName [
	[currentProfile  nil [PrinterName] currentProfile printerName]]\gb19B
name [DL name]\gb5B
scale [scale]\gb6B

Entity/Page/File Commands\gbf5 
box: rect hue: hue sat: sat bright: bright containing expr | w r
	[self entity: (self transrect: (w_ rect inset: 2)) containing
		[for r from: (w minus: rect) do
			[self showrect: r color: 0].
		[ColorPrint
			[self hue: hue; saturation: sat;
				showrect: rect color: bright; brightness: 0]].
		expr eval]]\gb65B
clip: boundingbox\gb
close | p i font [
	DL writingfalse [DL close]
	self closePage.
	partsfalse or parts empty []

	"if present, include the external file part  --- added Sept 80"

	[FL empty[]
	self part [DL append: FL] code: 2.
	FL reset.
	self padpage].

	"put font names and descriptions into font directory (part)"
	self part [
		for i to: fontdefs length do [
			font _ fontdefs  i.
			DL nextword_ 16; nextword_ i-1;
				next _ font min; next _ font max.
			self Bcpl: font name pad: 20.
			DL next _ font face; next _ font min;
				nextword _ font pointsize; nextword_ 0]]
		code: 1.

	"write part directory. Pstart is current page position"
	DL append: parts asReadStream.
	self padpage.
	p _ self recordnum.

	"document directory"
	DL nextword_ 27183; "press password"
		nextword_ p + 1 "number of records";
		nextword_ parts position / 8 "number of parts";
		nextword_ Pstart; "part dir and length"
		nextword_ p - Pstart;
		nextword_ 1; "backpointer to obsolete doc dir"
		append: user timewords; "2 time words"
		nextword_ 1; "first and last copies"
		nextword_ 1;
		nextword_ 1; "first and last pages"
		nextword _ 1;
		nextword _ 'S'1 "solid color (looked at by color printers)";
		next: 2*(0177-12) _ 0377.

	p _ user now.
	self Bcpl: self name pad: 52;
		Bcpl: [currentProfilenil [dp0 diskID1] currentProfile printedBy] pad: 32;
		Bcpl: [((String new: 40) asStream) print: p1; space; print: p2; contents] pad: 40;
		padpage.
	DL close.
	parts reset]\gb6B240i60I280i53I73i18I23i16I19i19I33i17I22i21I42i31I58i23I32i24I36i41I
entity: box containing expr | v [
	self startEntity.
	boundbox _ box.
	v _ expr eval.
	self closeEntity.
	v]\gb29B
entityorigin: eorigin\gb
page [self closePage]\gb5B
pictureinit [self pictureinit: user screenrect scale: PressScale]\gb12B
pictureinit: rect scale: scale
	[boundbox _ boundbox include: (self transrect: rect).
	self somefont]\gb32B
screenout: rect scale: scale
	["puts a bit map image onto the PressFile.  The standard
	scaling is 32 micas per Alto dot.  22 looks better, Dover only
	works with 32"
	user displayoffwhile [
		self somefont; setp: (self transrect: rect) origin; bitmap: rect bits: false; close]]\gb30B1i135I
selectPrinter [self selectPrinter: self defaultPrinterName]\gb14B
selectPrinter: oldName | t [
	user cr; show: 'select a printer (currently ';
		show: [oldNamefalse or oldName empty ['none'] oldName]; show: ')'.
	user cursorloc _ user screenrect center; restoredisplay.
	t _ 0.
	while t = 0 do [t _ printerMenu wbug].
	[t  printers length [printerst]
		t = (printers length+1) ["same" oldName] "none" false]]\gb23B
toPrinter [self toPrinter: self defaultPrinterName]\gb10B
toPrinter: ndest "a printer name" | psocket dest np t perr [
	ndest  false ["don't try to print" false]

	E  nil [
		"use O.S. if Smalltalk ethercode not alive"
		t _ (String new: 100) asStream.
		t append: 'Empress. '; append: self name.
		[ndest length > 0 [t space; append: ndest; append: '/H']].
		t append: '; Resume.~ Small.Boot'.
		user quitThen: t asReadStream]

	dest _ ''.
	perr _ psocket _ false.
	np _ printers length+1.
	DL readonly.

	while ndest do [
		perr or ndest empty [
			perr _ false.
			ndest _ self selectPrinter: dest]

		[dest = ndest ["to same printer"]
		dest _ ndest.
		"close previous socket"
		psocket [psocket close. psocket _ false]].

		[psocket []
		"create new socket"
		psocket _ EFTPSender new hostName: dest [psocket wakeup]
		user cr; show: 'name lookup failure'].

		"send file"
		psocket and (user displayoffwhile [psocket send: DL reset]) [
			"success--stop" ndest _ false]

		"failure--switch servers?"
		perr _ true].

	"cleanup after success or abort"
	DL close.
	psocket [psocket close]]\gb17B

Fonts\gbf5 
codefont: code style: style
	[fontdefs(self fontindex: code style: style)]\gb29B
fontindex: code style: style | ix font n
	["return index if in font dictionary"
	code _ code land: 0363.		"Remove underline and strikeout"
		[style=prevstyle
			[(ix _ fontcodes find: code) > 0  [ix]]
		fontcodes all_ nil. "invalid across style change"
		prevstyle_ style].
	n _ code / 16 + 1.
	font _ (WidthTable new
		named: (style fontfamily: n)
		pointsize: (style fontsize: n)
		face: (code / 2 land: 1) + (code * 2 land: 2))
	 lookup.
	(ix_ fontdefs find: font)>0
		[fontcodesix_ code. ix]
	"add entry to font dictionary"
	fontdefs length=16[user notify: 'too many fonts'. 1]
	fontcodes _ fontcodes, code.
	fontdefs _ fontdefs, font.
	fontcodes length]\gb29B14i36I27i32I365i30I
selectfont: f [
	estate1 = f []
	EL next _ 0160 + (estate1 _ f)]\gb14B
somefont		"fool self into writing non-empty fontdir"
	[self fontindex: 5*16 style: DefaultTextStyle]\gb10Bi42I

Transformations\gbf5 
transpt: p
	[ Point new x: (p x * scale) asInteger y: (25400 - (p y * scale)) asInteger]\gb12B
transrect: rect
	[ Rectangle new
		origin: (self transpt: rect minX  rect maxY)
		corner: (self transpt: rect maxX  rect minY)]\gb17B

EL commands\gbf5 
brightness: b [EL next_ 0370; next_ b]\gb14B
hue: b [EL next_ 0371; next_ b]\gb7B
onlyoncopy: n [EL next _ 0355; next _ n]\gb14B
resetspace [EL next _ 0366]\gb11B
saturation: s [EL next_ 0372; next_ s]\gb14B
setp: p [
	"self setx: p x; sety: p y"
	EL next _ 0356; nextword _ p x;
		next _ 0357; nextword _ p y]\gb8B
setspacex: x [
	estate2 = x []
	estate2 _ x.
	x  0 and x  2047 ["short form" EL nextword _ 060000 + x]
	EL next _ 0364; nextword _ x]\gb13B59i10I
setspacey: y [
	estate3 = y []
	estate3 _ y.
	y  0 and y  2047 ["short form" EL nextword _ 064000 + y]
	EL next _ 0365; nextword _ y]\gb13B59i10I
setx: x [EL next _ 0356; nextword _ x]\gb8B
sety: y [EL next _ 0357; nextword _ y]\gb8B
showchar: char ["immediate" EL next _ 0363; next _ char]\gb15B
showchars: n [
	n=0 []
	n  1 and n  32 ["short form" EL next _ n-1]
	EL next _ 0360; next _ n]\gb13B33i10I
showchars: n skip: t [
	t=1 and (n  1 and n  32) [EL next _ 0100 + n-1]
	self showchars: n; skipchars: t]\gb21B
showdots: nwords [EL next _ 0374; nextNumber: 4 _ nwords]\gb17B
showdotsopaque: nwords [EL next _ 0375; nextNumber: 4 _ nwords]\gb23B
showrect: rect [
	self setp: rect origin.
	EL next _ 0376;
		nextword _ rect width;
		nextword _ rect height]\gb15B
showrect: rect color: c [
	[ColorPrint [self brightness: c]].
	self showrect: (self transrect: rect)]\gb24B
showrectwidth: w height: h [EL next _ 0376; nextword _ w; nextword _ h]\gb27B
skipchars: n [
	n=0 []
	n  1 and n  32 ["short form" EL next  _ 040 + n-1]
	EL next _ 0361; next _ n]\gb13B33i10I
skipcontrol: n [
	"immediate"
	EL next _ 0353; next _ n.
	"now put n bytes in EL"]\gb15B
skipcontrol: n type: t [
	"n bytes have been put in DL"
	EL next _ 0362; nextword _ n; next _ t]\gb23B
space [EL next _ 0367]\gb6B

Bitmaps/Dots\gbf5 
AIS: file width: w height: h croprect: r at: pt scale: s
	[self setp: (self transpt: pt); dots
		[self setcoding: 8 "byte samples" dots: w lines: h;
				setmode: 3 "to right and to bottom of page";
				setsizewidth: (s*r width*scale) asInteger height: (s*r height*scale) asInteger;
				setwindowwidth: r width height: r height skipdots: r minX skiplines: r minY;
				dotsfromAIS: file]]
"
(dp0 pressfile: 'pix.press') somefont; AIS: 'girl.ais' width: 512 height: 512 croprect: (5050 rect: 500500) at: 3680 scale: 0.65; close.
"\gb58B
bitmap: rect bits: bits | w w16 h [
	"some pecularities of spruce:
	scale must be 32, and multiples of 16 for width (maybe extra stuff prints)"
	w _ rect width.
	w16 _ w + 15 | 16 "width to next word boundary".
	h _ rect height.
	"origin should be set earlier"
	self dots [
		self setcoding: 0 "bitmap" dots: w16 lines: h;
			setmode: 3 "to right and to bottom of page";
			setsizewidth: scale * w16 height: scale * h;
			setwindowwidth: [ColorPrint [w] w16] height: h;
			dotsfollow.
		bits["bits supplied" DL append: bits]
		"else from screen"
		rect bitsOntoStream: DL]]\gb24B9i1I4i104I39i27I23i28I37i6I37i30I127i13I22i16I
dots exp | dlpos [
	dlpos _ self padword.
	exp eval.
	self showdots: DL wordposition - dlpos]\gb10B
dotsfollow [DL nextword _ 3]\gb11B
dotsfromAIS: file | f
	[f_file length inString+file+[file length even[' ']'']. "BCPLize"
	DL nextword _ 4; nextword _ 4; append: f. FL append: f]\gb18B
setcoding: c dots: d lines: l [
	DL next _ 1; next _ c;
		nextword _ d; nextword _ l]\gb30B
setmode: m [DL next _ 2; next _ m]\gb11B
setsizewidth: w height: h [
	DL nextword _ 2; nextword _ w; nextword _ h]\gb26B
setwindowwidth: w height: h [
	self setwindowwidth: w height: h skipdots: 0 skiplines: 0]\gb28B
setwindowwidth: w height: h skipdots: sd skiplines: sl
	[DL nextword _ 1;
		nextword _ sd; nextword _ w;
		nextword _ sl; nextword _ h]\gb56B

Lines/Objects\gbf5 
drawcurve: v [
	v length  12 [user notify: 'illegal drawcurve']
	DL nextword _ 2.
	for v from: v do [DL nextword _ v]]\gb13B
drawdiscat: pt radius: radius | dx dy i
	[radius  16  []
	 dx _ (5 4 3 1 1 3 4 5 5 4 3 1 1 3 4 5).
	 dy _ (1 3 4 5 5 4 3 1 1 3 4 5 5 4 3 1).
	 self showobject [
		self moveto: pt + ((dx16*radius/5)  (dy16*radius/5)).
	 	for i to: 16 do
			[self drawto: pt + ((dxi*radius/5)  (dyi*radius/5))]]]\gb41B
drawlinefrom: p1 to: p2 width: width | d length t1 t2
	[[(d _ p2-p1) = (00)  []
		d x_ d x asFloat. d y_ d y asFloat. width _ width asFloat.
		length _ ((d x*d x)+(d y*d y)) sqrt.
		d x_ (d x*width/length) asInteger.
		d y_ (d y*width/length) asInteger.
		t1 _ d y  (0 - d x).
		t2 _ 0 - d y  d x.
		self showobject [
			self moveto: p1 + t1.
			self drawto: p2 + t1.
			self drawto:  p2 + t2.
			self drawto:  p1 + t2.
			self drawto:  p1 + t1]].
	 self drawdiscat: p2 radius: width]\gb55B
drawlinefromscreen: p1 to: p2 width: width
	[self drawlinefrom: (self transpt: p1) to: (self transpt: p2) width: (width*scale)] \gb44B
drawto: p [DL nextword _ 1; nextPoint _ p]\gb10B
moveto: p [DL nextword _ 0; nextPoint _ p]\gb10B
object expr atScreen: p 
	[self showobject [self objectGotoScreen: p pen: 0. expr eval]]\gb27B
objectGotoScreen: p pen: pen [
	DL nextword_ pen; nextPoint _ (self transpt: p)]\gb29B
showobject exp | p [
	p _ self padword.
	"expression containing moveto, drawto, drawcurve"
	exp eval.
	EL next _ 0373; nextword _ DL wordposition - p]\gb16B

Private\gbf5 
append: x
	[DL append: x]\gb11B
Bcpl: s pad: n | slen [
	"write a Bcpl string and padding to fill n bytes (used by close)"
	slen _ s length min: n-1.
	DL next _ slen; append: s(1 to: slen); next: n-(slen+1) _ 0]\gb15B11i63I
classInit | a p ["PressFile classInit."
	Smalltalk declare: PressScale as: 32.
	recordsize _ 512.
	SMentity _ 5.

	a _ (String new: 250) asStream.
"from [Maxc1]<Altodocs>NetTopology.Press, October 1980. in order of net number"
	printers _ (
		"net #"	"printer names"
		" 1"		'Navajo'			"HENRIETTA"
		" 3"		'Menlo' 'Clover' 'Lilac' "PARC: BLDG 35, FLOOR 2"
		" 5"		'Kanji'					"PARC:  BLDG 34"
		" 6"		'Wonder' 'Quake'	"PARC: BLDG 35, FLOOR 1&3"
		"10"		'Puff'					"A&E"
		"12"		'White' 'Colorado'	"PASADENA"
		"14"		'Niagara' 'Tioga'		"WEBSTER"
		"20"		'Yoda'			"PARC: BLDG 32"
		"21"		'Lily' 			"SPG"
		"23"		'Ranger'			"DALLAS"
		"26"		'Windfall'		"DC"
		"27"		'Genesee'		"WEBSTER"
		"33"		'Amarok'		"TORONTO"
		"34"		'Yankee'		"STAMFORD"
		"36"		'Cyclops'		"LEESBURG"
		"54"		'Rover'			"A&E"
		"55"		'SPGEng' 'Emperor'		"A&E"
		"56"		'Thud'				"A&E"
		"60"		'Adelie' 'Daisy' 'RockHopper' 	"BAYHILL"
		"62"		'Bud'				"?"
	).
	for p from: printers do [a append: p; cr].
	a append: 'same printer'; cr; append: 'no printer'.
	printerMenu _ Menu new string: a contents]\gb10B
closeEntity [self closeEntity: SMentity]\gb12B
closeEntity: etype [
	EL wordposition = ELstart []
	"Put a trailer into the EL"
	EL	padNext _ 0377;	"word-pad EL with <Nop>"
		next _ etype;
		next_ 0; "fontset"
		"dlstart relative to DL location in file"
		nextNumber: 4 _ DLstart - (Pstart*recordsize);
		nextNumber: 4 _ DL position - DLstart;
		nextPoint_ eorigin; "entity origin"
		nextPoint_ boundbox origin;
		nextPoint_ boundbox extent.
	EL nextword _ EL wordposition - ELstart + 1.
	self startEntity]\gb19B34i27I21i24I28i9I3i44I110i15I
closePage [
	self closeEntity.
	EL empty []
	DL	padNext _ 0;
		nextword _ 0;
		append: EL asReadStream.
	self part: 0 start: Pstart]\gb10B
data ["slightly dangerous" DL]\gb5B
padpage ["words of padding to end of page" (DL pad: recordsize with: 0) / 2]\gb8B2i31I
padword [
	"make object (lines or dots) start on word boundary"
	[DL padNext _ 0 [self skipchars: 1]].
	DL wordposition]\gb8B
part exp code: c | fp [
	self closePage.
	fp _ self recordnum.
	exp eval.
	self part: c start: fp]\gb18B
part: type start: start | padding [
	padding _ self padpage.
	parts nextword _ type;
		nextword _ start;
		nextword _ self recordnum - start;
		nextword _ padding.
	self startPage]\gb24B9b1B
recordnum [DL positionSize: recordsize]\gb10B
skipcode: code data: s | t [
	"called by hidePress:complete:. s is a String"
	(t _ s length+1) < 256 [
		"immediate, in EL"
		self skipcontrol: t.
		EL next _ code; append: s]
	"in DL"
	DL next _ code; append: s.
	self skipcontrol: t type: SMentity]\gb23B8i10bI19Bi15I32i16I56i5I
startEntity [
	DLstart _ DL position.
	ELstart _ EL wordposition.
	boundbox _ 0 asRectangle.
	eorigin _ 00.
	estate all _ 1.
	estate1 _ 0]\gb12B
startPage [
	EL reset.
	Pstart _ self recordnum.
	self startEntity]\gb10B

Reading\gbf5 
filin | p [
	self open.
	while (p _ self nextParagraph) do [
		FilinSource _ self.
		user print: nil p text; space].
	FilinSource _ nil.
	self close]\gb6B
nextControl | command t entity [
	"return the next skip-control information"
	command _ nil.
	while true do [
		(estate and command)false [
			"either or both false. get next entity"
			t _ EL next [
				estate _ EL next viewer. command _ nil.
				t1  SMentity ["ignore this entity" estate _ false]
				DLstart _ (t(3 to: 6)) asStream nextNumber: 4.
				DL position _ Pstart*recordsize + DLstart]

			"no more entities on current part (page)"
			self readPart []
			"no more pages"
			false]

		entity _ estate.
	while (command _ entity next) do [
	"some stuff arranged by probable frequency"
	command
	< 0100 [
		"show-characters-short (0-037)
		skip-characters-short (040-077)"
		DL skip: (command land: 037) +1];
	= 0356 ["set-x" entity nextword];
	= 0357 ["set-y" entity nextword];
	< 0140 [
		"show-characters-and-skip (0100-0137)"
		DL skip: (command land: 037) +2];
	< 0160 [
		"set-space-x-short (0140-0147)
		set-space-y-short  (0150-0157)"
		"(command land: 7)*256 +" entity next];
	< 0200 ["font" "command land: 017"];
	= 0362 [
		"skip-control-bytes"
		t _ entity nextword.
		entity nextSMentity ["ignore" DL skip: t]
		DL next: t];
	= 0360 ["show-characters" DL skip: entity next];
	= 0377 ["nop"];

	< 0353 [
		"available (0200-0237)
		spare (0240-0352)"];
	= 0353 [
		"skip-control-bytes-immediate"
		entity next: entity next];
	= 0354 ["alternative" entity skipwords: 5];
	= 0355 ["only-on-copy" entity next];
	= 0361 ["skip characters" DL skip: entity next];

	= 0363 ["show-character-immediate" entity next];
	< 0366 [
		"set-space-x (0364)
		set-space-y (0365)" entity nextword];
	< 0370 [
		"reset-space (0366)
		space (0367)" ];
	< 0373 [
		"set-brightness (0370)
		set-hue (0371)
		set-saturation (0372)" entity next];

	= 0373 ["show-object" DL skipwords: entity nextword];
	< 0376 [
		"show-dots (0374)
		show-dots-opaque (0375)"
		DL skipwords: (entity nextNumber: 4)];
	= 0376 ["show-rectangle" entity skipwords: 2]
	]]]\gb12B23i40I74i37I226i39I27i13I73i41I25b21B11b21B59b6B30b5B34b24B64b17B15b17B68b4B38b18B98b15B36b3B19b9B15b5B30b28B43b11B35b12B27b15B37b24B30b11B10b11B41b11B10b5B26b14B10b7B10b14B35b11B48b9B10b16B61b14B
nextParagraph | s p [
	s _ self nextControl [
		s _ s asStream.
		p _ Paragraph new.
		s next = p pressCode [p fromPress: self value: s]
		false]
	false]\gb14B
open | t [
	"read the parts (and font directory?)"
	DL readonly; "reopen?" settoend; skip: 0 - recordsize.
	DL nextword = 27183 and DL nextword = (self recordnum + 1) [
		t _ DL nextword.
		DL position: DL nextword size: recordsize.
		parts _ (DL next: t*8) viewer.
		self readPart]
	self error: 'not a press file']\gb5B8i36I
readPart | t [
	"read parts until we find a printed page or end"
	estate _ false.
	while (t _ parts nextword) do [
		Pstart _ parts nextword.
		t  0 [
			"not a printed page"
			parts skip: 4.
			t> 0 ["font or other part"]
			"a non-standard part. let document (estate?) interpret"
			"DL position _ Pstart*recordsize.
			estate fromPress: self name: t value: DL"]

		"go to end of last record of entity list, ignoring padding"
		t _ parts nextword "length".
		DL position _ Pstart+t * recordsize - ((1 + parts nextword) * 2).
		EL _ Set new vector: 50.

		"scan backwards for beginning of entity list, reading entities"
		while (t _ DL nextword) > 0 do [
			t < 12 [user notify: 'illegal entity']
			DL skipwords: 0-t.
			"read entity and trailer (last 12 words of entity)"
			EL next _ DL next: t-12 *2.
			EL next _ DL next: 24.
			DL skipwords: 1 - t].
		"now reverse:  trailer, entity (1st), ... (last)"
		EL _ (EL asArray(EL length to: 1 by: 1)) asStream]
	false]\gb9B8i46I96i18I56i53I89i57I24i6I102i61I108i49I88i47I
\g
SystemOrganization classify: PressFile under: 'Press File Support'.\g
PressFile classInit\g

"WidthTable"l15000z20000\gbf5 
Class new title: 'WidthTable'
	subclassof: Object
	fields: 'name "<String> name of font family"
		pointsize "<Integer> size in points"
		face "<Integer> Press face code"
		min "<Integer> min character code in font"
		max "<integer> max character code in font"
		"Ascent, descent, and width are in micas"
		ascent "<Integer> max ascent of characters in font"
		descent "<Integer> NEGATIVE max descent of characters in font"
		widths "<Vector of Integers> widths of characters"
		'
	declare: 'tab WidthDict ';
	asFollows\gbf5 

Holds font parameters and width table for a Press font.  It knows how to load itself from FONTS.WIDTHS.\gi

Initialization\gbf5 
classInit
	[WidthDict _ Dictionary init.
	tab _ 500]\gb11B
lookup | key font i [
	key _ name + pointsize asString + (('' 'I' 'B' 'BI')(face+1)).
	font _ WidthDict lookup: key [font]
	self fontfrom: (dp0 oldFile: 'Fonts.Widths') readonly.
	for i from: (011 015 040) do
		[i  min and i  max  [widths(i-min+1) _ 0]].
	WidthDict insert: key with: self.
	self]\gb7B
named: name pointsize: pointsize face: face\gb

Access\gbf5 
ascent [ascent]\gb7B
descent [descent]\gb8B
face [face]\gb5B
max [max]\gb4B
min [min]\gb4B
name [name]\gb5B
pointsize [pointsize]\gb10B
scan: strm until: width exceeds: maxw | char w [
	while (char _ strm next) do
		[char < min 
			[char=040 or (char=015 or char=011)  [char, width]
			user notify: 'char too low']
		char > max  [user notify: 'char too high']
		(w _ widths(char+1-min)) = 0  [char, width]
		(width _ width + w) > maxw  [true, width]
		].
	false, width]\gb38B43b1B
space [150]\gb6B
tab [tab]\gb4B
tab _ t [tab _ t]\gb8B

Reading FONTS.WIDTHS\gbf5 
findfield: n on: file | IXH [
	while [
		IXH _ file nextword.
		(IXH bits: (0 to: 3)) "type"
			= 0  [user notify: 'field not found'];
			 n]
	 do
		[file skipwords: (IXH land: 07777 "length") - 1]]\gb22B
fontfrom: file | i code fam fmin fmax start len found w scale
	["find code for font family"
	file reset. fam _ ''.
	until (fam = name) do
		[self findfield: 1 on: file.
		code _ file nextword.
		fam _ file next: (len _ file next).
		file skip: 19 - len].
	"now search for proper face"
	found _ false.
	"Convert from points to micas"
	scale _ (pointsize asFloat * 2540 / 72) asInteger.
	until found do
		[self findfield: 4 on: file.
		found _ [file next = code].
		[file next  face  [found _ false]].
		fmin _ file next.
		fmax _ file next.
		i _ file nextword. [i  scale and: i  0  [found _ false]].
		file skip: 4. start _ file nextword. file skip: 4].
	scale _ [i  0  [1 "don't need to scale"] pointsize asFloat * 254 / 7200].
	min _ fmin. max _ fmax.
	"get bb and x-tables"
	file wordposition_ start+1.
	descent _ 0 - (scale * file nextword) asInteger.
	file nextword.
	ascent _ (scale * file nextword) asInteger.
	file nextword.
	widths _ Vector new: (max - min + 1).
	for i to: widths length do
		[w _ file nextword.
		widthsi _ [w > 0  [(scale * w) asInteger] 0]].
	file close]\gb15B49i27I167i28I18i30I350i21I61i21I
\g
SystemOrganization classify: WidthTable under: 'Press File Support'.\g
WidthTable classInit\g 