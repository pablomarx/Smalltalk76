'From Smalltalk 5.5k XM November 24 on 22 November 1980 at 2:57:08 am.'
\g
"BitRect"l15000z20000\gbf5 
Class new title: 'BitRect'
	subclassof: Rectangle
	fields: 'title  "<String> title of picture"
		stripheight  "<Integer> scan lines in a buffer (private)"
		data  "<Vector> of Strings.  Saves the bits in the Rectangle"'
	declare: 'defaultpic ';
	asFollows\gbf5 

BitRect is a Rectangle that remembers the bits within it.
To create and edit one, say:
		BitRect new fromuser edit.
This installs a BitRectEditor in the scheduler and starts it up.
The editor is explained in BitRectEditor.\gi

Initialization\gbf5 
classInit
	["the default picture is a gray rectangle"
	defaultpic _ BitRect new filin: 'defaultpic']\gb11B2i39I
default [defaultpic recopy]\gb8B
fromuser
	[self title: 'BitRect' in: Rectangle new fromuser.
	self saveScreenBits]\gb10B
origin: origin corner: corner title: title stripheight: stripheight data: data\gb
title: title in: rect | nStrips i strips
	[origin_rect origin.  corner_rect corner.
	"the strip height is chosen so that each bitstring is about 2048 bytes"
	stripheight_1023/((self extent x + 15)/16).
	nStrips_(self extent y+stripheight-1)/stripheight.
	data_Vector new: nStrips.
	strips_self strips.
	for i to: nStrips do
		[datai_String new: (stripsi) bitStringLength]]\gb22B64i69I

Access to parts\gbf5 
data [data]\gb5B
title [title]\gb6B

Rectangle Protocol\gbf5 
= x [selfx]\gb4B
bitsOntoStream: strm | bits
	[for bits from: data do [strm append: bits]]\gb21B
corner_x [self growby: x-corner]\gb9B
extent_x [self growby: x-self extent]\gb9B
growby: change | old
	[old_BitRect new origin: origin corner: corner title: title
		stripheight: stripheight data: data.
	self title: title in: (origin rect: corner+change).
	self copyBitsFrom: old]\gb15B
growto: x [self growby: x-corner]\gb10B
hash [user croak] primitive: 46\gb5B
height_h [self growby: 0(h-self extent y)]\gb9B
printon: strm
	[strm append: 'a BitRect']\gb15B
width_w [self growby: (w-self extent x)0]\gb8B

Editing\gbf5 
copyBitsFrom: other
		| clippedStrip i j myStrips otherStrips myStrip otherStrip
	["copy all bits from other that are within my area"
	myStrips_self strips.  otherStrips_other strips.
	for i to: myStrips length do
		[for j to: otherStrips length do
			[myStrip_myStripsi.  otherStrip_otherStripsj.
			clippedStrip_myStrip intersect: otherStrip.
			clippedStrip empty[]
			BitBlt init function_0;
				destbase_datai;
				destraster_myStrip width+15/16;
				dest_clippedStrip origin-myStrip origin;
				extent_clippedStrip extent;
				sourcebase_other dataj;
				sourceraster_otherStrip width+15/16;
				source_clippedStrip origin-otherStrip origin;
				checksandcall]]]\gb22B62i19u5U24I
edit | a
	[user leaveTop.
	a_BitRectEditor new picture: self.
	a takeCursor; enter.
	user restartup: a]\gb5B

Showing\gbf5 
saveScreenBits | strips i
	[strips_self strips.
	for i to: strips length do
		[stripsi bitsIntoString: datai mode: storing clippedBy: nil]]\gb15B
show | strips i
	[strips_self strips.
	for i to: strips length do
		[stripsi bitsFromString: datai]]\gb5B
strips   "return a vector of strips (Rectangles)"
		| nStrips strips stripOrigin stripExtent i
	[(nStrips_data length)=1[self inVector]
	strips_Vector new: nStrips.
	stripOrigin_origin.  stripExtent_self widthstripheight.
	for i to: nStrips-1 do
		[stripsi_Rectangle new origin: stripOrigin extent: stripExtent.
		stripOrigin_stripOrigin+(0stripheight)].
	stripsnStrips_Rectangle new origin: stripOrigin corner: corner.
	strips]\gb9B1i38I

