'From Smalltalk 5.5k XM November 24 on 4 October 1990 at 11:42:27 pm.'

"CharLine" 
Class new title: 'CharLine'
	subclassof: Object
	fields: '	starti "index of first character"
				stopi		"index of last character"
				spaces 	"# of ascii spaces in line"
				inset		"relative inset from normal line start"
				width	"line width, assuming some space width"
				measure	" max allowed line width" '
	declare: '';
	asFollows 

A CharLine specifies the parameters of a measured line of text.  The text, and its default spacing and alignment, etc. is contained in the TextBox (and the latters stylesheet)

Init/Access 
inset [⇑inset]
inset: inset
spaces [⇑spaces]
starti [⇑starti]
starti: starti
stopi [⇑stopi]
stopi: stopi spaces: spaces width: width
width [⇑width]

Measure info 
measure [⇑measure]
measure: measure
pad
	[⇑measure-width/(spaces max: 1)]
white
	[⇑measure-width]

SystemOrganization classify: ↪CharLine under: 'NewText'.

"Font" 
Class new title: 'Font'
	subclassof: Object
	fields: 'family pointsize minascii maxascii maxwidth length ascent descent xoffset raster glyphs xtable'
	declare: '';
	asFollows 

This class models the strike format for fonts.

Initialization 
fromStrike: name | strike i split	"Build instance from strike file."
	[name←name asUppercase.
	split←name length-1. [(name◦split) isdigit⇒[split←split-1]].
	family←name copy: 1 to: split.
	pointsize←(name copy: split+1 to: name length) asInteger.
	strike ← (dp0 oldFile: name + '.strike.').
	strike nextword.	"skip header"
	minascii ← strike nextword. maxascii ← strike nextword.
	maxwidth ← strike nextword. length ← strike nextword.
	ascent ← strike nextword. descent ← strike nextword.
	xoffset ← strike nextword.	"If (horrors!) we should ever kern."
	raster ← strike nextword. glyphs ← strike next: self byteraster * self height.
	xtable ← (Vector new: maxascii + 3) all← 0.
	for⦂ i from: (minascii + 1 to: maxascii + 3) do⦂ [xtable◦i ← strike nextword]]

Access to Parts 
ascent [⇑ascent]
byteraster [⇑raster * 2]
charForm: ascii ["should return a Form copied out of glyphs"]
descent [⇑descent]
family [⇑family]
glyphs [⇑glyphs]
height [⇑ascent + descent]  "height of font"
maxascii [⇑maxascii]
maxwidth [⇑maxwidth]
minascii [⇑minascii]
pointsize [⇑pointsize]
raster [⇑raster]
spacewidth | w
	[w ← self widthof: 040.
	w = 0 ⇒ [⇑4] ⇑w]
widthof: glyph [⇑(xtable◦(glyph + 2)) - (xtable◦(glyph + 1))]
xtable [⇑xtable]

SystemOrganization classify: ↪Font under: 'NewText'.

"FontSet" 
Class new title: 'FontSet'
	subclassof: Object
	fields: 'fonts'
	declare: '';
	asFollows 

Structure for holding a set of fonts.

Init/Access 
font: n
	[n>fonts length or⦂ n<1⇒[user notify: 'font index out of range'] ⇑fonts◦n]
fontfamily: f 
	[⇑(self font: f) family]
fonts [⇑fonts]
fontsize: f 
	[⇑(self font: f) pointsize]
fromVector: v | n 
	[v length>16⇒[user notify: 'font vector too long']
	fonts←Vector new: v length.
	for⦂ n to: v length do⦂ [fonts◦n←Font new fromStrike: v◦n]]
"
DefaultFontSet←FontSet new fromVector: ('timesroman12', 'helvetica10', 'helvetica12', 'oldenglish18').
"

SystemOrganization classify: ↪FontSet under: 'NewText'.

"ScreenPress" 
Class new title: 'ScreenPress'
	subclassof: BitBlt
	fields: '	x "position in micas"
				y "position in micas"
				spwidth "mica value for a space"
				fontcode "ffff00ib: font number/bold/italic for current font"
				font "the current strike Font"
				widths "the current width table"
				fonttab	"a vector (16) of fontcodes"
				fontindex "so that fonttab◦fontindex=fontcode"
				style "the current style (1 per press file)" '
	declare: '';
	asFollows 

