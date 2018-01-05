'From Smalltalk 5.5k XM November 24 on 5 February 2037 at 11:37:58 pm.'
\g
"ExceptionHandler"l15000z20000\gbf5 
Class new title: 'ExceptionHandler'
	subclassof: Object
	fields: ' 
		fDoContext
		fCode
		fTrapCode
		fTrapCondition
		fResult
		fPostTrapIndicator
		fStatusIndicator
	'
	declare: '';
	asFollows\gbf5 

EXCEPTION HANDLER  J.C. Althoff  7/79\gi

DOCUMENTATION\gbf5 
description
[
"
This class provides some exception handling capabilities that can be used in a variety of applications.  It is intended to be used in the following way:

1. An ExceptionHandler object is created to supervise the execution of a block of statements.
	EH _ ExceptionHandler new.
2. Each object that is capable of detecting an exception is informed of the existence of the ExceptionHandler object.
	dpj exceptionHandler: EH.
3. The ExceptionHandler object is then sent the message 'do pCode onTrapDo pTrapCode'.  The parameter pCode is a block of statements that is to be supervised by the ExceptionHandler object.  The parameter pTrapCode is a block of statements that is to be executed whenever an exception is detected.
	EH do [ ... ] onTrapDo [ ... ].
4. When an exception is detected during the execution of one of the statements in pCode the message 'trap' can be sent to the ExceptionHandler object which will then take control.  If information about the exception is available, it can be relayed by sending the message 'trap:' with the information specified as the parameter.
	EH trap.  (or)  EH trap: information.
5. When the ExceptionHandler object gets control it saves the parameter if one was sent, then executes pTrapCode.  The saved parameter can be retrieved by sending the message 'trapCondition'.  The statements in pTrapCode should take any actions necessary to handle the exception. Messages can be included in pTrapCode that tell the ExceptionHandler object what to do when pTrapCode completes.  The available messages are:
	5.1 'restart' which restarts the execution of pCode,
	5.2 'continue' which continues pCode at the point at which 'trap' was sent,
	5.3 'abort' which aborts the execution of pCode and returns control to the statement following 'do pCode onTrapDo pTrapCode'.
	EH restart.  (or)  EH continue.  (or)  EH abort.
6. The message 'doonTrapDo' returns a result which can be specified during the execution of either  pCode or pTrapCode by the message 'result _ pResult'.  This result value can be retrieved anytime after it has been specified by sending the message 'result'.
	EH result _ true.
	[ EH result  [ ... ] ].
7. If pCode is terminated abnormally from a user notify window, the message 'release' should be sent to return the ExceptionHandler object to its initial state.
	EH release.
8. Special error checking is included in the ExceptionHandler object to detect calls to pTrapCode during the execution of pTrapCode and other invalid conditions.
"
]j\gb12B3f8 250f0 26f8 120f0 25f8 57f0 31f8 17f0 5f8 98f0 9f8 85f0 33f8 83f0 5f8 13f0 6f8 165f0 7f8 51f0 9f8 7f0 21f8 104f0 9f8 63f0 15f8 21f0 9f8 88f0 9f8 55f0 9f8 46f0 9f8 33f0 5f8 7f0 10f8 17f0 5f8 23f0 7f8 15f0 7f8 31f0 5f8 48f0 31f8 3f0 11f8 8f0 12f8 8f0 9f8 16f0 14f8 73f0 5f8 4f0 9f8 16f0 18f8 97f0 8f8 3f0 17f8 2f0 24f8 7f0 5f8 65f0 9f8 77f0 11f8 89f0 9f8 25f0 9f8 30f0 
implementationNotes
[
"
FIELDS
fDoContext : a Context that controls the execution of the message 'doonTrapDo'.
fCode : a Context that controls the execution of the statements passed as the first parameter to 'doonTrapDo'.
fTrapCode : a Context that controls the execution of the statements passed as the second parameter to 'doonTrapDo'.
fTrapCondition : the object passed as the parameter to 'trap:'.
fResult : the object that is the result of 'doonTrapDo'.
fPostTrapIndicator : an Integer specifying the action to be taken after fTrapCode is executed.
fStatusIndicator : an Integer specifying the status of 'doonTrapDo'; nil means 'doonTrapDo' has not been invoked, 1 means fCode is active, 0 means fTrapCode is active.
"
]\gb20B11b10B72b5B108b9B109b14B50b7B52b18B77b16B

