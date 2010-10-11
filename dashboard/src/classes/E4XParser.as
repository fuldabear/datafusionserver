package classes
{
	import flash.utils.Dictionary;
	import mx.utils.StringUtil;

	public class E4XParser
	{
		static protected var patterns:Dictionary = new Dictionary(false);

		static protected function sEqual( leftSide:String, rightSide:String ):Boolean {
			return ( StringUtil.trim( leftSide ) == StringUtil.trim( rightSide ) );
		}

		static protected function sNotEqual( leftSide:String, rightSide:String ):Boolean {
			return ( StringUtil.trim( leftSide ) != StringUtil.trim( rightSide ) );
		}

		static protected function sGreaterThan( leftSide:String, rightSide:String ):Boolean {
			return ( StringUtil.trim( leftSide ) > StringUtil.trim( rightSide ) );
		}

		static protected function sLessThan( leftSide:String, rightSide:String ):Boolean {
			return ( StringUtil.trim( leftSide ) < StringUtil.trim( rightSide ) );
		}

		static protected function nEqual( leftSide:String, rightSide:String ):Boolean {
			if ( isNaN( Number( leftSide ) ) || isNaN( Number( rightSide ) ) ) {
				return sEqual( leftSide, rightSide );
			}

			return ( Number( leftSide ) == Number( rightSide ) );
		}

		static protected function nNotEqual( leftSide:String, rightSide:String ):Boolean {
			if ( isNaN( Number( leftSide ) ) || isNaN( Number( rightSide ) ) ) {
				return sNotEqual( leftSide, rightSide );
			}

			return ( Number( leftSide ) != Number( rightSide ) );
		}

		static protected function nGreaterThan( leftSide:String, rightSide:String ):Boolean {
			if ( isNaN( Number( leftSide ) ) || isNaN( Number( rightSide ) ) ) {
				return sGreaterThan( leftSide, rightSide );
			}

			return ( Number( leftSide ) > Number( rightSide ) );
		}

		static protected function nLessThan( leftSide:String, rightSide:String ):Boolean {
			if ( isNaN( Number( leftSide ) ) || isNaN( Number( rightSide ) ) ) {
				return sLessThan( leftSide, rightSide );
			}

			return ( Number( leftSide ) < Number( rightSide ) );
		}

		static protected var comparisonMap:Object;
		static protected function getComparisonHashMap():Object {
			if ( !comparisonMap )
			{
				comparisonMap = new Object();
				comparisonMap[ 'string' ] = new Object();
				comparisonMap[ 'numeric' ] = new Object();

				comparisonMap[ 'string' ][ '==' ] = sEqual;
				comparisonMap[ 'string' ][ '!=' ] = sNotEqual;
				comparisonMap[ 'string' ][ '>' ] = sGreaterThan;
				comparisonMap[ 'string' ][ '<' ] = sLessThan;

				comparisonMap[ 'numeric' ][ '==' ] = nEqual;
				comparisonMap[ 'numeric' ][ '!=' ] = nNotEqual;
				comparisonMap[ 'numeric' ][ '>' ] = nGreaterThan;
				comparisonMap[ 'numeric' ][ '<' ] = nLessThan;
			}
			
			return comparisonMap;
		}

		static public var quotedAttrib:RegExp = /(@)\["*(\w+)"*\]/g;
		static public var quotedBrackets:RegExp = /\["*(\w+)"*\]/g;
		static public var brackets:RegExp = /\[(.+)\]/g;
		static public var descendant:RegExp = /\.\./g;
		static public var quotes:RegExp = /\"/g;
		static public var periods:RegExp = /\./g;
		static public var dotsInPredicate:RegExp = /(\([^\)]+)(\.)([^\)\.]+\))/g;
		static public var previousDots:RegExp = /(.+)(\(dot\))(.+)/g;

		static public function comparison( data:XMLList, comparison:String ):XMLList {
			var operands:Array;
			var returnList:XMLList = new XMLList();
			var comparisonType:String;
			var operator:String;

			//Loose the parens
			comparison = comparison.substr( 1, comparison.length - 2);

			//Right now we are just supporting these four basic operators
			//Feel free to add more for <=, >=, etc.
			if ( comparison.search( "==" ) > -1 ) {
				operator = "==";
			} else if ( comparison.search( "!=" ) > -1 ) {
				operator = "!=";
			} else if ( comparison.search( ">" ) > -1 ) {
				operator = ">";
			} else if ( comparison.search( "<" ) > -1 ) {
				operator = "<";
			} else
				throw new Error("Unknown Operator");

			operands = comparison.split( operator );
			
			var leftSide:String = operands[0];
			var rightSide:String = operands[1];

			if ( ( !leftSide.length ) || ( !rightSide.length ) )
				throw new Error("Missing operand in comparison " + comparison );

			//Does the right side have quotes?
			if ( rightSide.substr(0,1) == '"' ) {
				//Loose the quotes and do a string comparison
				rightSide = rightSide.substr( 1, rightSide.length - 2);
				comparisonType = "string";
			} else {
				//This means we are going to try the numeric test first,
				//however, we still might not be able to convert the criterion
				//to a number, in which case, we still revert to string
				comparisonType = "numeric";
			}

			var compareFunction:Object = getComparisonHashMap();
						
			var item:XML;
			for ( var i:int=0; i<data.length(); i++ ) {
				item = data[i];
				//trace( "compare : " + item[ leftSide ] + " with " + rightSide );
				
				if ( compareFunction[comparisonType][operator]( item[StringUtil.trim(leftSide)], rightSide ) )
				{
					returnList += item;
				}
			}
			
			return returnList;
		}
		
		static public function descend( data:XMLList, expression:String ):XMLList {
			//loose the double underscores
			expression = expression.substr( 2 );
			
			data = data.descendants( expression );
			
			return data;
		}		

		static public function evaluate( data:Object, expression:String ):XMLList {
			var items:Array;
			
			if ( !expression ) {
				return null;
			}

			if ( !patterns[ expression ] )
			{
				//In our particular application this code is used within datagrids, so the exact same
				//pattern is searched many time. Basically, we are just optimizing for this case by storing
				//the split array of strings when we encounter the same pattern
				var s:String = expression;

				//Handle any quoted strings after the @ by removing the quotes and brackets, not needed now
				s = s.replace(quotedAttrib, "$1$2" );

				//Handle any quoted strings inside of brackets and replace with a .
				s = s.replace(quotedBrackets, ".$1" );
				
				//Remove the remaining brackets and replace with a .
				s = s.replace(brackets, ".$1" );

				//We replace the descendant character with double underscores
				s = s.replace( descendant, ".__" );

				//This now gets extremely complicated. There are times when the
				//predicate is very complicated, for instance, regular expressions
				//right now we only support basic examples. Stay tuned for enhanced versions
				s = s.replace(dotsInPredicate, "$1(dot)$3" );
				
				//We split the string along the remaining periods
				items = s.split(periods);

				for ( var j:int=0;j<items.length;j++ ) {
					//We replace the phrase (dot) with real periods again as the split is now complete
					items[j] = items[j].replace(previousDots, "$1.$3" );
				}
				
				//Store this for the next round
				patterns[ expression ] = items;
			}
			else
			{
				items = patterns[ expression ];
			}

			var dataPtr:Object;

			var item:String;

			dataPtr = data;
			for ( var i:int = 0; i<items.length;i++ )
			{
				//items contains the expression, split apart to be examined
				item = items[ i ];
				if ( item.substr(0,1) == '(' ) {
					//This is a prediate filter, now the fun work begins
					dataPtr = comparison( XMLList( dataPtr ), item );
				}
				else if ( item.search( /__/ ) > -1 )
				{
					//this is a simple descendent case
					dataPtr = descend( XMLList( dataPtr ), item );
				}
				else
				{
					if ( item.substr(0,1) == '"' ) {
						//This handles the case where the user provides a quoted string to an
						//array reference
						item = item.replace(quotes, "");
					}

					//So long as the item exists, follow the pointer.
					if ( item != '' && dataPtr )
						dataPtr = dataPtr[ item ];
				}
			}
			
			return XMLList( dataPtr );
		}
	}
}