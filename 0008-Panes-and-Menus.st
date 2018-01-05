'From Smalltalk 5.5k XM November 24 on 22 November 1980 at 2:57:08 am.'

"CodePane" 
Class new title: 'CodePane'
	subclassof: Window
	fields: 'pared class selector selectorPane scrollBar'
	declare: 'editmenu ';
	asFollows 

I am a Window for editing a paragraph which may include Smalltalk source code.  My selectorPane (not necessarily of class SelectorPane, and possibly even myself) compiles and doits for me.

Initialization 
class: class selector: selector para: para
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
align']
from: selectorPane
init
showing: paragraph
	[pared ← ParagraphEditor new para: paragraph asParagraph frame: nil.
	pared formerly: false; fixframe: frame.
	self windowenter.
	scrollBar ← ([scrollBar≡nil⇒ [ScrollBar new] scrollBar]) on: frame from: pared]

Window protocol 
close
	[pared unselect. selectorPane ← pared ← nil. scrollBar close]
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
]
eachtime [
	user kbck⇒ [⇑self kbd]
	frame has: user mp⇒ [
		user anybug⇒ [
			user redbug⇒ [⇑self redbug]
			user yellowbug⇒ [⇑self yellowbug]
			user bluebug⇒ [⇑false]]
		user anykeys⇒ [⇑self keyset]]
	⇑self outside]
enter
	[scrollBar show]
frame ← frame
	["Change my frame and that of my pared (if any)."
	pared≡nil⇒ [] pared frame ← frame.
	scrollBar on: frame from: pared]
hardcopy: pf [
	"if this is just part of a CodeWindow, then print entire Paragraph with no frame.
	unfortunately, the test for this is a kludge. otherwise, print clipped"

	selectorPane ≡ self⇒ [(PressPrinter init) press: pf; print: pared contents]
	frame hardcopy: pf thickness: 1.
	pared hardcopy: pf]
kbd
	[pared typing]
keyset
	[⇑pared keyset]
leave
	[scrollBar hide]
outline
	[frame outline: 1]
outside
	[⇑scrollBar startup]
picked
	[⇑frame has: user mp]
redbug
	[⇑pared selecting]
show
	[frame outline. pared show]
windowenter
	[self outline. pared enter]
windowleave
	[pared≡nil⇒[] pared leave]
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
		=9⇒[pared realign]]

Browse/Notify protocol 
compile: parag	"as my own selectorPane"
	[⇑self compile: parag in: class under: 'As yet unclassified']
compile: parag in: defaultClass under: category
	[⇑Generator new
		compile: parag
		in: [class≡nil⇒ [defaultClass] class]
		under: category
		notifying: self]
contents
	[⇑pared contents]
dirty
	[pared formerly⇒ [⇑frame] ⇑false]
execute: parseStream for: codePane		"as my own selectorPane"
	[⇑self execute: parseStream in: false to: nil]
execute: parseStream in: context to: receiver
	[⇑Generator new evaluate: parseStream in: context to: receiver notifying: self]
formerly: oldpara 	"should not be called before 'showing:'"
	[pared formerly: oldpara]
interactive
	[⇑true]
notify: errorString at: position in: stream
	[pared
		fintype;
		selectRange: (position to: position);
		replace: ('➲' + errorString + '➲.') asParagraph;
		selectAndScroll.
	⇑false]
oldContents
	[⇑pared formerly]
reflects: selection  "am I trying to show the code of selectorPaneⓢ selection?"
	[⇑class≡nil and⦂ selection>0]
selectRange: r [pared selectRange: r; selectAndScroll]

SystemOrganization classify: ↪CodePane under: 'Panes and Menus'.
CodePane classInit

"FilePane" 
Class new title: 'FilePane'
	subclassof: CodePane
	fields: 'file'
	declare: 'editmenu ';
	asFollows 

This class has not yet been commented

As yet unclassified 
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
align']
file: file
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
		=9⇒[pared realign]]

SystemOrganization classify: ↪FilePane under: 'Panes and Menus'.
FilePane classInit