I imitate a PressFile object, routing my output to the display. I currently understand text and rules (matching Spruce). The mica to point conversion factor, 2540/72 (~35.3), we approximate in tight loops by P=[M-(3M/32)]/32, because 29/1024=35.3 to 0.1%

Init/Access 
fontindex: fontcode style: newstyle | n
	[newstyle≠style and⦂ style≠nil⇒[user notify: 'invalid style']
	style←newstyle. fontcode←fontcode land: 0363.
	(n←fonttab find: fontcode)>0⇒[⇑n]
	"add entry to font dictionary"
	fonttab length=16⇒[user notify: 'too many fonts']
	fonttab←fonttab, fontcode. ⇑fonttab length]
init
	[super init. fontcode←¬1. fonttab←Vector new: 0. color←¬1 "default black".
	destbase←mem◦066. destraster←user screenrect width/32*2.
	self setx: 0; sety: 0]
strikepattern | s tint i
	[s←Set new string: 16. for⦂ i from: 127 to: 200 do⦂ [s next←i].
	user screenrect clear: white.
	self fontindex: 0 style: DefaultFontSet; selectfont: 0; setspacex: 100;
		setx: 2000; sety: 20000; setcolor: 5; showstr: s]
"
ScreenPress init strikepattern.
"

testpattern | s tint
	[s←'Folks, this is called Drop Shadowing'.
	user screenrect clear: white.
	self fontindex: 48 style: DefaultFontSet; selectfont: 0; setspacex: 100;
		setx: 2000; sety: 20000; setcolor: 2; showstr: s;
		setx: 2070; sety: 20070; setcolor: 5; showstr: s.
	for⦂ tint to: 9 do⦂
		[self setx: 1000+(tint*2000); sety: 25000; setcolor: tint; showrectwidth: 900 height: 900]]
"
ScreenPress init testpattern.
"

testpattern2 | s tint
	[s←'Folks, this is called Drop Shadowing'.
	user screenrect clear: ltgray.
	self fontindex: 48 style: DefaultFontSet; selectfont: 0; setspacex: 100;
		setx: 2000; sety: 20000; setcolor: 6; showstr: s.
	for⦂ tint to: 9 do⦂
		[self setx: 1000+(tint*2000); sety: 25000; setcolor: tint; showrectwidth: 900 height: 900]]
"
ScreenPress init testpattern2.
"

x [⇑x]
y [⇑y]

Setting State 
selectfont: newfont | n
	[newfont←newfont+1. newfont=fontindex⇒[]
	fontindex←newfont. fontcode←fonttab◦fontindex.
	n←(fontcode lshift: ¬4)+1. font←style font: n.
	widths←(WidthTable new named: (style fontfamily: n)
		pointsize: (style fontsize: n) face: (fontcode/2 land: 1)+(fontcode*2 land: 2)) lookup.
	sourceraster←font raster]
setcolor: c
	[color←↪(¬1 0 ¬32126 23130 21845 25500 27795 4740)◦c]
			"black white ltgray gray red green blue yellow"
setspacex: spwidth
setx: x
sety: y
showrectwidth: w height: h | ty
	[ty←27940-y-h. function←034 "store gray block to bank 1".
	desty←ty inPts. destx←x inPts. width←w inPts max: 1. height←h inPts max: 1.
	self callBLT]
showstr: str
	[self showstr: str first: 1 last: str length]
showstr: str first: fi last: li | xtab ch wid t bold yslices yslice xskew savxskew xsave tone chi
	[xtab←font xtable. xsave←x. sourcebase←font glyphs lock. bold←(fontcode land: 1)≠0.
	t←font height. [fontcode\4<2⇒[savxskew←0. yslices←t inVector]
		savxskew←font ascent/4. yslices←Vector new: t+3/4. yslices all←4; last←t-1\4+1]. 
	for⦂ tone to: 2 do⦂	"erase/paint loop"
		[tone-color=2⇒[] function←↪(023 "erase dest" 031 "or in under mask")◦tone.
		desty←(27940-y) inPts-font ascent. sourcey←0. xskew←savxskew.
		for⦂ yslice from: yslices do⦂	"italic (sliceup) loop"
			[height←yslice. x←xsave.
			for⦂ chi from: fi to: li do⦂		"character loop"
				[ch←str◦chi. [ch=040⇒[wid←spwidth] wid←widths widthof: ch.
					t←x lshift: ¬5. destx←((x-(t+t+t)) lshift: ¬5)+xskew.
					sourcex←(t←xtab◦(ch+1)). width←xtab◦(ch+2)-t. self callBLT. "char print"
					bold⇒[destx←destx+1. self callBLT]]. "embolden"
				x←x+wid].
			desty←desty+yslice. sourcey←sourcey+yslice. xskew←xskew-1]]. 
	font glyphs unlock]

