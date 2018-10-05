'From Smalltalk 5.5k XM November 24 on 4 October 1990 at 11:39:12 pm.'

"AttributeMenu" 
Class new title: 'AttributeMenu'
	subclassof: Menu
	fields: 'viewee title extract assign viewer showing underbits'
	declare: '';
	asFollows 

AttributeMenus are Menus augmented with:
	underbits	the bits of what I cover
	viewee		the object whose attributes I show
	showing	back-to-front list of indices of visible attriburte viewers
The following fields are Vectors of equal length:
	title			a String of text for each menu line
	extract		how to get the attribute from the viewee (selector or code)
					(can use attributeViewee, attributeValue, attributeMenu)
	assign		how to put a new value in the attribute (selector or code)
					(can use attributeViewee, attributeValue, attributeMenu)
	viewer		a viewer for showing and editing the attributes value
					(may be an Attribute- or UnitViewer or another AttributeMenu)
I access the following globals:
	Smalltalk declare: ↪attributeMenu as: nil.
	Smalltalk declare: ↪attributeViewee as: nil.
	Smalltalk declare: ↪attributeText as: nil. "AttributeViewer uses"
	Smalltalk declare: ↪attributeValue as: nil.
	Smalltalk declare: ↪attributeOldValue as: nil.
See example for sample definition

Init 
assign⦂ a [assign←assign, a]
assign: a [assign←assign, [ a≡nil ⇒ [] a unique ] ]
assign←assign
attribute: viewee [self viewee: viewee]
copy | i t [
	t←self class init.
	t title←title; extract←extract; assign←assign.
	for⦂ i to: viewer length do⦂ [t viewer: (viewer◦i) copy].
	⇑t ]
extract⦂ e [extract←extract, e]
extract: e [extract←extract, [ e≡nil ⇒ [] e unique ]]
extract←extract
init [
	title←Vector new: 0.
	extract←Vector new: 0.
	assign←Vector new: 0.
	viewer←Vector new: 0.
	showing←Set default.
	self reset. ]
title: t [
	[ title≡nil ⇒ [self init] ].
	title←title, t.
	self stringFromVector: title.
	text para flushright. ]
title←title [self stringFromVector: title. text para flushright.]
viewee: viewee | i v [
	for⦂ i from: showing do⦂ [
		(viewer◦i) attribute: (self extractI: i) ] ]
viewer: v [ viewer←viewer, v. v≡nil or⦂ v ismenu ⇒ [] showing add: viewer length ]
viewer←viewer

Parts 
assign [⇑assign]
attribute [⇑viewee]
extract [⇑extract]
index [⇑1+(thisline origin y-text frame origin y / text lineheight)]
ismenu "I'm not a leaf"
showing [⇑showing]
text [⇑text]
thisline [⇑thisline]
title [⇑title]
viewee [⇑viewee]
viewer [⇑viewer]

Show 
at: pt | i [
	self moveto: pt; reset.
	for⦂ i from: showing do⦂ [
		(viewer◦i) attribute: (self extractI: i); at: (self atI: i) ] ]
atI: i [⇑frame rightside ⌾ ((i-1)*text lineheight+text frame top)]
covering: i | j k v  [ "viewer◦i should be showing"
	j←showing find: i.
	j=0 ⇒ [⇑false] "I'm not showing"
	v←viewer◦i.
	for⦂ k from: j+1 to: showing length do⦂ [
		v intersects: viewer◦(showing◦k) ⇒
			[⇑k "index in showing of deepest viewer intersecting over v"] ]
	⇑false ]
intersects: a | i [
	a intersects: frame ⇒ [⇑true]
	for⦂ i from: showing do⦂ [
		viewer◦i intersects: a ⇒ [⇑true] ].
	⇑false ]
moveto: pt | move [ "Move the menu to the new location"
	move←pt-text frame origin.
	frame moveby: move.
	text frame moveby: move.
	thisline moveby: move ]
reset | i "recursive thru showing tree" [
	underbits←false.
	for⦂ i from: showing do⦂ [(viewer◦i) reset]. ]
