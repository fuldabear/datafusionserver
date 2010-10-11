// ActionScript file
import classes.*;

import mx.charts.series.LineSeries;
import mx.collections.ArrayCollection;

public var canvas:simComponentCanvas = new simComponentCanvas;
[Bindable] private var simulationTableDataProvider:XML = new XML;
[Bindable] private var componentTableDataProvider:XML = new XML;
[Bindable] private var stateTableDataProvider:XML = new XML;
[Bindable] private var simulationComboDataProvider:ArrayCollection = new ArrayCollection;
[Bindable] public var listOfDataVarablesDataProvider:ArrayCollection = new ArrayCollection;
[Bindable] public var lineChartDataProvider:ArrayCollection = new ArrayCollection;
private var simulationsTableData:XML = new XML;
private var componentsTableData:XML = new XML;
private var statesTableData:XML = new XML;
private var http:dashML = new dashML;
private var currentSimulationId:String = new String;
private var selectedComponentIdInTable0:String = new String;
private var selectedComponentIdInTable1:String = new String;
private var selectedStateIdInTable:String = new String;
private var simData:SimDataManager = new SimDataManager;


private function init():void
{
	//this.canvas.setBackground2(xml:String);
	this.canvas.setBackground(this.cwrsadSVG);
	drawingArea.addChild(canvas);
	this.simData.registerLiveButton(this.liveButton);
	this.simData.registerPlayButton(this.playButton);
	this.simData.registerSlider(this.timeSlider);
	this.simData.registerSimTimeCounter(this.timeAt);
	this.simData.registerTotalSimTimeCounter(this.timeMax);
	this.simData.registeredSimComponentUpdateFunction(this.canvas.update);
	this.getListOfSimulations();	
} 

public function newChiller(percentX:Number,percentY:Number,percentH:Number,percentW:Number,rotation:Number,select:Boolean = false):void
{
	this.canvas.addSimComponent([chiller_green,chiller_red,chiller_gray_green,chiller_gray_red],percentX,percentY,percentH,percentW,rotation);
	this.canvas.lastSimComponent.setSource(1);
	this.canvas.lastSimComponent.simComponentType = "chiller";
	if(select == true) this.canvas.lastSimComponent.selectSimComponent();
}

public function newPump(percentX:Number,percentY:Number,percentH:Number,percentW:Number,rotation:Number,select:Boolean = false):void
{
	this.canvas.addSimComponent([pump_green,pump_red,pump_gray_green,pump_gray_red],percentX,percentY,percentH,percentW,rotation);
	this.canvas.lastSimComponent.setSource(1);
	this.canvas.lastSimComponent.simComponentType = "pump";
	if(select == true) this.canvas.lastSimComponent.selectSimComponent();
}

public function newLoad(percentX:Number,percentY:Number,percentH:Number,percentW:Number,rotation:Number,select:Boolean = false):void
{
	this.canvas.addSimComponent([load_green,load_red,load_gray_green,load_gray_red],percentX,percentY,percentH,percentW,rotation);
	this.canvas.lastSimComponent.setSource(1);
	this.canvas.lastSimComponent.simComponentType = "load";
	if(select == true) this.canvas.lastSimComponent.selectSimComponent();
}

public function newValve(percentX:Number,percentY:Number,percentH:Number,percentW:Number,rotation:Number,select:Boolean = false):void
{
	this.canvas.addSimComponent([valve_green,valve_red,valve_gray_green,valve_gray_red],percentX,percentY,percentH,percentW,rotation);
	this.canvas.lastSimComponent.setSource(1);
	this.canvas.lastSimComponent.simComponentType = "valve";
	if(select == true) this.canvas.lastSimComponent.selectSimComponent();
}

public function closePanel():void
{
	this.canvas.deselectAllSimComponents();
	this.mode.selectedIndex = 0;
	this.changeState();
}

