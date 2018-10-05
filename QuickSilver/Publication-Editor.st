'From Smalltalk 5.5k XM November 24 on 4 October 1990 at 11:44:27 pm.'
\g
"Coord"l15000z20000\gbf5 
Class new title: 'Coord'
	subclassof: Object
	fields: 'pt tic box pageviewer cursor underbits showing'
	declare: '';
	asFollows\gbf5 

I am used by PublicationViewer to display its anchor and mark:
	pt					the Point in points relative to pageviewer origin where I am showing
	tic					the Integer 0-8 indicating which Rectangle tic I am showing on
	box				the PublicationBox in which I am showing (false if none)
	pageviewer	the PageViewer in which I am showing
	cursor			the Cursor which I display when I am showing
	underbits		the String of bits which I cover (false if not showing)
	showing		the flag which indicates whether or not I am showing\gi

Init/Access\gbf5 
box [⇑box]\gb4B1b4B
box←box\gb
cursor [⇑cursor]\gb7B1b7B
cursorpt [⇑(pageviewer scaleDn: pt)+(pageviewer frame origin)-cursor offset]\gb9B1b65B
cursor←cursor\gb
forget [pt←tic←box←pageviewer←cursor←underbits←showing←nil]\gb7B
frame [⇑self cursorpt extent: 16⌾16]\gb6B1b28B
init [pt←tic←box←pageviewer←cursor←underbits←showing←false]\gb5B
pageviewer [⇑pageviewer]\gb11B1b11B
pageviewer←pageviewer\gb
pt [⇑pt]\gb3B1b3B
pt←pt\gb
showing [⇑showing]\gb8B1b8B
showing←showing\gb
tic [⇑tic]\gb4B1b4B
tic←tic\gb
underbits [⇑underbits]\gb10B1b10B
underbits←underbits\gb

Showing\gbf5 
show | f "Save underbits and BitBlt the cursor at the specified point"
	[f←self frame. underbits←f bitsIntoString.
	cursor showat: (f origin+cursor offset) mode: oring. showing←true]\gb5B3bi1B61I
showAt: cursorinfo "Extract the fields from cursorinfo and show the cursor"
	[self unshow.
	pageviewer←cursorinfo◦1. pt←cursorinfo◦2.
	box←cursorinfo◦3. tic←cursorinfo◦4. cursor←cursorinfo◦5.
	self show]\gb18i1B56I
showSame [showing⇒[self show] ]\gb8i1BI
unshow "Restore the original bits to the screen"
	[showing⇒[self frame bitsFromString: underbits. underbits←showing←false] ]\gb6i1B41bI2B
unshowSame | s [s←showing. self unshow. showing←s]\gb11B3i1I
\g
SystemOrganization classify: ↪Coord under: 'Publication Editor'.\g

"PageViewer"l15000z20000\gbf5 
Class new title: 'PageViewer'
	subclassof: Window
	fields: 'publicationviewer publication pageindex pagenumframe selectedbox backcolor attributes cursorinfo dirty'
	declare: 'PageAttributes CrossCursor PageCursor BoxCursor BoxMenu AnchorCursor PageMenu ';
	asFollows\gbf5 

A PageViewer is a Window that is a pane of a PublicationViewer with:
	publicationviewer	the PanedWindow of which I am a pane
	publication			the Publication containing the PublicationPage that I view
	pageindex				the Integer index of the PublicationPage that I view
	pagenumframe		the Rectangle in which I display my pagenum
	selectedbox				the PublicationBox where the mark is (false if none)
	backcolor				the Integer color which fills my window (default is gray)
	attributes				the AttributeMenu currently being displayed (false if none)
	cursorinfo				the Vector of (view,pt,box,tic,cursor) where cursor last was
	dirty						the flag which indicates whether or not I need to be redrawn\gi

Init/Access\gbf5 
attributesInit "PageViewer classInit. PageViewer new attributesInit."
	|	colorviewer ViewerAttributes
	[	colorviewer←[AttributeViewer new
			menu: [ActionMenu new
				stringFromVector: ('white','light gray','gray','dark gray','black'); init;
				action←(white,ltgray,gray,dkgray,black)] ].
		ViewerAttributes←AttributeMenu new.
			ViewerAttributes title: 'Background Color';
				extract: ↪backcolor; assign: 'backcolor←'; viewer: colorviewer copy.
		PageAttributes←AttributeMenu new.
			PageAttributes title: 'Viewer⇒';
				extract: ↪itself; assign: nil; viewer: ViewerAttributes.
			PageAttributes title: 'Page⇒';
				extract: ↪page; assign: nil; viewer: nil  ]\gb15B
backcolor [⇑backcolor]\gb10B1b10B
backcolor←backcolor [dirty←true]\gb20B
classInit "PageViewer classInit."
	[	self cursorInit; menuInit; attributesInit  ]\gb10B
