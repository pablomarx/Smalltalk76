'From Smalltalk 5.5k XM November 24 on 22 November 1980 at 2:57:08 am.'
\g
"Form"l15000z20000\gbf5 
Class new title: 'Form'
	subclassof: Object
	fields: 'extent bits offset figure ground'
	declare: 'brush aurora black white aurorarunning SPARE color formmenu under reverse blankcursor over dotsetter ';
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
	brush _ Form new extent: 55. brush black.
	color _ 1.
formmenu _ Menu new string:
'brush
black
white
line
arc
erase
size
figure
ground
'.
	dotsetter _ BitBlt new init." a BitBlt for pattern access."
	dotsetter width _ 1.
	dotsetter height _ 1.
	aurorarunning _ false.
	aurora _ "Aurora new" nil.
	]\gb12B
close
	[]\gb7B
extent: extent
	["creates a virtual bit map with width = (extent x) and height = (extent y) with the bits all 1."
	self extent: extent figure: 0 ground: 1 offset: (00).
	]
	\gb16B
extent: extent figure: figure ground: ground offset: offset
	["creates a virtual bit map with width = (extent x) and height = (extent y) with the bits all 1."
	bits_ String new: 2*(extent y)*( ((extent x) +15) /16).
	]
	\gb61B
fromImage: image 
	["creates a virtual bit map with width = (image width) and height = (image height) with the bits in image."
	self extent: image extent.
	bits_ (image rectangle) bitsIntoString
	]
	\gb19B
fromrectangle: r 
	["creates a virtual bit map with width = (r width) and height = (r height) with the bits in r."
	self extent: r extent.
	bits_ r bitsIntoString
	]
	\gb19B
	fromuser  | r
	["create a new Form whose rectangle is specified by the user. "
	r _ Rectangle new fromuser.
	self extent: r extent.
	bits_ r bitsIntoString
	]\gb16B
fromuserevenword  | r
	["create a new Form whose rectangle is specified by the user,
		truncated to nearest multiple of 16 (for Spruce printing). "
	r _ Rectangle new fromuserevenword.
	self extent: r extent.
	bits_ r bitsIntoString
	]\gb23B

PATTERN ACCESS\gbf5 
bits 
	["return the string containing the bits)"
	 bits
	]\gb7B
bits: bits 
	["reset the string containing the bits)"
	]\gb13B
black | i
	["sets all bits in the form to black ( to ones)"
	for i to: bits length do [ bitsi _ 0-1]
	]\gb6B
black: pt 
	["sets the bit at pt in the  form to black ( to one)"
	(((00)  pt) and (pt  extent)) 
		[
		dotsetter destbase _ bits.
		dotsetter destraster _ (extent x +15)/16.
		dotsetter destx _ pt x.
		dotsetter desty _ pt y.
		dotsetter fill: storing color: black
		]
	]\gb12B
gray | i
	["sets all bits in the form to gray ( to gray)"
	for i to: bits length do [ bitsi _ 025252]
	]\gb5B
white | i
	["sets all bits in the form to white ( to zeros)"
	for i to: bits length do [ bitsi _ 0]
	]\gb6B

MODULE ACCESS\gbf5 
extent
	["return the extent (widthheight) of the Form"
	 extent
	]\gb8B
figure
	["return the figure( color assiciated with black) for the form "
	 figure
	]\gb8B
figure: figure 
	["set the figure ( color assiciated with black) for the form "
	]\gb17B
ground 
	["return the ground ( color assiciated with white) for the form "
	 ground
	]\gb9B
ground: ground 
	["set the ground ( color assiciated with white) for the form "
	]\gb17B
height 
	["return the height of the Form"
	 extent y
	]\gb9B
length [  bits length]\gb7B
offset 
	["return the offset of the Form"
	 offset
	]\gb9B
offset: offset 
	["set the offset of the form "
	 self
	]\gb17B
width 
	["return the width of the Form"
	 extent x
	]\gb8B

FILING\gbf5 
read: filename | f strip w h form stripheight leftoverlines i
	["Reads the Form from the disk in the format width,height,bits."
	f_ (dp0 oldFile: filename).
	f readonly.
	w _ (f nextword).
	h _(f nextword).
	extent _ wh.
	w*h < 64000
		[bits _ (Form new extent: extent) bits.
		f into: bits.
		f close.
		]
	f close.
	user notify: 'too many bits to be a Form'.
	
	]\gb15B
write: filename
	["Saves the Form in the format width,height,bits."
	(dp0 file: filename)
		nextword_ (self width);
		nextword_ (self height);
		append: bits;
		close.
	]\gb17B2i47I

DISPLAY\gbf5 
displayat:  path effect: effect clippedBy: cliprect| r i clippedrect
	["basic form display primitive"
	
	path is: Point 
				[ r _ Rectangle new origin:  path extent: (self extent).
									r bitsFromString: bits mode: effect clippedBy: cliprect.
				aurorarunning 
				[user displayoffwhile
						[
						clippedrect _ r intersect: (user screenrect).
						aurora destination: clippedrect ; source: clippedrect ;
						figure: figure ; ground: ground ;  function: 002117 "AoverB" ;
						 doit; function: 0 ; doit.
						]
				] 		
 				]
	path is: Path  [for i to: path length do [ self displayat: pathi
												effect: effect clippedBy: cliprect] ]
	]\gb51B

SYSTEM\gbf5 
asInstance | s
	[s _ Stream new default.
	s nextPoint_ extent.
	s nextPoint_ offset.
	s nextword _ figure.
	s nextword _ ground.
	s nextString _ bits.
	 s contents 
	]\gb11B
copy | t
	["return a copy of myself"
	t _ Form new extent: extent.
	t bits: bits copy.
	 t
	]\gb5B
fromInstance: file 
	[
	extent _  file nextPoint.
	offset _  file nextPoint.
	figure _ file nextword.
	ground _ file nextword.
	bits _ file nextString.
	 self 
	]\gb21B
fromPress: press value: s | nbytes [
	extent_ s nextPoint.
	offset_ s nextPoint.
	figure _ s nextword.
	ground _ s nextword.
	nbytes _ 2*(extent y)*((extent x + 15)/16).
	(press data) skip: 0-nbytes.
	bits _ (press data) next: nbytes]\gb26B
hideData: complete | s
	["a Form does not split across page boundaries"
	Stream new of: (s _ String new: 12);
		nextPoint_ extent;
		nextPoint_ offset;
		nextword _ figure;
		nextword _ ground.
	 s]\gb19B7i44I
hidePress: press complete: c [
	press skipcode: self pressCode data: (self hideData: c)]\gb29B
pressCode [5]\gb10B
presson: press in: r | hs y [
	(hs  _ press scale*self height) > r height [
		"not enough room left on current page.
		assume for now that it will at least fit on an entire page"
		self]

	press setp: (r origin x)(y _ r corner y - hs);
		bitmap: self bits: bits.
	y]\gb21B

EDITING\gbf5 
arc: parentimage | pt1 pt2 pt3 path pt
	["arc tool for forms."
	BlankCursor topage1.
	until user redbug do	[ pt1 _ self blinkbrush: parentimage].
	brush displayat: pt1 effect: color clippedBy: user screenrect.
	until user nobug do		[ pt2 _ self blinkbrush: parentimage].
	brush displayat: pt2 effect: color clippedBy: user screenrect.
	until user redbug do	[ pt3 _ self blinkbrush: parentimage].
	brush displayat: pt3 effect: color clippedBy: user screenrect.
	path _ Path new init.
	path addarcfrom: pt1 via: pt2 to: pt3.
	for pt from: path do
					[ brush displayat: pt effect: color clippedBy: user screenrect].
	NormalCursor topage1
	]
\gb17B
blinkbrush: parentimage | pt 
	["to show current position of brush in the form."
		pt _ parentimage mp.
		brush displayat: (parentimage rectangle origin)+ pt
			effect: 2 clippedBy: user screenrect.
		brush displayat: (parentimage rectangle origin)+ pt
			effect: 2 clippedBy: user screenrect.
	 (parentimage rectangle origin)+ pt
	]
\gb24B
edit: parentimage | pt f c file
	["Simple Form editor for now."
	until false do "forever for now"
		[pt _ parentimage mp." blink the current brush"
		BlankCursor topage1.
		self blinkbrush: parentimage.
		user redbug  		[ parentimage contains:
										(pt _ self blinkbrush: parentimage)
											[brush displayat: pt effect: color
													clippedBy: parentimage rectangle.
											while user redbug do
												[brush displayat:
													(self blinkbrush: parentimage) effect: color
														clippedBy: parentimage rectangle.
												].
											] 
									NormalCursor topage1. 
									bits_ (parentimage rectangle) bitsIntoString.
									 self.
									] 
		user kbck [
							c _ user kbd. 
							c = 120
								[ user clearshow: 'x gridding is '. parentimage xgrid print.
								user cr.
								parentimage xgrid:
								(user request: 'x gridding . . . ') asInteger.
								] 
							c = 121
								[ user clearshow: 'y gridding is '. parentimage ygrid print.
								user cr.
								parentimage ygrid:
								(user request: 'y gridding . . . ') asInteger.
								] 
							c = 114
								[ 
								file _(user request: 'filename of Form . . .') .
								brush _Form new read: file. brush figure: 1  ; ground: 0.
								] 
						 ]
		user yellowbug 	[
			NormalCursor topage1.
			formmenu bug
				=1	[self newbrush: parentimage ]; "get a new brush"
				=2	[color _ 1.]; "set the color of the brush to black"
				=3	[color _ 3.]; "set the color of the brush to white"
				=4	[self line: parentimage];
				=5	[self arc: parentimage];
				=6	[self white. parentimage display];
											"erase the whole form"
 				=7	[self resize: parentimage
						]; "change size"
				=8	[self setfigure: parentimage];
				=9	[self setground: parentimage]
									]
				user bluebug  		[bits_ (parentimage rectangle) bitsIntoString.
									NormalCursor topage1.  self.
									] "exit back to the parentimage"
		]
	]
\gb18B
line: parentimage | pt1 pt2 path pt
	["line tool for forms."
	BlankCursor topage1.
	until user redbug do	[ pt1 _ self blinkbrush: parentimage].
	brush displayat: pt1 effect: color clippedBy: user screenrect.
	until user nobug do		[ pt2 _ self blinkbrush: parentimage].
	brush displayat: pt2 effect: color clippedBy: user screenrect.
	path _ Path new init.
	path addlinefrom: pt1 to: pt2.
	for pt from: path do
					[ brush displayat: pt effect: color clippedBy: user screenrect].
	NormalCursor topage1
	]
\gb18B
newbrush: superimage |  pt rect
	[
	OriginCursor topage1.
	user waitbug.
	pt _ ( superimage mp)+ superimage rectangle origin.
	rect _ pt rect: pt.	
	CornerCursor topage1.
	until user nobug do
			[rect reverse.
			rect reverse.
			pt _ 
			( superimage mp)+ superimage rectangle origin.
			rect corner _ (rect origin) max: pt.
			]
 	brush _ Form new fromrectangle: rect.
	NormalCursor topage1.
	]
\gb21B
resize: superimage |  pt f
	[superimage boxcomp.
	CornerCursor topage1.
	user waitbug. 
	until user nobug do
			[superimage reverse.
			superimage reverse.
			( pt _ 
			((superimage superimage) mp)+
				((superimage superimage) rectangle origin)).
			superimage corner_ pt max: ((superimage origin) + (1616)).
			]
 	f_Form new fromrectangle: superimage rectangle.
	bits _ f bits.
 	extent_ f extent .
 	offset _ 00.
 	superimage white ;
 						resize ; display ; boxcomp.
	NormalCursor topage1.
	]
