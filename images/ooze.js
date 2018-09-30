//
// Transliteration of Hobbes's OOZE code
// http://www.squeaksource.com/@p3tr2oU-pspdtMYT/Cx8V2_P8
// Original Authors: Vassili Bykov, Dan Ingalls, Wolfgang Helbig
//

class OOZEHandle {
	constructor(snapshot, oop, address, zonePageArray, classOop, size, bytes, data, t) {
		this.snapshot = snapshot;
		this.oop = oop;
		this.address = address;
		this.zonePageArray = zonePageArray;
		this.classOop = classOop;
		this.maxSize = size;
		this.size = size;
		this.isBytes = bytes;
		this.immediateData = data;
		if (t != null) {
			if (this.size >= this.octaveSize()) {
				this.checkNewSize(this.at(t));
				if (t == 1) {
					this.address = this.address + 1;
				}
			}
		}
	}
	octaveSize() {
		if (this.classOop >= 384) return 20;
		return 999;  // No size is octave for fixed classes
	}
	checkNewSize(newSize) {
		this.maxSize = Math.pow(2, this.size - 16);
		if (newSize >= Math.floor((this.maxSize / 2) + 1) && newSize <= this.maxSize) {
			this.size = newSize;
		}
		else {
			this.size = 0;
		}
	}
	
	at(index) {
		if (this.zonePageArray == null) {
			if (this.immediateData != null) {
				if (index == 1) {
					return this.immediateData;
				}
				"self error: 'Attempt to access more than the immediate data'"
				return this.snapshot.nilOop();
			}
			return this.snapshot.word(this.address + index - 1);
		}
		var wordAddress = this.address + index - 1;
		var page = Math.floor(wordAddress / 256);
		var offsetInPage = wordAddress % 256;
		if ((page + 1) > this.zonePageArray.length) { return  -1 }
		var addr = (this.zonePageArray[page] * 256) + offsetInPage;
		var r = this.snapshot.oozeWord(addr);
		return r;
	}
	fields() {
		var r = new Array();
		for (var i=0; i<this.size; i++) {
			r.push(this.at(i));
		}
		return r;
	}
	location() {
		if (this.zonePageArray != null) return 'Nonresident';
		if (this.immediateData != null) return 'Immediate';
		return 'Resident';
	}
	valid() {
		if (this.zonePageArray == null) return true;

		var maxLen;
		if (this.isBytes) {
			maxLen = Math.floor((this.maxSize + 1) / 2); 
		}
		else {
			maxLen = this.maxSize;
		}

		var wordAddress = this.address + maxLen - 1;
		var page = Math.floor(wordAddress / 256);
		return (page + 1) <= this.zonePageArray.length;
	}
	bytes() {
		if (this.size == 0) {
			return [];
		}
		// You can ask a word object for its bytes and it returns the 2N bytes.
		// No check is made here for pointer fields or not.
		var bytes;
		if (this.isBytes == true) {
			bytes = new Uint8Array(this.size);
		}
		else {
			bytes = new Uint8Array(this.size * 2);
		}
		
		var word;
		for (var index=0; index<this.size; index++) {
			if (index % 2 == 0) {
				word = this.at(Math.floor((index / 2) + 1));
				bytes[index] = word >> 8;
			}
			else {
				bytes[index] = word & 0xff;
			}
		}
		return bytes;
	}