Filin and filout\gbf5 
filin: title | f i x y rect strips  "read bits from a file"
	[f_dp0 oldFile: (title concat: '.pic.').
	f readonly.
	f end[f close. user notify: 'no data']

	x_f nextword.  y_f nextword.
	rect_Rectangle new origin: [origin is: Point[origin] 00] extent: xy.
	self title: title in: rect.
	stripheightf nextword[user notify: 'strip heights dont match']
	strips _ self strips.
	for i to: strips length do
		[f into: datai].
	f close]\gb13B23i23I
filout | f i  "write bits on a file"
	[f _ dp0 file: (title concat: '.pic.').
	f nextword _ self extent x.
	f nextword _ self extent y.
	f nextword _ stripheight.
	for i from: data do [f append: i].
	f close]\gb7B8i20I

Press\gbf5 
length [self bitStringLength]\gb7B
presson: press in: r | w h hs scale w16 y [
	scale _ press scale.
	h _ self height.
	(hs  _ scale*h) > r height [
		"not enough room left on current page.
		assume for now that it will at least fit on an entire page"
		self]

	w _ self width.
	w16 _ w + 15 | 16 "width to next word boundary".
	"with w, prints on viola but not on spruce.
	with w16, prints on spruce with garbage on end"
	press setp: 0(y _ r corner y - hs);
		dots [
			press setcoding: 1 "bitmap" dots: w16 lines: h;
				setmode: 3 "to right and to bottom";
				setsizewidth: scale*w16 height: hs;
				setwindowwidth: w16 height: h;
				dotsfollow.
			self bitsOntoStream: press data].
	y]\gb21B
\g
SystemOrganization classify: BitRect under: 'Picture Editor'.\g
BitRect classInit\g

"BitRectEditor"l15000z20000\gbf5 
Class new title: 'BitRectEditor'
	subclassof: Window
	fields: 'tool  "<BitRectTool> the current tool"
		picture  "<BitRect> the picture we are working on"
		dirty  "false if picture has not been modified"
		saveActionPic saveToolPic  "buffers for saving background" '
	declare: 'tools toolpic actionbuttons actionpic windowmenu ';
	asFollows\gbf5 

BitRectEditor edits BitRects.
To create, say:
	BitRect new fromuser edit.
This installs a BitRectEditor in the scheduler and starts it up.
The editing tools are to the left of the picture.  (The first one looks like a doodle).  They are: draw-thin, erase, straightedge, gray-block, paintbrush, magnifier.  The actions for the tools are displayed above the picture.
See BitRectTool for explanations of the actions.

CAUTION: this ordering is arbitrary.  It is currently possible to set a new action for any of the tools, so that if you are not careful, the straightedge will start being a magnifier or whatever.  This should get fixed eventually.

tools = a RadioButtons. Each button owns a BitRectTool (the active one is held in tool).
actionbuttons = a Vector of RadioButtons.  The groups of buttons are: action, mode, pen width, gray, and grid.
toolpic = BitRect of icons for the tools (at side of picture).
actionpic = BitRect of icons for the parts of a tool (above picture)
windowmenu = menu for bluebug.

To edit a copy of the tool picture, say
	newpic_(BitRectEditortoolpic) recopy.
	newpic edit.
To install this copy as the menu picture, say
	BitRectEditor new toolpic: newpic recopy.
Do the analogous thing to edit the action picture.
Caution: the editor blows up if you edit the tool picture itself and not a copy.
\gi

Initialization\gbf5 
actionpic: a [actionpic _ a]\gb13B
classInit | t i
	[t _ Vector new: 6.
	for i to: t length do [ti _ BitRectTool new init].
	tools _ (RadioButtons new) vec: t at: 00 width: 20.
	windowmenu _ Menu new string: 'under
move
grow
close
filout
printbits'.
	actionpic_BitRect new filin: 'actionpic'.
	toolpic_BitRect new filin: 'toolpic'.
	self initmenu1]\gb10B
