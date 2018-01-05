↪FILES AND DIRECTORIES
June 15, 1977  1:18 PM↪

Integer understands: 'allmask: b [!b = (self land: b)]'
Integer understands: 'anymask: b [!0 ≠ (self land: b)]'
Integer understands: 'nomask: b [!0 = (self land: b)]'
Integer understands: 'asLowercase
	[0101 ≤ self? [
		self ≤ 0132? [!self + 040]]]'
Integer understands: 'asUppercase
	[0141 ≤ self? [
		self ≤ 0172? [!self - 040]]]'
Integer understands: 'compareChar: c
	[!self asLowercase compare: c asLowercase]'

Number understands: 'compare: i
	[self < i? [!1]
	self = i? [!2]
	!3]'

String understands: 'compare: s | i v
	[for⦂ i to: (self length min: s length) do⦂
		[self◦i = (s◦i)? []
		v ← self◦i compareChar: s◦i.
		v ≠ 2? [!v]]
	!self length compare: s length]'

String understands: '< s [!1 = (self compare: s)]'
String understands: '= s [
	self length = s length? [!2 = (self compare: s)]
	!false]'
String understands: '> s [!3 = (self compare: s)]'

UserView understands: 'read [!disp read]'


Smalltalk define "Filestuff as "Filestuff ← SymbolTable new.
↪disk commands↪
Filestuff insertall: "(CRR CRW CCR CCW CWW)
	with: "(044100 044110 044120 044130 044150)
↪disk label↪
Filestuff insertall: "(nextp backp lnused numch pagen version sn1 sn2)
	with: "(1 2 3 4 5 6 7 8)
Filestuff insertall: "(read write shorten) with: "(1 2 4)
Filestuff insertall: "(old oldornew new created) with: "(1 2 3 4)
Filestuff insertall: "(dfmask boffset) with: "(02000 040)
Filestuff insertall: "(dirname defdir pagelength) with: "('SysDir.' nil 512)


Class new title: 'File';
	subclassof: Stream; ↪except end, pastend (←), reset, contents, skip↪
	fields: ↪array position limit↪ 'dirinst filename rvec label rwmode leader curadr status';
	sharing: 'Filestuff'

File understands: 'readonly [rwmode ← read]'
File understands: 'readwrite [rwmode ← read + write]'
File understands: 'writeonly [rwmode ← write]'

File understands: 'old [status ← old]'
File understands: 'oldornew [status ← oldornew]'
File understands: 'new [status ← new]'

File understands: 'on: dirinst []'
File understands: 'random [rvec ← Vector new: 0]'

File understands: 'dskio: curadr
		command: command
		page: startpage
		pages: npages
		onerror⦂ exp
	[!exp eval] primitive: 80'

File understands: 'docommand: com [
	self dskio: curadr
		command: com
		page: label◦pagen
		pages: 1
		onerror⦂ [!self error: ''docommand'']]'

File understands: 'error: s [
	user notify: ''File error: ''+s+'' in ''+filename asString.
	!false]'

File understands: 'named: filename [
	filename ← self namecheck: filename? [!self find]
	!false]'

File understands: 'namecheck: name | i x [
	name length = 0? [!self error: ''empty name'']
	name length > 255? [!self error: ''name too long'']
	for⦂ i to: name length do⦂ [
		↪check characters↪
		x ← name◦i.
		x isletter? []
		x isdigit? []
		0 = (''+-$!?.'' find: x)? [
			!self error: ''illegal character '' + (name◦(i to: i))]]
	x ≠ (''.''◦1)? [!name + ''.'']
	!name]'

File understands: 'getname: name | t [
	user show: ''type a file name''.
	user show: [name length > 0? ['', just  for '' + name] '' '']
	t ← user read.
	t ≡ false? [!false]
	!self named: [t ≡ nil? [name] t]]'