	set size(aSize) {
		this._size = aSize;
	}
	get size() {
		if (this.immediateData != null) { return Math.min(this._size, this.isBytes ? 2 : 1); }
		return this._size;
	}
	string() {
		var charmap = { 
			0x01:"≤", 0x03:"⦂", 0x06:"≡", 0x07:"◦", 0x0e:"≠", 0x0f:"↪",
			0x11:"⇑", 0x12:"≥", 0x13:"ⓢ", 0x15:"¬", 0x16:"∢", 0x17:"⌾",
			0x18:"▱", 0x19:"➲", 0x1b:"⇒", 0x5f:"←",
		};
		var s = '';
		var bytes = this.bytes();
		for (var i=0; i<bytes.length; i++) {
			var char = bytes[i];
			if (charmap[char] != null) {
				s += charmap[char];
			}
			else {
				s += String.fromCharCode(char);
			}
		}
		return s;
	}
	isOctave() {
		return this.maxSize >= this.octaveSize();
	}
	freeListLink() {
		// This access is special because for non-resident octave objects, the first field
		// link is in the size slot, not the normal first field.
		if (this.location == 'Nonresident' && this.isOctave()) {
			return this.at(0);
		}
		return this.at(1);
	}
}

class NovaCode {
	accMaskWithArgs(pair, args) {
		var mask = pair[0];
		var value = pair[1];

		// accumulator register
		var m = 0x0000;  var v = 0x0000;  // non numeric
		var first = args.shift();
		
		if (first == '0') { m = 0x1800;  v = 0x0000 }
		if (first == '1') { m = 0x1800;  v = 0x0800 }
		if (first == '2') { m = 0x1800;  v = 0x1000 }
		if (first == '3') { m = 0x1800;  v = 0x1800 }
		return this.mriMaskWithArgs([mask + m, value + v], args);
	}
	mriMaskWithArgs(pair, args) {
		var mask = pair[0];
		var value = pair[1];
		var m, v;
		if (args.length > 2) {
			throw "huh?";
		}
		if (args.length == 2) {
			var last = args[args.length - 1];
			// index register
			m = 0x0200;  v = 0x0200;  // has index, but not numeric
			if (last == '2') { m = 0x0300;  v = 0x0200 }
			if (last == '3') { m = 0x0300;  v = 0x0300 }
		}
		else {
			m = 0x0200;  v = 0x0000;  // rel to pc or page0
		}

		mask = mask + m;
		value = value + v;
		
		if (args.length > 0 && args[0].startsWith("@") == true) {
			m = 0x0400;  v = 0x0400  // indirect
		}
		else {
			m = 0x0400;  v = 0x0000  // direct
		}
		
		mask = mask + m;  value = value + v;
		return [ mask, value ];
	}
	logicMaskWithArgsModifiers(pair, args, mods) {
		// pair is a mask pair to be merged with the result of parsing the arguments
		var mask = pair[0];
		var value = pair[1];

		// source register 
		var m = 0x0000;  var v = 0x0000;  // non numeric
		var first = args[0];
		if (first == '0') { m = 0x6000;  v = 0x0000 }
		if (first == '1') { m = 0x6000;  v = 0x2000 }
		if (first == '2') { m = 0x6000;  v = 0x4000 }
		if (first == '3') { m = 0x6000;  v = 0x6000 }
		mask = mask + m;  value = value + v;

		// destination register
		m = 0x0000;  v = 0x0000;  // non numeric
		var second = args[1];
		if (second == '0') { m = 0x1800;  v = 0x0000 }
		if (second == '1') { m = 0x1800;  v = 0x0800 }
		if (second == '2') { m = 0x1800;  v = 0x1000 }
		if (second == '3') { m = 0x1800;  v = 0x1800 }
		mask = mask + m;  value = value + v;

		if (args.length == 3) { // skips
			m = 0;  v = 0;
			var third = args[2];
			if (third == 'SKP') { m = 0x0007;  v = 0x0001 }
			if (third == 'SZC') { m = 0x0007;  v = 0x0002 }
			if (third == 'SNC') { m = 0x0007;  v = 0x0003 }
			if (third == 'SZR') { m = 0x0007;  v = 0x0004 }
			if (third == 'SNR') { m = 0x0007;  v = 0x0005 }
			if (third == 'SEZ') { m = 0x0007;  v = 0x0006 }
			if (third == 'SBN') { m = 0x0007;  v = 0x0007 }
			if (m == 0) { throw 'huh?'}
		}
		else {
			m = 0x0007;  v = 0x0000 
		}	
		mask = mask + m;  value = value + v;

		// modifiers
		m = 0x0030;  v = 0;  "carry"
		if (mods.indexOf('Z') > 0) { v = 0x0010 }
		if (mods.indexOf('O') > 0) { v = 0x0020 }
		if (mods.indexOf('C') > 0) { v = 0x0030 }
		mask = mask + m;  value = value + v;

		m = 0x00C0;  v = 0;  "shift"
		if (mods.indexOf('L') > 0) { v = 0x0040 }
		if (mods.indexOf('R') > 0) { v = 0x0080 }
		if (mods.indexOf('S') > 0) { v = 0x00C0 }
		mask = mask + m;  value = value + v;

		m = 0x0008;  v = 0;  "no load"
		if (mods.indexOf('#') > 0) { v = 0x0008 }
		mask = mask + m;  value = value + v;

		return [mask, value]
	}
	patternForNovaLine(codeLine) {
		var line = codeLine.toUpperCase();
		var ix = line.indexOf(";");
		if (ix > 0) {
			line = line.substring(0, ix);
		}
		ix = line.indexOf(":");
		if (ix > 0) {
			line = line.substring(ix+1);
		}

		var tokens = line.trim().split(/[ \t,]/g);
		var args = tokens.splice(1);
		var op = tokens[0];
		
		if (op == "LDA") return this.accMaskWithArgs([0xE000, 0x2000], args);
		if (op == "STA") return this.accMaskWithArgs([0xE000, 0x4000], args);
		if (op == "JMP") return this.mriMaskWithArgs([0xF800, 0x0000], args);
		if (op == "JSR") return this.mriMaskWithArgs([0xF800, 0x0800], args);
		if (op == "ISZ") return this.mriMaskWithArgs([0xF800, 0x1000], args);
		if (op == "DSZ") return this.mriMaskWithArgs([0xF800, 0x1800], args);

		if (op == "SWATME") return [0xFFFF, 0x7f00];
		if (op == "UHASH") return [0xFFFF, 0x7401];
		if (op == "SKIP") return this.patternForNovaLine(' MOV 0,0,SKP');
		if (op == "JSRII")return [0, 0]; // ignore
		if (op == "BLT") return [0, 0];	// ignore
		
		var mods = op.substring(3);
		if (op == 'COM') return this.logicMaskWithArgsModifiers([0x8700, 0x8000], args, mods);
		if (op == 'NEG') return this.logicMaskWithArgsModifiers([0x8700, 0x8100], args, mods);
		if (op == 'MOV') return this.logicMaskWithArgsModifiers([0x8700, 0x8200], args, mods);
		if (op == 'INC') return this.logicMaskWithArgsModifiers([0x8700, 0x8300], args, mods);
		if (op == 'ADC') return this.logicMaskWithArgsModifiers([0x8700, 0x8400], args, mods);
		if (op == 'SUB') return this.logicMaskWithArgsModifiers([0x8700, 0x8500], args, mods);
		if (op == 'ADD') return this.logicMaskWithArgsModifiers([0x8700, 0x8600], args, mods);
		if (op == 'AND') return this.logicMaskWithArgsModifiers([0x8700, 0x8700], args, mods);

		// Not recognized -- allow anything
		return [0, 0];
	}
	patternForNovaLines(linesOfCode) {
		var lines = linesOfCode.split(/\n/);
		lines = lines.filter(s => { return s.length > 0 });
		return lines.map(s => { return this.patternForNovaLine(s) } );
	}
}

