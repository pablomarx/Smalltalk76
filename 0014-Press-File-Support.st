'From Smalltalk 5.5k XM November 24 on 22 November 1980 at 2:57:08 am.'

"ParagraphScanner" 
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
	asFollows 

Scans through a paragraph computing the dimensions of a partial line of text.

Initialization 
in: rect
init
	[ascent ← descent ← width ← spaces ← 0. tabpos reset]
of: para to: press style: style
	[textstrm ← '' asStream.
	runstrm ← para runs asStream.
	tabpos ← (Vector new: 10) asStream]

Access 
position [⇑textstrm position]
width [⇑width]

Scanning 
backup
	[textstrm skip: ¬1]
scan "Scan up to a zero-width character, back up to last blank if width exceeded"
		| maxw sp char t
			"Save state" spos slim srunpos sasc sdesc swidth ssp sfont stpos
	[textstrm end and⦂ self newrun≡false⇒ [⇑false]
	maxw ← rect width.
	while⦂
		[ascent ← ascent max: font ascent.
		descent ← descent max: font descent.
		sp ← font space.
		while⦂ [
			t ← font scan: textstrm until: width exceeds: maxw.
			[(char ← t◦1) ≡ true⇒ [] width ← t◦2].
			char = 040] do⦂
			["Save state"
				spos ← textstrm position. slim ← textstrm limit.
				srunpos ← runstrm position. stpos ← tabpos position.
				sasc ← ascent. sdesc ← descent.
				swidth ← width. ssp ← spaces. sfont ← font.
			spaces ← spaces+1.
			width ← width+sp].

		char⇒
			[(char≡true and⦂ nil≠spos) and⦂ (2*ascent ≤ rect height)⇒ [
				"Back up to just past last blank (if another line fits)"
				textstrm of: para text from: spos+1 to: slim.
				runstrm position ← srunpos. tabpos position ← stpos.
				ascent ← sasc. descent ← sdesc.
				width ← swidth. spaces ← ssp. font ← sfont.
				⇑040]
			⇑char]
		self newrun]
	 do⦂ [].
	⇑false]
tab
	[spaces ← 0.
	tabpos next ← textstrm position;
		next ← (width ← width + font tab | font tab)]

Printing 
printfrom: charpos aligned: align skip: n "Returns false if goes below bottom"
		| ybot a b ix iy px xs sp rs len tpos ts ntab rval ifont w ps [
	"this code basically writes the EL (entity list) for a line"
	"bottom of character -- ascent not really ascent but height"
	(ybot ← rect corner y - ascent) < rect origin y ⇒ [
		"won't fit" ⇑false]

	a ← charpos + 1.
	b ← textstrm position - n.
	[a > b ⇒ ["No text"]
	ts ← tabpos viewer.
	tpos ← ts next.

	px ← false.
	xs ← rect width - width.
	ix ← rect minX + ["left margin offset" align=2⇒ [xs/2]; =4⇒[xs] 0].
	"set baseline of character.  do setx before showchars"
	press sety: (iy ← ybot + descent).
	sp ← font space "kludge?".
	[align=1⇒ ["do setspacex before showchars"] press setspacex: sp].

	rs ← (para run: a to: b) asStream.
	while⦂ (len ← rs next) do⦂ [
		press selectfont: (press fontindex: (rval ← rs next) style: style) - 1.
		b ← a+len.

		[(rval land: 4) = 0⇒ ["no underlining"]
		"unfortunately, we must rescan this part of line to find out how wide it is"
		ifont ← press codefont: rval style: style "a WidthTable".
		ps ← (para◦(a to: b-1)) asStream.
		w ← true, 0.
		while⦂ w◦1 do⦂ [
			w ← ifont scan: ps until: w◦2 exceeds: rect width.
			w◦1 = 040⇒ [w◦2 ← w◦2 + ifont space];
				=011⇒ [w◦2 ← w◦2 + ifont tab | ifont tab]].

		[px⇒ ["use current x position"] press setx: ix].
		"change y position to show rectangle, then change y back again"
		press sety: iy-40; showrectwidth: w◦2 height: 30; sety: iy].

		ntab ← 0.
		while⦂ (tpos and⦂ tpos<b) do⦂ [	"Put out tabs"
			[tpos = a⇒ ["no text between this tab and last"]
			"put out accumulated tabs or initial x"
			[ntab> 0⇒ [
				press skipchars: ntab; setx: px.
				ntab ← 0]
			px⇒ []
			press setx: (px ← ix)].
			press showchars: tpos-a].
			ntab ← ntab+1.
			px ← ix + ts next.
			a ← tpos+1.
			tpos ← ts next].
		[ntab> 0⇒ [
			press skipchars: ntab;
				setx: px]
		px⇒ []
		press setx: (px ← ix)].

		[align=1 and⦂ tpos≡false ⇒		["Reset space width"
			[spaces=0⇒ [] press setspacex: xs/spaces+sp].
			align ← 0]].
		rs end⇒ [
			"for more compactness, maybe"
			press showchars: b-a skip: n.
			⇑ybot]
		press showchars: b-a.
		a ← b]].
	[n > 0⇒ [
		"skip over ending blank or carriage return"
		press skipchars: n]].
	⇑ybot]

