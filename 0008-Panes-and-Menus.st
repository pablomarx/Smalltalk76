'From Smalltalk 5.5k XM November 24 on 22 November 1980 at 2:57:08 am.'
\g
"CodePane"l15000z20000\gbf5 
Class new title: 'CodePane'
	subclassof: Window
	fields: 'pared class selector selectorPane scrollBar'
	declare: 'editmenu ';
	asFollows\gbf5 

I am a Window for editing a paragraph which may include Smalltalk source code.  My selectorPane (not necessarily of class SelectorPane, and possibly even myself) compiles and doits for me.\gi

Initialization\gbf5 
class: class selector: selector para: para\gb
classInit
	[editmenu ← Menu new string:
		'again
copy
cut
paste
doit
compile
undo
cancel
align']\gb11B
from: selectorPane\gb
init\gb
showing: paragraph
	[pared ← ParagraphEditor new para: paragraph asParagraph frame: nil.
	pared formerly: false; fixframe: frame.
	self windowenter.
	scrollBar ← ([scrollBar≡nil⇒ [ScrollBar new] scrollBar]) on: frame from: pared]\gb20B

Window protocol\gbf5 
close
	[pared unselect. selectorPane ← pared ← nil. scrollBar close]\gb7B
doit | s val d [
	d ← [user leftShiftKey⇒ [mem◦067] false].
	[d⇒ [mem◦067 ← 58]].
	scrollBar hide.

	"do automatic selection (ESC) on empty selections"
	[(s ← pared selectRange) empty⇒ [
		pared unselect; fintype; complement.
		s ← pared selectRange]].

	val ← selectorPane execute: pared selectionAsStream for: self. 
	[val≡nil or⦂ s ≠ pared selectRange⇒ ["result is nil or error occurred"]
	"automatically paste result"
	s← s stop+1.
	pared Scrap ← [(String new: 100) asStream
			space; print: val; contents asParagraph];
		selectRange: (s to: s); paste].

	scrollBar show.
	d⇒ [mem◦067 ← d]
]\gb5B97i48I208i31I5i26I
eachtime [
	user kbck⇒ [⇑self kbd]
	frame has: user mp⇒ [
		user anybug⇒ [
			user redbug⇒ [⇑self redbug]
			user yellowbug⇒ [⇑self yellowbug]
			user bluebug⇒ [⇑false]]
		user anykeys⇒ [⇑self keyset]]
	⇑self outside]\gb9B
enter
	[scrollBar show]\gb7B
frame ← frame
	["Change my frame and that of my pared (if any)."
	pared≡nil⇒ [] pared frame ← frame.
	scrollBar on: frame from: pared]\gb15B1i48I
hardcopy: pf [
	"if this is just part of a CodeWindow, then print entire Paragraph with no frame.
	unfortunately, the test for this is a kludge. otherwise, print clipped"

	selectorPane ≡ self⇒ [(PressPrinter init) press: pf; print: pared contents]
	frame hardcopy: pf thickness: 1.
	pared hardcopy: pf]\gb13B
kbd
	[pared typing]\gb5B
keyset
	[⇑pared keyset]\gb8B
leave
	[scrollBar hide]\gb7B
outline
	[frame outline: 1]\gb9B
outside
	[⇑scrollBar startup]\gb9B
picked
	[⇑frame has: user mp]\gb8B
redbug
	[⇑pared selecting]\gb8B
show
	[frame outline. pared show]\gb6B
windowenter
	[self outline. pared enter]\gb13B
windowleave
	[pared≡nil⇒[] pared leave]\gb13B
yellowbug
	[editmenu bug
		=5⇒[self doit];
		=1⇒[scrollBar hidewhile⦂ [pared again]];
		=2⇒[pared copy];
		=3⇒[pared cut];
		=4⇒[pared paste];
		=6⇒[pared formerly⇒
				[scrollBar hidewhile⦂ [selectorPane compile: pared contents⇒ [pared formerly: false]]]
			  frame flash];
		=7⇒[pared undo];
		=8⇒[pared formerly⇒ [
				pared Deletion ← pared contents.
				scrollBar hidewhile⦂ [self showing: pared formerly]] frame flash];
		=9⇒[pared realign]]\gb11B

Browse/Notify protocol\gbf5 
compile: parag	"as my own selectorPane"
	[⇑self compile: parag in: class under: 'As yet unclassified']\gb15Bi24I
compile: parag in: defaultClass under: category
	[⇑Generator new
		compile: parag
		in: [class≡nil⇒ [defaultClass] class]
		under: category
		notifying: self]\gb49B
contents
	[⇑pared contents]\gb10B
dirty
	[pared formerly⇒ [⇑frame] ⇑false]\gb7B
execute: parseStream for: codePane		"as my own selectorPane"
	[⇑self execute: parseStream in: false to: nil]\gb36Bi24I
execute: parseStream in: context to: receiver
	[⇑Generator new evaluate: parseStream in: context to: receiver notifying: self]\gb47B
formerly: oldpara 	"should not be called before 'showing:'"
	[pared formerly: oldpara]\gb19Bi40I
interactive
	[⇑true]\gb13B
notify: errorString at: position in: stream
	[pared
		fintype;
		selectRange: (position to: position);
		replace: ('➲' + errorString + '➲.') asParagraph;
		selectAndScroll.
	⇑false]\gb45B
oldContents
	[⇑pared formerly]\gb13B
reflects: selection  "am I trying to show the code of selectorPaneⓢ selection?"
	[⇑class≡nil and⦂ selection>0]\gb21Bi58I
selectRange: r [pared selectRange: r; selectAndScroll]\gb15B
\g
SystemOrganization classify: ↪CodePane under: 'Panes and Menus'.\g
CodePane classInit\g

"FilePane"l15000z20000\gbf5 
Class new title: 'FilePane'
	subclassof: CodePane
	fields: 'file'
	declare: 'editmenu ';
	asFollows\gbf5 

This class has not yet been commented\gi

As yet unclassified\gbf5 
classInit "FilePane classInit."
	[editmenu ← Menu new string:
		'again
copy
cut
paste
doit
put
undo
get
align']\gb10B21b2B
file: file\gb
yellowbug
	[editmenu bug
		=1⇒[pared again];
		=2⇒[pared copy];
		=3⇒[pared cut];
		=4⇒[pared paste];
		=5⇒[self doit];
		=6⇒[pared formerly⇒ [user displayoffwhile⦂ [
					file readwriteshorten; reset; append: pared contents; close.
					pared formerly: false]]
				frame flash];
		=7⇒[pared undo];
		=8⇒[user displayoffwhile⦂ [scrollBar hidewhile⦂
				[self showing: file contents asParagraph]]];
		=9⇒[pared realign]]\gb11B
\g
SystemOrganization classify: ↪FilePane under: 'Panes and Menus'.\g
FilePane classInit\g

"ListPane"l15000z20000\gbf5 
Class new title: 'ListPane'
	subclassof: Textframe
	fields: 'list firstShown lastShown selection scrollBar'
	declare: '';
	asFollows\gbf5 

A list pane displays a vertical list of one-line items.  The list can be scrolled slow or fast, and any item can be selected.  When an item is selected (or deselected), a dependent pane can be told to display appropriate material.\gi

Initialization\gbf5 
of: list "Acquire the specified list and show me scrolled to the top"
	[firstShown← selection← 0.
	self frame← window.
	self fill; deselected]\gb9B
revise: newlist with: sel  | changing
	["Acquire newlist. Do not change firstShown. Select sel if in list."
	[changing ← list≠newlist⇒
		[list ← newlist.
		firstShown ← firstShown min: (
			list length+2  - (window height-4/self lineheight) max: 0).
		[nil ≠ para⇒ [para ← para asStream]].
		self fill]
	 selection>0⇒ [changing ← list◦selection≠sel⇒ [self compselection]]
	 changing ← true].
	changing⇒ [selection ← ¬1. self select: (list find: sel)]]\gb27B13i67I
select: lineNum | oldSel
	["Select my non-dummy displayed entry whose subscript is lineNum; highlight it; if it is different from selection, tell me to select.  If there is no such entry, set selection to 0 and if it wasnt 0 before, tell me to deselect."
	oldSel ← selection.
	(1 max: firstShown) ≤ lineNum and⦂ lineNum ≤ (list length min: lastShown)⇒
		[selection ← lineNum. self compselection. oldSel≠selection⇒ [self selected]]
	selection ← 0. oldSel≠selection⇒ [self deselected]]\gb16B11i227I

Pane protocol\gbf5 
close "Zero my selection so it wont be grayed when I close.  Break cycles."
	[selection←0. scrollBar close]\gb5i1B69bI2B
eachtime
	[window has: user mp⇒
		[user kbck⇒[⇑self kbd]
		user anybug⇒
			[user redbug⇒[⇑self redbug]
			user yellowbug⇒[⇑self yellowbug]
			user bluebug⇒[⇑false]]
		user anykeys⇒[⇑self keyset]]
	⇑self outside]\gb10B
enter
	[scrollBar show]\gb7B
firsttime
	[window has: user mp⇒[self enter]
	⇑false]\gb11B
frame ← window "(Re)initialize my window"
	[para ← nil.
	scrollBar ← ([scrollBar≡nil⇒ [ScrollBar new] scrollBar]) on: window from: self]\gb15Bi26I
hardcopy: pf | t cr first last lasty lineNum parag left right lineheight [
	window hardcopy: pf thickness: 1.
	[para≡nil⇒ [self makeParagraph]].
	parag ← para asParagraph.

	t ← para asStream.
	last ← 0.
	cr ← 015.
	left ← frame minX.
	right ← window maxX.
	lasty ← frame minY.
	lineheight ← self lineheight.

	for⦂ lineNum from: firstShown to: lastShown do⦂ [
		first ← last.
		[(t skipTo: cr) or⦂ lineNum = lastShown⇒ [last ← t position]
		user notify: 'not enough lines'].

		[lineNum = selection and⦂ selection > 0⇒ [
			"outline selection; complementing doesn't look good"
			(self selectionRect-(0⌾1) inset: 0⌾1) hardcopy: pf thickness: 1]].

		(parag copy: first+1 to: last-1) presson: pf in:
			(pf transrect: (left ⌾ lasty rect: right ⌾ (lasty+lineheight+4))) style: style.
		lasty ← lasty + lineheight.
	]]\gb13B
kbd
	[window flash. user kbd.]\gb5B
keyset | c
	["As long as any keyset keys are down, react to keys 2 and 8 down by scrolling up or down a line at a time.  If key 4 is down as well, scroll faster."
	c ← user currentCursor.
	self scrollControl⦂ [user keyset=6⇒[2]; =12⇒[¬2]; =2⇒[1]; =8⇒[¬1] 0].
	c show]\gb7B6i149I
lasttime
	[self leave]\gb10B
leave
	[scrollBar hide]\gb7B
outline
	[window outline: 1]\gb9B
outside [⇑scrollBar startup]\gb8B
picked
	[⇑window has: user mp]\gb8B
redbug | newSel f		"Deselect selection and select cursor item, if any"
	[[f ← self locked⇒ []
	self compselection.
	newSel ← (user mp y - window origin y)/self lineheight + firstShown.
	XeqCursor showwhile⦂ [self select: [newSel = selection⇒ [0] newSel]]].

	while⦂ (user redbug and⦂ (window has: user mp)) do⦂ [
		f⇒ [f flash. self compselection; compselection]]]\gb7B12i51I
scrollPos
	[firstShown≡nil or⦂ list length=0⇒[⇑0.0]
	⇑firstShown asFloat/list length]\gb11B
scrollTo: f | t
	[self scrollControl⦂
		[t← (f*list length) asInteger - firstShown.
		t<0⇒[firstShown<0⇒[0] t]
		lastShown>list length⇒[0] t]]\gb15B
windowenter "Refresh my image.  Reaffirm selection."
	[self outline; fill; select: selection.]\gb12Bi40I
windowleave
	[self compselection; grayselection]\gb13B
yellowbug
	[window flash]\gb11B

Subclass defaults\gbf5 
deselected "I just lost my selection.  I dont care, but my subclasses might."\gb11Bi
dirty "My subclasses may want to prohibit a change of selection"
	[⇑false]\gb6Bi58I
locked "My subclasses may want to prohibit a change of selection"
	[⇑[selection=0⇒ [false] self dirty]]\gb7Bi58I
selected "A new selection is highlighted.  I dont care, but my subclasses might"\gb9Bi

Private\gbf5 
compselection "If I have a selection, complement its image."
	[selection≠0⇒ [self selectionRect comp]]\gb14Bi46I
dummy
	[⇑'▱▱▱▱▱▱▱']\gb7B
fill [self makeParagraph; show]\gb5B
grayselection
	[selection≠0⇒ [self selectionRect color: ltgray mode: oring]]\gb15B
init
	[self para: nil frame: nil.]\gb6B
makeParagraph | i len s lines "Given firstShown, compute lastShown."
	[
	len ← list length.
	lastShown ← firstShown-1 + (lines ← window height-4/self lineheight)
		min: 1+len.
	[self locked⇒
		[i ← (selection-lastShown max: 0) + (selection-firstShown min: 0).
		i≠0⇒ [para←nil. firstShown ← firstShown + i. lastShown ← lastShown + i]]].

	(frame ← window inset: 2) width ← 999.
	para is: String⇒ ["if para is a String, refresh from it directly"]
	"otherwise compute para."
	s ← [para≡nil⇒ [(String new: 200) asStream] para].
	for⦂ i from: firstShown to: lastShown do⦂ [
		[0<i and⦂ i≤len⇒ [lines ← lines-1. (list◦i) printon: s]
			s append: self dummy].
		s cr].
	for⦂ i to: (lines+1 min: s limit - s position) do⦂ [s cr].
	para ← s asArray]\gb14B16i38I330i45I4i25I
scrollBy⦂ expr copying: src into: dest showing: item in: frame direction: n
		| strm final stop pt delay chars locked t
	[strm ← Stream new. chars ← 2*frame width/self lineheight. para ← String new: chars.
	pt ← dest origin. final ← [n<0⇒ [0] list length+1].
	stop ← [locked←self locked⇒ [0 max: (list length+1 min: (lastShown - firstShown * n sign + selection))] final].
	while⦂ item≠stop do⦂
		[firstShown ← firstShown + n. lastShown ← lastShown + n. item ← item + n.
		strm of: para from: 1 to: chars.
		[item≠final⇒ [(list◦item) printon: strm] self dummy copyto: strm].
		strm cr. src blt: pt mode: storing. self show.
		(t← expr eval) abs ≤1⇒ [for⦂ delay to: chars/4 do⦂ [strm myend]. para ← nil. ⇑self]
			t*n<0⇒[⇑self]].
	para ← nil. locked and: stop≠final⇒ [locked flash. ⇑false]]
\gb78B710b
scrollControl⦂ expr
		| dY onlyFirst butFirst onlyLast butLast x1 x2 y1 y2 y3 y4 k
	["Selection is highlighted.  Unhighlight it.  Invalidate my saved para if I scroll.  Then reselect selection, or deselect if it is no longer displayed."
	self compselection. dY ← self lineheight.
	x1 ← window origin x. x2 ← window corner x.
	y1 ← window origin y+2. y4 ← window height-4 |dY + y1. y2←y1+dY. y3←y4-dY.
	onlyFirst ← x1+2⌾y1 rect: 2000⌾y2. butFirst ← x1⌾y2 rect: x2⌾y4.
	onlyLast ← x1+2⌾y3 rect: 2000⌾y4. butLast ← x1⌾y1 rect: x2⌾y3.
	while⦂ (k←expr eval)≠0 do⦂
		[k>0⇒[UpCursor topage1.
			self scrollBy⦂ expr eval copying: butFirst into: butLast showing: lastShown
				in: onlyLast direction: 1⇒[] ⇑self select: selection]
		DownCursor topage1.
		self scrollBy⦂ expr eval copying: butLast into: butFirst showing: firstShown
				in: onlyFirst direction: ¬1⇒[] ⇑self select: selection].
	self select: selection]\gb22B63i151I
scrollUp: n | c
	[c ← window origin x-20.
	self scrollControl⦂
		[user buttons=4⇒
			[user mp x > c⇒[2] ¬2]
		0]]\gb12B
selectionRect | h w
	["I have a selection.  Return its highlighting rectangle."
	(w ← window inset: 2) height ← h ← self lineheight. 
	⇑w + (0⌾(selection-firstShown *h))]\gb14B8i57I
\g
SystemOrganization classify: ↪ListPane under: 'Panes and Menus'.\g

"ClassPane"l15000z20000\gbf5 
Class new title: 'ClassPane'
	subclassof: ListPane
	fields: 'systemPane organizationPane'
	declare: 'editmenu ';
	asFollows\gbf5 

I am a list pane that displays the names of all the classes of a category\gi

Initialization\gbf5 
classInit
	[editmenu ← Menu new string: 'filout
print
forget']\gb11B
from: systemPane to: organizationPane\gb

Window protocol\gbf5 
close
	[systemPane ← nil. super close]\gb7B
yellowbug
	["If there is a selection, let the user choose a command from the menu."
	selection=0⇒ [window flash]
	editmenu bug
		=1⇒ ["filout" (Smalltalk◦(list◦selection)) filout];
		=2⇒ ["print" (Smalltalk◦(list◦selection)) printout];
		=3⇒ ["forget" systemPane forget: list◦selection]]\gb11B2i69I53i6I48i5I50i6I

ListPane protocol\gbf5 
deselected
	["I just lost my selection.  Tell organizationPane to display nothing."
	organizationPane class: nil.]\gb12B1i70I
selected
	["My selection just changed.  Tell organizationPane to display the categories of my newly selected Class."
	organizationPane class: Smalltalk◦(list◦selection).]\gb10B1i105I

Browser protocol\gbf5 
compile: parag
	[systemPane compile: parag]\gb16B
dirty
	[⇑organizationPane dirty]\gb7B
noCode
	[selection=0⇒ [⇑systemPane noCode] ⇑'']\gb8B
\g
SystemOrganization classify: ↪ClassPane under: 'Panes and Menus'.\g
ClassPane classInit\g

"Menu"l15000z20000\gbf5 
Class new title: 'Menu'
	subclassof: Object
	fields: 'str text thisline frame'
	declare: '';
	asFollows\gbf5 

I am a list of text lines one of which can be selected with the pointing device\gi

Initialization\gbf5 
rescan " | each. Menu allInstances notNil transform⦂ each to⦂ each rescan."
	[self string: str]		"rescan (for new fonts, lineheight)"\gb7Bi68I22i
string: str |  i pt tpara
	[[str last≠13⇒[str←str+'
']].		"make sure str ends with CR"
	text ← Textframe new para: (tpara ← str asParagraph)
				frame:  (Rectangle new origin: (pt ←  0 ⌾ 0)
												corner: 1000 ⌾ 1000).
	pt ← text maxx: str length+1.
	text frame growto: pt + (4 ⌾ 0).
	tpara center.
	frame ← text frame inset: ¬2  ⌾ ¬2.
	thisline ← Rectangle new origin: text frame origin
				corner: text frame corner x ⌾ text lineheight]\gb12B46i28I
stringFromVector: v | s
	["DW classInit"
	s ← Stream default.
	for⦂ v from: v do⦂ [s append: v; cr].
	self string: s contents]\gb20B

User interactions\gbf5 
bug | index bits
	[bits ← self movingsetup.			"set up and save background"
	index ← self bugit.						"get the index"
	frame bitsFromString: bits.		"restore background"
	⇑ index										"return index"
	]
\gb4B42i28I27i15I31i20I19i14I
clear
	[frame clear]\gb7B
fbug | index
	[	"for fixed menus"
	index ← self bugit.						"get the index"
	⇑ index										"return index"
	]
\gb5B11i17I27i15I19i14I
frame
	[⇑ frame]\gb7B
has: pt
	[⇑ text frame has: pt]\gb9B
moveto: pt
	[self clear.
	frame moveto: pt.
	text frame moveto: pt+2.
	thisline moveto: pt+2.
	]\gb12B
rebug
	[user waitbug. 	"wait for button down again"
	⇑"bugcursor showwhile⦂" self bug]\gb7B16i28I3i22I
show
	[frame clear: black. text show.]\gb6B
wbug | index bits [
	"save background, display menu"
	bits ← self movingsetup.

	"wait until a mouse button is down"
	until⦂ user anybug do⦂ [].

	"get selection (possibly 0)"
	index ← self bugit.

	"restore background"
	frame bitsFromString: bits.
	⇑ index
	]
\gb5B
zbug | index bits
	[bits ← self movingsetup.
	while⦂ (index ← self bugit) = 0 do⦂ [].
	frame bitsFromString: bits.
	⇑ index
	]
\gb5B

Internal\gbf5 
bugit | pt bits
	[user nobug ⇒
		[⇑0]										"accidental bug returns 0"
	thisline comp.
	while⦂ true do⦂
		[text frame has: (pt ← user mp) ⇒
			[user anybug⇒
				[thisline has: pt⇒[]
				pt ← text ptofpt: pt.
				thisline comp.			"selection follows mouse"
				thisline moveto: text frame origin x  ⌾ pt y.
				thisline comp]

			⇑1+ (thisline origin y-text frame origin y
					/ text lineheight)		"return index"
			]
		thisline comp. 						"he left the menu"
		until⦂ [text frame has: user mp] do⦂
			[user nobug⇒[⇑0]] 			"return 0 for abort"
		thisline comp]						"he came back"
	]\gb6B41i26I159i25I142i14I29i18I64i20I23i14I
movingsetup | pt bits
	[pt ← user mp - thisline center.	"center prev item on mouse"
	text frame moveby: pt. thisline moveby: pt.
	frame moveby: pt.
	bits ← frame bitsIntoString.	"save background"
	frame clear: black. text show.
	⇑ bits
	]\gb12B44i27I95i17I
\g
SystemOrganization classify: ↪Menu under: 'Panes and Menus'.\g

"OrganizationPane"l15000z20000\gbf5 
Class new title: 'OrganizationPane'
	subclassof: ListPane
	fields: 'classPane selectorPane class'
	declare: 'editmenu ';
	asFollows\gbf5 

I am a list pane that displays the selector categories of a class.\gi

Initialization\gbf5 
class: class
	[self of: (self listFor: class)]\gb14B
classInit
	[editmenu ← Menu new string: 'filout
print']\gb11B
from: classPane to: selectorPane\gb
listFor: class
	[⇑[class≡nil⇒ [Vector new: 0]
		↪(ClassDefinition ClassOrganization) concat: class organization categories]]\gb16B

Window protocol\gbf5 
close
	[classPane ← nil. super close]\gb7B
yellowbug
	["If there is a selection, let the user choose a command from the menu."
	selection≤1⇒ [window flash]		"Can't filout or print definition by itself"
	editmenu bug
		=1⇒ ["filout the selected category"
			selection=2⇒ [class filoutOrganization]
			class filoutCategory: list◦selection];
		=2⇒ ["print the selected category"
			selection=2⇒ [window flash]		"Can't print organization"
			class printoutCategory: list◦selection]
	]\gb11B

ListPane protocol\gbf5 
deselected
	["I just lost my selection.  Tell selectorPane to display nothing."
	selectorPane of: (Vector new: 0)]\gb12B1i66I
selected
	[selectorPane of: [selection≤2⇒ [Vector new: 0] class organization category: list◦selection]]\gb10B

Browser protocol\gbf5 
code: selector
	[⇑class code: selector]\gb16B
compile: parag
		| sel cat
	[class≡nil or⦂ selection=1⇒ [classPane compile: parag] "new definition"
	selection=2⇒ [class organization fromParagraph: parag. self class: class] "new organization"
	cat ← [selection=0⇒ ['As yet unclassified'] list◦selection].
	sel ← selectorPane compile: parag in: class under: cat⇒
		[self revise: (self listFor: class) with: cat.
		selection≠0⇒ [selectorPane revise: (class organization category: cat) with: sel]]
	⇑false]\gb17B66i16I76i18I
dirty
	[⇑selectorPane dirty]\gb7B
execute: parag
	[⇑classⓢ parag]\gb16B
forget: selector | cat
	[class derstands: selector.
	cat ← list◦selection.
	self revise: (self listFor: class) with: cat.
	selection>0⇒
		[selectorPane revise: (class organization category: cat) with: selector]]\gb17B
noCode
	[class≡nil⇒ [⇑classPane noCode]
	selection=0⇒ [⇑'']; =1⇒ [⇑class definition]; =2⇒ [⇑class organization]
	⇑'Message name and Arguments | Temporary variables "short comment"
	["long comment if necessary"
	Smalltalk
	Statements]']\gb8B
spawn: selector with: parag formerly: oldparag
	[selectorPane compselection; select: 0.
	class edit: selector para: parag formerly: oldparag]\gb48B
\g
SystemOrganization classify: ↪OrganizationPane under: 'Panes and Menus'.\g
OrganizationPane classInit\g

"ScrollBar"l15000z20000\gbf5 
Class new title: 'ScrollBar'
	subclassof: Object
	fields: 'rect bitstr owner position'
	declare: 'DownCursor UpCursor JumpCursor ';
	asFollows\gbf5 

I am a bar to the left of an awake window.  With the cursor in me I can make that window scroll.\gi

Initialization\gbf5 
classInit
	[UpCursor ← Cursor new fromtext: '
1000000000000000
1100000000000000
1110000000000000
1111000000000000
1111100000000000
1111110000000000
1100000000000000
1100000000000000
1100000000000000
1100000000000000
1100000000000000
1100000000000000
1100000000000000
1100000000000000
1100000000000000
1100000000000000'.
	DownCursor ← Cursor new fromtext: '
1100000000000000
1100000000000000
1100000000000000
1100000000000000
1100000000000000
1100000000000000
1100000000000000
1100000000000000
1100000000000000
1100000000000000
1111110000000000
1111100000000000
1111000000000000
1110000000000000
1100000000000000
1000000000000000'.
	JumpCursor ← Cursor new fromtext: '
0111000000000000
1111100000000000
1111100000000000
0111000000000000
0000000000000000
0000000000000000
0000000000000000
0000000000000000
0000000000000000
0000000000000000
0000000000000000
0000000000000000
0000000000000000
0000000000000000
0000000000000000
0000000000000000' offset: 2⌾1]\gb11B
on: f from: o
	[self on: f from: o at: o scrollPos]\gb15B
on: frame from: owner at: f
	[rect ← Rectangle new
		origin: frame origin-(32⌾2)
		extent: 32⌾(frame height+4).
	position ← Rectangle new
		origin: rect origin+(9⌾4)
		extent: 16⌾8.
	self boxPosition← f]\gb29B

Scheduling\gbf5 
close
	[owner←nil]\gb7B
eachtime | p cx r		"This needs to be restructured"
	[rect has: (p← user mp)⇒
		[cx ← rect center x - 2.
		p x < cx⇒
			[r ← Rectangle new origin: rect origin corner: cx⌾rect maxY.
			DownCursor showwhile⦂
					[while⦂ (r has: (p←user mp)) do⦂
						[self slide: p⇒[owner scrollTo: (position minY-rect minY-4) asFloat/(rect height-12)]
						user redbug⇒[self reposition⦂[owner scrollUp: rect origin y - p y]]]]]
		r ← Rectangle new origin: cx⌾rect minY corner: rect corner.
		UpCursor showwhile⦂
				[while⦂ (r has: (p←user mp)) do⦂
					[self slide: p⇒[owner scrollTo: (position minY-rect minY-4) asFloat/(rect height-12)]
					user redbug⇒[self reposition⦂[owner scrollUp: p y - rect origin y]]]]]
	⇑false]\gb9B11i29I
firsttime	
	[⇑rect has: user mp]\gb12B
lasttime\gb
slide: p | bug
	[position has: p⇒
		[JumpCursor showwhile⦂
			[bug ← false.
			while⦂ ((position has: user mp) and⦂ bug≡false) do⦂
				[user redbug⇒
					[bug ← true.
					while⦂ user redbug do⦂
						[self reshow⦂
							[position moveto: position origin x⌾
								((user mp y max: rect origin y+4) min: rect corner y-12)]]]]].
		⇑bug]
	⇑false]\gb9B

Image\gbf5 
boxPosition← f
	[position moveto: rect origin+
			(9⌾(4+(([f<0.0⇒[0.0]; >1.0⇒[1.0] f])*(rect height-16))))]\gb16B
hide 	"restore background"
	[bitstr≡nil⇒ [user notify: 'Attempt to hide unshown scrollbar']
	rect bitsFromString: bitstr.
	bitstr ← nil]\gb6B1i18I
hidewhile⦂ expr  | v
	[self hide. v ← expr eval. self show. ⇑v]\gb17B
reposition⦂ expr
	[self reshow⦂
		[expr eval.  self boxPosition← owner scrollPos]]\gb18B
reshow⦂ expr | r
	[r ← position inset: ¬2.  expr eval.
	r clear: white.  position outline]\gb13B
show	"Save background and turn gray"
	[bitstr ← rect bitsIntoString.
	rect clear: black.
	(rect inset: 2⌾2 and: 1⌾2) clear: white.
	position outline]\gb5B1i29I
\g
SystemOrganization classify: ↪ScrollBar under: 'Panes and Menus'.\g
ScrollBar classInit\g

"SelectorPane"l15000z20000\gbf5 
Class new title: 'SelectorPane'
	subclassof: ListPane
	fields: 'organizationPane codePane'
	declare: 'editmenu ';
	asFollows\gbf5 

I am a ListPane whose entries are the message selectors of a category within a class.  Only organizationPane knows what the class and category are.  I make codePane display the code of my selected selector, if any.\gi

Initialization\gbf5 
classInit
	[editmenu ← Menu new string:
		'spawn
forget']\gb11B
from: organizationPane to: codePane\gb

Window protocol\gbf5 
close
	[organizationPane ← nil. super close]\gb7B
yellowbug
	[selection=0⇒ [window flash]
	scrollBar hidewhile⦂
		[editmenu bug
			=1⇒ [organizationPane spawn: list◦selection with: codePane contents
					formerly: codePane oldContents];
			=2⇒ [organizationPane forget: list◦selection]]]\gb11B

ListPane protocol\gbf5 
deselected
	[codePane showing: organizationPane noCode]\gb12B
selected
	[codePane showing: (organizationPane code: list◦selection)]\gb10B

Browser protocol\gbf5 
compile: parag
	[⇑organizationPane compile: parag]\gb16B
compile: parag in: class under: heading
	[⇑codePane compile: parag in: class under: heading]\gb41B
dirty
	[⇑codePane dirty]\gb7B
execute: parseStream for: codePane
	[⇑codePane execute: parseStream in: false to: nil]\gb36B
\g
SystemOrganization classify: ↪SelectorPane under: 'Panes and Menus'.\g
SelectorPane classInit\g

"StackPane"l15000z20000\gbf5 
Class new title: 'StackPane'
	subclassof: ListPane
	fields: 'contextVarPane instanceVarPane codePane variables proceed'
	declare: 'stackmenu ';
	asFollows\gbf5 

I am a list pane that displays one or all of the stack below a context in a notify window.\gi

Initialization\gbf5 
classInit
	[stackmenu ← Menu new string:
		'stack
spawn
proceed
restart']\gb11B
context: contextVarPane at: level instance: instanceVarPane code: codePane
	[variables ← (Vector new: 16) asStream.
	 proceed≡nil⇒[proceed ← (false, nil, level)]]\gb76B
context: contextVarPane instance: instanceVarPane code: codePane
	[variables ← (Vector new: 16) asStream.
	 proceed≡nil⇒[proceed ← (false, nil, Top currentPriority)]]\gb66B
interrupt: flag
	[proceed◦1 ← flag]\gb17B

Window protocol\gbf5 
close
	[Top enable: proceed◦3. super close. list⇒ [(list◦1) releaseFully]]\gb7B
yellowbug
	[scrollBar hidewhile⦂
		[stackmenu bug
			=1⇒ ["show a full backtrace"
					 self revise: (list◦1) stack with: [selection=0⇒ [nil] list◦selection]];
			=2⇒ ["spawn a code editor" self spawn];
			=3⇒ ["return to selected context" self continue: false];
			=4⇒ ["restart selected context" self continue: true]]]\gb11B47i23I87i21I22i28I32i26I

ListPane protocol\gbf5 
deselected
	[contextVarPane ≡ false⇒ []
	codePane showing: ''.
	contextVarPane names: (Vector new: 0) values: ↪(nil) wrt: false.
	instanceVarPane names: (Vector new: 0) values: ↪(nil) wrt: false]\gb12B
locked
	[⇑contextVarPane and⦂ (selection>0 and⦂ self dirty)]\gb8B
selected | context instance code safeVec
	[contextVarPane ≡ false⇒ []
	context ← list◦selection. instance ← context receiver.
	Decompiler new findPC: context pc.
	code ← self code.
	codePane showing: [code⇒ [code] ''].
	codePane selectRange: Decompiler new highlight.
	variables reset. context variableNamesInto: self with: nil.
	[code⇒
		[contextVarPane names: (↪(thisContext) concat: variables contents)
				values: (context, context tempframe) wrt: context.
		 context tempframe≡nil⇒ [user notify: 'NIL TEMPFRAME']]
	 contextVarPane names: ↪(thisContext) values: context inVector wrt: context].
	variables reset. instance class fieldNamesInto: self.
	safeVec ← Vector new: 2. safeVec all ← instance.
	instanceVarPane names: (↪(self) concat: variables contents) values: safeVec wrt: context.
	contextVarPane select: 1]\gb9B

NotifyWindow protocol\gbf5 
compile: parseStream | ctxt selector method mcl
	[ctxt ← list◦(selection max: 1). mcl ← ctxt mclass.
	 proceed◦2 ← selector ←
			codePane compile: parseStream in: mcl under: 'As yet unclassified'⇒
	 	[codePane reflects: selection⇒
			[method ← mcl md methodorfalse: selector⇒
				[self releaseAboveSelection.
			 	ctxt restartWith: method. proceed◦1 ← true.
			 	self of: list◦(selection to: list length) copy; select: 1]]]]\gb21B
dirty
	[⇑codePane and⦂ codePane dirty]\gb7B
execute: parseStream for: codePane
	[⇑proceed◦2 ←
		codePane execute: parseStream in: [selection=0⇒ [false] list◦selection] to: nil]\gb36B

Private\gbf5 
code | mclass selector 		"code of my selected context"
	[mclass ← (list ◦ selection) mclass.
	selector ← self selector.
	⇑(mclass canunderstand: selector) and⦂ (mclass code: selector)]\gb5B20i29I
comment: s		"called by selected via Class fieldNamesInto"\gb12Bi
contents	"called by selected via Class fieldNamesInto"\gb9Bi
continue: restarting | ctxt
	["Close my window and resume my selected context, if any, else my first context.  If interrupted (proceed◦1) or restarting or a recompiled method, don't return a value; otherwise, return proceed◦2."
	[user leftShiftKey ⇒[mem◦067 ← 58 "turn display off"]].
	[selection=0⇒ [selection←1]].
	ctxt ← list◦selection.
	self releaseAboveSelection.	"release abandoned contexts"
	[restarting⇒ [ctxt restart]
	 proceed◦1 and: selection=1⇒ ["resume after interrupt"]
	 ctxt push: proceed◦2].
	list ← false. "Inhibit me closing." user topWindow vanish.
	list ← nil.
	[proceed◦3=1⇒[thisContext sender release]].
	Top run: ctxt at: proceed◦3.
	Top enable: proceed◦3.
	Top wakeup: proceed◦3.
	Top resetCurrent]\gb21B9i199I140i28I61i24I42i21I
declaration: dummy1 name: string asArg: dummy2
	[variables next ← string]\gb48B
identifier: s		"called by selected via Class fieldNamesInto"
	[variables next ← s]\gb15Bi45I
notify: msg "selected context doesnt know its variables"\gb12Bi
releaseAboveSelection
	[[selection>1⇒ [(list◦(selection-1)) sender ← nil. (list◦1) release"Fully"]].
	(list◦(selection max: 1)) verifyFrames]\gb23B67i7I
selector | context
	[context ← list◦(selection max: 1).
	⇑[context sender≡nil⇒ [false] context selector]]\gb9B
separator: c	"called by selected via Class fieldNamesInto"\gb13Bi
spawn | mclass selector parag oldparag
	[mclass ← (list◦(selection max: 1)) mclass.
	selector ← self selector.
	parag ← [codePane⇒ [codePane contents] mclass canunderstand: selector⇒ [mclass code: selector] ''].
	oldparag ← [codePane⇒ [codePane oldContents] false].
	self compselection; select: 0.
	mclass edit: selector para: parag formerly: oldparag]\gb6B
terminate "called by parser close during initialization"\gb10Bi
trailer: s	"called by selected via Class fieldNamesInto"\gb11Bi
\g
SystemOrganization classify: ↪StackPane under: 'Panes and Menus'.\g
StackPane classInit\g

"SystemPane"l15000z20000\gbf5 
Class new title: 'SystemPane'
	subclassof: ListPane
	fields: 'mySysOrgVersion classPane'
	declare: 'sysmenu ';
	asFollows\gbf5 

I am a list pane in which all the system categories are displayed.\gi

Initialization\gbf5 
classInit
	[sysmenu ← Menu new string: 'filout
print']\gb11B
to: classPane\gb
update
	[self of: (↪(AllClasses SystemOrganization) concat: SystemOrganization categories). mySysOrgVersion←user classNames]\gb8B

Window protocol\gbf5 
enter	 "be sure I am up to date"
	[mySysOrgVersion≡user classNames⇒ [super enter]
	window outline. self update. super enter]\gb7Bi25I
leave	 "I am up to date"
	[mySysOrgVersion ← user classNames. super leave]\gb7Bi17I
yellowbug
	[selection<3⇒[window flash]
	scrollBar hidewhile⦂
		[sysmenu bug
			=1⇒
				[SystemOrganization filoutCategory: list◦selection];
			=2⇒
				[SystemOrganization printCategory: list◦selection]
		]
	]\gb11B

ListPane protocol\gbf5 
deselected
	[classPane of: (Vector new: 0)]\gb12B
selected
	[classPane of: self classes]\gb10B

Browser protocol\gbf5 
classes "return a Vector of the classes in my selected category"
	[selection	=1⇒ [⇑user classNames];
				≤2⇒ [⇑Vector new: 0]
	⇑SystemOrganization category: list◦selection]\gb8Bi56I
compile: parag
		| class cat className
	[selection=2⇒ [SystemOrganization fromParagraph: parag. self update] "new organization"
	cat ← [selection≤1⇒ [false] list◦selection].
	class ← nilⓢparag.
	class Is: Class⇒
		[className ← class title unique.
		[cat⇒ [SystemOrganization classify: className under: cat]].
		mySysOrgVersion≡user classNames⇒
			[selection>0⇒
				[classPane of: [cat⇒ [SystemOrganization category: cat] user classNames]]]
		self update]]\gb17B92i18I
dirty
	[⇑classPane dirty]\gb7B
forget: className
	[user notify: 'Class '+className+' will disappear if you proceed...'.
	(Smalltalk◦className) noChanges; obsolete. Smalltalk delete: className.
	SystemOrganization delete: className.
	AllClassNames ← AllClassNames delete: className.
	classPane revise: self classes with: className]\gb19B
noCode
	[selection=0⇒ [⇑'']; =2⇒ [⇑SystemOrganization]
	⇑'Class new title: ''NameOfClass''
	subclassof: Object
	fields: ''names of fields''
	declare: ''names of class variables''' copy]\gb8B
\g
SystemOrganization classify: ↪SystemPane under: 'Panes and Menus'.\g
SystemPane classInit\g

"VariablePane"l15000z20000\gbf5 
Class new title: 'VariablePane'
	subclassof: ListPane
	fields: 'valuePane values context'
	declare: 'varmenu ';
	asFollows\gbf5 

I am a list pane that displays the names of variables in a context or instance.\gi

Initialization\gbf5 
classInit
	[varmenu ← Menu new string: 'inspect']\gb11B
names: vars values: values wrt: context
	[self of: vars]\gb41B
to: valuePane
	[]\gb15B

Window protocol\gbf5 
yellowbug
	[selection=0⇒ [window flash]
	scrollBar hidewhile⦂ [varmenu bug =1⇒ [self value inspect]]]\gb11B

ListPane protocol\gbf5 
deselected
	[valuePane showing: '']\gb12B
selected
	[valuePane showing: self value asString]\gb10B

Notify/Inspect protocol\gbf5 
compile: parag
	[window flash. ⇑false]\gb16B
execute: parseStream for: valuePane
	[⇑valuePane execute: parseStream in: context to: values◦1]\gb37B

Private\gbf5 
value
	[selection=1⇒ [⇑values◦1] ⇑(values◦2) inspectfield: selection-1]\gb7B
\g
SystemOrganization classify: ↪VariablePane under: 'Panes and Menus'.\g
VariablePane classInit\g