File understands: 'reopen [
	self dskio: leader
		command: CCR
		page: 0
		pages: 1
		onerror⦂ [
			↪leader page failed↪
			self oldornew.
			!self find].
	filename ≠ (array◦(14 to: array◦13 + 13))? [
		↪name failed - how about ser no~↪
		self oldornew.
		!self find]

	[rvec ≡ nil? []
	self random].
	self old.
	self init]'

File understands: 'find | entry [
	↪some defaults↪
	[status ≡ nil? [self oldornew]].
	[rwmode ≡ nil? [self readwrite]].
	[dirinst ≡ nil? [self on: defdir]].
	[array ≡ nil? [self of: (String new: pagelength)]].
	label ← Vector new: 8.
	label◦nextp ← 0.
	label◦backp ← 0.
	label◦lnused ← 0.
	label◦numch ← pagelength.
	label◦pagen ← 0.
	entry ← dirinst find: filename? [
		status = new? [!false]
		label◦sn1 ← entry word: 2.
		label◦sn2 ← entry word: 3.
		label◦version ← entry word: 4.
		self dskio: (leader ← self virtualToAlto: (entry word: 6))
			command: CCR
			page: 0
			pages: 1
			onerror⦂ [!self error: ''leader page''].
		self init]
	status = old? [!false]
	rwmode nomask: write? [!false]
	(leader ← dirinst alloc: 0) ≡ false? [!false]
	entry ← dirinst getNewSn.
	label◦sn1 ← entry word: 1.
	label◦sn2 ← entry word: 2.
	label◦version ← 1.

	status ← created ↪for leaderstamp↪.
	↪6 header words, length char, filename, possible null↪
	entry ← String new: 13 + (filename length lor: 1).
	entry word: 1 ← entry length/2 lor: dfmask.
	entry word: 2 ← label◦sn1.
	entry word: 3 ← label◦sn2.
	entry word: 4 ← label◦version.
	entry word: 5 ← 0 ↪~↪.
	entry word: 6 ← self altoToVirtual: leader.
	entry◦13 ← filename length.
	entry◦(14 to: 13+filename length) ← filename.
	self init.
	dirinst next ← entry]'

File understands: 'init | oldmode s [
	s ← String new: 4.
	s word: 1 ← mem◦0572.
	s word: 2 ← mem◦0573.
	oldmode ← rwmode.
	self readwrite.

	↪assumes positioned at page 0↪
	position ← 0.
	[status ≠ created? [self skip: 4]
	self append: s].	↪creation date↪

	[oldmode allmask: write? [self append: s]	↪write date↪
	self skip: 4].
	
	↪read date↪
	self append: s.

	[status = created? [
		self next ← filename length.	↪file name (Bcpl style)↪
		self append: filename]].

	[rvec ≡ nil? []
	↪random access↪
	self settoend.
	[label◦pagen > rvec length? [
		rvec ← rvec copyto: (Vector new: label◦pagen)]].
	for⦂ s to: rvec length do⦂ [
		rvec◦s ≡ nil? [
			self settopage: s char: 0.
			rvec◦s ← curadr]]].

	self reset.
	rwmode ← oldmode]'

File understands: 'flush [
	rwmode nomask: write? [!false]
	label◦numch < position? [
		position ≠ pagelength? [self docommand: CWW]
		label◦nextp = 0? [self extendto: label◦pagen + 1]
		self docommand: CWW]
	self docommand: CCW]'

