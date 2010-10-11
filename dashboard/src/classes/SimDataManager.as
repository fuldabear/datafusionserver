package classes
{
	import flash.events.*;
	import flash.utils.Timer;
	
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.HSlider;
	import mx.controls.Label;
	import mx.events.*;
	
	public class SimDataManager extends Timer
	{
		private var controlSliders:Array = new Array;
		private var liveButtons:Array = new Array;
		private var playButtons:Array = new Array;
		private var simTimeCounters:Array = new Array;
		private var totalSimTimeCounters:Array = new Array;
		private var currentSimTime:Number = 0; // in seconds
		private var currentTotalTime:Number = 0; // in seconds
		private var data:Array = new Array;
		private var currentData:XML = new XML;
		private var currentCData:XML = new XML;
		private var currentDataIndex:int = 0;
		private var currentCDataIndex:int = 0;
		private var currentDataId:int = 0;
		private var dash:dashML = new dashML;
		private var lastSentCData:String = new String;
		private var registeredSimComponentUpdateFunctions:Array = new Array;
		private var isAttachedToAnotherDatamanager:Boolean = false;
		private var attachedToDatamanager:SimDataManager = null;
		private var attachedDatamanagers:Array = new Array;
		private var isPaused:Boolean = true;
		private var isLive:Boolean = false;
		
		
		public var refreshRate:int = 1000;
		public var simulationId:String = new String;
		public var userId:int = 0;
		
		
		public function SimDataManager()
		{
			super(this.refreshRate, 5);
			this.addEventListener(TimerEvent.TIMER,refreshData);
			
		}
		
		public function init():void
		{
			for each (var i:HSlider in this.controlSliders)	i.enabled = true;
			for each (var j:Button in this.liveButtons) j.enabled = true;
			for each (var k:Button in this.playButtons)	k.enabled = true;
			this.data = new Array;
			this.currentSimTime = 0;
			this.currentTotalTime = 0;
			this.currentData = new XML;
			this.currentCData = new XML;
			this.currentDataIndex = 0;
			this.currentCDataIndex = 0;
			this.currentDataId = 0;
			var e:TimerEvent;
			this.refreshData(e);
		}
		
		private function updateControls(s:HSlider):void
		{
			for each (var i:HSlider in this.controlSliders)
			{
				if (i != s)
				{
					i.value = this.currentSimTime;					
				}
				i.maximum = this.currentTotalTime;
			}
			var str:String = classes.dateToEnglish.convertSeconds(this.currentSimTime);
			for each (var j:Label in this.simTimeCounters)
			{
				if(j.text != str) j.text = str;
			}
			if (this.isLive == true) str = "live";
			else str = classes.dateToEnglish.convertSeconds(this.currentTotalTime);
			for each (var k:Label in this.totalSimTimeCounters)
			{
				if(k.text != str) k.text = str;
			}
			for each (var l:Button in this.playButtons)
			{
				if(this.isPaused == true) l.label = "Play";
				else l.label = "Pause";
			}
		}
		
		private function refreshData(e:TimerEvent):void
		{
			if(this.simulationId == "")
			{ 
				this.reset();
				Alert.show("Please Select a simulation");		
			}
			else
			{
				var cdata:String = this.collectCData();
				if(cdata == this.lastSentCData) cdata = "";
				else this.lastSentCData = cdata;
				var dashml:String = "<dashML><cdata>"+cdata+"</cdata><user_id>"+this.userId+"</user_id><simulation_id>"+this.simulationId+"</simulation_id><data_id>"+this.currentDataId+"</data_id></dashML>";
				this.dash.sendDashML(dashml, gotNewData);
			}
		}
		
		private function gotNewData(result:Object, token:Object):void
		{
			this.reset();
			this.start();
			var xml:XML = new XML(result.result as String);
			var lastRow:int;
			if(xml.serverResponse.num > 0)
			{
				lastRow = xml.serverResponse.num - 1;
				this.currentDataId = xml.serverResponse.row[lastRow].data_id;
				if(xml.serverResponse.row[lastRow].data != "") this.currentTotalTime = xml.serverResponse.row[lastRow].data.time;
				if(xml.serverResponse.row[lastRow].cdata != "") this.currentTotalTime = xml.serverResponse.row[lastRow].cdata.time;
				this.parseDataIntoArray(xml);
				this.updateControls(null);
				this.alertAllSimComponents();
			}
			this.player();			
		}
		
		private function player():void
		{
			// this function simply keeps the simulation moving to simulate playback capability
			if(this.isLive == false && this.isPaused == false)
			{
				this.setCurrentDataForTime(this.currentSimTime + 1);
				this.updateControls(null);
				this.alertAllSimComponents();
			}
		}
		
		public function collectCData():String
		{
			if (this.isLive == false) return "";
			return "";
		}
		
		private function parseDataIntoArray(x:XML):void
		{
			var n:int = x.serverResponse.num;
			for (var i:int = 0; i < n; i++)
			{
				this.data.push(x.serverResponse.row[i]);
			}
		}
		
		public function registeredSimComponentUpdateFunction(s:Function):void
		{
			this.registeredSimComponentUpdateFunctions.push(s);
		}
		
		public function removeSimComponentUpdateFunctions(s:Function):void
		{
			this.registeredSimComponentUpdateFunctions.splice(this.registeredSimComponentUpdateFunctions.indexOf(s),1);
		}
		
		private function alertAllSimComponents():void
		{
			for each (var i:Function in this.registeredSimComponentUpdateFunctions)
			{
				i(this.currentData, this.currentCData, this.data);
			}
			
		}
		
		public function attachToAnotherDatamanager(d:SimDataManager):void
		{
			this.isAttachedToAnotherDatamanager = true;
			this.attachedToDatamanager = d;
		}
		
		public function disattchFromAnotherDatamanager():void
		{
			this.isAttachedToAnotherDatamanager = false;
			this.attachedToDatamanager = null;
		}
		
		public function registerSlider(s:HSlider):void
		{
			this.controlSliders.push(s);
			s.addEventListener(SliderEvent.CHANGE, this.onChangeOfSlider);
			s.enabled = false;
		}
		
		public function removeRegisteredSlider(s:HSlider):void
		{
			this.controlSliders.splice(this.controlSliders.indexOf(s),1);
			s.removeEventListener(SliderEvent.THUMB_DRAG, this.onChangeOfSlider);
		}
		
		public function registerLiveButton(b:Button):void
		{
			this.liveButtons.push(b);
			b.addEventListener(MouseEvent.CLICK, this.onClickOfLiveButton);
			b.enabled = false;
		}
		
		public function removeLiveButton(b:Button):void
		{
			this.liveButtons.splice(this.liveButtons.indexOf(b),1);
			b.removeEventListener(MouseEvent.CLICK, this.onClickOfLiveButton);
		}
		
		public function registerPlayButton(b:Button):void
		{
			this.playButtons.push(b);
			b.addEventListener(MouseEvent.CLICK, this.onClickOfPlayButton);
			b.enabled = false;
		}
		
		public function removePlayButton(b:Button):void
		{
			this.playButtons.splice(this.playButtons.indexOf(b),1);
			b.removeEventListener(MouseEvent.CLICK, this.onClickOfPlayButton);
		}
		
		public function registerSimTimeCounter(l:Label):void
		{
			this.simTimeCounters.push(l);
		}
		
		public function removeSimTimeCounter(l:Label):void
		{
			this.simTimeCounters.splice(this.simTimeCounters.indexOf(l),1);
		}
		
		public function registerTotalSimTimeCounter(l:Label):void
		{
			this.totalSimTimeCounters.push(l);
		}
		
		public function removeTotalSimTimeCounter(l:Label):void
		{
			this.totalSimTimeCounters.splice(this.totalSimTimeCounters.indexOf(l),1);
		}
		
		private function onClickOfPlayButton(e:MouseEvent):void
		{
			this.reset();
			if (this.isPaused == true)
			{
				this.isPaused = false;
				this.isLive = false;
				this.start();
			}
			else
			{
				this.isPaused = true;
				this.isLive = false;
			}
			this.updateControls(null);
		}
		
		private function onClickOfLiveButton(e:MouseEvent):void
		{
			this.reset();
			this.isPaused = false;
			this.isLive = true;
			this.setCurrentDataForTime(-1);
			this.updateControls(null);
			this.start();
			
		}
		
		private function onChangeOfSlider(e:SliderEvent):void
		{
			this.reset();
			this.isLive = false;
			this.isPaused = true;
			this.setCurrentDataForTime(e.currentTarget.value);
			this.updateControls(e.currentTarget as HSlider);
			this.alertAllSimComponents();
			//if(this.isPaused == false) this.start();
		}
		
		private function setCurrentDataForTime(n:Number):void
		{
			// If n = -1 then LIVE
			var dataFound:Boolean = false;
			var cdataFound:Boolean = false;
			var start:int = 0;
			var l:int = this.data.length;
			var i:int = 0;
			if (n == -1)
			{
				for (i = this.data.length - 1; i >= 0 && (dataFound == false || cdataFound == false); i--)
				{
					if (this.data[i].cdata != "" && cdataFound == false)
					{
						this.currentCData = new XML (this.data[i].cdata);
						this.currentCDataIndex = i;
						cdataFound = true;
					}
					if (this.data[i].data != "" && dataFound == false)
					{
						this.currentData = new XML(this.data[i].data);
						this.currentSimTime = this.currentData.time;
						this.currentDataIndex = i;
						dataFound = true;
					}
				}
			}
			else
			{
				if (n > this.currentData.time || n > this.currentCData.time) start = this.currentDataIndex;
				for (i = start; i < l && (dataFound == false || cdataFound == false); i++)
				{
					if (this.data[i].cdata != "")
					{
						if (this.data[i].cdata.time >= n && cdataFound == false)
						{
							if(this.data[i].cdata.time > n)
							{
								this.currentCData = new XML(this.data[i - 1].cdata);
								this.currentCDataIndex = i - 1;
							} 
							else
							{
								this.currentCData = new XML(this.data[i].cdata);
								this.currentCDataIndex = i - 1;
							} 
							cdataFound = true;
						}
					}
					if (this.data[i].data != "")
					{
						if (this.data[i].data.time >= n && dataFound == false)
						{
							if(this.data[i].data.time > n)
							{
								this.currentData = new XML(this.data[i - 1].data);
								this.currentDataIndex = i - 1;
							}
							else
							{
								this.currentData = new XML(this.data[i].data);
								this.currentDataIndex = i;
							} 
							this.currentSimTime = this.currentData.time;
							dataFound = true;
						}
					}
				}
			}
		}

	}
}