Private scanning 
newrun | len pos [
	len ← runstrm next⇒
		[pos ← textstrm position.
		textstrm of: para text from: pos+1 to: pos+len.
		font ← press codefont: (runstrm next) style: style]
	⇑false]

SystemOrganization classify: ↪ParagraphScanner under: 'Press File Support'.

"PressFile" 
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
	asFollows 

There are two levels of code in this class: the low-level Press commands and the high level user commands.  At the moment, only text, lines and bitmaps are supported (see Paragraph presson:in: and class ParagraphScanner for the former).  ignores bounding box stuff. limited reading.

see <GR-DOCS>PressFormat.Press and PressFormat-figure.Press for more details

Initialization 
of: DL [
	EL ← Set new string: 200.
	FL ← Set new string: 40.
	parts ← Set new string: 40.
	fontcodes ← Vector new: 0.
	fontdefs ← Vector new: 0.
	estate ← Vector new: 3 "font, spacex, spacey, ...".
	prevstyle← nil.
	self scale: PressScale;
		startPage]
reset [
	DL readwriteshorten; reset.
	self of: DL]
scale: scale

Aspects 
defaultPrinterName [
	⇑[currentProfile ≡ nil⇒ [PrinterName] currentProfile printerName]]
name [⇑DL name]
scale [⇑scale]

Entity/Page/File Commands 
box: rect hue: hue sat: sat bright: bright containing⦂ expr | w r
	[self entity: (self transrect: (w← rect inset: ¬2)) containing⦂
		[for⦂ r from: (w minus: rect) do⦂
			[self showrect: r color: 0].
		[ColorPrint⇒
			[self hue: hue; saturation: sat;
				showrect: rect color: bright; brightness: 0]].
		expr eval]]