File understands: 'settopage: page char: char | pch pn [
	pch ← [char<0? [0-char] char].	page ← pch/pagelength + page.
	pch ← pch \ pagelength.	[char < 0 and: pch ≠ 0?[
		pch ← pagelength - pch.		page ← page-1]].
	page < 0? [!self error: ''negative page'']
	↪possibly write current page↪	[label◦pagen < page and⦂ label◦nextp = 0? [self extendto: page]	self flush].
	↪try random access↪	[rvec ≡ nil? []
	label◦pagen = page? [↪already there↪]
	↪chain read from the nearest page we can↪	pn ← page min: rvec length.	while⦂ [pn > 0 and⦂ rvec◦pn ≡ nil] do⦂ [pn ← pn - 1]	self dskio: [pn = 0? [leader] rvec◦pn]
		command: CCR page: pn pages: page+1-pn
		onerror⦂ [!self error: ''random access'']].
	↪do sequential reads to get there, possibly extending file↪
	[label◦pagen < page? [		↪chained read forward↪
		[label◦nextp ≠ 0? [			self dskio: label◦nextp
				command: CCR				page: label◦pagen+1
				pages: page-(label◦pagen)
				onerror⦂ [!self error: ''forward chaining'']]].
		label◦pagen = page? [↪finished↪]
		rwmode allmask: write? [self extendto: page]
		↪change the request↪		page ← label◦pagen]
	label◦pagen > page?		[label◦pagen-1 = page?
			[↪one page backwards↪
			self dskio: label◦backp
				command: CCR page: page pages: 1
				onerror⦂ [!self error: ''reading backwards'']]
		↪forward from leader↪		self dskio: leader
			command: CCR			page: 0			pages: page+1
			onerror⦂ [!self error: ''leader reading'']]].
	label◦pagen ≠ page? [!self error: ''didnt get to page'']
	position ← [rwmode allmask: write? [pch] label◦numch min: pch].	limit ← label◦numch]'

File understands: 'end [
	position < (label◦numch)? [!false]
	!label◦nextp = 0]'

File understands: 'pastend [
	self end? [!false]
	self settopage: label◦pagen+1 char: 0.
	!self next]'

File understands: 'pastend ← x [
	[limit < pagelength? [limit ← pagelength]
	self settopage: label◦pagen+1 char: 0].
	!self next ← x]'

File understands: 'reset [self settopage: 1 char: 0]'

File understands: 'settoend | oldmode [
	self flush.
	oldmode ← rwmode.
	self readonly.
	self settopage: 5000 char: 0.
	rwmode ← oldmode]'

File understands: 'contents | s [
	self settoend.
	s ← String new: (label◦pagen-1)*pagelength + (label◦numch).
	self reset.
	!self into: s]'

File understands: 'skip: n [
	position ← position + n.
	position <  0 or: position ≥ limit? [
		self settopage: label◦pagen char: position]]'

File understands: 'positioneven [
	position allmask: 1? [self skip: 1]]'

File understands: 'nextword | s [
	position ← position + 1 | 2.
	self end? [!false]
	s ← self into: (String new: 2).
	!s word: 1]'

File understands: 'nextword ← w | s [
	s ← String new: 2.
	s word: 1 ← w.
	self positioneven.
	self append: s]'

File understands: 'close [
	rwmode allmask: shorten? [self shortento: label◦pagen char: position]
	self flush]'

File understands: 'extendto: dest [
	rwmode nomask: write? [!false]
	[rvec ≡ nil? []
	rvec ← rvec copyto: (Vector new: dest)].
	until⦂ label◦pagen = dest do⦂ [
		label◦nextp ← dirinst alloc: curadr.
		label◦numch ← pagelength.
		self docommand: CWW.
		label◦backp ← curadr.
		curadr ← label◦nextp.
		label◦pagen ← label◦pagen + 1.
		rvec ≡ nil? []
		rvec◦(label◦pagen) ← curadr]
	label◦nextp ← 0.
	label◦numch ← 0.
	position ← 0.
	self docommand: CWW]'

File understands: 'shortento: page char: char [
	rwmode nomask: write? [!false]
	self settopage: page char: char.
	dirinst dealloc: label◦nextp.
	label◦nextp ← 0.
	label◦numch ← label◦numch min: char.
	self docommand: CWW.
	rvec ≡ nil? []
	rvec ← rvec copyto: (Vector new: label◦pagen)]'