\gb19B
setfigure: parentimage | 
	["for now just increment the figure color by 1 \ 14"
	figure _ (figure +1 ) \ 14.
	self displayat: (parentimage origin) effect: 0 clippedBy: user screenrect.
]
\gb23B5i52I
setground: parentimage | 
	["for now just increment the ground color by 1 \ 14"
	ground _ (ground +1 ) \ 14.
	self displayat: (parentimage origin) effect: 0 clippedBy: user screenrect.
]
\gb23B5i52I
\g
SystemOrganization classify: Form under: 'Form Path Image'.\g
Form classInit\g

"FormSet"l15000z20000\gbf5 
Class new title: 'FormSet'
	subclassof: Object
	fields: 'space spaceorigin image strike style styleindex formindex offsettable'
	declare: 'imageindex bitmover ';
	asFollows\gbf5 

An object for holding sets of forms.  The most conventional use will be as a repository of a set of forms typically identified as characters when seen on the display or on paper.  The forms will be ascessible by passing a one-character
string or a number.\gi

ACCESS\gbf5 
asForm: formindex	  | f
	["returns the form indexed by formindex ."
	self checkindex.
	f _ Form new extent: (self width)  (self height) . 
	bitmover destraster _ (f width + 15 / 16).
	bitmover destx _ 0. bitmover desty _ 0.
	bitmover sourcex _ (self originx). bitmover sourcey _  0.
	bitmover width _ (self width).
	bitmover height _ (self ascent) + (self descent).
	bitmover sourceraster _ (self wordwidth).
	bitmover destbase _ (f bits).
	bitmover sourcebase _ strike.
	bitmover dstrike _ false.
	bitmover sstrike _ true.
	bitmover copy: storing.
	 f
	]\gb20B6i43I
changeascentto: newascent	
	[	"new ascent for FormSet"
	self deltaascent: (newascent - (self ascent))
	]\gb28B1b1Bi26I
changedescentto: newdescent	
	[	"new ascent for FormSet"
	self deltadescent: (newdescent - (self descent))
	]\gb30B1b1Bi26I
changewidthof: formindex to: width	
	[	"new width for form at index"
	self checkindex. self deltawidthof: formindex by: (width - (self width))
	]\gb37B1b1Bi31I
classInit
	["Just initialize the bitmover for now."
	bitmover _ BitBlt init
	]\gb11B1i41I22i2I
copy: formindex	 to: pt | f
	["copies the form indexed by formindex to pt."
	self checkindex.
	"f _ Image new size: (self width)  (self height) at: pt."
	bitmover destraster _ ((user screenrect) width + 15 / 16).
	bitmover destx _ pt x. bitmover desty _ pt y.
	bitmover sourcex _ (self originx). bitmover sourcey _  0.
	bitmover width _ (self width).
	bitmover height _ (self ascent) + (self descent).
	bitmover sourceraster _ (self wordwidth).
	bitmover destbase _ (mem 066).
	bitmover sourcebase _ strike.
	bitmover strike _ true.
	bitmover copy: oring.
	 self widthof: formindex
	]\gb24B6i47I
copy: formindex	 to: pt effect: effect | f
	["copies the form indexed by formindex to pt."
	self checkindex.
	"f _ Image new size: (self width)  (self height) at: pt."
	bitmover destraster _ ((user screenrect) width + 15 / 16).
	bitmover destx _ pt x. bitmover desty _ pt y.
	bitmover sourcex _ (self originx). bitmover sourcey _  0.
	bitmover width _ (self width).
	bitmover height _ (self ascent) + (self descent).
	bitmover sourceraster _ (self wordwidth).
	bitmover destbase _ (mem 066).
	bitmover sourcebase _ strike.
	bitmover strike _ true.
	bitmover copy: effect.
	
	]\gb39B6i47I
copyrange: start to: stop from: sourceset startingat: deststart
		| savebackground savebits i f
	["copy a range of forms from one set to another"
	user displayoffwhile
	[
	[sourceset is: FormSet  []
		sourceset is: String  [sourceset _ FormSet new from: sourceset]
		user notify: 'Illegal sourceset -- not String or Formset.'
	].
	savebackground _
		Form new size: (sourceset maxwidth) by: (sourceset height).
	savebackground translate: 00; scale: 1.
	savebits _ savebackground bitsIntoString.

	for i from: start to: stop do
		[f _ sourceset copy: i to: 00. self include: deststart with: f.
		deststart _ deststart + 1].

	savebackground bitsFromString: savebits.
	]
	]\gb66B32i48I
currentformindex
	["return index of form last touched"
	 formindex
	]\gb18B1i37I
currentformorigin | imageindex
	["return index in image of form last touched"
	 imageindex _ image find: formindex.
	 space ptofchar: imageindex.
	]\gb19B11b2B1i45I
from: strike
	["Make a formset out of string in strike format"
	self classInit. self install: strike
	]\gb14B1i47I
from: first to: last ascent: ascent descent: descent
	style: style styleindex: styleindex name: name
	["Make an empty formset."
	self classInit.
	offsettable _ String new: (last - first + 3) * 2.
	offsettable all _ 0.
	offsettable word: (last - first + 3) _ 4.				"width of illegal form"
	strike _
		String new: (9 "header" + ascent + descent "space for illegal form") * 2.
	strike all _ 0.
	self type: 0100000.						"for the outside world"
	self first: first.
	self last: last.
	self wordwidth: 1.			"only illegal form"
	self ascent: ascent.
	self descent: descent.
	self maxwidth: 4.			"width of illegal form"

	strike _ strike concat: offsettable  (1 to: offsettable length).

	"mash in bits of illegal form"
	"leftside"
	bitmover destraster _ (self wordwidth).
	bitmover destx _ 0. bitmover desty _ 0.
	bitmover width _ 1. bitmover height _ (self ascent) + (self descent).
	bitmover destbase _ strike.
	bitmover dstrike _ true.
	bitmover fill: storing color: black.
	"rightside"
	bitmover destx _ 3.
	bitmover dstrike _ true.
	bitmover fill: storing color: black.
	"top"
	bitmover width _ 4. bitmover height _ 1. bitmover destx _ 0.
	bitmover dstrike _ true.
	bitmover fill: storing color: black.
	"bottom"
	bitmover desty _ (self ascent) + (self descent) - 1.
	bitmover dstrike _ true.
	bitmover fill: storing color: black.

	self install: strike.
	self updateseglength.
	[style  nil  []
		style setfont: styleindex name: name fromstring: strike]
	]\gb102B1i24I137i23I28i8I20i24I50i23I61i19I68i23I71i30I2i10I248i11I87i5I128i8I
fromspace: pt to: dest
	["get form selected from space"
	formindex _ image  ((space charofpt: pt) min: 256).
	 (self copy: formindex to: dest).
	]\gb24B1i30I
fromstyle: style styleindex: styleindex
	["Make a formset out of string in strike format"
	self classInit. self install: style fonts(styleindex+1)
	]\gb41B1i47I
height
	["return height of fromset"
	self ascent + self descent
	]\gb8B1i26I
include: formindex with: form | newoffsettable newstrike i j
	["Put a form into the formset"
	(formindex > (self first)) and:
		(formindex < (self last))  [ self replace: formindex with: form]

	formindex < 0  [user notify: 'Formindex < 0 illegal for formset.']
	formindex > 255  [user notify: 'Formindex > 255 illegal for formset.']

	[formindex < (self first) 
		[newoffsettable _
				String new: ((self first) - formindex + (self abslength)) * 2.
		newoffsettable all _ 0.
		j _ (self first) - formindex + 1.
		for i  from: j to: ((newoffsettable length) / 2) do
			[newoffsettable word: i _ strike word: offsettable + (i-j)].
		]
		newoffsettable _
				String new: ((self abslength) + formindex - (self last)) * 2.
		newoffsettable all _ 0.
		for i from: 0 to: ((self length) - 1) do
			[newoffsettable word: (i+1) _ strike word: offsettable + i].
		for i from: (self length) to: ((newoffsettable length) / 2) do
			[newoffsettable word: i _ strike word: offsettable + self length].
		newoffsettable word: ((newoffsettable length) / 2) _
			strike word: (offsettable + self length + 1).
		].
	newstrike _ String new: (9 "header" + ((self wordwidth) *
		((self ascent + self descent)) "bits")) * 2.	"new space for bits"
	for i to: 9 do
		[newstrike word: i _ strike word: i].			"fill in header of new font"

	bitmover destraster _ (self wordwidth).
	bitmover destx _ 0. bitmover desty _ 0.
	bitmover sourcex _ 0. bitmover sourcey _ 0.
	bitmover width _ (self strikerightx).
	bitmover height _ (self ascent) + (self descent).
	bitmover sourceraster _ (self wordwidth).
	bitmover destbase _ newstrike.
	bitmover sourcebase _ strike.
	bitmover strike _ true.
	bitmover copy: storing.

	"copy the xtable"
	newstrike _
		newstrike concat:  newoffsettable (1 to: newoffsettable length).
	self install: newstrike.
	[formindex < (self first)   [self first: formindex] self last: formindex].
	self replace: formindex with: form.
	]\gb30B33i29I1042i8I56i6I8i20I61i28I377i17I
initspaceat: spaceorigin | i run para
	["make a space for formset viewing"
	image _ String new: 256.
	image all _ 0.
	for i from: ((self first) to: (self last)+1)
		do [image(i+1) _ i].
	run _ String new: 2.
	run word: 1 _  16 * (styleindex) + 0177400.
	para _
	Paragraph new text: image runs: run alignment: 0.
	[space  nil  [] space erase].
	space_ Textframe new para: para
		frame: (Rectangle new origin: spaceorigin extent:
		((self last) - (self first) * (self maxwidth) / 8)
											
		((self ascent) + (self descent) * 6))
		style: style.
	]
\gb25B15i34I
makecu: name scale: scale
		| f i iform bits drast srast
	["Put out strike in Carnegie-Mellon format.
		A typical call might look like:
			yourset _
				FormSet new style: DefaultTextStyle styleindex: 0.

				yourset makecu: 'cream12' scale: 1.			
			"

	user  displayoffwhile
	[
	f _ (dp0 file: name + '.cu.').
	f nextword _ self height * scale.
	f nextword _ self maxwidth * scale + 15 / 16.
	bits _ String new:
		((self height * scale) * ((self maxwidth * scale + 15)/16))
			* 2.
	drast _ self maxwidth * scale + 15 / 16.
	srast _ (user screenrect width) + 15/16.
	for i from: ((self first) to: (self last) by: 1) do
		[iform _ "self copy: i to: 00" self asForm: i. 
		iform displayat: (00) effect: 0 clippedBy: user screenrect.
		[scale > 1  [iform blowup: 00 by: scale]].
		f nextword _ i. f nextword _ self width*scale.

		bitmover destbase _ bits.
		bitmover destraster _ drast.
		bitmover destx _ 0. bitmover desty _ 0.
		bitmover sourcebase _ mem066.
		bitmover sourceraster _ srast.
		bitmover sourcex _ 0. bitmover sourcey _ 0.
		bitmover dstrike _ false.
		bitmover sstrike _ true.
		bitmover width _ (iform width) * scale.
		bitmover height _ (iform height) * scale.
		bits all _ 0.
		bitmover copy: storing.
		f append: bits].
	f close.
	]
	]\gb28B31i195I
newspace
	["let user reshape/position space"
	space frame _ Rectangle new fromuser. self show.
	]\gb10B1i33I
replace: formindex with: form
	["Replace form in set.  Check incoming form for compatibility with formset,
	and insert form into formset."
	self checkindex.
	[form width  self width  [self changewidthof: formindex to: form width]].
	form displayat: (00) effect: 0 clippedBy: user screenrect.
	"copy bits of form into formset"
	bitmover destraster _ (self wordwidth).
	bitmover destx _ (self originx). bitmover desty _ 0.
	bitmover sourcex _ 0. bitmover sourcey _ 0.
	bitmover width _ (self width).
	bitmover height _ (self ascent) + (self descent).
	bitmover sourceraster _ ((user screenrect) width + 15 / 16).
	bitmover destbase _ strike.
	bitmover sourcebase _ (mem  066).
	bitmover dstrike _ true.
	bitmover copy: storing.
	]\gb31B1i106I158i32I