class OOZEImage {
	constructor() {
		this.jumps = [0, 603, 570, 471, 410, 353, 300, 253, 210, 169, 132, 101, 72, 49, 30, 13];
	}
	word(wordAddress) {
		return this.memWords[wordAddress];
	}
	oozeWord(wordAddress) {
		// Access words in the ooze part of the file, past the ram image
		return this.memWords[wordAddress + this.oozeBase];
	}
	matchPatternAt(pattern, loc) {
		for (var i=0; i<pattern.length; i++) {
			var pair = pattern[i];
			var mask = pair[0];
			var value = pair[1];
			if ((this.memWords[loc + i] & mask) != value) {
				return false;
			}
		}
		return true;
	}
	findNovaCode(code) {
		var nova = new NovaCode();
		var pattern = nova.patternForNovaLines(code);
		var locs = new Array();
		for (var i=0; i<65000; i++) {
			if (this.matchPatternAt(pattern, i) == true) {
				locs.push(i);
			}
		}
		return locs;
	}
	rotAddr(oop) {
		var rootHash = this.rhash(oop);
		var residue = rootHash & 0xF800;
		const rpcMax = 7;
		var rpcs = [0, 13, 30, 49, 72, 101, 132, 169];
		for (var rpc=0; rpc<=rpcs.length; rpc++) {
			var probeAddr = this.rotBase + (((rootHash + rpcs[rpc]) * 2) & (Math.floor(this.rotSize/2) - 1));
			var rotWord0 = this.memWords[probeAddr];
			if ((rotWord0 & 0xf0) == 0xf0) {
				// Should return nil, but then does not find oop=26313
				if (oop != 2631) {
					return null; // empty entry
				}
			}
			
			if ((rotWord0 & 0xf800) == residue) {
				if (((rotWord0 >> 8) & 7) == rpc) {
					return probeAddr;
				}
			}
		}
		return null; // end of reprobe chain
	}
	rhash(oopOrIndex) {
		// reversible root hash
		return ((oopOrIndex & 0xff) << 8) ^ oopOrIndex;
	}
	hash(oop) {
		// Returns {ROT word 0. ROT word 1} if found; else nil"
		var rotAddr = this.rotAddr(oop);
		if (rotAddr == null) {
			// empty or end of reprobe chain
			return null;
		}
		// If immediate data, then pair second is the data"
		return [ this.memWords[rotAddr], this.memWords[rotAddr + 1] ];
	}
	isImmediate(rotEntry) {
		return ((rotEntry[0] & 4) != 0); 
	}
	pmEntry(oop) {
		var pClass = oop >> 7;
		var pmAddr = this.pmBase + (2*pClass);
		if (this.memWords[pmAddr] == 0) {
			// attempt to access an invalid pclass
			return null;
		}
		return [ this.memWords[pmAddr], this.memWords[pmAddr + 1] ];
	}
	classSizeAndBytesFor(oop) {
		var pmEntry = this.pmEntry(oop);
		if (pmEntry == null) {
			return null;
		}
		return [ pmEntry[0] >> 7, pmEntry[0] & 0x1F, (pmEntry[0] & 0x20) == 0];
	}
	residentHandle(oop) {
		// Returns an OOZEHandle for resident objects, and nil otherwise.
		var rotEntry = this.hash(oop);
		if (rotEntry == null) {
			// Not found in ROT
			return null;
		}
		var csb = this.classSizeAndBytesFor(oop);
		if (csb == null) {
			return null;
		}
		
		var handle = null;
		if (this.isImmediate(rotEntry) == true) {
			handle = new OOZEHandle(
				this,
				oop,
				null,
				csb[0],
				csb[1],
				csb[2],
				rotEntry[1],
				null,
			)
		}
		else {
			handle = new OOZEHandle(
				this,
				oop,
				rotEntry[1],
				null,
				csb[0],
				csb[1],
				csb[2],
				null,
				1,
			)
		}
		return handle;
	}
	vpnForPageInZone(piz, zone) {
		var index = zone*2;
		var runStart = 1;
		var runLength = 1;
		var cnt = 0;

		while (true) {
			var zipWord = this.memWords[this.zipBase + index];
			var offset = (piz+1) - runStart;  // offset in this run
			if (offset <= (runLength-1)) {
				return (zipWord & 0xFFF) + offset;
			}
			var jmpix = zipWord >> 12;
			if (jmpix <= 0) {
				break;
			}
			var jmp = this.jumps[jmpix];
			cnt = cnt + 1;
			if (cnt > 10) { throw 'loop in zip reprobes' };
			
			index = index + jmp;
			if (index > this.zipSize) { index = index - this.zipSize; }
			runStart = runStart + runLength;
			runLength = Math.min(32, runLength*2);
		}
		return -1;  // This is an error
	}
	zonePageArray(zoneNumber) {
		// If we have already computed the page array, return it.
		var pageArray = this.zonePageArrays[zoneNumber];
		if (pageArray != null) {
			return pageArray;
		}

		// We have to compute the page array, and save it.
		var pageInZone = 0;
		var pages = new Array();
		var page;
		while ((page = this.vpnForPageInZone(pageInZone, zoneNumber)) != -1) {
			pages.push(page);
			pageInZone = pageInZone + 1;
		}

		pageArray = pages;
		this.zonePageArrays[zoneNumber] = pageArray;  // save the result
				
		return pageArray;  // also return it
	}
	