"ListPane" 
Class new title: 'ListPane'
	subclassof: Textframe
	fields: 'list firstShown lastShown selection scrollBar'
	declare: '';
	asFollows 

A list pane displays a vertical list of one-line items.  The list can be scrolled slow or fast, and any item can be selected.  When an item is selected (or deselected), a dependent pane can be told to display appropriate material.

Initialization 
of: list "Acquire the specified list and show me scrolled to the top"
	[firstShown← selection← 0.
	self frame← window.
	self fill; deselected]
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
	changing⇒ [selection ← ¬1. self select: (list find: sel)]]
select: lineNum | oldSel
	["Select my non-dummy displayed entry whose subscript is lineNum; highlight it; if it is different from selection, tell me to select.  If there is no such entry, set selection to 0 and if it wasnt 0 before, tell me to deselect."
	oldSel ← selection.
	(1 max: firstShown) ≤ lineNum and⦂ lineNum ≤ (list length min: lastShown)⇒
		[selection ← lineNum. self compselection. oldSel≠selection⇒ [self selected]]
	selection ← 0. oldSel≠selection⇒ [self deselected]]

Pane protocol 
close "Zero my selection so it wont be grayed when I close.  Break cycles."
	[selection←0. scrollBar close]
eachtime
	[window has: user mp⇒
		[user kbck⇒[⇑self kbd]
		user anybug⇒
			[user redbug⇒[⇑self redbug]
			user yellowbug⇒[⇑self yellowbug]
			user bluebug⇒[⇑false]]
		user anykeys⇒[⇑self keyset]]
	⇑self outside]
enter
	[scrollBar show]
firsttime
	[window has: user mp⇒[self enter]
	⇑false]
frame ← window "(Re)initialize my window"
	[para ← nil.
	scrollBar ← ([scrollBar≡nil⇒ [ScrollBar new] scrollBar]) on: window from: self]
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
	]]
kbd
	[window flash. user kbd.]
keyset | c
	["As long as any keyset keys are down, react to keys 2 and 8 down by scrolling up or down a line at a time.  If key 4 is down as well, scroll faster."
	c ← user currentCursor.
	self scrollControl⦂ [user keyset=6⇒[2]; =12⇒[¬2]; =2⇒[1]; =8⇒[¬1] 0].
	c show]
lasttime
	[self leave]
leave
	[scrollBar hide]
outline
	[window outline: 1]
outside [⇑scrollBar startup]
picked
	[⇑window has: user mp]
redbug | newSel f		"Deselect selection and select cursor item, if any"
	[[f ← self locked⇒ []
	self compselection.
	newSel ← (user mp y - window origin y)/self lineheight + firstShown.
	XeqCursor showwhile⦂ [self select: [newSel = selection⇒ [0] newSel]]].

	while⦂ (user redbug and⦂ (window has: user mp)) do⦂ [
		f⇒ [f flash. self compselection; compselection]]]
scrollPos
	[firstShown≡nil or⦂ list length=0⇒[⇑0.0]
	⇑firstShown asFloat/list length]
scrollTo: f | t
	[self scrollControl⦂
		[t← (f*list length) asInteger - firstShown.
		t<0⇒[firstShown<0⇒[0] t]
		lastShown>list length⇒[0] t]]
windowenter "Refresh my image.  Reaffirm selection."
	[self outline; fill; select: selection.]
windowleave
	[self compselection; grayselection]
yellowbug
	[window flash]

Subclass defaults 
deselected "I just lost my selection.  I dont care, but my subclasses might."
dirty "My subclasses may want to prohibit a change of selection"
	[⇑false]
locked "My subclasses may want to prohibit a change of selection"
	[⇑[selection=0⇒ [false] self dirty]]
selected "A new selection is highlighted.  I dont care, but my subclasses might"

Private 
compselection "If I have a selection, complement its image."
	[selection≠0⇒ [self selectionRect comp]]
dummy
	[⇑'▱▱▱▱▱▱▱']
fill [self makeParagraph; show]
grayselection
	[selection≠0⇒ [self selectionRect color: ltgray mode: oring]]
init
	[self para: nil frame: nil.]
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
	para ← s asArray]
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
	self select: selection]