SystemOrganization classify: ↪ScreenPress under: 'NewText'.

"ScreenPressFile" 
Class new title: 'ScreenPressFile'
	subclassof: PressFile
	fields: 'x y'
	declare: '';
	asFollows 

I augment class PressFile for text related functions, and also keep track of the last setx and sety, thus resembling ScreenPress

Access 
pressfile: name [⇑super of: (dp0 file: name)]
setcolor: c
	[super hue: ↪(0 0 0 0 0 80 140 40)◦c;
	saturation: ↪(0 0 0 0 255 255 255 255)◦c;
	brightness: ↪(0 255 100 150 255 255 255 255)◦c]
setx: x
	[super setx: x]
sety: y
	[super sety: y]
showstr: str 
	[self showstr: str first: 1 last: str length]
showstr: str first: fi last: li | w ch chi spwidth
	[super append: (str◦(fi to: li)); showchars: li-fi+1. spwidth←estate◦2.
	w←fontdefs◦(estate◦1+1). for⦂ chi from: fi to: li do⦂
		[ch←str◦chi. x←x+[ch=040⇒[spwidth]w widthof: ch]]]
testpattern | s tint i
	[s←'Folks, this is called Drop Shadowing'.
	user screenrect clear: white.
	self fontindex: 51 style: DefaultFontSet; selectfont: 0; setspacex: 100.
	for⦂ i to: 10 do⦂
		[self setx: 2000; sety: 2000*i; setcolor: 4; showstr: s;
		setx: 2000+i; sety: 2010*i; setcolor: 5; showstr: s]] 
"
|P. P←ScreenPressFile new pressfile: 'shadow.press'. P testpattern; close.
"

x [⇑x]
y [⇑y]

SystemOrganization classify: ↪ScreenPressFile under: 'NewText'.

"Text" 
Class new title: 'Text'
	subclassof: Object
	fields: '	para				"the text"
				color				"0..7 denoting a color"
				lines				"vector of CharLines"
				lastline			"index 1≤lastline≤lines length of last visible line"
				fontset			"the ≤16 fonts used"
				linespercol		"# of lines per column"
				columns		"# of columns --all subsequent values are in Micas"
				origin			"the upper-lefthand corner of the text"
				tabs				"vector of monotonically increasing offsets"
				lineheight		"baseline to baseline; bodyheight+leading"
				bodyheight		"char height of body text"
				ascent			"dist above baseline for body text"
				descent			"dist beneath baseline (pos)"
				minsp			"default interword space"
				maxsp			"max interword space"
				linemeasure	"default line measure"
				columnspace	"inter column spacing " '
	declare: 'attributes curface chartype curwidths ';
	asFollows 

I window text taken from para onto a screen or page, defined in region frame, using fonts and line measures from style. lines maintains line break and line measure info.