	octaveSize() {
		return 20;
	}
			
	dataLengthForIsBytes(instanceSizeCode, isBytes) {
	// This returns the size of a data block in OOZE, which then gets multiplied
	// by the instance number to get the offset into the zone for this class.
	// It's whacky code, but it parallels the original logic.

		var isc = instanceSizeCode;
		var oct = this.octaveSize();
		var dLen;
		if (isc < oct) {
			dLen = Math.max(isc, 1);
			if (isBytes == true) {
				dLen = Math.floor((dLen+1)/2);
			}
		}
		else {
			if (isBytes == false) {
				isc = isc + 1;
			}
			dLen = 8;
			while (isc != oct) {
				dLen = dLen * 2;
				oct = oct + 1;
			}
			dLen = dLen +1;
		}
		dLen = dLen + 1;  // For refct
		return dLen;
	}
	nonresidentHandle(oop) {
		// Returns an OOZEHandle capable of reading external objects that straddle zone breaks."

		// Look up in Pclass Map, compute offset in zone, and return
		// a handle that includes the corrsponding zonePageArray. 
		var csb = this.classSizeAndBytesFor(oop);
		if (csb == null) {
			return null;
		}
		
		var classOop = csb[0];
		var instSizeCode = csb[1];
		var isBytes = csb[2];
		var dLen = this.dataLengthForIsBytes(instSizeCode, isBytes);
		var pInst = oop & 0x7F;
		var pmEntry = this.pmEntry(oop);
		var zoneNumber = pmEntry[1] & 0xFF;
		var zhb = pmEntry[1] >> 8;
		var zoneOffset = (zhb*128+pInst)*dLen;
		var zpa = this.zonePageArray(zoneNumber);
		var handle = new OOZEHandle(
			this,
			oop,
			zoneOffset + 1,  // +1 to skip refct word
			zpa,
			classOop,
			instSizeCode,
			isBytes,
			null,
			1
		);
		return handle;
	}
	oozeHandle(oop) {
		// Returns an OOZEHandle capable of reading internal and external objects.
		var handle = this.residentHandle(oop);
		if (handle == null) {
			handle = this.nonresidentHandle(oop);
		}
		return handle;
	}
	classOf(oop) {
		if (oop == 0xffff) { return 23 }
		var csb = this.classSizeAndBytesFor(oop);
		if (csb == null) {
			return null;
		}
		return csb[0];
	}
	isInt(oop) {
		if (oop == 0xffff) { return false }
		if (oop >= 0xf800) { return true }
		return (this.classOf(oop) == 4);
	}
	fieldOfObject(n, oop) {
		return this.oozeHandle(oop).at(n);
	}
	ival(oop) {
		if (oop >= 0xf800) { return oop - 0xfc00 }
		var unsigned = this.fieldOfObject(1, oop);
		if (unsigned >= 32768 ) { return unsigned - 65536 }
		return unsigned;
	}
	stringOf(oop) {
		if (this.pmEntry(oop) == null) return 'Bogus';
		return this.oozeHandle(oop).string();
	}