scrollUp: n | c
	[c ← window origin x-20.
	self scrollControl⦂
		[user buttons=4⇒
			[user mp x > c⇒[2] ¬2]
		0]]
selectionRect | h w
	["I have a selection.  Return its highlighting rectangle."
	(w ← window inset: 2) height ← h ← self lineheight. 
	⇑w + (0⌾(selection-firstShown *h))]

SystemOrganization classify: ↪ListPane under: 'Panes and Menus'.

"ClassPane" 
Class new title: 'ClassPane'
	subclassof: ListPane
	fields: 'systemPane organizationPane'
	declare: 'editmenu ';
	asFollows 

I am a list pane that displays the names of all the classes of a category

Initialization 
classInit
	[editmenu ← Menu new string: 'filout
print
forget']
from: systemPane to: organizationPane

Window protocol 
close
	[systemPane ← nil. super close]
yellowbug
	["If there is a selection, let the user choose a command from the menu."
	selection=0⇒ [window flash]
	editmenu bug
		=1⇒ ["filout" (Smalltalk◦(list◦selection)) filout];
		=2⇒ ["print" (Smalltalk◦(list◦selection)) printout];
		=3⇒ ["forget" systemPane forget: list◦selection]]

ListPane protocol 
deselected
	["I just lost my selection.  Tell organizationPane to display nothing."
	organizationPane class: nil.]
selected
	["My selection just changed.  Tell organizationPane to display the categories of my newly selected Class."
	organizationPane class: Smalltalk◦(list◦selection).]

Browser protocol 
compile: parag
	[systemPane compile: parag]
dirty
	[⇑organizationPane dirty]
noCode
	[selection=0⇒ [⇑systemPane noCode] ⇑'']

SystemOrganization classify: ↪ClassPane under: 'Panes and Menus'.
ClassPane classInit

"Menu" 
Class new title: 'Menu'
	subclassof: Object
	fields: 'str text thisline frame'
	declare: '';
	asFollows 

I am a list of text lines one of which can be selected with the pointing device

Initialization 
rescan " | each. Menu allInstances notNil transform⦂ each to⦂ each rescan."
	[self string: str]		"rescan (for new fonts, lineheight)"
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
				corner: text frame corner x ⌾ text lineheight]
stringFromVector: v | s
	["DW classInit"
	s ← Stream default.
	for⦂ v from: v do⦂ [s append: v; cr].
	self string: s contents]

User interactions 
bug | index bits
	[bits ← self movingsetup.			"set up and save background"
	index ← self bugit.						"get the index"
	frame bitsFromString: bits.		"restore background"
	⇑ index										"return index"
	]

clear
	[frame clear]
fbug | index
	[	"for fixed menus"
	index ← self bugit.						"get the index"
	⇑ index										"return index"
	]

frame
	[⇑ frame]
has: pt
	[⇑ text frame has: pt]
moveto: pt
	[self clear.
	frame moveto: pt.
	text frame moveto: pt+2.
	thisline moveto: pt+2.
	]
rebug
	[user waitbug. 	"wait for button down again"
	⇑"bugcursor showwhile⦂" self bug]
show
	[frame clear: black. text show.]
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

zbug | index bits
	[bits ← self movingsetup.
	while⦂ (index ← self bugit) = 0 do⦂ [].
	frame bitsFromString: bits.
	⇑ index
	]


Internal 
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
	]
movingsetup | pt bits
	[pt ← user mp - thisline center.	"center prev item on mouse"
	text frame moveby: pt. thisline moveby: pt.
	frame moveby: pt.
	bits ← frame bitsIntoString.	"save background"
	frame clear: black. text show.
	⇑ bits
	]

SystemOrganization classify: ↪Menu under: 'Panes and Menus'.

"OrganizationPane" 
Class new title: 'OrganizationPane'
	subclassof: ListPane
	fields: 'classPane selectorPane class'
	declare: 'editmenu ';
	asFollows 

I am a list pane that displays the selector categories of a class.

Initialization 
class: class
	[self of: (self listFor: class)]