show
	["show all the forms in the set"
	space outline. space show
	]\gb6B1i31I
space
	["return textframe that is space of formset"
	 space 
	]\gb7B1i43I
spaceframe
	["return frame of space"
	(space frame)
	]\gb12B1i23I
spaceorigin: spaceorigin
	["reposition the space"
	space erase. (space frame) origin _ spaceorigin. self show.
	]\gb26B1i22I
widthof: formindex
	["return width of from at formindex"
	self width
	]\gb20B1i35I

INTERNAL\gbf5 
abslength
	["Return absolute length of formset, i.e. number of forms in set
		plus space for illegal character and its rightx"
	 ((self last) - (self first) + 3)
	]\gb11B1i114I
checkindex
	["check formindex for legality and make into number if necessary"
	[formindex is: String 
		[formindex length > 1  [user notify: 'formindex out of range for FormSet.']
		formindex _ formindex1]
	].
	(formindex < (self first)) or: (formindex > (self last+1)) 
		[user notify: 'formindex out of range for this FormSet.']
		]\gb12B1i64I
deltaascent: delta | newstrike
	["ascent delta"
	[(self ascent) + delta < 0 [delta _ 0 - (self ascent)]].
	[delta > 0 
		["grow"
		newstrike _ String new: (2 * (self wordwidth) * delta).
		newstrike all _  0.						"fill with white"
		newstrike _				"add oldfont header and new space together"
			(strike(1 to: 18) concat: newstrike(1 to: newstrike length)).
		newstrike _									"now add on rest of old font"
			(newstrike concat: strike(19 to: strike length)).
		]
	"shrink"
	newstrike _ (strike(1 to: 18) concat:
		strike((19 + (0 - (2 * (self wordwidth) * delta)))
			to: strike length)).
	].
	newstrike word: 6 _ ((self ascent) + delta).	"reset ascent word in font"
	self install: newstrike.						"newstrike now font of interest"
	self updateseglength.
	[style  nil  [ ]
		(style maxascent) < (self ascent)  [style maxascent: (self ascent)]].
	]\gb19B14i14I77i6I86i17I18i43I90i29I60i8I169i27I32i32I
deltadescent: delta | newstrike somespace
	["descent delta"
	[(self descent) + delta < 0  [ delta _ 0 - (self descent)]].
	[delta > 0 
			[somespace _ String new: 2 * (self wordwidth) * delta.
			somespace all _ 0.
			newstrike _
				(strike  (1 to: offsettable - 1 * 2) concat: somespace).
			]
	newstrike _
		(strike  (1 to: ((offsettable - 1 * 2)
				+ ((self wordwidth) * delta * 2)))).
	].
	"copy the xtable"
	newstrike _
		newstrike concat: strike  ((offsettable * 2 - 1) to: strike length).
	newstrike word: 7 _
		((self descent) + delta).			"reset descent word in font"
	self install: newstrike.					"updatedfont now font of interest"
	self updatemaxwidth.
	self updateseglength.
	[style  nil  [ ]
		(style maxdescent) < (self descent) 
			[style maxdescent: (self descent)]]
	]\gb20B24i15I341i17I137i28I31i34I
deltawidthof: index by: delta
	| newwordwidth newoffsettable newstrike normalizedindex normalizedlast i
	["change width of form at index"
	[delta < 0  [(delta abs) > (self width)  [delta _ 0-(self width)]]].
	newwordwidth _
		[((self strikerightx) + 15 / 16) 
			(i _ ((self strikerightx) + delta + 15 / 16)) 
			[ i ]
			(self wordwidth)].
	newoffsettable _ newwordwidth *
		((self ascent + self descent)) "height" + 9 "header" + 1 "for 0 addressing".
	XeqCursor showwhile 
	[
	newstrike _ String new: (9 "header" + (newwordwidth *
		((self ascent + self descent)) "bits")) * 2.			"grow/shrink the bits"
	newstrike all _ 0.
	for i to: 8 do
		[newstrike word: i _ strike word: i].					"fill in header of new font"
	newstrike word: 9 _ newwordwidth.						"set raster in new font"

	"copy the xtable"
	newstrike _ newstrike concat: strike((offsettable * 2 - 1) to: strike length).

	"set up to copy up to old bits of form in formset"
	bitmover destraster _ newwordwidth.
	bitmover destx _ 0. bitmover desty _ 0.
	bitmover sourcex _ 0. bitmover sourcey _ 0.
	bitmover width _ (self originx) + (self width).
	bitmover height _ (self ascent) + (self descent).
	bitmover sourceraster _ (self wordwidth).
	bitmover destbase _ newstrike.
	bitmover sourcebase _ strike.
	bitmover sstrike _ true.
	bitmover dstrike _ true.
	bitmover copy: storing.

	"now copy remainder of font"
	bitmover destx _ (self originx) + (self width) + delta.
	bitmover width _ (self strikerightx) - (self originx) - (self width).
	bitmover sourcex _ (self originx) + (self width).
	bitmover copy: storing.

	"shift x-vals"
	normalizedindex _ formindex - (self first).
	normalizedlast _ (self last) - (self first).
	for i from: ((normalizedindex + 1) to: (normalizedlast + 2 "max")) do
		[newstrike word: (newoffsettable+i) _
			delta + (newstrike word: (newoffsettable+i))].
	self install: newstrike.		"set up the updated copy of the formset"
	self updatemaxwidth.
	self updateseglength. 
	].
	]\gb31B75i31I274i8I5i8I5i18I56i8I52i6I10i22I83i28I41i24I3i17I84i50I409i28I207i14I153i5I124i40I
install: strike
	["set up a new or refreshed strike"
	[style  nil  [] style fonts  (styleindex + 1) _ strike].
	offsettable _ (self wordwidth) *
		((self ascent) + (self descent)) + 9 "header" + 1 "for 0 addressing".
	 strike]\gb17B1i34I135i8I5i18I
length
	["Return length of formset, i.e. number of forms in set"
	 ((self last) - (self first) + 1)
	]\gb8B1i55I
originx
	["Return origin x  of form at formindex"
	 (strike word: (offsettable + formindex - (self first)))]\gb9B1i39I
updatemaxwidth | newmaxwidth i
	["update max width"
	newmaxwidth _ 0.
	for i from:
		(offsettable to: offsettable + ((self last) - (self first) + 1))
		do
		[newmaxwidth _
			(newmaxwidth
				max: ((strike word: i+1) - (strike word: i)))].
	self maxwidth: newmaxwidth.
	]\gb15B18i18I
updateseglength
	["compute new segment length for formset"
	strike word: 5 _
		(5														"length, ascent, descent, kern, and raster"
			+ ((self wordwidth) * ((self ascent) + (self descent)))	"bits"
			+ ((self last "max") - (self first	"min") + 2)					"xtabl"
		).
	]\gb17B1i40I37i43I60i6I55i7I
width
	["Return width of form at formindex"
	 (strike word: (offsettable + (formindex - (self first)) + 1)) -
			(strike word: (offsettable + (formindex - (self first)))) ]\gb7B1i35I

PARTS\gbf5 
ascent
	["When form set treated as characters, describes distance from top of form
	to baseline."
	(strike word: 6)
	]\gb8B1i88I
ascent: ascent
	["When form set treated as characters, describes distance from top of form
	to baseline."
	strike word: 6 _ ascent.
	]\gb16B1i88I
descent
	["When form set treated as characters, describes distance from bottom of
	form to baseline."
	(strike word: 7)
	]\gb9B1i91I
descent: descent
	["When form set treated as characters, describes distance from bottom of
	form to baseline."
	strike word: 7 _ descent.
	]\gb18B1i91I
first
	["Heritage from the world of fonts"
	(strike word: 2)	"minimum formindex (ascii) in the strike"]\gb7B1i36I18i41I
first: first
	["Heritage from the world of fonts"
	strike word: 2 _ first.		"minimum formindex (ascii) in the strike"
	]\gb14B1i36I25i43I
kern
	["When form set treated as characters, describes distance this form is
	to intrude into space of preceding character."
	(strike word: 8)
	]\gb6B1i119I
last
	["Heritage from the world of fonts"
	(strike word: 3)	"maximum formindex (ascii) in the strike"
	]\gb6B1i36I18i43I
last: last
	["Heritage from the world of fonts"
	strike word: 3 _ last.		"maximum formindex (ascii) in the strike"
	]\gb12B1i34I26i43I
maxwidth
	["All forms in this set  to this value"
	(strike word: 4)
	]\gb10B1i39I
maxwidth: maxwidth
	["All forms in this set  to this value"
	strike word: 4 _ maxwidth.
	]\gb20B1i39I
segmentlength
	["Amount of space allocated for form set - 4"
	(strike word: 5)
	]\gb15B1i44I
strikerightx
	["Corner x of last form in form set"
	(strike word: (offsettable + ((self last) - (self first)) + 2)).
	]\gb14B
type
	["**BEWARE -- outside world has ideas about this value."
	(strike word: 1)
	]\gb6B1i55I
type: type
	["**BEWARE -- outside world has ideas about this value."
	strike word: 1 _ type.
	]\gb12B1i55I
wordwidth
	["Also know as the raster of the formset.
	The width in alto words of the bits of the formset.  When the display of a 
	form is desired, the word and bit address of the bits of the form must
	be discovered.  Adding the wordwidth to the word portion of that value,
	produces the word address of the second line of the bits of the form, and
	so on until the height of the form is spanned."

	(strike word: 9)
	]\gb11B1i386I
wordwidth: wordwidth
	["Also know as the raster of the formset.
	The width in alto words of the bits of the formset.  When the display of a 
	form is desired, the word and bit address of the bits of the form must
	be discovered.  Adding the wordwidth to the word portion of that value,
	produces the word address of the second line of the bits of the form, and
	so on until the height of the form is spanned."

	strike word: 9 _ wordwidth.
	]\gb22B1i386I
\g
SystemOrganization classify: FormSet under: 'Form Path Image'.\g
FormSet classInit\g

"Image"l15000z20000\gbf5 
Class new title: 'Image'
	subclassof: Set
	fields: ' origin rectangle path form superimage xgrid ygrid figure ground'
	declare: 'aurora under black screen reverse white over aurorarunning ';
	asFollows\gbf5 

This class has not yet been commented\gi

INIT\gbf5 
blink: form | pt 
	["to show current gridded position of the form... returns abs position."
		pt _ self mp.
		form displayat: ( rectangle origin)+ pt
			effect: 2 clippedBy: user screenrect.
		form displayat: ( rectangle origin)+ pt
			effect: 2 clippedBy: user screenrect.
	 (self rectangle origin)+ pt
	]
\gb12B
classInit
	["sets up black and white as colors and over ,under and reverse as modes
	also initializes the name screen as an image the size of the display"
	black _ 0-1.
	white _ 0.
	over _ 0.
	under _ 1.
	reverse _ 2.
	screen _ Image new origin: user screenrect origin extent: user screenrect extent.
	aurora _ "Aurora new" nil.
	aurorarunning _ false.
	]\gb11B
fromuser
	["create a new Image whose rectangle is specified by the user. "
	rectangle _ Rectangle new fromuser.
	self origin: (rectangle origin) rectangle: rectangle
		path: (rectangle origin) form: (Form new fromrectangle: rectangle)
		figure: 1 ground: 0 xgrid: 1 ygrid: 1.
	]\gb10B
origin: origin extent: extent 
	["create a new Image at origin with extent (widthheight). "
	self origin: (origin copy)  rectangle: (Rectangle new origin: origin extent: extent)
		 path: nil form: nil figure: 1 ground: 0 xgrid: 1 ygrid: 1
	]\gb32B
origin: origin rectangle: rectangle path: path form: form
	["basic message to create a new instance."
	self origin: origin rectangle: rectangle path: path form: form
	figure: 1 ground: 0 xgrid: 1 ygrid: 1.
	]
