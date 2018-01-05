'From Smalltalk 5.5k XM November 24 on 22 November 1980 at 2:57:08 am.'
\g
"Natural"l15000z20000\gbf5 
VariableLengthClass new title: 'Natural'
	subclassof: String
	fields: ''
	declare: 'Naturalzero ';
	bytesize: 8;
	asFollows\gbf5 

A Natural consists of digits between 0 and 255. Accessing beyond the end gives zeroes. This Class is intended to be used by people who implement nicer numbers such as LargeInteger or Rational, thus some of the messages are hard to use because they smash existing Naturals. These messages are only used on Naturals that were created by the programmer using the message.
Since we want to eventually have the result of a LargeInteger operation to return a SmallInteger if possible, Natural numbers do not respond to the same set of arithmetic messages as Integers. All of the messages for Natural numbers are preceeded by "nat".\gi

Arithmetic\gbf5 
natadd: arg | shorter longer i z sum
	["returns a Natural number"
	z ← MachineDouble init.
	[self length < arg length  ⇒ [longer ← arg. shorter ← self]
	longer ← self. shorter ← arg].
	sum ← Natural new: (longer length).
	for⦂ i to: longer length do⦂
		[z increaseby: longer ◦ i. z increaseby: shorter ◦ i.
		sum ◦ i ← z extract].
	[z low ≠ 0 ⇒ [ sum ← sum growby: 1. sum last ← z low]].
	⇑sum]\gb12B
natcompare: arg | i len
	"speeded up for Integer args, same speed for LargeInteger (Natural) args"
	[len ← self length.
	arg length < len⇒ [⇑3]; > len⇒[⇑1]
	for⦂ i from: len to: 1 by: ¬1 do⦂
		[(arg◦i) < (self◦i)⇒[⇑3];
				> (self◦i)⇒[⇑1]].
	⇑2]\gb16B
natdiv: arg | quo rem ql d div dh dnh z z2 dl q i j k l carry digit flag
	["returns a vector of (quotient, remainder)"
	l ← ((self length) - (arg length) + 1).
	[l≤0 ⇒[⇑(Naturalzero, self)]].
	d ← 8 - (arg last hibit).
	rem ← self natnormalize: d. "makes a copy and shifts"
	div ← arg natnormalize: d. "shifts so high order word is >127"
	quo ← Natural new: l.
	dl ← div length - 1.
	ql ← l.
	dh ← div◦dl.
	dnh ← [dl=1 ⇒[0](div◦(dl-1))].
	z ← MachineDouble init.
	z2 ← MachineDouble new.
	for⦂ k to: ql do⦂				"maintain quo*arg+rem=self"
		[j ← rem length + 1 - k.
		z high ← rem◦j.
		[z high = dh ⇒ [q ← ¬1]
			z low ← rem◦(j-1).
			q ← z mdiv: dh.
			z low ← [j<3⇒[0]rem◦(j-2)].
			z2 gets: q mtimes: dnh.
			flag ← true.
			while⦂ ((z < z2) and⦂ flag) do⦂
				[q ← q unsignedadd: ¬1.
				 z2 decreaseby: dnh.
				 [z2 high < dh ⇒ [flag ← false]
					z2 high ← z2 high - dh]]].
		l ← j - dl.
		z2 init.
		carry ← 0.
		for⦂ i to: div length do⦂
			[z gets: q mtimes: (div◦i).
			z2 increaseby: rem◦l.
			z2 decreaseby: carry.  "subtract q * div from rem"
			z2 decreaseby: z low.
			carry ← z high.
			rem◦l ← z2 extract.
			l ← l+1].
		[z2 low = 255 ⇒
			[q ← q unsignedadd: ¬1.
			l ← j - dl.
			z init.
			for⦂ i to: div length do⦂
				[z increaseby: rem◦l.
				z increaseby: (div◦i).
				rem◦l ← z extract.
				l ← l+1]]].
		quo◦(quo length + 1 - k) ← q.].
	rem ← rem natunnormalize: d lookfirst: dl.
	[quo last = 0 ⇒ [ql<2⇒[]
							quo ← quo growby: ¬1]].
	⇑(quo,rem)]\gb12B
natdivideandCarry: arg extra: pair | i len z
	["arg is an integer < 256 - returns remainder, smashes self to quotient - pair is a 2-vector of len (index of high order non-zero word in self) and a MachineDouble - be careful!!!"
	z ← pair ◦ 2.
	z high ← 0.
	len ← pair ◦ 1.
	for⦂ i from: len to: 1 by: ¬1 do⦂
		[z low ← self ◦i.
		self ◦ i ← (z mdiv: arg)].
	[self ◦ len = 0 ⇒[len ← len - 1. len=0⇒[len ← 1]]].
	pair ◦ 1 ← len.
	⇑z high]\gb35B
natnormalize: n | x i r f digit
	["n is the number of bits to shift by. The Natural number returned will be written over repeatedly, so we must make a new one."
	r ← (Natural new: (self length+1)).
	x ← 0.
	f ← n-8.
	for⦂ i to: r length do⦂
		[digit ← self ◦i.
		r◦i ← (digit lshift: n) lor: x.
		x ← digit lshift: f.].
	⇑r]\gb16B
natsubtract: arg | shorter longer i z sum sl al ng lastdigit
	["returns an Integer that is created by this operation"
	 sl ← self length. al ← arg length.
	 z ← MachineDouble init.
	 [sl = al ⇒
		[i ← sl.
		while⦂ (((self ◦i)=(arg◦i)) and⦂ (i>1)) do⦂ [i ← i - 1].
		sl ← i.
		self◦i unsignedlessthan: arg◦i ⇒[longer ← arg. ng ← true. shorter ← self]
		longer ← self. shorter ← arg. ng ← false]
	  sl < al  ⇒ [longer ← arg. shorter ← self. ng ← true. sl ← al]
	  longer ← self. shorter ← arg. ng ← false].
	 sum ← Natural new: longer length. lastdigit ← 1.
	 for⦂ i to: longer length do⦂
		[z increaseby: longer ◦ i. z decreaseby: shorter ◦ i.
		 (sum ◦ i ← z extract)≠0⇒[lastdigit←i]].
	 [lastdigit=longer length⇒[] z ← (Natural new: lastdigit).
						for⦂ i to: lastdigit do⦂ [z◦i ← sum◦i]. sum ← z].
	 ⇑LargeInteger new bytes: sum neg: ng]\gb17B
nattimes: arg | prod z pl carry digit i j k
	[[((self length) = 1) and⦂ ((self◦1) = 0) ⇒ [⇑Naturalzero]].
	pl ← (self length) + arg length.
	prod ← (Natural new: pl).
	z ← MachineDouble new.
	for⦂ i to: pl do⦂ [prod ◦ i ← 0].
	for⦂ i to: self length do⦂
		[k ← i - 1. carry ← 0. digit ← self ◦ i.
		digit ≠ 0 ⇒
			[for⦂ j to: arg length do⦂
				[z gets: digit mtimes: (arg ◦ j).
				z increaseby: carry. k ← k + 1.
				z increaseby: (prod ◦ k).  "k=i+j-1"
				prod◦k← z low.
				carry ← z high]
			prod◦(k+1)←carry]].
	(prod◦pl) = 0 ⇒ [⇑ prod growby: ¬1]
	⇑prod]\gb14B
