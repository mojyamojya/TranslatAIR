var Ctxt = WScript.CreateObject("Sapi.SpSharedRecoContext", "Ctxt_");

Ctxt.EventInterests = 2+4+16+32+512; // SRESoundStart + SRESoundEnd + SRERecognition + SREHypothesis + SREFalseRecognition



var GramDict = Ctxt.CreateGrammar(0);

GramDict.DictationLoad();

GramDict.DictationSetState(1);



var loop = true;



while(loop){

	WScript.Sleep(1000);

	

	/*var proc = getProcessList();

	

	if (proc.Count == 0) {

		Quit();

	}*/

}



var proc = getProcessList();



if (proc.Count > 0) {

	Terminate(proc);

}



Quit();



function getProcessList() {

	var Locator = WScript.CreateObject("WbemScripting.SWbemLocator");

	var Service = Locator.ConnectServer();

	

	return Service.ExecQuery("Select * From Win32_Process Where Caption = 'sapisvr.exe'");

}



function Terminate(proc) {

	var procEnum = new Enumerator(proc);

	

	for (; !procEnum.atEnd(); procEnum.moveNext()) {

		procEnum.item().Terminate();

	}

}



function Quit() {

	Ctxt = null;

	GramDict = null;

	

	WScript.Quit(0);

}



function Ctxt_Recognition(StreamNum, StreamPos, RecogType, Result){

	WScript.Stdout.Write(Result.PhraseInfo.GetText());

	loop = false;

}


function Ctxt_SoundStart(StreamNum, StreamPos)
{
}


function Ctxt_SoundEnd(StreamNum, StreamPos)
{
}


function Ctxt_FalseRecognition(StreamNum, StreamPos, Result)
{
}


function Ctxt_Hypothesis(StreamNum, StreamPos, Result)
{
}