cursorInit "PageViewer classInit. PageViewer new cursorInit."
	[	PageCursor←Cursor new fromtext: '
0000000000000000
0001111111111100
0001000000000100
0001000000110100
0001000000110100
0001000000000100
0001011111110100
0001010000010100
0001010000010100
0001010000010100
0001010000010100
0001010000010100
0001011111110100
0001000000000100
0001111111111100
0000000000000000' offset: 8⌾8.
		CrossCursor←Cursor new fromtext: '
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
0000000010000000' offset: 8⌾8.
		BoxCursor←Cursor new fromtext: '
0000000000000000
0000000000000000
0000000000000000
0000000000000000
0000000000000000
0000000000000000
0000011111110000
0000010000010000
0000010000010000
0000010000010000
0000010000010000
0000010000010000
0000011111110000
0000000000000000
0000000000000000
0000000000000000' offset: 8⌾8.
		AnchorCursor←Cursor new fromtext: '
0000000000000000
0110000000000011
0111000000000111
0011100000001110
0001110000011100
0000111000111000
0000011101110000
0000001111100000
0000000111000000
0000001111100000
0000011101110000
0000111000111000
0001110000011100
0011100000001110
0111000000000111
0110000000000011' offset: 8⌾8  ]\gb11B
frame←frame "For compatibility with PanedWindow frame:"\gb12Bi
fullScale [self scale=(1,1)⇒[⇑true] ⇑false]\gb10B19b5B2b6B
init [selectedbox←attributes←false. backcolor←gray "052652"]\gb5B
menuInit "PageViewer classInit. PageViewer new menuInit."
	[	BoxMenu←MenuSet new default init.
			BoxMenu add: [(ActionMenu new) string:		"1"
'adjust
change⇒
contents⇒
attributes
duplicate
delete'; init].
			BoxMenu add: [(ActionMenu new) string:		"2"
'links⇒
selection⇒'; init].
			BoxMenu add: [(ActionMenu new) string:		"3"
'continued from
continued to
unlink'; init].
			BoxMenu add: [(ActionMenu new) string:		"4"
'next
prev
first
last
under'; init].
			BoxMenu add: [(ActionMenu new) string:		"5"
'get
edit'; init].
			BoxMenu firstmenu←1.
			BoxMenu menu: 1 line: 2 tomenu: 2.
				BoxMenu menu: 2 line: 1 tomenu: 3.
				BoxMenu menu: 2 line: 2 tomenu: 4.
			BoxMenu menu: 1 line: 3 tomenu: 5.
		PageMenu←MenuSet new default init.
			PageMenu add: [(ActionMenu new) string:		"1"
'page⇒
publication⇒'; init].
			PageMenu add: [(ActionMenu new) string:		"2"
'add box⇒
attributes
display⇒
delete⇒
filing⇒
hardcopy'; init].
			PageMenu add: [(ActionMenu new) string:		"3"
'text
picture
table'; init].
			PageMenu add: [(ActionMenu new) string:		"4"
'next
prev
first
last'; init].
			PageMenu add: [(ActionMenu new) string:		"5"
'remove⇒
keep'; init].
			PageMenu add: [(ActionMenu new) string:		"6"
'renumber
same'; init].
			PageMenu add: [(ActionMenu new) string:		"7"
'file in
file out'; init].
			PageMenu add: [(ActionMenu new) string:		"8"
'add page⇒
attributes
display⇒
filing⇒
hardcopy'; init].
			PageMenu add: [(ActionMenu new) string:		"9"
'empty
duplicate'; init].
			PageMenu add: [(ActionMenu new) string:		"10"
'full scale
half scale⇒';init].
			PageMenu add: [(ActionMenu new) string:		"11"
'facing pages
arbitrary⇒'; init].
			PageMenu add: [(ActionMenu new) string:		"12"
'1 page
2 pages
3 pages
4 pages'; init].
			PageMenu add: [(ActionMenu new) string:		"13"
'file in
file out'; init].
			PageMenu firstmenu←1.
			PageMenu menu: 1 line: 1 tomenu: 2.
				PageMenu menu: 2 line: 1 tomenu: 3.
				PageMenu menu: 2 line: 3 tomenu: 4.
				PageMenu menu: 2 line: 4 tomenu: 5.
					PageMenu menu: 5 line: 1 tomenu: 6.
				PageMenu menu: 2 line: 5 tomenu: 7.
			PageMenu menu: 1 line: 2 tomenu: 8.
				PageMenu menu: 8 line: 1 tomenu: 9.
				PageMenu menu: 8 line: 3 tomenu: 10.
					PageMenu menu: 10 line: 2 tomenu: 11.
						PageMenu menu: 11 line: 2 tomenu: 12.
				PageMenu menu: 8 line: 4 tomenu: 13  ]

\gb9B2314b1B
page [⇑publication◦pageindex]\gb5B1b22B
pageindex [⇑pageindex]\gb10B1b10B
pageindex←pageindex\gb
pagenum [⇑self page pagenum]\gb8B1b18B
pagenumframe [⇑pagenumframe]\gb13B1b13B
publication: publication publicationviewer: publicationviewer\gb
publication←publication\gb
scale [⇑publicationviewer scale]\gb6B1b24B
selectedbox [⇑selectedbox]\gb12B1b12B
selectedbox←selectedbox\gb

Window Protocol\gbf5 
bluebug [⇑false]\gb8B1b6B
close [publicationviewer←publication←selectedbox←attributes←cursorinfo←nil]\gb5i1BI
eachtime
	[frame has: user mp⇒
		[self updateCursor.
		user kbck⇒[⇑self kbd]
		user anybug⇒
			[user redbug⇒[⇑self redbug]
			user yellowbug⇒[⇑self yellowbug]
			user bluebug⇒[⇑self bluebug] ]
		user anykeys⇒[⇑self keyset] ]
	self outside⇒[⇑false]
	user anybug⇒[frame has: user mp⇒[ ] ⇑false]
	user kbck⇒[user kbd. frame flash] "flush typing outside"]\gb10B56b9B34b12B21b15B19b13B20b12B19b6B39b6B37i22I
enter [PageCursor show. self showAttributesSame]\gb5i1BI
firsttime [frame has: user mp⇒[self reset; enter. ⇑self] ⇑false]\gb10B40b5B2b6B
keyset | name "This is a kluge to capture the screen bits for documentation"
	[frame flash. name←'Screen.press' asFileName.
	(dp0 pressfile: name) screenout: (user screenrect) scale: PressScale]\gb6i1BI7i64I
leave [self unshowAttributes]\gb5i1BI
outside [frame has: user mp⇒[⇑false] ⇑true]
\gb8B21b6B2b5B
picked [⇑frame has: user mp]\gb7B1b19B
redbug | pt2
	[pt2←user mp.
	[(self attributesAt: pt2)⇒
		[self attributesEdit]
		(publicationviewer attributesAt: pt2)⇒
			[publicationviewer attributesEdit]
			user leftShiftKey⇒
				[self anchorSelect]
				self markSelect].
	user waitnobug. self redrawDirty]\gb7B
show
	[(frame inset: (¬2⌾¬2)) clear: black. frame color: backcolor mode: storing.
	self redrawAll]\gb6B
windowenter [self showPageNum; show]\gb12B
windowleave\gb
yellowbug | v menu item
	[NormalCursor show.
	[selectedbox⇒
		[(v←BoxMenu bug)≡false⇒[ ]
		menu←BoxMenu find: v◦1. item←v◦2.
		menu
			=1⇒	"main menu"			[item
					=1⇒	"adjust"				[self adjustBox];
					=4⇒	"attributes"			[self flipAttributes];
					=5⇒	"duplicate"			[self addBoxDuplicate];
					=6⇒	"delete"					[self deleteBox] frame flash];
			=2⇒	"change⇒"						[frame flash];
			=3⇒	"change⇒links⇒"		[item
					=1⇒	"continued from"	[self continuedFrom];
					=2⇒	"continued to"		[self continuedTo];
					=3⇒	"unlink"				[self unlink] ];
			=4⇒	"change⇒selection⇒"	[item
					=1⇒	"next"					[self nextBox];
					=2⇒	"prev"					[self prevBox];
					=3⇒	"first"					[self firstBox];
					=4⇒	"last"					[self lastBox];
					=5⇒	"under"					[self underBox] ];
			=5⇒	"contents⇒"				[item
					=1⇒	"get"						[self fillBox];
					=2⇒	"edit"					[self editBox] ] ].
		[(v←PageMenu bug)≡false⇒[ ]
		menu←PageMenu find: v◦1. item←v◦2.
		menu
			=1⇒	"main menu"				[frame flash];
			=2⇒	"page⇒"						[item
					=2⇒	"attributes"			[self flipAttributes];
					=6⇒	"hardcopy"			[self hardcopy] frame flash];
			=3⇒	"page⇒add box⇒"			[self addBox: item];
			=4⇒	"page⇒display⇒"		[item
					=1⇒	"next"					[self nextPage];
					=2⇒	"prev"					[self prevPage];
					=3⇒	"first"					[self firstPage];
					=4⇒	"last"					[self lastPage] ];
			=5⇒	"page⇒delete⇒"			[item
					=1⇒	"remove⇒"				[self deletePage: true renum: true];
					=2⇒	"keep"					[self deletePage: false renum: false] ];
			=6⇒	"delete⇒remove⇒"		[item
					=1⇒	"renumber"			[self deletePage: true renum: true];
					=2⇒	"same"					[self deletePage: true renum: false] ];
			=7⇒	"page⇒filing⇒"			[item
					=1⇒	"file in"					[self fileIn];
					=2⇒	"file out"				[self fileOut] ];
			=8⇒	"publication⇒"			[item
					=2⇒	"attributes"			[publicationviewer flipAttributes];
					=5⇒	"hardcopy"			[publicationviewer hardcopy] frame flash];
			=9⇒	"pub⇒add page⇒"		[item
					=1⇒	"empty"				[self addPage];
					=2⇒	"duplicate"			[self addPageDuplicate] ];
			=10⇒	"pub⇒display⇒"			[item
					=1⇒	"full scale"			[publicationviewer changeViews: 1
															firstpageindex: pageindex] frame flash];
			=11⇒	"display⇒half⇒"			[item
					=1⇒	"facing"				[publicationviewer changeViews: 2
															firstpageindex: pageindex] frame flash];
			=12⇒	"half⇒arbitrary⇒"			[publicationviewer changeViews: (item+2)
															firstpageindex: pageindex];
			=13⇒	"pub⇒filing⇒"			[item
					=1⇒	"file in"					[publicationviewer fileIn];
					=2⇒	"file out"				[publicationviewer fileOut] ] ] ].
	PageCursor show. self redrawDirty]\gb10B13b2B114i11I18i8I31i12I35i11I36i8I43i9I28i15I17i16I32i14I31i8I28i19I16i6I30i5I31i6I32i5I31i8I30i11I19i5I31i6I106i11I26i7I21i12I35i10I40i15I31i15I17i8I29i8I29i9I30i8I29i14I18i9I50i6I53i16I17i10I49i6I52i14I18i9I29i10I29i14I18i12I48i10I53i15I17i7I29i11I38i14I18i14I99i15I18i8I102i17I95i13I18i9I42i10I

Page Manipulation\gbf5 
addPage [publication addPage. self lastPage]\gb8B
addPageDuplicate | box newbox page newpage i
	[publication addPage. page←self page. newpage←publication◦(publication length).
	for⦂ box from: page do⦂
		[newbox←box duplicate: self. newbox page←newpage. newpage add: newbox].
	for⦂ box from: page do⦂
		[newbox←newpage◦(page find: box).
		[(box uplink) and⦂ (i←page find: box uplink)>0⇒[newbox uplink←newpage◦i] ].
		[(box downlink) and⦂ (i←page find: box downlink)>0⇒[newbox downlink←newpage◦i] ] ].
	self lastPage]\gb17B
deletePage: removeFlag renum: renumFlag | numviews firstpageindex delpage delbox i
	[self unshowAttributes.
	numviews←publicationviewer numviews.
	firstpageindex←publicationviewer firstpageindex.
	delpage←self page.
	for⦂ i to: (delpage length) do⦂
		[delbox←delpage◦1. self tidy: delbox. delbox delete. delpage delete: delbox].
	removeFlag⇒
		[ [pageindex=(publication length)⇒
			[firstpageindex←pageindex-1]
			renumFlag⇒
				[for⦂ i from: (pageindex+1) to: (publication length) do⦂
					[(publication◦i) pagenum←(publication◦i) pagenum-1] ] ].
			publication delete: delpage.
			publicationviewer changeViews: numviews firstpageindex: firstpageindex]
		self redrawAll]\gb40B42b2B
firstPage [self newPage: 1]\gb9i1BI
lastPage [self newPage: (publication length)]\gb8i1BI
newPage: newpageindex | view
	[(view←publicationviewer viewShowing: (publication◦newpageindex))⇒
		[frame flash. view frame flash. ⇑false]
		self erasePageNum; unshowAttributes. pageindex←newpageindex. selectedbox←false.
			self windowenter; enter]\gb22B109b6B
nextPage | i
	[for⦂ i from: (pageindex+1) to: (publication length) do⦂ [(self newPage: i)⇒[⇑self] ] ]\gb9B3b2B77b5B
prevPage | i j
	[for⦂ i from: 1 to: (pageindex-1) do⦂ [j←pageindex-i. (self newPage: j)⇒[⇑self] ] ]\gb9B5b2B73b5B

Box Manipulation\gbf5 
addBox: type | v f newbox
	[self unshowAttributes.
	f←Rectangle new fromuser. f←self scaleUp: (f-frame origin).
	newbox←(self page) addBox: type pageviewer: self frame: f.
	self tidyAll: newbox; redrawDirty; boxSelect: newbox]\gb13B
addBoxDuplicate | view pt tic newbox
	[self unshowAttributes.
	publicationviewer mark cursor show. while⦂ (user nobug) do⦂ [pt←user mp].
	[(view←publicationviewer pickedpane: pt)⇒[ ] frame flash. ⇑self].
	pt←view scaleUp: (pt-view frame origin). tic←publicationviewer mark tic.
	newbox←selectedbox duplicate: view.
	newbox frame: ((selectedbox frame) tic: tic moveto: pt).
	(view page) add: newbox.
	view unshowSame; redrawDirty; showSame. self newSelection: newbox]\gb16B180b5B
adjustBox
	[(publicationviewer mark showing)⇒
		[publicationviewer unshowMark. self getPt.
		[(publicationviewer anchor showing) and⦂
			(publicationviewer anchor box)≡(publicationviewer mark box)⇒
				[self stretchBox] self moveBox].
		publicationviewer showMarkAt: cursorinfo] ]\gb11B
continuedFrom | view prevbox
	[prevbox←self getBox. view←cursorinfo◦1.
	[((view and⦂ prevbox) and⦂
		((selectedbox uplink≡false and⦂ selectedbox downlink≡false) or⦂
		(selectedbox uplink≡false and⦂ prevbox downlink≡false)))⇒[ ] frame flash. ⇑self].
	[((prevbox class)≡(selectedbox class))⇒[ ] frame flash. ⇑self].
	selectedbox continuedFrom: prevbox. self newSelection: prevbox]
\gb14B227b5B60b5B
continuedTo | view nextbox
	[nextbox←self getBox. view←cursorinfo◦1.
	[((view and⦂ nextbox) and⦂
		((selectedbox uplink≡false and⦂ selectedbox downlink≡false) or⦂
		(selectedbox downlink≡false and⦂ nextbox uplink≡false)))⇒[ ] frame flash. ⇑self].
	[((nextbox class)≡(selectedbox class))⇒[ ] frame flash. ⇑self].
	selectedbox continuedTo: nextbox. self newSelection: nextbox]
\gb12B227b5B60b5B
deleteBox
	[self unshowAttributes. publicationviewer unshowMark.
	[publicationviewer anchor box≡selectedbox⇒[publicationviewer unshowAnchor] ].
	self unshowSame.
	self tidy: selectedbox. selectedbox delete.
	self page delete: selectedbox. selectedbox←false.
	self showSame]\gb11B
editBox
	[self fullScale⇒
		[self unshowSame. selectedbox edit: self. self redrawDirty; showSame] ]\gb9B
fillBox [self unshowSame. selectedbox fill: self. self redrawDirty; showSame]
\gb8B
firstBox [self newSelection: (selectedbox firstbox)]
\gb9B
getBox
	[user waitnobug. self cursorBox. while⦂ (user nobug) do⦂ [self cursorBox].
	PageCursor show. user waitnobug. ⇑cursorinfo◦3]\gb8B109b13B
getPt
	[user waitnobug. self cursorMark. while⦂ (user nobug) do⦂ [self cursorMark].
	user waitnobug. ⇑cursorinfo◦2]\gb7B94b13B
lastBox [self newSelection: (selectedbox lastbox)]
\gb8B
moveBox | f
	[f←selectedbox frame.
	f tic: (cursorinfo◦4) moveto: (cursorinfo◦2).
	cursorinfo◦2←f pointoftic: (cursorinfo◦4). self newFrame: f]\gb8B
nextBox | b [ [(b←selectedbox downlink)⇒[ ] b←selectedbox]. self newSelection: b]\gb8B
prevBox | b [ [(b←selectedbox uplink)⇒[ ] b←selectedbox]. self newSelection: b]\gb8B
stretchBox | f atic
	[f←(cursorinfo◦3) frame. atic←publicationviewer anchor tic.
	f tic: (cursorinfo◦4) stretchto: (cursorinfo◦2) anchor: atic.
	cursorinfo◦2←f pointoftic: (cursorinfo◦4). self newFrame: f]\gb11B
underBox | page i j box underbox
	[page←self page. j←page find: selectedbox. underbox←false.
	for⦂ i from: (j+1) to: (self page length) do⦂
		[(box←page◦i) intersects: selectedbox⇒[underbox←box] ].
	[underbox⇒[ ] for⦂ i to: (j-1) do⦂
		[(box←page◦i) intersects: selectedbox⇒[underbox←box] ] ].
	underbox⇒
		[self unshowAttributes. selectedbox←false. publicationviewer unshowMark.
		underbox show: self. self boxSelect: underbox] frame flash]\gb9B
unlink [self unshowSame. selectedbox unlink. self redrawDirty; showSame]
\gb7B

Box Scaling/Framing\gbf5 
newFrame: f
	[self unshowSame.
	self tidy: selectedbox. selectedbox frame: f; show: self.
	[(publicationviewer mark showing)⇒
		[publicationviewer mark pt←f pointoftic: (publicationviewer mark tic)] ].
	self showSame]\gb13B
scaleDn: a | scale [scale←self scale. ⇑a*(scale◦1)/(scale◦2)]
\gb11B27b22B
scaleUp: a | scale [scale←self scale. ⇑a*(scale◦2)/(scale◦1)]
\gb11B27b22B

Box Selection\gbf5 
anchorSelect
	[cursorinfo◦5←AnchorCursor.
	(self≡publicationviewer anchor pageviewer) and⦂
		((publicationviewer anchor showing) and⦂
			(((cursorinfo◦2)-publicationviewer anchor pt) abs≤(8⌾8)))⇒
				[publicationviewer unshowAnchor]
				publicationviewer showAnchorAt: cursorinfo]\gb14B
boxAt: pt | box [for⦂ box from: self page do⦂ [box has: pt⇒[⇑box] ]. ⇑false]
\gb10B50b4B5b6B
boxSelect: box | pt tic cursor
	[self unshowAttributes; unshowSame. selectedbox←box.
	[(tic←publicationviewer mark tic)⇒[ ] tic←0]. pt←box pointoftic: tic.
	cursor←Cursor new fromTic: tic. cursorinfo←(self,pt,box,tic,cursor).
	self redrawDirty. publicationviewer showSame; showMarkAt: cursorinfo]\gb15B
markSelect
	[ [(publicationviewer mark pageviewer)⇒
		[publicationviewer mark pageviewer selectedbox←false] ].
	(selectedbox←cursorinfo◦3)⇒
		[(self≡publicationviewer mark pageviewer) and⦂
			((publicationviewer mark showing) and⦂
				(((cursorinfo◦2)-publicationviewer mark pt) abs≤(8⌾8)))⇒
					[self unshowAttributes. publicationviewer unshowMark. selectedbox←false]
					publicationviewer showMarkAt: cursorinfo]
		self unshowAttributes. publicationviewer unshowMark]\gb12B
newSelection: newbox | view newpage newpageindex
	[self unshowAttributes. publicationviewer unshowMark. view←self.
	newpage←newbox page. newpageindex←publication find: newpage.
	[selectedbox and⦂ (selectedbox page≠newpage)⇒
		[(view←publicationviewer viewShowing: newpage)⇒
			[view picked⇒[ ] view takeCursor]
			self newPage: newpageindex. view←self] ].
	selectedbox←false. view boxSelect: newbox]\gb20i1BI
pageTicAt: pt | f tic
	[f←self scaleUp: (frame copy moveto: 0⌾0). tic←f ticofpoint: pt.
	(f inset: 8⌾8) has: pt⇒[⇑false] pt←f pointoftic: tic. ⇑(tic,pt)]\gb14B99b6B24b9B

Page/Box Display\gbf5 
colorPage: i [backcolor←(white, ltgray, gray, dkgray, black)◦i. self enter]\gb13B
erasePageNum | f c
	[ [self fullScale⇒
		[f←(pagenumframe origin copy-(6⌾2)) rect: (pagenumframe corner copy+(3⌾2)).
			c←white]
		f←(pagenumframe origin copy-(6⌾4)) rect: (pagenumframe corner copy+(6⌾2)).
		c←publicationviewer backcolor].
	f clear: c]\gb13B
redraw: allBoxes | box
	[for⦂ box from: self page do⦂
		[(allBoxes or⦂ box dirty) and⦂ selectedbox≠box⇒[box show: self] ].
	selectedbox and⦂ (allBoxes or⦂ selectedbox dirty)⇒[selectedbox show: self] ]\gb17B5b1B
redrawAll [self redraw: true]\gb10B
redrawDirty [self redraw: false]\gb12B
showPageNum | p para textframe ptx xoff yoff
	[p←self pagenum.
	para←(Paragraph new text: (p asString) alignment: 0) allBold.
	textframe←Textframe new para: para frame: (0⌾0 rect: 100⌾100).
	ptx←(textframe rectofchar: para length+1) corner x+7.
	[(self fullScale) or⦂ (p even≡false)⇒[xoff←frame width-ptx] xoff←3]. yoff←¬16.
	textframe put: para at: (frame origin+(xoff⌾yoff)); outline.
	pagenumframe←textframe frame]\gb12B
showSame [publicationviewer showSame. self showAttributesSame]\gb9B
tidy: f | fs box
	[fs←(self scaleDn: f)+frame origin.
	(fs intersect: frame) color: backcolor mode: storing.
	for⦂ box from: self page do⦂
		[(box intersects: f) and⦂ (selectedbox≠box)⇒[box makeDirty] ] ]\gb8B8i1I
tidyAll: f
	[self tidy: f. selectedbox and⦂ (selectedbox intersects: f)⇒[selectedbox makeDirty] ]\gb12B
unshowSame [self unshowAttributesSame. publicationviewer unshowSame]\gb10i1BI

Filing/Hardcopy\gbf5 
fileIn | ext files files2 s name newpage
	[ext←'page'. files←(dp0 filesMatching: '*.'+ext+'.') sort.
	[files empty⇒
		[(Menu new string: '*none*') zbug]
		files2←files transform⦂ s to⦂ (s copy: 1 to: s length-ext length-2).
		name←files◦((Menu new stringFromVector: files2) zbug).
		newpage←nil filinFrom: name. newpage pagenum←(self page) pagenum.
		newpage openAis. "a kluge to open the appropriate ais files"
		(self page) forget. publication◦pageindex←newpage. self windowenter; enter] ]\gb7B361i43I
fileOut | name
	[name←(publicationviewer title)+(self pagenum asString)+'.page'.
	(self page) closeAis. "a kluge to close all appropriate ais files"
	(self page) filoutOn: name.
	(self page) openAis. "a kluge to open all appropriate ais files"]\gb8B96i44I52i43I
hardcopy | name pressfile
	[user displayoffwhile⦂
		[name←(publicationviewer title)+(self pagenum asString)+'.press'.
		pressfile←ScreenPressFile new pressfile: name.
		(self page) hardcopy: pressfile. pressfile close; toPrinter] ]\gb9B

Attributes\gbf5 
attributes | a [a←PageAttributes viewee: self. (a viewer)◦2←(self page) attributes. ⇑a]\gb11B73b2B
attributesAt: pt [attributes⇒[⇑attributes has: pt] ⇑false]\gb17B13b19B2b6B
attributesEdit | f1 f2
	[NormalCursor show.
	[selectedbox⇒[f1←selectedbox frame] ].
	attributes Bug⇒
		[selectedbox⇒
			[f2←selectedbox frame. selectedbox frame: f1. self newFrame: f2]
			self unshowSame; show; showSame] ]\gb15B
flipAttributes [attributes⇒[self unshowAttributes] self showAttributes]\gb15B
showAttributes | pt
	[CrossCursor show. user waitbug. pt←user mp. NormalCursor show.
	[selectedbox⇒
		["Box attributes"	attributes←selectedbox attributes]
		["Page attributes"	attributes←self attributes] ].
	attributes showat: (pt-(attributes frame extent/2))]\gb15B88i16I39i17I
showAttributesSame [attributes⇒[attributes reshow] ]\gb19B
unshowAttributes [attributes⇒[attributes unshow. attributes←false] ]\gb17B
unshowAttributesSame [attributes⇒[attributes unshow] ]\gb21B

Cursor/Mp Control\gbf5 
cursorBox | view pt box tic cursor
	[pt←user mp.
	box←false. tic←publicationviewer mark tic. cursor←CrossCursor.
	[(view←publicationviewer pickedpane: pt)⇒
		[pt←view scaleUp: (pt-view frame origin).
		(box←view boxAt: pt) and⦂ box≠selectedbox⇒
			[cursor←BoxCursor. pt←box inPts pointoftic: tic] ] ].
	cursor show. cursorinfo←(view,pt,box,tic,cursor)]\gb10B24b2B
cursorMark | view pt tic cursor
	[pt←user mp.
	tic←publicationviewer mark tic. cursor←publicationviewer mark cursor.
	[(view←publicationviewer pickedpane: pt)⇒
		[pt←view scaleUp: (pt-view frame origin)] ].
	cursor show. cursorinfo←(self,pt,selectedbox,tic,cursor)]\gb11B20b2B
mp [⇑user mp-frame origin]\gb3B1b21B
updateCursor | pt pt2 box tic cursor v
	[pt2←user mp. pt←self scaleUp: (pt2-frame origin). box←tic←false.
	[(self attributesAt: pt2) or⦂ (publicationviewer attributesAt: pt2)⇒
		[cursor←CrossCursor]
		(box←self boxAt: pt)⇒
			[tic←box ticofpoint: pt. pt←box pointoftic: tic. cursor←Cursor new fromTic: tic]
			(v←self pageTicAt: pt)⇒
				[tic←v◦1. pt←v◦2. cursor←Cursor new fromTic: tic]
				(user leftShiftKey)⇒
					[cursor←AnchorCursor]
					(selectedbox)⇒
						[cursor←BoxCursor]
						cursor←PageCursor].
	cursor show. cursorinfo←(self,pt,box,tic,cursor)]\gb13B23i1I1b1Bi1I
\g
SystemOrganization classify: ↪PageViewer under: 'Publication Editor'.\g
PageViewer classInit\g

"Publication"l15000z20000\gbf5 
Class new title: 'Publication'
	subclassof: Set
	fields: 'firstpagenum pagesize dirty'
	declare: 'PublicationAttributes ';
	asFollows\gbf5 

I am a Set of PublicationPages with:
	firstpagenum		the Integer number of the first page
	pagesize			the Point pagewidth⌾pageheight in points (default size)
	dirty					the flag which indicates whether or not I need to be redrawn\gi

Init/Access\gbf5 
attributesInit "Publication classInit. Publication new attributesInit."
	|	unitviewer integerviewer
		dimensionsmenu
	[	unitviewer←UnitViewer default
			units: (('pts',1) inVector, ('picas',12), ('cm',28.35), ('in',72.0)).
		integerviewer←[AttributeViewer new
			toString:		↪asString;
			fromString⦂	[attributeValue←attributeText asStream integerScan asInteger] ].
		dimensionsmenu←AttributeMenu new.
			dimensionsmenu title: 'width';
				extract: ↪x; assign: 'x←'; viewer: unitviewer copy.
			dimensionsmenu title: 'height';
				extract: ↪y; assign: 'y←'; viewer: unitviewer copy.
		PublicationAttributes←AttributeMenu new.
			PublicationAttributes title: '#Pages';
				extract: ↪numpages; assign: 'numpages←'; viewer: integerviewer copy.
			PublicationAttributes title: '1st Page#';
				extract: ↪firstpagenum; assign: 'firstpagenum←'; viewer: integerviewer copy.
			PublicationAttributes title: 'Page Size⇒';
				extract: ↪pagesize; assign: nil; viewer: dimensionsmenu  ]\gb15B
classInit "Publication classInit."
	[	self attributesInit  ]\gb10B
dirty [⇑dirty]\gb6B1b6B
dirty←dirty\gb
firstpagenum [⇑firstpagenum]\gb13B1b13B
firstpagenum←firstpagenum | i page
	[i←firstpagenum. for⦂ page from: self do⦂ [page pagenum←i. i←i+1]. dirty←true]\gb26B8b2B
forget | page [for⦂ page from: self do⦂ [page forget]. firstpagenum←pagesize←nil]\gb7B
init [firstpagenum←1. pagesize←612⌾792. dirty←false]\gb5B
lastpagenum [⇑(firstpagenum+(self numpages)-1)]\gb12B1b33B
numpages [⇑self length]\gb9B1b12B
numpages←n | i l
	[l←self numpages.
	(n≤0 or⦂ n≡l)⇒
		[user screenrect flash]
		dirty←true.
		(n<l)⇒
		[for⦂ i from: n+1 to: (l) do⦂ [self◦i forget. self deleteI: i] ]
		for⦂ i from: (l+1) to: n do⦂ [self addPage] ]\gb11B
pagesize [⇑pagesize]\gb9B1b9B
pagesize←pagesize\gb

Adding Pages\gbf5 
addPage | page
	[page←PublicationPage default init: (self lastpagenum+1).
	self add: page. ⇑page]\gb8B6b2B75b5B

Attributes/Hardcopy\gbf5 
attributes [⇑PublicationAttributes viewee: self]\gb11B1b35B
hardcopy: pressfile | page
	[for⦂ page from: self do⦂ [page hardcopy: pressfile. pressfile page] ]\gb20B
\g
SystemOrganization classify: ↪Publication under: 'Publication Editor'.\g
Publication classInit\g

"PublicationBox"l15000z20000\gbf5 
Class new title: 'PublicationBox'
	subclassof: Rectangle
	fields: 'page uplink downlink margin color border bordercolor dirty file'
	declare: 'BoxAttributes ';
	asFollows\gbf5 

I am a Rectangle on a PublicationPage with content-independent information:
	page			the PublicationPage on which I reside
	uplink		the PublicationBox above me (from which my contents flow)
	downlink	the PublicationBox below me (to which my contents flow)
	margin		the Rectangle left⌾top rect: right⌾bottom in points
	color			the Integer color of my frame (white,ltgray,gray,dkgray,black)
	border		the Integer width in points of my border (>0⇒inside frame)
	bordercolor	the Integer color of my border (white,ltgray,gray,dkgray,black)
	dirty			the flag which indicates whether or not I need to be redrawn
	file			the input FileStream (false if none)\gi

Init/Access\gbf5 
attributesInit "PublicationBox classInit. PublicationBox new attributesInit."
	|	unitviewer stringviewer colorviewer
		dimensionsmenu locationmenu marginsmenu colorbordermenu GeneralAttributes
	"	unitviewer←UnitViewer default units:
			(('micas',1) inVector, ('pts',35.3), ('picas',423.3), ('cm',899.75), ('in',2540.0))."
	[	unitviewer←UnitViewer default
			units: (('pts',1) inVector, ('picas',12), ('cm',28.35), ('in',72.0)).
		stringviewer←[AttributeViewer new
			toString:		↪asString;
			fromString⦂	[attributeValue←attributeText] ].
		colorviewer←[AttributeViewer new
			menu: [ActionMenu new
				stringFromVector: ('white','light gray','gray','dark gray','black'); init;
				action←(white,ltgray,gray,dkgray,black)] ].
		dimensionsmenu←AttributeMenu new.
			dimensionsmenu title: 'width';
				extract: ↪width; assign: 'width←'; viewer: unitviewer copy.
			dimensionsmenu title: 'height';
				extract: ↪height; assign: 'height←'; viewer: unitviewer copy.
		locationmenu←AttributeMenu new.
			locationmenu title: 'horizontal';
				extract: ↪originx; assign: 'originx←'; viewer: unitviewer copy.
			locationmenu title: 'vertical';
				extract: ↪originy; assign: 'originy←'; viewer: unitviewer copy.
		marginsmenu←AttributeMenu new.
			marginsmenu title: 'top';
				extract: ↪topMargin; assign: 'topMargin←'; viewer: unitviewer copy.
			marginsmenu title: 'bottom';
				extract: ↪botMargin; assign: 'botMargin←'; viewer: unitviewer copy.
			marginsmenu title: 'left';
				extract: ↪leftMargin; assign: 'leftMargin←'; viewer: unitviewer copy.
			marginsmenu title: 'right';
				extract: ↪rightMargin;	assign: 'rightMargin←'; viewer: unitviewer copy.
		colorbordermenu←AttributeMenu new.
			colorbordermenu title: 'color';
				extract: ↪color; 	assign: 'color←'; viewer: colorviewer copy.
			colorbordermenu title: 'border';
				extract: ↪border; assign: 'border←'; viewer: unitviewer copy.
			colorbordermenu title: 'bordercolor';
				extract: ↪bordercolor; assign: 'bordercolor←'; viewer: colorviewer copy.
		GeneralAttributes←AttributeMenu new.
			GeneralAttributes title: 'Type';
				extract: ↪type; assign: nil; viewer: stringviewer copy.
			GeneralAttributes title: 'From File';
				extract: ↪filename; assign: nil; viewer: stringviewer copy.
			GeneralAttributes title: 'Dimensions⇒';
				extract: ↪itself; assign: nil; viewer: dimensionsmenu.
			GeneralAttributes title: 'Location⇒';
				extract: ↪itself; assign: nil; viewer: locationmenu.
			GeneralAttributes title: 'Margins⇒';
				extract: ↪itself; assign: nil; viewer: marginsmenu.
			GeneralAttributes title: 'Color/Border⇒';
				extract: ↪itself; assign: nil; viewer: colorbordermenu.
		BoxAttributes←AttributeMenu new.
			BoxAttributes title: 'General⇒';
				extract: ↪itself; assign: nil; viewer: GeneralAttributes.
			BoxAttributes title: 'Specific⇒';
				extract: ↪itself; assign: nil; viewer: nil  ]\gb15B
border [⇑border]\gb7B1b7B
bordercolor [⇑bordercolor]\gb12B1b12B
bordercolor←bordercolor\gb
border←border\gb
botMargin [⇑margin corner y]\gb10B1b16B
botMargin←b [margin corner y←b]\gb12B
classInit "PublicationBox classInit."
	[	self attributesInit  ]\gb10B
color [⇑color]\gb6B1b6B
color←color\gb
dirty [⇑dirty]\gb6B1b6B
dirty←dirty\gb
downlink [⇑downlink]\gb9B1b9B
downlink←downlink\gb
file [⇑file]\gb5B1b5B
filename [file⇒[⇑file copy: 1 to: (file length-1)] ⇑'-no file-']\gb9B7b33B2b12B
file←file\gb
firstbox | box [box←self. until⦂ box uplink≡false do⦂ [box←box uplink]. ⇑box]\gb9B63b4B
lastbox | box [box←self. until⦂ box downlink≡false do⦂ [box←box downlink]. ⇑box]\gb8B67b4B
leftMargin [⇑margin origin x]\gb11B1b16B
leftMargin←l [margin origin x←l]\gb13B
makeClean [dirty←false]\gb10B
makeDirty [dirty←true]\gb10B
margin [⇑margin]\gb7B1b7B
margin←margin\gb
originx [⇑origin x]\gb8B1b9B
originx←originx [self moveto: originx⌾(self originy)]\gb16B
originy [⇑origin y]\gb8B1b9B
originy←originy [self moveto: (self originx)⌾originy]\gb16B
page [⇑page]\gb5B1b5B
page←page\gb
rightMargin [⇑margin corner x]\gb12B1b16B
rightMargin←r [margin corner x←r]\gb14B
topMargin [⇑margin origin y]\gb10B1b16B
topMargin←t [margin origin y←t]\gb12B
type | t [t←self class asString. ⇑t copy: 7 to: (t length-3)]\gb5B28b27B
uplink [⇑uplink]\gb7B1b7B
uplink←uplink\gb

Common Box Methods\gbf5 
attributes | a [a←BoxAttributes viewee: self. (a viewer)◦2←self attributesS. ⇑a]\gb11B66b2B
create: pageviewer page: page frame: f
	[uplink←downlink←false. margin←0⌾0 rect: 0⌾0. color←white.
	border←0. bordercolor←white. file←false. origin←corner←0⌾0. self frame: f]
\gb40B
delete [self unlink. page←margin←color←border←bordercolor←dirty←file←nil]\gb7B
duplicate: pageviewer | box
	[box←(self class) copy: self. box origin: origin copy corner: corner copy.
	box page←pageviewer page. box uplink←false. box downlink←false.
	box margin←margin copy. box file←false. box dirty←true. ⇑box]
\gb22B204b4B
edit: pageviewer [NormalCursor show]\gb17B
fill: pageviewer | ext files files2 s name
	[ext←self type. files←(dp0 filesMatching: '*.'+ext+'.') sort.
	[files empty⇒
		[(Menu new string: '*none*') zbug. file←dirty←false]
		files2←files transform⦂ s to⦂ (s copy: 1 to: s length-ext length-2).
		file←files◦((Menu new stringFromVector: files2) zbug). dirty←true] ]\gb17B25b2B
frame: f [self origin: (f origin copy) corner: (f corner copy); fixFrame]\gb9B
hardcopy: pressfile | f b ox oy cx cy w h
	[f←self borderFrame inMicas. b←border inMicas.
	ox←f origin x-b. oy←f origin y-b. cx←f corner x. cy←f corner y.
	w←(f width)+1+(b*2). h←(f height)+1+(b*2).
	bordercolor=black⇒
		[pressfile setcolor: 1.
		pressfile setp: ox⌾oy; showrectwidth: w height: b.
		pressfile setp: ox⌾oy; showrectwidth: b height: h.
		pressfile setp: ox⌾cy; showrectwidth: w height: b.
		pressfile setp: cx⌾oy; showrectwidth: b height: h] ]\gb20B21b2B
show: pageviewer | fs fb
	[fs←self scaledFrame: pageviewer. fb←self borderFrame: pageviewer.
	(fs intersect: pageviewer frame) clear: color.
	(fb intersect: pageviewer frame) border: border color: bordercolor. dirty←false]\gb17B

Box Linking\gbf5 
continuedFrom: prevbox | nextbox "Assume prevbox is not false"
	[ [(nextbox←prevbox downlink)⇒[nextbox uplink←self. downlink←nextbox] ].
	prevbox downlink←self. uplink←prevbox]
\gb23B10i29bI2B
continuedTo: nextbox | prevbox "Assume nextbox is not false"
	[ [(prevbox←nextbox uplink)⇒[prevbox downlink←self. uplink←prevbox] ].
	downlink←nextbox. nextbox uplink←self]
\gb21B10i29bI2B
unlink | prevbox nextbox
	[prevbox←uplink. nextbox←downlink.
	[prevbox⇒[prevbox downlink←nextbox] ].
	[nextbox⇒[nextbox uplink←prevbox] ].
	uplink←downlink←false]\gb7B17b2B

Box Scaling/Framing\gbf5 
borderFrame | f [f←self inset: border⌾border. ⇑f]\gb12B3b1B30b2B
borderFrame: pageviewer | f
	[f←(pageviewer scaleDn: (self borderFrame))+pageviewer frame origin. ⇑f]\gb24B74b2B
fixFrame | f w h ox oy cx cy
	[w←page pagesize x. h←page pagesize y.
	[self width≤0⇒[self width←32] ]. [self height≤0⇒[self height←32] ].
	[self width>w⇒[self width←w] ]. [self height>h⇒[self height←h] ].
	ox←origin x. oy←origin y.
	[ox<0⇒[ox←0] ]. [oy<0⇒[oy←0] ]. self moveto: ox⌾oy.
	cx←corner x. cy←corner y.
	[cx>w⇒[ox←ox-cx+w] ]. [cy>h⇒[oy←oy-cy+h] ]. self moveto: ox⌾oy]\gb9B19i1I
frame | f [f←Rectangle new origin: origin copy corner: corner copy. ⇑f]\gb6B3b1B58b2B
marginFrame | f [f←(origin+(margin origin)) rect: (corner-(margin corner)). ⇑f]\gb12B64b2B
marginFrame: pageviewer | f
	[f←(pageviewer scaleDn: (self marginFrame))+pageviewer frame origin. ⇑f]\gb24B3b1B70b2B
newLocation: oldf | f [f←self frame. ⇑(f origin≠oldf origin)]\gb18B19b23B
newSize: oldf | f [f←self frame. ⇑(f width≠oldf width) or⦂ (f height≠oldf height)]\gb14B19b48B
scaledFrame: pageviewer | f
	[f←(pageviewer scaleDn: (self frame))+pageviewer frame origin. ⇑f]\gb24B68b2B
scaleDn: scale [⇑(self frame)*(scale◦1)/(scale◦2)]
\gb15B1b33B
scaleUp: scale [⇑(self frame)*(scale◦2)/(scale◦1)]
\gb15B1b33B
\g
SystemOrganization classify: ↪PublicationBox under: 'Publication Editor'.\g
PublicationBox classInit\g

"AisBox"l15000z20000\gbf5 
Class new title: 'AisBox'
	subclassof: PublicationBox
	fields: 'halftoner'
	declare: 'AisAttributes ';
	asFollows\gbf5 

I am a PublicationBox whose content-dependent information consists of a
	half-toned image read from an Ais file:
	halftoner		the HalfToner for halftoning/cropping/displaying the image\gi

Init/Access\gbf5 
attributesInit "AisBox classInit. AisBox new attributesInit."
	|	unitreader1 unitreader2
	[	unitreader1←UnitViewer new readonly units: (('pixels',1) inVector).
		unitreader2←UnitViewer new readonly units: (('lines',1) inVector).
		AisAttributes←AttributeMenu new.
			AisAttributes title: 'width';
				extract: ↪widthPixels; assign: nil; viewer: unitreader1 copy.
			AisAttributes title: 'height';
				extract: ↪heightLines; assign: nil; viewer: unitreader2 copy  ]\gb15B
classInit "AisBox classInit."
	[	self attributesInit  ]\gb10B
halftoner [⇑halftoner]\gb10B1b10B
halftoner←halftoner\gb
heightLines [halftoner⇒[⇑halftoner nlines] ⇑0]\gb12B12b17B2b2B
widthPixels [halftoner⇒[⇑halftoner npix] ⇑0]\gb12B12b15B2b2B

Common Box Methods\gbf5 
attributesS [⇑AisAttributes viewee: self]\gb12B1b27B
create: pageviewer page: page frame: f
	[super create: pageviewer page: page frame: f.
	"self leftMargin←5. self rightMargin←5." halftoner←false]\gb40B
delete: pageviewer
	[super delete: pageviewer.
	halftoner←nil]\gb20B
duplicate: pageviewer | box
	[box←super duplicate: pageviewer.
	box halftoner←false. ⇑box]
\gb22B63b4B
edit: pageviewer | f
	[super edit: pageviewer.
	halftoner⇒[halftoner setup: (dp0 file: file)] ]\gb17B3b2B
fill: pageviewer
	[super fill: pageviewer.
	halftoner←HalfToner new. halftoner rect←self marginFrame+PubOffset.
	halftoner setup: (dp0 file: file)]\gb18B
frame: f | oldf
	[oldf←self frame. super frame: f.
	file⇒
		[halftoner rect←self marginFrame+PubOffset.
		self newSize: oldf⇒[halftoner setup: (dp0 file: file)] ] ]\gb9B
hardcopy: pressfile | f
	[super hardcopy: pressfile.
	halftoner⇒
		[f←halftoner rect. halftoner rect←self marginFrame.
		pressfile pictureinit. halftoner intoPress: pressfile file: file.
		halftoner rect←f] ]\gb20B3b2B
show: pageviewer | f
	[super show: pageviewer.
	pageviewer fullScale and⦂ file⇒[halftoner doFile] ]\gb17B
\g
SystemOrganization classify: ↪AisBox under: 'Publication Editor'.\g
AisBox classInit\g

"PublicationPage"l15000z20000\gbf5 
Class new title: 'PublicationPage'
	subclassof: Set
	fields: 'pagenum pagesize margin'
	declare: 'PageAttributes ';
	asFollows\gbf5 

I am a Set of PublicationBoxes with:
	pagenum	the Integer page number which appears on the hardcopy
	pagesize	the Point pagewidth⌾pageheight in points
	margin		the Rectangle left⌾top rect: right⌾bottom in points\gi

Init/Access\gbf5 
attributesInit "PublicationPage classInit. PublicationPage new attributesInit."
	|	unitviewer unitreader colorviewer
		sizemenu marginsmenu
	[	unitviewer←UnitViewer default
			units: (('pts',1) inVector, ('picas',12), ('cm',28.35), ('in',72.0)).
		unitreader←UnitViewer new readonly.
		colorviewer←[AttributeViewer new
			menu: [ActionMenu new
				stringFromVector: ('white','light gray','gray','dark gray','black'); init;
				action←(white,ltgray,gray,dkgray,black)] ].
		sizemenu←AttributeMenu new.
			sizemenu title: 'width';
				extract: ↪x; assign: 'x←'; viewer: unitviewer copy.
			sizemenu title: 'height';
				extract: ↪y; assign: 'y←'; viewer: unitviewer copy.
		marginsmenu←AttributeMenu new.
			marginsmenu title: 'top';
				extract: ↪topMargin; assign: 'topMargin←'; viewer: unitviewer copy.
			marginsmenu title: 'bottom';
				extract: ↪botMargin; assign: 'botMargin←'; viewer: unitviewer copy.
			marginsmenu title: 'left';
				extract: ↪leftMargin; assign: 'leftMargin←'; viewer: unitviewer copy.
			marginsmenu title: 'right';
				extract: ↪rightMargin; assign: 'rightMargin←'; viewer: unitviewer copy.
		PageAttributes←AttributeMenu new.
			PageAttributes title: 'Page#';
				extract: ↪pagenum; assign: nil; viewer: unitreader copy.
			PageAttributes title: '#Boxes';
				extract: ↪numboxes; assign: nil; viewer: unitreader copy.
			PageAttributes title: 'Size⇒';
				extract: ↪pagesize; assign: nil; viewer: sizemenu.
			PageAttributes title: 'Margins⇒';
				extract: ↪itself; assign: nil; viewer: marginsmenu  ]\gb15B
botMargin [⇑margin corner y]\gb10B1b16B
botMargin←b [margin corner y←b]\gb12B1b17B
classInit "PublicationPage classInit."
	[	self attributesInit  ]\gb10B
forget | box [for⦂ box from: self do⦂ [box delete]. pagenum←pagesize←margin←nil]\gb7B
init: pagenum [pagesize←612⌾792. margin←0⌾0 rect: 0⌾0]\gb14B
leftMargin [⇑margin origin x]\gb11B1b16B
leftMargin←l [margin origin x←l]\gb13B1b17B
margin [⇑margin]\gb7B1b7B
margin←margin\gb
numboxes [⇑self length]\gb9B1b12B
pagenum [⇑pagenum]\gb8B1b8B
pagenum←pagenum\gb
pagesize [⇑pagesize]\gb9B1b9B
pagesize←pagesize\gb
rightMargin [⇑margin corner x]\gb12B1b16B
rightMargin←r [margin corner x←r]\gb14B1b17B
topMargin [⇑margin origin y]\gb10B1b16B
topMargin←t [margin origin y←t]\gb12B1b17B

Adding Boxes\gbf5 
addBox: i pageviewer: pageviewer frame: f | type newbox
	[type←(TextBox,AisBox,TableBox)◦i.
	newbox←type new create: pageviewer page: self frame: f.
	self add: newbox. ⇑newbox]\gb42B126b7B
closeAis | box
	[for⦂ box from: self do⦂
		[(box is: AisBox) and⦂ (box file)⇒
			[box halftoner strm close. box halftoner strm←nil] ] ]\gb9B
openAis | box
	[for⦂ box from: self do⦂
		[(box is: TextBox)⇒[box markCorrupted]
		(box is: AisBox) and⦂ (box file)⇒
			[box halftoner strm←dp0 file: (box file). box halftoner strm readonly] ] ]\gb8B

Attributes/Hardcopy\gbf5 
attributes [⇑PageAttributes viewee: self]\gb11B1b28B
hardcopy: pressfile | box [for⦂ box from: self do⦂ [box hardcopy: pressfile] ]\gb20B
\g
SystemOrganization classify: ↪PublicationPage under: 'Publication Editor'.\g
PublicationPage classInit\g

"PublicationViewer"l15000z20000\gbf5 
Class new title: 'PublicationViewer'
	subclassof: PanedWindow
	fields: 'publication pageviews numviews scale backcolor attributes anchor mark grid measure measureinfo measureframe measureXY gridXY rectG rectM rectA dirty'
	declare: 'PageTemplates MarkOffset MeasureOffset PointMenu GridOffset GOffset MOffset CrossCursor AOffset PublicationAttributes Scale PublicationCursor AnchorCursor PublicationMenu ';
	asFollows\gbf5 

I am a PanedWindow whose panes are PageViewers:
	publication		the Publication which I view
	pageviews			the Set of PageViewers which are my panes
	numviews			the Integer number of panes that I currently display (1-4)
	scale					the Vector (m,n) which means (m/n)
	backcolor			the Integer color which fills my window (default is white)
	attributes			the AttributeMenu currently being displayed (false if none)
	anchor				the Coord which indicates where my anchor currently is
	mark					the Coord which indicates where my mark currently is
	grid					the Grid whose origin is at anchor pt (may or may not be active)
	measure			the Point in points distance between my anchor and mark
	measureinfo		the Textframe for displaying my measure/grid info
	measureframe	the Rectangle in which my measureinfo is displayed
	markXY				the AttributeHMenu for displaying/editing mark x-y coords
	gridXY				the AttributeHMenu for displaying/editing grid x-y scale
	rectG					the Rectangle in measureinfo for turning on/off my grid
	rectM				the Rectangle in measureinfo for taking a measure
	rectA					the Rectangle in measureinfo for applying my measure
	dirty					the flag which indicates whether or not I need to be redrawn\gi

Init/Access\gbf5 
anchor [⇑anchor]\gb7B1b7B
attributesInit "PublicationViewer classInit. PublicationViewer new attributesInit."
	|	unitviewer displayviewer colorviewer
		ViewerAttributes
	[	unitviewer←UnitViewer default
			units: (('pts',1) inVector, ('picas',12), ('cm',28.35), ('in',72.0)).
		displayviewer←[AttributeViewer new
			menu: [ActionMenu new
				stringFromVector: ('full scale','facing pages','1','2','3','4'); init;
				action←(1,2,3,4,5,6)] ].
		colorviewer←[AttributeViewer new
			menu: [ActionMenu new
				stringFromVector: ('white','light gray','gray','dark gray','black'); init;
				action←(white,ltgray,gray,dkgray,black)] ].
		ViewerAttributes←AttributeMenu new.
			ViewerAttributes title: 'Display';
				extract: ↪numviews; assign: 'numviews←'; viewer: displayviewer copy.
			ViewerAttributes title: 'Background Color';
				extract: ↪backcolor; assign: 'backcolor←'; viewer: colorviewer copy.
		PublicationAttributes←AttributeMenu new.
			PublicationAttributes title: 'Viewer⇒';
				extract: ↪itself; assign: nil; viewer: ViewerAttributes.
			PublicationAttributes title: 'Publication⇒';
				extract: ↪publication; assign: nil; viewer: nil  ]\gb15B
backcolor [⇑backcolor]\gb10B1b10B
backcolor←backcolor [dirty←true]\gb20B
classInit "PublicationViewer classInit."
	[	self cursorInit; menuInit; attributesInit; templatesInit; measureInit  ]\gb10B
cursorInit "PublicationViewer classInit. PublicationViewer new cursorInit."
	[	PublicationCursor←Cursor new fromtext: '
0000011111111100
0000010000000100
0001111111110100
0001000000010100
0111111111010100
0100000001010100
0101101101010100
0100000001010100
0101101101010100
0100000001010100
0101111101011100
0100000001010000
0101111101110000
0100000001000000
0111111111000000
0000000000000000' offset: 8⌾8.
		CrossCursor←Cursor new fromtext: '
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
0000000010000000' offset: 8⌾8.
		AnchorCursor←Cursor new fromtext: '
0000000000000000
0110000000000011
0111000000000111
0011100000001110
0001110000011100
0000111000111000
0000011101110000
0000001111100000
0000000111000000
0000001111100000
0000011101110000
0000111000111000
0001110000011100
0011100000001110
0111000000000111
0110000000000011' offset: 8⌾8  ]\gb11B
dirty [⇑dirty]\gb6B1b6B
dirty←dirty\gb
firstpageindex [⇑(panes◦1) pageindex]\gb15B1b20B
init: numviews | i "Initialize with the specified number of empty pages"
	[publication←Publication new default init.
	for⦂ i to: numviews do⦂ [publication addPage].
	self initPageViews.
	self views: numviews title: 'New-Publication' firstpageindex: 1.
	self showInfo]

"
	user killWindows: PublicationViewer.
	user restartup: (PublicationViewer new init: 1).
	user restartup: (PublicationViewer new init: 2).
	user restartup: (PublicationViewer new init: 3).
	user restartup: (PublicationViewer new init: 4).

"\gb15B4i53bI2B
init: numviews fromFile: title "Read in the publication from the specified file"
	[publication←nil filinFrom: (title+'.pub').
	self initPageViews.
	self views: numviews title: title firstpageindex: 1.
	self showInfo]

"
	user killWindows: PublicationViewer.
	user restartup: (PublicationViewer new init: 1 fromFile: 'Sample1').

"\gb31Bi49bI2B
initPageViews | i view
	[backcolor←white. attributes←false. measure←0⌾0. grid←Grid init.
	grid window: (PageTemplates◦1◦1+PubOffset); grid: 10⌾10; at: 0⌾0.
	anchor←Coord init. anchor cursor←AnchorCursor.
	mark←Coord init. mark tic←0. mark cursor←Cursor new fromTic: 0.
	pageviews←Set new default.
	for⦂ i to: 4 do⦂
		[view←PageViewer new publication: publication publicationviewer: self.
		pageviews add: view] ]\gb14B
mark [⇑mark]\gb5B1b5B
measureframe [⇑measureframe]\gb13B1b13B
measureinfo [⇑measureinfo]\gb12B1b12B
measureInit "PublicationViewer classInit. PublicationViewer new measureInit."
	|	unitviewer
	[	unitviewer←[UnitViewer default
			units: (('pts',1) inVector, ('picas',12), ('cm',28.35), ('in',72.0));
			menu: [ActionMenu new string: 'zero'; init; action←0 asVector] ].
		PointMenu←AttributeHMenu init.
		PointMenu title: 'x';
			extract: ↪x; assign: 'x←'; viewer: unitviewer copy.
		PointMenu title: 'y';
			extract: ↪y; assign: 'y←'; viewer: unitviewer copy.
	"	MOffset←10⌾¬1. MeasureOffset←40⌾1. GOffset←210⌾¬1. GridOffset←240⌾1.
		AOffset←420⌾¬1."
		MOffset←60⌾¬1. MeasureOffset←90⌾1. AOffset←370⌾¬1.
		DefaultTextStyle setfont: 15 fromfile: 'PubIcon11'  ]\gb11i1BI
menuInit "PublicationViewer classInit. PublicationViewer new menuInit."
	[	PublicationMenu←MenuSet new default init.
			PublicationMenu add: [(ActionMenu new) string:	"1"
'attributes
views⇒
filing⇒
hardcopy'; init].
			PublicationMenu add: [(ActionMenu new) string:	"2"
'full scale
half scale⇒';init].
			PublicationMenu add: [(ActionMenu new) string:	"3"
'facing pages
arbitrary⇒'; init].
			PublicationMenu add: [(ActionMenu new) string:	"4"
'1 page
2 pages
3 pages
4 pages'; init].
			PublicationMenu add: [(ActionMenu new) string:	"5"
'file in
file out'; init].
			PublicationMenu firstmenu←1.
			PublicationMenu menu: 1 line: 2 tomenu: 2.
				PublicationMenu menu: 2 line: 2 tomenu: 3.
					PublicationMenu menu: 3 line: 2 tomenu: 4.
			PublicationMenu menu: 1 line: 3 tomenu: 5  ]\gb9B
numviews [⇑numviews]\gb9B1b9B
numviews←numviews [dirty←true]\gb18B
pageheight [⇑(PageTemplates◦1◦1) height+1]\gb11B1b29B
pagewidth [⇑(PageTemplates◦1◦1) width+1]\gb10B1b28B
panes [⇑panes]\gb6B1b6B
publication [⇑publication]\gb12B1b12B
scale [⇑scale]\gb6B1b6B
Spy
[
spy every: 10; on⦂ [Z←PublicationViewer new init: 4]; report: 'AltoInit.spy'; close.
spy every: 10; on⦂ [Z showInfo]; report: 'AltoMeasureInfo.spy'; close.
spy every: 10; on⦂ [Z show]; report: 'AltoShowPub.spy'; close.
spy every: 10; on⦂ [Z enter]; report: 'AltoEnterPub.spy'; close.
spy every: 10; on⦂ [for⦂ Y to: 5 do⦂ [(Z panes◦1) windowenter] ]; report: 'AltoShowPage.spy'; close.
]\gb4B1b1B
templatesInit "PublicationViewer classInit. PublicationViewer new templatesInit."
	| sc sc2 sc3 width height swidth sheight marginx marginy topl topr botl botr
	[	"The following five parameters may be changed:"
		Smalltalk declare: ↪PubOffset.
		PubOffset←4⌾16. width←600. height←792. sc2←(5,11). sc3←(5,11).
		"Initialize a vector of Scale factors"
		Scale←Vector new: 3.
		Scale◦1←(1,1). Scale◦2←sc2. Scale◦3←sc3.
		"Initialize a vector of PageTemplates"
		PageTemplates←Vector new: 3.
		PageTemplates◦1←(0⌾0 rect: (width-1)⌾(height-1)) asVector.
		sc←Scale◦2. swidth←width*(sc◦1)/(sc◦2). sheight←height*(sc◦1)/(sc◦2).
		marginx←(width-(swidth*2))/2-1. marginy←(height-(sheight*2))/3.
		topl←marginx⌾marginy rect: (swidth+marginx)⌾(sheight+marginy).
		topr←topl+((swidth+2)⌾0).
		botl←topl+(0⌾(sheight+marginy)).
		botr←topr+(0⌾(sheight+marginy)).
		PageTemplates◦2←(topl,topr,botl,botr).
		sc←Scale◦3. swidth←width*(sc◦1)/(sc◦2). sheight←height*(sc◦1)/(sc◦2).
		marginx←(width-(swidth*2))/3. marginy←(height-(sheight*2))/3.
		topl←marginx⌾marginy rect: (swidth+marginx)⌾(sheight+marginy).
		topr←topl+((swidth+marginx)⌾0).
		botl←topl+(0⌾(sheight+marginy)).
		botr←topr+(0⌾(sheight+marginy)).
		PageTemplates◦3←(topl,topr,botl,botr)  ]\gb14B149i47I101i38I26u7U8u7U6u7U8i41I31u15U347u15U331u15U

Window Protocol\gbf5 
bluebug [NormalCursor show. ⇑super bluebug]\gb8B20b14B
close | pane
	[anchor forget. mark forget. publication forget.
	for⦂ pane from: panes do⦂ [pane close].
	publication←pageviews←scale←nil. attributes←false.
	anchor←mark←grid←measure←measureinfo←measureframe←nil.
	measureXY←gridXY←rectG←rectM←rectA←dirty←nil]\gb6B
eachtime | pane
	[frame has: user mp⇒
		[self updateCursor.
		user kbck⇒[⇑self kbd]
		user anybug⇒
			[user redbug⇒[⇑self redbug]
			user yellowbug⇒[self pickedpane⇒[ ] ⇑self yellowbug]
			user bluebug⇒[⇑self bluebug] ]
		user anykeys⇒[⇑self keyset]
		for⦂ pane from: panes do⦂ [pane startup] ]
	self outside⇒[ ]
	user anybug⇒[frame has: user mp⇒[ ] ⇑false]
	user kbck⇒[user kbd. frame flash] "flush typing outside" ]\gb9B64b9B34b12B40b16B19b13B20b12B62b1B39b6B37i22I
editTitle [super editTitle. self showInfo. title←titlepara text]\gb9i1BI
enter | pane
	[self show.
	for⦂ pane from: panes do⦂ [pane windowenter].
	self showSame. self showAttributesSame]\gb6B
firsttime [frame has: user mp⇒[self reset; enter; showInfo. ⇑self] ⇑false]\gb9i1BI50b5B2b6B
frame: frame | tStream orig pane
	[tStream←templates asStream. orig←frame origin.
	for⦂ pane from: panes do⦂ [pane frame←(tStream next)+orig] ]\gb13B
keyset | name "This is a kluge to capture the screen bits for documentation"
	[frame flash. name←'Screen.press' asFileName.
	(dp0 pressfile: name) screenout: (user screenrect) scale: PressScale]\gb7B7i62I
leave | pane
	[for⦂ pane from: panes do⦂ [pane windowleave].
	self unshowAttributes. NormalCursor show]\gb6B
newframe [self frame: (PageTemplates◦1◦1+PubOffset); takeCursor]\gb9B
outside | pt
	[pt←user mp.
	titleframe window has: pt⇒
		[NormalCursor show. [user anybug⇒[self editTitle] ]. ⇑true]
	measureframe has: pt⇒
		[NormalCursor show. [user anybug⇒[self editInfo] ]. ⇑true] ⇑false]\gb8B102b5B79b5B2b6B
pickedpane | pane [for⦂ pane from: panes do⦂ [pane picked⇒[⇑pane] ] ⇑false]\gb11B48b5B4b6B
pickedpane: pt | pane
	[for⦂ pane from: panes do⦂ [pane frame has: pt⇒[⇑pane] ] ⇑false]\gb15B56b5B4b6B
redbug
	[ [(self attributesAt: user mp)⇒[self attributesEdit] ].
	user waitnobug. self redrawDirty]
\gb8B
show | pane
	[(frame inset: (¬2⌾¬2)) clear: black. frame color: backcolor mode: storing.  
	[growing⇒[ ] self showtitle].
	for⦂ pane from: panes do⦂ [pane outline] ]\gb5B
yellowbug | v menu item
	[NormalCursor show.
	(v←PublicationMenu bug)≡false⇒[ ]
	menu←PublicationMenu find: v◦1. item←v◦2.
	menu
		=1⇒	"main menu"		[item
				=1⇒	"attributes"		[self flipAttributes];
				=4⇒	"hardcopy"		[self hardcopy] frame flash];
		=2⇒	"views⇒"				[item
				=1⇒	"full scale⇒"		[self changeViews: 1] frame flash];
		=3⇒	"views⇒half⇒"		[item
				=1⇒	"facing"			[self changeViews: 2] frame flash];
		=4⇒	"half⇒arbitrary⇒"		[self changeViews: (item+2)];
		=5⇒	"filing⇒"				[item
				=1⇒	"file in"				[self fileIn];
				=2⇒	"file out"			[self fileOut] ].
	self redrawDirty]\gb10B125i11I16i12I33i10I38i8I18i14I43i13I16i8I45i17I38i9I18i9I27i10I

Pane Manipulation\gbf5 
changeViews: numviews
	[self changeViews: numviews firstpageindex: self firstpageindex]
\gb23B
changeViews: numviews firstpageindex: firstpageindex
	[(panes◦1) erasePageNum.
	self views: numviews title: title firstpageindex: firstpageindex]\gb54B
redrawDirty
	[dirty or⦂ publication dirty⇒
		[self changeViews: numviews. dirty←false. publication dirty←false] ]\gb13B
views: viewset title: title firstpageindex: firstpageindex | i view views template
	[ [viewset
		=1⇒	"full scale"
			[numviews←1. template←PageTemplates◦1. scale←Scale◦1];
		=2⇒	"half scale, facing pages"
			[numviews←4. template←PageTemplates◦2. scale←Scale◦2.
			firstpageindex←(firstpageindex min: (publication length-4+1)) max: 1.
			numviews←numviews min: (publication length-firstpageindex+1).
			[firstpageindex even⇒[ ] template←template copy: 2 to: 4.
				numviews=4⇒[numviews←3] ].
			template←template copy: 1 to: numviews];
		>2⇒	"half scale, arbitrary pages (1,2,3,4)"
			[numviews←viewset-2. template←PageTemplates◦3. scale←Scale◦3.
			firstpageindex←
				(firstpageindex min: (publication length-numviews+1)) max: 1.
			numviews←numviews min: (publication length-firstpageindex+1).
			template←template copy: 1 to: numviews] ].
	views←Set new default.
	for⦂ i to: numviews do⦂
		[view←pageviews◦i. views add: view. view pageindex←firstpageindex+i-1].
	self title: title with: views at: template.
	self newframe; enter]\gb59B24b1B17i12I65i26I338i39I
viewShowing: page | pane
	[for⦂ pane from: panes do⦂ [pane page=page⇒[⇑pane] ] ⇑false]
\gb18B6b2B44b5B4b6B

Measure Info\gbf5 
editInfo | pt
	[while⦂ (measureframe has: (pt←user mp)) do⦂
		[measureXY has: (pt←user mp)⇒
			[while⦂ (measureXY has: user mp) do⦂ [measureXY Bug] ]
		"gridXY has: (pt←user mp)⇒
			[while⦂ (gridXY has: user mp) do⦂ [gridXY Bug] ]"
		user redbug⇒
			[rectM has: pt⇒[self measure]
			"rectG has: pt⇒[self flipGrid]"
			rectA has: pt⇒[self apply] ] ] ]\gb8i1BI4i2I
initInfo | mo
	[measureframe←Rectangle new
		origin: (titleframe corner x+4)⌾(frame origin y-16)
		corner: (frame corner x)⌾(frame origin y-2).
	measureinfo←Textframe new para: '' frame: (measureframe copy).
	measureinfo show; outline. mo←measureframe origin-(2⌾0).
	self showTitle: 'M' offset: MOffset.	rectM←(mo+MOffset) extent: (27⌾15).
"	self showTitle: 'G' offset: GOffset.		rectG←(mo+GOffset) extent: (26⌾15)."
	self showTitle: 'A' offset: AOffset.		rectA←(mo+AOffset) extent: (29⌾15).
	measureXY←PointMenu copy. "gridXY←PointMenu copy."
	(panes◦1) showPageNum]\gb8i1BI
showInfo [self initInfo; updateInfo]\gb9B
showPara: para offset: offset | orig corn clipframe
	[orig←measureframe origin+offset. corn←(orig x+40)⌾(measureframe corner y).
	clipframe←orig rect: corn.
	(Textframe new para: (para allFont: 15) frame: (measureframe copy))
		displayat: (measureframe origin+offset) effect: storing clippedBy: clipframe]\gb30B21b2B
showTitle: titlestr offset: offset | para
	[para←titlestr asParagraph. self showPara: para offset: offset]\gb35B
updateGrid
	["gridXY unshow.
	gridXY viewee: (grid grid); showat: (measureframe origin+GridOffset)"]\gb12B
updateInfo [self updateMeasure; updateGrid]\gb11B
updateMeasure
	[measureXY unshow.
	measureXY viewee: measure; showat: (measureframe origin+MeasureOffset)]\gb15B

Anchor/Mark\gbf5 
apply | apt f diff
	[rectA comp.
	[anchor showing⇒[apt←anchor pt] apt←0⌾0. anchor box←false].
	[mark showing⇒
		[mark unshow.
		f←mark box frame. diff←measure-(mark pt-apt).
		[mark box≡anchor box⇒
			[f tic: (mark tic) stretchto: (mark pt+diff) anchor: (anchor tic)]
			f tic: (mark tic) moveto: (mark pt+diff)].
		mark pageviewer newFrame: f. mark pt←(mark box) pointoftic: (mark tic).
		"[anchor box⇒[anchor pt←(anchor box) pointoftic: (anchor tic)] ]."
		mark show] ].
	user waitnobug. rectA comp]\gb6B12i2I
measure
	[rectM comp. user waitnobug.
	[mark showing⇒
		[anchor showing⇒[measure←mark pt-(anchor pt)] measure←mark pt-(0⌾0)] ].
	self updateMeasure. rectM comp]\gb7i2BI
showAnchorAt: cursorinfo | view pt cursor f
	[view←cursorinfo◦1. pt←cursorinfo◦2. cursor←cursorinfo◦5.
	f←((view scaleDn: pt)+(view frame origin)-cursor offset) extent: 16⌾16.
	(mark showing and⦂ ((f intersects: mark frame) or⦂
	(anchor showing and⦂ (anchor frame intersects: mark frame))))⇒
		[mark unshowSame. anchor showAt: cursorinfo. mark showSame]
		anchor showAt: cursorinfo]\gb25B18b1B
showMarkAt: cursorinfo [mark showAt: cursorinfo]\gb23B
showSame [anchor showSame. mark showSame]\gb8i1BI
unshowAnchor
	[(mark showing and⦂
	(anchor showing and⦂ (anchor frame intersects: mark frame)))⇒
		[mark unshowSame. anchor unshow. mark showSame]
		anchor unshow]\gb14B
unshowMark [mark unshow]\gb11B
unshowSame [mark unshowSame. anchor unshowSame]\gb10i1BI

Attributes/Grid\gbf5 
attributes | a
	[a←PublicationAttributes viewee: self. (a viewer)◦2←publication attributes. ⇑a]\gb11B81b2B
attributesAt: pt [attributes⇒[⇑attributes has: pt] ⇑false]\gb17B13b19B2b6B
attributesEdit [NormalCursor show. attributes Bug⇒[self redrawDirty] ]\gb15B
flipAttributes [attributes⇒[self unshowAttributes] self showAttributes]\gb15B
flipGrid [rectG comp. user waitnobug]\gb9B
gridActive [⇑false]\gb11B1b6B
gridActive←gridActive\gb
gridOrigin [⇑grid origin-PubOffset]\gb11B1b22B
gridOrigin←gridOrigin [grid at: (gridOrigin+PubOffset)]\gb22B
gridScale [⇑grid grid]\gb10B1b10B
gridScale←scale [grid grid: scale. self updateGrid]\gb16B
showAttributes | pt
	[CrossCursor show. user waitbug. pt←user mp. NormalCursor show.
	attributes←self attributes.
	attributes showat: (pt-(attributes frame extent/2))]\gb15B
showAttributesSame [attributes⇒[attributes reshow] ]\gb19B
unshowAttributes [attributes⇒[attributes unshow. attributes←false] ]\gb17B
unshowAttributesSame [attributes⇒[attributes unshow] ]\gb21B

Filing/Hardcopy\gbf5 
fileIn | ext files files2 s name newpub page i
	[ext←'pub'. files←(dp0 filesMatching: '*.'+ext+'.') sort.
	[files empty⇒
		[(Menu new string: '*none*') zbug]
		files2←files transform⦂ s to⦂ (s copy: 1 to: s length-ext length-2).
		name←files◦((Menu new stringFromVector: files2) zbug).
		newpub←nil filinFrom: name.
		for⦂ page from: newpub do⦂ [page openAis]. "a kluge"
		publication forget. publication←newpub.
		for⦂ i to: 4 do⦂ [(pageviews◦i) publication←newpub]. titlepara←nil.
		name←name copy: 1 to: name length-ext length-2.
		self views: numviews title: name firstpageindex: 1] ]\gb7B354i9I
fileOut | page
	[for⦂ page from: publication do⦂ [page closeAis]. "a kluge"
	publication filoutOn: (title+'.pub').
	for⦂ page from: publication do⦂ [page openAis]. "a kluge"]\gb8B58i9I89i9I
hardcopy | name pressfile
	[user displayoffwhile⦂
		[name←self title+'.press'.
		pressfile←ScreenPressFile new pressfile: name.
		publication hardcopy: pressfile. pressfile close; toPrinter] ]\gb9B

Cursor Control\gbf5 
updateCursor [self attributesAt: user mp⇒[CrossCursor show] PublicationCursor show]
\gb13B
\g
SystemOrganization classify: ↪PublicationViewer under: 'Publication Editor'.\g
PublicationViewer classInit\g

"TableBox"l15000z20000\gbf5 
Class new title: 'TableBox'
	subclassof: PublicationBox
	fields: 'columns rows entrylist entryoverlap pageviewer selectedentry'
	declare: 'RowsMenu EntryTypeMenu EntryCursor ColumnCursor ColsMenu RowCursor EntryMenu TableMenu EntryECursor TableAttributes TableCursor ';
	asFollows\gbf5 

I am a PublicationBox whose content-dependent information consists of a
	matrix of one or more rows of one or more columns of PublicationBoxes,
	all of which are the same type and have the same dimensions:
	columns		the Integer number of PublicationBoxes wide
	rows				the Integer number of PublicationBoxes high
	entrylist		the Set of PublicationBox entries
	entryoverlap	the Integer amount of overlap in bits (<0⇒gap)
	pageviewer	the PageViewer in which I currently reside
	selectedentry	the currently selected entry (false if none)\gi

Init/Access\gbf5 
attributesInit "TableBox classInit. TableBox new attributesInit."
	|	unitviewer unitreader stringviewer colorviewer
		matrixmenu dimensionsmenu marginsmenu overlapbordermenu entrymenu
	[	unitviewer←UnitViewer default
			units: (('pts',1) inVector, ('picas',12), ('cm',28.35), ('in',72.0)).
		unitreader←UnitViewer new readonly.
		stringviewer←[AttributeViewer new
			toString:		↪asString;
			fromString⦂	[attributeValue←attributeText] ].
		colorviewer←[AttributeViewer new
			menu: [ActionMenu new
				stringFromVector: ('white','light gray','gray','dark gray','black'); init;
				action←(white,ltgray,gray,dkgray,black)] ].
		matrixmenu←AttributeMenu new.
			matrixmenu title: 'columns';
				extract: ↪columns; assign: nil; viewer: unitreader copy.
			matrixmenu title: 'rows';
				extract: ↪rows; assign: nil; viewer: unitreader copy.
		dimensionsmenu←AttributeMenu new.
			dimensionsmenu title: 'width';
				extract: ↪entryWidth; assign: 'entryWidth←'; viewer: unitviewer copy.
			dimensionsmenu title: 'height';
				extract: ↪entryHeight; assign: 'entryHeight←'; viewer: unitviewer copy.
		marginsmenu←AttributeMenu new.
			marginsmenu title: 'top'; viewer: unitviewer copy;
				extract: ↪entryTopMargin; assign: 'entryTopMargin←'.
			marginsmenu title: 'bottom'; viewer: unitviewer copy;
				extract: ↪entryBotMargin; assign: 'entryBotMargin←'.
			marginsmenu title: 'left'; viewer: unitviewer copy;
				extract: ↪entryLeftMargin; assign: 'entryLeftMargin←'.
			marginsmenu title: 'right'; viewer: unitviewer copy;
				extract: ↪entryRightMargin; assign: 'entryRightMargin←'.
		overlapbordermenu←AttributeMenu new.
			overlapbordermenu title: 'overlap'; viewer: unitviewer copy;
				extract: ↪entryOverlap; assign: 'entryOverlap←'.
			overlapbordermenu title: 'border'; viewer: unitviewer copy;
				extract: ↪entryBorder; assign: 'entryBorder←'.
			overlapbordermenu title: 'bordercolor'; viewer: colorviewer copy;
				extract: ↪entryBorderColor; assign: 'entryBorderColor←'.
		entrymenu←AttributeMenu new.
			entrymenu title: 'Type';
				extract: ↪entryType; assign: nil; viewer: stringviewer copy.
			entrymenu title: 'Dimensions⇒';
				extract: ↪itself; assign: nil; viewer: dimensionsmenu.
			entrymenu title: 'Margins⇒';
				extract: ↪itself; assign: nil; viewer: marginsmenu.
			entrymenu title: 'Overlap/Border⇒';
				extract: ↪itself; assign: nil; viewer: overlapbordermenu.
		TableAttributes←AttributeMenu new.
			TableAttributes title: 'Matrix⇒';
				extract: ↪itself; assign: nil; viewer: matrixmenu.
			TableAttributes title: 'Entry⇒';
				extract: ↪itself; assign: nil; viewer: entrymenu  ]\gb15B
classInit "TableBox classInit."
	[	self cursorInit; menuInit; attributesInit  ]\gb10B
columns [⇑columns]\gb8B1b8B
columns←columns\gb
cursorInit "TableBox classInit. TableBox new cursorInit."
	[	TableCursor←Cursor new fromtext: '
0000000000000000
0111111111111111
0100000010000001
0100000010000001
0100000010000001
0100000010000001
0100000010000001
0100000010000001
0111111111111111
0100000010000001
0100000010000001
0100000010000001
0100000010000001
0100000010000001
0100000010000001
0111111111111111' offset: 8⌾8.
		EntryCursor←Cursor new fromtext: '
0000000000000000
0000000000000000
0000000000000000
0000000000000000
0000000000000000
0000011111110000
0000010000010000
0000010000010000
0000010000010000
0000010000010000
0000010000010000
0000011111110000
0000000000000000
0000000000000000
0000000000000000
0000000000000000' offset: 8⌾8.
		EntryECursor←Cursor new fromtext: '
0000000000000000
0000000000000000
0011111111111110
0010000000000010
0010000000000010
0010000000000010
0010000000000010
0010000000000010
0010000000000010
0010000000000010
0010000000000010
0010000000000010
0010000000000010
0010000000000010
0011111111111110
0000000000000000' offset: 8⌾8.
		ColumnCursor←Cursor new fromtext: '
0000000000000000
0000000000000000
0000011111110000
0000010000010000
0000010000010000
0000010000010000
0000010000010000
0000010000010000
0000011111110000
0000010000010000
0000010000010000
0000010000010000
0000010000010000
0000010000010000
0000011111110000
0000000000000000' offset: 8⌾8.
		RowCursor←Cursor new fromtext: '
0000000000000000
0000000000000000
0000000000000000
0000000000000000
0000000000000000
0011111111111110
0010000010000010
0010000010000010
0010000010000010
0010000010000010
0010000010000010
0011111111111110
0000000000000000
0000000000000000
0000000000000000
0000000000000000' offset: 8⌾8  ]\gb11B
entrylist [⇑entrylist]\gb10B1b10B
entrylist←entrylist\gb
entryoverlap [⇑entryoverlap]\gb13B1b13B
entryoverlap←entryoverlap\gb
makeClean | e [super makeClean. for⦂ e from: entrylist do⦂ [e makeClean] ]\gb10B
menuInit "TableBox classInit. TableBox new menuInit."
	[	ColsMenu←Menu new string:
'COLUMNS
1
2
3
4
5
6
7
8
9
10'.
		RowsMenu←Menu new string:
'ROWS
1
2
3
4
5
6
7
8
9
10'.
		EntryTypeMenu←Menu new string:
'ENTRY TYPE
text
ais
table'.
		EntryMenu←MenuSet new default init.
			EntryMenu add: [(ActionMenu new) string:	"1"
'edit
exchange two⇒'; init].
			EntryMenu add: [(ActionMenu new) string:	"2"
'entries
columns
rows'; init].
			EntryMenu firstmenu←1.
			EntryMenu menu: 1 line: 2 tomenu: 2.
		TableMenu←MenuSet new default init.
			TableMenu add: [(ActionMenu new) string:	"1"
'new matrix
new arrangement⇒'; init].
			TableMenu add: [(ActionMenu new) string:	"2"
'transpose
rotate right
rotate left'; init].
			TableMenu firstmenu←1.
			TableMenu menu: 1 line: 2 tomenu: 2  ]\gb9B
pageviewer [⇑pageviewer]\gb11B1b11B
pageviewer←pageviewer\gb
rows [⇑rows]\gb5B1b5B
rows←rows\gb
selectedentry [⇑selectedentry]\gb14B1b14B
selectedentry←selectedentry\gb

Common Box Methods\gbf5 
attributesS [⇑TableAttributes viewee: self]\gb12B1b29B
create: pageviewer page: page frame: f | i type entry
	[super create: pageviewer page: page frame: f.
	[(columns←ColsMenu zbug-1)<0⇒[columns←1] ].
	[(rows←RowsMenu zbug-1)<0⇒[rows←1] ].
	[(i←EntryTypeMenu zbug-1)<1⇒[i←1] ]. type←(TextBox,AisBox,TableBox)◦i.
	margin←5⌾5 rect: 1⌾1. border←1. bordercolor←black.
	entryoverlap←border. entrylist←Set new default. selectedentry←false.
	for⦂ i to: (columns*rows) do⦂
		[entry←type new create: pageviewer page: page frame: f.
		entry margin←margin. entry border←border. entry bordercolor←bordercolor.
		entrylist add: entry].
	self frame: self]\gb39B14b2B
delete | entry
	[super delete.
	for⦂ entry from: entrylist do⦂ [entry delete].
	columns←rows←entrylist←entryoverlap←pageviewer←selectedentry←nil]\gb7B
duplicate: view | box i entry
	[box←super duplicate: view.
	box pageviewer←view. box entrylist←Set new default.
	for⦂ i to: (columns*rows) do⦂
		[box entrylist add: (entrylist◦i duplicate: view)] ⇑box]\gb16B180b4B
edit: pageviewer | v menu item pt entry colors
	[super edit: pageviewer.
	TableCursor show. selectedentry←false. user waitnobug.
	colors←(white,ltgray,gray,dkgray,black).
	until⦂ 1=2 do⦂
		[ [user kbck⇒
			[self frame flash]
		user yellowbug⇒
			[selectedentry⇒
				[(v←EntryMenu bug)≡false⇒[ ]
				menu←EntryMenu find: v◦1. item←v◦2.
				menu
					=1⇒	"main menu"				[item
							=1⇒	"edit"						[self editEntry] self frame flash];
					=2⇒	"exchange two⇒"			[item
							=1⇒	"entries"					[self exchangeEntries];
							=2⇒	"columns"					[self exchangeColumns];
							=3⇒	"rows"						[self exchangeRows] ].
				self redrawDirty. EntryCursor show]
				(v←TableMenu bug)≡false⇒[ ]
				menu←TableMenu find: v◦1. item←v◦2.
				menu
					=1⇒	"main menu"				[item
							=1⇒	"new matrix"			[self newMatrix] self frame flash];
					=2⇒	"new arrangement⇒"		[item
							=1⇒	"transpose"				[self transpose];
							=2⇒	"rotate right"				[self rotateRight];
							=3⇒	"rotate left"				[self rotateLeft] ].
				self redrawDirty. TableCursor show]
		user redbug⇒
			[pt←pageviewer scaleUp: (pageviewer mp).
			(entry←self entryAt: pt)⇒
				[entry≡selectedentry⇒
					[self entrySelect: false. TableCursor show]
					self entrySelect: entry. EntryCursor show]
				selectedentry⇒
					[self entrySelect: false. TableCursor show]
					⇑self] ].
			user waitnobug. self redrawDirty].
	TableCursor show]\gb17B336i11I21i6I51i15I20i9I40i9I40i6I159i11I21i12I48i18I19i11I33i14I35i12I350b5B
fill: pageviewer | entry
	[super fill: pageviewer.
	for⦂ entry from: entrylist do⦂ [entry fill: pageviewer] ]\gb17B
frame: f | w h i j k
	[super frame: f. self makeDirty.
	(rows≡nil or⦂ columns≡nil)⇒[⇑self]
	"Constrain the width and height to fit the entries"
	w←(self width+(entryoverlap*(columns-1)))/columns.
	h←(self height+(entryoverlap*(rows-1)))/rows. k←1.
	for⦂ i to: rows do⦂
		[for⦂ j to: columns do⦂
			[entrylist◦k frame: (self frameEntry: i⌾j with: w⌾h). k←k+1] ].
	corner←(entrylist◦(k-1)) corner]\gb9B11b2B33i1I28b5B3i52I
hardcopy: pressfile | entry
	[super hardcopy: pressfile.
	for⦂ entry from: entrylist do⦂ [entry hardcopy: pressfile] ]\gb20B
show: pageviewer | entry
	[super show: pageviewer.
	for⦂ entry from: entrylist do⦂ [entry show: pageviewer] ]\gb17B

Table Manipulation\gbf5 
entryBorder [⇑(entrylist◦1) border]\gb12B1b21B
entryBorderColor [⇑(entrylist◦1) bordercolor]\gb17B1b26B
entryBorderColor←bordercolor | entry
	[self makeDirty. for⦂ entry from: entrylist do⦂ [entry bordercolor←bordercolor] ]\gb29B
entryBorder←border | entry
	[self makeDirty. for⦂ entry from: entrylist do⦂ [entry border←border] ]\gb19B
entryBotMargin [⇑(entrylist◦1) botMargin]\gb15B1b24B
entryBotMargin←b | entry
	[self botMargin←b.
	self makeDirty. for⦂ entry from: entrylist do⦂ [entry botMargin←b] ]\gb17B
entryHeight [⇑(entrylist◦1) height+1]\gb12B1b23B
entryHeight←h
	[self height←(h*rows)-(entryoverlap*(rows-1))-1. self frame: self]\gb15B
entryLeftMargin [⇑(entrylist◦1) leftMargin]\gb16B1b25B
entryLeftMargin←l | entry
	[self leftMargin←l.
	self makeDirty. for⦂ entry from: entrylist do⦂ [entry leftMargin←l] ]\gb18B
entryMargin [⇑(entrylist◦1) margin]\gb12B1b21B
entryMargin←m | entry
	[margin←m⌾m rect: m⌾m.
	self makeDirty. for⦂ entry from: entrylist do⦂ [entry margin←margin] ]\gb14B
entryOverlap [⇑entryoverlap]\gb13B1b13B
entryOverlap←entryoverlap [self frame: self]\gb26B
entryRightMargin [⇑(entrylist◦1) rightMargin]\gb17B1b26B
entryRightMargin←r | entry
	[self rightMargin←r.
	self makeDirty. for⦂ entry from: entrylist do⦂ [entry rightMargin←r] ]\gb19B
entryTopMargin [⇑(entrylist◦1) topMargin]\gb15B1b24B
entryTopMargin←t | entry
	[self topMargin←t.
	self makeDirty. for⦂ entry from: entrylist do⦂ [entry topMargin←t] ]\gb17B
entryType [⇑(entrylist◦1) type]\gb10B1b19B
entryWidth [⇑(entrylist◦1) width+1]\gb11B1b22B
entryWidth←w
	[self width←(w*columns)-(entryoverlap*(columns-1))-1. self frame: self]\gb14B
newMatrix | newcolumns newrows newnum num i k entry
	[NormalCursor show.
	[(newcolumns←ColsMenu zbug-1)<0⇒[newcolumns←1] ].
	[(newrows←RowsMenu zbug-1)<0⇒[newrows←1] ].
	TableCursor show.
	newnum←newcolumns*newrows. num←columns*rows. k←newnum+1.
	[newnum>num⇒
		[for⦂ i from: num+1 to: newnum do⦂
			[entry←entrylist◦1 duplicate: pageviewer. entrylist add: entry] ]
	[newnum<num⇒
		[for⦂ i from: newnum+1 to: num do⦂
			[entry←entrylist◦k delete: pageviewer. entrylist delete: entry] ] ] ].
	columns←newcolumns. rows←newrows.
	pageviewer tidy: self. self frame: self]\gb10B41b2B
rotateLeft | entry k "Put the first entry at the end of the table"
	[entry←entrylist delete: entrylist◦1. entrylist add: entry.
	self frame: self]\gb11B9i46bI2B
rotateRight | entry k "Put the last entry at the beginning of the table"
	[entry←entrylist delete: entrylist◦(columns*rows). entrylist insertI: 1 value: entry.
	self frame: self]\gb12B9i51bI2B
transpose | newentrylist i j k l cols "Interchange rows and columns"
	[newentrylist←Set new default. k←1.
	for⦂ i to: columns do⦂ [l←i.
		for⦂ j to: rows do⦂
			[newentrylist◦k←entrylist◦l. k←k+1. l←l+columns] ].
	entrylist←newentrylist. cols←columns. columns←rows. rows←cols.
	pageviewer tidy: self. self frame: self]\gb10B27i31bI2B

Entry Manipulation\gbf5 
editEntry [selectedentry edit: pageviewer]\gb10B
exchange: entry1 with: entry2 | f1 f2 k1 k2
	[f1←entry1 frame. f2←entry2 frame.
	k1←entrylist find: entry1. k2←entrylist find: entry2.
	entrylist◦k2←entry1. entry1 frame: f2; makeDirty.
	entrylist◦k1←entry2. entry2 frame: f1; makeDirty]\gb30B13b2B
exchangeColumns | entry k1 k2 i
	[ColumnCursor show.
	(entry←self getEntry) and⦂ (entry≠selectedentry)⇒
		[k1←((entrylist find: entry)-1)\columns+1.
		k2←((entrylist find: selectedentry)-1)\columns+1.
		k1≡k2⇒
			[self frame flash]
			for⦂ i to: rows do⦂
				[self exchange: entrylist◦k1 with: entrylist◦k2.
				k1←k1+columns. k2←k2+columns] ]
		user screenrect flash]\gb16B15b1B
exchangeEntries | entry
	[EntryECursor show.
	(entry←self getEntry) and⦂ (entry≠selectedentry)⇒
		[self exchange: entry with: selectedentry]
	user screenrect flash]\gb16B7b1B
exchangeRows | entry k1 k2 i
	[RowCursor show.
	(entry←self getEntry) and⦂ (entry≠selectedentry)⇒
		[k1←((entrylist find: entry)-1)/columns*columns+1.
		k2←((entrylist find: selectedentry)-1)/columns*columns+1.
		k1≡k2⇒
			[self frame flash]
			for⦂ i to: columns do⦂
				[self exchange: entrylist◦k1 with: entrylist◦k2.
				k1←k1+1. k2←k2+1] ]
		user screenrect flash]\gb13B15b1B
frameEntry: ij with: wh | row col w h ox oy
	[row←ij x-1. col←ij y-1. w←wh x. h←wh y.
	ox←self origin x+(col*(w-entryoverlap)).
	oy←self origin y+(row*(h-entryoverlap)). ⇑ox⌾oy extent: w⌾h]\gb24B146b18B
getEntry | pt
	[pt←pageviewer mp. while⦂ (user nobug) do⦂ [pt←pageviewer mp].
	pt←pageviewer scaleUp: pt. EntryCursor show. ⇑self entryAt: pt]\gb9B4b1B110b17B

Entry Selection\gbf5 
entryAt: pt | entry [for⦂ entry from: entrylist do⦂ [entry has: pt⇒[⇑entry] ] ⇑false]
\gb12B56b6B4b6B
entrySelect: entry [self flipSelectedEntry. selectedentry←entry. self flipSelectedEntry]
\gb19B

Table/Entry Display\gbf5 
flipSelectedEntry | f "Does nothing if there is no selected entry"
	[selectedentry⇒
		[f←selectedentry scaledFrame: pageviewer. (f origin+(0⌾0 rect: 9⌾9)) comp] ]\gb18B4i44I
redraw: allEntries | entry "Redraw entries, depending on 'allEntries'"
	[ [dirty⇒
		[self show: pageviewer]
		for⦂ entry from: entrylist do⦂
			[(allEntries or⦂ entry dirty)⇒[entry show: pageviewer. dirty←true] ] ].
	dirty⇒[self flipSelectedEntry; makeClean] ]\gb19B8i43I
redrawAll [self redraw: true]\gb10B
redrawDirty [self redraw: false]\gb12B
\g
SystemOrganization classify: ↪TableBox under: 'Publication Editor'.\g
TableBox classInit\g

"TextBox"l15000z20000\gbf5 
Class new title: 'TextBox'
	subclassof: PublicationBox
	fields: 'para c1 c2 text coveredarea corrupted'
	declare: 'TextAttributes ';
	asFollows\gbf5 

I am a PublicationBox whose content-dependent information consists of a
	Paragraph and display/run-around information:
	para				the Paragraph containing all the text for a story
	c1					the Integer index of the first character from para
	c2					the Integer index of the last character from para
	text				the Text for displaying the text (c1 to: c2) from para
	coveredarea	the Set containing intersecting Rectangles for run-around
	corrupted		the flag for indicating that the text needs to be re-copyfitted\gi

Init/Access\gbf5 
attributesInit "TextBox classInit. TextBox new attributesInit."
	|	unitviewer integerviewer
	[	unitviewer←UnitViewer default
			units: (('pts',1) inVector, ('picas',12), ('cm',28.35), ('in',72.0)).
		integerviewer←[AttributeViewer new
			toString⦂		[attributeText←attributeValue asString+' chars'];
			fromString⦂	[attributeValue←attributeText asStream integerScan asInteger] ].
		TextAttributes←AttributeMenu new.
			TextAttributes title: 'length';
				extract: ↪length; assign: nil; viewer: integerviewer.
			TextAttributes title: 'leading';
				extract: ↪leading; assign: 'leading←'; viewer: unitviewer  ]\gb15B
c1 [⇑c1]\gb3B1b3B
c1←c1\gb
c2 [⇑c2]\gb3B1b3B
c2←c2\gb
classInit "TextBox classInit."
	[	self attributesInit; fontInit  ]\gb10B20b2B
corrupted [⇑corrupted]\gb10B1b10B
corrupted←corrupted\gb
coveredarea [⇑coveredarea]\gb12B1b12B
coveredarea←coveredarea\gb
fontInit "TextBox classInit. TextBox new fontInit. TextEditor classInit."
	[	DefaultFontSet←FontSet new fromVector:
			('TimesRoman10', 'TimesRoman12', 'TimesRoman14', 'TimesRoman8',
			'Helvetica14', 'Helvetica12', 'Helvetica10', 'Helvetica8', 'Hippo10', 'Hippo8',
			'Math10', 'Math8', 'TimesRoman18', 'Helvetica18', 'OldEnglish18', 'Logo24')  ]\gb9B64b1B
leading [⇑text linelead inPts]\gb8B1b20B
leading←leading [text linelead: (leading inMicas)]\gb16B
length [⇑c2-c1+1]\gb7B1b8B
para [⇑para]\gb5B1b5B
para←para\gb
text [⇑text]\gb5B1b5B
text←text\gb

Common Box Methods\gbf5 
attributesS [⇑TextAttributes viewee: self]\gb12B1b28B
create: pageviewer page: page frame: f
	[super create: pageviewer page: page frame: f.
	para←'  ' asParagraph allFont: 0. c1←1. self botMargin←5.
	self getCoveredArea; newText; runAround; copyFit]\gb40B47b1B
delete
	[super delete.
	c1←c2←para←text←corrupted←coveredarea←nil]\gb8B
duplicate: pageviewer | box
	[box←super duplicate: pageviewer.
	box para←'  ' asParagraph allFont: 0. box c1←1.
	box newText; getCoveredArea; runAround; copyFit. ⇑box]\gb22B140b4B
edit: pageviewer
	[super edit: pageviewer.
	TextEditor new edit: text. c2←text lastshown. downlink⇒[downlink fillList] ]\gb18B
fill: pageviewer | f firstbox
	[super fill: pageviewer.
	f←(dp0 file: file) readonly. para←f contents asParagraph fromBravo. f close.
	firstbox←self firstbox. firstbox file←file. firstbox para←para.
	firstbox fillList]\gb17B12b2B
frame: f | oldf
	[oldf←self frame. super frame: f.
	text≡nil⇒[⇑self] self fillList]
	"[self newCoveredArea⇒[self runAround] ].
	self newSize: oldf⇒[self fillList]
	self newLocation: oldf⇒[self newTextOrigin] ]"\gb9B53b5B
hardcopy: pressfile | to
	[super hardcopy: pressfile.
	to←text origin.
	text origin: ((to x)-(PubOffset x inMicas))⌾((to y)+(PubOffset y inMicas)).
	text presson: pressfile. text origin: to]\gb20B4b2B
show: pageviewer
	[super show: pageviewer.
	[corrupted⇒[self fillList] ].
	(pageviewer fullScale)⇒[text showall. dirty←corrupted←false] ] \gb18B

Box Linking\gbf5 
continuedFrom: prevbox
	[super continuedFrom: prevbox.
	file←prevbox file. para←prevbox para. self fillList]\gb24B
continuedTo: nextbox
	[super continuedTo: nextbox.
	nextbox file←file. nextbox para←para. nextbox fillList]\gb22B
unlink | d
	[d←downlink. super unlink.
	file←false. para←'Text' asParagraph allFont: 0. c1←1. self newText.
	d⇒[d fillList] ]\gb7B3b2B

Text Flowing\gbf5 
copyFit [text copyfitall: c1. c2←text lastshown. dirty←true. corrupted←false]\gb8B
fillList | box c maxlength
	[box←self. [uplink⇒[c←uplink c2+1] c←1]. maxlength←para length.
	while⦂ (box and⦂ (c≤maxlength)) do⦂
		[box file←file; para←para; c1←c.
		box newText; getCoveredArea; runAround; copyFit.
		c←box c2+1. box←box downlink] ]\gb9B
markCorrupted [corrupted←dirty←true]\gb14B
markDownCorrupted | box
	[box←downlink. while⦂ box do⦂ [box markCorrupted. box←box downlink] ]\gb18B
newText
	[text←Text new frame: ((self marginFrame+PubOffset) inMicas) para: para
		fontset: DefaultFontSet columns: 1]\gb9B
newTextOrigin | f [f←(self marginFrame+PubOffset) inMicas. text origin: (f origin)]\gb14B

Text Run-Around\gbf5 
getCoveredArea | box
	[coveredarea←Set new default.
	for⦂ box from: page do⦂
		[((self≠box) and⦂ (self intersects: box))" and⦂ (box is: AisBox)"⇒
			[coveredarea add: (self intersect: box)] ] ]\gb15B
newCoveredArea | old i
	[old←coveredarea copy. self getCoveredArea.
	[(old≡nil) or⦂ (old length)≠(coveredarea length)⇒
		[⇑true] for⦂ i to: (old length) do⦂ [(old◦i)≠(coveredarea◦i)⇒[⇑true] ] ]. ⇑false]\gb15B107b5B56b5B7b6B
runAround | f fc m measure linei in out inset outset y flag
	[f←(self marginFrame+PubOffset) inMicas.
	measure←text linemeasure.
	for⦂ linei to: (text totlines) do⦂
		[inset←0. outset←0. y←text ystart: linei. flag←false.
		for⦂ fc from: coveredarea do⦂
			[fc←(fc+PubOffset) inMicas.
			(fc origin y≤y) and⦂ (fc corner y≥y)⇒
				[	[(in←fc corner x-f origin x)<measure⇒[inset←in max: inset] ].
					[(out←f corner x-fc origin x)<measure⇒[outset←out max: inset] ].
				(in≥measure) and⦂ (out≥measure)⇒[flag←true] ] ].
		m←[flag⇒[0] (measure-inset-outset) max: 0].
		(text lines◦linei) inset: (inset min: measure); measure: m] ]\gb10B
\g
SystemOrganization classify: ↪TextBox under: 'Publication Editor'.\g
TextBox classInit\g 