natunnormalize: n lookfirst: a | x i r f digit
	[n ← 0 - n.
	x ← 0.
	f ← n+8.
	i ← a.
	digit ← self◦i.
	while⦂ ((((digit lshift: n) lor: x)=0) and⦂ (i≠1)) do⦂
		[x ← digit lshift: f.
		i ← i - 1.
		digit ← self ◦ i].
	r ← (Natural new: i).
	a ← i.
	x ← (self◦1) lshift: n.
	for⦂ i to: a do⦂
		[digit ← self ◦ (i+1).
		r◦i ← (digit lshift: f) lor: x.
		x ← digit lshift: n.].
	⇑r]\gb31B

As yet unclassified\gbf5 
◦ n
	[super length < n ⇒ [⇑0]
		 ⇑(super◦n)]\gb5B
asInteger
	[self length=1⇒[⇑self◦1]
	 ⇑LargeInteger new bytes: self neg: false]\gb11B
classInit
	[Naturalzero←Natural new: 1.
	 Naturalzero◦1←0.
	 ⇑self]\gb11B
isLarge
	[⇑false]\gb9B
printon: strm [self printon: strm base: 10]\gb14B
printon: strm base: b | p z n b2 x "only works if b≤10"
	[p ← Stream default.
	z ← (self length, MachineDouble new).
	n ← Natural new: super length.
	b2 ← b*b.
	self copyto: n.
	until⦂ (((z ◦ 1) = 1) and⦂ ((n◦1)<b2)) do⦂
		[x ← (n natdivideandCarry: b2 extra: z).
		 p next← (x\b)+060.
		 p next← (x/b)+060].
	(n◦1) printon: strm base: b.
	strm append: p contents reverse]\gb22B
species
	[⇑Natural]\gb9B
\g
SystemOrganization classify: ↪Natural under: 'Numbers'.\g
Natural classInit\g

"Number"l15000z20000\gbf5 
Class new title: 'Number'
	subclassof: Object
	fields: ''
	declare: '';
	asFollows\gbf5 

Numbers in general\gi

Arithmetic\gbf5 
≠ arg
	[⇑((self=arg) ≡ false)]\gb7B
< n [⇑self - n < 0]\gb4B
= n [⇑self - n = 0]\gb4B
> n [⇑self - n > 0]\gb4B
abs [self<0⇒[⇑self * ¬1]]\gb4B
between: min and: max
	[⇑[min≤self and⦂ self≤max]]\gb23B
compare: i
	[self < i⇒ [⇑1]
	self = i⇒ [⇑2]
	⇑3]\gb12B
factorial  "I only work for positive integer values"
	[self=0⇒[⇑1]
	⇑self * (self-1) factorial]\gb11Bi41I
log2 | i cnt "floor of log base 2"
	[self < 0 ⇒[⇑(self * ¬1) log2]
	self < 1 ⇒[⇑((self/self) / self) log2 * ¬1]
	i ← 1. cnt ← 0.
	while⦂ self ≥ i do⦂ [i ← i+i. cnt ← cnt+1].
	⇑cnt-1]\gb5B8i21I
max: arg
	[self<arg⇒[⇑arg]]\gb10B
min: arg
	[self>arg⇒[⇑arg]]\gb10B
sign
	[⇑[self=0⇒ [0]; <0⇒ [¬1] 1]]\gb6B

Conversions\gbf5 
asPoint
	["Return a Point with me as both coordinates."
	⇑self ⌾ self]\gb9B1i45I
asPtX "pretend to be a Point for Point +-*/"\gb6Bi
asPtY "pretend to be a Point for Point +-*/"\gb6Bi
asRectangle
	["Return a Rectangle with me as all coordinates."
	⇑self ⌾ self rect: self ⌾ self]\gb13B1i48I
asRectCorner "pretend to be a Rectangle for Rectangle +-*/"\gb13Bi
asRectOrigin "pretend to be a Rectangle for Rectangle +-*/"\gb13Bi
base8 | s
	[s ← Stream default. s append: '0'.
	self printon: s base: 8. ⇑s contents]\gb6B
base: b | s
	[s ← Stream default.
	self printon: s base: b. ⇑s contents]\gb8B
printon: strm [self printon: strm base: 10]	"default print radix"\gb14B

Subscripts\gbf5 
cansubscript: a
	[⇑self asInteger cansubscript: a]\gb17B
subscripts: a
	[⇑a◦self asInteger]\gb15B
subscripts: a ← val
	[⇑a◦self asInteger ← val]\gb21B

Intervals, Points\gbf5 
⌾ y
	[⇑Point new x: self y: y]\gb5B
for: n [⇑Interval new from: self to: self+(n-1) by: 1]\gb7B
to: x
	[⇑Interval new from: self to: x by: 1]\gb7B
to: x by: y
	[⇑Interval new from: self to: x by: y]\gb13B
within: int [⇑int start ≤ self and⦂ self ≤ int stop]\gb12B
~ x		"synonym for to: "
	[⇑Interval new from: self to: x by: 1]\gb5B13b3B2b2B

Compatibility\gbf5 
isLarge
	[⇑false]\gb9B
isNumber\gb
\g
SystemOrganization classify: ↪Number under: 'Numbers'.\g

"Date"l15000z20000\gbf5 
Class new title: 'Date'
	subclassof: Number
	fields: 'day year'
	declare: 'monthnames secsinday ';
	asFollows\gbf5 

Implements dates. (Steve Weyer)\gi

Initialization\gbf5 
classInit [
	monthnames ← ↪(
		January February March April May June
		July August September October November December).
	secsinday ← 24*60*60]\gb10B

Setting state\gbf5 
day: day month: month year: year [
	[year < 100⇒ [year ← 1900 + year]].
	(month ← self whichmonth: month)≡false⇒ [user notify: 'illegal month']
	day < 1 or⦂ day > (self daysinmonth: month)⇒ [
		user notify: 'illegal day in month']
	day ← day + (self monthday: month)]\gb33B
day: day year: year | d
	[while⦂ day > (d ← self daysinyear) do⦂ [
		year ← year + 1.
		day ← day - d].
	while⦂ day ≤ 0 do⦂ [
		year ← year - 1.
		day ← day + self daysinyear].
	]\gb20B
default ["today" ⇑user now◦1]\gb8B2i5I
fromDays: d [
	"d = days since Jan 1 1901. There are 1461 days in a 4-year cycle.
	2000 is a leap year, so no extra correction is necessary.
	day:year: will fix things up"
	d ← d asInteger intdiv: 1461.
	self day: 1+ (d◦2) asSmall year: 1901+ ((d◦1) asSmall *4)]\gb12B4i154I

Aspects\gbf5 
asSeconds "Seconds since the beginning of time (local time)" [
	⇑secsinday * (self - (Date new day: 1 year: 1901))]\gb10B
day [⇑day]\gb4B
dayinmonth [⇑day - (self monthday: self month)]\gb11B
dayinyear [⇑day]\gb10B
daysinmonth [⇑self daysinmonth: self month]\gb12B
daysinmonth: m [
	⇑↪(31 28 31 30 31 30 31 31 30 31 30 31)◦m + [m=2⇒ [self leap] 0]]\gb15B2b1B