classInit
	[editmenu ← Menu new string: 'filout
print']
from: classPane to: selectorPane
listFor: class
	[⇑[class≡nil⇒ [Vector new: 0]
		↪(ClassDefinition ClassOrganization) concat: class organization categories]]

Window protocol 
close
	[classPane ← nil. super close]
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
	]

ListPane protocol 
deselected
	["I just lost my selection.  Tell selectorPane to display nothing."
	selectorPane of: (Vector new: 0)]
selected
	[selectorPane of: [selection≤2⇒ [Vector new: 0] class organization category: list◦selection]]

Browser protocol 
code: selector
	[⇑class code: selector]
compile: parag
		| sel cat
	[class≡nil or⦂ selection=1⇒ [classPane compile: parag] "new definition"
	selection=2⇒ [class organization fromParagraph: parag. self class: class] "new organization"
	cat ← [selection=0⇒ ['As yet unclassified'] list◦selection].
	sel ← selectorPane compile: parag in: class under: cat⇒
		[self revise: (self listFor: class) with: cat.
		selection≠0⇒ [selectorPane revise: (class organization category: cat) with: sel]]
	⇑false]
dirty
	[⇑selectorPane dirty]
execute: parag
	[⇑classⓢ parag]
forget: selector | cat
	[class derstands: selector.
	cat ← list◦selection.
	self revise: (self listFor: class) with: cat.
	selection>0⇒
		[selectorPane revise: (class organization category: cat) with: selector]]
noCode
	[class≡nil⇒ [⇑classPane noCode]
	selection=0⇒ [⇑'']; =1⇒ [⇑class definition]; =2⇒ [⇑class organization]
	⇑'Message name and Arguments | Temporary variables "short comment"
	["long comment if necessary"
	Smalltalk
	Statements]']
spawn: selector with: parag formerly: oldparag
	[selectorPane compselection; select: 0.
	class edit: selector para: parag formerly: oldparag]

SystemOrganization classify: ↪OrganizationPane under: 'Panes and Menus'.
OrganizationPane classInit

"ScrollBar" 
Class new title: 'ScrollBar'
	subclassof: Object
	fields: 'rect bitstr owner position'
	declare: 'DownCursor UpCursor JumpCursor ';
	asFollows 

I am a bar to the left of an awake window.  With the cursor in me I can make that window scroll.

Initialization 
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
0000000000000000' offset: 2⌾1]
on: f from: o
	[self on: f from: o at: o scrollPos]
on: frame from: owner at: f
	[rect ← Rectangle new
		origin: frame origin-(32⌾2)
		extent: 32⌾(frame height+4).
	position ← Rectangle new
		origin: rect origin+(9⌾4)
		extent: 16⌾8.
	self boxPosition← f]

Scheduling 
close
	[owner←nil]
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
	⇑false]
firsttime	
	[⇑rect has: user mp]
lasttime
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
	⇑false]

Image 
boxPosition← f
	[position moveto: rect origin+
			(9⌾(4+(([f<0.0⇒[0.0]; >1.0⇒[1.0] f])*(rect height-16))))]
hide 	"restore background"
	[bitstr≡nil⇒ [user notify: 'Attempt to hide unshown scrollbar']
	rect bitsFromString: bitstr.
	bitstr ← nil]
hidewhile⦂ expr  | v
	[self hide. v ← expr eval. self show. ⇑v]
reposition⦂ expr
	[self reshow⦂
		[expr eval.  self boxPosition← owner scrollPos]]
reshow⦂ expr | r
	[r ← position inset: ¬2.  expr eval.
	r clear: white.  position outline]
show	"Save background and turn gray"
	[bitstr ← rect bitsIntoString.
	rect clear: black.
	(rect inset: 2⌾2 and: 1⌾2) clear: white.
	position outline]

SystemOrganization classify: ↪ScrollBar under: 'Panes and Menus'.
ScrollBar classInit

"SelectorPane" 
Class new title: 'SelectorPane'
	subclassof: ListPane
	fields: 'organizationPane codePane'
	declare: 'editmenu ';
	asFollows 

I am a ListPane whose entries are the message selectors of a category within a class.  Only organizationPane knows what the class and category are.  I make codePane display the code of my selected selector, if any.