public function updatePanel():void
{
	if(this.dragAndDropCheckBox.selected != this.canvas.currentlySelectedSimComponent.dragable)
	{
		this.dragAndDropCheckBox.selected = this.canvas.currentlySelectedSimComponent.dragable;	
	}
	if(this.sizeStepper.value != this.canvas.currentlySelectedSimComponent.percentHeight)
	{
		this.sizeStepper.value = this.canvas.currentlySelectedSimComponent.percentHeight;
	}
	if(this.rotationStepper.value != this.canvas.currentlySelectedSimComponent.rotation)
	{
		this.rotationStepper.value = this.canvas.currentlySelectedSimComponent.rotation;
	}
	if(this.simComponentVariableSelector.text != this.canvas.currentlySelectedSimComponent.componentVarable)
	{
		this.simComponentVariableSelector.text = this.canvas.currentlySelectedSimComponent.componentVarable;
	}
	if(this.linechart != null)
	{
		var a:Array = new Array;
		var s:Array = new Array;
		var l:LineSeries;
		for each (var i:XML in this.canvas.simulationData)
		{
			var o:Object = new Object;
			for each (var j:String in this.canvas.currentlySelectedSimComponent.varablesToPlot)
			{
				o[j] = new Number(E4XParser.evaluate(i,"..data."+j).toString());
			}
			o.time = new Number(i.data.time.toString());
			a.push(o);
		}
		for each (var k:String in this.canvas.currentlySelectedSimComponent.varablesToPlot)
		{
			l = new LineSeries;
			l.yField = k;
			l.displayName = k;
			s.push(l);
		}
		this.linechart.series = s;
		if(a.length > 0) this.lineChartDataProvider = new ArrayCollection(a);
	}
}

public function changeState():void
{
	var number:int = this.mode.selectedIndex;
	if(number == 0) this.currentState = "";
	if(number == 1) this.currentState = "configureComponent";
	if(number == 2) this.currentState = "configureDash";
	this.updatePanel();
}

public function getListOfSimulations():void
{
	this.http.sendSql("SELECT * FROM simulations;",gotListOfSimulations);
}

public function gotListOfSimulations(result:Object, token:Object):void
{
	this.simulationsTableData = new XML(result.result as String);
	var n:xml2xml = new xml2xml;
	n.xml = this.simulationsTableData; //new XML(E4XParser.evaluate(this.simulationsTableData,"serverResponse").toString());
	n.rTag = "row";
	n.rProperty = "simulation_name";
	this.simulationsTable.columns = n.toDatagridColumns();
	this.simulationTableDataProvider = n.toDatagridDataProvider();
	this.simulationComboDataProvider = n.toComboDataProvider();
}

public function selectSimulation(event:Event):void
{
	// !!! add enabling code here for those function that should not be avalible until after a simulation has been selected
	this.canvas.delAllSimComponents();
	var id:String;
	var index:int;
	if(this.simulationsTable == event.currentTarget)
	{
		index = simulationsTable.selectedIndex as int;
		this.currentSimulationId = E4XParser.evaluate(this.simulationsTableData,"serverResponse.row.simulation_id["+index+"]").toString();
		this.simulationIdBox.text = this.currentSimulationId;
		this.simulationNameBox.text = E4XParser.evaluate(this.simulationsTableData,"serverResponse.row.simulation_name["+index+"]").toString();
		this.simulationDiscBox.text = E4XParser.evaluate(this.simulationsTableData,"serverResponse.row.simulation_discription["+index+"]").toString();
		this.simulationIpBox.text = E4XParser.evaluate(this.simulationsTableData,"serverResponse.row.simulation_source_ip["+index+"]").toString();
		id = this.currentSimulationId;
		this.simData.simulationId = id;
		this.simData.userId = 1; // this is a temp fix !!!!!
		this.simData.init();
	}
	else
	{
		index = loadDataFromCombo.selectedIndex as int;
		id = E4XParser.evaluate(this.simulationsTableData,"serverResponse.row.simulation_id["+index+"]").toString();
	}
	
	
	this.http.sendDashML("<dashML><dash_id>2</dash_id><config_data></config_data><simulation_id>"+id+"</simulation_id></dashML>",gotConfiguration);
}