Init/Access 
attributes [⇑attributes viewee: self]
attributesInit "Text classInit. Text new attributesInit."
	|	unitviewer integerviewer colorviewer
		columnsmenu linesmenu spacingmenu
	[	unitviewer←UnitViewer default units:
			(('micas',1) inVector, ('pts',35.3), ('picas',423.3), ('cm',899.75), ('in',2540.0)).
		integerviewer←[AttributeViewer new
			toString:		↪asString;
			fromString⦂	[attributeValue←attributeText asStream integerScan asInteger] ].
		colorviewer←[AttributeViewer new
			menu: [ActionMenu new
				stringFromVector:
					('black','white','light gray','gray','red','green','blue','yellow'); init;
				action←(0,1,2,3,4,5,6,7)] ].
		linesmenu←AttributeMenu new.
			linesmenu title: 'total number';
				extract: ↪totlines; assign: nil; viewer: integerviewer copy.
			linesmenu title: 'per column';
				extract: ↪linespercol; assign: nil; viewer: integerviewer copy.
			linesmenu title: 'default measure';
				extract: ↪linemeasure; assign: nil; viewer: unitviewer copy.
		columnsmenu←AttributeMenu new.
			columnsmenu title: 'number';
				extract: ↪columns; assign: nil; viewer: integerviewer copy.
			columnsmenu title: 'spacing';
				extract: ↪columnspace; assign: nil; viewer: unitviewer copy.
		spacingmenu←AttributeMenu new.
			spacingmenu title: 'body height';
				extract: ↪bodyheight; assign: nil; viewer: unitviewer copy.
			spacingmenu title: 'leading';
				extract: ↪linelead; assign: 'linelead:'; viewer: unitviewer copy.
			spacingmenu title: 'min interword';
				extract: ↪minsp; assign: nil; viewer: unitviewer copy.
			spacingmenu title: 'max interword';
				extract: ↪maxsp; assign: nil; viewer: unitviewer copy.
		attributes←AttributeMenu new.
			attributes title: 'Color';
				extract: ↪color; assign: 'color:'; viewer: colorviewer.
			attributes title: 'Columns⇒';
				extract: ↪itself; assign: nil; viewer: columnsmenu.
			attributes title: 'Lines⇒';
				extract: ↪itself; assign: nil; viewer: linesmenu.
			attributes title: 'Spacing⇒';
				extract: ↪itself; assign: nil; viewer: spacingmenu  ]
bodyheight [⇑bodyheight]
charInit "Text classInit. Text new charInit."
	[	chartype←String new: 256.
		chartype all←4.		"Normal Char"
		chartype◦011←0.	"Tab"
		chartype◦015←1.	"<CR>"
		chartype◦040←2.	"Space"
		chartype◦020←3.	"Misc. Spacing"
		chartype◦055←5.	"Hyphen"
		curface←false  ]
classInit "Text classInit."
	[	self attributesInit; charInit  ]

color [⇑color]
color: color
columns [⇑columns]
columnspace [⇑columnspace]
frame
	[⇑(origin x)⌾(origin y-descent-2) extent:
		(linemeasure+columnspace*columns-columnspace)⌾(linespercol*lineheight)]
frame: frame para: para fontset: fontset columns: columns | i
	[origin←frame origin copy.
	bodyheight←(fontset font: 1) height inMicas. lineheight←bodyheight+71.
	tabs←lineheight inVector. minsp←bodyheight/5. maxsp←bodyheight.
	ascent←465. descent←92. columnspace←400.
	linemeasure←frame width-(columns-1*columnspace)/columns.
	linespercol←frame height/lineheight.
	lines←Vector new: self totlines. color←0. "black"
	for⦂ i to: self totlines do⦂
		[lines◦i←CharLine new. lines◦i measure: linemeasure; inset: 0] ]
lastline [⇑lastline]
lastshown [⇑(lines◦lastline) stopi]
linelead [⇑lineheight-bodyheight]
linelead: linelead [lineheight←bodyheight+linelead]
linemeasure [⇑linemeasure]
lines [⇑lines]
linespercol [⇑linespercol]
maxsp [⇑maxsp]
minsp [⇑minsp]
origin [⇑origin]
origin: origin
para [⇑para]
ptframe: f para: p
	[self frame: f inMicas para: p fontset: DefaultFontSet columns: 1]

ptframe: f para: p columns: columns
	[self frame: f inMicas para: p fontset: DefaultFontSet columns: columns]
test
"
|P T f i.
P←('This is an easy little test, which tries to fit as much text as it can into a large oval. As you can see, it is quite nice.  Sorry that the text is rather trite, but this is needed to test out the code. Of course, any shape will do, but those with simple math defs. are best, on the whole.') asParagraph. P allFont: 0. P alignment←1. T←Text new ptframe: Rectangle new usersize para: P columns: 2.
user screenrect clear: white. T outline. T showall. while⦂ user anybug do⦂
	[(T rectofline: (T lineofpt: user mp inMicas)) inPts comp]
"
totlines [⇑linespercol*columns]