	shortPrintObject(oop) {
		if (oop == 0xffff) { return 'nil' }
		if (oop == 0x400) { return 'false' }
		if (oop == 0x401) { return 'true' }
		if (this.isInt(oop)) { return '='+this.ival(oop) }
		var classOop = this.classOf(oop);
		if (classOop >= 385 && classOop <= 386) {
			if (classOop == 386) return '#' +this.stringOf(oop);
			else return this.stringOf(oop);
		}
		return '<' + this.stringOf(this.fieldOfObject(1, this.classOf(oop))) + '>' + oop;
	}
	nameOfClass(oop) {
		if (true) {
			return this.stringOf(this.fieldOfObject(1, oop));
		}
		if (oop == 0) return 'Class';
		if (oop == 1) return 'VClass';
		if (oop == 4) return 'Integer';
		if (oop == 5) return 'Float';
		if (oop == 0x00c) return 'Point';
		if (oop == 0x017) return 'Object';
		if (oop == 0x180) return 'Vector';
		if (oop == 0x181) return 'String';
		if (oop == 0x182) return 'Atom';
		return 'class=' + oop;
	}
	printObject(oop) {
		if (this.isInt(oop) == true) {
			console.log('='+this.ival(oop));
			return;
		}
		
		var handle = this.oozeHandle(oop);
		if (handle == null) {
			console.error("oozeHandle("+oop+") returned null");
			return;
		}
		
		var s = '';
		s += handle.location(); s += ' ';
		s += this.nameOfClass(handle.classOop);
		s += ' oop='; s += oop; s += ': ';
		if (handle.isBytes == true) {
			s += handle.string();
		}
		else {
			var fields = handle.fields();
			s += ' fields=(';
			for (var i=1; i<fields.length; i++) {
				var x = fields[i];
				s += this.shortPrintObject(x);
				s += ' ';
			}
			s += ')';
		}
		console.log(s);
	}
	nilOop() {
		return 0xFFFF;
	}
	freeListOfClass(index, classOop) {
		var list = new Array();
		var oop = this.fieldOfObject(9 + index - 1, classOop);
		list.push(oop);
		while (true) {
			var h = this.oozeHandle(oop);
			if (h.classOop != classOop || oop == this.nilOop()) {
				break;
			} 
			oop = h.freeListLink();
			if (list.indexOf(oop) != -1) {
				list.push(oop);
				return list;
			}
			list.push(oop);
		}
		return list;
	}
	firstFreeOopForClass(classOop) {
		// This is really the 

		var fl = this.freeListOfClass(1, classOop);
		if (fl[fl.length-1] != this.nilOop()) throw "Ill-formed freeList";
		return fl[fl.length-1];
	}
	allInstancesOf(classOop) {
		// Scan the pclass map for valid pclasses, and then use last item on free list
		// to end the last pclass.  Won't work right for classes allocated down from top of PM

		var pmOops = new Array();
		for (var i=0; i<65536; i+=128) {
			var entry = this.pmEntry(i);
			if (entry != null && this.classOf(i) == classOop) {
				pmOops.push(i);
			}
		}
		var firstFree = this.firstFreeOopForClass(classOop);
		var allInstances = new Array();
		for (var i=0; i<pmOops.length; i++) {
			var pmOop = pmOops[i];
			for (var j=0; j<128; j++) {
				if (pmOop + j < firstFree) {
					allInstances.push(pmOop + j);
				}
			}
		}
		var freeList = this.freeListOfClass(1, classOop);
		if (freeList[freeList.length-1] != this.nilOop()) throw "bad freeList";

		var r = new Array;
		for (var i=0; i<allInstances.length; i++) {
			var oop = allInstances[i];
			var idx = freeList.indexOf(oop);
			if (idx == -1 || idx < freeList.length - 1) {
				r.push(oop);
			}
		}
		return r;
	}
	dumpROT() {
		// Look up a few notable oops in ROT...
		var oops = [0, 1, 4, 5, 12, 384, 385, 386];
		for (var i=0; i<oops.length; i++) {
			this.printObject(oops[i]);
		}
	}
	pclassString(pclass) {
		var pmWord0 = this.memWords[this.pmBase + (pclass*2)];
		var pmWord1 = this.memWords[this.pmBase + (pclass*2) + 1];
		var s = "";
		s += 'pclass= '+pclass;
		if (pmWord0 == 0 && pmWord1 == 0) {
			s += ' not found ';
		}
		s += ' '; s += '{rci, cpt, bsc, isc}= ';
		s += pmWord0 >> 7; s += ','; s += (pmWord0 >> 6) & 1; s += ','; s += (pmWord0 >> 6) & 1; s += ','; s += pmWord0 & 0x1F; 
		s += ' '; s += '{zhb, zone}= ';
		s += pmWord1 >> 8; s += ', '; s += pmWord1 & 0xFF;
		return s;
	}
	dumpPclassForOop(oop) {
		console.log('oop= '+ oop + ', ' + this.pclassString(Math.floor(oop / 128)));
	}
	dumpPM() {
		for (var pclass=0; pclass<=512; pclass++) {
			this.dumpPclassForOop(pclass * 128);
		}
	}
	dumpZip() {
		for (var i=0; i<=15; i++) {
			var zipWord0 = this.memWords[this.zipBase + (i*2)];
			var jmpix = zipWord0 >> 12;
			var jmp = this.jumps[jmpix];
			console.log('{vpn, jmpix, jmp} = '+(zipWord0 & 0xFFF)+', '+jmpix+', '+jmp);
		}
	}
	isValidClass(oop) {
		if (this.pmEntry(oop) == null) return false;
		var h = this.oozeHandle(oop);
		if (h.valid() == false) return false;
		if ((h.classOop != 0 || h.size != 9) && (h.classOop != 1 || h.size != 21)) {
			// Not a class
			return false;
		}
		if (this.pmEntry(h.at(4)) == null) throw "some error...";
		if (this.classOf(h.at(4)) != 11 /*MessageDict*/)  throw "MDict not a MessageDict";
		if (this.classOf(h.at(1)) < 385/*String*/ || this.classOf(h.at(1)) > 386/*UniqueString*/) throw "title not a string or atom";
		return true;
	}
	allValidClasses() {
		// Should really use allInstances of 0 and 1, and allInstances would scan
		// the pclass map for valid pclasses, and then use last item on free list
		// to end the last pclass."
		var classes = this.allInstancesOf(0); // Class
		classes = classes.concat(this.allInstancesOf(1)); // VariableLengthClass
		return classes.filter(i => { 
			var r; 
			try { 
				r = this.isValidClass(i);
			} catch (e) {
				console.log("oop: "+i+", isValidClass threw: "+e)
				return false;
			} 
			return r
		});
	}
	dumpClasses() {
		this.allValidClasses().forEach(oop => { image.printObject(oop); });
	}
	dumpSymbols() {
		this.allInstancesOf(386).map(oop => { image.printObject(oop); })
	}
	fileAddrForIndex(index) {
		return (index-256)*2;
	}
	unhash(rotAddr) {
		var rotWord0 = this.memWords[rotAddr];
		if ((rotWord0 & 0xF0) == 0xF0) return null; // empty entry
		var rotIndex = rotAddr - Math.floor(this.rotBase / 2);
		var rpc = (rotWord0 >> 8) & 7;
		var rpcs = [0, 13, 30, 49, 72, 101, 132, 169];
		rotIndex = rotIndex - (rpcs[rpc+1]);
		var residue = rotWord0 & 0xF800;
		return this.rhash((rotIndex + (this.rotSize & 0x7FF)) | residue);
	}
	allResidentObjects() {
		// Return the oops of all objects in the ROT
		var r = [];
		for (var i=0; i<Math.floor(this.rotSize/2); i+=2) {
			var oop  = this.unhash(this.rotBase + i);
			if (oop != null) {
				r.push(oop);
			}
		}
		return r;
	}
	allImmediateObjects() {
		return this.allResidentObjects().filter(oop => { 
			var hash = this.hash(oop);
			if (hash == null) {
				return false;
			}
			return this.isImmediate(hash);
		});
	}