private function gotConfiguration(result:Object, token:Object):void
{
	var xml:XML = new XML(result.result as String);
	var x:Number;
	var y:Number;
	var s:Number;
	var r:Number;
	var i:int;
	var j:int;

	var chillers:XMLList = E4XParser.evaluate(xml,"serverResponse.row.config_data.chiller");
	var numOfChillers:Number = chillers.length();
	for(i = 0; i < numOfChillers; i++)
	{
		x = xml.serverResponse.row.config_data.chiller[i].percentXofCenter;
		y = xml.serverResponse.row.config_data.chiller[i].percentYofCenter;
		s = xml.serverResponse.row.config_data.chiller[i].size;
		r = xml.serverResponse.row.config_data.chiller[i].rotation;
		this.newChiller(x,y,s,s,r);
		this.canvas.lastSimComponent.componentVarable = xml.serverResponse.row.config_data.chiller[i].componentVarable;
		
		var plot:XMLList = E4XParser.evaluate(xml,"serverResponse.row.config_data.chiller["+i+"].plot.varable");
		var numOfPlots:Number = plot.length();
		for(j = 0; j < numOfPlots; j++)
		{
			this.canvas.lastSimComponent.varablesToPlot.push(xml.serverResponse.row.config_data.chiller[i].plot.varable[j]);
		}
		var control:XMLList = E4XParser.evaluate(xml,"serverResponse.row.config_data.chiller["+i+"].control.varable");
		var numOfControls:Number = control.length();
		for(j = 0; j < numOfControls; j++)
		{
			this.canvas.lastSimComponent.varablesToControl.push(xml.serverResponse.row.config_data.chiller[i].control.name[j]);
			this.canvas.lastSimComponent.varablesToControlType.push(xml.serverResponse.row.config_data.chiller[i].control.type[j]);
			this.canvas.lastSimComponent.varablesToControlValue.push(xml.serverResponse.row.config_data.chiller[i].control.value[j]);
		}
	}
	var loads:XMLList = E4XParser.evaluate(xml,"serverResponse.row.config_data.load");
	var numOfloads:Number = loads.length();
	for(i = 0; i < numOfloads; i++)
	{
		x = xml.serverResponse.row.config_data.load[i].percentXofCenter;
		y = xml.serverResponse.row.config_data.load[i].percentYofCenter;
		s = xml.serverResponse.row.config_data.load[i].size;
		r = xml.serverResponse.row.config_data.load[i].rotation;
		this.newLoad(x,y,s,s,r);
		this.canvas.lastSimComponent.componentVarable = xml.serverResponse.row.config_data.load[i].componentVarable;
		
		plot = E4XParser.evaluate(xml,"serverResponse.row.config_data.load["+i+"].plot.varable");
		numOfPlots = plot.length();
		for(j = 0; j < numOfPlots; j++)
		{
			this.canvas.lastSimComponent.varablesToPlot.push(xml.serverResponse.row.config_data.load[i].plot.varable[j]);
		}
		control = E4XParser.evaluate(xml,"serverResponse.row.config_data.load["+i+"].control.varable");
		numOfControls = control.length();
		for(j = 0; j < numOfControls; j++)
		{
			this.canvas.lastSimComponent.varablesToControl.push(xml.serverResponse.row.config_data.load[i].control.name[j]);
			this.canvas.lastSimComponent.varablesToControlType.push(xml.serverResponse.row.config_data.load[i].control.type[j]);
			this.canvas.lastSimComponent.varablesToControlValue.push(xml.serverResponse.row.config_data.load[i].control.value[j]);
		}
	}
	var pumps:XMLList = E4XParser.evaluate(xml,"serverResponse.row.config_data.pump");
	var numOfpumps:Number = pumps.length();
	for(i = 0; i < numOfpumps; i++)
	{
		x = xml.serverResponse.row.config_data.pump[i].percentXofCenter;
		y = xml.serverResponse.row.config_data.pump[i].percentYofCenter;
		s = xml.serverResponse.row.config_data.pump[i].size;
		r = xml.serverResponse.row.config_data.pump[i].rotation;
		this.newPump(x,y,s,s,r);
		this.canvas.lastSimComponent.componentVarable = xml.serverResponse.row.config_data.pump[i].componentVarable;
		
		plot = E4XParser.evaluate(xml,"serverResponse.row.config_data.pump["+i+"].plot.varable");
		numOfPlots = plot.length();
		for(j = 0; j < numOfPlots; j++)
		{
			this.canvas.lastSimComponent.varablesToPlot.push(xml.serverResponse.row.config_data.pump[i].plot.varable[j]);
		}
		control = E4XParser.evaluate(xml,"serverResponse.row.config_data.pump["+i+"].control.varable");
		numOfControls = control.length();
		for(j = 0; j < numOfControls; j++)
		{
			this.canvas.lastSimComponent.varablesToControl.push(xml.serverResponse.row.config_data.pump[i].control.name[j]);
			this.canvas.lastSimComponent.varablesToControlType.push(xml.serverResponse.row.config_data.pump[i].control.type[j]);
			this.canvas.lastSimComponent.varablesToControlValue.push(xml.serverResponse.row.config_data.pump[i].control.value[j]);
		}
	}
	var valves:XMLList = E4XParser.evaluate(xml,"serverResponse.row.config_data.valve");
	var numOfvalves:Number = valves.length();
	for(i = 0; i < numOfvalves; i++)
	{
		x = xml.serverResponse.row.config_data.valve[i].percentXofCenter;
		y = xml.serverResponse.row.config_data.valve[i].percentYofCenter;
		s = xml.serverResponse.row.config_data.valve[i].size;
		r = xml.serverResponse.row.config_data.valve[i].rotation;
		this.newValve(x,y,s,s,r);
		this.canvas.lastSimComponent.componentVarable = xml.serverResponse.row.config_data.valve[i].componentVarable;
		
		plot = E4XParser.evaluate(xml,"serverResponse.row.config_data.valve["+i+"].plot.varable");
		numOfPlots = plot.length();
		for(j = 0; j < numOfPlots; j++)
		{
			this.canvas.lastSimComponent.varablesToPlot.push(xml.serverResponse.row.config_data.valve[i].plot.varable[j]);
		}
		control = E4XParser.evaluate(xml,"serverResponse.row.config_data.valve["+i+"].control.varable");
		numOfControls = control.length();
		for(j = 0; j < numOfControls; j++)
		{
			this.canvas.lastSimComponent.varablesToControl.push(xml.serverResponse.row.config_data.valve[i].control.name[j]);
			this.canvas.lastSimComponent.varablesToControlType.push(xml.serverResponse.row.config_data.valve[i].control.type[j]);
			this.canvas.lastSimComponent.varablesToControlValue.push(xml.serverResponse.row.config_data.valve[i].control.value[j]);
		}
	}
}