Copy Fitting 
copyfitall [self copyfitall: 1]
copyfitall: firsti [(lines◦1) starti: firsti. self copyfitfrom: 1 to: lines length]
copyfitfrom: startline to: stopline | maxlength chari i curline
	[maxlength←para length. chari←(lines◦startline) starti.
	for⦂ i from: startline to: stopline do⦂
		[chari←chari+[chartype◦(para text◦chari)>3⇒[0] 1].
		(curline←lines◦i) starti: chari. self fitline: curline.
		(chari←curline stopi+1)>maxlength⇒[lastline←i. ⇑nil] ].
	lastline←lines length]
fitline: line
| em width bwidth spaces bspaces chari bchari rs ri rlen body oldbody lasti ch
	[em←bodyheight. width←bwidth←spaces←bspaces←0.
	chari←bchari←line starti. lasti←para length. body←4.
	rs←para runfind: line starti. ri←rs◦1. rlen←(para runs◦ri)-(rs◦2)+1.
	self widthtable: para runs◦(ri+1).
	until⦂ ((width≥line measure or⦂ chari>lasti) or⦂ (body=1)) do⦂
		[[body=5⇒[bwidth←width. bspaces←spaces. bchari←chari]]. "was hyphen"
		[rlen=0⇒[ri←ri+2. rlen←para runs◦ri. self widthtable: (para runs◦(ri+1))]]. "new run"
		ch←para text◦chari. oldbody←body. body←chartype◦ch.
		[body<4⇒[[oldbody>3⇒[bwidth←width. bspaces←spaces. bchari←chari]]. "sp tab cr white"
			body=2⇒[width←width+minsp. spaces←spaces+1]; =0⇒[width←width+em|em]]].
		[body>2⇒[width←width+(curwidths widthof: ch)]]. "white text hyphen"
		chari←chari+1. rlen←rlen-1].
	chari>lasti or⦂ spaces=0⇒[line stopi: chari-1 spaces: spaces width: width]
		line stopi: bchari-1 spaces: bspaces width: bwidth]
shrinktofit | i
	[linemeasure←0.
	for⦂ i to: lastline do⦂ [linemeasure←linemeasure max: (lines◦i) width].
	for⦂ i to: lastline do⦂ [(lines◦i) measure: linemeasure].
	self copyfitall]
	
widthtable: face | i
	[face≠curface⇒
		[curface←face. i←(face lshift: ¬4)+1.
		curwidths←(WidthTable new named: (fontset fontfamily: i)
		pointsize: (fontset fontsize: i)
		face: (face/2 land: 1)+(face*2 land: 2)) lookup. ⇑curwidths]]

Layout Info 
xend: linei 
	[⇑(self xstart: linei)+((lines◦linei) measure)]
xstart: linei
	[⇑origin x+(lines◦linei) inset+(linei-1/linespercol*(linemeasure+columnspace))]
ystart: linei 
	[⇑origin y+(linespercol-(linei-1\linespercol+1)*lineheight)]

Displaying 
displaylines: firsti to: lasti press: p | linei line curi newcuri runs runi run x1 y1 x2
	[p setcolor: color+1.
	for⦂ linei from: firsti to: lasti do⦂
		[line←lines◦linei. curi←line starti. curi≡nil⇒[⇑nil]
		p	sety: (self ystart: linei);
			setx: (self xstart: linei)+[para alignment=2⇒[line white/2]; =3⇒[line white]0];
			setspacex: ((minsp+[para alignment=1⇒[line pad]0]) min: maxsp).
		runs←(para run: line starti to: line stopi).
		for⦂ runi from: (1 to: runs length by: 2) do⦂
			[p	selectfont: ((p fontindex: (run←runs◦(runi+1)) style: fontset)-1). x1←p x.
			p showstr: para text first: curi last: (newcuri←runs◦runi+curi-1). curi←newcuri+1.
			[(run land: 12)≠0⇒[x2←p x. y1←self ystart: linei. p setx: x1]].
			[(run land: 4)≠0⇒[p sety: ascent/4+y1; showrectwidth: x2-x1 height: 20]].
			[(run land: 8)≠0⇒[p sety: y1-descent; showrectwidth: x2-x1 height: 20]].
			[(run land: 12)≠0⇒[p setx: x2; sety: y1]]]]]