clip: boundingbox
close | p i font [
	DL writing≡false⇒ [DL close]
	self closePage.
	parts≡false or⦂ parts empty⇒ []

	"if present, include the external file part  --- added Sept 80"

	[FL empty⇒[]
	self part⦂ [DL append: FL] code: 2.
	FL reset.
	self padpage].

	"put font names and descriptions into font directory (part)"
	self part⦂ [
		for⦂ i to: fontdefs length do⦂ [
			font ← fontdefs ◦ i.
			DL nextword← 16; nextword← i-1;
				next ← font min; next ← font max.
			self Bcpl: font name pad: 20.
			DL next ← font face; next ← font min;
				nextword ← font pointsize; nextword← 0]]
		code: 1.

	"write part directory. Pstart is current page position"
	DL append: parts asReadStream.
	self padpage.
	p ← self recordnum.

	"document directory"
	DL nextword← 27183; "press password"
		nextword← p + 1 "number of records";
		nextword← parts position / 8 "number of parts";
		nextword← Pstart; "part dir and length"
		nextword← p - Pstart;
		nextword← ¬1; "backpointer to obsolete doc dir"
		append: user timewords; "2 time words"
		nextword← 1; "first and last copies"
		nextword← 1;
		nextword← ¬1; "first and last pages"
		nextword ← ¬1;
		nextword ← 'S'◦1 "solid color (looked at by color printers)";
		next: 2*(0177-12) ← 0377.

	p ← user now.
	self Bcpl: self name pad: 52;
		Bcpl: [currentProfile≡nil⇒ [dp0 diskID◦1] currentProfile printedBy] pad: 32;
		Bcpl: [((String new: 40) asStream) print: p◦1; space; print: p◦2; contents] pad: 40;
		padpage.
	DL close.
	parts reset]
entity: box containing⦂ expr | v [
	self startEntity.
	boundbox ← box.
	v ← expr eval.
	self closeEntity.
	⇑v]
entityorigin: eorigin
page [self closePage]
pictureinit [self pictureinit: user screenrect scale: PressScale]
pictureinit: rect scale: scale
	[boundbox ← boundbox include: (self transrect: rect).
	self somefont]
screenout: rect scale: scale
	["puts a bit map image onto the PressFile.  The standard
	scaling is 32 micas per Alto dot.  22 looks better, Dover only
	works with 32"
	user displayoffwhile⦂ [
		self somefont; setp: (self transrect: rect) origin; bitmap: rect bits: false; close]]
selectPrinter [⇑self selectPrinter: self defaultPrinterName]
selectPrinter: oldName | t [
	user cr; show: 'select a printer (currently ';
		show: [oldName≡false or⦂ oldName empty⇒ ['none'] oldName]; show: ')'.
	user cursorloc ← user screenrect center; restoredisplay.
	t ← 0.
	while⦂ t = 0 do⦂ [t ← printerMenu wbug].
	⇑[t ≤ printers length⇒ [printers◦t]
		t = (printers length+1)⇒ ["same" oldName] "none" false]]
toPrinter [self toPrinter: self defaultPrinterName]
toPrinter: ndest "a printer name" | psocket dest np t perr [
	ndest ≡ false⇒ ["don't try to print" ⇑false]

	E ≡ nil⇒ [
		"use O.S. if Smalltalk ethercode not alive"
		t ← (String new: 100) asStream.
		t append: 'Empress. '; append: self name.
		[ndest length > 0⇒ [t space; append: ndest; append: '/H']].
		t append: '; Resume.~ Small.Boot'.
		user quitThen: t asReadStream]

	dest ← ''.
	perr ← psocket ← false.
	np ← printers length+1.
	DL readonly.

	while⦂ ndest do⦂ [
		perr or⦂ ndest empty⇒ [
			perr ← false.
			ndest ← self selectPrinter: dest]

		[dest = ndest⇒ ["to same printer"]
		dest ← ndest.
		"close previous socket"
		psocket⇒ [psocket close. psocket ← false]].

		[psocket⇒ []
		"create new socket"
		psocket ← EFTPSender new hostName: dest⇒ [psocket wakeup]
		user cr; show: 'name lookup failure'].

		"send file"
		psocket and⦂ (user displayoffwhile⦂ [psocket send: DL reset])⇒ [
			"success--stop" ndest ← false]

		"failure--switch servers?"
		perr ← true].

	"cleanup after success or abort"
	DL close.
	psocket⇒ [psocket close]]

Fonts 
codefont: code style: style
	[⇑fontdefs◦(self fontindex: code style: style)]