private function saveConfiguration():void
{
	this.http.sendDashML("<dashML><dash_id>2</dash_id><config_data>"+this.canvas.createConfigurationXml()+"</config_data><simulation_id>"+this.currentSimulationId+"</simulation_id></dashML>");
}

private function saveSimulationInfo():void
{
	this.http.sendSql("update simulations set simulation_name='"+this.simulationNameBox.text+"', simulation_discription='"+this.simulationDiscBox.text+"', simulation_source_ip='"+this.simulationIpBox.text+"' where simulation_id='"+this.currentSimulationId+"'",saveSimulationInfoResult);
}

private function saveComponent():void
{
	
}

private function saveButton():void
{
	if(this.editorPanelTabs.selectedIndex == 0 && this.currentState == "configureDash") this.saveSimulationInfo();
	if(this.editorPanelTabs.selectedIndex == 2 && this.currentState == "configureDash") this.saveComponent();
	else this.saveConfiguration();
}

private function saveSimulationInfoResult(result:Object, token:Object):void
{
	this.getListOfSimulations();
}

private function simulationNewButton():void
{
	this.http.sendSql("insert into simulations set simulation_name='NEW SIMULATION'",saveSimulationInfoResult);
}

private function simulationDuplicateButton():void
{
	
	this.http.sendSql("insert into simulations set simulation_name='"+this.simulationNameBox.text+" (COPY)', simulation_discription='"+this.simulationDiscBox.text+"', simulation_source_ip='"+this.simulationIpBox.text+"'",saveSimulationInfoResult);
}

private function simulationRemoveButton():void
{
	this.simulationDiscBox.text = "";
	this.simulationIdBox.text = "";
	this.simulationIpBox.text = "";
	this.simulationNameBox.text = "";
	this.canvas.delAllSimComponents();
	this.http.sendSql("delete from simulations where simulation_id='"+this.currentSimulationId+"'",saveSimulationInfoResult);
}

private function getListOfComponents0():void
{
	this.http.sendSql("select * from widgets",gotListOfComponents0);
}

private function getListOfComponents1():void
{
	this.http.sendSql("select * from widgets",gotListOfComponents1);
}

private function gotListOfComponents0(result:Object, token:Object):void
{
	this.componentsTableData = new XML(result.result as String);
	var n:xml2xml = new xml2xml;
	n.xml = this.componentsTableData; //new XML(E4XParser.evaluate(this.simulationsTableData,"serverResponse").toString());
	n.rTag = "row";
	n.rProperty = "widget_name";
	this.componentTable0.columns = n.toDatagridColumns();
	this.componentTableDataProvider = n.toDatagridDataProvider();
}

