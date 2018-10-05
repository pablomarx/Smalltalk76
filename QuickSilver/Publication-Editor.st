'From Smalltalk 5.5k XM November 24 on 4 October 1990 at 11:44:27 pm.'

"Coord" 
Class new title: 'Coord'
	subclassof: Object
	fields: 'pt tic box pageviewer cursor underbits showing'
	declare: '';
	asFollows 

I am used by PublicationViewer to display its anchor and mark:
	pt					the Point in points relative to pageviewer origin where I am showing
	tic					the Integer 0-8 indicating which Rectangle tic I am showing on
	box				the PublicationBox in which I am showing (false if none)
	pageviewer	the PageViewer in which I am showing
	cursor			the Cursor which I display when I am showing
	underbits		the String of bits which I cover (false if not showing)
	showing		the flag which indicates whether or not I am showing

Init/Access 
box [⇑box]
box←box
cursor [⇑cursor]
cursorpt [⇑(pageviewer scaleDn: pt)+(pageviewer frame origin)-cursor offset]
cursor←cursor
forget [pt←tic←box←pageviewer←cursor←underbits←showing←nil]
frame [⇑self cursorpt extent: 16⌾16]
init [pt←tic←box←pageviewer←cursor←underbits←showing←false]
pageviewer [⇑pageviewer]
pageviewer←pageviewer
pt [⇑pt]
pt←pt
showing [⇑showing]
showing←showing
tic [⇑tic]
tic←tic
underbits [⇑underbits]
underbits←underbits

Showing 
show | f "Save underbits and BitBlt the cursor at the specified point"
	[f←self frame. underbits←f bitsIntoString.
	cursor showat: (f origin+cursor offset) mode: oring. showing←true]
showAt: cursorinfo "Extract the fields from cursorinfo and show the cursor"
	[self unshow.
	pageviewer←cursorinfo◦1. pt←cursorinfo◦2.
	box←cursorinfo◦3. tic←cursorinfo◦4. cursor←cursorinfo◦5.
	self show]
showSame [showing⇒[self show] ]
unshow "Restore the original bits to the screen"
	[showing⇒[self frame bitsFromString: underbits. underbits←showing←false] ]
unshowSame | s [s←showing. self unshow. showing←s]

SystemOrganization classify: ↪Coord under: 'Publication Editor'.

"PageViewer" 
Class new title: 'PageViewer'
	subclassof: Window
	fields: 'publicationviewer publication pageindex pagenumframe selectedbox backcolor attributes cursorinfo dirty'
	declare: 'PageAttributes CrossCursor PageCursor BoxCursor BoxMenu AnchorCursor PageMenu ';
	asFollows 

A PageViewer is a Window that is a pane of a PublicationViewer with:
	publicationviewer	the PanedWindow of which I am a pane
	publication			the Publication containing the PublicationPage that I view
	pageindex				the Integer index of the PublicationPage that I view
	pagenumframe		the Rectangle in which I display my pagenum
	selectedbox				the PublicationBox where the mark is (false if none)
	backcolor				the Integer color which fills my window (default is gray)
	attributes				the AttributeMenu currently being displayed (false if none)
	cursorinfo				the Vector of (view,pt,box,tic,cursor) where cursor last was
	dirty						the flag which indicates whether or not I need to be redrawn

Init/Access 
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
				extract: ↪page; assign: nil; viewer: nil  ]
backcolor [⇑backcolor]
backcolor←backcolor [dirty←true]
classInit "PageViewer classInit."
	[	self cursorInit; menuInit; attributesInit  ]
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
0110000000000011' offset: 8⌾8  ]
frame←frame "For compatibility with PanedWindow frame:"
fullScale [self scale=(1,1)⇒[⇑true] ⇑false]
init [selectedbox←attributes←false. backcolor←gray "052652"]
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


page [⇑publication◦pageindex]
pageindex [⇑pageindex]
pageindex←pageindex
pagenum [⇑self page pagenum]
pagenumframe [⇑pagenumframe]
publication: publication publicationviewer: publicationviewer
publication←publication
scale [⇑publicationviewer scale]
selectedbox [⇑selectedbox]
selectedbox←selectedbox

Window Protocol 
bluebug [⇑false]
close [publicationviewer←publication←selectedbox←attributes←cursorinfo←nil]
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
	user kbck⇒[user kbd. frame flash] "flush typing outside"]
enter [PageCursor show. self showAttributesSame]
firsttime [frame has: user mp⇒[self reset; enter. ⇑self] ⇑false]
keyset | name "This is a kluge to capture the screen bits for documentation"
	[frame flash. name←'Screen.press' asFileName.
	(dp0 pressfile: name) screenout: (user screenrect) scale: PressScale]
leave [self unshowAttributes]
outside [frame has: user mp⇒[⇑false] ⇑true]

picked [⇑frame has: user mp]
redbug | pt2
	[pt2←user mp.
	[(self attributesAt: pt2)⇒
		[self attributesEdit]
		(publicationviewer attributesAt: pt2)⇒
			[publicationviewer attributesEdit]
			user leftShiftKey⇒
				[self anchorSelect]
				self markSelect].
	user waitnobug. self redrawDirty]
show
	[(frame inset: (¬2⌾¬2)) clear: black. frame color: backcolor mode: storing.
	self redrawAll]
windowenter [self showPageNum; show]
windowleave
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
	PageCursor show. self redrawDirty]

Page Manipulation 
addPage [publication addPage. self lastPage]
addPageDuplicate | box newbox page newpage i
	[publication addPage. page←self page. newpage←publication◦(publication length).
	for⦂ box from: page do⦂
		[newbox←box duplicate: self. newbox page←newpage. newpage add: newbox].
	for⦂ box from: page do⦂
		[newbox←newpage◦(page find: box).
		[(box uplink) and⦂ (i←page find: box uplink)>0⇒[newbox uplink←newpage◦i] ].
		[(box downlink) and⦂ (i←page find: box downlink)>0⇒[newbox downlink←newpage◦i] ] ].
	self lastPage]
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
		self redrawAll]
firstPage [self newPage: 1]
lastPage [self newPage: (publication length)]
newPage: newpageindex | view
	[(view←publicationviewer viewShowing: (publication◦newpageindex))⇒
		[frame flash. view frame flash. ⇑false]
		self erasePageNum; unshowAttributes. pageindex←newpageindex. selectedbox←false.
			self windowenter; enter]
nextPage | i
	[for⦂ i from: (pageindex+1) to: (publication length) do⦂ [(self newPage: i)⇒[⇑self] ] ]
prevPage | i j
	[for⦂ i from: 1 to: (pageindex-1) do⦂ [j←pageindex-i. (self newPage: j)⇒[⇑self] ] ]

Box Manipulation 
addBox: type | v f newbox
	[self unshowAttributes.
	f←Rectangle new fromuser. f←self scaleUp: (f-frame origin).
	newbox←(self page) addBox: type pageviewer: self frame: f.
	self tidyAll: newbox; redrawDirty; boxSelect: newbox]