resetbits [underbits←false]
reshow [self reset viewee: viewee; show] "redisplay on changed screen"
restorebits [underbits⇒[frame bitsFromString: underbits] ]
savebits [underbits←frame bitsIntoString]
show | i "must at: first" [
	[ underbits ⇒ [] self savebits ].
	super show.
	for⦂ i from: showing do⦂ [(viewer◦i) show]. ]
show: viewee at: pt [self viewee: viewee; at: pt; show]
showat: pt [self at: pt; show]
showI: i | j k [ "show viewer◦i at top of showing"
	showing has: i ⇒ [
		(j←self covering: i) ⇒ [ "showing index of first cover"
			for⦂ k from: showing length to: j by: ¬1 do⦂ [
				(viewer◦(showing◦k)) unshow ].
			(viewer◦i) unshow.
			for⦂ k from: j to: showing length do⦂ [
				(viewer◦(showing◦k)) show ].
			showing delete: i; add: i.
			(viewer◦i) show. ] ]
	showing add: i. "new show"
	(viewer◦i) show: (self extractI: i) at: (self atI: i). ]
unshow | i [
	for⦂ i from: showing length to: 1 by: ¬1 do⦂ [
		(viewer◦(showing◦i)) unshow].
	self restorebits resetbits. ]
unshowI: i | j k [
	showing has: i ⇒ [
		[ (j←self covering: i) ⇒ [] j←showing length+1 ].
		for⦂ k from: showing length to: j by: ¬1 do⦂ [ (viewer◦(showing◦k)) unshow ].
		(viewer◦i) unshow.
		for⦂ k from: j to: showing length do⦂ [ (viewer◦(showing◦k)) show ].
		showing delete: i. ] ]

visible: i [ showing has: i ⇒ [self covering: i ⇒ [⇑false] ⇑true ] ⇑false ]

Bug/Edit 
assignI: i | e "Value of attribute i" [
	e←assign◦i.
	e is: UniqueString⇒[viewee perform: e with: (viewer◦i) attribute]
	e≡nil⇒[]
	attributeValue←(viewer◦i) attribute.
	attributeOldValue←self extractI: i.
	attributeViewee←viewee.
	attributeMenu←self.
	e "sender←thisContext; can kill smalltalk" eval. "remote code" ]
bug | r pt left i [
	user nobug⇒[⇑false]
	[ (r←text frame) has: user mp ⇒ [thisline comp. left←r leftside] ⇑false ].
	while⦂ (r has: (pt←user mp)) do⦂ [
			user nobug ⇒ [
				i←self index.
				[ self visible: i ⇒ [self unshowI: i] self showI: i ].
				thisline comp.
				⇑false. ]
			thisline has: pt⇒[ ]
			thisline comp;
			 moveto: ((text ptofpt: pt) x←left); "follow mouse"
			 comp ].
	pt x≥r rightside⇒[⇑self edit]
	thisline comp. ⇑false ]
Bug | trace i menu index res [
	while⦂ ((trace←self has: user mp) or⦂ user anybug) do⦂ [
		trace and⦂ user anybug ⇒ [
			for⦂ i from: trace length to: 2 by: ¬1 do⦂ [ "root down"
				menu←trace◦i◦1. index←trace◦i◦2.
				menu indexI: index; showI: index; thisline comp. ].
			res←(trace◦1) bug. "does its own comp"
			for⦂ i from: 2 to: trace length do⦂ [ "unravel"
				menu←trace◦i◦1. index←trace◦i◦2.
				menu assignI: index; thisline comp. ].
			res ⇒ [⇑true] ] ].
	⇑false ]

edit | i v res [
	self showI: (i←self index).
	v←viewer◦i.
	[ res←v bug ⇒ [self assignI: i] ].
	self thisline comp. ⇑res ]
extractI: i | e "Get value of attribute i" [
	(e←extract◦i)≡nil⇒[⇑nil]
	e class≡UniqueString⇒[⇑viewee perform: e]
	attributeViewee←viewee.
	attributeMenu←self.
	e "sender←thisContext;" eval. "remote code"
	⇑attributeValue. ]