daysinyear [⇑365 + self leap]\gb11B
daysleft [⇑self daysinyear - day]\gb9B
day← day\gb
hash [⇑(year lshift: 3) lxor: day]\gb5B
leap [
	year \ 4 = 0⇒ [
		year \ 100 = 0⇒ [year \ 400 = 0⇒ [⇑1] ⇑0]
		⇑1]
	⇑0]\gb5B
month | m leap [
	leap ← self leap.
	for⦂ m from: 12 to: 1 by: ¬1 do⦂ [
		(↪(0 31 59 90 120 151 181 212 243 273 304 334)◦m +
			[m > 2⇒ [leap] 0] "self monthday: m") < day⇒ [⇑m]].
	user notify: 'illegal month']\gb6B
monthday: m "Return first day-in-year of m'th month"
	[⇑↪(0 31 59 90 120 151 181 212 243 273 304 334)◦m +
		[m > 2⇒ [self leap] 0]]\gb12Bi40I
monthname [⇑monthnames◦self month]\gb10B
weekday [
	⇑↪(Tuesday Wednesday Thursday Friday Saturday Sunday Monday)
		◦self weekdayIndex]\gb8B
weekdayIndex | a d [
	[day ≤ (self monthday: 3)⇒ [
		a ← year-1.
		d ← 306]
	a ← year.
	d ← ¬59 - self leap].
	"Tuesday=1,..., Monday=7"
	⇑d + day + a + (a/4) + (a/400) - (a/100) \ 7 + 1]\gb19B
whichmonth: m | a "M may be a (partial) month name, or a number.  Return the month number, or false" [
	m Is: String⇒ [
		m ← m + '*'.
		for⦂ a to: 12 do⦂ [
			"first partial match"
			m match: monthnames◦a⇒ [⇑a]].
		⇑false]
	 ⇑m ≥ 1 and⦂ m ≤ 12]\gb14B4i82I60i21I
year [⇑year]\gb5B
year← year\gb

Arithmetic\gbf5 
+ days | t [
	days ← day + days.
	t ← Date new.
	days > 0 and⦂ days < 366⇒ [
		"same year"
		t day ← days; year ← year.
		⇑t]
	⇑t day: days year: year]\gb7B5b2B66i9I
- date
	[date is: Date⇒ [
		year = date year⇒ [⇑day - date day]
		⇑(year-1 / 4) - (date year / 4) +
		day + date daysleft + (year-1 - date year * 365)]
	⇑self + (0 - date)]\gb8B
< date [
	year = date year⇒ [⇑day < date day]
	⇑year < date year]\gb7B
= date [⇑day = date day and⦂ year = date year]\gb7B
> date [
	year = date year⇒ [⇑day > date day]
	⇑year > date year]\gb7B
previous: di [
	"e.g. previous: 6 (Sunday) returns Date which is previous closest Sunday.
	note: di=self weekdayIndex returns self+0"
	⇑self + (0 - (7 + self weekdayIndex - di \ 7))]\gb13B

