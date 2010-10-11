package classes
{
	public class xml2xml
	{
		import classes.*;
		import mx.controls.dataGridClasses.DataGridColumn;
		import mx.collections.*;
		public var rLabel:String = new String;
		public var rTag:String = new String;
		public var rProperty:String = new String;
		public var key:String = new String;
		public var cLabel:String = new String;
		public var cTag:String = new String;
		public var cProperty:String = new String;
		public var xml:XML = new XML;
		public var xmlProcessed:XML = new XML;
		public var xmlList:XMLList = new XMLList;
		public var xmlListProcessed:XMLList = new XMLList;
		public var menuLabel:String = new String;
		
		static protected function XmlList2Array(x:XMLList,countDuplicates:Boolean=false):Array
		{
			var num:Array = new Array;
			var duplicate:Boolean = false;
			for each (var item:XML in x){
				if (countDuplicates == true) num.push(item);
				else{
					for each (var item2:XML in num){
						if(item == item2) duplicate = true;
					}
					if(duplicate == false)num.push(item);
					duplicate = false;
				}
			}
			return num;
		}
		static protected function getLengthOfXmlArray(x:XMLList,countDuplicates:Boolean=false):int
		{
			var num:Array = new Array;
			var duplicate:Boolean = false;
			for each (var item:XML in x){
				if (countDuplicates == true) num.push(item);
				else{
					for each (var item2:XML in num){
						if(item == item2) duplicate = true;
					}
					if(duplicate == false)num.push(item);
					duplicate = false;
				}
			}
			return num.length;
		}
		protected function xmlStats():Object
		{
			var o:Object = new Object;
			o.numOfKeys = getLengthOfXmlArray(E4XParser.evaluate(this.xml, '..'+this.rTag+'.'+this.key));
			o.numOfRows = getLengthOfXmlArray(E4XParser.evaluate(this.xml, '..'+this.rTag+'.'+this.rProperty));
			o.numOfCols = 0;
			o.arrOfKeys = XmlList2Array(E4XParser.evaluate(this.xml, '..'+this.rTag+'.'+this.key));
			for each(var m:XML in o.arrOfKeys){
				var e4x2:String = '..'+this.cTag+".("+this.key+" == "+m.toString()+")."+this.cProperty;
				var numOfColsTemp:int = getLengthOfXmlArray(E4XParser.evaluate(this.xml, e4x2));
				if(o.numOfCols <= numOfColsTemp) o.numOfCols = numOfColsTemp; 
			}
			return o;
		}
		public function toDatagridDataProvider():XML
		{
			var s:Object = this.xmlStats();
			var xmlProcessed:String = "<root>";
			for(var i:int = 0; i < s.numOfRows; i++){
				var rowName:String = E4XParser.evaluate(this.xml, '..'+this.rTag+"["+i+"]."+this.rProperty);
				var rowKey:String = E4XParser.evaluate(this.xml, '..'+this.rTag+"["+i+"]."+this.key); 
				xmlProcessed += "<rootItem>"+"<"+this.rProperty+">"+
				rowName+
				"</"+this.rProperty+">" ;		
				for(var j:int = 0; j < s.numOfCols; j++){
					var e4x:String = this.cTag+".("+this.key+" == "+rowKey+")."+this.cProperty;
					var rowList:XMLList = E4XParser.evaluate(this.xml, '..'+this.cTag+".("+this.key+" == "+rowKey+")."+this.cProperty);
					var rowListLength:int = getLengthOfXmlArray(rowList);
					var cellName:String = rowList[j];
					if(cellName == null) cellName = "";
					xmlProcessed += "<"+this.cTag+""+(j+1)+">"+
					cellName+
					"</"+this.cTag+""+(j+1)+">";
				}
				xmlProcessed += "</rootItem>";		
			}
			xmlProcessed += "</root>";
			this.xmlProcessed = new XML(xmlProcessed);
			return this.xmlProcessed;
		}
		static protected function createArrayOfDgCol(num:int):Array
		{
			var cols:Array = new Array;
			for (var i:int = 0; i < num; i++) {
				cols[i] = new DataGridColumn();
			}
			return cols;
		}
		public function toDatagridColumns():Array
		{
			var s:Object = this.xmlStats();
			var columns:Array = createArrayOfDgCol(s.numOfCols + 1);
			columns[0].dataField = this.rProperty;
			columns[0].headerText = this.rLabel;
			for (var i:int = 1; i <= s.numOfCols; i++){
				columns[i].dataField = this.cTag+i;
				columns[i].headerText = this.cLabel+" "+i;
			}
			return columns;
		}
		public function swapButton():void
		{
			var rowLabelTemp:String = this.cLabel;
			var rowTagTemp:String = this.cTag;
			var rowPropTemp:String = this.cProperty;
			this.cLabel = this.rLabel;
			this.cTag = this.rTag;
			this.cProperty = this.rProperty;
			this.rLabel = rowLabelTemp;
			this.rTag = rowTagTemp;
			this.rProperty = rowPropTemp;
			this.toDatagridDataProvider();			 
		}
		static public function eval2String(x:XML,s:String):String
		{
			var t:XMLList = E4XParser.evaluate(x,s);
			return t.toString()
		}
		public function toMenuBarDataProvider():XMLListCollection
		{
			var xmlListProcessed:String = "<>";
			var num_of_row:int = this.xml.serverResponse.num;
			var current_menu_cat:String = this.xml.serverResponse.row[0].menu_cat_name;
			xmlListProcessed += "<menuitem label=\""+current_menu_cat+"\">";
			for(var j:int = 0; j < num_of_row; j++){
				if(current_menu_cat != this.xml.serverResponse.row[j].menu_cat_name){
					current_menu_cat = this.xml.serverResponse.row[j].menu_cat_name;
					xmlListProcessed += "</menuitem>";
					xmlListProcessed += "<menuitem label=\""+current_menu_cat+"\">";
				}		
				xmlListProcessed += "<menuitem label=\""+this.xml.serverResponse.row[j].dash_name+"\" data=\""+this.xml.serverResponse.row[j].dash_id+"\"/>";
			}
			xmlListProcessed += "</menuitem>";
			xmlListProcessed += "</>";						
					//"<menuitem label=\"Dashboards\" data=\"top\">"+
			return new XMLListCollection(this.xmlListProcessed = new XMLList(xmlListProcessed));
		}
		public function menuBarEventTitleData(id:String):String {
			return E4XParser.evaluate(this.xml, "serverResponse.row.(dash_id == "+id+").dash_title");
		}
		public function menuBarEventPathData(id:String):String {
			return E4XParser.evaluate(this.xml, "serverResponse.row.(dash_id == "+id+").dash_path");
		}
		public function toComboDataProvider():ArrayCollection
		{
			var s:String = new String;
			var a:Array = new Array;
			var n:int = this.xml.serverResponse.num;
			
			for(var i:int = 0; i < n; i++)
			{
				s = E4XParser.evaluate(this.xml, "serverResponse."+this.rTag+"["+i+"]."+this.rProperty).toString();
				a.push(s);
			}
			return new ArrayCollection(a);
		}
	}
}