flashbug | a [
	self showat: user mp-(frame extent/2).
	a←self Bug.
	self unshow.
	⇑a ]
has: pt | i v res "trace from menu having pt" [
	text frame has: pt ⇒ [⇑self inVector "first element is menu with pt"]
	for⦂ i from: showing length to: 1 by: ¬1 do⦂ [
		(v←viewer◦(showing◦i)) ismenu ⇒ [
			(res←v has: pt) ⇒ [⇑(res, (self, (showing◦i))) "later ones have index"] ] ]
	⇑false ]
indexI: i "make self index be i" [
	thisline moveto: ((self atI: i) x←text frame leftside). ]

Example 
example
"	Here is an example with an AttributeMenu as a viewer for an AttributeMenu
	| unitviewer menuviewer originmenu X oldr newr.
	unitviewer←UnitViewer default units:
		(('micas',1) inVector, ('pts',35.3), ('picas',423.3), ('cm',899.75), ('in',2540.0)).
	menuviewer←[AttributeViewer new
		menu: [ActionMenu new
			stringFromVector: ('white','ltgray','gray','dkgray','black'); init;
			action←(white,ltgray,gray,dkgray,black)] ].
	originmenu←AttributeMenu init.
		originmenu title: 'x';
			extract: ↪x; assign: 'x←'; viewer: unitviewer copy.
		originmenu title: 'y';
			extract: ↪y; assign: 'y←'; viewer: unitviewer copy.
	X←AttributeMenu init.
		X	title: 'origin⇒';
			extract: ↪origin; assign: nil; viewer: originmenu.
		X	title: 'color';
			extract⦂	[attributeValue←attributeViewee bitsIntoString◦1];
 			assign⦂	[attributeViewee clear: attributeValue];
			viewer: menuviewer.

	oldr←Rectangle new fromuser. oldr comp. newr←oldr.
	user waitbug. X viewee: newr; showat: user mp-(X frame extent/2).
	while⦂ (X has: user mp) do⦂ [X bug]. X unshow. oldr comp. newr comp.
"
exampleH
"	Here is an example of horizontal attributes display/edit
	| unitviewer ptmenu X oldr newr.
	unitviewer←UnitViewer default
		units: (('pts',1) inVector, ('picas',12), ('in',72.0), ('cm',28.35)).
	ptmenu←AttributeHMenu init.
		ptmenu title: 'x';
			extract: ↪x; assign: 'x←'; viewer: unitviewer copy.
		ptmenu title: 'y';
			extract: ↪y; assign: 'y←'; viewer: unitviewer copy.
	X←AttributeMenu init.
		X title: 'origin⇒';
			extract: ↪origin; assign: nil; viewer: ptmenu copy.
		X title: 'corner⇒';
			extract: ↪corner; assign: nil; viewer: ptmenu copy.

	oldr←Rectangle new fromuser. oldr comp. newr←oldr copy.
	user waitbug. X viewee: newr; showat: user mp.
	while⦂ (X has: user mp) do⦂ [X bug]. X unshow. oldr comp. newr comp.
"
exampleV
"	Here is an example of vertical attributes display/edit
	| unitviewer X oldr newr.
	unitviewer←UnitViewer default
		units: (('pts',1) inVector, ('picas',12), ('in',72.0), ('cm',28.35)).
	X←AttributeMenu init.
		X title: 'origin x';
			extract: ↪x; assign: 'x←'; viewer: unitviewer copy.
		X title: 'origin y';
			extract: ↪y; assign: 'y←'; viewer: unitviewer copy.

	oldr←Rectangle new fromuser. oldr comp. newr←oldr.
	user waitbug. X viewee: (newr origin); showat: user mp.
	while⦂ (X has: user mp) do⦂ [X bug]. X unshow. oldr comp. newr comp.
"

SystemOrganization classify: ↪AttributeMenu under: 'Attributes'.

"AttributeHMenu" 
Class new title: 'AttributeHMenu'
	subclassof: AttributeMenu
	fields: ''
	declare: '';
	asFollows 

I am an AttributeMenu stretched out on one line
I use the following in a non-standard way:
	title is now a Set of readonly viewers that display the titles
	underbits is now unused (the viewers do their own)
	thisline is now an Integer


