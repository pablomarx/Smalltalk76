'From Smalltalk 5.5k XM November 24 on 22 November 1980 at 2:57:08 am.'
\g
"FontWindow"l15000z20000\gbf5 
Class new title: 'FontWindow'
	subclassof: Object
	fields: 'frame font fontht fontraster fontxtabl bitsetter char charx charwid charstr altostyle fontnumber clearframe scale boxer'
	declare: 'fontmenu ';
	asFollows\gbf5 

I am a window that displays one blown up character at a time of a strike-format font\gi

Help\gbf5 
help
["
**sysFontWindow is declared in the Smalltalk dictionary, and bound to the font window displayed on the screen of most system releases -- intended to provide an easy way to play around with the font editor.
**to create a window for editing default font 0 at middle-click:
	 user schedule: (sysFontWindow _ FontWindow new
		altostyle: DefaultTextStyle
		fontnumber: 1
		at: (OriginCursor showwhile
			[user waitbug [user mp]])).
**to create a new font
	yourfont _ FontWindow new newfont: 16 maxcharwidth: 16 min: 0
			max: 177 ascent: 12 kern: 0.

**to edit newly created font
	yourtextstyle setfont: n name: yourfont.	**insert it into a TextStyle
	**now create a window as above with yourtextstyle and appropriate
		fontnumber
	

**examples of manual manipulation of yourfontwindow:
	sysFontWindow setascent: 2.	**Deltas -- for entire font**
	sysFontWindow setascent: 3.
	sysFontWindow setdescent: 2.
	sysFontWindow setdescent: 2.
	sysFontWindow setchar: 046.
	sysFontWindow setwidth: 5.	**Absolute--for char in window. 
	Useful for characters of zero width.**
"]\gb5B1i1067I

Initialization\gbf5 
altostyle: altostyle fontnumber: fontnumber at: origin
	[		"set up an instance"
	[fontmenunil[self init]].
	scale _ 9. charstr _ String new: 1. char _ 65. charstr1 _ char.
	bitsetter _ BitBlt init.
	boxer _ Rectangle new
				origin: 0  0 extent: (scale-1)  (scale-1).
	frame _ Rectangle  new origin: origin  extent:  scale  0.
	clearframe _ Rectangle  new origin: origin  extent:  scale  0.
	self setfont: altostyle fontsfontnumber.
	]\gb56B3i20I
classInit
	[fontmenu _ Menu new string:
'strike
set width
debug
move
close']\gb11B

Scheduler\gbf5 
eachtime							"while active"
	[clearframe has: user mp
		[user redbug 
			[self setbit: user mp color: black]				"make dot black"
		user yellowbug 
			[self setbit: user mp color: white]				"make dot white"
		user bluebug 
			[fontmenu bug
				=1[self strike];			"put strike of font in dialogue window"
				=2[self setwidth];								"grow character"
				=3[self updateseglength: font raster: fontraster.
						self updatemaxwidth.		"clean things up"
						user notify: 'font debugging'];
				=4[self frame];									"move fontwindow"
				=5[clearframe clear.
						self updateseglength: font raster: fontraster.
						self updatemaxwidth.		"clean things up"
						user unschedule: self. false]]
		user kbck
			[char _ user kbd. self setchar: char]
		]
	user anybug[false]
	]\gb15Bi14I87i16I62i16I59i39I32i16I84i17I68i17I108i17I
 firsttime						"upon entry"
	[
	clearframe has: user mp[self show]
	false
	]\gb16Bi12I
lasttime						"upon exit"
	[]\gb14Bi11I

Editing\gbf5 
setascent: ascentdelta | updatedfont ascent
	[								 "ascent delta"
	ascent _ font word: 6.
	[ascent + ascentdelta < 0 [ascentdelta _ 0 - ascent]].
	[ascentdelta > 0 
		[
		updatedfont _ String new: (2 * fontraster * ascentdelta).		"grow"
		updatedfont all _  0.			"fill with white"
		updatedfont _		"add oldfont header and new space together"
			(font(1 to: 18) concat: updatedfont(1 to: updatedfont length)).
		updatedfont _		"now add on rest of old font"
			(updatedfont concat: font(19 to: font length)).
		]
	updatedfont _ (font(1 to: 18) concat:								"shrink"
		font((19 + (0 - (2 * fontraster * ascentdelta))) to: font length)).
	].
	updatedfont word: 6 _ ascent + ascentdelta.	"reset ascent word in font"
	self setfont: updatedfont.					"updatedfont now font of interest"
	self updateseglength: font raster: fontraster.
	]\gb23B32i14I167i6I27i17I18i43I87i29I104i8I121i27I33i35I
setbit: bitpoint color: color		"turn bits on, off"
								| x y
	[
	bitpoint _  bitpoint - frame origin.
	 x _ (0 max: (charwid-1)) min: (bitpoint x/scale).
	 y _ (0 max: (fontht-1)) min: (bitpoint y/scale).
	 boxer moveto: frame origin + ((scale*x)  (scale*y)).
	 boxer color: color mode: storing.						"turn bit on/off in blowup"

	bitsetter destraster _ fontraster.						"set up bitblt table."
	bitsetter destx _ charx + x.
	bitsetter desty _ y.
	bitsetter destbase _ font; dstrike_ true.  "lock font and get core ptr"
	bitsetter fill: storing color: color.						"turn bit on/off in font"]\gb31Bi19I256i27I43i22I97i28I45i25I
setchar: char
	[
	charstr1 _  char.
	[((font word: 2)  char) and: (char  (font word: 3))
	[char _ char - (font word: 2)]
	char _ ((font word: 3) - (font word: 2)) + 1].	"char out of range"
	charx _ (font word: (fontxtabl+ (char))).
	charwid _ (font word: (fontxtabl + char+1)) - charx.
	clearframe clear.
	frame extent _ charwid   fontht.
	clearframe _
		frame inset: 2  2							"for clearing everything including outline"
		and: (charwid - (charwid * scale + 2))  (fontht - (fontht * scale + 2)).
	self show.
	]\gb15B158i19I195i43I
setdescent: descentdelta | updatedfont descent space
	[								"descent delta"
	descent _ font word: 7.
	[descent + descentdelta < 0  [ descentdelta _ 0 - descent]].
	[descentdelta > 0 
			[space _ String new: 2 * fontraster * descentdelta.
			space all _ 0.
			updatedfont _ (font  (1 to: fontxtabl - 1 * 2) concat: space).
			updatedfont _ (self appendxtable: updatedfont).
			]
	updatedfont _
		(font  (1 to: ((fontxtabl - 1 * 2) + (fontraster * descentdelta * 2)))).
	updatedfont _ (self appendxtable: updatedfont).
	].
	updatedfont word: 7 _
		descent + descentdelta.	"reset descent word in font"
	self setfont: updatedfont.	"updatedfont now font of interest"
	self updateseglength: font raster: fontraster.
	]\gb25B38i15I499i28I29i35I
setfont: font
	[
	altostyle fonts  fontnumber _ font.
	fontraster _ font word: 9.
	fontht _ (font word: 6) + ( font word: 7).		"ascent + descent"
	fontxtabl _ fontraster * fontht + 9 "header" + 1 "for 0 addressing".
	bitsetter width _  1. bitsetter height _ 1.
	self setchar: charstr1.
	]\gb15B113i18I38i8I5i18I
setwidth | newextentx outlineframe
	[						"get new size"
	outlineframe _ clearframe inset: 1  1 and: 0  1.
	OriginCursor showwhile
		[user waitbug
			[while user anybug do
				[outlineframe growto:
				((clearframe origin x + 2) +
						(newextentx _ (user mp x - clearframe origin x + 2) | scale))
					  (outlineframe corner y).
				outlineframe border: 2 color: black.
				outlineframe border: 2 color: background
				].
			].
		].
		outlineframe border: 2 color: black.
		self setwidth: newextentx / scale.
	]\gb9B34i14I
setwidth: delta
	| fontrightx newraster newxtabl newmaxwidth updatedfont i

	[						"change in width"
	delta _ delta - charwid. delta = 0  [self show. false].
	fontrightx _
		font word: (fontxtabl + ((font word: 3) - (font word: 2)) + 2).
	newraster _
		[(fontrightx + 15 / 16)  (i _ (fontrightx + delta + 15 / 16)) 
		[ i ] fontraster].
	newxtabl _ newraster * fontht + 9 "header" + 1 "for 0 addressing".

	XeqCursor showwhile 
	[
	updatedfont _ String new:
	(9 "header" + (newraster * fontht "bits")) * 2.		"grow/shrink the bits"
	for i to: 8 do
		[updatedfont word: i _ font word: i].			"fill in header of new font"
	updatedfont word: 9 _ newraster.					"set raster in new font"
	"copy the xtable"
	updatedfont _ (self appendxtable: updatedfont).

	"set up to copy up to old bits of char"
	bitsetter destraster _ newraster.
	bitsetter destx _ 0. bitsetter desty _ 0.
	bitsetter sourcex _ 0. bitsetter sourcey _ 0.
	bitsetter width _ charx + charwid.
	bitsetter height _ fontht.
	bitsetter sourceraster _ fontraster.
	bitsetter destbase _ updatedfont.
	bitsetter sourcebase _ font.
	bitsetter sstrike_ true; dstrike_ true.
	bitsetter copy: storing.
		[					"if char grown, clean out right side of char"
		delta< 0 []
		bitsetter destx _ charx + charwid.
		bitsetter width _ delta.
		bitsetter fill: storing color: 0.
		].
			"now copy remainder of font"
	bitsetter destx _ charx + charwid + delta.
	bitsetter width _ fontrightx - charx - charwid.
	bitsetter sourcex _ charx + charwid.
	bitsetter copy: storing.
		"shift x-vals"
	for i from: ((char + 1)
		to: (2 + (updatedfont word: 3) - (updatedfont word: 2) "max")) do
		[updatedfont word: (newxtabl + i) _
				delta + (updatedfont word: (newxtabl +i ))].
	clearframe clear.						"clear out old version of character"
	self setfont: updatedfont.			"set up the new copy of the font"
	self updateseglength: font raster: fontraster.
	self updatemaxwidth.
	].
	]\gb17B67i17I276i8I5i18I60i8I23i6I9i22I61i28I39i24I2i17I52i39I368i45I124i28I160i14I84i5I118i37I30i33I

Image\gbf5 
frame
	[clearframe clear.
	frame moveto:
	(OriginCursor showwhile
		[user waitbug[user mp]]).
	self setchar: char.
	]\gb7B
show |									"refresh window"
					tempframe showrun showpara
	[
	showrun _ String new: 2.
	showrun word: 1 _  16 * (fontnumber-1) + 0177400.
	showpara _ Paragraph new text: charstr runs: showrun alignment: 0.
	tempframe _ Textframe new para: showpara frame: frame style: altostyle.
	tempframe show.
	frame blowup: (frame origin) by: scale.
	]\gb5B10i16I

Strike format\gbf5 
appendxtable: thefont
	[										"put fontxtable on end of a grown/shrunk font"
	thefont _ thefont concat: font  ((fontxtabl * 2 - 1) to: font length).
	thefont.
	]\gb23B11i47I
cufixup |  "Carnegie-Mellon fixup for scale compatibility"
	[boxer extent _ (scale-1)(scale-1).
	frame extent _ scale0.
	clearframe extent _ scale0.
	]\gb8B3i47I
makecu: name scale: cuscale  "Put out font in Carnegie-Mellon format"
		| f svscale svchar  bitwidth i bitmover bits
	[f _ dp0 file: name + '.cu.'.
	self updateseglength: font raster: fontraster.  self updatemaxwidth.
	svscale _ scale. scale _ cuscale.  svchar _ char.
	self cufixup.
	f nextword _ fontht*scale.
	f nextword _ (bitwidth _ (font word: 4)) * scale + 15 / 16.
	bits _ String new: ((fontht * scale) * ((bitwidth * scale + 15)/16)) * 2.
	bitmover _ BitBlt init.
	bitmover destbase _ bits lock.
	bitmover destraster _ bitwidth * scale + 15 / 16.
	bitmover destx _ 0.
	bitmover desty _ 0.
	bitmover sourcebase _ mem066.
	bitmover sourceraster _ (user screenrect extent x) + 15/16.
	bitmover sourcex _ frame origin x.
	bitmover sourcey _ frame origin y.
	
	for i from: ((font word: 2) to: (font word: 3) by: 1) do
		[self setchar: i.
		f nextword _ i. f nextword _ charwid*scale.
		bitmover width _ (frame extent x) * scale.
		bitmover height _ (frame extent y) * scale.
		bits all _ 0.
		bitmover copy: storing.
		f append: bits].
	f close. scale _ svscale. self cufixup. bits unlock. self setchar: svchar]\gb29Bi40I
newfont: fontht maxcharwidth: maxcharwidth min: min max: max ascent: ascent kern: kern
	| raster i x
	[XeqCursor showwhile
		[raster _ (2 + max - min * maxcharwidth + 15)/16.
		font _ String new:  (3 + max - min + (fontht * raster) + 9 * 2).
		font word: 1 _ 0100000.											"format: strike, simple, varwidth"
		font word: 2 _ min.												"min ascii code"
		font word: 3 _ max.												"max ascii code"
		font word: 4 _ maxcharwidth.										"max char width"
		font word: 5 _ (2+max-min + 5 + (fontht*raster)).			"segment length"
		font word: 6 _ ascent.												"bits above baseline"
		font word: 7 _ fontht-ascent.										"bits below baseline"
		font word: 8 _ kern.												"kerning offset"
		font word: 9 _ raster.												"#words per scan-line in bitmap"

		(font((18 + 1) to: 2 * raster * fontht + 18)) all _ 0.		"chars all white"

		ascent _ ascent min: (fontht-1).									"keep baseline within char"
		(font(2 * raster * ascent + 18 + 1 to:
				ascent+1*raster*2 + 18)) all _ 0377.						"put in a black baseline"

		x _ 0.
		for i  from: (raster * fontht + 9 + 1 to:
					raster * fontht + 9 + 3 + max - min by: 1) do
			[font word: i _ x. x _ x+maxcharwidth].					"table of left x"
		].
	font.
	]\gb88B191i34I34i16I34i16I41i16I55i16I37i21I42i21I35i16I37i32I61i17I45i27I89i25I155i17I
strike | i	showstr "Put a strike of font into dialogue window"
	[showstr _ String new: 128. for i to: 128 do [showstri _i].
	user clearshow: showstr]\gb7B12i43I
updatemaxwidth | newmaxwidth i
	[										"update max width"
	newmaxwidth _ 0.
	for i from: (fontxtabl to: fontxtabl + ((font word: 3) - (font word: 2) + 1) by: 1) do
				[newmaxwidth _ (newmaxwidth max: ((font word: i+1) - (font word: i)))].
	font word: 4 _ newmaxwidth.
	]\gb15B28i18I
updateseglength: newfont raster: newraster
	[								"compute new segment length for a font"
	newfont word: 5 _	(5												"length, ascent, descent, kern, and raster"
								+ (newraster * fontht)					"bits"
								+ ((font word: 3 "max") -
										(font word: 2"min") + 2)		"xtabl"
							).
	]\gb44B9i39I34i43I36i6I26i5I27i5I8i7I
\g
SystemOrganization classify: FontWindow under: 'Windows'.\g
FontWindow classInit\g

"Window"l15000z20000\gbf5 
Class new title: 'Window'
	subclassof: Object
	fields: 'frame collapsed titlepara growing exitflag '
	declare: 'titlerun border titleloc titleframe windowmenu ';
	asFollows\gbf5 

This is a superclass for presenting windows on the screen.  Besides outlining and scheduling the frame, it includes the distribution of user events which will someday be driven by interrupts.\gi

Initialization\gbf5 
classInit		"Window classInit"
	[border _ 22.
	titleframe _ Textframe new para: nil frame: nil.
	titleloc _ 3(4-titleframe lineheight).
	titlerun _ String new: 2.
	titlerun word: 1 _ 0177401.
	windowmenu _ Menu new string:
'under
frame
close
print
printbits
']\gb11B18b2B
reset
	[exitflag_true. growing_false] \gb7B

Scheduling\gbf5 
eachtime
	[frame has: user mp
		[user kbck[self kbd]
		user anybug
			[user redbug[self redbug]
			user yellowbug[self yellowbug]
			user bluebug[self bluebug]]
		user anykeys[self keyset]]
	self outside[]
	user anybug[frame has: user mp[] false]
	user kbck[user kbd. frame flash] "flush typing outside"]\gb10B288i22I
firsttime
	[frame has: user mp [self reset.  self enter] false]\gb11B
lasttime
	[self leave. exitflag]\gb10B
schedule [user restartup: self]\gb9B

Framing\gbf5 
clearTitle: color
	[(titleframe window inset: 22) clear: color]\gb19B
editTitle | pared w
	[pared_ ParagraphEditor new para: titlepara frame: nil.
	pared formerly: false; fixframe: titleframe window+(12).
	pared enter.  w_ titleframe window.
	until (user anybug and (w has: user mp)false) do
		[user kbck[pared typing]
		user redbug[w has: user mp[pared selecting]]
		user yellowbug[w has: user mp[w flash]]].
	titlepara_ pared contents.
	self showtitle]\gb10B
erase
	[(frame inset: 22) clear.
	self clearTitle: background]\gb7B
fixedwidthfromuser: width | a b oldframe [
	user waitnobug.
	[framenil[] self aboutToFrame; erase].
	a _ OriginCursor showwhile user waitbug.
	growing _ true.
	self frame: (frame _ self fixframe: (a rect: a+(width32))); show.
	CornerCursor showwhile [
		while (a _ user mpnext)  do [ a x _ frame corner x.
			[oldframenil [user cursorloc _ a max: frame corner]].
			oldframe _ frame copy.
			self frame: (frame _ self fixframe: (frame growto: a));
				moveFrom: oldframe]].
	growing _ false.
	self takeCursor]\gb26B
fixframe: f [Rectangle new origin: f origin extent: (f extent max: 3232)]\gb12B
frame 
	[  frame ]\gb8B
frame: f
	[frame _ self fixframe: f]\gb10B
moveFrom: oldframe
	[(oldframe inset: 2) clear. self show]\gb20B
newframe
	| a oldframe
	[user waitnobug; restoredisplay.
	[framenil
		[]
		self aboutToFrame; erase].
	a _ OriginCursor showwhile user waitbug.
	growing _ true.
	frame _ self fixframe: (a rect: a+32).
	frame outline.
	CornerCursor showwhile
		[while (a _ user mpnext) do
			[[oldframenil
				 [user cursorloc _ a max: frame corner]].
			oldframe _ frame copy.
			frame _ self fixframe: (frame growto: a).
			(oldframe inset: 2) clear.
			frame outline]].
	self frame: frame.
	growing _ false.
	self takeCursor]\gb10B
outline
	["Clear and outline me."
	frame outline]\gb9B1i23I
show [
	self outline.
	growing[]
	self showtitle]\gb5B
showtitle
	[[titleparanil
		[titlepara_ Paragraph new text: self title runs: titlerun alignment: 0]].
	titleframe put: titlepara at: frame origin+titleloc; outline]\gb11B
takeCursor
	["Move the cursor to my center."
	user cursorloc _ frame center]\gb12B1i31I
title ['Untitled']\gb6B

Default Event responses\gbf5 
aboutToFrame
	["My frame is about to change.  I dont care."]\gb14B1i44I
bluebug
	[windowmenu bug
		=1[exitflag _ false];
		=2[self newframe. self enter];
		=3[self close. self erase.
			user unschedule: self. false];
		=4[self hardcopy];
		=5[self print]]\gb9B
close []\gb6B
enter [self show]\gb6B
hardcopy [frame flash]\gb9B
kbd [user kbd. frame flash]\gb4B
keyset [frame flash]\gb7B
leave []\gb6B
outside [titleframe window has: user mp
		[user anybug[self editTitle] false]
	false]\gb8B
print
	[(dp0 pressfile: (self title + '.press.') asFileName)
		screenout: frame scale: PressScale; toPrinter]\gb7B
redbug
	[frame flash]\gb8B
yellowbug
	[frame flash]\gb11B
\g
SystemOrganization classify: Window under: 'Windows'.\g
Window classInit\g

"PanedWindow"l15000z20000\gbf5 
Class new title: 'PanedWindow'
	subclassof: Window
	fields: 'panes templates title'
	declare: '';
	asFollows\gbf5 

A paned window is a Window that has subwindows (panes) that are awakened and resized in unison. The instance variable templates is a set of Rectangles for the frames of the panes normalized such that the whole PanedWindow is a frame of 00 rect: 3636.\gi

Initialization\gbf5 
title: title with: panes at: templates | pane
"The instance variable templates is a set of Rectangles for the frames of the panes normalized such that the whole PanedWindow is a frame of 00 rect: 3636."
	[self reset.
	for pane from: panes do [pane init]]\gb39B

Window protocol\gbf5 
close | pane
	[for pane from: panes do [pane close]]\gb6B
eachtime | pane
	[frame has: user mp
		[user bluebug[self bluebug]
		for pane from: panes do [pane startup]]
	self outside[]
	user anybug[frame has: user mp[] false]
	user kbck[user kbd. frame flash] "flush typing outside"]\gb9B201i22I
enter | pane
	[super show.
	for pane from: panes do [pane windowenter]]\gb6B
erase
	[self titlerect clear. super erase]\gb7B
fixframe: f
	[Rectangle new origin: f origin extent: (f extent max: 16080)]\gb13B
frame: frame "(Re)initialize my frame, and tell my panes their locations."
		| templateStream template pane orig ext
	[templateStream _ templates asStream.
	orig_ frame origin-1. ext_ frame extent+2.
	for pane from: panes do
		["It would be nice to have parallel fors as in MLISP."
		template _ templateStream next.
		pane frame _ (template*ext /36 + orig) inset: 1]]\gb13Bi61I156i53I
hardcopy | p
	[user displayoffwhile [
	p _ dp0 pressfile: (self title+'.press') asFileName.
	self hardcopy: p.
	p close; toPrinter]]\gb9B
hardcopy: pf | pane [
	self hardcopyTitle: pf.

	"print frame rectangle"
	frame hardcopy: pf.

	"print all panes"
	for pane from: panes do [pane hardcopy: pf].

	"print cursor if it's inside"
	frame has: user mp [user currentCursor hardcopy: pf]]\gb13B
hardcopyTitle: pf [
	"refresh title (since it's a class var)"
	self showtitle.

	"draw title rectangle"
	titleframe window hardcopy: pf.

	"print title text (make frame larger)"
	titleframe para presson: pf in: (pf transrect: (
		titleframe frame origin rect: titleframe frame corner + (999  2)))
		style: titleframe style]\gb18B
kbd | pane
	[(pane _ self pickedpane) [pane kbd]]\gb4B
keyset | pane
	[(pane _ self pickedpane) [pane keyset]]\gb7B
leave | pane
	[for pane from: panes do [pane windowleave]]\gb6B
pickedpane | pane
	[for pane from: panes do [pane picked [pane]]
	frame flash. false]\gb11B
redbug | pane
	[(pane _ self pickedpane) [pane redbug]]\gb7B
show | pane
	[super show.
	for pane from: panes do [pane outline]]\gb5B
takeCursor
	[(panes1) takeCursor]\gb12B
title
	[title]\gb7B
yellowbug | pane
	[(pane _ self pickedpane) [pane yellowbug]]\gb10B

Pane services\gbf5 
vanish
	[self close; erase. user unschedule: self.]\gb8B

Private\gbf5 
titlerect
	[frame origin - (2  (DefaultTextStyle lineheight + 4)) rect: (frame corner xframe origin y) + (20)]\gb11B
\g
SystemOrganization classify: PanedWindow under: 'Windows'.\g

"BrowseWindow"l15000z20000\gbf5 
Class new title: 'BrowseWindow'
	subclassof: PanedWindow
	fields: ''
	declare: 'stdTemplates ';
	asFollows\gbf5 

I am a five-paned window to browse through classes.  My panes are...
	system pane: categories of classes in the system
	class pane: classes in the selected category
	organization pane: categories of methods in the selected class
	selector pane: method selectors in the selected category
	code pane: source code of the selected method, if any, else other useful info\gi

Initialization\gbf5 
classInit
	[stdTemplates _ (00 rect: 1014), (100 rect: 1814), (180 rect: 2814), (280 rect: 3614), (014 rect: 3636)]\gb11B
default 	"Let the user draw a five-paned window to browse through classes."
		| systemPane classPane orgPane selectorPane codePane
	["Create the panes."
	systemPane _ SystemPane new. classPane _ ClassPane new.
	orgPane _ OrganizationPane new. selectorPane _ SelectorPane new.
	codePane _ CodePane new.
	"Acquire them."
	self title: 'Classes'
		with: (systemPane, classPane, orgPane, selectorPane, codePane)
		at: stdTemplates.
	self newframe; show.
	"Interconnect them."
	systemPane to: classPane. classPane from: systemPane to: orgPane.
	orgPane from: classPane to: selectorPane. selectorPane from: orgPane to: codePane.
	codePane from: selectorPane.	
	"Display them."
	systemPane update]\gb9Bi66I58i19I151i15I132i20I184i15I
\g
SystemOrganization classify: BrowseWindow under: 'Windows'.\g
BrowseWindow classInit\g

"CodeWindow"l15000z20000\gbf5 
Class new title: 'CodeWindow'
	subclassof: PanedWindow
	fields: ''
	declare: 'stdTemplates ';
	asFollows\gbf5 

I am a paned window with a code pane to edit a method or a file.\gi

Initialization\gbf5 
class: class selector: selector para: para formerly: oldpara | codePane
	[codePane _ CodePane new class: class selector: selector para: nil.
	self title: class title+ ' ' + selector with: codePane inVector at: stdTemplates.
	self newframe; show.
	codePane showing: para; formerly: oldpara; from: codePane]\gb61B
classInit
	[stdTemplates _ (00 rect: 3636) inVector]\gb11B
editTitle [titleframe window flash]\gb10B
file: file | filePane
	[filePane _ FilePane new file: file.
	self title: file name with: filePane inVector at: stdTemplates.
	self newframe; show.
	filePane showing: file contents asParagraph; from: filePane]\gb11B
hardcopy: p | pane [for pane from: panes do [pane hardcopy: p]]\gb12B
\g
SystemOrganization classify: CodeWindow under: 'Windows'.\g
CodeWindow classInit\g

"InspectWindow"l15000z20000\gbf5 
Class new title: 'InspectWindow'
	subclassof: PanedWindow
	fields: 'variables'
	declare: 'stdTemplates ';
	asFollows\gbf5 

I am a paned window with a variable pane that displays the fields of an object and a code pane to display their values and to evaluate in their context.\gi

Initialization\gbf5 
classInit
	[stdTemplates _ (00 rect: 1236), (120 rect: 3636)]\gb11B
of: object | instanceVarPane instanceValuePane safeVec n
	[instanceVarPane _ VariablePane new. instanceValuePane _ CodePane new.
	self title: object class title
		with: (instanceVarPane, instanceValuePane) at: stdTemplates.
	self newframe; show.
	instanceVarPane to: instanceValuePane.
	instanceValuePane from: instanceVarPane.
	variables _ (Vector new: 16) asStream.
		[object class is: VariableLengthClass
			[for n from: object fields do
				[self identifier: n]]
		object class fieldNamesInto: self].
	safeVec _ Vector new: 2. safeVec all _ object.
	instanceVarPane names: ((self) concat: variables contents) values: safeVec wrt: false]\gb11B
show: object | fixedframe instanceVarPane instanceValuePane safeVec n
	[instanceVarPane _ VariablePane new. instanceValuePane _ CodePane new.
	fixedframe _ 400450 rect: 600565.
	self title: object class title
		with: (instanceVarPane, instanceValuePane) at: stdTemplates.
	self frame: (self fixframe: fixedframe); show.
	instanceVarPane to: instanceValuePane.
	instanceValuePane from: instanceVarPane.
	variables _ (Vector new: 16) asStream.
		[object class is: VariableLengthClass
			[for n from: object fields do
				[self identifier: n]]
		object class fieldNamesInto: self].
	safeVec _ Vector new: 2. safeVec all _ object.
	instanceVarPane names: ((self) concat: variables contents) values: safeVec wrt: false]\gb13B

Private\gbf5 
comment: s		"called by of: via Class fieldNamesInto"\gb12B1i38I
contents	"called by of: via Class fieldNamesInto"\gb9B1i38I
identifier: s		"called by of: via Class fieldNamesInto"
	[variables next _ s]\gb15B1i38I
separator: c		"called by of: via Class fieldNamesInto"\gb14B1i38I
trailer: s	"called by of: via Class fieldNamesInto"\gb11B1i38I
\g
SystemOrganization classify: InspectWindow under: 'Windows'.\g
InspectWindow classInit\g

"NotifyWindow"l15000z20000\gbf5 
Class new title: 'NotifyWindow'
	subclassof: PanedWindow
	fields: 'enoughpanes'
	declare: 'bigTemplates smallFrame smallTemplates ';
	asFollows\gbf5 

I am a paned window with one or six panes that display the context of an error or breakpoint.\gi

Initialization\gbf5 
classInit
	[smallTemplates _ (00 rect: 3636) inVector.
	bigTemplates _ (00 rect: 1218), (120 rect: 3618), (018 rect: 1227), (1218 rect: 3627), (027 rect: 1236), (1227 rect: 3636).
	smallFrame _ 204366 rect: 404402]\gb11B
of: titleString level: level interrupt: flag | stackPane
	[NotifyFlag _ false.
	stackPane _ StackPane new.
	self title: titleString with: stackPane inVector at: smallTemplates.
	smallFrame moveto:
		[level>1
			[30050]
		(user screenrect center-(smallFrame extent/2))].
	self frame: (self fixframe: smallFrame); show.
	stackPane context: false at: level instance: false code: false;
		interrupt: flag.
	stackPane of: (Toplevel) inVector. NotifyFlag _ true]\gb45B
of: titleString stack: stack interrupt: flag | stackPane
	[NotifyFlag _ false.
	stackPane _ StackPane new.
	self title: titleString with: stackPane inVector at: smallTemplates.
	smallFrame moveto:
		[Top currentPriority>1
			[30050]
		(user screenrect center-(smallFrame extent/2))].
	self frame: (self fixframe: smallFrame); show.
	stackPane context: false instance: false code: false; interrupt: flag.
	stackPane of: stack inVector. NotifyFlag _ true]\gb45B

Window protocol\gbf5 
aboutToFrame
	[enoughpanes _ panes length = 6. super aboutToFrame]\gb14B
enter | stackPane codePane contextVarPane contextValuePane instanceVarPane instanceValuePane
	[enoughpanes [super enter]
	NotifyFlag _ false.
	"Create the remaining five panes."
	stackPane _ panes1. codePane _ CodePane new.
	contextVarPane _ VariablePane new. contextValuePane _ CodePane new.
	instanceVarPane _ VariablePane new. instanceValuePane _ CodePane new.
	"Create the six-paned window."
	self title: title
		with: (stackPane, codePane, contextVarPane, contextValuePane, instanceVarPane, instanceValuePane)
		at: bigTemplates.
	self frame: frame; show.
	"Initialize the six panes."
	stackPane context: contextVarPane instance: instanceVarPane code: codePane.
	codePane from: stackPane.
	contextVarPane to: contextValuePane. contextValuePane from: contextVarPane.
	instanceVarPane to: instanceValuePane. instanceValuePane from: instanceVarPane.
	stackPane select: 0; deselected; fill. enoughpanes _ NotifyFlag _ true]\gb6B138i34I189i30I167i27I
\g
SystemOrganization classify: NotifyWindow under: 'Windows'.\g
NotifyWindow classInit\g

"ProjectWindow"l15000z20000\gbf5 
Class new title: 'ProjectWindow'
	subclassof: Window
	fields: 'userview parent changes'
	declare: 'actionMenu ';
	asFollows\gbf5 

A ProjectWindow represents its userview as a window to provide access to many UserViews, each for a different "project".  Besides the state in the userview, they also carry their own hashset for changes, so that such changes can be maintained on a per-project basis.  parent specifies another ProjectWindow to which control is given when the user leaves the current userview\gi

Changing views\gbf5 
install		"Establish this project and its userview as the current screen view"
	[Changes_ changes.
	(user_ userview) install.
	self putTitle.
	user restart]\gb9B1i66I1b2B
putTitle
	[ [titleparanil[titlepara_ 'Top View' asParagraph allBold]].
	titleframe put: titlepara
		centered: user screenrect extent x/38.
	titleframe outline]\gb10B
runParent		"leave this view by installing the one above"
	[parent install]\gb11B1i43I

Window behavior\gbf5 
close		"break circular links"
	[userview_ parent_ nil]\gb7B
yellowbug
	[actionMenu bug=1[self install]]\gb11B

Initialization\gbf5 
classInit
	[actionMenu _ Menu new string: 'enter']\gb11B
init		"a new window"
	[self userview: (user copyIn: self)
		changes: HashSet init
		parent: user projectWindow.
	self newframe; show]\gb6B
userview: userview changes: changes parent: parent		"load state"\gb52B
\g
SystemOrganization classify: ProjectWindow under: 'Windows'.\g
ProjectWindow classInit\g

"SyntaxWindow"l15000z20000\gbf5 
Class new title: 'SyntaxWindow'
	subclassof: PanedWindow
	fields: ''
	declare: 'stdFrame stdTemplates ';
	asFollows\gbf5 

I am a paned window with a stack pane and a code pane to report errors during non-interactive compilations, e.g., filin, , understands.\gi

Initialization\gbf5 
classInit
	[stdTemplates _ (00 rect: 1236), (120 rect: 3636).
	stdFrame _ 60320 rect: 570500]\gb11B
of: errorString at: position in: stream for: class from: context | stackPane codePane
	[stackPane _ StackPane new.
	codePane _ CodePane new class: class selector: nil para: nil.
	self title: class title with: (stackPane, codePane) at: stdTemplates.
	stdFrame moveto: (user screenrect center-(stdFrame extent/2)).
	self frame: (self fixframe: stdFrame); show.
	stackPane context: false instance: false code: codePane.
	stackPane of: context inVector.
	codePane showing: stream asArray.
	codePane from: stackPane; notify: errorString at: position in: stream]\gb65B
\g
SystemOrganization classify: SyntaxWindow under: 'Windows'.\g
SyntaxWindow classInit\g 