'From Smalltalk 5.5k XM November 24 on 4 October 1990 at 11:38:19 pm.'

"ActionMenu" 
Class new title: 'ActionMenu'
	subclassof: Menu
	fields: 'action underbits firstline menu'
	declare: '';
	asFollows 

ActionMenus are Menus augmented with:
	action		bugging line i in the menu activates action◦i,
					which must be a UniqueString
	menu		going right out of line i activates menu◦i,
					which must be the index of a menu in my MenuSet
	underbits	the bits of what I cover
	firstline		if not nil is the number-1 of the first thisline
					(note that firstline← does the -1 for you)
See example for a sample definition

Init 
action←action
copy [⇑(self class copy: self) action← action copy]
firstline←n [firstline←n-1] "converts to 0 offset"
indexI: i [thisline moveto: text frame origin+(0⌾((i-1)*text lineheight))]
init "Do after text is ok"
	[action←Vector new: self lines. menu←Vector new: self lines]
movingsetup | orig 
	[ [firstline≡nil⇒
		[ ]
		orig←text frame origin.
		thisline moveto: orig x ⌾(firstline "0 offset" * text lineheight + orig y)].
	underbits←super movingsetup]

Parts 
action [⇑action]
index [⇑1+(thisline origin y - text frame origin y / text lineheight)]
lines [⇑text frame extent y / text lineheight]
menu [⇑menu]
state | i [i←self index. ⇑(self, i, (action◦i)) "last bug"]
string [⇑str]
text [⇑text]
thisline [⇑thisline]
titleI: i | s t c j
	[s←str asStream.
	for⦂ j to: i-1 do⦂  "skip up to line i"
		[until⦂ (c←s next)=015 do⦂ [c⇒[ ] ⇑false "i too big"] ].
	t←Stream default.
	until⦂ (c←s next)=015 do⦂
		[c⇒
			[t next←c]
			t empty⇒
				[⇑false "no such line"]
				⇑t cr contents  "no cr at end" ].
	⇑t cr contents "normal exit"]
underbits [⇑underbits]

Show 
restorebits [underbits⇒[frame bitsFromString: underbits] ]
unshow [self restorebits]

Bug 
bug | pt i "a triple if bug inside; false if outside, unless trigger new menu"
	[user nobug⇒[⇑false]
	[text frame has: user mp⇒[thisline comp] ⇑false].
	while⦂ (text frame has: (pt←user mp)) do⦂
		[user anybug⇒
			[thisline has: pt⇒
				[ ]
				pt←text ptofpt: pt.
				thisline comp; moveto: text frame origin x ⌾ pt y; comp "follow mouse"].
			i←self index. ⇑(self, i, (action◦i))].
	(pt x < text frame corner x) or⦂ (i←menu◦self index)≡nil⇒
		[thisline comp. ⇑false]
		⇑i	"went out to the right"]
Bug | a "stays in this menu until nobug; returns false unless bugged inside"
	[ while⦂ user anybug do⦂ [(a←self bug) is: Vector ⇒ [⇑a] ]. ⇑false ]
flashbug | a [a←self movingsetup Bug. self unshow. ⇑a] "show, bug, unshow"

Example 
example
"	A simple menu
	X←[(ActionMenu new)
		stringFromVector: ('storing', 'oring', 'xoring', 'erasing '); init].
	until⦂ user yellowbug do⦂ [ ]. X movingsetup.
	X show. X bug. X unshow.
"

SystemOrganization classify: ↪ActionMenu under: 'Action Menus'.

"MenuSet" 
Class new title: 'MenuSet'
	subclassof: Set
	fields: 'current firstmenu showing'
	declare: '';
	asFollows 

A MenuSet is a set of ActionMenus with the following:
	current		the index of the current menu
	firstmenu	is the index of the first menu to show on bug
						(if nil use current)
	showing	a set of the indices of the menus now being displayed
See example for sample definition.

Init 
current←current
firstmenu←firstmenu
init [current←1. showing←Set new default]
menu: m line: l action: act
	[ [m Is: ActionMenu⇒[m←self find: m] ].	"m can be a menu in self or its index"
	(self◦m) action◦l ← act								"act is: UniqueString"]
menu: m line: l tomenu: n
	[ [m Is: ActionMenu⇒[m←self find: m] ].	"m is a menu in self, or its index"
	  [n Is: ActionMenu⇒[n←self find: n] ].		"likewise for n"
	(self◦m) menu◦l ← n]