	readImage(data) {
		var memWords = new Uint16Array(data.length + 256);
		for (var i=0, j=256; i<data.length; i++, j++) {
			memWords[j] = (data[i] >> 8) | (data[i] << 8);
		}
		this.memWords = memWords;
		this.oozeBase = 65536 + (7*256);

		console.log("Looking for the Resident Object Table (ROT)...");
		var locs = this.findNovaCode("LDA	0,DCBLAB,2\n\
	NEG	0,0\n\
	COM	0,0			;LLX-1\n\
	LDA	1,LPTR		;USER LABEL-1\n\
	LDA	3,MLABSZ\n\
	SUB	3,1			;...+COUNT\n\
	BLT\n\
	LDA	3,D3			;DCB STILL IN AC2\n\
	JMP	DARGS+1,3")

		if (locs.length != 1) {
			throw 'Failure to find SMDSK code';
		}
		
		var rotBase = locs[0] + 10;
		if ((rotBase & 1) == 1) rotBase = rotBase + 1;
		
		var rotSize = this.memWords[rotBase-1];
		console.log("ROT="+this.fileAddrForIndex(rotBase)+", size="+rotSize);
		
		this.rotBase = rotBase;
		this.rotSize = rotSize;
		
		locs = this.findNovaCode("INSERT:	STA	3,ISAV3\n\
	STA	1,ISAV1\n\
	STA	0,ISAV0\n\
RETRY:	UHASH		;// SEE IF SPACE IN MY CHAIN FIRST\n\
	 SKIP		;// DIDNT FIND IT (HAD BETTER DO THIS)\n\
	 SWATME	;// DID FIND (WHY ARE WE INSERTING)\n\
	STA	3,RESID	;// HASH LEAVES RESIDUE IN AC3\n\
	LDA	3,RPCMAX	;// LIMIT");
	
		if (locs.length != 1) {
			throw 'Failure to find ROT code';
		}
		console.log("ROTend="+this.fileAddrForIndex(locs[0]));
		
		console.log("Looking for the Pclass Map (PM)...");
		var pmBase;
		for (var i=0; i<65000; i++) {
			if (this.memWords[i] == 0xfc00) {
				if (this.memWords[i+1] == 0xf800) {
					if (this.memWords[i+2] < this.memWords[i+1]) {
						if (this.memWords[i+3] < this.memWords[i+2]) {
							if (this.memWords[i+3] > 2000) {
								pmBase = i + 4;
								console.log("PM="+this.fileAddrForIndex(pmBase));
								// XXX: Hobbes doesn't do this, but xmsmall.boot
								// ends up finding two values, and the second 
								// doesn't seem to be what we want.
								// The first agrees with the other two images.
								break;
							}
						}
					}
				}
			}
		}
		this.pmBase = pmBase;

		console.log("Looking for the Zone Index of Pages (ZIP)...");
		var zipBase;
		var zipSize;
		for (var i=0; i<65000; i++) {
			var s = this.memWords[i];
			if (s >= 512 && s <= 1000) {
				if (this.memWords[i+1] == (i+2+s)) {
					zipBase = i+2;
					zipSize = s;
					console.log("ZIP="+this.fileAddrForIndex(zipBase)+", size="+zipSize);
				}
			}
		}
		
		this.zipBase = zipBase;
		this.zipSize = zipSize;
		
		this.zonePageArrays = [];
		
		this.dumpROT();
		this.dumpPM();
		this.dumpZip();
		//this.dumpClasses();
		//this.dumpSymbols();
	}
}