outline
	[self frame inPts boxcomp]
presson: press
	[self displaylines: 1 to: lines length press: press]
showall [self presson: (ScreenPress init)]
unshowall [self frame inPts clear: white]
unshowlines: startline to: stopline | i
	[for⦂ i from: startline to: stopline do⦂ [(self rectofline: i) inPts clear: white] ]

Line Selection 
lastusedline
	[⇑self lineofchar: para text length]
lineofchar: chari | i
	[chari=0⇒[⇑1]. for⦂ i to: lastline do⦂
		[(lines◦i) starti≡nil or⦂ ((lines◦i) starti-1>chari)⇒[⇑i-1]].
	⇑self lastline]
"lineofchar: chari | lo mid hi
	[chari=1⇒[⇑1] hi←self totlines+1.  lo←1.
	while⦂ lo<hi do⦂
		[(lines◦(mid←lo+hi/2)) starti<chari⇒[hi←mid] lo←mid+1].
	⇑hi-1]	0≤result≤length"
lineofpt: pt | x y row col
	[x←pt x-origin x. y←pt y-origin y.
	col←(x/(linemeasure+columnspace) min: columns-1) max: 0.
 	row←(linespercol-1-(y/lineheight) min: linespercol-1) max: 0.
	⇑(col*linespercol+row+1) min: lastline]
rectofline: linei
	[⇑Rectangle new origin: ((self xstart: linei)⌾((self ystart: linei)-descent))
		extent: (lines◦linei) measure⌾(ascent+descent)]
widthsofline: linei | line em firsti lasti m chi pad width rs rlen ch
	[line←lines◦linei. em←bodyheight. firsti←line starti. lasti←line stopi.	
	m←Vector new: (lasti-firsti+2). width←self xstart: linei.
	pad←(minsp+[para alignment=1⇒[line pad]0]) min: maxsp.
	width←width+[para alignment=2⇒[line white/2]; =3⇒[line white]0].
	m◦1←width. rs←(para run: firsti to: lasti) asStream. rlen←0.
	for⦂ chi from: firsti to: lasti do⦂ "chari>lasti needed?"
		[[rlen=0⇒[rlen←rs next. self widthtable: rs next]]. "new run"
		ch←para text◦chi.
		[(chartype◦ch)
			=2⇒[width←width+pad]; "space"
			=1⇒[];	"cr"
			=0⇒[width←width+em|em].	"tab"
			width←width+(curwidths widthof: ch)]. "else: white, text or hyphen"
		m◦(chi-firsti+2)←width. rlen←rlen-1]. ⇑m]

SystemOrganization classify: ↪Text under: 'NewText'.
Text classInit

"TextEditor" 
Class new title: 'TextEditor'
	subclassof: Object
	fields: 'text currect curline curmeasure c1line c1index c1offset c2line c2index c2offset line index offset attributes'
	declare: 'alignmenu fontmenu cutbuffer CrossCursor cursor editmenu lookmenu ';
	asFollows 

I edit the para in a textbox. I also change other TextBox fields

Init/Access 
classInit "TextEditor classInit."
	[	self cursorInit; menuInit; editInit  ]