\gb59B
origin: origin rectangle: rectangle path: path form: form figure: figure ground: ground xgrid: xgrid ygrid: ygrid
	["basic message to create a new instance."
	self default]
\gb115B
rectanglefromuser | f pt r
	["create a  Rectangle  specified by the user and origin and corner are gridded. "
	r _ Rectangle new.
	f _ Form new extent: xgridygrid. f black.
	user waitnobug.
	until user anybug do
		[
		r origin _ self blink: f.
		].
	until user nobug do
		[
		r corner _ (self mp + rectangle origin) max: (r origin + f extent).
		r reverse ; reverse.
		].
	 r.
	]\gb28B

BUILDING IMAGES\gbf5 
add: p and: i | s
	["add p (set or point) and i ( Image or Form ) and expand the
		 bounding rectangle of this image."
	rectangle _
		rectangle include:
			((Rectangle new origin: (p origin)+ origin extent: i size)
				include: (Rectangle new origin: (p corner)+ origin extent: i size)).
	s _ Set default. s add: p ; add: i .
	self add: s
	]\gb19B
addform: f andpath: p | r
	["add p (set or point) and f ( Form ) and expand the
		 bounding rectangle of this image."
	self addpath: p andform: f
	]\gb27B
addimage: i  | r
	["add the Image i (as a subimage) and expand the
		 bounding rectangle of this image."
	rectangle _
		rectangle
			include:
			(Rectangle new origin: (i origin)+ origin extent: i extent).
	self add: i.
	]\gb18B
addpath: p andform: f | r
	["add p (set or point) and f ( Form ) and expand the
		 bounding rectangle of this image."
	rectangle _
		rectangle
			include:
			(r _ ((Rectangle new origin: (p origin)"+ origin" extent: f extent)
			include:
			(Rectangle new origin: ((p corner) - (11))"+ origin" extent: f extent))).
	self add: (Image new origin: 00 rectangle: r path: p form: f
		figure: 1 ground: 0 xgrid: 1 ygrid: 1).
	]\gb27B

CHANGING IMAGES\gbf5 
appendimage: newimage after: image | i
	["append newimage into the image after image."
	i _ self findbyrect: image.
	self insertI: (i+1) value: newimage.
	]\gb35B
comment
	["see class Set for operations (deletion,replacement,insertion etc.) on subimages ( elements)."]
\gb9B
deleteimage: i | subimage
	["delete the i th subimage and recompute the bounding rectangle of the Image"
	subimage _ selfi.
	self deleteI: i.
	( subimage rectangle) isWithin: rectangle [] self resize "recompute bounding rectangle"
	]\gb27B
deletesubimage: i 
	["delete the ith subimage."
	self deleteindex: i.
	]\gb20B
edit: superimage | blackdot pt indexofsubimage subimage
	["eventually a general Image manipulator for now
			just passes control to its subimages."
	nil form 
			[user waitnobug.
			until (1 = 2) do
					 "until bug occurs outside rectangle"
			[
			((false = (rectangle has: (user mp))) and: (user anybug))[ self ]
			user kbck  [ self kbd ]
			user redbug
					[indexofsubimage _ self smallestsubimageat:
										( (user mp) - self rectangle origin).
					indexofsubimage
							[ subimage _ selfindexofsubimage.
							subimage translate: self origin .
							subimage edit: self.
							subimage translate: ((00)-self origin).
							]
					]
				user yellowbug
					[
					self yellowbug
					]
				]
				].
	form _ form edit: self.
	[form is: Form [] "origin _  (form origin) copy." rectangle _ (form frame) copy].
	 self 
	]
\gb19B36b2B
findbyrect: image | i
	[
	for i to: position do
		[(arrayi) rectangle = image rectangle  [i]].
	0]\gb18B
highlite  | r i
	["reverse the ith subimage ."
	for i to: position do 
		[
		r _ Rectangle new origin: (self origin+ (selfi) origin)
			extent: (selfi) extent.
		r comp
		]
	]\gb17B
indexofsubimageat: pt | i subimage 
	["return the index of the subimage which contains pt(relative to self origin)
		otherwise return false."
	for i to: self length do
		[subimage _ (selfi).
		(subimage rectangle) has: pt [  i]
		]
	 false
	]\gb37B
indexofsubimagebelow: yvalue | i subimage 
	["return the index of the first subimage below yvalue otherwise return false."
	for i to: self length do
		[ ((selfi) top  yvalue)  [  i]
		]
	 false
	]\gb44B
outlinesubimage: i  | r
	["draw an outline(reversed boarder 2 units thick) about the ith subimage ."
	r _ Rectangle new origin: (self origin+ (selfi) origin)
			extent: (selfi) extent.
	r comp
	]\gb25B
replaceimage: image with: newimage | i
	["replace image with newimage in self."
	i _ self findbyrect: image.
	self replaceI: i value: newimage.
	]\gb35B
smallestsubimageat: pt | i smallest slf sml
	["return the index of the smallest subimage which contains pt(relative to self origin)
		otherwise return false."
	smallest _ false.
	for i to: self length do
		[
		((selfi) rectangle) has: pt
			[
			smallest[ slf_((selfi) rectangle).
							sml_((selfsmallest) rectangle).
							(slf area < sml area) 
										[smallest _ i]
									
						  ]
			smallest _ i
			]
		]
	smallest[ selfsmallest]
	 smallest 
	]\gb45B422bi1BI
subimage: i | sub s
	["return the ith subimage."
	sub _ (selfi)
	s _ Image new at: (self origin) + (sub1) origin. s add: (00) and: sub2. 
	 s
	]\gb21B
subimageat: pt | i 
	["return the  subimage which contains pt (relative to self origin)
		otherwise return false."
	i _ self indexofsubimageat: pt.
	i  [  self i]
	 false
	]\gb21B
subimageswithin: rect | image topleft fittedimage t
	["return an image containing my subimages that are within rect, 		otherwise return false."
	image _ Image new origin: rect origin extent: rect extent.
	for t from: self do
		[
		(t rectangle) isWithin: rect
			[
			image addimage: (t translate: (00)-(rect origin))
			]
		].
	image length = 0[ false]
	topleft _ (image1) rectangle origin.
	for t from: image do
		[(t rectangle origin) < topleft [topleft _ (t rectangle origin)]].
	fittedimage _ Image new origin: (topleft+rect origin) extent: (11).
	for t from: image do
		[ fittedimage addimage: (t translate: (00)-topleft)].
	 fittedimage 
	]\gb53B605bi1BI
substitute: form1 for: form2 | i 
	["everywhere in the imagesubstitute form1 for form2"
	for i to: self length do [ (selfi)2  form2   [ (selfi)2 _ form1]]  
	]\gb29B

DISPLAY\gbf5 
blink 
	["blink the image" 
	self display: 2.
	self display: 2.
	]\gb8B
display 
	["display all of the forms in the image on the screen "
	self displayat: 00 effect: 0 clippedBy: user screenrect.
	]\gb10B
display: effect  
	["display all of the forms in the image on the screen 
	effect = 0  store
	effect = 1  or
	effect = 2  xor
	effect = 3  and complement
"
	self displayat: 00 effect: effect clippedBy: user screenrect.
	]\gb19B
displayat: pt effect: effect clippedBy: cliprect | i 
	["display all of the subimages in this image "
	[nil form	 []
		form displayat: (path + pt+ origin) effect: effect clippedBy: cliprect].
	for i to: self length  do
				[ (selfi) displayat: (pt +  origin) effect: effect clippedBy: cliprect
				]
	]\gb49B
quickDisplayAt: pt scale: scal offset: delta | i rect x1 y1 x2 y2
	["outline me and all of the subimages in this image in given scale"
	x1_ (scal*(rectangle minX + pt x) + delta x) asInteger.
	y1_ (scal*(rectangle minY + pt y) + delta y) asInteger.
	x2_ (scal*(rectangle maxX + pt x) + delta x) asInteger.
	y2_ (scal*(rectangle maxY + pt y) + delta y) asInteger.
	rect _ x1y1 rect: x2y2.
	rect outline.
	pt _ pt+origin.
	for i to: self length do
		[rect _ (selfi) rectangle.
		x1_ (scal*(rect minX + pt x) + delta x) asInteger.
		y1_ (scal*(rect minY + pt y) + delta y) asInteger.
		x2_ (scal*(rect maxX + pt x) + delta x) asInteger.
		y2_ (scal*(rect maxY + pt y) + delta y) asInteger.
		rect _ x1y1 rect: x2y2.
		rect color: gray mode: oring.
		]
	]\gb45B

MODULE ACCESS\gbf5 
= image
	[(rectangle = (image rectangle))
	]\gb9B
bottom
	["return the bottom y of the bounding rectangle of theImage."
	 rectangle corner y.
	]\gb8B
center
	["return the center of the Image."
	 rectangle center.
	]\gb8B
contains: pt 
	["return true if the  bounding rectangle for the Image contains pt.."
	 rectangle has: pt
	]\gb15B
corner
	["return the corner of the Image."
	 rectangle corner.
	]\gb8B
corner_ pt
	["modify the corner of the Image."
	 rectangle corner_ pt.
	]\gb12B
extent 
	["return the extent (width,height) of the Image."
	 rectangle extent
	]\gb9B
height
	["return the height of the Image."
	 rectangle extent y.
	]\gb8B
leftside
	["return the leftmost x of the bounding rectangle of theImage."
	 rectangle origin x.
	]\gb10B
origin
	["return the origin of the image."
	 origin
	]\gb8B
origin: origin
	["change the origin of the image."]\gb16B
rectangle 
	["return the rectangle that bounds the Image."
	 rectangle
	]\gb12B
rectangle: r 
	["redefine rectangle that bounds the Image."
	rectangle_ r
	]\gb15B
resize | i 
	[" Recompute the bounding rectangle of the Image"
	[nil form	 [rectangle _ Rectangle new origin: origin extent: 11]
				rectangle _ Rectangle new origin: origin extent: form extent].
	
	for i to: self length do
		[ rectangle  _ rectangle include: ((selfi) rectangle) ]
	]\gb13B
rightside
	["return the rightmost x of the bounding rectangle of theImage."
	 rectangle corner x.
	]\gb11B
superimage
	["return the superimage (Image containing) of this Image."
	 superimage
	]\gb12B
top
	["return the top y of the bounding rectangle of theImage."
	 rectangle origin y.
	]\gb5B
width
	["return the width of the Image."
	 rectangle extent x.
	]\gb7B

PATTERN ACCESS\gbf5 
black
	["black out the image"
	self color: black effect: 0.
	]\gb7B
boxcomp 
	["border without disturbing the interior."
	rectangle comp
	]\gb10B
color: color effect: effect 
	["basic rectangle call to blt."
	rectangle color: color mode: effect .
	aurorarunning	[user displayoffwhile [aurora destination: rectangle ; source: rectangle ;
					figure: figure ; ground: ground ;  function: 002117 "AoverB" ; doit
							]]
 ]\gb30B
gray
	["gray out the image"
	self color: gray effect: storing
	]\gb6B
reverse
	["reverse  the image (black to white and white to black)"
	self color: black effect: 2
	]\gb9B
white 
	["white out the image"
	form is: BorderedText [ (rectangle inset: (11) and: (11)) clear: 0]
	self color: white effect: over.
	]\gb8B

TRANSFORMATIONS\gbf5 
griddedpoint: pt 
	[ ((pt x)| xgrid)  ((pt y)| ygrid) ]\gb19B
normalize | delta i 
	["recompute origin, rectangle and path so that: path origin = 00."
	[nil  path  [] delta _ (path origin) copy. path normalize. origin translate: delta]. 	for i to: self length do [ (selfi) normalize ].
	]\gb22B
translate: delta 
	["translate the origin and bounding rectangle of the Image."
	rectangle _ rectangle translate: delta.
	origin translate: delta.
	]\gb19B