initmenu1 | s z
	[s _ Vector new: 5. z _ 20.
	s1 _ (RadioButtons new) vec: (setbrush paint block draw line blowup) at: 00 height: z. "action"
	s2 _ (RadioButtons new) vec: (black, dkgray, gray, ltgray, white) at: 00 height: z. "tone"
	s3 _ (RadioButtons new) vec: (0, 1, 2, 3) at: 00 height: z. "mode"
	s4 _ (RadioButtons new) vec: (1, 2, 4, 8) at: 00 height: z. "width"
	s5 _ (RadioButtons new) vec: (1, 2, 4, 8, 16, 32) at: 00 height: z. "grid"
	actionbuttons _ s.]\gb10B127i6I90i4I66i4I66i5I74i4I
picture: picture
	[tool _ tools push: 1.
	self frame: (picture origin rect: picture corner)]\gb18B
toolpic: a [toolpic _ a]\gb11B

Window protocol\gbf5 
bluebug | 
	[
	picture is: BitImage [  picture fromrectangle: (picture rectangle)]
	windowmenu bug
	 =1 [self leave. exitflag _ false];  "under"
	=2 [self leave; newframe; enter];  "move"
	=3 [self grow  "grow"];
	=4 [self leave; erase.   "close"
		 user unschedule: self. false];
	=5 [self leave. picture filout. self enter];  "filout"
	=6 [self print]	"press file"]\gb8B134i5I40i4I20i4I32i5I86i6I21i10I
enter | start pt b
	["Periodically check if the mouse is still in the frame.
		If not, stop showing the picture"
	super show.  self lostMouse[false]
	picture show.  dirty_false.  self lostMouse[false]
	for b from: actionbuttons do [b reset].
	"show action menu above the picture"
	start_frame origin-1.
	pt _ start-(0actionpic extent y).
	actionpic moveto: pt.
	saveActionPic_actionpic bitsIntoString.
	self lostMouse[false]
	"last point I can return before having to restore bits under menus"
	actionpic show.
	pt _ actionbuttons1 moveto: pt. "action"
	pt _ actionbuttons3 moveto: pt. "mode"
	pt _ actionbuttons4 moveto: pt. "width"
	"show the next bank of action buttons"
	pt _ start-(0(actionpic extent y+1/2)).
	pt _ actionbuttons2 moveto: pt.  "tone"
	pt _ actionbuttons5 moveto: pt.  "grid"
	tool brushpt: (pt _ pt+(77)).
	(tool brush) moveto: pt; show.
	"show the tool pic"
	pt _ start-(toolpic extent x0).
	toolpic moveto: pt.
	saveToolPic _ toolpic bitsIntoString.
	toolpic show.
	tools moveto: pt;  setvalue: tool.
	tool frame: frame; showon: actionbuttons.]\gb6B16i89I139i34I152i65I54i6I37i4I37i5I4i36I80i4I38i4I
fixframe: r
	[picture moveto: r origin.
	r corner_picture corner.
	r]\gb13B
grow | oldframe newframe pt r
	[self leave.
	newframe_picture origin rect: picture corner.
	CornerCursor showwhile
		[pt_user mp+16.
		while user nobug do
			[newframe corner_pt.  newframe comp.
			pt_user mp+16.  newframe comp].
		while user anybug do
			[newframe corner_pt.  newframe comp.
			pt_user mp+16.  newframe comp]].
	"clear unused areas from old picture to background,
		and clear new picture areas to white"
	oldframe_picture inset: 22.  "2 is for erasing old border"
	for r from: (oldframe minus: newframe) do [r clear: background].
	for r from: (newframe minus: picture) do [r clear: white].
	picture title: picture title in: newframe; saveScreenBits.
	self frame: newframe; show; takeCursor; enter]\gb5B331i89I36i28I
leave
	[[nilsaveActionPic[]
	 actionpic bitsFromString: saveActionPic.
	 saveActionPic _ nil.].
	 [nil saveToolPic[]
	 toolpic bitsFromString: saveToolPic.
	 saveToolPic_nil].
	[dirty[picture saveScreenBits. dirty _ false]].
	frame border: 3 color: white]\gb7B
