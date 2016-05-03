package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.utils.ByteArray;
	import flash.net.*;
	
	import org.as3wavsound.WavSound;
	import org.bytearray.micrecorder.MicRecorder;
	import org.bytearray.micrecorder.encoder.WaveEncoder;
	import org.bytearray.micrecorder.events.RecordingEvent;
	
	import com.greensock.*;
	import com.greensock.easing.*;
	import com.greensock.loading.*;
	import com.greensock.events.*;
	import com.greensock.plugins.*;
	TweenPlugin.activate([TintPlugin]);


	public class SpeechText extends MovieClip {
		
		private var recorder:MicRecorder = new MicRecorder(new WaveEncoder());
		private var player:WavSound;
		private var _state:Boolean;
		private var _display:TextField = new TextField();
		private var sttData:DataLoader;
		private var recordAvail:Boolean=true;
		private var isAIR:Boolean = true;
		
		public function SpeechText() {
			
			if(isAIR){
				URLRequestDefaults.setLoginCredentialsForHost("stream.watsonplatform.net", "**BlueMix Credential Username**", "**BlueMix Credential Password**");
			}
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			recorder.addEventListener(RecordingEvent.RECORDING, onRecording);
			recorder.addEventListener(Event.COMPLETE, onRecordComplete);
			recordBtn.addEventListener(MouseEvent.CLICK, onClick);	
		}

		private function onRecording(event:RecordingEvent):void
		{
			var scaleSize = 1+ ((event.activityLevel/100)/4);
			TweenMax.to(recordSize, 0.1, {scaleX:scaleSize, scaleY:scaleSize});
		}

		private function onRecordComplete(event:Event):void
		{
			requestSTT(recorder.output);
		}

		private function onClick(event:MouseEvent=null):void
		{
			if(recordAvail)
			{
				if(!_state)
				{
					myText.text = "Listening...";
					recorder.record();
					TweenMax.to(recordBtn, 0.5, {tint:0xCC3333, tintAmount:0.7, repeat:-1, yoyo:true,ease:Linear.easeNone});
				}else{
					recorder.stop();
					TweenMax.to(recordBtn, 0.5, {tint:0xDEE9F6, tintAmount:1,ease:Linear.easeNone});
					TweenMax.to(recordSize, 0.3, {scaleX:1, scaleY:1});
				}
				_state = !_state;
			}
		}
		
		private function requestSTT(voice:ByteArray):void
		{
			recordAvail = false;
			myText.text = "Working...";
			var request:URLRequest;
			if(isAIR){
				request:URLRequest = new URLRequest("https://stream.watsonplatform.net/speech-to-text/api/v1/recognize");
			}else{
				request = new URLRequest("cantbebothered.php");
			}
			var header:URLRequestHeader = new URLRequestHeader("content-type", "audio/wav");
				request.requestHeaders.push(header);
				request.data = voice;
				request.method = URLRequestMethod.POST;
			
			sttData = new DataLoader(request, {name:"sttData", format:"text"});
			
			var queue:LoaderMax = new LoaderMax({name:"mainQueue", onComplete:readSTT, onError:errorHandler});
				queue.append(sttData)
				queue.load();
		}
		
		private function readSTT(event:LoaderEvent):void {
			var theResult:Object = JSON.parse(LoaderMax.getContent("sttData"));
			var results = checkSTT(theResult);
			if(results[0] != "false" && results[1] > 0.35)
			{
				myText.text = String(results[0]);
			}
			recordAvail = true;
			TweenMax.to(recordBtn, 0.5, {tint:null, tintAmount:1,ease:Linear.easeNone});
		}	
		
		private function checkSTT(oObj:Object):Array  
		{
			var returnArray:Array = new Array("false",0);
			runAgain(oObj);

			function runAgain(oObj:Object){
				var sPrefix = "*";
				sPrefix == "" ? sPrefix = "---" : sPrefix += "---";  
				  
				for (var i:* in oObj){  
					if("transcript" == String(i)){returnArray[0]=oObj[i];};
					if("confidence" == String(i)){returnArray[1] = oObj[i];};
					if (typeof( oObj[i] ) == "object") runAgain( oObj[i]);         
				}
			}
			return returnArray;
		}

		private function errorHandler(event:LoaderEvent):void {
			recordAvail = true;
			TweenMax.to(recordBtn, 0.5, {tint:null, tintAmount:1,ease:Linear.easeNone});
			trace("error occured with " + event.target + ": " + event.text);
		}
		
	}
	
}







			