translateto: pt 
	["move the Image to pt."
	self translate: pt - origin.
	]\gb18B

SYSTEM\gbf5 
copy | im i
[
	im _ Image new origin: origin copy rectangle: rectangle copy path: path copy form: form copy figure: figure copy ground: ground copy xgrid: xgrid copy  ygrid: ygrid copy.
	for i to: self length do 
		[im add: (selfi) copy].
	 im
]\gb5B
fromPress: press value: s | numberofsubimages i code t
	["retrieves and builds an instance of class Image from a press file"
	self default. 
	numberofsubimages_ s nextword.
	origin _ s nextPoint.
	i _ s nextPoint.
	rectangle _ i rect: s nextPoint.
	xgrid _ s nextword.
	ygrid _ s nextword.
	figure _ s nextword.
	ground _ s nextword.

	form _ s next.
	path _ s next.

	for i to: numberofsubimages do [
		s _ press nextControl asStream.
		code _ s next.
		t _ Image new.
		code = t pressCode [
			self addimage: (t fromPress: press value: s)]
		user notify: 'subimage not Image'].

	[form=0 [form _ nil]
	s _ press nextControl asStream.
	code _ s next.
	form _ [code = 4 [TextImage new]; =5 [Form new]; = 6 [BorderedText new] false].
	form and code = form pressCode [
		[code=4 [form frame _ rectangle copy]].
		[code=6 [form frame _ rectangle copy]].
		form fromPress: press value: s]
	user notify: 'illegal form'].

	[path=0 [path _ nil]
	s _ press nextControl asStream.
	code _ s next.
	path _ [code = 6 [Path new]; =7 [Point new] false].
	path and code = path pressCode [path fromPress: press value: s]
	user notify: 'illegal path']
	]\gb26B32i65I
hideData: complete | s
	["stores an instance of class Image on a press file. ignore complete"
	Stream new of: (s _ String new: 24);
		nextword_ self length; "number of subimages"
		nextPoint_ origin;
		nextPoint_ rectangle origin;
		nextPoint_ rectangle corner;
		nextword_ xgrid;
		nextword _ ygrid;
		nextword _ figure;
		nextword _ ground;
		next _ [formnil  [0] 1];
		next _ [pathnil [0] 1].
	 s]\gb19B7i66I66i19I
hidePress: press complete: c [
	c  0 [
		"called from PressPrinter print:in:"
		[formnil ["already done"]
		form hidePress: press complete: c].
		pathnil []
		path hidePress: press complete: c]
	"1. called from Image presson:in:"
	press skipcode: self pressCode data: (self hideData: c)]\gb29B15i12bI22B17i12I95i16bI17B
kbd | 
	[" default response for Images."
	user kbd.
	self reverse ; reverse.
	]\gb8B
mp | p
	[" returns a gridded point relative to my rectangle."
	p _ user mp.
	p x_ ((p x) - rectangle origin x) | xgrid. 
	p y_ ((p y) - rectangle origin y) | ygrid.
	 p
	]\gb8B
pressCode [1]\gb10B
presson: press in: r | yvalue t h rect [
	self length > 0 and r height < (h _ press scale * self height) [
		"try on next page" self]

	self hidePress: press complete: 1.
	for t from: self do [
		yvalue _  t presson: press in: r.
		"if subimage didn't fit, print version will be clipped,
		but entire subimage will be stored"
		t hidePress: press complete: [yvalue is: Integer [0] 1]].

	formnil [r corner y - h]
	rect _ r copy.
	rect corner y _ rect corner y - (( path y)*(press scale)).
	"form will be hidden by Image presson:in: or PressPrinter print:in:".
	form presson: press in: rect]\gb21B19b1B71i16I10b1B100i91I171i66I
printon: strm | t [
	strm append: 'an Image: '.
	array is: String [strm space append: self]
	for t from: self do [strm space print: t]]\gb14B

ACCESS TO PARTS\gbf5 
figure
	["return the figure color (color associated with black) for this Image"
	 figure
	]\gb8B
figure: figure 
	["change the figure color (color associated with black) for this Image"]\gb17B
form 
	["return the form for this Image"
	 form
	]\gb7B
form: form 
	["change the form for this Image"]\gb13B
ground
	["return the ground color (color associated with white) for this Image"
	 ground
	]\gb8B
ground: ground 
	["change the ground color (color associated with white) for this Image"]\gb17B
hash [rectangle hash]\gb5B
path 
	["return the path for this Image"
	 path
	]\gb7B
path: path
	["change the path for this Image"]\gb12B
superimage: superimage \gb
xgrid 
	["return the x gridding module for this Image"
	 xgrid
	]\gb8B
xgrid: xgrid 
	["set the x gridding module for this Image"
	]\gb15B
ygrid 
	["return the y gridding module for this Image"
	 ygrid
	]\gb8B
ygrid: ygrid 
	["set the y gridding module for this Image"
	]\gb15B

Fist and last\gbf5 
close
	| im
	[[arraynil
		[]
		for im  from: self asArray notNil do
		[im close]].
	superimage_nil.
	form_nil.
	self vector: 0]\gb7B
\g
SystemOrganization classify: Image under: 'Form Path Image'.\g
Image classInit\g

"Path"l15000z20000\gbf5 
Class new title: 'Path'
	subclassof: Set
	fields: ''
	declare: '';
	asFollows\gbf5 

This class has not yet been commented\gi

INIT\gbf5 
init 
	["must be executed for each new instance."
	self default.
	]\gb7B

BUILDING PATHS\gbf5 
comment 
	["see Set for these ... add:, append:, and _ are the main ones"
	]\gb10B

ACCESSING PATHS\gbf5 
pointnearestto: p | distance i nearest d
	["return the index of the point  in the path nearest (manhatten norm) to p."
	distance _ p dist: self1.
	nearest _ 1.
	for i to: position do 
		[	d _  p dist: selfi .
			d< distance 
			[ nearest_ i. distance _ d.]  
		]
	 nearest
	]\gb18B

MODIFYING PATHS\gbf5 
deleteindex: i | r [
	r _ array( i+1 to: position).
	position _ i-1.
	self append: r.
	array(position+1) _ nil.
	]\gb15B
insert: pt atindex: index | r 
	[
	"insert pt at index in the path"
	index > position [self next _ pt]
	r _ [position = limit [self grow] self growby: 0].
	position _ 0.
	self append: (r  1 to: index-1);
		next _ pt;
		append: r(index to: r length).
	]\gb26B

SPECIAL PATHS\gbf5 
addarcfrom: p1 via: p2 to: p3 | pa pb i k s
	["Kaehler method for Flegal curve"
	s_ Path new init. 
	s add: p1.
	pa_ p2-p1. pb_ p3-p2.
	k_ 5 max: (pa x abs + pa y abs + pb x abs + pb y abs)/20.
	for i to: k do		"k is a guess how many segments are appropriate"
		[s add: (pa*i/k+p1*(k-i)) + (pb*(i-1)/k+p2*(i-1)) / (k-1)]
	s add: p3 .
	for i to: (s length-1) do [  self addlinefrom: si to: s(i+1) ] 
]\gb30B16i33I134i48I
addlinefrom: p1 to: p2 | x1 y1 dx dy yinc x0 y0 cdl i
	["for now just add points to the space at alto resolution between p1 and p2
	inclusive"
	dx_ ( p2 x) - (p1 x).
	dy_ ( p2 y) - (p1 y).

	[dx < 0  [dx _ 0-dx. dy _ 0-dy. x0_ p2 x. y0 _ p2 y]
							x0 _ p1 x. y0 _ p1 y].
	[dy  0  [yinc_1] yinc _ 0-1 . dy _ 0-dy].
	
	 dxdy
		[cdl _ ( dx/2).
		for i from: 0 to: dx do
			[self add: (x0y0). cdl _ cdl + dy.
			x0 _ x0+1. 
 			cdl > dx [cdl _ cdl - dx. y0 _ y0 + yinc]
			]
		]

	"y is fastest mover"
	cdl _ (dy/2).
	for i from: 0 to: dy do
		[self add: (x0y0) . cdl _ cdl+ dx.
		y0 _ y0 + yinc.  
	 cdl > dy  [cdl _ cdl - dy. x0_ x0+1]
		]. 
	]\gb24B32i86I347i20I

TRANSFORMATIONS\gbf5 
+ delta | i
	[ "add delta to every point in the path"
	 (self copy) translate: delta
	]\gb8B
normalize | delta i
	[ "subtract the origin of the path from every point in the path"
	delta _ self origin.
	for i to: self length  do
		[ selfi _ selfi - delta
		]
	]\gb10B
scale: factor | i
	[ "scale every point in the path by factor"
	for i to: self length  do
		[ selfi _ selfi * factor
		]
	]\gb14B
translate: delta | i
	[ "add delta to every point in the path"
	for i to: self length  do
		[ selfi _ selfi + delta
		]
	]\gb17B

MEASURING\gbf5 
corner 
	["return the corner of the bounding rectangle that includes all the points in the path."
	 (self rectangle) corner
	]\gb9B
extent 
	["return the extent of the bounding rectangle that includes all the points in the path."
	 (self rectangle) extent]\gb9B
height 
	["return the height of the bounding rectangle that includes all the points in the path."
	 self size y]\gb9B
origin 
	["return the origin of the bounding rectangle that includes all the points in the path."
	 (self rectangle) origin
	]\gb9B
rectangle | r  i
	["return the bounding rectangle that includes all the points in the path."
	r _ Rectangle new origin: self1 extent: 11.
	for i to: self length do
		[ r _ r include: selfi		
		]
	 r
	]\gb18B
size 
	["return the extent of the bounding rectangle that includes all the points in the path."
	 (self rectangle) extent]\gb7B
width 
	["return the width of the bounding rectangle that includes all the points in the path."
	 self size x]\gb8B

SYSTEM\gbf5 
copy  | t
	["returns a new instance of Path that is a copy "
	t _ Path new init.
	t append: (array(1 to: position)) copy.
	 t]\gb11B
pressCode [6]\gb10B
printon: strm | t [
	strm append: 'a Path: '.
	array is: String [strm space append: self]
	for t from: self do [strm space print: t]]\gb14B
\g
SystemOrganization classify: Path under: 'Form Path Image'.\g

"Point"l15000z20000\gbf5 
Class new title: 'Point'
	subclassof: Object
	fields: 'x y'
	declare: '';
	asFollows\gbf5 

I am an x-y pair of numbers usually designating a location on the screen\gi

Initialization\gbf5 
copy 
	[ (xy)
	]\gb7B
x: x y: y\gb

Arithmetic\gbf5 
 pt [ xpt x and ypt y]\gb5B
 pt [ xpt x and ypt y]\gb5B
* scale
	["Return a Point that is the product of me and scale (which is a Point or Number)"
	Point new x: (x * scale asPtX) y: (y * scale asPtY)]\gb9B1i81I
+ delta
	["Return a Point that is the sum of me and delta (which is a Point or Number)"
	Point new x: (x + delta asPtX) y: (y + delta asPtY)]\gb9B1i77I
- delta
	["Return a Point that is the difference of me and delta (which is a Point or Number)"
	Point new x: (x - delta asPtX) y: (y - delta asPtY)]\gb9B1i84I
/ scale
	["Return a Point that is the quotient of me and scale (which is a Point or Number)"
	Point new x: (x / scale asPtX) y: (y / scale asPtY)]\gb9B1i82I
< pt [ x<pt x and y<pt y]\gb5B
= pt [x=pt x and y=pt y]\gb5B
> pt [x>pt x and y>pt y]\gb5B
abs	"absolute value of a point"
	[	Point new x: (x abs) y: (y abs)	]\gb4Bi27I
dist: pt | t	"distance (Manhattan norm) between pt and self"
	[t _ (pt - self) abs.
	(t x) + (t y)]\gb9B4i47I
length
	[((x asFloat*x asFloat)+(y asFloat*y asFloat)) sqrt]\gb8B