Printing and reading\gbf5 
from: s [self readfrom: s asVector "asSet" viewer format: nil]\gb8B
printon: strm [self printon: strm format: ↪(1 2 3 040 3 1)]\gb14B
printon: strm format: f | i m [
	"f is print format.
	1-3	positions to print day,month,year respectively
	4	character separator
	5	month format (1 month #, 2 first 3 chars, 3 entire name)
	6	year format (1 year #, 2 year #\100)"

	m ← self month.
	for⦂ i to: 3 do⦂ [
		[f◦i
		=1⇒ [day - (self monthday: m) printon: strm];
		=2⇒ [
			f◦5
			=1⇒ [m printon: strm];
			=2⇒ [strm append: monthnames◦m◦(1 to: 3)]
			strm append: monthnames◦m]
		([f◦6=1⇒ [year] year\100]) printon: strm].
		i<3⇒ [strm next ← f◦4 "separator"]]]\gb24B10i193I281i9I
readfrom: strm
	[self readfrom: strm format: ↪(1 2 3)]\gb16B
readfrom: strm format: order | dmy i [
	strm ∢ ↪today⇒ [⇑self default]
	[order ≡ nil⇒ [order ← ↪(1 2 3)]].
	dmy ← Vector new: 3.
	for⦂ i to: 3 "dmy length" do⦂ [dmy◦(order◦i) ← strm next].
	self day: dmy◦1 month: dmy◦2 year: dmy◦3]\gb29B
\g
SystemOrganization classify: ↪Date under: 'Numbers'.\g
Date classInit\g

"Float"l15000z20000\gbf5 
Class new title: 'Float'
	subclassof: Number
	fields: ''
	declare: 'halfpi sqrt2 twopi fourthpi degreesPerRadian pi radiansPerDegree ln2 ';
	bytesize: 16;
	veryspecial: 3;
	asFollows\gbf5 

These floating-point numbers are good for about 8 or 9 digits of accuracy, and the range is between plus and minus 10^4000.  Here are some valid floating-point examples:
	8.0   13.3   0.3   2.5e6   1.27e¬300   ¬12.987654e2412
Mainly: use shift-minus, no imbedded blanks, little e for tens power, and a digit on both sides of the decimal point.\gi

Arithmetic\gbf5 
≤ arg
	[⇑self≤arg asFloat] primitive: 73\gb7B
≠ arg
	[⇑self≠arg asFloat] primitive: 76\gb7B
≥ arg
	[⇑self≥arg asFloat] primitive: 75\gb7B
* arg
	[⇑self*arg asFloat] primitive: 69\gb7B
+ arg
	[⇑self+arg asFloat] primitive: 67\gb7B
- arg
	[⇑self-arg asFloat] primitive: 68\gb7B
/ arg
	[0.0=arg⇒[user notify: 'Attempt to divide by 0.0']
	⇑self/arg asFloat] primitive: 70\gb7B
< arg
	[⇑self<arg asFloat] primitive: 71\gb7B
= arg
	[arg isNumber⇒ [⇑self = arg asFloat] ⇑false] primitive: 72\gb7B
> arg
	[⇑self>arg asFloat] primitive: 74\gb7B
hash [⇑(self fpart * 100) asInteger lxor: self ipart asInteger]\gb5B
near: n [⇑self near: n within: 1.0e¬4]\gb8B
near: n within: eps [
	"for testing near equality, e.g. error convergence"
	⇑(self - n) abs ≤ eps]\gb20B
negated [⇑0.0-self]\gb8B
sameAs: arg  "arg assumed to be of same class as self"
	[⇑self=arg]\gb13Bi41I
\ arg	"By analogy with integers"
	[self<0.0⇒[⇑(self/arg) ipart+1.0*arg+self]
	⇑self-((self/arg) ipart*arg)]\gb6Bi26I
| arg	"By analogy with integers"
	[⇑(self/arg) ipart*arg]\g6i26I

Conversion\gbf5 
asDegrees		"self assumed to be in radians"
	[⇑self / radiansPerDegree]\gb11Bi31bI2B
asDirection [⇑self cos ⌾ self sin]\gb12B
asFloat\gb
asInteger		"Return an Integer = self ipart"
	[⇑self asLarge] primitive: 78\gb11Bi32I
asLarge | me digits nat i "convert to LargeInteger"
	[self<0⇒[⇑(0.0-self) asLarge negated]
	 digits ← Stream default.
	 [self=0.0⇒[digits next← 0]
	  me ← self ipart.
	  while⦂ me≥1 do⦂
		[digits next ← (me\256.0) asInteger.
	 	 me ← me/256.0]].
	 digits ← digits contents.
	 nat ← Natural new: digits length.
	 for⦂ i to: digits length do⦂ [nat◦i ← digits◦i].
	 ⇑LargeInteger new bytes: nat neg: false]
\gb8B
asRadians		"self assumed to be in degrees"
	[⇑self * radiansPerDegree]\gb11Bi31bI2B
copy [⇑self]\gb5B
fpart [user croak] primitive: 77\gb6B
ipart		"Returns a Float with zero fractional part"
	[⇑self-self fpart]\gb7Bi43I
recopy [⇑self]\gb7B
round
	[⇑(self + [self < 0⇒ [¬0.5] 0.5]) asInteger]\gb7B

Math functions\gbf5 
arctan | theta term y eps i  "return angle in degrees good to .02 degrees."
	[self = 1.0 ⇒ [⇑ 45.0].
	 self = ¬1.0 ⇒ [⇑ ¬45.0].
	 [self*self >1.0 ⇒[theta ← halfpi. y ← ¬1.0/(self*self).  term ← ¬1.0/(self abs).]
			theta ← 0.0. y ← 0.0 - (self*self).  term ← self abs].

	i ← 1.  eps ← 0.0001. 
	while⦂ term abs > eps do⦂
		[theta ← theta + term.
		 term ← term*y*(i asFloat)/((i+2) asFloat).
		 i ← i+2].

	theta ← (self sign asFloat)*theta* 360.0 / twopi.
	⇑ theta] \gb7B
cos  "for angles in radians"
	[self<0.0⇒[⇑(self+halfpi) sin]
	⇑(halfpi-self) sin]\gb5Bi23bI2B30i1I
exp | a n1 x x2 P Q [
	"see Computer Approximations, pp. 96-104, p. 205 (EXPB 1065)"

	self abs > 9212.0 "1.0e4001 ln"⇒ [user notify: 'exp overflow']
	x ← self / ln2.
	(n1 ← Float new "2.0 ipow: x asInteger")
		instfield: 1 ← x asInteger * 2.
	[(x ← x fpart) ≥ 0.5⇒ [
		n1 ← n1 * sqrt2.
		x ← x - 0.5]].
	x2 ← x*x.
	"compute 2.0 power: x"
	P ← Q ← 0.0.
	"↪(0.25250428525576241933744e4 0.28875563776168927289e2) reverse copy"
	for⦂ a from: ↪(28.875564 2525.0429) do⦂ [
		P ← (P*x2) + a].
	"↪(0.72857336028361108885189e4 0.375021654220866600213e3 0.1e1) reverse copy"
	for⦂ a from: ↪(1.0 375.02165 7285.7336) do⦂ [
		Q ← (Q*x2) + a].
	⇑n1 * ((Q + (x*P))/(Q - (x*P)))]\gb4B
ipow: x		"fixed powers in log n steps"
	[x=0⇒ [⇑1.0]
	x=1⇒ [⇑self]
	x>1⇒ [⇑((self*self) ipow: x/2)*(self ipow: x\2)]
	⇑1.0/(self ipow: 0-x)]\gb9Bi29I
ln | a x x2 n P [
	"see Computer Approximations, pp. 105-111, p. 227 (LOGE 2663)"

	self ≤ 0.0⇒ [user notify: 'ln not valid for ' + self asString]

	x ← self + 0.0.
	"exponent"
	n ← ln2 * (((x instfield: 1) / 2) asFloat - 0.5).
	"mantissa between 0.5 and 1.0".
	x instfield: 1 ← 0.
	x ← x * sqrt2.
	x ← (x - 1.0) / (x + 1.0).
	x2 ← x*x.
	P ← 0.0.
	"↪(0.2000000000046727e1 0.666666635059382 0.4000059794795
		0.28525381498 0.2376245609) reverse copy"
	for⦂ a from: ↪(0.23762456 0.28525381 0.40000598 0.66666664 2.0) do⦂ [
		P ← (P*x2) + a].
	⇑n + (x * P)]\gb3B
log: base [⇑self ln / base asFloat ln]\gb10B
neg "Obsolete - use negated, which is uniform for all Numbers"
	[⇑self negated]\gb3i1B16bI8Bi34bI2B
sin | x x2 sum const  "for angles in radians"
	[self<0.0⇒[⇑self negated sin negated];		" normalize to 0≤self≤(pi/4) "
		>twopi⇒[⇑(self\twopi) sin];
		>pi⇒[⇑(self-pi) sin negated];
		>halfpi⇒[⇑(pi-self) sin]
	sum ← x ← self.
	x2 ← x*x.
	for⦂ const from:		"Now compute the series"
		↪(¬0.1666666664 0.0083333315 ¬1.98409e¬4 2.7526e¬6 ¬2.39e¬8)
		do⦂ [sum ← const*(x ← x*x2)+sum]
	⇑sum]\gb4B18i23I42i30I137i24I
sqrt | guess i
	[self≤0.0⇒[self=0.0⇒[⇑0.0] user notify: 'sqrt invalid for x<0.']
	guess ← self+0.0.		"copy x"
	guess instfield: 1 ← (guess instfield: 1)/4*2.	"and halve expt for first guess"
	for⦂ i to: 5 do⦂
		[guess ← (self-(guess*guess)) / (guess*2.0) + guess]
	⇑guess]\gb5B96i8I49i32I
tan | x x2 sum const  "for angles in radians"
	[self<0.0⇒[⇑self negated tan negated];		" normalize to 0≤self≤(pi/4) "
		>pi⇒[⇑(self\pi) tan];
		>halfpi⇒[⇑(self-halfpi) tan negated];
		>fourthpi⇒[⇑1.0/(halfpi-self) tan]
	sum ← x ← self.
	x2 ← x*x.
	for⦂ const from:		"Now compute the series"
		↪(0.3333314036 0.1333923995 0.0533740603 0.0245650893 0.0029005250 0.0095168091)
		do⦂ [sum ← const*(x ← x*x2)+sum]
	⇑sum]\gb4B18i23I42i30I149i24I

Printing\gbf5 
absprinton: strm digits: digits   "print me using digits significant figures"
		| fuzz x exp q i
	["x is myself normalized to [1.0, 10.0), exp is my exponent"
	exp ← [self<1.0⇒ [0-(10.0/self epart: 10.0)] self epart: 10.0].
	x ← self/(10.0 ipow: exp).
	"round the last digit to be printed"
	fuzz ← 10.0 ipow: 1-digits.  x ← 0.5*fuzz+x.
	"check if rounding has unnormalized x"
	[x≥10.0⇒[x←x/10.0.  exp←exp+1]].
	[exp<6 and⦂ exp>¬4⇒
		[q ← 0.			"decimal notation"
		exp<0⇒ [strm append: '0.0000'◦(1 to: 1-exp)]].
	q ← exp. exp ← 0].		"scientific notation"
	"use fuzz to track significance"
	while⦂ x≥fuzz do⦂
		[i ← x asInteger.  strm next ← 060+i.
		x ← x-i * 10.0.  fuzz ← fuzz*10.0.
		exp ← exp-1.  exp=¬1⇒ [strm append: '.']].
	"append additional zeros if necessary"
	while⦂ exp≥¬1 do⦂
		[strm next ← 060.
		exp ← exp-1.  exp=¬1⇒ [strm append: '.']].
	q≠0⇒[strm append: 'e'; print: q]]\gb34Bi43I22i59I95i36I48i38I68i18I71i21I3i31I144i36I
epart: base | x	"gives floor log.base self"
	[self<base⇒ [⇑0]		"self assumed positive"
	self<(base*base)⇒ [⇑1]
	x ← 2*(self epart: base*base).	"binary recursion like ipow"
	⇑x + ((self/(base ipow: x)) epart: base)]\gb12B4i27I20i23I57i28I
printon: strm
	[self printon: strm digits: 8]\gb15B
printon: strm digits: digits   "print me using digits significant figures"
	[self>0.0⇒[self absprinton: strm digits: digits]
	self=0.0⇒[strm append: '0.0']
	strm append: '¬'. (0.0-self) absprinton: strm digits: digits]\gb31Bi43I
roundTo: d
	[⇑(self/d+[self<0.0⇒[¬0.5] 0.5]) ipart*d]\gb12B

Initialization\gbf5 
classInit [
	"constants from Computer Approximations, pp. 182-183
	pi = 3.14159265358979323846264338327950288
	pi/2 = 1.57079632679489661923132169163975144
	pi/4 = 0.78539816339744830961566084581987572
	pi*2 = 6.28318530717958647692528676655900576
	pi/180 = 0.01745329251994329576923690768488612
	2.0 ln = 0.69314718055994530941723212145817657
	2.0 sqrt = 1.41421356237309504880168872420969808"

	pi ← 3.141592654.
	halfpi ← pi/2.0.
	fourthpi ← pi/4.0.
	twopi ← pi*2.0.

	radiansPerDegree ← pi/180.0.
	degreesPerRadian ← 180.0/pi.

	ln2 ←0.6931471806.
	sqrt2 ← 1.414213562]\gb10B4i51I
\g
SystemOrganization classify: ↪Float under: 'Numbers'.\g
Float classInit\g

"Integer"l15000z20000\gbf5 
Class new title: 'Integer'
	subclassof: Number
	fields: ''
	declare: 'digitbuffer ';
	bytesize: 16;
	veryspecial: 1;
	sharing: BitMasks;
	sharing: ByteCodes;
	asFollows\gbf5 

Integers are 16-bit numbers, stored in two-s complement form.  The allowable range is from ¬32768 to +32767.  You can type them in octal by typing a leading zero, as in 0377.\gi

Arithmetic\gbf5 
≤ arg | t
	[t ← arg asInteger.
	 t isLarge⇒[⇑t neg ≡ false]
	 ⇑self ≤ t]\gb6B3b2B
≠ arg | t
	[arg isNumber⇒
	 [t ← arg asInteger.
	  t isLarge⇒[⇑true]
	  ⇑self ≠ t]
	 ⇑true]\gb6B3b2B
≥ arg | t
	[t ← arg asInteger.
	 t isLarge⇒[⇑t neg]
	 ⇑self ≥ t]\gb6B3b2B
* arg | t
	[arg is: Integer⇒[⇑self asLarge*arg]
	 t ← arg asInteger.
	 t isLarge⇒[⇑self asLarge*arg]
	 ⇑self*t] primitive: 21\gb6B3b2B
+ arg | t
	[arg is: Integer⇒[⇑self asLarge+arg]
	 t ← arg asInteger.
	 t isLarge⇒[⇑self asLarge+arg]
	 ⇑self + t]\gb6B3b2B
- arg | t
	[arg is: Integer⇒[⇑self asLarge-arg]
	 t ← arg asInteger.
	 t isLarge⇒[⇑self asLarge-arg]
	 ⇑self - t]\gb6B3b2B
/ arg
	[0=arg⇒[user notify: 'Attempt to divide by 0']
	 arg isLarge⇒[⇑self asLarge/arg]
	 ⇑self / arg asInteger] primitive: 22\gb7B
< arg | t
	[t ← arg asInteger.
	 t isLarge⇒[t neg ≡ false]
	 ⇑self < t]\gb6B3b2B
= arg | t
	[arg isNumber⇒
	 [t ← arg asInteger.
	  t isLarge⇒[⇑false]
	  ⇑self = t]
	 ⇑false]\gb6B3b2B
> arg | t
	[t ← arg asInteger.
	 t isLarge⇒[⇑t neg]
	 ⇑self > t]\gb6B3b2B
compare: arg [
	arg is: Integer⇒ [self < arg⇒ [⇑1]; = arg⇒ [⇑2] ⇑3]
	⇑self natcompare: arg bytes "4 - (arg bytes natcompare: self)"]\gb13B
even
	[⇑(self land: 1) = 0]\gb6B
intdiv: arg
	[arg is: Integer ⇒[⇑(self/arg),(self\arg)]
	 arg is: LargeInteger ⇒ [⇑self asLarge intdiv: arg]
	user notify: 'I give up']\gb13B
negate
	[⇑0-self]\gb8B
negated [⇑0-self]\gb8B
sameAs: arg  "arg assumed to be of same class as self"
	[⇑self=arg]\gb13Bi41I
unsignedadd: y
	["treat numbers as unsigned 8-bit quantities."
	⇑((self + y) land: 0377)]\gb16B
unsignedlessthan: y
	["treat numbers as unsigned 8-bit quantities."
	⇑self < y]\gb21B
\ arg	"mod"
	[0=arg⇒[user notify: 'Attempt to divide by 0']
	 arg isLarge⇒[⇑self asLarge\arg]
	 ⇑self \ arg asInteger] primitive: 26\gb6Bi5I
| arg	"truncate"
	[⇑self/arg*arg]\g6i10I

Bit Manipulation\gbf5 
allmask: b [⇑b = (self land: b)]\gb11B
anymask: b [⇑0 ≠ (self land: b)]\gb11B
bits: int [
	"int is an Interval:  0 is leftmost bit, 15 is rightmost"
	⇑self field: (int length "width" * 16) +
		15 - int stop "displacement from right"]\gb10B
field: fld | t
	[t ← fld asInteger.
	 t isLarge⇒[user notify: 'Field descriptor too large']
	 ⇑self field: t] primitive: 36\gb11B3b2B
field: fld ← val | t
	[t ← fld asInteger.
	 t isLarge⇒[user notify: 'Field descriptor too large']
	 ⇑self field: t ← val asSmall] primitive: 37\gb17B3b2B
hash "used to find large integers in dictionaries"
	[⇑self]\gb5Bi45I
hibit | i
	[for⦂ i to: 16 do⦂
		[(self land: (biton◦(17-i)))≠0⇒[⇑17-i]]
	⇑0]\gb6B
land: arg
	[⇑self land: arg asSmall] primitive: 23\gb11B
lor: arg
	[⇑self lor: arg asSmall] primitive: 24\gb10B
lshift: arg
	[⇑self lshift: arg asSmall] primitive: 25\gb13B
lxor: arg
	[⇑self lxor: arg asSmall] primitive: 35\gb11B
nomask: b [⇑0 = (self land: b)]\gb10B

Conversion\gbf5 
asFloat [user croak] primitive: 34\gb8B
asInteger [⇑self]\gb10B
asLarge | me digits "convert to LargeInteger"
	[me ← self bytes.
	digits ← Natural new: me length.
	digits◦1 ← me◦1.
	[digits length = 2 ⇒ [digits◦2 ← me◦2]].
	⇑LargeInteger new bytes: digits neg: self neg]\gb8B
asNatural | t
	[t ← Natural new: self length.
	 t◦1←self◦1.
	 [t length > 1 ⇒ [t◦2←self◦2]].
	 ⇑t]\gb10B
asObject [user croak] primitive: 81\gb9B
asSmall\gb
inString | t
	[t ← String new: 1. t◦1 ← self. ⇑t]\gb9B
oneToMeAsStream		"used by for-loops"
	[⇑Stream new of: (Interval new from: 1 to: self by: 1)]\gb17Bi19I
unique
[
⇑ self inString unique.
]
\gb7B
unsigned [
	self < 0⇒ [⇑65536.0 + self asFloat]
	⇑self asFloat]\gb9B

Subscripts\gbf5 
cansubscript: a
	[⇑self≥1 and⦂ self≤a length]\gb17B
instfield:	 i	"small integer gives trouble"
	[i = 1 ⇒[⇑self] user notify: 'arg too big']\gb14Bi29I
subscripts: a
	[self cansubscript: a⇒[⇑a◦self]
	user notify: 'Subscript out of bounds: ' + self asString]\gb15B
subscripts: a ← val | t
	[self cansubscript: a⇒
		[t ← val asInteger.
		 (a is: String) and⦂ (t isnt: Integer)⇒
			[user notify: 'Improper store (non-char into String?)']
		 ⇑a◦self ← t]
	user notify: 'Subscript out of bounds: ' + self asString]\gb20B3b2B

Printing\gbf5 
absprinton: strm | rem
	[rem ← self\10.
	[self>9⇒ [self/10 absprinton: strm]].
	strm next ← rem+060]\gb17B
printon: strm
	[self<0⇒[self=¬32768⇒[strm append: '¬32768']
				strm append:'¬'. (0-self) printon: strm base: 10]
	self printon: strm base: 10]\gb15B
printon: strm base: b | rem i x
	[[0>(x←self)⇒[i ← 1.
			digitbuffer◦1 ← 040000\b*2+self-0100000\b. "get it?"
			x ← (040000/b*2+(self-0100000/b))]
	i ← 0].
	while⦂ x≥b do⦂
		[digitbuffer◦(i←i+1) ← x\b.  x ← x/b].
	strm next ← 060+x.
	while⦂ i≠0 do⦂
		[strm next ← 060+(digitbuffer◦i).  i ← i-1].
	]\gb22B78i9I

Characters\gbf5 
asLowercase
	[0101 ≤ self⇒ [
		self ≤ 0132⇒ [⇑self + 040]]]\gb13B
asUppercase
	[0141 ≤ self⇒ [
		self ≤ 0172⇒ [⇑self - 040]]]\gb13B
compareChar: c | a
	["⇑self asLowercase compare: c asLowercase"
	a← self.    "written in-line for speed"
	[0101≤a⇒[a≤0132⇒[a←a+040]]].
	[0101≤c⇒[c≤0132⇒[c←c+040]]].
	a<c⇒[⇑1] a=c⇒[⇑2] ⇑3]\gb15B6i42I14i27I
isalphanumeric
	[self isletter⇒[⇑true]	"lower-case"
	⇑self isdigit]\gb16B23i12I
isdigit 
	[self ≥ 060⇒	" 0 "
		[⇑self ≤ 071]	" 9 "
	⇑false]\gb10B13i5I17i5I
isletter
	[self ≥ 0141⇒	" a "
		[⇑self ≤ 0172]	" z "
	self ≥ 0101⇒	" A "
		[⇑self ≤ 0132]	" Z "
	⇑false]\gb10B14i5I18i5I15i5I18i5I
tokenish		"test for token-chars"
	[self isletter⇒[⇑true]	"lower-case"
	 self isdigit⇒[⇑true]	"digits"
	 ⇑'¬.:⦂' has: self]\gb10Bi22I25i12I24i8I

Copying and Purging\gbf5 
copy [⇑self]\gb5B
purge [user croak] primitive: 44\gb6B
recopy [⇑self]\gb7B

Initialization\gbf5 
classInit "Initialize the digit buffer"
	[digitbuffer ← String new: 16]\gb10Bi29I

Compiler Bytecodes\gbf5 
asCompilerCode  "I am a byte code.  Return the corresponding compiler code"
	[self<16⇒[⇑self+codeLoadField  "inst field"];
		<32⇒[⇑self-16+codeLoadTemp  "temp"];
		<64⇒[⇑self-32+codeLoadLit  "literal"];
		<111⇒[⇑self-64+codeLoadLitInd  "indirect literal"];
		<208⇒[⇑self  "context relative or constant ... not all values here are legal"];
		<256⇒[⇑self-208+codeSendLit  "selector"]
	user notify: 'unexpected byte']\gb16B1i57I35i10I35i4I34i7I38i16I20i62I36i8I
asRemoteCode: generator
	[self<256⇒ [⇑super asRemoteCode: generator]
	(self land: 0177400)≤codeLoadTemp⇒ [⇑ParsedFieldReference new var: self];
		=codeLoadLitInd⇒ [⇑ParsedObjectReference new var: self]
	⇑super asRemoteCode: generator]\gb25B
bfpSize
	[⇑[self<0⇒ [2]; >8⇒ [2] 1]]\gb9B
emitBfp: code on: stack
	[stack pop: 1.
	0=self⇒ [code next ← toPop]
	1≤self and⦂ self≤8⇒ [code next ← self+toShortBfp-1] "short bfp"
	code emitLong: toLongBfp by: self]\gb25B97i11I
emitBytes: code  | c t
	[self<256⇒ [code next ← self]
	c ← self lshift: ¬8. t ← self land: 0377.
	↪(16 16 32 48 48)◦c > t⇒ [code next ← ↪(0 16 32 64 208)◦c+t]
	code next ← toLoadFieldLong+c-1; next ← t]\gb17B5b2B
emitForValue: code on: stack
	[[self=toSuper⇒ [code next ← toLoadSelf] self emitBytes: code].
	stack push: 1]\gb30B
emitJmp: code on: stack
	[0=self⇒ []
	1≤self and⦂ self≤8⇒ [code next ← self+toShortJmp-1] "short jmp"
	code emitLong: toLongJmp by: self]\gb25B65i11I
emitsLoad
	[self<256⇒ [⇑self<toSmashPop] ⇑self<codeSendLit]\gb11B
emittedVariable
	[[self<256⇒[self≤toSuper] self<codeSendLit]⇒[] ⇑false]\gb17B
findMacros: macros compilerTemps: compilerTemps | i j assignment
	[self<codeLoadTemp or⦂ self>(codeLoadTemp+255)⇒[]
	"this temp is not compiler-generated"
	j ← self-codeLoadTemp+1.
	compilerTemps◦j≡false⇒[]
	compilerTemps◦j≡nil⇒[compilerTemps◦j ← false]
	"The temp isn't compiler-generated after all!!  Nil out the macro"
	for⦂ i from: macros position to: 2 by: ¬2 do⦂
		[assignment ← macros◦(i-1) ◦ (macros◦i).
		assignment var=self⇒
			[macros◦i ← nil.  macros◦(i-1) ← nil.
			compilerTemps◦j ← false.
			⇑nil]].
	user notify: 'couldnt find bad macro']\gb48B70i35I103i64I
firstPush\gb
isField
	[⇑self≥codeLoadField and⦂ self<codeLoadTemp]\gb9B
jmpSize
	[⇑[self=0⇒ [0]; <0⇒ [2]; >8⇒ [2] 1]]\gb9B
printon: strm indent: level precedence: p forValue: v decompiler: decompiler
	[v≡false⇒[]
	self<112⇒[user notify: 'unknown code'];
		<128⇒[strm append: ↪('sender' 'self' '?' '?' '?' '?' '?' '?'
				'¬1' '0' '1' '2' '10' 'nil' 'false' 'true')◦(self-111)];
		=133⇒[strm append: 'thisContext'];
		=134⇒[strm append: 'super'];
		<167⇒[user notify: 'unknown code'];
		<208⇒[strm append: SpecialOops◦(self-166)];
		<256⇒[user notify: 'unknown code'];
		<512⇒[strm append: (decompiler instvar: self)];
		<768⇒[strm append: (decompiler temp: self)];
		<1024⇒[strm append: (decompiler literal: self)];
		<1280⇒[strm append: (decompiler literalIndirect: self)]
	strm append: (decompiler selector: self)]\gb78B
sizeForValue
	[self<256 or⦂	↪(16 16 32 48 48)◦(self lshift: ¬8) > (self land: 0177)⇒ [⇑1]
	⇑2]\gb14B

LargeInteger Compatability\gbf5 
◦ n | t
	["behave like a Natural"
	n = 1 ⇒ [self < 0 ⇒ [⇑((((self land: 0377) lxor: 0377) + 1) land: 0377)]
					⇑self land: 0377]
	n = 2 ⇒ [self < 0 ⇒ [t ← ((self lshift: ¬8) lxor: 0377).
									(self land: 0377) = 0 ⇒[⇑((t+1) land: 0377)]
									⇑t]
					⇑ self lshift: ¬8]
	⇑0]\gb9B
bytes
	["behave like a LargeInteger - negative integers behave like positive naturals"
	⇑self]\gb7B
isInt
\gb
last
	[⇑self◦self length]\gb6B
length
	["behave like a Natural"
	(self ≥ 256) or⦂ (self ≤ ¬256) ⇒ [⇑2]
	⇑1]\gb8B
natcompare: arg | i len [
	len ← self length.
	arg length < len⇒[⇑3]; > len⇒[⇑1]
	for⦂ i from: len to: 1 by: ¬1 do⦂
		[(self◦i)>(arg◦i)⇒[⇑3];
				<(arg◦i)⇒[⇑1]].
	⇑2]\gb16B
natnormalize: n | x i r f digit
	["n is the number of bits to shift by. The Natural number returned will be written over repeatedly, so we must make a new one."
	r ← (Natural new: (self length+1)).
	x ← 0.
	f ← n-8.
	for⦂ i to: r length do⦂
		[digit ← self ◦i.
		r◦i ← (digit lshift: n) lor: x.
		x ← digit lshift: f.].
	⇑r]\gb16B
neg
	["behave like a LargeInteger"
	(self < 0)⇒[⇑true]⇑false]\gb5B

As yet unclassified\gbf5 
asInt32 [⇑ Int32 new high: 0 low: self]\gb8B
between: min and: max
	[⇑self≥min and⦂ self≤max]\gb23B
\g
SystemOrganization classify: ↪Integer under: 'Numbers'.\g
Integer classInit\g

"LargeInteger"l15000z20000\gbf5 
Class new title: 'LargeInteger'
	subclassof: Number
	fields: 'bytes	"A Natural number (digits are 0 to 255)"
				 neg	"The sign" '
	declare: '';
	asFollows\gbf5 

LargeInteger is a class of Numbers with integral values of arbitrary precision. The values are stored as a Natural number that has digits between 0 and 255. The real work is done in Natural, which uses MachineDouble for single digit calculations. The first element of bytes contains the lowest precision digit.
All of the Bit Manipulation messages behave like the integer is represented in twos complement and then truncates the number to 16 bits before operating upon it. The value is always a Small integer.\gi

Access\gbf5 
bit: index | byte
	"Return bit number i in the binary representation of this number. Bit number 1 is the low order bit"
	[byte ← bytes◦(1+((index-1)/8)).
	 ⇑(byte lshift: (0-((index-1)\8))) land: 1]\gb11B
bytes
	[⇑bytes]\gb7B
bytes: bytes neg: neg
	[while⦂ bytes isLarge do⦂ [bytes←bytes bytes]]\gb23B
hibit
	"Return the index of the high order bit of the binary representation of this number"
	[⇑bytes last hibit+(8*(bytes length-1))]\gb7B
neg
	[⇑neg]\gb5B
neg ← neg |  "Smashes sign - be careful!"\gb10B

Arithmetic\gbf5 
≤ arg [(self compare: arg)<3⇒[⇑self] ⇑false]\gb6B
≥ arg [(self compare: arg)>1⇒[⇑self] ⇑false]\gb6B
* arg | as r
	["take care of sign. Arithmetic is done in Natural numbers. 
			if arg is Small, it behaves as a LargeInteger."
	as ← arg neg.
	r ← bytes nattimes: arg bytes.
	⇑LargeInteger new bytes: r neg: ((neg≡as)≡false)]\gb6B
+ arg | as r
	["take care of sign. Arithmetic is done in Natural numbers. 
			if arg is Small, it behaves as a LargeInteger."
	as ← arg neg.
	neg ≡ as ⇒[r←bytes natadd: arg bytes. ⇑LargeInteger new bytes: r neg: neg]
	r ← bytes natsubtract: arg bytes.
	neg ⇒ [⇑ r negate].
	⇑r]\gb6B
- arg | as r
	["take care of sign. Arithmetic is done in Natural numbers. 
			if arg is Small, it behaves as a LargeInteger."
	as ← arg neg.
	neg ≡ as ⇒
		[r ← bytes natsubtract: arg bytes.
		neg ⇒ [⇑ r neg← (r neg ≡ false)].
		⇑r]
	r←bytes natadd: arg bytes.
	⇑LargeInteger new bytes: r neg: neg]\gb6B
/ arg
	[⇑(self intdiv: arg)◦1]\gb7B
< arg [(self compare: arg)=1⇒[⇑self] ⇑false]\gb6B
= arg
	[arg isNumber⇒
		[(self compare: arg)=2⇒[⇑self] ⇑false]
	 ⇑false]\gb7B
> arg [(self compare: arg)=3⇒[⇑self] ⇑false]\gb6B
abs "Return the positive magnitude (absolute value) of this LargeInteger"
	[⇑LargeInteger new bytes: bytes neg: false]\gb4B69b2B
compare: arg | i a
	[[(((bytes length = 1) and⦂ (bytes◦1=0)) and⦂ (arg bytes length =1)) and⦂ (arg bytes◦1=0)⇒[⇑2]].
	neg⇒
		[arg neg⇒[⇑arg bytes natcompare: bytes] ⇑1]
	arg neg⇒[⇑3]
	⇑bytes natcompare: arg bytes]\gb13B
even | 
	[⇑(((bytes ◦ 1) land: 1) = 0)]\gb5B
intdiv: arg | quo rem ng qr z
	["returns a vector of (quotient, remainder)"
	qr ← bytes natdiv: arg bytes.
	quo ← qr◦1.
	rem ← (qr◦2) asInteger.
	ng ← (neg≡arg neg)≡false.
	[quo last = 0 ⇒ [quo length<2⇒[]
							quo ← quo growby: ¬1]].
	qr◦1←(LargeInteger new bytes: quo neg: ng).
	qr◦2 ← [ng and⦂ 0≠rem⇒ [arg abs-rem] rem].
	⇑qr]\gb12B
negate
	[⇑LargeInteger new bytes: bytes neg: (neg≡false)]\gb8B
negated
	[⇑LargeInteger new bytes: bytes neg: neg≡false]\gb9B
\ arg
	[⇑(self intdiv: arg)◦2]\gb7B

Conversion\gbf5 
asFloat		"Built for comfort, not for speed"
	[⇑self asString asFloat]\gb7i2B34I
asInteger
	[bytes length>2⇒[⇑self]
	 self≤077777 and: self≥0100000⇒
		[⇑self asSmall]
	 ⇑self]\gb11B
asLarge\gb
asSmall | t
	[t ← (bytes◦1).
	 [bytes length > 1 ⇒ [t ← (t field: 0210 ← (bytes◦2))]].
	 neg ⇒[t = ¬32768⇒[⇑¬32768] ⇑0-t]
	 ⇑t]\gb8B
isLarge\gb

Printing\gbf5 
printon: strm base: b
	[[neg ⇒ [strm append: '¬']].
	bytes printon: strm base: b]\gb23B

Bit Manipulation\gbf5 
allmask: b [⇑b = (self land: b)]\gb11B
anymask: b [⇑0 ≠ (self land: b)]\gb11B
field: n
	[⇑self asSmall field: n]\gb10B
field: n ← val
	[⇑self asSmall field: n ← val]\gb16B
hash [⇑bytes hash]\gb5B
land: n
	[⇑self asSmall land: n]\gb9B
lshift: n
	[⇑self asSmall lshift: n]\gb11B
nomask: b [⇑0 = (self land: b)]\gb10B
\g
SystemOrganization classify: ↪LargeInteger under: 'Numbers'.\g

"MachineDouble"l15000z20000\gbf5 
Class new title: 'MachineDouble'
	subclassof: Number
	fields: 'high low'
	declare: 'low4 low8 high4 high8 ';
	asFollows\gbf5 

MachineDouble is intended to be used by people who are implementing multiple precision arithmetic. It is hard to use - be careful! These are not ordinary numbers.
A MachineDouble behaves like a double precision register on an 8-bit machine. Accessing and setting the high and low words of the register are legitimate. Extract returns the low word and shifts the register right by one word, while propagating the sign. This turns out to be very convenient for addition and subtraction to propagate carries and borrows. Sometimes it does too much, but it is faster than using two other messages. Arithmetic is all unsigned, but decreaseby:, when answer is negative, uses twos complement notation to represent borrows.
On the NoteTaker, each half of the MachineDouble will be a complete 15-bit unsigned quantity. Obtaining the low or high half may return a negative number that should be considered to be positive (unsigned). The unsignedadd: and unsignedlessthan: messages to integers allow such numbers to be used without creating large integers.
This class will be Nova-coded soon.\gi

Access\gbf5 
extract | x
	["returns low, moves high down and propagates sign."
	x ← low.
	low ← high.
	high ← [(low land: 0200)=0 ⇒[0] 0377].
	⇑x]\gb8B
high
	[⇑high]\gb6B
high ← high
	[⇑self]\gb13B
low
   [⇑low]\gb7B
low ← low
   [⇑self]\gb13B

Arithmetic\gbf5 
< arg
	[high = arg high⇒[⇑low < arg low]
	⇑high < arg high]\gb7B
decreaseby: y | x "y is a positive <256 integer"
	[x ← low - y.
	[x < 0 ⇒[high ← (high-1) land: 0377]].
	low ← x land: 0377.
	⇑self]\gb14B
gets: x mtimes: y | xh xl yh yl p1 p2
	["x and y are 8-bit positive #'s.
      Does single precision unsigned multiplication
      returning a double precision result."
    xh ← x field: high4.
    xl ← x field: low4.
    yh ← y field: high4.
    yl ← y field: low4.
    low ← yl * xl.
    high ← yh * xh.
    p2 ← yh * xl.
    p1 ← (p2 + (yl * xh)).
    high ← high + (p1 lshift: ¬4).
    low ← ((p1 land: 017) lshift: 4) + low.
    [low ≥ 256 ⇒ [high ← high + 1. low ← low - 256.]].
    ⇑self]\gb18B
increaseby: y | x "y is a positive <256 integer"
	[x ← low + y.
	[x > 255 ⇒[high ← (high+1) land: 0377]].
	low ← x land: 0377.
	⇑self]\gb14B
mdiv: y | x
	["Ignores y high (assumes it to be zero. Also assumes that y > x high.
      This does a single precision unsigned divide into a double precision dividend
      that results in a single precision quotient (returned) and
      a single precision remainder(placed in self high)."

	high < 128 ⇒ [x ← (high lshift: 8) + low.
						high ← x\y.
						⇑x/y.]
	high > y ⇒ [user notify: 'illegal MachineDouble division']
	x ← ((high lshift: 1) + (low lshift: ¬7)) - y.
	high ← x lshift: ¬1.
	low ← (low field: 027 ← x).
	⇑((self mdiv: y) + 128)]\gb8B

As yet unclassified\gbf5 
asInt | n i "may return a negative number"
	[⇑((high lshift: 8) lor: low)]\gb6B
classInit
	["low4 is a field description for the low order 4 bits of an Integer
      high4 is a field description for the high order 4 bits of an 8-bit Integer"
	low4 ← 0100.
    high4 ← 0104]\gb11B
init
	[low ← 0. high ← 0. ⇑self]\gb6B
printon: strm | 
	[strm append: '[MachineDouble 0'.
     high printon: strm base: 8.
     strm append: ' 0'.
     low printon: strm base: 8.
     strm append: ']']\gb14B
\g
SystemOrganization classify: ↪MachineDouble under: 'Numbers'.\g
MachineDouble classInit\g

"Time"l15000z20000\gbf5 
Class new title: 'Time'
	subclassof: Object
	fields: 'h m s'
	declare: '';
	asFollows\gbf5 

Implements times of day.  Still needs a lot of work.  (Steve Weyer)\gi

Setting state\gbf5 
default ["right now" ⇑user now◦2]\gb8B2i9I
fromSeconds: sec [
	"seconds since midnight (adjusted for time zone and DST)"
	sec ← sec asInteger intdiv: 3600.
	h ← (sec◦1) asSmall.
	sec ← (sec◦2) asSmall.
	m ← sec / 60.
	s ← sec \ 60]\gb17B
hours: h\gb
minutes: m\gb
seconds: s\gb

Printing\gbf5 
printon: strm "Format is h:mm:ss am/pm" [
	strm print: [h>12⇒[h-12]; <1⇒[12] h];
		append: [m < 10⇒ [':0'] ':']; print: m;
		append: [s < 10⇒ [':0'] ':']; print: s;
		space append: [h<12⇒['am'] 'pm']]\gb14Bi25I

Aspects\gbf5 
asSeconds [⇑3600 * h + (60*m+s)]\gb10B
hours [⇑h]\gb6B
\g
SystemOrganization classify: ↪Time under: 'Numbers'.\g