fontindex: code style: style | ix font n
	["return index if in font dictionary"
	code ← code land: 0363.		"Remove underline and strikeout"
		[style=prevstyle⇒
			[(ix ← fontcodes find: code) > 0 ⇒ [⇑ix]]
		fontcodes all← nil. "invalid across style change"
		prevstyle← style].
	n ← code / 16 + 1.
	font ← (WidthTable new
		named: (style fontfamily: n)
		pointsize: (style fontsize: n)
		face: (code / 2 land: 1) + (code * 2 land: 2))
	 lookup.
	(ix← fontdefs find: font)>0⇒
		[fontcodes◦ix← code. ⇑ix]
	"add entry to font dictionary"
	fontdefs length=16⇒[user notify: 'too many fonts'. ⇑1]
	fontcodes ← fontcodes, code.
	fontdefs ← fontdefs, font.
	⇑fontcodes length]
selectfont: f [
	estate◦1 = f⇒ []
	EL next ← 0160 + (estate◦1 ← f)]
somefont		"fool self into writing non-empty fontdir"
	[self fontindex: 5*16 style: DefaultTextStyle]

Transformations 
transpt: p
	[⇑ Point new x: (p x * scale) asInteger y: (25400 - (p y * scale)) asInteger]
transrect: rect
	[⇑ Rectangle new
		origin: (self transpt: rect minX ⌾ rect maxY)
		corner: (self transpt: rect maxX ⌾ rect minY)]

EL commands 
brightness: b [EL next← 0370; next← b]
hue: b [EL next← 0371; next← b]
onlyoncopy: n [EL next ← 0355; next ← n]
resetspace [EL next ← 0366]
saturation: s [EL next← 0372; next← s]
setp: p [
	"self setx: p x; sety: p y"
	EL next ← 0356; nextword ← p x;
		next ← 0357; nextword ← p y]
setspacex: x [
	estate◦2 = x⇒ []
	estate◦2 ← x.
	x ≥ 0 and⦂ x ≤ 2047⇒ ["short form" EL nextword ← 060000 + x]
	EL next ← 0364; nextword ← x]
setspacey: y [
	estate◦3 = y⇒ []
	estate◦3 ← y.
	y ≥ 0 and⦂ y ≤ 2047⇒ ["short form" EL nextword ← 064000 + y]
	EL next ← 0365; nextword ← y]
setx: x [EL next ← 0356; nextword ← x]
sety: y [EL next ← 0357; nextword ← y]
showchar: char ["immediate" EL next ← 0363; next ← char]
showchars: n [
	n=0⇒ []
	n ≥ 1 and⦂ n ≤ 32⇒ ["short form" EL next ← n-1]
	EL next ← 0360; next ← n]
showchars: n skip: t [
	t=1 and⦂ (n ≥ 1 and⦂ n ≤ 32)⇒ [EL next ← 0100 + n-1]
	self showchars: n; skipchars: t]
showdots: nwords [EL next ← 0374; nextNumber: 4 ← nwords]
showdotsopaque: nwords [EL next ← 0375; nextNumber: 4 ← nwords]
showrect: rect [
	self setp: rect origin.
	EL next ← 0376;
		nextword ← rect width;
		nextword ← rect height]
showrect: rect color: c [
	[ColorPrint⇒ [self brightness: c]].
	self showrect: (self transrect: rect)]
showrectwidth: w height: h [EL next ← 0376; nextword ← w; nextword ← h]
skipchars: n [
	n=0⇒ []
	n ≥ 1 and⦂ n ≤ 32⇒ ["short form" EL next  ← 040 + n-1]
	EL next ← 0361; next ← n]
skipcontrol: n [
	"immediate"
	EL next ← 0353; next ← n.
	"now put n bytes in EL"]
skipcontrol: n type: t [
	"n bytes have been put in DL"
	EL next ← 0362; nextword ← n; next ← t]
space [EL next ← 0367]