private function gotListOfComponents1(result:Object, token:Object):void
{
	this.componentsTableData = new XML(result.result as String);
	var n:xml2xml = new xml2xml;
	n.xml = this.componentsTableData; //new XML(E4XParser.evaluate(this.simulationsTableData,"serverResponse").toString());
	n.rTag = "row";
	n.rProperty = "widget_name";
	this.componentTable1.columns = n.toDatagridColumns();
	this.componentTableDataProvider = n.toDatagridDataProvider();
}

private function selectComponent0(event:Event):void
{
	var id:String;
	var index:int;
	index = componentTable0.selectedIndex as int;
	this.selectedComponentIdInTable0 = E4XParser.evaluate(this.simulationsTableData,"serverResponse.row.widget_id["+index+"]").toString();
}

private function selectComponent1(event:Event):void
{
	var id:String;
	var index:int;
	index = componentTable1.selectedIndex as int;
	this.selectedComponentIdInTable1 = E4XParser.evaluate(this.componentsTableData,"serverResponse.row.widget_id["+index+"]").toString();
	this.componentNameBox.text = E4XParser.evaluate(this.componentsTableData,"serverResponse.row.widget_name["+index+"]").toString();
	this.componentDiscBox.text = E4XParser.evaluate(this.componentsTableData,"serverResponse.row.widget_discription["+index+"]").toString();
	this.componentXBox.text = E4XParser.evaluate(this.componentsTableData,"serverResponse.row.widget_center_x["+index+"]").toString();
	this.componentYBox.text = E4XParser.evaluate(this.componentsTableData,"serverResponse.row.widget_center_y["+index+"]").toString();
	this.componentIdBox.text = this.selectedComponentIdInTable1;
	this.getListOfComponentStates();
}

private function getListOfComponentStates():void
{
	this.http.sendSql("select * from widgetStates where widget_id='"+this.selectedComponentIdInTable1+"'",gotListOfComponentStates);
}

private function gotListOfComponentStates(result:Object, token:Object):void
{
	this.statesTableData = new XML(result.result as String);
	var n:xml2xml = new xml2xml;
	n.xml = this.statesTableData; //new XML(E4XParser.evaluate(this.simulationsTableData,"serverResponse").toString());
	n.rTag = "row";
	n.rProperty = "state_name";
	this.stateTable.columns = n.toDatagridColumns();
	this.stateTableDataProvider = n.toDatagridDataProvider();
}

private function selectState(event:Event):void
{
	var id:String;
	var index:int;
	index = stateTable.selectedIndex as int;
	this.selectedStateIdInTable = E4XParser.evaluate(this.statesTableData,"serverResponse.row.state_id["+index+"]").toString();
	this.stateNameBox.text = E4XParser.evaluate(this.statesTableData,"serverResponse.row.state_name["+index+"]").toString();
	this.inSvg.text = this.http.decode(E4XParser.evaluate(this.statesTableData,"serverResponse.row.state_svg["+index+"]").toString());
	this.preSVG.xml = new XML(this.inSvg.text);
}

[Embed(source="cwrsad.svg")]
[Bindable]
public var cwrsadSVG:Class;

[Embed(source="chiller_green.svg")]
[Bindable]
public var chiller_green:Class;

[Embed(source="chiller_red.svg")]
[Bindable]
public var chiller_red:Class;

[Embed(source="chiller_gray_green.svg")]
[Bindable]
public var chiller_gray_green:Class;

[Embed(source="chiller_gray_red.svg")]
[Bindable]
public var chiller_gray_red:Class;

[Embed(source="load_green.svg")]
[Bindable]
public var load_green:Class;

[Embed(source="load_red.svg")]
[Bindable]
public var load_red:Class;

[Embed(source="load_gray_green.svg")]
[Bindable]
public var load_gray_green:Class;

[Embed(source="load_gray_red.svg")]
[Bindable]
public var load_gray_red:Class;

[Embed(source="pump_green.svg")]
[Bindable]
public var pump_green:Class;

[Embed(source="pump_red.svg")]
[Bindable]
public var pump_red:Class;

[Embed(source="pump_gray_green.svg")]
[Bindable]
public var pump_gray_green:Class;

[Embed(source="pump_gray_red.svg")]
[Bindable]
public var pump_gray_red:Class;

[Embed(source="valve_green.svg")]
[Bindable]
public var valve_green:Class;

[Embed(source="valve_red.svg")]
[Bindable]
public var valve_red:Class;

[Embed(source="valve_gray_green.svg")]
[Bindable]
public var valve_gray_green:Class;

[Embed(source="valve_gray_red.svg")]
[Bindable]
public var valve_gray_red:Class;