max: t
	[Point new x: (x max: t x) y: (y max: t y)]\gb8B
min: t
	[Point new x: (x min: t x) y: (y min: t y)]\gb8B
normal | n		"unit vector rotated 90 deg clockwise"
	[n_ y asFloat neg  x asFloat.
	n/n length]\gb7B5i38I
normalize 
	["set selt to zero"
	self x _ 0.
	self y _ 0.
	]\gb12B1i18I
translate:  delta
	["increment self by delta"
	x _ x + delta x.
	y _ y + delta y.
	]\gb19B1i25I
| grid
	[Point new x: x|grid y: y|grid]\g

Conversion\gbf5 
asPoint
	["Return self."]\gb9B1i14I
asPtX
	[x]\gb7B
asPtY
	[y ]\gb7B
asRectangle
	["Return a Rectangle with me as both origin and corner."
	self rect: self]\gb13B1i55I
asRectCorner "pretend to be a Rectangle for Rectangle +-*/"\gb13Bi
asRectOrigin "pretend to be a Rectangle for Rectangle +-*/"\gb13Bi
corner
	[ self+ (11)]\gb8B
extent
	[ (11)]\gb8B
extent: p		"infix creation of rectangles"
	[Rectangle new origin: self extent: p]\gb11Bi30I
height
	[ 1]\gb8B
origin
	[ self]\gb8B
printon: strm 
	[strm print: x; append: ''; print: y]\gb16B
rect: p		"infix creation of rectangles"
	[Rectangle new origin: self corner: p]\gb9Bi30I
width
	[ 1]\gb7B

Access to parts\gbf5 
hash [(x lshift: 2) lxor: y]\gb5B
theta | tan theta "return the angle the point makes with origin.  right is 0; down is 90."
	[x=0  [y0  [ 90.0]  270.0].

	 tan _ y asFloat/x asFloat.
	 theta _ tan arctan.

	 x0  [y0 [ theta] 360.0 + theta].
	  180.0 + theta]\gb6B
x	 [x]\gb3B
x _ x\gb
y [y]\gb2B
y _ y\gb

SYSTEM\gbf5 
fromPress: press value: s
	[ x _ s nextword. y _ s nextword]\gb27B
hideData: complete | s
	[Stream new of: (s _ String new: 4); nextPoint_ self.
	 s]\gb19B
hidePress: press complete: c
	[press skipcode: self pressCode data: (self hideData: c)]\gb30B
pressCode [7]\gb10B
\g
SystemOrganization classify: Point under: 'Form Path Image'.\g

"Rectangle"l15000z20000\gbf5 
Class new title: 'Rectangle'
	subclassof: Object
	fields: 'origin corner'
	declare: '';
	asFollows\gbf5 

I am a pair of points, usually representing a rectangular area on the screen\gi

Initialization\gbf5 
copy  
	["new rectangle"
	 (origin copy) rect: (corner copy)
	]\gb8B
fromuser | t
	["Show the origin cursor until the user presses a mouse button,
		then get my origin"
	origin_OriginCursor showwhile [user waitbug].
	"Show the corner cursor and complement me until the user presses
		a button again.  The loop is arranged so 
		that complementing stays on for a little while."
	t_origin.
	CornerCursor showwhile
		[while [corner_t.  t _ user mpnext] do
			[self comp.  t _ t max: origin.  self comp]]]\gb9B6i84I50i159I
fromuserevenword | t
	["Show the origin cursor until the user presses a mouse button,
		then get my origin"
	origin_OriginCursor showwhile [user waitbug].
	"Show the corner cursor and complement me until the user presses
		a button again.  The loop is arranged so 
		that complementing stays on for a little while."
	t_origin.
	CornerCursor showwhile
		[while [corner _ t.  t _ user mpnext] do
			[self comp.  t _ (((t x) + 15 | 16)  t y) max: origin.  self comp]].
	]\gb17B6i84I50i159I
origin: origin corner: corner\gb
origin: origin extent: extent
	[corner _ origin+extent]\gb31B

Aspects\gbf5 
area [(self width)*(self height)]\gb5B
bottom [corner y]\gb7B
corner [corner]\gb7B
corners | v
	[v_ Vector new: 4.
	v1_ origin. v2_ corner x origin y.
	v3_ corner. v4_ origin xcorner y.
	v]\gb8B
corner _ corner\gb
edge: side "Returns one side as a number."
	"Sides are numbered 0-3.  +1 goes counterclockwise.  lxor: 2 gets opposite side."
	[side
		=0["top" origin y];
		=1["left" origin x];
		=2["bottom" corner y];
		=3["right" corner x].
	user notify: 'Invalid side']\gb11B1i29I4i79I
extent
	[corner-origin]\gb8B
extent _ extent
	[corner _ origin+extent. extent]\gb17B
hash [(origin lshift: 1) lxor: corner]\gb5B
height
	[corner y - origin y]\gb8B
height _ h "change my bottom y to make my height h"
	[corner y _ origin y + h]\gb11Bi40I
leftside [origin x]\gb9B
maxX [corner x]\gb5B
maxY [corner y]\gb5B
minX [origin x]\gb5B
minY [origin y]\gb5B
origin [origin]\gb7B
origin _ origin\gb
rightside [corner x]\gb10B
side: side "Returns one side as a rectangle."
	"Sides are numbered 0-3.  +1 goes counterclockwise.  Xor: 2 gets opposite side."
	[side
		=0["top" origin rect: corner xorigin y];
		=1["left" origin rect: origin xcorner y];
		=2["bottom" origin xcorner y rect: corner];
		=3["right" corner xorigin y rect: corner].
	user notify: 'Invalid side']\gb11Bi34I2i80I14i5I41i6I41i8I41i7I
size
	[corner-origin]\gb6B
top [origin y]\gb4B
width
	[corner x - origin x]\gb7B
width _ w "change my right x to make my width w"
	[corner x _ origin x + w]\gb10Bi38I
withEdge: side at: coord "Returns a rectangle with one side moved."
	[side
		=0 [origin xcoord rect: corner];
		=1 [coordorigin y rect: corner];
		=2 [origin rect: corner xcoord];
		=3 [origin rect: coordcorner y].
	user notify: 'Invalid side']\gb25B
withSide: side at: pt "Returns a rectangle with one side moved."
	[side
		=0 [origin xpt y rect: corner];
		=1 [pt xorigin y rect: corner];
		=2 [origin rect: corner xpt y];
		=3 [origin rect: pt xcorner y].
	user notify: 'Invalid side']\gb22Bi42I

Arithmetic\gbf5 
* scale [
"Return a Rectangle which is the product of me and scale (which is a Rectangle, Point, or Number)"
	Rectangle new origin: origin * scale asRectOrigin corner: corner * scale asRectCorner]\gb8B2i98I
+ delta [
"Return a Rectangle which is the sum of me and delta (which is a Rectangle, Point, or Number)"
	Rectangle new origin: origin + delta asRectOrigin corner: corner + delta asRectCorner]\gb8B3i94I
- delta [
"Return a Rectangle which is the difference of me and delta (which is a Rectangle, Point, or Number)"
	Rectangle new origin: origin - delta asRectOrigin corner: corner - delta asRectCorner]\gb8B2i101I
/ scale [
"Return a Rectangle which is the quotient of me and scale (which is a Rectangle, Point, or Number)"
	Rectangle new origin: origin / scale asRectOrigin corner: corner / scale asRectCorner]\gb8B2i99I
= r
	[origin = r origin and: corner = r corner]\gb5B
center
	[origin+corner/2]\gb8B
empty
	[(origin < corner)false]\gb7B
has: pt [origin  pt and pt < corner]\gb8B
include: r "Returns the merge with an adjacent rectangle."
	[(origin min: r origin) rect: (corner max: r corner)]\gb11Bi47I
inset: p1
	[origin+p1 rect: corner-p1]\gb11B
inset: p1 and: p2
	[origin+p1 rect: corner-p2]\gb19B
intersect: r [
	Rectangle new origin: (origin max: r origin)
		corner: (corner min: r corner)]\gb13B
intersects: r
	[(origin max: r origin) < (corner min: r corner)]\gb15B
isWithin: rect  "am I equal to or contained within rect"
	[origin  rect origin and corner  rect corner]\gb14i2B40I
max: rect
	[Rectangle new
		origin: (origin min: rect origin)
		corner: (corner max: rect corner)]\gb11B
minus: r | s yorg ycor		"return Vector of Rectangles comprising
				the part of me not intersecting r "
	["Make sure the intersection is non-empty"
	[originr corner and r origincorner [] self inVector].
	s _ (Vector new: 4) asStream.
	[r origin y>origin y
		[s next _ origin rect: corner x(yorg _ r origin y)]
	 yorg _ origin y].
	[r corner y<corner y
		[s next _ origin x(ycor _ r corner y) rect: corner]
	 ycor _ corner y].
	[r origin x>origin x
		[s next _ origin xyorg rect: r origin xycor]].
	[r corner x<corner x
		[s next _ r corner xyorg rect: corner xycor]].
	s contents]\gb9B15i79I3i41I
nearest: pt
	[((origin x max: pt x) min: corner x) 
	((origin y max: pt y) min: corner y)]\gb13B
side: side distanceTo: pt
	[side
		=0 [pt y-origin y];
		=1 [pt x-origin x];
		=2 [corner y-pt y];
		=3 [corner x-pt x].
	user notify: 'Invalid side']\gb27B
sideNearest: pt | d dmin i imin
	[dmin _ 077777.
	for i from: (0 to: 3) do
		[dmin>(d _ self side: i distanceTo: pt) abs
			[dmin _ d.  imin _ i]].
	imin]\gb16B

Altering\gbf5 
dragto: dest | v i
	[self blt: dest mode: storing.
	v _ dest rect: dest+self extent.
	for i from: (self minus: v) do [i clear].
	origin _ dest. corner _ v corner]\gb13B
growby: pt
	[corner _ corner + pt]\gb12B
growto: corner \gb
maxstretch: bound | bx by boundr selfr
	[bx_(bound corner-origin) x. by_(bound corner-origin) y.
	boundr_bx asFloat/by. selfr_self width asFloat/self height.
	selfr>boundr[self extent_(bx(bx asFloat/selfr) asInteger)]
		self extent_((by asFloat*selfr) asIntegerby)]\gb18B
moveby: pt
	[origin _ origin+pt. corner _ corner+pt]\gb12B
moveto: pt
	[corner _ corner+pt-origin. origin_pt]\gb12B
translate: pt
	[origin _ origin+pt. corner _ corner+pt]\gb15B
translateto: pt 
	[self translate:  pt - origin. ]\gb18B
usermove 
	[self usermove: user screenrect]\gb11B
usermove: bound | m lim
	[lim_bound corner-self extent. self bordercomp. m_user mp.
	while true do
		[[user redbug
			[self bordercomp; moveto: (bound origin max: ((m_user mp) min: lim)); bordercomp]].
		while (user anybug and m=user mp) do [].
		[user bluebug[user waitnobug. self bordercomp]]]]\gb16B
usersize 
	[self usersize: user screenrect]\gb11B
usersize: bound | m lim
	[[self originnil[origin_user mp. self extent_16]].
	self bordercomp. m_user mp.
	while true do
		[lim_bound corner-self extent.
		[user redbug
			[self bordercomp; moveto: (bound origin max: ((m_user mp) min: lim)); bordercomp]].
		[user yellowbug[self bordercomp.
				corner_m_(user mp min: bound corner) max: origin. self bordercomp]].
		while (user anybug and m=user mp) do [].
		[user bluebug[user waitnobug. self bordercomp]]]]\gb16B

Conversion\gbf5 
asRectangle
	["Return self."]\gb13B1i14I
asRectCorner
	[corner ]\gb14B
asRectOrigin
	[origin ]\gb14B