Init 
init [super init. thisline←1.]
title: t [
	[ title≡nil ⇒ [self init] ].
	title←title, [AttributeViewer new toString: ↪itself; attribute: t]. ]
title←t | s i [
	t◦1 is: String ⇒ [for⦂ s from: t do⦂ [self title: s] ]
	title←Vector new: t length.
	for⦂ i to: t length do⦂ [title◦i ← (t◦i) copy]. ]

Parts 
index [⇑thisline "I don't really use my menuness"]
thisline [⇑(title◦thisline) window]
window [⇑(title◦1) window origin rect: title last window corner]

Show 
at: pt [(title◦1) at: pt]
atI: i | w [ w←(title◦i) window. ⇑w rightside⌾w top ]
intersects: a [⇑a intersects: self window]
	
pastI: i | w [
	showing has: i ⇒ [
		w←(viewer◦i) window.
		⇑w rightside⌾w top ]
	⇑(self atI: i)+(2⌾0) ]
restorebits | t [ for⦂ t from: title do⦂ [t unshow]. ]
show [ (title◦1) show window comp. self showfrom: 1. ]
showfrom: i | j pt [
	pt←self atI: i.
	for⦂ j from: i to: title length do⦂ [
		[	i=j ⇒ []
			(title◦j) showat: pt; window comp.
			pt←self atI: j. ].
		[ showing has: j ⇒ [(viewer◦j) showat: pt] ].
		pt←self pastI: j. ]. ]
showI: i [
	(showing has: i) ⇒ []
	self unshowto: i.
	showing add: i.
	self showfrom: i. ]	
unshow [self unshowto: 1. (title◦1) unshow.]
unshowI: i [
	showing has: i ⇒ [
		self unshowto: i.
		showing delete: i.
		self showfrom: i. ] ]
unshowto: i | j [
	for⦂ j from: title length to: i+1 by: ¬1 do⦂ [
		(viewer◦j) unshow.
		(title◦j) unshow. ].
	(viewer◦i) unshow. ]

Bug/Edit 
bug | r pt i res w [
	user nobug ⇒ [⇑false]
	pt←user mp.
	for⦂ i to: title length do⦂ [
		(r←(title◦i) window) has: pt ⇒ [
			r comp.
			while⦂ (r has: (pt←user mp)) do⦂ [
				user nobug ⇒ [
					[ self visible: i ⇒ [self unshowI: i] self showI: i ].
					r comp.
					⇑false ] ]
			pt x≥r rightside ⇒ [
				self showI: i; indexI: i.
				w←(viewer◦i) window.
				res←self edit.
				[w≠(viewer◦i) window ⇒ [
					(viewer◦i) unshow.
					self unshowto: i; showfrom: i. ] ].
				⇑res ]
			r comp.
			⇑false ] ]
	⇑false ]
flashbug | a [
	self showat: user mp-((title◦1) frame extent/2).
	a←self Bug.
	self unshow.
	⇑a ]
has: pt | i [
	for⦂ i to: title length do⦂ [
		(title◦i) window has: pt ⇒ [⇑self inVector] ].
	⇑false ]
indexI: thisline

SystemOrganization classify: ↪AttributeHMenu under: 'Attributes'.

"AttributeViewer" 
Class new title: 'AttributeViewer'
	subclassof: TextImage
	fields: 'attribute menu toString fromString underbits'
	declare: '';
	asFollows 

AttributeViewers are TextImages augmented with:
	attribute		the value I deal with
	underbits		the bits of what I cover
	For choose-one values:
	menu			an ActionMenu to select one of a set of values
	For integers, strings, etc:
	toString			how to show the value as a String (selector or code)
	fromString		how to get the value from a String (selector or code)
My code can utilize the globals:
	attribueMenu (caller)
	attributeViewee (callers viewee)
	attributeText (text)
	attributeValue

Init 
attribute: attribute
copy [⇑(self class copy: self) reset menu: menu copy]
default [ "for integers, read/write. start with new me"
	self toString: ↪asString;
		fromString⦂ [attributeValue←attributeText asStream integerScan asInteger] ]