addBoxDuplicate | view pt tic newbox
	[self unshowAttributes.
	publicationviewer mark cursor show. while⦂ (user nobug) do⦂ [pt←user mp].
	[(view←publicationviewer pickedpane: pt)⇒[ ] frame flash. ⇑self].
	pt←view scaleUp: (pt-view frame origin). tic←publicationviewer mark tic.
	newbox←selectedbox duplicate: view.
	newbox frame: ((selectedbox frame) tic: tic moveto: pt).
	(view page) add: newbox.
	view unshowSame; redrawDirty; showSame. self newSelection: newbox]
adjustBox
	[(publicationviewer mark showing)⇒
		[publicationviewer unshowMark. self getPt.
		[(publicationviewer anchor showing) and⦂
			(publicationviewer anchor box)≡(publicationviewer mark box)⇒
				[self stretchBox] self moveBox].
		publicationviewer showMarkAt: cursorinfo] ]
continuedFrom | view prevbox
	[prevbox←self getBox. view←cursorinfo◦1.
	[((view and⦂ prevbox) and⦂
		((selectedbox uplink≡false and⦂ selectedbox downlink≡false) or⦂
		(selectedbox uplink≡false and⦂ prevbox downlink≡false)))⇒[ ] frame flash. ⇑self].
	[((prevbox class)≡(selectedbox class))⇒[ ] frame flash. ⇑self].
	selectedbox continuedFrom: prevbox. self newSelection: prevbox]

continuedTo | view nextbox
	[nextbox←self getBox. view←cursorinfo◦1.
	[((view and⦂ nextbox) and⦂
		((selectedbox uplink≡false and⦂ selectedbox downlink≡false) or⦂
		(selectedbox downlink≡false and⦂ nextbox uplink≡false)))⇒[ ] frame flash. ⇑self].
	[((nextbox class)≡(selectedbox class))⇒[ ] frame flash. ⇑self].
	selectedbox continuedTo: nextbox. self newSelection: nextbox]

deleteBox
	[self unshowAttributes. publicationviewer unshowMark.
	[publicationviewer anchor box≡selectedbox⇒[publicationviewer unshowAnchor] ].
	self unshowSame.
	self tidy: selectedbox. selectedbox delete.
	self page delete: selectedbox. selectedbox←false.
	self showSame]
editBox
	[self fullScale⇒
		[self unshowSame. selectedbox edit: self. self redrawDirty; showSame] ]
fillBox [self unshowSame. selectedbox fill: self. self redrawDirty; showSame]

firstBox [self newSelection: (selectedbox firstbox)]

getBox
	[user waitnobug. self cursorBox. while⦂ (user nobug) do⦂ [self cursorBox].
	PageCursor show. user waitnobug. ⇑cursorinfo◦3]
getPt
	[user waitnobug. self cursorMark. while⦂ (user nobug) do⦂ [self cursorMark].
	user waitnobug. ⇑cursorinfo◦2]
lastBox [self newSelection: (selectedbox lastbox)]

moveBox | f
	[f←selectedbox frame.
	f tic: (cursorinfo◦4) moveto: (cursorinfo◦2).
	cursorinfo◦2←f pointoftic: (cursorinfo◦4). self newFrame: f]
nextBox | b [ [(b←selectedbox downlink)⇒[ ] b←selectedbox]. self newSelection: b]
prevBox | b [ [(b←selectedbox uplink)⇒[ ] b←selectedbox]. self newSelection: b]
stretchBox | f atic
	[f←(cursorinfo◦3) frame. atic←publicationviewer anchor tic.
	f tic: (cursorinfo◦4) stretchto: (cursorinfo◦2) anchor: atic.
	cursorinfo◦2←f pointoftic: (cursorinfo◦4). self newFrame: f]
underBox | page i j box underbox
	[page←self page. j←page find: selectedbox. underbox←false.
	for⦂ i from: (j+1) to: (self page length) do⦂
		[(box←page◦i) intersects: selectedbox⇒[underbox←box] ].
	[underbox⇒[ ] for⦂ i to: (j-1) do⦂
		[(box←page◦i) intersects: selectedbox⇒[underbox←box] ] ].
	underbox⇒
		[self unshowAttributes. selectedbox←false. publicationviewer unshowMark.
		underbox show: self. self boxSelect: underbox] frame flash]
unlink [self unshowSame. selectedbox unlink. self redrawDirty; showSame]


Box Scaling/Framing 
newFrame: f
	[self unshowSame.
	self tidy: selectedbox. selectedbox frame: f; show: self.
	[(publicationviewer mark showing)⇒
		[publicationviewer mark pt←f pointoftic: (publicationviewer mark tic)] ].
	self showSame]
scaleDn: a | scale [scale←self scale. ⇑a*(scale◦1)/(scale◦2)]

scaleUp: a | scale [scale←self scale. ⇑a*(scale◦2)/(scale◦1)]


Box Selection 
anchorSelect
	[cursorinfo◦5←AnchorCursor.
	(self≡publicationviewer anchor pageviewer) and⦂
		((publicationviewer anchor showing) and⦂
			(((cursorinfo◦2)-publicationviewer anchor pt) abs≤(8⌾8)))⇒
				[publicationviewer unshowAnchor]
				publicationviewer showAnchorAt: cursorinfo]
boxAt: pt | box [for⦂ box from: self page do⦂ [box has: pt⇒[⇑box] ]. ⇑false]

boxSelect: box | pt tic cursor
	[self unshowAttributes; unshowSame. selectedbox←box.
	[(tic←publicationviewer mark tic)⇒[ ] tic←0]. pt←box pointoftic: tic.
	cursor←Cursor new fromTic: tic. cursorinfo←(self,pt,box,tic,cursor).
	self redrawDirty. publicationviewer showSame; showMarkAt: cursorinfo]
markSelect
	[ [(publicationviewer mark pageviewer)⇒
		[publicationviewer mark pageviewer selectedbox←false] ].
	(selectedbox←cursorinfo◦3)⇒
		[(self≡publicationviewer mark pageviewer) and⦂
			((publicationviewer mark showing) and⦂
				(((cursorinfo◦2)-publicationviewer mark pt) abs≤(8⌾8)))⇒
					[self unshowAttributes. publicationviewer unshowMark. selectedbox←false]
					publicationviewer showMarkAt: cursorinfo]
		self unshowAttributes. publicationviewer unshowMark]
newSelection: newbox | view newpage newpageindex
	[self unshowAttributes. publicationviewer unshowMark. view←self.
	newpage←newbox page. newpageindex←publication find: newpage.
	[selectedbox and⦂ (selectedbox page≠newpage)⇒
		[(view←publicationviewer viewShowing: newpage)⇒
			[view picked⇒[ ] view takeCursor]
			self newPage: newpageindex. view←self] ].
	selectedbox←false. view boxSelect: newbox]
pageTicAt: pt | f tic
	[f←self scaleUp: (frame copy moveto: 0⌾0). tic←f ticofpoint: pt.
	(f inset: 8⌾8) has: pt⇒[⇑false] pt←f pointoftic: tic. ⇑(tic,pt)]

Page/Box Display 
colorPage: i [backcolor←(white, ltgray, gray, dkgray, black)◦i. self enter]
erasePageNum | f c
	[ [self fullScale⇒
		[f←(pagenumframe origin copy-(6⌾2)) rect: (pagenumframe corner copy+(3⌾2)).
			c←white]
		f←(pagenumframe origin copy-(6⌾4)) rect: (pagenumframe corner copy+(6⌾2)).
		c←publicationviewer backcolor].
	f clear: c]