Bitmaps/Dots 
AIS: file width: w height: h croprect: r at: pt scale: s
	[self setp: (self transpt: pt); dots⦂
		[self setcoding: 8 "byte samples" dots: w lines: h;
				setmode: 3 "to right and to bottom of page";
				setsizewidth: (s*r width*scale) asInteger height: (s*r height*scale) asInteger;
				setwindowwidth: r width height: r height skipdots: r minX skiplines: r minY;
				dotsfromAIS: file]]
"
(dp0 pressfile: 'pix.press') somefont; AIS: 'girl.ais' width: 512 height: 512 croprect: (50⌾50 rect: 500⌾500) at: 36⌾80 scale: 0.65; close.
"
bitmap: rect bits: bits | w w16 h [
	"some pecularities of spruce:
	scale must be 32, and multiples of 16 for width (maybe extra stuff prints)"
	w ← rect width.
	w16 ← w + 15 | 16 "width to next word boundary".
	h ← rect height.
	"origin should be set earlier"
	self dots⦂ [
		self setcoding: 0 "bitmap" dots: w16 lines: h;
			setmode: 3 "to right and to bottom of page";
			setsizewidth: scale * w16 height: scale * h;
			setwindowwidth: [ColorPrint⇒ [w] w16] height: h;
			dotsfollow.
		bits⇒["bits supplied" DL append: bits]
		"else from screen"
		rect bitsOntoStream: DL]]
dots⦂ exp | dlpos [
	dlpos ← self padword.
	exp eval.
	self showdots: DL wordposition - dlpos]
dotsfollow [DL nextword ← 3]
dotsfromAIS: file | f
	[f←file length inString+file+[file length even⇒[' ']'']. "BCPLize"
	DL nextword ← 4; nextword ← 4; append: f. FL append: f]
setcoding: c dots: d lines: l [
	DL next ← 1; next ← c;
		nextword ← d; nextword ← l]
setmode: m [DL next ← 2; next ← m]
setsizewidth: w height: h [
	DL nextword ← 2; nextword ← w; nextword ← h]
setwindowwidth: w height: h [
	self setwindowwidth: w height: h skipdots: 0 skiplines: 0]
setwindowwidth: w height: h skipdots: sd skiplines: sl
	[DL nextword ← 1;
		nextword ← sd; nextword ← w;
		nextword ← sl; nextword ← h]

Lines/Objects 
drawcurve: v [
	v length ≠ 12⇒ [user notify: 'illegal drawcurve']
	DL nextword ← 2.
	for⦂ v from: v do⦂ [DL nextword ← v]]
drawdiscat: pt radius: radius | dx dy i
	[radius ≤ 16 ⇒ []
	 dx ← ↪(5 4 3 1 ¬1 ¬3 ¬4 ¬5 ¬5 ¬4 ¬3 ¬1 1 3 4 5).
	 dy ← ↪(1 3 4 5 5 4 3 1 ¬1 ¬3 ¬4 ¬5 ¬5 ¬4 ¬3 ¬1).
	 self showobject⦂ [
		self moveto: pt + ((dx◦16*radius/5) ⌾ (dy◦16*radius/5)).
	 	for⦂ i to: 16 do⦂
			[self drawto: pt + ((dx◦i*radius/5) ⌾ (dy◦i*radius/5))]]]
drawlinefrom: p1 to: p2 width: width | d length t1 t2
	[[(d ← p2-p1) = (0⌾0) ⇒ []
		d x← d x asFloat. d y← d y asFloat. width ← width asFloat.
		length ← ((d x*d x)+(d y*d y)) sqrt.
		d x← (d x*width/length) asInteger.
		d y← (d y*width/length) asInteger.
		t1 ← d y ⌾ (0 - d x).
		t2 ← 0 - d y ⌾ d x.
		self showobject⦂ [
			self moveto: p1 + t1.
			self drawto: p2 + t1.
			self drawto:  p2 + t2.
			self drawto:  p1 + t2.
			self drawto:  p1 + t1]].
	 self drawdiscat: p2 radius: width]