CONTROL STRUCTURE\gbf5 
do pCode onTrapDo pTrapCode
"...executes the set of statements in the block pCode and, conditionally, the set of statements in the block pTrapCode.  If 'trap' or 'trap:' is invoked during the execution of pCode, the execution is interrupted and pTrapCode is started.  When pTrapCode completes, pCode is either continued, restarted, or aborted, depending on which of 'continue', 'restart', and 'abort' is sent during the execution of pTrapCode.  A notify window is created if 'trap' or 'trap:' is sent when pCode is not active, or if 'doonTrapDo' is sent again before the first invocation completes."
[
	[ fStatusIndicator  nil  [ user notify: 'ExceptionHandler is active'. ]  "1"
	].
	fStatusIndicator _ 1.  "2"
	fCode _ pCode.  "3"
	fTrapCode _ pTrapCode.  "4"
	fDoContext _ thisContext.  "5"
	fTrapCondition _ nil.  "6"
	fResult _ true.  "7"
	fCode eval.  "8"
	self release.  "9"
	 fResult  "10"
]
"
1. If fStatusIndicator  nil, then the previous invocation of 'doonTrapDo' has not completed properly.  Create a notify window in this case.
2. Set fStatusIndicator to indicate pCode is active.
3. Save pCode for execution and restart.
4. Save pTrapCode for later execution.
5. Save the context of 'doonTrapDo' for 'restart' and 'abort'.
6. Initialize the trap condition to nil.
7. Initialize the result of 'doonTrapDo ' to true.
8. Execute pCode.
9. Set fields to nil to release saved contexts.
10. Return fResult (which may have been modified during the execution of pCode or pTrapCode).
"\gb30B

TRAP HANDLER\gbf5 
trap
"...interrupts the execution of pCode and begins pTrapCode (from 'do pCode onTrapDo pTrapCode')."
[
	self trap: nil.
]\gb5B
trap: pTrapCondition
"...interrupts the execution of pCode and begins pTrapCode (from 'do pCode onTrapDo pTrapCode').  The trap condition is set to pTrapCondition."
	|tTrapCode i
[
	[ fStatusIndicator
		 nil  [ user notify: 'ExceptionHandler is not active' ];  "1"
		= 0   [ user notify: 'ExceptionHandler trap code is already active' ]  "2"
	].
	fStatusIndicator _ 0.  "3"
	fTrapCondition _ pTrapCondition.  "4"
	fPostTrapIndicator _ 0.  "5"
	tTrapCode _ fTrapCode cleancopy.  "6"
	tTrapCode eval.  "7"
	for i to: tTrapCode totalPT do
		[ fTrapCode setPT: i to: (tTrapCode getPT: i). ].  "8"
	fStatusIndicator _ 1.  "9"
	[ fPostTrapIndicator  "10"
		= 0  [ self restartCode. ];
		= 1  [ self abortCode. ];
		= 2  [ ]
	].
]
"
1. If fStatusIndicator  nil, then 'doonTrapDo' has not been invoked and there is no trap code to execute.
2. if fStatusIndicator = 0, then fTrapCode is active.  This is an invalid state.
3. Set fStatusIndicator to indicate fTrapCode is active.
4. Set the trap condition to pTrapCondition.
5. Set the default post trap action to 'restart'.
6. Make a new copy of the context, fTrapCode.
7. Execute the new copy of fTrapCode.
8. Set the parameters and temporaries in the context, fTrapCode to those of the executed copy.  This is done so that fCode will see any changes made to these variables by fTrapCode.
9. Set fStatusIndicator to indicate fTrapCode is not active.
10. Select the terminating action from the value of fPostTrapIndicator.
"\gb21B

POST TRAP SPECIFICATION\gbf5 
abort
"...specifies that the code interrupted by 'trap' or 'trap:' will be aborted when the trap code completes.  Control will return to the statement that follows the invocation of 'doonTrapDo'."
[
	fPostTrapIndicator _ 1.
]\gb6B
continue
"...specifies that the code interrupted by 'trap' or 'trap:' will be continued when the trap code completes."
[
	fPostTrapIndicator _ 2.
]\gb9B
restart
"...specifies that the code interrupted by 'trap' or 'trap:' will be restarted when the trap code completes."
[
	fPostTrapIndicator _ 0.
]\gb8B