lostMouse [(frame has: user mp)false]\gb10B
outside | pt
	[toolpic has: (pt_user mp)
		[user redbug
			[tool_tools bug: pt. tool frame: frame; showon: actionbuttons]]
	actionpic has: pt
		[user redbug
			[tool setfrom: actionbuttons]]
	false]\gb8B
redbug [dirty_true.  tool redbug]\gb7B
showtitle   "The BitRectEditor have a menu where the title used to be"\gb12Bi
title [picture title]\gb6B
tool [ tool]\gb5B
yellowbug
	[picture is: BitImage [ picture yellowbug] 
	]\gb11B
\g
SystemOrganization classify: BitRectEditor under: 'Picture Editor'.\g
BitRectEditor classInit\g

"BitRectTool"l15000z20000\gbf5 
Class new title: 'BitRectTool'
	subclassof: Object
	fields: 'action "<UniqueString> the current action"
		pencil  "<Turtle> used for draw or straight-edge"
		brush  "<BitRect> source for painting"
		mode  "<Integer> how brush combines with the destination"
		tone  "<Integer> a spatial half-tone color (4 bits by 4 bits)"
		grid  "<Integer> all mouse points are rounded to this"'
	declare: 'blowupScale graypens brushpt ';
	asFollows\gbf5 

A BitRectTool paints on the screen.
A tool is a combination of action, mode, pen-width, gray, and grid.
	action is one of: make-brush, paint, block-of-gray, draw, straight-edge, magnify.
	mode is one of: store, or, xor, and.  (how tool is combined with picture)
	pen-width is 1, 2, 4, or 8.  (width of the pen)
	gray is one of: black, darkgray, gray, lightgray, white.
	grid is one of: 1, 2, 4, 8, 16, 32.   (minimum spacing of mouse points)
Menus for each part of a tool appear above the picture (in the same order).
Some actions do not use certain of the other parts of a tool.
(example: Block-of-gray does not use pen-width.)

brushpt = Point in the menu where brush is shown.
graypens = Vector of Strings of bits in pens.\gi

Tool action\gbf5 
block [self getRectangle color: tone mode: mode]\gb6B
blowup | smallRect bigRectFrame
	[smallRect_self getRectangle.
	bigRectFrame _ Rectangle new origin: smallRect corner
		extent: 44 + (smallRect  extent*blowupScale).
	smallRect empty or bigRectFrame bitStringLength>4000
		[pencil frame flash.  nil].
	[user screenrect has: bigRectFrame corner[] 
		bigRectFrame moveto: smallRect origin-bigRectFrame extent.
		user screenrect has: bigRectFrame origin[]
		"can't find a space for blown up image"	
		pencil frame flash.  nil].
	self blowup: smallRect to: bigRectFrame]\gb7B404i37I
blowup: smallRect to: bigRectFrame
		| bigRect box pt i turt flag bits
	[bits _ bigRectFrame bitsIntoString.
	bigRect _ bigRectFrame inset: 22.
	smallRect blowup: bigRect origin by: blowupScale.
	turt_Turtle init.
	box _ 00 rect: (blowupScale-1)(blowupScale-1).
	"keep editing in blowup mode until the user presses a button
		outside the big rect"
	while flag do
		[bigRect has: (pt _ user mp)
			[box moveto: bigRect origin + (i _ pt-bigRect origin|blowupScale).
			turt place: smallRect origin + (i/blowupScale).
			user redbug[box color: black mode: storing. 
				turt black; go: 0]
			user yellowbug[box color: white mode: storing. 
				turt white; go: 0]
			user bluebug[bigRect flash]]		
		user anybug 
			[(bigRect inset: 55) has: pt[bigRect flash]
			"quit" flag_false]].
	bigRectFrame bitsFromString: bits]\gb37B230i82I425i4I