Initialization 
classInit
	[editmenu ← Menu new string:
		'spawn
forget']
from: organizationPane to: codePane

Window protocol 
close
	[organizationPane ← nil. super close]
yellowbug
	[selection=0⇒ [window flash]
	scrollBar hidewhile⦂
		[editmenu bug
			=1⇒ [organizationPane spawn: list◦selection with: codePane contents
					formerly: codePane oldContents];
			=2⇒ [organizationPane forget: list◦selection]]]

ListPane protocol 
deselected
	[codePane showing: organizationPane noCode]
selected
	[codePane showing: (organizationPane code: list◦selection)]

Browser protocol 
compile: parag
	[⇑organizationPane compile: parag]
compile: parag in: class under: heading
	[⇑codePane compile: parag in: class under: heading]
dirty
	[⇑codePane dirty]
execute: parseStream for: codePane
	[⇑codePane execute: parseStream in: false to: nil]

SystemOrganization classify: ↪SelectorPane under: 'Panes and Menus'.
SelectorPane classInit

"StackPane" 
Class new title: 'StackPane'
	subclassof: ListPane
	fields: 'contextVarPane instanceVarPane codePane variables proceed'
	declare: 'stackmenu ';
	asFollows 

I am a list pane that displays one or all of the stack below a context in a notify window.

Initialization 
classInit
	[stackmenu ← Menu new string:
		'stack
spawn
proceed
restart']
context: contextVarPane at: level instance: instanceVarPane code: codePane
	[variables ← (Vector new: 16) asStream.
	 proceed≡nil⇒[proceed ← (false, nil, level)]]
context: contextVarPane instance: instanceVarPane code: codePane
	[variables ← (Vector new: 16) asStream.
	 proceed≡nil⇒[proceed ← (false, nil, Top currentPriority)]]
interrupt: flag
	[proceed◦1 ← flag]

Window protocol 
close
	[Top enable: proceed◦3. super close. list⇒ [(list◦1) releaseFully]]
yellowbug
	[scrollBar hidewhile⦂
		[stackmenu bug
			=1⇒ ["show a full backtrace"
					 self revise: (list◦1) stack with: [selection=0⇒ [nil] list◦selection]];
			=2⇒ ["spawn a code editor" self spawn];
			=3⇒ ["return to selected context" self continue: false];
			=4⇒ ["restart selected context" self continue: true]]]

ListPane protocol 
deselected
	[contextVarPane ≡ false⇒ []
	codePane showing: ''.
	contextVarPane names: (Vector new: 0) values: ↪(nil) wrt: false.
	instanceVarPane names: (Vector new: 0) values: ↪(nil) wrt: false]
locked
	[⇑contextVarPane and⦂ (selection>0 and⦂ self dirty)]
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
	contextVarPane select: 1]

NotifyWindow protocol 
compile: parseStream | ctxt selector method mcl
	[ctxt ← list◦(selection max: 1). mcl ← ctxt mclass.
	 proceed◦2 ← selector ←
			codePane compile: parseStream in: mcl under: 'As yet unclassified'⇒
	 	[codePane reflects: selection⇒
			[method ← mcl md methodorfalse: selector⇒
				[self releaseAboveSelection.
			 	ctxt restartWith: method. proceed◦1 ← true.
			 	self of: list◦(selection to: list length) copy; select: 1]]]]
dirty
	[⇑codePane and⦂ codePane dirty]
execute: parseStream for: codePane
	[⇑proceed◦2 ←
		codePane execute: parseStream in: [selection=0⇒ [false] list◦selection] to: nil]

Private 
code | mclass selector 		"code of my selected context"
	[mclass ← (list ◦ selection) mclass.
	selector ← self selector.
	⇑(mclass canunderstand: selector) and⦂ (mclass code: selector)]
comment: s		"called by selected via Class fieldNamesInto"
contents	"called by selected via Class fieldNamesInto"
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
	Top resetCurrent]
declaration: dummy1 name: string asArg: dummy2
	[variables next ← string]
identifier: s		"called by selected via Class fieldNamesInto"
	[variables next ← s]