bitsFromStream: strm | rec s [
	rec _ origin rect: origin + (self width  (16 min: self height)).
	s_ String new: rec bitStringLength.
	while rec maxY  corner y do
		[strm into: s.  rec bitsFromString: s; moveby: 016].
	rec minY < corner y
		[rec corner y_ corner y.
		s_ nil. s_ String new: rec bitStringLength.
		strm into: s.  rec bitsFromString: s]]\gb21B
bitsFromString: str
	["default stores bits onto display"
	self bitsFromString: str mode: storing]\gb21B1i34I
bitsFromString: str mode: mode [user croak] primitive: 52\gb31B
bitsFromString: str mode: mode clippedBy: clipRect
		| destRect 
	["Load the screen bits within my area from those stored in str.
		If clipRect is not nil, then load only those bits within both
		myself and clipRect"
	self bitStringLengthstr length[user notify: 'wrong bit string length']
	destRect_self intersect: user screenrect.
	[nilclipRect[] destRect_destRect intersect: clipRect].
	BitBlt init destbase_mem066;
	destraster_user screenrect width/16|2;
	dest_destRect origin;
	extent_destRect extent;
	sourceraster_corner x-origin x+15/16;
	source_destRect origin-origin;
	sourcebase _ str ; copy: mode]\gb53B15i57u3U7u8U64u8IU
bitsIntoString | str [
	str _ String new: self bitStringLength.
	self  bitsIntoString: str mode: storing.
	str]\gb15B
bitsIntoString: str
	["default stores bits into the string"
	self bitsIntoString: str mode: storing]\gb21B1i37I
bitsIntoString: str mode: mode [user croak] primitive: 51\gb31B
bitsIntoString: str mode: mode clippedBy: clipRect
		| sourceRect 
	["Store the screen bits within my area into str.  If clipRect is not nil,
		then store only those bits within both myself and clipRect,
		leaving alone the other bits in str"
	self bitStringLengthstr length[user notify: 'wrong bit string length']
	sourceRect_self intersect: user screenrect.
	[clipRectnil[] sourceRect_sourceRect intersect: clipRect].
	BitBlt init destraster_corner x-origin x+15/16;
	dest_sourceRect origin-origin;
	extent_sourceRect extent;
	sourcebase_mem066;
	sourceraster_user screenrect width/16|2;
	source_sourceRect origin;
	destbase _ str ; copy: mode]\gb53B17i42u3U6u8U65u8U36u3IU
bitsOntoStream: strm | rec s [
	rec _ origin rect: origin + (self width  (16 min: self height)).
	s_ (String new: rec bitStringLength) all_0.
	while rec maxY  corner y do
		[rec bitsIntoString: s; moveby: 016.
		strm append: s].
	rec minY < corner y
		[rec bitsIntoString: s.  strm append:
			s(1 to: s length/rec height*(corner y-rec minY))]]\gb21B
bitStringLength | extent [
	extent _ corner - origin.
	 2 * extent y* (extent x +15/16)]\gb16B
hardcopy: pf [self hardcopy: pf thickness: 2]\gb13B
hardcopy: pf thickness: th | r [
	for r from: ((self inset: 0-th) minus: self) do [pf showrect: r color: 0]]\gb27B
printon: strm 
	[strm print: origin; append: ' rect: '; print: corner]\gb16B

Image\gbf5 
blowup: at by: scale | z dest
	[dest _ Rectangle new origin: at extent: self extent*scale.
		[(dest has: origin) or: (dest has: corner) 
			[z _ self bitsIntoString. dest outline.
			self moveto: dest origin. self bitsFromString: z]
		dest outline].
	self blowup: at by: scale spacing: 1]\gb21B
blowup: at by: scale spacing: spacing
		| extent z inc sinc slice width height dest i j spread
	[extent _ self extent.
	scale _ scale asPoint.  spacing _ spacing asPoint.
	dest _ Rectangle new origin: at extent: extent*scale.
	z _ 10. width _ extent x. height _  0extent y.
	spread _ (scale-spacing) x.
	for i to: 2 do								"first do horiz, then vert"
		[inc _ z * 1. sinc _ z * scale.
		slice _ Rectangle new
			origin: (z * width) + [i = 1 [self origin] at]
			extent: z + height.
		dest _ at + (z * (scale * width)).
		for j to: width do					"slice it up"
			[dest _ dest - sinc.
			slice moveby: inc.
			slice blt: dest mode: storing]
		slice _ Rectangle new origin: at + z
						extent: height+(z*(scale-1)).
		for j to: width do		"clear slice source"
			[slice clear: white. slice moveby: sinc]
		slice _ Rectangle new origin: at
						extent: height + (z * ((scale*width)-1)).
		for j to: spread - 1 do				"spread it out"
			[slice blt: at + z mode: oring]
		z _ 01.					"flip to do vertical"
		width _ extent y. height _ (scale*extent) x0.
		spread _ (scale-spacing) y]
	]\gb40B290i27I198i13I180i20I159i15I51i21I
blt: dest mode: mode [user croak] primitive: 47\gb21B
blt: dest mode: mode clippedBy: clipRect
		| destRect clippedSource
	["Copy the screen bits within my area to the rectangle whose
		origin is dest and whose extent is the same as mine.
		If clipRect is not nil, then copy only those bits within both
		the destination rectangle and clipRect"
	destRect_(Rectangle new origin: dest extent: self extent)
		intersect: user screenrect.
	[nilclipRect[] destRect_destRect intersect: clipRect].
	"find the source for the bits after clipping"
	clippedSource_origin+destRect origin-dest.
	BitBlt init
		destbase_mem066;
		destraster_user screenrect width/16|2;
		dest_destRect origin;
		extent_destRect extent;
		sourcebase_mem066;
		sourceraster_user screenrect width/16|2;
		source_clippedSource;
		copy: mode]\gb43B28i71u4U44u8U83u8IU151i43I
bltcomp: dest mode: mode [user croak] primitive: 48\gb25B
brush: dest mode: mode color: color [user croak] primitive: 49\gb36B
brush: dest mode: mode color: color clippedBy: clipRect
		| destRect clippedSource
	["Brush the screen bits within my area to the rectangle whose
		origin is dest and whose extent is the same as mine.
		If clipRect is not nil, then brush only those bits within both
		the destination rectangle and clipRect"
	destRect_(Rectangle new origin: dest extent: self extent)
		intersect: user screenrect.
	[nilclipRect[] destRect_destRect intersect: clipRect].
	"find the source for the bits after clipping"
	clippedSource_origin+destRect origin-dest.
	BitBlt init
		color_color;
		destbase_mem066;
		destraster_user screenrect width/16|2;
		dest_destRect origin;
		extent_destRect extent;
		sourcebase_mem066;
		sourceraster_user screenrect width/16|2;
		source_clippedSource;
		paint: mode]\gb58B28i72u4U44u8U84u8IU151i43I
clear		"default is backround"
	[self color: background mode: storing]\gb7Bi22I
clear: color
	[self color: color mode: storing]\gb14B
color: color mode: mode [user croak] primitive: 50\gb24B
comp
	[self color: black mode: xoring]\gb6B
comp: color
	[self color: color mode: xoring]\gb13B
fillin: color mode: mode | T bits p s dirs i which		"Rectangle new fromuser fillin: gray"
	[T _ Turtle init.
	p_ origin + (self width0).
	s_ Rectangle new origin: p extent: self extent.
	dirs_((10), (10), (01), (01)).
	bits_ s bitsIntoString.
	self blt: p mode: storing.		"s _ self"
	user waitbug. T place: user mp; pendn.
	while user anybug do		"draw seed in self"
		[T goto: user mp].
	self blt: p mode: xoring.		"s _ seed only"
	s blt: origin mode: xoring.		"take seed out of self"
	user waitbug.
	while user anybug do
		[for which from: 0 to: 2 by: 2 do [
		for i to: 2 do
			[s blt: dirs(which+i)+p mode: oring]		"smear seed around"
 		self blt: p mode: erasing]]		"then clip to outline"
	s brush: origin mode: mode color: color.		"paint it in"
	s bitsFromString: bits]		"restore background to s"\gb25B
flash [self comp; comp]\gb6B
reverse
	[self color: black mode: xoring]\gb9B
rotate		"(00 rect: 128128) rotate."
		| size maskr spt mpt tpt data temp atab btab i unit
	[size _ self extent x. spt _ sizesize.		"size must be a power of 2"
	data _ Rectangle new origin: origin extent: spt.
	maskr _ Rectangle new origin: (mpt_ origin + (0size)) extent: spt.
	temp _ Rectangle new origin: (tpt_ mpt + (size0)) extent: spt.
	atab _ (00),(10),(00),(01),(11),(01),(10),(10),(10).
	btab _ (00),(11),(00),(11),(11),(11).
	unit _ size/2.
	maskr clear: white.
	(Rectangle new origin: mpt extent: unitunit) clear: black.
	until unit<1 do
		[for i to: 3 do		"flip left and right halves"
			[temp clear: white.
			maskr blt: atabi*unit + tpt mode: storing.
			maskr blt: atab(3+i)*unit + tpt mode: oring.
			data bltcomp: tpt mode: erasing.
			temp blt: atab(6+i)*unit + origin mode: xoring].
		for i to: 3 do		"flip diagonals"
			[temp clear: white.
			maskr blt: btabi*unit + tpt mode: storing.
			data bltcomp: tpt mode: erasing.
			temp blt: btab(3+i)*unit + origin mode: xoring].
		(unit_ unit/2)<1[]
		maskr blt: (0unit)+mpt mode: erasing.
		maskr blt: (unit0)+mpt mode: erasing.
		maskr blt: (unit*20)+mpt mode: oring.
		maskr blt: (0(2*unit))+mpt mode: oring]]\gb8B

Border\gbf5 
border: thick color: color	"paints a border withoud disturbing interior"
	[(Rectangle new
		origin: origin-(thickthick) corner: (corner x+thick)origin y)
	clear: color;
	moveto: (origin x-thick)corner y; clear: color;
	origin _ corner x(origin y-thick); clear: color;
	moveto: origin-(thickthick); clear: color]\gb27Bi45I
boxcomp	"paints a border withoud disturbing interior"
	[(Rectangle new
		origin: origin-(22) corner: (corner x+2)origin y)
	color: black mode: xoring;
	moveto: (origin x-2)corner y; color: black mode: xoring;
	origin _ corner x(origin y-2); color: black mode: xoring;
	moveto: origin-(22); color: black mode: xoring]\gb8Bi45I
outline 	"default border is two thick"
	[self outline: 2]\gb9Bi29I
outline: thick | t
	[t _ (11)*thick.
	(self inset: t) clear: black.  self clear: white]\gb15B
\g
SystemOrganization classify: Rectangle under: 'Form Path Image'.\g

"TextImage"l15000z20000\gbf5 
Class new title: 'TextImage'
	subclassof: Textframe
	fields: 'c1 c2 begintypein superimage figure ground'
	declare: 'cut esc paste aurora Scrap scrap bs Deletion aurorarunning paragraphmenu ctlw ';
	asFollows\gbf5 

This class has not yet been commented\gi

INIT\gbf5 
classInit 
[
	bs _ 8. ctlw _ 145. esc _ 160. cut _ 173. paste _ 158.
	Scrap _ Deletion _ nullString.
	paragraphmenu _ Menu new string:
'resize
fit
cut
paste
copy
align
figure
ground
'.
	aurora _ "Aurora new" nil.
	aurorarunning _ false.
]
\gb11B
close
	[superimage_nil]\gb7B
paragraph: para frame: frame style: style
	[
	self paragraph: para frame: frame style: style figure: 1 ground: 0
	]\gb43B
paragraph: para frame: frame style: style figure: figure ground: ground
	[
	[nil para  [ para _ nullString ]].
	c1 _ c2 _ begintypein_ 1.
	self para: para frame: frame style: style
	]\gb73B