Parts 
current [⇑self◦current]
firstmenu [⇑firstmenu]
showing [⇑showing]
state [⇑self current state, showing copy "last bug"]

Show 
show: menu [self showI: (self has: menu)]
showI: i | j
	[i⇒[i=current⇒[ ]
		(j←showing has: (current←i))⇒
			["back to an old menu"
			for⦂ i from: showing position to: j+1 by: ¬1 do⦂ [(self◦(showing◦i)) unshow].
			showing position←j. self current show]
			"show a new menu"
			self current movingsetup. showing add: current] ]
unshow | i
	[for⦂ i from: showing position to: 1 by: ¬1 do⦂ [(self◦(showing◦i)) unshow] ]

Bug 
bug | i act found v
	[ [firstmenu≡nil⇒[ ] current←firstmenu].
	self current movingsetup.
	showing reset add: current. "current is an index"
	while⦂ true do⦂
		[(v←self current bug)⇒
			[v	is: Integer⇒
				[self showI: v] "menu index"
				v←v, showing copy. "a trace of the menus"
				self unshow.
				[(act←v◦3)≡nil⇒
					[ ]
					v◦3←thisContext sender receiver perform: act].
				⇑v]
			found←false.
			until⦂ found do⦂
				[user nobug⇒[self unshow. ⇑false]
				for⦂ i from: showing do⦂
					[found⇒[ ]
					(self◦i) has: user mp⇒[found←true. self showI: i] ]
				user anykeys⇒ 
					[(dp0 pressfile: 'screen.press' asFileName)
					screenout: user screenrect scale: PressScale] ] ] ]
flashbug [⇑self bug] "show, bug, unshow"
zbug | i v act found
	[ [firstmenu≡nil⇒[ ] current←firstmenu].
	self current movingsetup.
	showing reset add: current. "current is an index"
	while⦂ true do⦂
		[(v←self current bug)⇒
			[v is: Integer⇒
				[self showI: v] "menu index"
				v←v, showing copy. "a trace of the menus"
				self unshow.
				[(act←v◦3)≡nil⇒
					[ ]
					v◦3←thisContext sender receiver perform: act].
				⇑v]
			found←false.
			until⦂ found do⦂
				[user nobug⇒[ ]
				for⦂ i from: showing do⦂
					[found⇒[ ]
					(self◦i) has: user mp⇒[found←true. self showI: i] ]
				user anykeys⇒ 
					[(dp0 pressfile: 'screen.press' asFileName)
					screenout: user screenrect scale: PressScale] ] ] ]

Example 
example
"	A simple tree menu
	X←MenuSet default init.
	X add: [(ActionMenu new)
			stringFromVector: ('add box⇒', 'selection⇒', 'position⇒'); init].
	X add: [(ActionMenu new)
			stringFromVector: ('text', 'rule', 'tone', 'ais', 'math', 'table'); init].
	X add: [(ActionMenu new)
			stringFromVector: ('next box', 'prev box', 'first box', 'last box'); init].
	X add: [(ActionMenu new)
			stringFromVector: ('move', 'drag', 'slide', 'delete', 'undelete'); init].
	X menu: 1 line: 1 tomenu: 2.
	X menu: 1 line: 2 tomenu: 3.
	X menu: 1 line: 3 tomenu: 4.
	X firstmenu←1.
	until⦂ user yellowbug do⦂ []. X bug.

	A cycle of menus
	X←MenuSet default init.
	X add: [(ActionMenu new)
			stringFromVector: ('add box⇒', 'selection⇒', 'position⇒'); init].
	X add: [(ActionMenu new)
			stringFromVector: ('text', 'rule', 'tone', 'ais', 'math', 'table'); init].
	X add: [(ActionMenu new)
			stringFromVector: ('next box', 'prev box', 'first box', 'last box'); init].
	X add: [(ActionMenu new)
			stringFromVector: ('move', 'drag', 'slide', 'delete', 'undelete'); init].
	(X◦1)menu all←2.
	(X◦2)menu all←3.
	(X◦3)menu all←4.
	(X◦4)menu all←1.
	until⦂ user yellowbug do⦂ []. X bug.
"

SystemOrganization classify: ↪MenuSet under: 'Action Menus'.