redraw: allBoxes | box
	[for⦂ box from: self page do⦂
		[(allBoxes or⦂ box dirty) and⦂ selectedbox≠box⇒[box show: self] ].
	selectedbox and⦂ (allBoxes or⦂ selectedbox dirty)⇒[selectedbox show: self] ]
redrawAll [self redraw: true]
redrawDirty [self redraw: false]
showPageNum | p para textframe ptx xoff yoff
	[p←self pagenum.
	para←(Paragraph new text: (p asString) alignment: 0) allBold.
	textframe←Textframe new para: para frame: (0⌾0 rect: 100⌾100).
	ptx←(textframe rectofchar: para length+1) corner x+7.
	[(self fullScale) or⦂ (p even≡false)⇒[xoff←frame width-ptx] xoff←3]. yoff←¬16.
	textframe put: para at: (frame origin+(xoff⌾yoff)); outline.
	pagenumframe←textframe frame]
showSame [publicationviewer showSame. self showAttributesSame]
tidy: f | fs box
	[fs←(self scaleDn: f)+frame origin.
	(fs intersect: frame) color: backcolor mode: storing.
	for⦂ box from: self page do⦂
		[(box intersects: f) and⦂ (selectedbox≠box)⇒[box makeDirty] ] ]
tidyAll: f
	[self tidy: f. selectedbox and⦂ (selectedbox intersects: f)⇒[selectedbox makeDirty] ]
unshowSame [self unshowAttributesSame. publicationviewer unshowSame]

Filing/Hardcopy 
fileIn | ext files files2 s name newpage
	[ext←'page'. files←(dp0 filesMatching: '*.'+ext+'.') sort.
	[files empty⇒
		[(Menu new string: '*none*') zbug]
		files2←files transform⦂ s to⦂ (s copy: 1 to: s length-ext length-2).
		name←files◦((Menu new stringFromVector: files2) zbug).
		newpage←nil filinFrom: name. newpage pagenum←(self page) pagenum.
		newpage openAis. "a kluge to open the appropriate ais files"
		(self page) forget. publication◦pageindex←newpage. self windowenter; enter] ]
fileOut | name
	[name←(publicationviewer title)+(self pagenum asString)+'.page'.
	(self page) closeAis. "a kluge to close all appropriate ais files"
	(self page) filoutOn: name.
	(self page) openAis. "a kluge to open all appropriate ais files"]
hardcopy | name pressfile
	[user displayoffwhile⦂
		[name←(publicationviewer title)+(self pagenum asString)+'.press'.
		pressfile←ScreenPressFile new pressfile: name.
		(self page) hardcopy: pressfile. pressfile close; toPrinter] ]

Attributes 
attributes | a [a←PageAttributes viewee: self. (a viewer)◦2←(self page) attributes. ⇑a]
attributesAt: pt [attributes⇒[⇑attributes has: pt] ⇑false]
attributesEdit | f1 f2
	[NormalCursor show.
	[selectedbox⇒[f1←selectedbox frame] ].
	attributes Bug⇒
		[selectedbox⇒
			[f2←selectedbox frame. selectedbox frame: f1. self newFrame: f2]
			self unshowSame; show; showSame] ]
flipAttributes [attributes⇒[self unshowAttributes] self showAttributes]
showAttributes | pt
	[CrossCursor show. user waitbug. pt←user mp. NormalCursor show.
	[selectedbox⇒
		["Box attributes"	attributes←selectedbox attributes]
		["Page attributes"	attributes←self attributes] ].
	attributes showat: (pt-(attributes frame extent/2))]
showAttributesSame [attributes⇒[attributes reshow] ]
unshowAttributes [attributes⇒[attributes unshow. attributes←false] ]
unshowAttributesSame [attributes⇒[attributes unshow] ]

Cursor/Mp Control 
cursorBox | view pt box tic cursor
	[pt←user mp.
	box←false. tic←publicationviewer mark tic. cursor←CrossCursor.
	[(view←publicationviewer pickedpane: pt)⇒
		[pt←view scaleUp: (pt-view frame origin).
		(box←view boxAt: pt) and⦂ box≠selectedbox⇒
			[cursor←BoxCursor. pt←box inPts pointoftic: tic] ] ].
	cursor show. cursorinfo←(view,pt,box,tic,cursor)]
cursorMark | view pt tic cursor
	[pt←user mp.
	tic←publicationviewer mark tic. cursor←publicationviewer mark cursor.
	[(view←publicationviewer pickedpane: pt)⇒
		[pt←view scaleUp: (pt-view frame origin)] ].
	cursor show. cursorinfo←(self,pt,selectedbox,tic,cursor)]
mp [⇑user mp-frame origin]
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
	cursor show. cursorinfo←(self,pt,box,tic,cursor)]

SystemOrganization classify: ↪PageViewer under: 'Publication Editor'.
PageViewer classInit

"Publication" 
Class new title: 'Publication'
	subclassof: Set
	fields: 'firstpagenum pagesize dirty'
	declare: 'PublicationAttributes ';
	asFollows 

I am a Set of PublicationPages with:
	firstpagenum		the Integer number of the first page
	pagesize			the Point pagewidth⌾pageheight in points (default size)
	dirty					the flag which indicates whether or not I need to be redrawn

Init/Access 
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
				extract: ↪pagesize; assign: nil; viewer: dimensionsmenu  ]
classInit "Publication classInit."
	[	self attributesInit  ]
dirty [⇑dirty]
dirty←dirty
firstpagenum [⇑firstpagenum]
firstpagenum←firstpagenum | i page
	[i←firstpagenum. for⦂ page from: self do⦂ [page pagenum←i. i←i+1]. dirty←true]
forget | page [for⦂ page from: self do⦂ [page forget]. firstpagenum←pagesize←nil]
init [firstpagenum←1. pagesize←612⌾792. dirty←false]
lastpagenum [⇑(firstpagenum+(self numpages)-1)]
numpages [⇑self length]
numpages←n | i l
	[l←self numpages.
	(n≤0 or⦂ n≡l)⇒
		[user screenrect flash]
		dirty←true.
		(n<l)⇒
		[for⦂ i from: n+1 to: (l) do⦂ [self◦i forget. self deleteI: i] ]
		for⦂ i from: (l+1) to: n do⦂ [self addPage] ]
pagesize [⇑pagesize]
pagesize←pagesize

Adding Pages 
addPage | page
	[page←PublicationPage default init: (self lastpagenum+1).
	self add: page. ⇑page]

Attributes/Hardcopy 
attributes [⇑PublicationAttributes viewee: self]
hardcopy: pressfile | page
	[for⦂ page from: self do⦂ [page hardcopy: pressfile. pressfile page] ]

SystemOrganization classify: ↪Publication under: 'Publication Editor'.
Publication classInit

"PublicationBox" 
Class new title: 'PublicationBox'
	subclassof: Rectangle
	fields: 'page uplink downlink margin color border bordercolor dirty file'
	declare: 'BoxAttributes ';
	asFollows 