drawlinefromscreen: p1 to: p2 width: width
	[⇑self drawlinefrom: (self transpt: p1) to: (self transpt: p2) width: (width*scale)] 
drawto: p [DL nextword ← 1; nextPoint ← p]
moveto: p [DL nextword ← 0; nextPoint ← p]
object⦂ expr atScreen: p 
	[self showobject⦂ [self objectGotoScreen: p pen: 0. expr eval]]
objectGotoScreen: p pen: pen [
	DL nextword← pen; nextPoint ← (self transpt: p)]
showobject⦂ exp | p [
	p ← self padword.
	"expression containing moveto, drawto, drawcurve"
	exp eval.
	EL next ← 0373; nextword ← DL wordposition - p]

Private 
append: x
	[⇑DL append: x]
Bcpl: s pad: n | slen [
	"write a Bcpl string and padding to fill n bytes (used by close)"
	slen ← s length min: n-1.
	DL next ← slen; append: s◦(1 to: slen); next: n-(slen+1) ← 0]
classInit | a p ["PressFile classInit."
	Smalltalk declare: ↪PressScale as: 32.
	recordsize ← 512.
	SMentity ← 5.

	a ← (String new: 250) asStream.
"from [Maxc1]<Altodocs>NetTopology.Press, October 1980. in order of net number"
	printers ← ↪(
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
	for⦂ p from: printers do⦂ [a append: p; cr].
	a append: 'same printer'; cr; append: 'no printer'.
	printerMenu ← Menu new string: a contents]
closeEntity [self closeEntity: SMentity]
closeEntity: etype [
	EL wordposition = ELstart⇒ []
	"Put a trailer into the EL"
	EL	padNext ← 0377;	"word-pad EL with <Nop>"
		next ← etype;
		next← 0; "fontset"
		"dlstart relative to DL location in file"
		nextNumber: 4 ← DLstart - (Pstart*recordsize);
		nextNumber: 4 ← DL position - DLstart;
		nextPoint← eorigin; "entity origin"
		nextPoint← boundbox origin;
		nextPoint← boundbox extent.
	EL nextword ← EL wordposition - ELstart + 1.
	self startEntity]
closePage [
	self closeEntity.
	EL empty⇒ []
	DL	padNext ← 0;
		nextword ← 0;
		append: EL asReadStream.
	self part: 0 start: Pstart]
data ["slightly dangerous" ⇑DL]
padpage ["words of padding to end of page" ⇑(DL pad: recordsize with: 0) / 2]
padword [
	"make object (lines or dots) start on word boundary"
	[DL padNext ← 0⇒ [self skipchars: 1]].
	⇑DL wordposition]
part⦂ exp code: c | fp [
	self closePage.
	fp ← self recordnum.
	exp eval.
	self part: c start: fp]
part: type start: start | padding [
	padding ← self padpage.
	parts nextword ← type;
		nextword ← start;
		nextword ← self recordnum - start;
		nextword ← padding.
	self startPage]
recordnum [⇑DL positionSize: recordsize]
skipcode: code data: s | t [
	"called by hidePress:complete:. s is a String"
	(t ← s length+1) < 256⇒ [
		"immediate, in EL"
		self skipcontrol: t.
		EL next ← code; append: s]
	"in DL"
	DL next ← code; append: s.
	self skipcontrol: t type: SMentity]
startEntity [
	DLstart ← DL position.
	ELstart ← EL wordposition.
	boundbox ← 0 asRectangle.
	eorigin ← 0⌾0.
	estate all ← ¬1.
	estate◦1 ← 0]
startPage [
	EL reset.
	Pstart ← self recordnum.
	self startEntity]

Reading 
filin | p [
	self open.
	while⦂ (p ← self nextParagraph) do⦂ [
		FilinSource ← self.
		user print: nilⓢ p text; space].
	FilinSource ← nil.
	self close]
nextControl | command t entity [
	"return the next skip-control information"
	command ← nil.
	while⦂ true do⦂ [
		(estate and⦂ command)≡false⇒ [
			"either or both false. get next entity"
			t ← EL next⇒ [
				estate ← EL next viewer. command ← nil.
				t◦1 ≠ SMentity⇒ ["ignore this entity" estate ← false]
				DLstart ← (t◦(3 to: 6)) asStream nextNumber: 4.
				DL position ← Pstart*recordsize + DLstart]

			"no more entities on current part (page)"
			self readPart⇒ []
			"no more pages"
			⇑false]

		entity ← estate.
	while⦂ (command ← entity next) do⦂ [
	"some stuff arranged by probable frequency"
	command
	< 0100⇒ [
		"show-characters-short (0-037)
		skip-characters-short (040-077)"
		DL skip: (command land: 037) +1];
	= 0356⇒ ["set-x" entity nextword];
	= 0357⇒ ["set-y" entity nextword];
	< 0140⇒ [
		"show-characters-and-skip (0100-0137)"
		DL skip: (command land: 037) +2];
	< 0160⇒ [
		"set-space-x-short (0140-0147)
		set-space-y-short  (0150-0157)"
		"(command land: 7)*256 +" entity next];
	< 0200⇒ ["font" "command land: 017"];
	= 0362⇒ [
		"skip-control-bytes"
		t ← entity nextword.
		entity next≠SMentity⇒ ["ignore" DL skip: t]
		⇑DL next: t];
	= 0360⇒ ["show-characters" DL skip: entity next];
	= 0377⇒ ["nop"];

	< 0353⇒ [
		"available (0200-0237)
		spare (0240-0352)"];
	= 0353⇒ [
		"skip-control-bytes-immediate"
		⇑entity next: entity next];
	= 0354⇒ ["alternative" entity skipwords: 5];
	= 0355⇒ ["only-on-copy" entity next];
	= 0361⇒ ["skip characters" DL skip: entity next];

	= 0363⇒ ["show-character-immediate" entity next];
	< 0366⇒ [
		"set-space-x (0364)
		set-space-y (0365)" entity nextword];
	< 0370⇒ [
		"reset-space (0366)
		space (0367)" ];
	< 0373⇒ [
		"set-brightness (0370)
		set-hue (0371)
		set-saturation (0372)" entity next];

	= 0373⇒ ["show-object" DL skipwords: entity nextword];
	< 0376⇒ [
		"show-dots (0374)
		show-dots-opaque (0375)"
		DL skipwords: (entity nextNumber: 4)];
	= 0376⇒ ["show-rectangle" entity skipwords: 2]
	]]]
nextParagraph | s p [
	s ← self nextControl⇒ [
		s ← s asStream.
		p ← Paragraph new.
		s next = p pressCode⇒ [⇑p fromPress: self value: s]
		⇑false]
	⇑false]
open | t [
	"read the parts (and font directory?)"
	DL readonly; "reopen?" settoend; skip: 0 - recordsize.
	DL nextword = 27183 and⦂ DL nextword = (self recordnum + 1)⇒ [
		t ← DL nextword.
		DL position: DL nextword size: recordsize.
		parts ← (DL next: t*8) viewer.
		self readPart]
	self error: 'not a press file']
readPart | t [
	"read parts until we find a printed page or end"
	estate ← false.
	while⦂ (t ← parts nextword) do⦂ [
		Pstart ← parts nextword.
		t ≠ 0⇒ [
			"not a printed page"
			parts skip: 4.
			t> 0⇒ ["font or other part"]
			"a non-standard part. let document (estate?) interpret"
			"DL position ← Pstart*recordsize.
			estate fromPress: self name: t value: DL"]

		"go to end of last record of entity list, ignoring padding"
		t ← parts nextword "length".
		DL position ← Pstart+t * recordsize - ((1 + parts nextword) * 2).
		EL ← Set new vector: 50.

		"scan backwards for beginning of entity list, reading entities"
		while⦂ (t ← DL nextword) > 0 do⦂ [
			t < 12⇒ [user notify: 'illegal entity']
			DL skipwords: 0-t.
			"read entity and trailer (last 12 words of entity)"
			EL next ← DL next: t-12 *2.
			EL next ← DL next: 24.
			DL skipwords: ¬1 - t].
		"now reverse:  trailer, entity (1st), ... (last)"
		⇑EL ← (EL asArray◦(EL length to: 1 by: ¬1)) asStream]
	⇑false]

SystemOrganization classify: ↪PressFile under: 'Press File Support'.
PressFile classInit

"WidthTable" 
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
	asFollows 

Holds font parameters and width table for a Press font.  It knows how to load itself from FONTS.WIDTHS.

Initialization 
classInit
	[WidthDict ← Dictionary init.
	tab ← 500]
lookup | key font i [
	key ← name + pointsize asString + (↪('' 'I' 'B' 'BI')◦(face+1)).
	font ← WidthDict lookup: key⇒ [⇑font]
	self fontfrom: (dp0 oldFile: 'Fonts.Widths') readonly.
	for⦂ i from: ↪(011 015 040) do⦂
		[i ≥ min and⦂ i ≤ max ⇒ [widths◦(i-min+1) ← 0]].
	WidthDict insert: key with: self.
	⇑self]
named: name pointsize: pointsize face: face

Access 
ascent [⇑ascent]
descent [⇑descent]
face [⇑face]
max [⇑max]
min [⇑min]
name [⇑name]
pointsize [⇑pointsize]
scan: strm until: width exceeds: maxw | char w [
	while⦂ (char ← strm next) do⦂
		[char < min ⇒
			[char=040 or⦂ (char=015 or⦂ char=011) ⇒ [⇑char, width]
			user notify: 'char too low']
		char > max ⇒ [user notify: 'char too high']
		(w ← widths◦(char+1-min)) = 0 ⇒ [⇑char, width]
		(width ← width + w) > maxw ⇒ [⇑true, width]
		].
	⇑false, width]
space [⇑150]
tab [⇑tab]
tab ← t [tab ← t]

Reading FONTS.WIDTHS 
findfield: n on: file | IXH [
	while⦂ [
		IXH ← file nextword.
		(IXH bits: (0 to: 3)) "type"
			= 0 ⇒ [user notify: 'field not found'];
			≠ n]
	 do⦂
		[file skipwords: (IXH land: 07777 "length") - 1]]
fontfrom: file | i code fam fmin fmax start len found w scale
	["find code for font family"
	file reset. fam ← ''.
	until⦂ (fam = name) do⦂
		[self findfield: 1 on: file.
		code ← file nextword.
		fam ← file next: (len ← file next).
		file skip: 19 - len].
	"now search for proper face"
	found ← false.
	"Convert from points to micas"
	scale ← (pointsize asFloat * 2540 / 72) asInteger.
	until⦂ found do⦂
		[self findfield: 4 on: file.
		found ← [file next = code].
		[file next ≠ face ⇒ [found ← false]].
		fmin ← file next.
		fmax ← file next.
		i ← file nextword. [i ≠ scale and: i ≠ 0 ⇒ [found ← false]].
		file skip: 4. start ← file nextword. file skip: 4].
	scale ← [i ≠ 0 ⇒ [1 "don't need to scale"] pointsize asFloat * 254 / 7200].
	min ← fmin. max ← fmax.
	"get bb and x-tables"
	file wordposition← start+1.
	descent ← 0 - (scale * file nextword) asInteger.
	file nextword.
	ascent ← (scale * file nextword) asInteger.
	file nextword.
	widths ← Vector new: (max - min + 1).
	for⦂ i to: widths length do⦂
		[w ← file nextword.
		widths◦i ← [w > 0 ⇒ [(scale * w) asInteger] 0]].
	file close]

SystemOrganization classify: ↪WidthTable under: 'Press File Support'.
WidthTable classInit 