fromString⦂ fromString
fromString: fromString [fromString≡nil ⇒ [] fromString←fromString unique]
init [self readonly]
menu: menu
readonly [self toString: ↪asString "for integers, read only. start with new me"]
toString⦂ toString
toString: toString [toString≡nil ⇒ [] toString≡nil ⇒ [] toString←toString unique]

Parts 
attribute [⇑attribute]
ismenu [⇑false] "no subtree here"
isreadonly [⇑fromString≡nil and⦂ menu≡nil]
menu [⇑menu]
para←para

Show 
at: pt [frame←pt+(2⌾0) rect: pt. self reset.]
intersects: a [⇑a intersects: window]
reset [underbits←false]
resetbits [underbits←false]
reshow [ self savebits show. ] "redisplay on changed screen"
restorebits [underbits≡nil⇒[] underbits⇒[window bitsFromString: underbits] ]
savebits [underbits←window bitsIntoString]
show [
	underbits ⇒ [window clear: white. super show.]
	self toString getframe savebits show. ]
show: v at: pt [ self attribute: v; at: pt; show. ]
showat: pt [self at: pt; show]
unshow [self restorebits reset]

Edit 
bug [⇑self edit]
edit | button c [
	self isreadonly ⇒ [⇑false]
	self menubug ⇒ [⇑self unshow show "new value"]
	fromString≡nil⇒[⇑false "only menu values allowed"]
	self unshow editshow.
	c←thisContext sender.
	while⦂ c receiver≡self do⦂ [c←c sender].
	button←c receiver thisline. "in mother AttributeMenu"
	while⦂ true do⦂ [
		user anybug ⇒ [
			frame has: user mp ⇒ []
			until⦂ [
				frame has: user mp ⇒ [
					self menubug ⇒ [⇑self editunshow show]
					true ]
				user nobug ⇒ [
					button has: user mp ⇒ [
						self editunshow.
						user leftShiftKey ⇒ [self show. ⇑false "abort"]
						⇑self fromString show "new value entered" ]
					true ]
				false ] do⦂ [button flash] ]
		super edit: 0. ] ]
editshow | w [
	self editframe.
	w←window inset:¬2.
	underbits←w bitsIntoString.
	w clear: black. self show. ]
editunshow | w [(window inset: ¬2) bitsFromString: underbits. self reset.]
fromString | i t [
	[	menu≡nil ⇒ [] t←para text.
		for⦂ i to: menu action length do⦂ [
			t=(menu titleI: i) ⇒ [attribute←menu action◦i. ⇑self] ]. ].
	fromString class≡UniqueString ⇒ [attribute←para text perform: fromString]
	attributeText←para text. "-Menu and -Viewee set up by caller"
	fromString eval.
	attribute←attributeValue. ]
menubug | a [
	menu≡nil ⇒ [⇑false]
	(a←menu flashbug) ⇒ [attribute←a◦3. ⇑true]
	⇑false ]