I am a Rectangle on a PublicationPage with content-independent information:
	page			the PublicationPage on which I reside
	uplink		the PublicationBox above me (from which my contents flow)
	downlink	the PublicationBox below me (to which my contents flow)
	margin		the Rectangle left⌾top rect: right⌾bottom in points
	color			the Integer color of my frame (white,ltgray,gray,dkgray,black)
	border		the Integer width in points of my border (>0⇒inside frame)
	bordercolor	the Integer color of my border (white,ltgray,gray,dkgray,black)
	dirty			the flag which indicates whether or not I need to be redrawn
	file			the input FileStream (false if none)

Init/Access 
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
				extract: ↪itself; assign: nil; viewer: nil  ]
border [⇑border]
bordercolor [⇑bordercolor]
bordercolor←bordercolor
border←border
botMargin [⇑margin corner y]
botMargin←b [margin corner y←b]
classInit "PublicationBox classInit."
	[	self attributesInit  ]
color [⇑color]
color←color
dirty [⇑dirty]
dirty←dirty
downlink [⇑downlink]
downlink←downlink
file [⇑file]
filename [file⇒[⇑file copy: 1 to: (file length-1)] ⇑'-no file-']
file←file
firstbox | box [box←self. until⦂ box uplink≡false do⦂ [box←box uplink]. ⇑box]
lastbox | box [box←self. until⦂ box downlink≡false do⦂ [box←box downlink]. ⇑box]
leftMargin [⇑margin origin x]
leftMargin←l [margin origin x←l]
makeClean [dirty←false]
makeDirty [dirty←true]
margin [⇑margin]
margin←margin
originx [⇑origin x]
originx←originx [self moveto: originx⌾(self originy)]
originy [⇑origin y]
originy←originy [self moveto: (self originx)⌾originy]
page [⇑page]
page←page
rightMargin [⇑margin corner x]
rightMargin←r [margin corner x←r]
topMargin [⇑margin origin y]
topMargin←t [margin origin y←t]
type | t [t←self class asString. ⇑t copy: 7 to: (t length-3)]
uplink [⇑uplink]
uplink←uplink

Common Box Methods 
attributes | a [a←BoxAttributes viewee: self. (a viewer)◦2←self attributesS. ⇑a]
create: pageviewer page: page frame: f
	[uplink←downlink←false. margin←0⌾0 rect: 0⌾0. color←white.
	border←0. bordercolor←white. file←false. origin←corner←0⌾0. self frame: f]

delete [self unlink. page←margin←color←border←bordercolor←dirty←file←nil]
duplicate: pageviewer | box
	[box←(self class) copy: self. box origin: origin copy corner: corner copy.
	box page←pageviewer page. box uplink←false. box downlink←false.
	box margin←margin copy. box file←false. box dirty←true. ⇑box]

edit: pageviewer [NormalCursor show]
fill: pageviewer | ext files files2 s name
	[ext←self type. files←(dp0 filesMatching: '*.'+ext+'.') sort.
	[files empty⇒
		[(Menu new string: '*none*') zbug. file←dirty←false]
		files2←files transform⦂ s to⦂ (s copy: 1 to: s length-ext length-2).
		file←files◦((Menu new stringFromVector: files2) zbug). dirty←true] ]
frame: f [self origin: (f origin copy) corner: (f corner copy); fixFrame]
hardcopy: pressfile | f b ox oy cx cy w h
	[f←self borderFrame inMicas. b←border inMicas.
	ox←f origin x-b. oy←f origin y-b. cx←f corner x. cy←f corner y.
	w←(f width)+1+(b*2). h←(f height)+1+(b*2).
	bordercolor=black⇒
		[pressfile setcolor: 1.
		pressfile setp: ox⌾oy; showrectwidth: w height: b.
		pressfile setp: ox⌾oy; showrectwidth: b height: h.
		pressfile setp: ox⌾cy; showrectwidth: w height: b.
		pressfile setp: cx⌾oy; showrectwidth: b height: h] ]
show: pageviewer | fs fb
	[fs←self scaledFrame: pageviewer. fb←self borderFrame: pageviewer.
	(fs intersect: pageviewer frame) clear: color.
	(fb intersect: pageviewer frame) border: border color: bordercolor. dirty←false]

Box Linking 
continuedFrom: prevbox | nextbox "Assume prevbox is not false"
	[ [(nextbox←prevbox downlink)⇒[nextbox uplink←self. downlink←nextbox] ].
	prevbox downlink←self. uplink←prevbox]

continuedTo: nextbox | prevbox "Assume nextbox is not false"
	[ [(prevbox←nextbox uplink)⇒[prevbox downlink←self. uplink←prevbox] ].
	downlink←nextbox. nextbox uplink←self]

unlink | prevbox nextbox
	[prevbox←uplink. nextbox←downlink.
	[prevbox⇒[prevbox downlink←nextbox] ].
	[nextbox⇒[nextbox uplink←prevbox] ].
	uplink←downlink←false]

Box Scaling/Framing 
borderFrame | f [f←self inset: border⌾border. ⇑f]
borderFrame: pageviewer | f
	[f←(pageviewer scaleDn: (self borderFrame))+pageviewer frame origin. ⇑f]
fixFrame | f w h ox oy cx cy
	[w←page pagesize x. h←page pagesize y.
	[self width≤0⇒[self width←32] ]. [self height≤0⇒[self height←32] ].
	[self width>w⇒[self width←w] ]. [self height>h⇒[self height←h] ].
	ox←origin x. oy←origin y.
	[ox<0⇒[ox←0] ]. [oy<0⇒[oy←0] ]. self moveto: ox⌾oy.
	cx←corner x. cy←corner y.
	[cx>w⇒[ox←ox-cx+w] ]. [cy>h⇒[oy←oy-cy+h] ]. self moveto: ox⌾oy]
frame | f [f←Rectangle new origin: origin copy corner: corner copy. ⇑f]
marginFrame | f [f←(origin+(margin origin)) rect: (corner-(margin corner)). ⇑f]
marginFrame: pageviewer | f
	[f←(pageviewer scaleDn: (self marginFrame))+pageviewer frame origin. ⇑f]
newLocation: oldf | f [f←self frame. ⇑(f origin≠oldf origin)]
newSize: oldf | f [f←self frame. ⇑(f width≠oldf width) or⦂ (f height≠oldf height)]
scaledFrame: pageviewer | f
	[f←(pageviewer scaleDn: (self frame))+pageviewer frame origin. ⇑f]
scaleDn: scale [⇑(self frame)*(scale◦1)/(scale◦2)]

scaleUp: scale [⇑(self frame)*(scale◦2)/(scale◦1)]


SystemOrganization classify: ↪PublicationBox under: 'Publication Editor'.
PublicationBox classInit

"AisBox" 
Class new title: 'AisBox'
	subclassof: PublicationBox
	fields: 'halftoner'
	declare: 'AisAttributes ';
	asFollows 

I am a PublicationBox whose content-dependent information consists of a
	half-toned image read from an Ais file:
	halftoner		the HalfToner for halftoning/cropping/displaying the image

