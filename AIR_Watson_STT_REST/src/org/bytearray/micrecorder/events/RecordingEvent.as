package org.bytearray.micrecorder.events
{
	import flash.events.Event;
	
	public final class RecordingEvent extends Event
	{
		public static const RECORDING:String = "recording";
		
		private var _time:Number;
		public var _activityLevel:int;
		
		/**
		 * 
		 * @param type
		 * @param time
		 * 
		 */		
		public function RecordingEvent(type:String, time:Number, activityLevel:int)
		{
			super(type, false, false);
			_time = time;
			_activityLevel = activityLevel;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		
		public function get activityLevel():Number
		{
			return _activityLevel;
		}

		public function get time():Number
		{
			return _time;
		}
		

		/**
		 * 
		 * @param value
		 * 
		 */		
		public function set time(value:Number):void
		{
			_time = value;
		}

		/**
		 * 
		 * @return 
		 * 
		 */		
		public override function clone(): Event
		{
			return new RecordingEvent(type, _time, _activityLevel)
		}
	}
}