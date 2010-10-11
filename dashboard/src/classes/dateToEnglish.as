/*
Dan Florio, aka: polyGeek
http://polygeek.com/flex/513_ConvertSecondsToEnglish/srcview/index.html
*/

package classes {
    public class dateToEnglish {
        public function dateToEnglish() {}
        
        public static const EXACT_SECONDS_IN_YEAR:uint =     31556926;     // according to Google
        public static const EXACT_SECONDS_IN_MONTH:Number =    2629743.83;    // according to Google
        public static const EXACT_SECONDS_IN_DAY:uint =        86400;        // according to Google
        
        public static const SECONDS_IN_MONTH:Number =        60 * 60 * 24 * 30.4167;// non leap year
        public static const SECONDS_IN_DAY:uint =             60 * 60 * 24;//    86400;
        public static const SECONDS_IN_YEAR:uint =             SECONDS_IN_DAY * 365;
        
        public static const MILLISECONDS_IN_MINUTE:int =     1000 * 60;
        public static const MILLISECONDS_IN_HOUR:int =         1000 * 60 * 60;
        public static const MILLISECONDS_IN_DAY:int =         1000 * 60 * 60 * 24;

        public static function convertSeconds( n:Number ):String {
            n *= 1000;
            
            var d:String = "";
            var and:String;
            var time:Date = new Date( n );
            
            var years:uint = time.fullYearUTC - 1970;
            var months:uint = time.monthUTC;
            var days:uint = time.dateUTC - 1;
            var hours:uint = time.hoursUTC;
            var mins:uint = time.minutesUTC;
            var secs:uint = time.secondsUTC;
            
            // years    
            if( years > 0 && ( months > 0 || days > 0 || hours > 0 || mins > 0 || secs > 0 ) ) {
                d = ( years > 1 ) ? 
                                        String( years ) + " years" : 
                                        "1 year";
            } else if( years > 0 ){
                d = ( years > 1 ) ? 
                                        String( years ) + " years" : 
                                        "1 year";
            }
            
            // months
            if( months > 0 && ( days > 0 || hours > 0 || mins > 0 || secs > 0 ) ) {    
                d = insertEndSpace( d );
                d += ( months > 1 ) ?
                                        String( months ) + " months" :
                                        "1 month";
            } else if( months > 0 ) {
                and = ( d.length > 0 ) ? " and " : "";
                d += ( months > 1 ) ?
                                        and + String( months ) + " months" :
                                        and + "1 month";
                
            }
            
            // days
            if( days > 0 && ( hours > 0 || mins > 0 || secs > 0 ) ) {
                d = insertEndSpace( d );
                d += ( days > 1 ) ?
                                        String( days ) + " days" :
                                        "1 day";
            } else if( days > 0 ) {
                and = ( d.length > 0 ) ? " and " : "";
                d += ( days > 1 ) ?
                                        and + String( days ) + " days" :
                                        and + "1 day";
            }
            
            // hours
            if( hours > 0 && ( mins > 0 || secs > 0 ) ) {
                d = insertEndSpace( d );
                d += ( hours > 1 ) ?
                                        String( hours ) + " hours" :
                                        "1 hour";
            } else if( hours > 0 ) {
                and = ( d.length > 0 ) ? " and " : "";
                d += ( hours > 1 ) ?
                                        and + String( hours ) + " hours" :
                                        and + "1 hour";                
            }
            
            // minutes
            if( mins > 0 && secs > 0 ) {
                d = insertEndSpace( d );
                d += ( mins > 1 ) ?
                                        String( mins ) + " minutes" :
                                        "1 minute";
            } else if( mins > 0 ) {
                and = ( d.length > 0 ) ? " and " : "";
                d += ( mins > 1 ) ?
                                        and + String( mins ) + " minutes" :
                                        and + "1 minute";
            }
            
            // seconds    
            if( secs > 0 && d.length > 0 ) {
                d += ( secs > 1 ) ?
                                        " and " + String( secs ) + " seconds" :
                                        " and 1 second";
            } else if( secs > 0 ) {
                d = insertEndSpace( d );
                d += ( secs > 1 ) ?
                                        String( secs ) + " seconds" :
                                        "1 second";
            }         
            return d;
        }
        
        private static function insertEndSpace( s:String ):String {
            s += ( s.length > 0 ) ? " " : "";
            return s;
        }
        
        public static function convertSecondsWithoutWords(n:Number):String
        {
        	var s:String = convertSeconds(n);
        	var pattern:RegExp = new RegExp("\D*","");
        	s = s.replace(pattern,":");
        	return s;
        }

    }
}