MISC\gbf5 
result
"...returns the result set by 'result_'."
[
	 fResult
]\gb7B
result _ pResult
"...sets the result value of 'doonTrapDo' to pResult."
[
	fResult _ pResult.
]\gb17B
trapCondition
"...returns the condition that was passed as the parameter to 'trap:'."
[
	 fTrapCondition
]\gb14B

POST TRAP ACTION (internal)\gbf5 
abortCode
"...releases the context chain and returns fResult to the caller of 'doonTrapDo'."
	|tDoContextCaller
[
	tDoContextCaller _ fDoContext caller.  "1"
	thisContext caller releaseTo: tDoContextCaller.  "2"
	self release.  "3"
	tDoContextCaller push: fResult.  "4"
	Top run: tDoContextCaller at: Top currentPriority.  "5"
]
"
1. Get the caller of 'doonTrapDo'.
2. Release the context chain from the caller of thisContext up to the caller of 'doonTrapDo'.
3. Set fields to nil to clean up pointers to unwanted contexts.
4. Return fResult to the caller of 'doonTrapDo'.
5. Run the caller of 'doonTrapDo'.
"\gb10B
release
"...resets the exception handler to its initial condition."
[
	fCode _ nil.
	fTrapCode _ nil.
	fDoContext _ nil.
	fStatusIndicator _ nil.
]\gb8B
restartCode
"...releases the context chain and restarts the block of statements passed as the first parameter to 'doonTrapDo'."
[
	thisContext caller releaseTo: fCode.  "1"
	fCode restart.  "2"
	fCode push: fDoContext.  "3"
	Top run: fCode at: Top currentPriority.  "4"
]
"
1. Release the context chain from the caller of thisContext up to fCode.
2. Resets the pc and stack pointer of fCode.
3. Push the return context of fCode onto its tempframe.
4. Run fCode.
"\gb12B

TEST AND DIAGNOSTIC\gbf5 
test  "ExceptionHandler new test."
	| guard i
[
	guard _ ExceptionHandler new.  user clear.  i _ 0.
	guard do
		[ user show: i asString.  i _ i+1.  guard trap: i.  user show: ' end'. ]
	onTrapDo
		[ i < 10  [ guard restart ]  guard continue ].
	user show: ' done.'.  user cr.   guard result
]\gb6B28b2B
testTransaction  "ExceptionHandler new testTransaction."
	| e i max f
[
	e _ ExceptionHandler new.  i _ 0.  max _ 5.  dpj exceptionHandler: e.
	dpj open.  f _ dpj file: 'test.test'.
	e do [f reset. until [ f end ] do [ user show: (f next) inString. ]. ]
	onTrapDo
		[ user cr;  show: 'Juniper not responding'.
		f release.  dpj release.  i _ i+1.  [ i < max  [ e restart. ] e abort ]. ].
	user cr;  show: 'done'.  f close.  dpj close.
]\gb17B39b2B

EXAMPLES\gbf5 
juniperTest  "ExceptionHandler new juniperTest."
	| e i max f
[
	e _ ExceptionHandler new.  i _ 0.  max _ 5.  dpj exceptionHandler: e.
	dpj open.  f _ dpj file: 'test.test'.
	e do [f reset. until [ f end ] do [ user show: (f next) inString. ]. ]
	onTrapDo
		[ user cr;  show: 'Juniper not responding'.
		f release.  dpj release.  i _ i+1.  [ i < max  [ e restart. ] e abort ]. ].
	user cr;  show: 'done'.  f close.  dpj close.
]\gb13B35b2B
loopTest  "ExceptionHandler new loopTest."
	| guard i
[
	guard _ ExceptionHandler new.  user clear.  i _ 0.
	guard do
		[ user show: i asString.  i _ i+1.  guard trap: i.  user show: ' end'. ]
	onTrapDo
		[ i < 10  [ guard restart ]  guard continue ].
	user show: ' done.'.  user cr.   guard result
]\gb10B32b2B
\g
SystemOrganization classify: ExceptionHandler under: 'ExceptionHandling'.\g 