Init/Access 
attributesInit "AisBox classInit. AisBox new attributesInit."
	|	unitreader1 unitreader2
	[	unitreader1←UnitViewer new readonly units: (('pixels',1) inVector).
		unitreader2←UnitViewer new readonly units: (('lines',1) inVector).
		AisAttributes←AttributeMenu new.
			AisAttributes title: 'width';
				extract: ↪widthPixels; assign: nil; viewer: unitreader1 copy.
			AisAttributes title: 'height';
				extract: ↪heightLines; assign: nil; viewer: unitreader2 copy  ]
classInit "AisBox classInit."
	[	self attributesInit  ]
halftoner [⇑halftoner]
halftoner←halftoner
heightLines [halftoner⇒[⇑halftoner nlines] ⇑0]
widthPixels [halftoner⇒[⇑halftoner npix] ⇑0]

Common Box Methods 
attributesS [⇑AisAttributes viewee: self]
create: pageviewer page: page frame: f
	[super create: pageviewer page: page frame: f.
	"self leftMargin←5. self rightMargin←5." halftoner←false]
delete: pageviewer
	[super delete: pageviewer.
	halftoner←nil]
duplicate: pageviewer | box
	[box←super duplicate: pageviewer.
	box halftoner←false. ⇑box]

edit: pageviewer | f
	[super edit: pageviewer.
	halftoner⇒[halftoner setup: (dp0 file: file)] ]
fill: pageviewer
	[super fill: pageviewer.
	halftoner←HalfToner new. halftoner rect←self marginFrame+PubOffset.
	halftoner setup: (dp0 file: file)]
frame: f | oldf
	[oldf←self frame. super frame: f.
	file⇒
		[halftoner rect←self marginFrame+PubOffset.
		self newSize: oldf⇒[halftoner setup: (dp0 file: file)] ] ]
hardcopy: pressfile | f
	[super hardcopy: pressfile.
	halftoner⇒
		[f←halftoner rect. halftoner rect←self marginFrame.
		pressfile pictureinit. halftoner intoPress: pressfile file: file.
		halftoner rect←f] ]
show: pageviewer | f
	[super show: pageviewer.
	pageviewer fullScale and⦂ file⇒[halftoner doFile] ]

SystemOrganization classify: ↪AisBox under: 'Publication Editor'.
AisBox classInit

"PublicationPage" 
Class new title: 'PublicationPage'
	subclassof: Set
	fields: 'pagenum pagesize margin'
	declare: 'PageAttributes ';
	asFollows 

I am a Set of PublicationBoxes with:
	pagenum	the Integer page number which appears on the hardcopy
	pagesize	the Point pagewidth⌾pageheight in points
	margin		the Rectangle left⌾top rect: right⌾bottom in points

Init/Access 
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
				extract: ↪itself; assign: nil; viewer: marginsmenu  ]
botMargin [⇑margin corner y]
botMargin←b [margin corner y←b]
classInit "PublicationPage classInit."
	[	self attributesInit  ]
forget | box [for⦂ box from: self do⦂ [box delete]. pagenum←pagesize←margin←nil]
init: pagenum [pagesize←612⌾792. margin←0⌾0 rect: 0⌾0]
leftMargin [⇑margin origin x]
leftMargin←l [margin origin x←l]
margin [⇑margin]
margin←margin
numboxes [⇑self length]
pagenum [⇑pagenum]
pagenum←pagenum
pagesize [⇑pagesize]
pagesize←pagesize
rightMargin [⇑margin corner x]
rightMargin←r [margin corner x←r]
topMargin [⇑margin origin y]
topMargin←t [margin origin y←t]

Adding Boxes 
addBox: i pageviewer: pageviewer frame: f | type newbox
	[type←(TextBox,AisBox,TableBox)◦i.
	newbox←type new create: pageviewer page: self frame: f.
	self add: newbox. ⇑newbox]
closeAis | box
	[for⦂ box from: self do⦂
		[(box is: AisBox) and⦂ (box file)⇒
			[box halftoner strm close. box halftoner strm←nil] ] ]
openAis | box
	[for⦂ box from: self do⦂
		[(box is: TextBox)⇒[box markCorrupted]
		(box is: AisBox) and⦂ (box file)⇒
			[box halftoner strm←dp0 file: (box file). box halftoner strm readonly] ] ]

Attributes/Hardcopy 
attributes [⇑PageAttributes viewee: self]
hardcopy: pressfile | box [for⦂ box from: self do⦂ [box hardcopy: pressfile] ]

SystemOrganization classify: ↪PublicationPage under: 'Publication Editor'.
PublicationPage classInit

"PublicationViewer" 
Class new title: 'PublicationViewer'
	subclassof: PanedWindow
	fields: 'publication pageviews numviews scale backcolor attributes anchor mark grid measure measureinfo measureframe measureXY gridXY rectG rectM rectA dirty'
	declare: 'PageTemplates MarkOffset MeasureOffset PointMenu GridOffset GOffset MOffset CrossCursor AOffset PublicationAttributes Scale PublicationCursor AnchorCursor PublicationMenu ';
	asFollows 

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
	dirty					the flag which indicates whether or not I need to be redrawn

Init/Access 
anchor [⇑anchor]
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
				extract: ↪publication; assign: nil; viewer: nil  ]
backcolor [⇑backcolor]
backcolor←backcolor [dirty←true]
classInit "PublicationViewer classInit."
	[	self cursorInit; menuInit; attributesInit; templatesInit; measureInit  ]
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
0110000000000011' offset: 8⌾8  ]
dirty [⇑dirty]
dirty←dirty
firstpageindex [⇑(panes◦1) pageindex]
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

"
init: numviews fromFile: title "Read in the publication from the specified file"
	[publication←nil filinFrom: (title+'.pub').
	self initPageViews.
	self views: numviews title: title firstpageindex: 1.
	self showInfo]

"
	user killWindows: PublicationViewer.
	user restartup: (PublicationViewer new init: 1 fromFile: 'Sample1').

"
initPageViews | i view
	[backcolor←white. attributes←false. measure←0⌾0. grid←Grid init.
	grid window: (PageTemplates◦1◦1+PubOffset); grid: 10⌾10; at: 0⌾0.
	anchor←Coord init. anchor cursor←AnchorCursor.
	mark←Coord init. mark tic←0. mark cursor←Cursor new fromTic: 0.
	pageviews←Set new default.
	for⦂ i to: 4 do⦂
		[view←PageViewer new publication: publication publicationviewer: self.
		pageviews add: view] ]
mark [⇑mark]
measureframe [⇑measureframe]
measureinfo [⇑measureinfo]
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
		DefaultTextStyle setfont: 15 fromfile: 'PubIcon11'  ]
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
			PublicationMenu menu: 1 line: 3 tomenu: 5  ]
numviews [⇑numviews]
numviews←numviews [dirty←true]
pageheight [⇑(PageTemplates◦1◦1) height+1]
pagewidth [⇑(PageTemplates◦1◦1) width+1]
panes [⇑panes]
publication [⇑publication]
scale [⇑scale]
Spy
[
spy every: 10; on⦂ [Z←PublicationViewer new init: 4]; report: 'AltoInit.spy'; close.
spy every: 10; on⦂ [Z showInfo]; report: 'AltoMeasureInfo.spy'; close.
spy every: 10; on⦂ [Z show]; report: 'AltoShowPub.spy'; close.
spy every: 10; on⦂ [Z enter]; report: 'AltoEnterPub.spy'; close.
spy every: 10; on⦂ [for⦂ Y to: 5 do⦂ [(Z panes◦1) windowenter] ]; report: 'AltoShowPage.spy'; close.
]
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
		PageTemplates◦3←(topl,topr,botl,botr)  ]