cursorInit "TextEditor classInit. TextEditor new cursorInit."
	[	CrossCursor←Cursor new fromtext: '
0000000000000000
0000000010000000
0000000010000000
0000000010000000
0000000010000000
0000000010000000
0000000010000000
0000000010000000
0111111111111111
0000000010000000
0000000010000000
0000000010000000
0000000010000000
0000000010000000
0000000010000000
0000000010000000' offset: 8⌾8  ]
edit: text | frame pt
	[c1index←c2index←(text lines◦1) starti-1. self pointofindicies; selectall.
	frame←text frame inPts. attributes←false.
	while⦂ true do⦂
		[while⦂ user nobug do⦂ [self updateCursor. user kbck⇒[self kbd] ].
		user redbug⇒
			[self attributesAt: (pt←user mp)⇒
				[self attributesEdit]
				frame has: pt⇒
					[self redbug]
					self selectall; unshowAttributes. ⇑nil]
		user yellowbug⇒[self yellowbug] ] ]
editInit "TextEditor classInit. TextEditor new editInit."
	|	i arrow
	[	cutbuffer←''.
	 	arrow←String new: 12.
		for⦂ i to: 6 do⦂ [arrow word: i←(↪(4 14 31 4 4 4)◦i) lshift: 11].
		cursor←Form new. cursor extent: (16⌾6); bits: arrow  ]
menuInit "TextEditor classInit. TextEditor new menuInit."
	|	v i
	[	v←Vector new: 0.
		for⦂ i from: DefaultFontSet fonts do⦂
			[v←v,((i family copy: 1 to: (i family length min: 4))+i pointsize asString)].
		editmenu←MenuSet new default init.
			editmenu add: [(ActionMenu new) string:
'copy
paste
cut
font⇒
look⇒
align⇒
attributes'; init].
			editmenu add: [(ActionMenu new) stringFromVector: v; init].
			editmenu add: [(ActionMenu new) string:
'clear
bold
italic
underscore
strikeout'; init].
			editmenu add: [(ActionMenu new) string:
'left flush
justify
center
right flush'; init].
			editmenu firstmenu←1.
			editmenu menu: 1 line: 4 tomenu: 2.
			editmenu menu: 1 line: 5 tomenu: 3.
			editmenu menu: 1 line: 6 tomenu: 4  ]
test | P T "TextEditor new test."
	[P←('This is an easy little test, which tries to fit as much text as it can into a large oval. As you can see, it is quite nice. Sorry that the text is rather trite, but this is needed to test out the code. Of course, any shape will do, but those with simple math defs. are best, on the whole. Note too, that the border may in fact be a curved line, as is the case here, and not simply a set of straight edges. Sorry that the text is rather silly, but this is needed to test out the code. Of course, any shape will do, but those with simple math defs. are best, on the whole. Note too, that the border may in fact be a curved line, as is the case here, and not simply a set of straight edges. Well now, I hope you liked our little demo.') asParagraph.
	P allFont: 0. P alignment←1. user screenrect clear: white.
	T←Text new ptframe: Rectangle new usersize para: P columns: 2.
"	T←Text new ptframe: (271⌾33 rect: 471⌾200) para: P columns: 2.  "
	T copyfitall; showall; outline. self edit: T]

Selection/Keyboard 
charpoint | pt charline i newline oldindex
	[oldindex←index. [pt←user mp inMicas. [(currect has: pt)⇒[]
		curline←text lineofpt: pt. currect←text rectofline: curline.
		curmeasure←text widthsofline: curline].
	charline←(text lines)◦curline. line←curline.
	pt x≤(curmeasure◦1)⇒[index←charline starti-1. offset←curmeasure◦1];
		≥(curmeasure last)⇒[index←charline stopi. offset←curmeasure last].
	i←curmeasure findSorted: pt x.
	[(curmeasure◦(i+1)-pt x)>(pt x-(curmeasure◦i))⇒[i←i-1]].
	index←charline starti+i-1. offset←curmeasure◦(i+1)]. ⇑oldindex≠index]
doubleclick | min thismax nextmax lbody rbody
	[min←(text lines◦c1line) starti-1. thismax←(text lines◦c1line) stopi.
	[c1line=text lines length⇒[nextmax←text para length]
		nextmax←(text lines◦(c1line+1)) starti-1].
	[c1index=min⇒[c2index←nextmax]	"line select or rangle select"
		until⦂ (c1index=min or⦂ text para◦c1index=040) do⦂ [c1index←c1index-1].
		until⦂ (c2index=thismax or⦂ text para◦(c2index+1)=040) do⦂ [c2index←c2index+1]].
	self pointofindicies]
kbd | s
	[s←Set new string: 16. while⦂ user kbck do⦂ [s next←user kbdnext].
	self replacewith: s select: false]
pointofindicies | i
	[c1line←text lineofchar: c1index. curmeasure←text widthsofline: c1line.
	i←c1index-(text lines◦c1line) starti+2.
	[i>curmeasure length⇒[c1offset←curmeasure last] c1offset←curmeasure◦i].
	c2line←curline←text lineofchar: c2index. curmeasure←text widthsofline: c2line.
	i←c2index-(text lines◦c2line) starti+2.
	[i>curmeasure length⇒[c2offset←curmeasure last] c2offset←curmeasure◦i].
	currect←text rectofline: c2line]
redbug
	[self selectall. "deselect".
	c1index=c2index and: self charpoint=false⇒[self doubleclick; selectall] "side-effect"
	c2line←c1line←line. c2index←c1index←index. c2offset←c1offset←offset.
	self select. while⦂ user redbug do⦂
		[self charpoint⇒[self select. c1index←index. c1offset←offset. c1line←line].
		c2index=index⇒[self showcursor; showcursor]]
	c2index=index⇒[self showcursor]]
select | l1 l2 c1 c2 o1 o2 r i
	[[index<c1index⇒
		[l2←line. l1←c1line. c2←index. c1←c1index. o2←offset. o1←c1offset]
		l1←line. l2←c1line. c1←index. c2←c1index. o1←offset. o2←c1offset].
	r←[l2=curline⇒[currect copy] text rectofline: l2]. r origin x←o2.
	l1=l2⇒[r corner x←o1. r pointize comp]
	r pointize comp. for⦂ i from: l2+1 to: l1-1 do⦂ [(text rectofline: i) pointize comp].
	r←text rectofline: l1. r corner x←o1. r pointize comp]
	
selectall
	[c2index=c1index⇒[self showcursor] line←c2line. index←c2index. offset←c2offset.
	self select. c2line←line. c2index←index. c2offset←offset]
selection [⇑text para copy: (c1index min: c2index)+1 to: (c1index max: c2index)]
showcursor
	[cursor displayat: (((text widthsofline: c2line)◦(c2index-(text lines◦c2line) starti+2))-71⌾
		(text ystart: c2line)) inPts effect: xoring clippedBy: nil]

Menu/Actions 
align: i
	[text unshowall. text para alignment←i-1. text showall. self selectall]
font: i
	[self replacewith: (self selection maskrunsunder: 0360 to: (i-1*16))
	select: true]
look: i
	[self replacewith: (self selection maskrunsunder: ↪(15 1 2 8 4)◦i to: ↪(0 1 2 8 4)◦i)
		select: true]
replacewith: scrap select: sflag | c1 c2 l1 l2 last i
	[c1←(c1index min: c2index)+1. c2←c1index max: c2index.
	l1← c1line min: c2line. l2←c1line max: c2line.
	self selectall.
	text para replace: c1 to: c2 by: scrap.
	text copyfitfrom: l1 to: text totlines.	"optimize later"
	last←text lastline.
	text unshowlines: l1 to: text totlines.
	text displaylines: l1 to: last press: (ScreenPress init).
	c1index←c1-1+scrap length. [sflag⇒[c2index←c1-1] c2index←c1index].
	self pointofindicies; selectall]
yellowbug | v menu item
	[(v←editmenu bug)≡false⇒[ ]
	menu←editmenu find: v◦1. item←v◦2.
	menu
		=1⇒	"main"				[item
				=1⇒	"copy"			[cutbuffer←self selection];
				=2⇒	"paste"			[self replacewith: cutbuffer select: true];
				=3⇒	"cut"				[cutbuffer←self selection. self replacewith: '' select: true];
				=7⇒	"attributes"	[self flipAttributes] ];
		=2⇒	"font⇒"					[self font: item];
		=3⇒	"look⇒"					[self look: item];
		=4⇒	"align⇒"				[self align: item] ]

Attributes 
attributes [⇑text attributes]
attributesAt: pt [attributes⇒[⇑attributes has: pt] ⇑false]
attributesEdit | f
	[NormalCursor show. self selectall. f←text frame inPts.
	[attributes Bug⇒
		[attributes unshow.
		f clear: white. text copyfitall: ((text lines◦1) starti); showall.
		attributes reshow] ].
	self selectall]
flipAttributes [attributes⇒[self unshowAttributes] self showAttributes]
showAttributes | pt
	[CrossCursor show. user waitbug. pt←user mp. NormalCursor show.
	attributes←text attributes. attributes showat: (pt-(attributes frame extent/2))]
unshowAttributes [attributes⇒[attributes unshow. attributes←false] ]

Cursor Control 
updateCursor [self attributesAt: user mp⇒[CrossCursor show] NormalCursor show]

SystemOrganization classify: ↪TextEditor under: 'NewText'.
TextEditor classInit