notify: msg "selected context doesnt know its variables"
releaseAboveSelection
	[[selection>1⇒ [(list◦(selection-1)) sender ← nil. (list◦1) release"Fully"]].
	(list◦(selection max: 1)) verifyFrames]
selector | context
	[context ← list◦(selection max: 1).
	⇑[context sender≡nil⇒ [false] context selector]]
separator: c	"called by selected via Class fieldNamesInto"
spawn | mclass selector parag oldparag
	[mclass ← (list◦(selection max: 1)) mclass.
	selector ← self selector.
	parag ← [codePane⇒ [codePane contents] mclass canunderstand: selector⇒ [mclass code: selector] ''].
	oldparag ← [codePane⇒ [codePane oldContents] false].
	self compselection; select: 0.
	mclass edit: selector para: parag formerly: oldparag]
terminate "called by parser close during initialization"
trailer: s	"called by selected via Class fieldNamesInto"

SystemOrganization classify: ↪StackPane under: 'Panes and Menus'.
StackPane classInit

"SystemPane" 
Class new title: 'SystemPane'
	subclassof: ListPane
	fields: 'mySysOrgVersion classPane'
	declare: 'sysmenu ';
	asFollows 

I am a list pane in which all the system categories are displayed.

Initialization 
classInit
	[sysmenu ← Menu new string: 'filout
print']
to: classPane
update
	[self of: (↪(AllClasses SystemOrganization) concat: SystemOrganization categories). mySysOrgVersion←user classNames]

Window protocol 
enter	 "be sure I am up to date"
	[mySysOrgVersion≡user classNames⇒ [super enter]
	window outline. self update. super enter]
leave	 "I am up to date"
	[mySysOrgVersion ← user classNames. super leave]
yellowbug
	[selection<3⇒[window flash]
	scrollBar hidewhile⦂
		[sysmenu bug
			=1⇒
				[SystemOrganization filoutCategory: list◦selection];
			=2⇒
				[SystemOrganization printCategory: list◦selection]
		]
	]

ListPane protocol 
deselected
	[classPane of: (Vector new: 0)]
selected
	[classPane of: self classes]

Browser protocol 
classes "return a Vector of the classes in my selected category"
	[selection	=1⇒ [⇑user classNames];
				≤2⇒ [⇑Vector new: 0]
	⇑SystemOrganization category: list◦selection]
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
		self update]]
dirty
	[⇑classPane dirty]
forget: className
	[user notify: 'Class '+className+' will disappear if you proceed...'.
	(Smalltalk◦className) noChanges; obsolete. Smalltalk delete: className.
	SystemOrganization delete: className.
	AllClassNames ← AllClassNames delete: className.
	classPane revise: self classes with: className]
noCode
	[selection=0⇒ [⇑'']; =2⇒ [⇑SystemOrganization]
	⇑'Class new title: ''NameOfClass''
	subclassof: Object
	fields: ''names of fields''
	declare: ''names of class variables''' copy]

SystemOrganization classify: ↪SystemPane under: 'Panes and Menus'.
SystemPane classInit

"VariablePane" 
Class new title: 'VariablePane'
	subclassof: ListPane
	fields: 'valuePane values context'
	declare: 'varmenu ';
	asFollows 

I am a list pane that displays the names of variables in a context or instance.

Initialization 
classInit
	[varmenu ← Menu new string: 'inspect']
names: vars values: values wrt: context
	[self of: vars]
to: valuePane
	[]

Window protocol 
yellowbug
	[selection=0⇒ [window flash]
	scrollBar hidewhile⦂ [varmenu bug =1⇒ [self value inspect]]]

ListPane protocol 
deselected
	[valuePane showing: '']
selected
	[valuePane showing: self value asString]

Notify/Inspect protocol 
compile: parag
	[window flash. ⇑false]
execute: parseStream for: valuePane
	[⇑valuePane execute: parseStream in: context to: values◦1]

Private 
value
	[selection=1⇒ [⇑values◦1] ⇑(values◦2) inspectfield: selection-1]

SystemOrganization classify: ↪VariablePane under: 'Panes and Menus'.
VariablePane classInit