File understands: 'delete [
	rwmode allmask: write? [
		dirinst delete: filename? [dirinst dealloc: leader]
		!false]
	!false]'

File understands: 'rename: newname [
	rwmode nomask: write? [!false]
	(newname ← self namecheck: newname) ≡ false?
		[!self error: ''badnew name'']	
	dirinst find: newname? [!self error: newname + '' already exists'']
	(dirinst rename: filename to: newname) ≡ false?
		[!self error: ''file not there'']
	filename ← newname.
	self settopage: 0 char: 12.
	self next ← filename length.
	self append: filename]'

File understands: 'virtualToAlto: vadr [
	!(vadr \ 12 lshift: 12) + (vadr/12 * 4)]'

File understands: 'altoToVirtual: dadr [
	!(dadr lshift: ¬12) + (3 * (dadr land: 07774))]'

File understands: 'altoToKeys: dadr | i k [
	k ← Stream default.
	for⦂ i to: 14 do⦂ [
		dadr allmask: (0100000 lshift: 1-i)? [
			k next←''546E7DUV0K-P/\''◦i]]
	!k contents]'

File understands: 'last ← x [
	self skip: ¬1.
	self next ← x]'

File understands: 'appendlast: x [
	self skip: 0-x length.
	self append: x]'

File understands: 'zaplabel [
	label◦nextp ← 0.
	label◦pagen ← 0.
	label◦sn1 ← ¬1.
	label◦sn2 ← ¬1.
	label◦version ← ¬1]'

File understands: 'fileid | v [
	v ← Vector new: 5.
	v◦1 ← label◦sn1.
	v◦2 ← label◦sn2.
	v◦3 ← label◦version.
	v◦4 ← 0.
	v◦5 ← curadr.
	!v]'

File understands: 'curadr [!curadr]'
File understands: 'nextp [!nextp]'

↪other unimplemented File messages:
load, save, copyto, length, remove, exists...↪

Class new title: 'Directory';
	fields: 'dirinst bitinst filinst junkfile closed';
	sharing: 'Filestuff'

Directory understands: 'reset [
	↪only system directories implemented now↪
	closed? [
		closed ← false.
		filinst ≡ nil? [
			filinst ← [File new readwrite old on: self; named: dirname].
			bitinst ← [File new readwrite old on: self; named: ''DiskDescriptor.''].
			junkfile ← [File new readwrite old on: self; named: ''Com.cm.'']]
		filinst reopen.
		bitinst reopen.
		junkfile reopen]
	filinst reset.
	bitinst ≡ nil ?[] bitinst flush]'

Directory understands: 'open [self reset]'

Directory understands: 'File [!File new on: self]'

Directory understands: 'close [
	filinst close.
	bitinst close.
	closed ← true]'

Directory understands: 'asStream'
Directory understands: 'next | w [
	w ← filinst nextword? [
		filinst skip: ¬2.
		!filinst into: (String new: 2 * (w land: dfmask-1))]
	!false]'
Directory understands: 'next ← entry [
	filinst append: entry.
	filinst flush]'

Directory understands: 'find: name | entry [
	name = dirname? [
		entry ← String new: 12.
		entry word: 2 ← 0100000.
		entry word: 3 ← 0.
		entry word: 4 ← 1.
		entry word: 6 ← 1.
		!entry]
	self reset.
	for⦂ entry from: self do⦂ [
		(entry word: 1) allmask: dfmask? [
			↪normal entry, check name↪
			entry◦13 ≠ name length? []
			name = (entry◦(14 to: entry◦13 + 13))? [!entry]]
		↪deleted entry↪]
	!false]'

Directory understands: 'list | entry [
	self reset.
	for⦂ entry from: self do⦂ [
		(entry word: 1) allmask: dfmask? [
			user show: entry◦(14 to: entry◦13 + 13)]
		↪ignore deleted entries↪]]'