brush [brush]\gb6B
brush: sourceRect   "use the bits in the BitRect sourceRect as a brush"
		| minpt maxpt pt offset
	["The inner painting loop should be fast - all the extra foliage below
		is to move tests outside of the inner loop"
	sourceRect moveto: brushpt; show.
	minpt_self frame origin.
	maxpt_self frame corner-sourceRect extent.
	offset_sourceRect extent/2.
	"If mode is storing or oring, use brush command, otherwise blt.
		Use the unclipped form of brushing  and grid=1 when possible"
	[mode<xoring and grid=1
		[while user redbug do
			[minpt(pt_user mp-offset) and ptmaxpt
				[sourceRect brush: pt mode: mode color: tone]
			sourceRect brush: pt mode: mode color: tone clippedBy: self frame]]
	 modexoring and grid=1
		[while user redbug do
			[minpt(pt_user mp-offset) and ptmaxpt
				[sourceRect blt: pt mode: mode]
			sourceRect blt: pt mode: mode clippedBy: self frame]]
	 mode<xoring   "grid is > 1"
		[while user redbug do
			[minpt(pt_self mpOnGrid-offset) and ptmaxpt
				[sourceRect brush: pt mode: mode color: tone]
			sourceRect brush: pt mode: mode color: tone clippedBy: self frame]]
	 "grid is > 1 and modexoring"
		while user redbug do
			[minpt(pt_self mpOnGrid-offset) and ptmaxpt
				[sourceRect blt: pt mode: mode]
			sourceRect blt: pt mode: mode clippedBy: self frame]].
	]\gb20B1i28u10U11I31i113I138i62I3i60I430i11I203i27I
draw
	[tone=white or tone=black
		[pencil place: self mpOnGrid-pencil frame origin.
		grid=1		"make drawing with grid 1 fast"
			[while user redbug do
				[pencil goto: user mp-pencil frame origin]]
		while user redbug do
			[pencil goto: self mpOnGrid-pencil frame origin]]
	self brush: graypenspencil width]\gb6B92i29I
getRectangle | rect newrect start t   "rect must be in my frame"
	["the rect-newrect stuff is so that the complementing stays
		on for a while"
	start_self mpOnGrid.
	rect_newrect_(Rectangle new origin: start corner: start)
		intersect: self frame.
	"move the cursor slightly so that the user will notice the rectangle
		being complemented"
	user cursorloc_start+4.
	while user anybug do
		[rect_newrect.
		rect comp.
		t_self mpOnGrid.
		newrect_(Rectangle new origin: (start min: t) corner: (start max: t))
			intersect: self frame.
		rect comp].
	rect]\gb13B25i26I4i74I109i88I
line | start end width
	[start_end_self mpOnGrid-pencil frame origin.
	width_pencil width.  pencil xor; width: 1.
	while user redbug do
		[end_self mpOnGrid-pencil frame origin.
		pencil xor; place: start; goto: end; place: start; goto: end].
	[tone=white[pencil white] pencil black].
	pencil width: width; place: start; goto: end]\gb5B17b2B
mode
	[ mode]\gb6B
mpOnGrid   "return mouse point rounded to grid"
	[user mp+(grid/2) | grid]\gb11Bi31u4U1I
paint
	[self brush: brush]\gb7B
redbug [self perform: action]\gb7B
setbrush | rect
	[rect_self getRectangle.
	rect empty or 5050<rect extent[pencil frame flash].
	brush color: white mode: storing.
	brush title: 'brush' in: rect; saveScreenBits.
	brush moveto: brushpt; show.
	action _ paint]\gb9B
shade | p1 p2 a b t p r vs "down on redbug is black place.
	up on redbug is white place.  Subsequent redbugs
	paint a shade of gray depending on position between
	black and white (and beyond white to black again).
	Yellow or blue bug terminates."
	[until user redbug do [p1 _ user mp]. "black"
	until user nobug do [p2 _ user mp]. "white"

	vs _ ( 1  1025  1089  585  4681  6731  22058  27031   26986  31191  32108   5160  5128  8321  1025 01 0).
	r _ 00 rect: 1010.
	b_(p1-p2). b _ b x asFloat  b y asFloat.
	a _ b x * b x + (b y * b y) /16.0.
	until (user yellowbug or user bluebug) do
	[user redbug [p_user mp.
		t _ b* (p-p2).
		t _ (t x + t y /a) asInteger abs min: 16.
		brush brush: p mode: mode color: vs(17-t)]
	]
	]
\gb6B
tone
	[ tone]\gb6B