Window Protocol 
bluebug [NormalCursor show. ⇑super bluebug]
close | pane
	[anchor forget. mark forget. publication forget.
	for⦂ pane from: panes do⦂ [pane close].
	publication←pageviews←scale←nil. attributes←false.
	anchor←mark←grid←measure←measureinfo←measureframe←nil.
	measureXY←gridXY←rectG←rectM←rectA←dirty←nil]
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
	user kbck⇒[user kbd. frame flash] "flush typing outside" ]
editTitle [super editTitle. self showInfo. title←titlepara text]
enter | pane
	[self show.
	for⦂ pane from: panes do⦂ [pane windowenter].
	self showSame. self showAttributesSame]
firsttime [frame has: user mp⇒[self reset; enter; showInfo. ⇑self] ⇑false]
frame: frame | tStream orig pane
	[tStream←templates asStream. orig←frame origin.
	for⦂ pane from: panes do⦂ [pane frame←(tStream next)+orig] ]
keyset | name "This is a kluge to capture the screen bits for documentation"
	[frame flash. name←'Screen.press' asFileName.
	(dp0 pressfile: name) screenout: (user screenrect) scale: PressScale]
leave | pane
	[for⦂ pane from: panes do⦂ [pane windowleave].
	self unshowAttributes. NormalCursor show]
newframe [self frame: (PageTemplates◦1◦1+PubOffset); takeCursor]
outside | pt
	[pt←user mp.
	titleframe window has: pt⇒
		[NormalCursor show. [user anybug⇒[self editTitle] ]. ⇑true]
	measureframe has: pt⇒
		[NormalCursor show. [user anybug⇒[self editInfo] ]. ⇑true] ⇑false]
pickedpane | pane [for⦂ pane from: panes do⦂ [pane picked⇒[⇑pane] ] ⇑false]
pickedpane: pt | pane
	[for⦂ pane from: panes do⦂ [pane frame has: pt⇒[⇑pane] ] ⇑false]
redbug
	[ [(self attributesAt: user mp)⇒[self attributesEdit] ].
	user waitnobug. self redrawDirty]

show | pane
	[(frame inset: (¬2⌾¬2)) clear: black. frame color: backcolor mode: storing.  
	[growing⇒[ ] self showtitle].
	for⦂ pane from: panes do⦂ [pane outline] ]
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
	self redrawDirty]

Pane Manipulation 
changeViews: numviews
	[self changeViews: numviews firstpageindex: self firstpageindex]

changeViews: numviews firstpageindex: firstpageindex
	[(panes◦1) erasePageNum.
	self views: numviews title: title firstpageindex: firstpageindex]
redrawDirty
	[dirty or⦂ publication dirty⇒
		[self changeViews: numviews. dirty←false. publication dirty←false] ]
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
	self newframe; enter]
viewShowing: page | pane
	[for⦂ pane from: panes do⦂ [pane page=page⇒[⇑pane] ] ⇑false]


Measure Info 
editInfo | pt
	[while⦂ (measureframe has: (pt←user mp)) do⦂
		[measureXY has: (pt←user mp)⇒
			[while⦂ (measureXY has: user mp) do⦂ [measureXY Bug] ]
		"gridXY has: (pt←user mp)⇒
			[while⦂ (gridXY has: user mp) do⦂ [gridXY Bug] ]"
		user redbug⇒
			[rectM has: pt⇒[self measure]
			"rectG has: pt⇒[self flipGrid]"
			rectA has: pt⇒[self apply] ] ] ]
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
	(panes◦1) showPageNum]
showInfo [self initInfo; updateInfo]
showPara: para offset: offset | orig corn clipframe
	[orig←measureframe origin+offset. corn←(orig x+40)⌾(measureframe corner y).
	clipframe←orig rect: corn.
	(Textframe new para: (para allFont: 15) frame: (measureframe copy))
		displayat: (measureframe origin+offset) effect: storing clippedBy: clipframe]
showTitle: titlestr offset: offset | para
	[para←titlestr asParagraph. self showPara: para offset: offset]
updateGrid
	["gridXY unshow.
	gridXY viewee: (grid grid); showat: (measureframe origin+GridOffset)"]
updateInfo [self updateMeasure; updateGrid]
updateMeasure
	[measureXY unshow.
	measureXY viewee: measure; showat: (measureframe origin+MeasureOffset)]

Anchor/Mark 
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
	user waitnobug. rectA comp]
measure
	[rectM comp. user waitnobug.
	[mark showing⇒
		[anchor showing⇒[measure←mark pt-(anchor pt)] measure←mark pt-(0⌾0)] ].
	self updateMeasure. rectM comp]
showAnchorAt: cursorinfo | view pt cursor f
	[view←cursorinfo◦1. pt←cursorinfo◦2. cursor←cursorinfo◦5.
	f←((view scaleDn: pt)+(view frame origin)-cursor offset) extent: 16⌾16.
	(mark showing and⦂ ((f intersects: mark frame) or⦂
	(anchor showing and⦂ (anchor frame intersects: mark frame))))⇒
		[mark unshowSame. anchor showAt: cursorinfo. mark showSame]
		anchor showAt: cursorinfo]
showMarkAt: cursorinfo [mark showAt: cursorinfo]
showSame [anchor showSame. mark showSame]
unshowAnchor
	[(mark showing and⦂
	(anchor showing and⦂ (anchor frame intersects: mark frame)))⇒
		[mark unshowSame. anchor unshow. mark showSame]
		anchor unshow]
unshowMark [mark unshow]
unshowSame [mark unshowSame. anchor unshowSame]

Attributes/Grid 
attributes | a
	[a←PublicationAttributes viewee: self. (a viewer)◦2←publication attributes. ⇑a]
attributesAt: pt [attributes⇒[⇑attributes has: pt] ⇑false]
attributesEdit [NormalCursor show. attributes Bug⇒[self redrawDirty] ]
flipAttributes [attributes⇒[self unshowAttributes] self showAttributes]
flipGrid [rectG comp. user waitnobug]
gridActive [⇑false]
gridActive←gridActive
gridOrigin [⇑grid origin-PubOffset]
gridOrigin←gridOrigin [grid at: (gridOrigin+PubOffset)]
gridScale [⇑grid grid]
gridScale←scale [grid grid: scale. self updateGrid]
showAttributes | pt
	[CrossCursor show. user waitbug. pt←user mp. NormalCursor show.
	attributes←self attributes.
	attributes showat: (pt-(attributes frame extent/2))]
showAttributesSame [attributes⇒[attributes reshow] ]
unshowAttributes [attributes⇒[attributes unshow. attributes←false] ]
unshowAttributesSame [attributes⇒[attributes unshow] ]

Filing/Hardcopy 
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
		self views: numviews title: name firstpageindex: 1] ]