text: t width: w | run r
	[
	c1 _ c2 _ begintypein_ 1.
	run _ String new: 2. run word: 1 _  16 * 7 + 0177400.
	r _ Rectangle new origin: 00 extent: w(DefaultTextStyle lineheight+2).
	self paragraph: (Paragraph new text: t runs: run  alignment: 2) frame: r style: DefaultTextStyle.

 ]\gb26B

EDITING\gbf5 
align
	[para alignment _ (1 2 4 0 0)(1+para alignment).
	self show.
	self reversefrom: c1 to: c2.
	]\gb7B
checklooks | t val mask [
	"see ParagraphEditor checklooks.
	substitute c1 for loc1, c2 for loc2, oldEntity for oldpara, entity for para"
	t _ (166 150 137 151   230 214 201 215
		135 159 144 143 128 127 129 131 180 149
		199 223 208 207 192 191 240 226) find: user kbck.
	t=0[false]
	user kbd.
	t=25[self toBravo]; "ctl-T" 
	 =26[self fromBravo]. "ctl-F" 

	"[oldEntity[] oldEntity _ entity recopy]."
	val _ (1 2 4 256   1 2 4 256  "ctl-b i - x   B I  X"
		0 16 32 48 64 80 96 112 128 144  "ctl-0 1 ... 9"
		160 176 192 208 224 240)t.  "ctl-shift-0 1 ... 5"
	[val=256[mask_ 0377.  val_ 0]		"reset all"
		val<0[mask_ 0-val.  val_ 0]		"reset emphasis"
		val>0 and val<16[mask_ val]	"set emphasis"
		mask_ 0360].				"set font"
	para maskrun: c1 to: c2-1 under: mask to: val]\gb11B
copyselection 
	["copy the current selection and store it in the Scrap."
	Scrap _ para copy: c1 to: c2-1.
	]
\gb16B
cut 
	["cut out the current selection and redisplay the paragraph."
	Scrap _ para copy: c1 to: c2-1.
	self reversefrom: c1 to: c2.	"deselect old selection"
	para replace: c1 to: c2-1 by: nullString.
	c2 _ c1.
	begintypein _ false.
	self show.
	self reversefrom: c1 to: c2.	"show new selection"
	]
\gb6B
edit: superimage | pt charindex
	[
	"eventually a general paragraph manipulator for now just a hack."
	
	self show ; reversefrom: c1 to: c2." show current selection"user waitnobug.
	until 1=2 do "forever for now"
		[
		user kbck [self kbd]
		user yellowbug [paragraphmenu bug
			=1	[self resize ]; "resize"
			=2	[self fit]; "include all of the text in the current selection"
			=3	[self cut]; "delete the current selection"
			=4	[self paste]; "paste the Scrap over the selection"
			=5	[self copyselection]; "copy current selection"
			=6	[self align]; "change the alignment of the paragraph"
			=7	[self setfigure]; "set color corrisponding to 1"
			=8	[self setground] "set color corrisponding to 1"
								]
		user redbug [self reversefrom: c1 to: c2. frame has: (pt _ user mp)
										[self select: pt]
							self.]
		user tabletbug [frame has: (pt _ user mp)
										[self tabletBug]
							self reversefrom: c1 to: c2. self.]
		user bluebug [self reversefrom: c1 to: c2. "erase current selection"
								self.] "and exit back to the document"
		]
	
	]\gb17B
fintype
	[begintypein
		[	[begintypein<c1
				[Scrap _ para copy: begintypein to: c1-1.
				c1 _ begintypein]].
		begintypein _ false]
	false]\gb9B
fit| t 
	["make the bounding rectangle of the TextImage contain all the textwhile not changing the width of the TextImage."
	self white.
	frame extent_ ((frame width) 1000).
	t _ self rectofchar: (para length+1).
	frame extent_ (frame width)((t corner y) - (frame origin y)).
	self show. frame border: 1 color: 1. self reversefrom: c1 to: c2.
]\gb3B7i115I
kbd | more char  "key struck on the keyboard"
	[c1<c2 and self checklooks[ self show reversefrom: c1 to: c2]
	more _ Set new string: 16.
	[begintypein[] Deletion _ para copy: c1 to: c2-1. begintypein _ c1].
	while (char _ user kbdnext) do [
		char
		=bs ["backspace"
			more empty [begintypein _ begintypein min: (c1 _ 1 max: c1-1)]
			more skip: 1];
		=cut [self cut];
		=paste [self paste];
		=ctlw ["ctl-w for backspace word"
			more reset.
			c1 _ 1 max: c1-1.	
			while [c1>1 and (para(c1-1)) tokenish] do [c1 _ c1-1].
			begintypein _ begintypein min: c1];
		=esc ["select previous type-in"
					[more empty[self reversefrom: c1 to: c2]
			para replace: c1 to: c2-1 by:  more. c1 _ c2].
			self fintype.
			c1 _ c2-Scrap length.
			self reversefrom: c1 to: c2]
		"just a normal character"
	more next_ char].
		para replace: c1 to: c2-1 by:  more. c2 _ c1 + more length. c1 _ c2.
	self show. self reversefrom: c1 to: c2]\gb4B587i23I
paste 
	["paste the Scrap over the current selection and redisplay the paragraph."
	self fintype.
	self reversefrom: c1 to: c2.	"deselect current selection"
	para replace: c1 to: c2-1 by: Scrap.
	c2 _ c1 + Scrap length.
	self show.
	self reversefrom: c1 to: c2.	"highlight new selection"
	]
\gb8B
resize | t pt xgrid ygrid
	["Show the origin cursor until the user presses a mouse button,
		then get my origin"
	"Show the corner cursor and show me until  user nobug
	"
	t_frame origin.
	CornerCursor topage1.
	user waitbug. self white.
	frame corner_ frame origin.
	until user nobug do
			[self white.
			( pt _ 
			((superimage superimage) mp)+
				((superimage superimage) rectangle origin)).
			frame corner_ pt max: frame origin+ (16(style lineheight)).
			self displayat: frame origin effect: 0 clippedBy: frame.
			]
	NormalCursor topage1.
	self show. frame boxcomp. self reversefrom: c1 to: c2.
]\gb7B21i85I1i56I
setfigure | 
	["for now just increment the figure color by 1 \ 14"
	figure _ (figure +1 ) \ 14.
	self displayat: (self frame origin) effect: 0 clippedBy: user screenrect.
]\gb10B5i52I
setground | 
	["for now just increment the figure color by 1 \ 14"
	ground _ (ground +1 ) \ 14.
	self displayat: (self frame origin) effect: 0 clippedBy: user screenrect.
]\gb10B5i52I
white 
	["white out the image"
	(frame inset: (22)) clear: 0.
	]\gb8B

SELECTION\gbf5 
complementfrom: hair1 to: hair2 | temprect
["Complement the screen dots corresponding to the lines and part-lines of the paragraph between hair1 inclusive and hair2 exclusive.  If hair1 = hair2, this is a no-op.  If hair1 > hair2, they are reversed. This complementing happens in three parts, A, B, and C, between points 1 and 2, according to the following illustration:
					1AAA
					BBBB
					BBBB
					BBBB
					CCC2
unless there is just one line involved, as in:
					1DD2
"
	"one line case"
	hair1 minY = hair2 minY
		[((([hair1 minX  hair2 minX [hair1 origin rect: hair2 corner]
		hair2 origin rect: hair1 corner]) intersect: frame) intersect: window) comp]

	[hair1 minY > hair2 minY [
		temprect _ hair1. hair1 _ hair2. hair2 _ temprect]].

	temprect _ (frame minX  hair1 maxY) rect: (frame maxX  hair2 minY).
	(((hair1 origin rect: (temprect maxX  temprect minY)) intersect: frame) intersect: window)  comp.
	((temprect intersect: frame) intersect: window)  comp.
	((((temprect minX  temprect maxY) rect: hair2 corner) intersect: frame) intersect: window)  comp.
	]\gb32B
reversefrom: char1 to: char2| h1 h2
["Complement the dots corresponding to the the lines and part-lines of the paragraph between the left edge of char1 and the left edge of char2.  If char1 = char2, this is sort of a no-op.  If char1 > char2, this is undefined."
	self ptofchar: char1. h1 _ reply1 rect: reply2.
 	[char2=char1[h2 _ h1+ (10)] self ptofchar: char2. h2 _ reply1 rect: reply2.].
	self complementfrom: h1 to: h2]\gb28B
select: pt | h1 h2 c h drag2 selection
	[
	"draw out and record ( c1 and c2) a selection"
	c1 _ c2 _ self charofpt: pt.
	h1 _ reply1 rect: reply2.
	h2 _ h1 + (10).
	self complementfrom: h1 to: h2.
	selection _ true.
	while (pt _ user mpnext) do [
		c _ self charofpt: pt.
		h _ "proj screenHairBeforeThatChar" reply1 rect: reply2.
		[c1 = c2 [drag2 _ c  c2]].
		[drag2 [
			[c < c1 [h _ self ptofchar: (c _ c1). h _ reply1 rect: reply2.]].
			self complementfrom: h to: h2.
			c2 _ c. h2 _ h]
		[c > c2 [h _ self ptofchar: (c _ c2). h _ reply1 rect: reply2.]].
		self complementfrom: h1 to: h.		c1 _ c. h1 _ h].
		h1 = h2 [
			self complementfrom: h1 to: (h2 _ h1 + (10))]].
	drag2 []
	"get rid of extra line in backwards select"
	self complementfrom: h2 - (10) to: h2]\gb11B

SYSTEM\gbf5 
copy | t
	[
	t _  TextImage new paragraph: para copy frame: (frame copy) style: style copy.
	t c1_ c1 ; c2_ c2 ; begintypein _ begintypein.
	 t
	]\gb10B
fromPress: press value: s [
	"frame set by Image"
	para _ Paragraph new fromPress: press value: s.
	figure _ s nextword.
	self paragraph: para frame: frame style: DefaultTextStyle
		figure: figure ground: s nextword]\gb26B1b2B1i18I
hideData: complete | s p [ 
	p _ para hideData: complete.
	Stream new of: (s _ String new: p length+4);
		append: p;
		nextword _ figure;
		nextword _ ground.
	s]\gb19B
hidePress: press complete: c [
	press skipcode: self pressCode data: (self hideData: c)]\gb29B
pressCode [4]\gb10B
presson: press in: r 
	[
	 para presson: press in: r.
	]\gb23B
show | lastvisible
	["display text and expand the frame in y to include all of
		the text if the textimage is too small"
	super show.
	lastvisible _ self rectofchar: para length.	"see if lastvisible out of frame"
	lastvisible bottom > frame bottom 
		[frame corner y_ lastvisible corner y.
			super show.
		]
	]\gb7B11b2B

ACCESS TO PARTS\gbf5 
begintypein_ begintypein \gb
c1_ c1 \gb
c2_ c2 \gb
figure 
	["return the figure color (color associated with black) for this TextImage"
	 figure
	]\gb9B
figure: figure 
	["change the figure color (color associated with black) for this TextImage"]\gb17B
ground 
	["return the ground color (color associated with white) for this TextImage"
	 ground
	]\gb9B
ground: ground 
	["change the ground color (color associated with white) for this TextImage"]\gb17B
leftflush
	[ (self para) flushleft]\gb11B
rectangle
	["Return rectangle (frame of Textframe) for compatibility with Image calls -- 
		needed in findbyrect: in Document"
	frame]\gb11B
text
	[ self para text]\gb6B

DISPLAY\gbf5 
displayat: pt effect: effect clippedBy: cliprect | clippedrect
	["display text "
	super displayat: pt effect: effect clippedBy: cliprect.
	aurorarunning 
				[user displayoffwhile
						[clippedrect _ (super frame) intersect: (user screenrect).
						aurora destination: clippedrect ; source: clippedrect ;
						figure: figure ; ground: ground ;  function: 002117 "AoverB" ;
						 doit; function: 0 ; doit.
						]
				]
	]\gb64B
\g
SystemOrganization classify: TextImage under: 'Form Path Image'.\g
TextImage classInit\g 