toString | i [
	[	menu≡nil⇒[]
		i←menu action has: attribute.
		i ⇒ [para←(menu titleI: i) asParagraph. ⇑self] ].
	toString≡nil ⇒ [para←'
' asParagraph].
	toString is: UniqueString⇒[para←(attribute perform: toString) asParagraph.]
	attributeValue←attribute. "-Menu and -Viewee set up by caller"
	toString eval.
	para←attributeText asParagraph. ]

Private 
editframe [self getframe growby: self extra]
extra [⇑24⌾0]
getframe | pt [
	self paragraph: para frame: (frame corner←(1000⌾1000)) style: DefaultTextStyle.
	frame growto: (self maxx: para length+1)+(4⌾0).
	frame height←style lineheight.
	window←frame origin-(2⌾0) rect: frame corner. ]
growby: pt [frame growby: pt. window growby: pt.]

SystemOrganization classify: ↪AttributeViewer under: 'Attributes'.

"UnitViewer" 
Class new title: 'UnitViewer'
	subclassof: Object
	fields: '	attribute	"Integer in internal units"
				val			"AttributeViewer for value in current units"
				units			"AttributeViewer for units choice"
				underbits '
	declare: '';
	asFollows 

a UnitViewer allows a finite choice of display forms, represented by the name of the unit and the number of fundamental units in this unit, organized in an ActionMenu. The following two displays are for the same field value, assuming that (pts, 1) and (picas, 12) are the menu associations (field value=144):
	144 pts				12 picas

use the form (unit, (internal count per unit, display denominator)) to for example display decimal fraction, as for (unit, (72, 100)), which will display 36 points as 0.5 unit


Init/Access 
attribute [⇑attribute]
attribute: attribute
copy | t [
	t←self class new.
	t	val←val copy; units←units copy; attribute: nil; reset.
	⇑t ]
default [self readonly. val fromString: ↪itself]
example [] "
 | colorviewer lengthviewer lengthreader pointviewer pointreader.
(colorviewer←AttributeViewer default)
	menu: [ActionMenu new stringFromVector: ('white','ltgray','gray','dkgray','black');
					init; action←(white, ltgray, gray, dkgray, black) ].
lengthviewer←UnitViewer default units: (('pts',1) inVector, ('picas', 12), ('inches', (72,100))).
lengthreader←UnitViewer new readonly units: (('pts',1) inVector, ('picas', 12), ('inches', (72,100))).
(pointreader←AttributeHMenu init)
	title: 'x'; extract: ↪x; assign: 'x←'; viewer: lengthreader copy;
	title: 'y'; extract: ↪y; assign: 'y←'; viewer: lengthreader copy.
(pointviewer←AttributeHMenu init)
	title: 'x'; extract: ↪x; assign: 'x←'; viewer: lengthviewer copy;
	title: 'y'; extract: ↪y; assign: 'y←'; viewer: lengthviewer copy.

X←AttributeMenu init.
X title: 'origin'; extract: ↪origin; assign: 'origin←'; viewer: pointviewer copy.
X title: 'corner'; extract: ↪corner; assign: 'corner←'; viewer: pointreader copy.
X title: 'width'; extract: ↪width; assign: 'width←'; viewer: lengthviewer copy.
X title: 'height'; extract: ↪height; assign: 'height←'; viewer: lengthviewer copy.
X title: 'color'; extract: nil;	assign⦂ [attributeViewee clear: attributeValue];
	viewer: colorviewer copy.

X viewee: Rectangle new fromuser. user waitbug. X showat: user mp-(X frame extent/2).
X Bug.
"
init [self default]
ismenu [⇑false] "no subtree here"
isreadonly [⇑val isreadonly]
menu: m [val menu: m]
readonly [
	val←AttributeViewer new toString: ↪itself.
	self units: ('', 1) inVector. ]
units [⇑units]
units: u | i v ["u is Vector of form (('unit', n), . . ) where n internal units equal a unit"
	v←Vector new: u length.
	for⦂ i to: v length do⦂ [v◦i←(u◦i◦1)].
	units←AttributeViewer new menu: [ActionMenu new stringFromVector: v].
	for⦂ i to: v length do⦂ [v◦i←(u◦i◦2)].
	units menu init action←v.
	units attribute: units menu state;
		toString⦂ [attributeText←(attributeValue◦1 titleI: attributeValue◦2)]. ]
units←units
val [⇑val]
val←val
window [⇑val window origin copy rect: units window corner copy ]

Show 
at: pt [val at: pt]
fromString | s neg n unit c rem denom [
	s←val para asStream.
	neg←[s ∢ 025 "¬" ⇒ [true] false].
	n←s integerScan asInteger.
	unit←units attribute◦3.
	[ unit is: Vector ⇒ [unit←unit◦1] ].
	[	s ∢ 057 "/" ⇒ [attribute←0. rem←n. denom←s integerScan asInteger.]
		attribute←n*unit. rem←0. denom←1.
		s ∢ 056 "." ⇒ [
			while⦂ [(c←s next) and⦂ (060≤c and⦂ 071≥c)] do⦂ [
				rem←rem*10 + c-060. denom←denom*10. ]. ]
		while⦂ [(c←s next) and⦂ (060>c or⦂ 071<c)] do⦂ [] "wait for a digit"
		s end ⇒ [] s skip: ¬1. rem←s integerScan asInteger.
		while⦂ [(c←s next) and⦂ (060>c or⦂ 071<c)] do⦂ []. "normally skips over /"
		s skip: ¬1. denom←s integerScan asInteger ].
	attribute←attribute + ((rem*unit+(denom/2))/denom). "blem for denom odd"
	[ attribute is: Float ⇒ [attribute←attribute round] ].
	neg ⇒ [attribute←attribute negated]  ]
getframe [val getframe. units at: val window rightside⌾val window top; getframe.]
intersects: a [⇑a intersects: self window]
reset [underbits←false. val reset. units reset.]
restorebits [val restorebits. units restorebits.]
show [self toString getframe. val savebits show. units savebits show.]
show: attribute at: pt [self at: pt; show]
showat: pt [self at: pt; show]
toString | a unit rem denom n fraction i [
	a←attribute abs. unit←units attribute◦3.
	units para←(units menu titleI: (units menu action find: unit)) asParagraph.
	[ unit is: Vector ⇒ [denom←unit◦2. unit←unit◦1] denom←unit ].
	[ denom is: Float ⇒ [denom←[denom≤10.0 ⇒ [10]; ≤100.0 ⇒ [100]; ≤1000.0 ⇒ [1000] 10000] ] ].
	rem←a\unit. n←(a/unit) asInteger.
	[ denom=unit ⇒ [] rem←(((rem*denom) asFloat+(unit/2))/unit) asInteger].
	[ rem=denom ⇒ [n←n+1. rem←0] ].
	while⦂ (denom\10=0 and⦂ rem\10=0) do⦂ [
		rem←rem/10. denom←denom/10].
	fraction← [
		rem=0 ⇒ ['']
		denom=10 ⇒ ['.' + rem asString]
		denom=100 ⇒ ['.' + [rem<10⇒['0'] ''] + rem asString]
		denom=1000 ⇒ ['.' + [rem<10⇒['00'] rem<100⇒['0'] ''] + rem asString]
		denom=10000 ⇒ ['.' + [rem<10⇒['000'] rem<100⇒['00'] rem<1000⇒['0'] ''] + rem asString]
		for⦂ i from: (2,3,5,7) do⦂ ["reduce p/q for sure if min(p,q)≤120"
			while⦂ (rem\i=0 and⦂ denom\i=0) do⦂ [
				rem←rem/i. denom←denom/i. ]. ].
		' ' + rem asString + '/' + denom asString ].
	val para← (
		([attribute<0 ⇒ ['¬'] '']) +
		n asString +
		fraction +
		015 inString "cr") asParagraph. ]
unshow [units unshow. val unshow.]

Edit 
bug [⇑self edit]
edit | button a c m old [
	val isreadonly ⇒ [
		[	(a←units menu flashbug) ⇒ [
				a≠units attribute ⇒ [
					self unshow. units attribute: a. self show ] ] ].
		⇑false ]
	old←attribute.
	self valmenubug ⇒ [
		attribute=old ⇒ [⇑false]
		self unshow show. ⇑true]
	self unshow editshow.
	c←thisContext sender.
	while⦂ c receiver≡self do⦂ [c←c sender].
	button←c receiver thisline.
	while⦂ true do⦂ [
		user anybug ⇒ [
			val frame has: user mp ⇒ []
			units frame has: user mp ⇒ [self unitsbug]
			until⦂ [
				val frame has: user mp ⇒ [
					self valmenubug ⇒ [self editunshow show. ⇑attribute≠old] ]
				user nobug ⇒ [
					button has: user mp ⇒ [
						self editunshow.
						[ user leftShiftKey ⇒ [attribute←old] self fromString ].
						self show. ⇑attribute≠old] ]
				false ] do⦂ [button flash] ]
		val edit: 0 ] ]

editframe [val editframe. units at: val window rightside⌾val window top; getframe.]
editshow | w [
	self toString editframe.
	w←self window inset: ¬2.
	underbits←w bitsIntoString.
	w clear: black.
	val savebits show.
	units savebits show. ]
editunshow [ (self window inset: ¬2) bitsFromString: underbits. self reset. ]
unitsbug | a [
	(a←units menu flashbug) ⇒ [
		a=units attribute ⇒ []
		self editunshow fromString.
		units attribute: a.
		self editshow. ] ]
valmenubug | a old [
	val menu≡nil ⇒ [⇑false]
	(a←val menu flashbug) ⇒ [attribute←a◦3. ⇑true]
	⇑false ]

SystemOrganization classify: ↪UnitViewer under: 'Attributes'.

"ViewerSet" 
Class new title: 'ViewerSet'
	subclassof: Dictionary
	fields: 'viewer'
	declare: '';
	asFollows 

I choose a viewer appropriate to the class of my attribute

Init/Access 
copy | v i vs [
	v←values class new: values size.
	for⦂ i to: values size do⦂ [v◦i ← (values◦i) copy]. "unique viewers"
	vs←self class new with: objects values: v.
	⇑vs ]
default | lengthviewer pointviewer "a universal viewer" [
	super init.
	lengthviewer←UnitViewer default
		units: (('pts', 1) inVector, ('picas', 12), ('inches', (72,100))).
	pointviewer←[ AttributeMenu init
		title: 'x'; extract: ↪x; assign: 'x←'; viewer: lengthviewer copy;
		title: 'y'; extract: ↪y; assign: 'y←'; viewer: lengthviewer copy ].
	self insert: Integer with: AttributeViewer default;
		insert: String with: [AttributeViewer new toString: ↪itself; fromString: ↪itself];
		insert: Point with: pointviewer copy;
		insert: Rectangle with: [ AttributeMenu init
			title: 'origin'; extract: ↪origin; assign: 'origin←'; viewer: pointviewer copy;
			title: 'corner'; extract: ↪corner; assign: 'corner←'; viewer: pointviewer copy;
			title: 'width'; extract: ↪width; assign: 'width←'; viewer: lengthviewer copy;
			title: 'height'; extract: ↪height; assign: 'height←'; viewer: lengthviewer copy ]. ]
"
X←ViewerSet default.
X attribute: user mp; flashbug.
X attribute: Rectangle new fromuser; flashbug.
"
readonly | lengthviewer pointviewer "a universal readonly viewer" [
	super init.
	lengthviewer←UnitViewer new readonly 
		units: (('pts', 1) inVector, ('picas', 12), ('inches', (72,100))).
	pointviewer←[ AttributeMenu init
		title: 'x'; extract: ↪x; viewer: lengthviewer copy;
		title: 'y'; extract: ↪y; viewer: lengthviewer copy. ].
	self insert: Integer with: AttributeViewer default;
		insert: String with: [AttributeViewer new toString: ↪itself];
		insert: Point with: pointviewer copy;
		insert: Rectangle with: [ AttributeMenu init
			title: 'origin'; extract: ↪origin; viewer: pointviewer copy;
			title: 'corner'; extract: ↪corner; viewer: pointviewer copy;
			title: 'width'; extract: ↪width; viewer: lengthviewer copy;
			title: 'height'; extract: ↪height; viewer: lengthviewer copy ]. ]

viewer [⇑viewer]

AsViewer 
at: pt [viewer at: pt]
attribute [⇑viewer attribute]
attribute: a | c [
	c←a class.
	until⦂ c≡nil do⦂ [
		(viewer←self lookup: c) ⇒ [viewer attribute: a. ⇑self]
		c←c superclass. ].
	viewer←AttributeViewer new readonly attribute: a. "can show anything that can asString"]
bug [⇑viewer bug]
Bug [⇑viewer Bug]
edit [⇑viewer edit]
flashbug [⇑viewer flashbug]
has: pt [⇑viewer has: pt]
intersects: a [⇑viewer intersects: a]
isreadonly [⇑viewer isreadonly]
reset [viewer reset]
show [viewer show]
show: a at: pt [viewer show: a at: pt]
showat: pt [self at: pt; show]
unshow [viewer unshow]
viewee: v [viewer attribute: v]

SystemOrganization classify: ↪ViewerSet under: 'Attributes'.