Directory understands: 'delete: name | entry [
	entry ← self find: name? [
		↪mark entry as deleted↪
		filinst skip: 0- entry length.
		filinst nextword ← (entry word: 1) land: dfmask-1.
		↪filinst skip: ¬2↪
		filinst flush]
	!false]'

Directory understands: 'rename: name to: newname | entry nentry [
	entry ← self find: name? [
		↪assumes newname already checked to be not there↪
		nentry ← String new: (newname length lor: 1) + 13.
		nentry word◦ 1 ← nentry length/2 lor: dfmask.
		nentry◦(3 to: 12) ← entry◦(3 to: 12).
		nentry◦13 ← newname length.
		nentry◦(13 to: 13+newname length) ← newname.
		↪mark old entry deleted↪
		filinst skip: 0- entry length.
		filinst nextword ← (entry word: 1) land: dfmask-1
		filinst settoend.
		self append: nentry]
	!false]'
	
Directory understands: 'alloc: dadr | index start stop ch i m [
	↪starting place in bittable↪
	start ← (bitinst altoToVirtual: dadr) land: 0177770.
	stop ← 4872 ↪see free↪.
	for⦂ i to: 2 do⦂ [
		↪up to two passes through table↪
		bitinst settopage: 1 char: start/8 + boffset.
		for⦂ index from: (start to: stop by: 8) do⦂ [
			ch ← bitinst next.
			ch = 0377? []
			m ← 0200.
			while⦂ m > 0 do⦂ [
				(ch land: m) ?[
					ch ← ch lor: m.
					↪check if page is really free↪
					junkfile zaplabel.
					junkfile dskio: (junkfile virtualToAlto: index)
						command: CRR
						page: 0
						pages: 1
						onerror⦂ [false] ?[m←¬1]]
				index ← index + 1.
				m ← m lshift: ¬1]
			↪update bittable↪
			bitinst last ← ch.
			m = ¬1? [!junkfile curadr]]
		stop ← start.
		start ← 0]
	bitinst error: ''nofreepages'']'

Directory understands: 'dealloc: dadr | index ch m [
	until⦂ dadr = 0 do⦂ [
		index ← bitinst altoToVirtual: dadr.
		bitinst settopage: 1 char: index/8 + boffset.
		↪mark page as free in bittable↪
		ch ← bitinst next.
		[ch allmask: (m ← 0200 lshift: 0-(index land: 7))? [
			bitinst last ← ch xor: m]
		↪already free~↪].
		junkfile dskio: dadr
			command: CRR
			page: 0
			pages: 1
			onerror⦂ [self error: ''dealloc'']
 		dadr ← junkfile nextp.
		junkfile zaplabel.
		junkfile docommand: CWW]
	bitinst flush]'

Directory understands: 'free | npages tpages ch i [
	self reset.
	↪bitinst settopage: 1 char: 2.
	tpages ← bitinst nextword * 24.↪
	tpages ← 4872.
	npages ← 0.
	bitinst settopage: 1 char: boffset.
	for⦂ i from: (1 to: tpages by: 8) do⦂ [
		ch ← bitinst next.
		ch = 0377? [npages ← npages+8]
		until⦂ ch = 0 do⦂ [
			[ch allmask: 1? [npages ← npages+1]]
			ch ← ch lshift: ¬1]]
	!tpages - npages]'

Directory understands: 'getNewSn | sn [
	bitinst settopage: 1 char: 010.
	sn ← bitinst into: (String new: 4).
	sn word: 2 ← (sn word: 2) + 1.
	[(sn word: 2) = 0? [sn word: 1 ← (sn word: 1) + 1]].
	bitinst appendlast: sn.
	bitinst flush.
	!sn]'

Directory understands: 'use [defdir ← self]'
Directory understands: 'on: dirinst []'

↪dp0 ← Directory new use on: 0↪

