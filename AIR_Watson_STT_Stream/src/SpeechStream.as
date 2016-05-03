package  {
	
	import flash.display.*;
	import flash.text.*;
	import flash.utils.*;
	import flash.net.*;
	import flash.events.*;
	import flash.media.*;
	
	import com.greensock.*;
	import com.greensock.easing.*;
	import com.greensock.loading.*;
	import com.greensock.events.*;
	import com.greensock.plugins.*;
	TweenPlugin.activate([TintPlugin]);
	
	import com.worlize.websocket.*;
	import com.hurlant.util.*;

	

	public class SpeechStream extends MovieClip {
		
		private var _state:Boolean;
		private var sttData:DataLoader;
		private var blueMixToken:DataLoader;
		private var myToken;
		private var recordAvail:Boolean=true;
		private var websocket:WebSocket;
		private var _microphone:Microphone;
		private var SSTConnected= false;
		private var minimumConfidenceToDisplayText:Number = 0.25;
		private var isAIR:Boolean = true;
		
		public function SpeechStream() {
			
			if(isAIR){
				URLRequestDefaults.setLoginCredentialsForHost("stream.watsonplatform.net", "**BlueMix Credential Username**", "**BlueMix Credential Password**");
			}
			TweenMax.delayedCall(1, getBlueMixToken);
			recordBtn.addEventListener(MouseEvent.CLICK, onClick);	
		}
		
		private function loadBlueMixSocket():void
		{
			websocket = new WebSocket("wss://stream.watsonplatform.net/speech-to-text/api/v1/recognize?watson-token="+myToken, "*",null);
			websocket.addEventListener(WebSocketEvent.CLOSED, handleWebSocketClosed);
			websocket.addEventListener(WebSocketEvent.OPEN, handleWebSocketOpen);
			websocket.addEventListener(WebSocketEvent.MESSAGE, handleWebSocketMessage);
			websocket.addEventListener(WebSocketErrorEvent.CONNECTION_FAIL, handleConnectionFail);
			websocket.connect();
		}
		
		private function getBlueMixToken():void
		{
			var request:URLRequest;
			if(isAIR)
			{
				request = new URLRequest("https://stream.watsonplatform.net/authorization/api/v1/token?url=https://stream.watsonplatform.net/speech-to-text/api");
			}else{
				request = new URLRequest("get_bluemix_token.php");
			}
				request.method = URLRequestMethod.GET;
				blueMixToken = new DataLoader(request, {name:"blueMixToken", format:"text"});
			
			var queue:LoaderMax = new LoaderMax({name:"blueMixTokenQueue", onComplete:readToken, onError:errorHandler});
				queue.append(blueMixToken)
				queue.load();
		}
		
		private function readToken(event:LoaderEvent):void {
			myToken = LoaderMax.getContent("blueMixToken");
			loadBlueMixSocket();
		}	
	
		
		private function micRecord():void
		{
			if ( _microphone == null ){
				_microphone = Microphone.getMicrophone();
			}
					
			_microphone.gain = 20;
			_microphone.rate = 44;
			_microphone.setSilenceLevel(0, 1000);
			_microphone.setUseEchoSuppression(true);
			
			_microphone.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			TweenMax.to(recordBtn, 0.5, {tint:0xCC3333, tintAmount:0.7, repeat:-1, yoyo:true,ease:Linear.easeNone});
		}	
		
		private function onSampleData(event:SampleDataEvent):void
		{
			
			var soundBytes:ByteArray = new ByteArray();
			
			var scaleSize = 1+ ((_microphone.activityLevel/10)/2);
			TweenMax.to(recordSize, 0.1, {scaleX:scaleSize, scaleY:scaleSize});
			
			while(event.data.bytesAvailable)
			{
				var sample:Number = event.data.readFloat();
				var integer:int;
				sample = sample * 32768 ;
				if( sample > 32767 ) sample = 32767;
				if( sample < -32768 ) sample = -32768;
				integer = int(sample) ;
				soundBytes.writeShort(integer);
			}
	
			if(SSTConnected==true){
				websocket.sendBytes(soundBytes);
			}
		}
	
		private function micStop():void
		{
			if(SSTConnected){
					websocket.sendUTF('{\"action\": \"stop\"}');
			}
			
			_microphone.removeEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			TweenMax.to(recordBtn, 0.5, {tint:0xDEE9F6, tintAmount:1,ease:Linear.easeNone});
			TweenMax.to(recordSize, 0.3, {scaleX:1, scaleY:1});
		}

		private function onClick(event:MouseEvent=null):void
		{
			if(recordAvail){
				
				if(!_state){
					myText.text = "Listening...";
					micRecord();
					
				}else{
					micStop();
				}
				_state = !_state;
			}
		}

		private function handleWebSocketOpen(event:WebSocketEvent):void {
		  trace("Connected");
			SSTConnected=true;
			var message = '{\"action\" : "\start\", \"content-type\" : \"audio/l16;rate=44100\", \"continuous\" : true, \"interim_results\" : true, \"inactivity_timeout\": 60000}';
			websocket.sendUTF(message);
			myText.text = "Connected";
			
		}

		private function handleWebSocketClosed(event:WebSocketEvent):void {
		  trace("Disconnected");
			SSTConnected=false;
		}

		private function handleConnectionFail(event:WebSocketErrorEvent):void {
		  trace("Connection Failure: " + event.text);
			myText.text = "Lost connection!";
		}

		function handleWebSocketMessage(event:WebSocketEvent):void {
		  if (event.message.type === WebSocketMessage.TYPE_UTF8) {
			trace("Got message: " + event.message.utf8Data);
			var theResult:Object = JSON.parse(event.message.utf8Data);
			var results = checkSTT(theResult);
			if(results[0] != "false" && results[1] > minimumConfidenceToDisplayText)
			{
				myText.text = String(results[0]);
			}
		  }
		}
		
		private function errorHandler(event:LoaderEvent):void {
			recordAvail = true;
			TweenMax.to(recordBtn, 0.5, {tint:null, tintAmount:1,ease:Linear.easeNone});
			trace("error occured with " + event.target + ": " + event.text);
			myText.text = "Error connecting to BlueMix / Watson..";
			
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
		
	}
}







			