Tool selection\gbf5 
brushpt: pt  "set the point at which the current brush will be shown"
	[brushpt_pt]\gb13B1i54I
frame [pencil frame]\gb6B
frame: f [pencil frame: f]\gb9B
setfrom: butvec | pt
	[butvec1 has: (pt _ user mp) 
		[action _ butvec1 bug: pt]
	butvec2 has: pt [tone _ butvec2 bug: pt.
		tone=white [pencil white] pencil black]
	butvec3 has: pt [mode _ butvec3 bug: pt]
	butvec4 has: pt [pencil width: (butvec4 bug: pt)]
	butvec5 has: pt [grid _ butvec5 bug: pt]
	]\gb16B
showon: butvec
	[butvec1 setvalue: action.
	butvec2 setvalue: tone.
	butvec3 setvalue: mode.
	butvec4 setvalue: pencil width.
	butvec5 setvalue: grid]\gb16B

Class initialization\gbf5 
classInit | rect saveBits t i
	[blowupScale_4.
	"make a vector of gray pens"
	rect _ 00 rect: 99.
	saveBits_rect bitsIntoString.
	t _ Turtle init.
	graypens _ Vector new: 8.
	for i to: 8 do
		[t width: i.
		rect clear: white. 
		t place: 44; go: 0. 
		graypensi _ BitRect new title: 'graypen' in: rect.
		(graypensi) saveScreenBits].
	rect bitsFromString: saveBits]\gb10B38i28I
init
	[(pencil _ Turtle new) init; black; width: 2.
	(brush _ BitRect new) title: 'brush' in: (00 rect: 1616).
	tone _ black. mode _ 0. grid _ 1. action _ draw]\gb6B
\g
SystemOrganization classify: BitRectTool under: 'Picture Editor'.\g
BitRectTool classInit\g

"RadioButtons"l15000z20000\gbf5 
Class new title: 'RadioButtons'
	subclassof: Object
	fields: 'vec  "<Vector> values corresponding to the buttons"
		cur  "<Integer> button currently selected"
		rect  "<Rectangle> contains all the buttons"
		size  "<Integer> width or height of a button"'
	declare: '';
	asFollows\gbf5 

A RadioButtons is a row or column of square regions ("buttons") on the display screen.  There is always exactly one button pushed.  (RadioButtons is a model of the station selection buttons on a car radio.)  The pushed button has a black box around it.  Each button has a value associated with it, which is returned when the button is pressed.  RadioButtons will not destroy a menu picture (BitRect) displayed in its area, but the RadioButtons has no knowledge of the picture.
\gi

Pushing a Button\gbf5 
bug: pt | r a
	[r _ (pt - rect origin - (11)) / size.
	a _ r x + r y + 1.
	self push: a]\gb8B
push: a
	[self release: cur thenPush: a.
	vec(cur _ a)]\gb9B
setvalue: v | i
	["if value has been lost, set self to 1"
	i_(vec find: v) max: 1.
	self push: i.  i]\gb12B6i39I

Init and State\gbf5 
has: pt [rect has: pt]\gb8B
moveto: pt
	[rect moveto: pt.
	cur _ 0.
	rect corner x  rect origin y]\gb12B
reset [cur_0]\gb6B
value [veccur]\gb6B
vec [vec]\gb4B
vec: vec at: r height: size
	[rect _ r rect: r+ ((vec length  1)*size).
	cur _ 0]\gb29B
vec: vec at: r width: size
	[rect _ r rect: r+ ((1  vec length)*size).
	cur _ 0]\gb28B

Private\gbf5 
release: a thenPush: b | boxer offset
	[a=b[]
	offset _ [size=rect extent y[size0] 0size].
	[a0[boxer _ Rectangle new origin: (offset*(a-1)+rect origin+1)
				extent: sizesize-1.  boxer comp.  (boxer inset: 11) comp]].
	b0[boxer _ Rectangle new origin: (offset*(b-1)+rect origin+1)
				extent: sizesize-1.  boxer comp.  (boxer inset: 11) comp]]\gb23B
\g
SystemOrganization classify: RadioButtons under: 'Picture Editor'.\g
