'From Smalltalk 5.5k XM November 24 on 4 October 1990 at 11:41:27 pm.'

"Axes" 
Class new title: 'Axes'
	subclassof: Object
	fields: 'origin window mode xScale yScale xaxis yaxis'
	declare: '';
	asFollows 

I display a pair of x-y axes with the following characteristics:
	origin		the point at which the axes cross (screen coordinates)
	window		the Rectangle in which I am displayed
	mode			display mode: xoring, oring, storing, or erasing
	xScale		(bits/large tick mark), (bits/small tick mark)
	yScale		(bits/large tick mark), (bits/small tick mark)
	xaxis			(a Rectangle, axis raster, underbits raster)
	yaxis			(a Rectangle, axis raster, underbits raster)
Notes:
	Parts--relOrigin gives origin relative to inRect origin.
	Change--no change is seen until a show. It may be necessary to unshow or at:
		before showing an altered version, depending on mode or scale change.
	Show--at:wrt: positions with-respect-to window origin.
	Display--only at:* causes saving of covered bits and movement of axes.
See example for a sample definition


Init 
default [self mode: xoring; xScale: 0; yScale: 0]

Parts 
finescale [⇑(xScale◦2) ⌾ (yScale◦2)]
mode [⇑mode]
origin [⇑origin]
relOrigin [⇑origin-window origin]
scale [⇑(xScale◦1) ⌾ (yScale◦1)] "gives coarse only"
window [⇑window]
xScale [⇑xScale] "a Vector: (coarse, fine)"
yScale [⇑yScale] "a Vector: (coarse, fine)"

Change 
mode: mode
xScale: k [self xScale: k finescale: k] "no finescale ticks"

xScale: k finescale: l | w a b r x [
	w←user screenrect width.
	a←0⌾0 rect: w⌾5. b←a bitsIntoString. a clear: white.
	[	k=0 ⇒ [(0⌾2 extent: w⌾1) comp "axis"]
		(0⌾0 extent: 1⌾5) comp. "coarse tick"
		[	l≤1 or⦂ l≥k ⇒ [] "otherwise draw short ticks (every l bits)"
			for⦂ x from: l to: k-1 by: l do⦂ [(x⌾1 extent: 1⌾3) comp]. ].
		(0⌾2 extent: k⌾1) clear: black. "axis"
		r←0⌾0 rect: k⌾5.
		while⦂ r width<w do⦂ [ "duplicate"
			r blt: r width⌾0 mode: storing clippedBy: user screenrect.
			r growby: r width⌾0] ].
	xScale←(k,l). xaxis←(a, a bitsIntoString, false).
	a bitsFromString: b ]
yScale: k [self yScale: k finescale: k] "no finescale ticks"

yScale: k finescale: l | h a b r y [
	h←user screenrect height.
	a←0⌾0 rect: 5⌾h. b←a bitsIntoString. a clear: white.
	[	k=0 ⇒ [(2⌾0 extent: 1⌾h) comp "axis"]
		(0⌾0 extent: 5⌾1) comp. "coarse tick"
		[	l≤1 or⦂ l≥k ⇒ [] "otherwise draw short ticks (every l bits)"
			for⦂ y from: l to: k-1 by: l do⦂ [(1⌾y extent: 3⌾1) comp]. ].
		(2⌾0 extent: 1⌾k) clear: black. "axis"
		r←0⌾0 rect: 5⌾k.
		while⦂ r height<h do⦂ [ "duplicate"
			r blt: 0⌾r height mode: storing clippedBy: user screenrect.
			r growby: 0⌾r height] ].
	yScale←(k,l). yaxis←(a, a bitsIntoString, false).
	a bitsFromString: b ]

Show 
at: origin | k z [
	[ window≡nil ⇒ [window←user screenrect] ].
	k←xScale◦1. z←window origin x.
	xaxis◦1 moveto: ([k=0⇒[z] z+(origin x-z \k)-k])⌾(origin y-2).
	k←yScale◦1. z←window origin y.
	yaxis◦1 moveto: (origin x-2)⌾([k=0⇒[z] z+(origin y-z \k)-k]).
	self savebits ]
at: origin in: window [self at: origin]
at: pt wrt: window [self at: pt+window origin] "pt with-respect-to window origin"
reshow [self at: origin; show] "redisplay on changed screen"
restorebits [
	[xaxis◦3 ⇒[(xaxis◦1 intersect: window) bitsFromString: xaxis◦3. xaxis◦3←false] ].
	[yaxis◦3 ⇒[(yaxis◦1 intersect: window) bitsFromString: yaxis◦3. yaxis◦3←false] ]. ]

savebits [
	xaxis◦3 ← (xaxis◦1 intersect: window) bitsIntoString.
	yaxis◦3 ← (yaxis◦1 intersect: window) bitsIntoString. ]

show [
	[ xaxis◦3 ⇒ [] self savebits ].
	xaxis◦1 bitsFromString: xaxis◦2 mode: mode clippedBy: window.
	yaxis◦1 bitsFromString: yaxis◦2 mode: mode clippedBy: window.
	mode=xoring ⇒ [ "xoring twice works right"
		[ xScale◦1≠0⇒[(origin-(0⌾2) extent: 1⌾5) comp] ].
		[ yScale◦1≠0⇒[(origin-(2⌾0) extent: 5⌾1) comp] ]. ]
	mode=storing and⦂ yScale◦1=0 ⇒ [ "redraw covered x-axis piece"
		(origin-(2⌾0) extent: 5⌾1) comp ] ]