fileOut | page
	[for⦂ page from: publication do⦂ [page closeAis]. "a kluge"
	publication filoutOn: (title+'.pub').
	for⦂ page from: publication do⦂ [page openAis]. "a kluge"]
hardcopy | name pressfile
	[user displayoffwhile⦂
		[name←self title+'.press'.
		pressfile←ScreenPressFile new pressfile: name.
		publication hardcopy: pressfile. pressfile close; toPrinter] ]

Cursor Control 
updateCursor [self attributesAt: user mp⇒[CrossCursor show] PublicationCursor show]


SystemOrganization classify: ↪PublicationViewer under: 'Publication Editor'.
PublicationViewer classInit

"TableBox" 
Class new title: 'TableBox'
	subclassof: PublicationBox
	fields: 'columns rows entrylist entryoverlap pageviewer selectedentry'
	declare: 'RowsMenu EntryTypeMenu EntryCursor ColumnCursor ColsMenu RowCursor EntryMenu TableMenu EntryECursor TableAttributes TableCursor ';
	asFollows 

I am a PublicationBox whose content-dependent information consists of a
	matrix of one or more rows of one or more columns of PublicationBoxes,
	all of which are the same type and have the same dimensions:
	columns		the Integer number of PublicationBoxes wide
	rows				the Integer number of PublicationBoxes high
	entrylist		the Set of PublicationBox entries
	entryoverlap	the Integer amount of overlap in bits (<0⇒gap)
	pageviewer	the PageViewer in which I currently reside
	selectedentry	the currently selected entry (false if none)

Init/Access 
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
				extract: ↪itself; assign: nil; viewer: entrymenu  ]
classInit "TableBox classInit."
	[	self cursorInit; menuInit; attributesInit  ]
columns [⇑columns]
columns←columns
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
0000000000000000' offset: 8⌾8  ]
entrylist [⇑entrylist]
entrylist←entrylist
entryoverlap [⇑entryoverlap]
entryoverlap←entryoverlap
makeClean | e [super makeClean. for⦂ e from: entrylist do⦂ [e makeClean] ]
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
			TableMenu menu: 1 line: 2 tomenu: 2  ]
pageviewer [⇑pageviewer]
pageviewer←pageviewer
rows [⇑rows]
rows←rows
selectedentry [⇑selectedentry]
selectedentry←selectedentry

Common Box Methods 
attributesS [⇑TableAttributes viewee: self]
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
	self frame: self]
delete | entry
	[super delete.
	for⦂ entry from: entrylist do⦂ [entry delete].
	columns←rows←entrylist←entryoverlap←pageviewer←selectedentry←nil]
duplicate: view | box i entry
	[box←super duplicate: view.
	box pageviewer←view. box entrylist←Set new default.
	for⦂ i to: (columns*rows) do⦂
		[box entrylist add: (entrylist◦i duplicate: view)] ⇑box]
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
	TableCursor show]
fill: pageviewer | entry
	[super fill: pageviewer.
	for⦂ entry from: entrylist do⦂ [entry fill: pageviewer] ]
frame: f | w h i j k
	[super frame: f. self makeDirty.
	(rows≡nil or⦂ columns≡nil)⇒[⇑self]
	"Constrain the width and height to fit the entries"
	w←(self width+(entryoverlap*(columns-1)))/columns.
	h←(self height+(entryoverlap*(rows-1)))/rows. k←1.
	for⦂ i to: rows do⦂
		[for⦂ j to: columns do⦂
			[entrylist◦k frame: (self frameEntry: i⌾j with: w⌾h). k←k+1] ].
	corner←(entrylist◦(k-1)) corner]
hardcopy: pressfile | entry
	[super hardcopy: pressfile.
	for⦂ entry from: entrylist do⦂ [entry hardcopy: pressfile] ]
show: pageviewer | entry
	[super show: pageviewer.
	for⦂ entry from: entrylist do⦂ [entry show: pageviewer] ]

Table Manipulation 
entryBorder [⇑(entrylist◦1) border]
entryBorderColor [⇑(entrylist◦1) bordercolor]
entryBorderColor←bordercolor | entry
	[self makeDirty. for⦂ entry from: entrylist do⦂ [entry bordercolor←bordercolor] ]
entryBorder←border | entry
	[self makeDirty. for⦂ entry from: entrylist do⦂ [entry border←border] ]
entryBotMargin [⇑(entrylist◦1) botMargin]
entryBotMargin←b | entry
	[self botMargin←b.
	self makeDirty. for⦂ entry from: entrylist do⦂ [entry botMargin←b] ]
entryHeight [⇑(entrylist◦1) height+1]
entryHeight←h
	[self height←(h*rows)-(entryoverlap*(rows-1))-1. self frame: self]
entryLeftMargin [⇑(entrylist◦1) leftMargin]
entryLeftMargin←l | entry
	[self leftMargin←l.
	self makeDirty. for⦂ entry from: entrylist do⦂ [entry leftMargin←l] ]
entryMargin [⇑(entrylist◦1) margin]
entryMargin←m | entry
	[margin←m⌾m rect: m⌾m.
	self makeDirty. for⦂ entry from: entrylist do⦂ [entry margin←margin] ]
entryOverlap [⇑entryoverlap]
entryOverlap←entryoverlap [self frame: self]
entryRightMargin [⇑(entrylist◦1) rightMargin]
entryRightMargin←r | entry
	[self rightMargin←r.
	self makeDirty. for⦂ entry from: entrylist do⦂ [entry rightMargin←r] ]
entryTopMargin [⇑(entrylist◦1) topMargin]
entryTopMargin←t | entry
	[self topMargin←t.
	self makeDirty. for⦂ entry from: entrylist do⦂ [entry topMargin←t] ]
entryType [⇑(entrylist◦1) type]
entryWidth [⇑(entrylist◦1) width+1]
entryWidth←w
	[self width←(w*columns)-(entryoverlap*(columns-1))-1. self frame: self]
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
	pageviewer tidy: self. self frame: self]
rotateLeft | entry k "Put the first entry at the end of the table"
	[entry←entrylist delete: entrylist◦1. entrylist add: entry.
	self frame: self]
rotateRight | entry k "Put the last entry at the beginning of the table"
	[entry←entrylist delete: entrylist◦(columns*rows). entrylist insertI: 1 value: entry.
	self frame: self]
transpose | newentrylist i j k l cols "Interchange rows and columns"
	[newentrylist←Set new default. k←1.
	for⦂ i to: columns do⦂ [l←i.
		for⦂ j to: rows do⦂
			[newentrylist◦k←entrylist◦l. k←k+1. l←l+columns] ].
	entrylist←newentrylist. cols←columns. columns←rows. rows←cols.
	pageviewer tidy: self. self frame: self]

Entry Manipulation 
editEntry [selectedentry edit: pageviewer]
exchange: entry1 with: entry2 | f1 f2 k1 k2
	[f1←entry1 frame. f2←entry2 frame.
	k1←entrylist find: entry1. k2←entrylist find: entry2.
	entrylist◦k2←entry1. entry1 frame: f2; makeDirty.
	entrylist◦k1←entry2. entry2 frame: f1; makeDirty]
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
		user screenrect flash]
