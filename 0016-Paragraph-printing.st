'From Smalltalk 5.5k XM November 24 on 22 November 1980 at 2:57:08 am.'

"ParagraphPrinter" 
Class new title: 'ParagraphPrinter'
	subclassof: Object
	fields: 'frame "<Rectangle> usable area on page"
		leading "<Integer> paragraph leading"
		style "<TextStyle> for paragraphs"
		strm "<Stream> for output"
		'
	declare: 'defaultframe defaultleading ';
	asFollows 

Provides a stream-like interface for printing a succession of paragraphs on a Bravo or Press file.  The margins, leading, and style are settable instance variables.  BravoPrinter and PressPrinter each override some messages

Initialization 
classInit | inch
	[inch ← 2540.		"1 inch in micas"
	defaultframe ←
		(0.75*inch) asInteger⌾(1*inch) rect: (7.75*inch) asInteger⌾(10*inch).
	defaultleading ← 0]
init
	[self frame ← self defaultframe.
	self leading ← defaultleading.
	self style ← DefaultTextStyle]
of: strm

Access to state 
defaultframe [⇑defaultframe]
defaultleading [⇑defaultleading]
frame [⇑frame]
frame ← frame
leading ← leading
style ← style

Writing 
print: para		"A dummy, subclasses will override"
	[strm append: para text]

Class stuff 
printchanges: lis | selector class heading old mes s delFlg
	"prints Changes format: ('class message' 'class message' ...)
	or alternate format: (class (message ...) class () ...) or both
	If an element appears in the list of the form '~class message', this puts out a 
	line causing the system to forget that method.  These come after any additons,
	owing to the sort on Changes"
  [lis empty⇒ [⇑lis]
	user displayoffwhile⦂ [
	lis ← lis asStream.
	old ← mes ← false.

	while⦂ class do⦂ [
		"get next class, selector pair"
		[delFlg← false.
		mes and⦂ (selector ← mes next)⇒ ["more of alternate form"]
		s ← lis next⇒ [
			s is: UniqueString⇒ [
				class ← Smalltalk lookup: s.
				mes ← lis next asStream.
				selector ← mes next]
			"Changes format"
			s ← s asStream.
			[s peek=126 "~"⇒[s next. "take it off stream" delFlg← true]].
			class ← Smalltalk◦(s upto: 040) unique.
			selector ← s upto: 040.]
		class ← false].

		delFlg⇒[self printForget: selector class: class]
		"same, different or no class"
		[old ≡ class⇒ []
		[old⇒ [old endCategoryOn: self; endChangesOn: self]].
		class ≡ false⇒ ["finished"]

		user cr; show: class title.
		old ← class.
		class startChangesOn: self.
		heading ← 'As yet unclassified'].

		class≡false⇒ []
		user space; show: selector.
		s ← class organization invert: (selector ← selector unique).
		s⇒[[s ≠ heading⇒[class startCategory: (heading ← s) on: self]].
		class printMethod: selector on: self]]]]
printclass: class | c first [
	class is: Vector⇒ [
		first ← true.
		for⦂ c from: class do⦂ [
			[first⇒ [first ← false] self nextpage].
			self printclass: c]]
	user displayoffwhile⦂ [
		[class is: UniqueString⇒
			[class ← Smalltalk◦class]].
		user cr; show: class title.
		class paraprinton: self]]
printForget: selector class: class
	"Print a line that causes a message to be forgotten"
	[user cr; show: '~'+class title+' '+selector.
	self print:
		(class title + ' derstands: ↪' + selector + '.
') asParagraph]
stamp | s t [
	t ← user now "date and time".
	s ← Stream default.
	s append: '''From '; append: user version;
		append: ' on '; print: t◦1;
		append: ' at '; print: t◦2;
		append: '.'''; cr.
	self print: s contents asParagraph]

Closing 
close [strm close]

SystemOrganization classify: ↪ParagraphPrinter under: 'Paragraph printing'.
ParagraphPrinter classInit

"BravoPrinter" 
Class new title: 'BravoPrinter'
	subclassof: ParagraphPrinter
	fields: 'eject "Eject page before next paragraph if true"
		'
	declare: '';
	asFollows 

Prints Paragraphs in Bravo format

Initialization 
init
	[super init.  eject ← false]

Writing 
eject
	[strm next ← 014; cr]
nextpage
	[eject⇒ [self eject] eject ← true]
print: para | l r
	[[eject⇒ [self eject. eject ← false]].
	strm append: para text; next← 032.		"^Z"
	l ← frame origin x.
	r ← frame corner x.
	[l≠self defaultframe origin x⇒
		[strm append: 'l'; print: l]].
	[r≠self defaultframe corner x⇒
		[strm append: 'z'; print: r]].
	[leading≠self defaultleading⇒
		[strm append: 'e'; print: leading]].

	"any other run info and cr"
	para bravoRuns: strm.
	]

SystemOrganization classify: ↪BravoPrinter under: 'Paragraph printing'.

"PressPrinter" 
Class new title: 'PressPrinter'
	subclassof: ParagraphPrinter
	fields: 'page "<Integer> current page number"
		ypos "<Integer> current y position on page"
		press "<PressFile> for output"
		'
	declare: 'defaultframe ';
	asFollows 

Prints Paragraphs in Press format

Initialization 
classInit | inch
	[inch ← 2540.		"1 inch in micas"
	defaultframe ←
		(1.1*inch) asInteger⌾(1*inch) rect: (7.75*inch) asInteger⌾(10*inch)]
defaultframe [⇑defaultframe]
init [super init. page ← 1. ypos ← frame maxY]
of: strm [press ← PressFile new of: strm]
press: press

Writing 
nextpage [self nextpage: true]
nextpage: h | n [
	press page.
	page ← page+1.
	ypos ← frame maxY.
	h⇒ [
		n ← page asString.
		press setp: frame maxX+800 ⌾ (ypos + 960);
			selectfont: (press fontindex: 0 style: DefaultTextStyle) - 1;
			append: n;
			showchars: n length]]
print: para [
	self print: para in: (
		Rectangle new origin: frame origin corner: frame maxX ⌾ ypos)]
print: para in: rect | result oldpara [
	[rect width = 0 or⦂ rect height = 0⇒ [user notify: 'zero dimension']].
	"para is a Paragraph-like object (TextImage, Form, etc.)"
	oldpara ← para.
	until⦂ ((result ← para presson: press in: rect) is: Integer) do⦂ [
		"rest of para goes on next page"
		self nextpage.
		para ← result.
		rect ← rect minX ⌾ frame minY rect: rect maxX ⌾ ypos].

	"original para can hide information. if it split across page boundaries,
	the format may vary. other completion flags can be added later"
	oldpara hidePress: press complete: [oldpara≡para⇒ [0] 1].
	⇑ypos ← result]

Closing 
close
	[press close]
toPrinter [press toPrinter]

Projector behavior 

SystemOrganization classify: ↪PressPrinter under: 'Paragraph printing'.
PressPrinter classInit