unshow [self restorebits]

Example 
example
"	Creating, showing, and changing an Axes
	axes←Axes new default.
	axes xScale: 15 finescale: 5. axes yScale: 16 finescale: 4.
	axes mode: oring. axes mode: xoring. axes mode: erasing. axes mode: storing.
	while⦂ user nobug do⦂ [].
	axes at: user mp; show.
	axes at: user mp in: user screenrect; show.
	axes at: user mp in: Rectangle new fromuser; show.
	axes at: 20⌾20 wrt: Rectangle new fromuser; show.
	axes show. axes unshow.
"


SystemOrganization classify: ↪Axes under: 'Axes/Gridding'.

"Grid" 
Class new title: 'Grid'
	subclassof: Rectangle
	fields: 'window tracker'
	declare: '';
	asFollows 

grid is defined by tiling the rectangle from its origin.
the grid points may be shown and unshown (xoring), clipped by window.
bugging returns the closest grid point to the mouse, relative to origin.
	leftShiftKey causes display of coords of nearest grid point, at that point.
	will not finish as long as either the leftShiftKey or the mouse button is down.
	currently selected point is updated only while mouse button is down.
	false is returned if a point outside the window is bugged.


Init 
copy [ ⇑[self class new tracker: tracker copy; at: origin in: window copy; grid: self grid] ]
default | v [
	v←UnitViewer new readonly
		units: (('grid', 10) inVector, ('pts', 1), ('picas', 12), ('inches', (72, 100))).
	tracker←[ AttributeMenu init
		title: 'x'; extract: ↪x; assign: 'x←'; viewer: v copy;
		title: 'y'; extract: ↪y; assign: 'y←'; viewer: v copy ].
	self origin: 0⌾0 corner: 10⌾10;
		grid: self extent; window: user screenrect. ]
init [self default]

Parts 
grid [⇑self extent]
tracker [⇑tracker]
window [⇑window]

Change 
grid: g | u [
	self extent← g.
	u←(tracker viewer◦1) units. u menu action◦1←g x. u attribute◦3←g x.
	u←(tracker viewer◦2) units. u menu action◦1←g y. u attribute◦3←g y. ]
tracker: tracker
units: u [self unitsx: u; unitsy: u.]
unitsx: u [(tracker viewer◦1) units: u. self grid: self grid.]
unitsy: u [(tracker viewer◦2) units: u. self grid: self grid.]
window: window

Show 
at: pt [self moveto: pt]
at: pt in: window [self at: pt]
linebits | r save x pt b [
	r←self linerect.
	save←r bitsIntoString.
	x←self grid x.
	[	x≤1 ⇒ [r clear: black]
		r clear: white.
		pt←r origin copy.
		while⦂ pt x<r rightside do⦂ [
			(pt extent: 1) comp.
			pt x ← x+pt x. ] ].
	b←r bitsIntoString.
	r bitsFromString: save.
	⇑b ]
linerect [⇑window origin extent: window width⌾1]
reshow [self at: origin; show] "redisplay on changed screen"
show | pt r a b x y [
	(origin-(2⌾0) extent: 5⌾1) comp.
	(origin-(0⌾2) extent: 1⌾5) comp.
	a←origin-window origin.
	x←self grid x. y←self grid y.
	pt←a x\x ⌾ (a y\y) + window origin.
	r←self linerect. b←self linebits.
	while⦂ pt y<window bottom do⦂ [
		r moveto: pt; bitsFromString: b mode: xoring clippedBy: window.
		pt←pt+(0⌾self height). ]. ]
unshow [self show "since xoring"]

Bug 
bug | pt old [
	old←pt←false. tracker reset.
	while⦂ true do⦂ [
		user leftShiftKey ⇒ [
			[ old ⇒ [ tracker has: user mp ⇒ [tracker Bug] self flash: old ] ].
			user anybug and⦂ (pt←self mp) ⇒ [
				old=pt ⇒ []
				tracker unshow show: pt at: pt+origin.
				old←pt. ] ]
		[ old ⇒ [tracker unshow] ].
		user anybug ⇒ [ old←false. (pt←self mp) ⇒ [self flash: pt] ]
		old ⇒ [⇑old] ⇑pt ] ]
flash: pt [ (pt+origin-2 extent: 5) flash ]
mp | pt g offset [
	window has: (pt←user mp) ⇒ [
		g←self grid.
		offset←(origin x\g x)⌾(origin y\g y).
		pt←g/2+pt-offset.
		pt←((pt x|g x)⌾(pt y|g y))-((origin x|g x)⌾(origin y|g y)).
		window has: pt+origin ⇒ [⇑pt]
		⇑false ]
	⇑false ]

Example 
example [] "
Y←Grid init.
Y window: Rectangle new fromuser.
Y unshow.
Y grid: 8⌾12.
Y at: user mp.
Y show.
Y bug .
Y unitsx: ( ('units', nil) inVector, ('cm', (28.35, 100)), ('pts', 1) ).
Y unitsy: ( ('units', nil) inVector, ('picas', 12), ('pts', 1) ).

Rectangle new fromuser clear: white.
"

SystemOrganization classify: ↪Grid under: 'Axes/Gridding'.