exchangeEntries | entry
	[EntryECursor show.
	(entry←self getEntry) and⦂ (entry≠selectedentry)⇒
		[self exchange: entry with: selectedentry]
	user screenrect flash]
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
		user screenrect flash]
frameEntry: ij with: wh | row col w h ox oy
	[row←ij x-1. col←ij y-1. w←wh x. h←wh y.
	ox←self origin x+(col*(w-entryoverlap)).
	oy←self origin y+(row*(h-entryoverlap)). ⇑ox⌾oy extent: w⌾h]
getEntry | pt
	[pt←pageviewer mp. while⦂ (user nobug) do⦂ [pt←pageviewer mp].
	pt←pageviewer scaleUp: pt. EntryCursor show. ⇑self entryAt: pt]

Entry Selection 
entryAt: pt | entry [for⦂ entry from: entrylist do⦂ [entry has: pt⇒[⇑entry] ] ⇑false]

entrySelect: entry [self flipSelectedEntry. selectedentry←entry. self flipSelectedEntry]


Table/Entry Display 
flipSelectedEntry | f "Does nothing if there is no selected entry"
	[selectedentry⇒
		[f←selectedentry scaledFrame: pageviewer. (f origin+(0⌾0 rect: 9⌾9)) comp] ]
redraw: allEntries | entry "Redraw entries, depending on 'allEntries'"
	[ [dirty⇒
		[self show: pageviewer]
		for⦂ entry from: entrylist do⦂
			[(allEntries or⦂ entry dirty)⇒[entry show: pageviewer. dirty←true] ] ].
	dirty⇒[self flipSelectedEntry; makeClean] ]
redrawAll [self redraw: true]
redrawDirty [self redraw: false]

SystemOrganization classify: ↪TableBox under: 'Publication Editor'.
TableBox classInit

"TextBox" 
Class new title: 'TextBox'
	subclassof: PublicationBox
	fields: 'para c1 c2 text coveredarea corrupted'
	declare: 'TextAttributes ';
	asFollows 

I am a PublicationBox whose content-dependent information consists of a
	Paragraph and display/run-around information:
	para				the Paragraph containing all the text for a story
	c1					the Integer index of the first character from para
	c2					the Integer index of the last character from para
	text				the Text for displaying the text (c1 to: c2) from para
	coveredarea	the Set containing intersecting Rectangles for run-around
	corrupted		the flag for indicating that the text needs to be re-copyfitted

Init/Access 
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
				extract: ↪leading; assign: 'leading←'; viewer: unitviewer  ]
c1 [⇑c1]
c1←c1
c2 [⇑c2]
c2←c2
classInit "TextBox classInit."
	[	self attributesInit; fontInit  ]
corrupted [⇑corrupted]
corrupted←corrupted
coveredarea [⇑coveredarea]
coveredarea←coveredarea
fontInit "TextBox classInit. TextBox new fontInit. TextEditor classInit."
	[	DefaultFontSet←FontSet new fromVector:
			('TimesRoman10', 'TimesRoman12', 'TimesRoman14', 'TimesRoman8',
			'Helvetica14', 'Helvetica12', 'Helvetica10', 'Helvetica8', 'Hippo10', 'Hippo8',
			'Math10', 'Math8', 'TimesRoman18', 'Helvetica18', 'OldEnglish18', 'Logo24')  ]
leading [⇑text linelead inPts]
leading←leading [text linelead: (leading inMicas)]
length [⇑c2-c1+1]
para [⇑para]
para←para
text [⇑text]
text←text

Common Box Methods 
attributesS [⇑TextAttributes viewee: self]
create: pageviewer page: page frame: f
	[super create: pageviewer page: page frame: f.
	para←'  ' asParagraph allFont: 0. c1←1. self botMargin←5.
	self getCoveredArea; newText; runAround; copyFit]
delete
	[super delete.
	c1←c2←para←text←corrupted←coveredarea←nil]
duplicate: pageviewer | box
	[box←super duplicate: pageviewer.
	box para←'  ' asParagraph allFont: 0. box c1←1.
	box newText; getCoveredArea; runAround; copyFit. ⇑box]
edit: pageviewer
	[super edit: pageviewer.
	TextEditor new edit: text. c2←text lastshown. downlink⇒[downlink fillList] ]
fill: pageviewer | f firstbox
	[super fill: pageviewer.
	f←(dp0 file: file) readonly. para←f contents asParagraph fromBravo. f close.
	firstbox←self firstbox. firstbox file←file. firstbox para←para.
	firstbox fillList]
frame: f | oldf
	[oldf←self frame. super frame: f.
	text≡nil⇒[⇑self] self fillList]
	"[self newCoveredArea⇒[self runAround] ].
	self newSize: oldf⇒[self fillList]
	self newLocation: oldf⇒[self newTextOrigin] ]"
hardcopy: pressfile | to
	[super hardcopy: pressfile.
	to←text origin.
	text origin: ((to x)-(PubOffset x inMicas))⌾((to y)+(PubOffset y inMicas)).
	text presson: pressfile. text origin: to]
show: pageviewer
	[super show: pageviewer.
	[corrupted⇒[self fillList] ].
	(pageviewer fullScale)⇒[text showall. dirty←corrupted←false] ] 

Box Linking 
continuedFrom: prevbox
	[super continuedFrom: prevbox.
	file←prevbox file. para←prevbox para. self fillList]
continuedTo: nextbox
	[super continuedTo: nextbox.
	nextbox file←file. nextbox para←para. nextbox fillList]
unlink | d
	[d←downlink. super unlink.
	file←false. para←'Text' asParagraph allFont: 0. c1←1. self newText.
	d⇒[d fillList] ]

Text Flowing 
copyFit [text copyfitall: c1. c2←text lastshown. dirty←true. corrupted←false]
fillList | box c maxlength
	[box←self. [uplink⇒[c←uplink c2+1] c←1]. maxlength←para length.
	while⦂ (box and⦂ (c≤maxlength)) do⦂
		[box file←file; para←para; c1←c.
		box newText; getCoveredArea; runAround; copyFit.
		c←box c2+1. box←box downlink] ]
markCorrupted [corrupted←dirty←true]
markDownCorrupted | box
	[box←downlink. while⦂ box do⦂ [box markCorrupted. box←box downlink] ]
newText
	[text←Text new frame: ((self marginFrame+PubOffset) inMicas) para: para
		fontset: DefaultFontSet columns: 1]
newTextOrigin | f [f←(self marginFrame+PubOffset) inMicas. text origin: (f origin)]

Text Run-Around 
getCoveredArea | box
	[coveredarea←Set new default.
	for⦂ box from: page do⦂
		[((self≠box) and⦂ (self intersects: box))" and⦂ (box is: AisBox)"⇒
			[coveredarea add: (self intersect: box)] ] ]
newCoveredArea | old i
	[old←coveredarea copy. self getCoveredArea.
	[(old≡nil) or⦂ (old length)≠(coveredarea length)⇒
		[⇑true] for⦂ i to: (old length) do⦂ [(old◦i)≠(coveredarea◦i)⇒[⇑true] ] ]. ⇑false]
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
		(text lines◦linei) inset: (inset min: measure); measure: m] ]

SystemOrganization classify: ↪TextBox under: 'Publication Editor'.
TextBox classInit
