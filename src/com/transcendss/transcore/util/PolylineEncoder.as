package com.transcendss.transcore.util
{
	import com.google.maps.Color;
	import com.google.maps.LatLng;
	import com.google.maps.overlays.EncodedPolylineData;
	import com.google.maps.overlays.Polygon;
	import com.google.maps.overlays.Polyline;
	import com.google.maps.overlays.PolylineOptions;
	import com.google.maps.styles.StrokeStyle;
	
	public class PolylineEncoder
	{
		private var x:Number;
		private var y:Number;
		private var numLevels:int;
		private var zoomFactor:int;
		private var verySmall:Number;
		private var forceEndpoints:Boolean;
		private var zoomLevelBreaks:Array;
	
		public function PolylineEncoder(numLevels:int=18, zoomFactor:int=3, verySmall:Number=0.00001, forceEndpoints:Boolean=true)
		{
			var i:int;
			this.numLevels = numLevels;
			this.zoomFactor = zoomFactor;
			this.verySmall = verySmall;
			this.forceEndpoints = forceEndpoints;
			this.zoomLevelBreaks = new Array(numLevels);
			for(i = 0; i < numLevels; i++) {
				zoomLevelBreaks[i] = verySmall*Math.pow(zoomFactor, numLevels-i-1);
			}			
		}
		
		// The main function.  Essentially the Douglas-Peucker
		// algorithm, adapted for encoding. Rather than simply
		// eliminating points, we record theirs from the
		// segment which occurs at that recursive step.  These
		// distances are then easily converted to zoom levels.
		public function dpEncode(points:Array):Array
		{
			var absMaxDist:Number = 0;
			var stack:Array = [];
			var dists:Array = new Array(points.length);
			var maxDist:Number;
			var maxLoc:int;
			var temp:Number;
			var current:Array=[];
			var encodedPoints:String
			var encodedLevels:String;
			var segmentLength:Number;	
			
			if(points.length > 2) {
				stack.push([0, points.length-1]);
				while(stack.length > 0) {
					current = stack.pop();
					maxDist = 0;

					segmentLength = Math.pow(points[current[1]].lat()-points[current[0]].lat(),2) + 
						Math.pow(points[current[1]].lng()-points[current[0]].lng(),2);

					for(var i:int = current[0]+1; i < current[1]; i++) {
						temp = distance(points[i], 
							points[current[0]], points[current[1]],
							segmentLength);
						if(temp > maxDist) {
							maxDist = temp;
							maxLoc = i;
							if(maxDist > absMaxDist) {
								absMaxDist = maxDist;
							}
						}
					}
					if(maxDist > verySmall) {
						dists[maxLoc] = maxDist;
						stack.push([current[0], maxLoc]);
						stack.push([maxLoc, current[1]]);
					}
				}
			}	
			encodedPoints = createEncodings(points, dists);
			encodedLevels = encodeLevels(points, dists, absMaxDist);
			var rArray:Array = [];
			rArray[0] = encodedPoints;//.replace(/\\/g,"\\\\")
			rArray[1] = encodedLevels;
			
			return rArray;			
		}

		public function dpEncodeToGPolyline (points:Array,pColor:uint=0x800000, pWeight:int=3, pOpacity:Number= 0.9):Polyline 
		{
			var ecArray:Array = dpEncode(points); //encoded array or strings (points and levels)
			var encodedPoints:String = ecArray[0]; //"sminFv|axSkCoF";
			var encodedLevels:String = ecArray[1];
			
			var encodedPolyData:EncodedPolylineData = new EncodedPolylineData(encodedPoints,32,encodedLevels,4);
			var sStyle:StrokeStyle = new StrokeStyle();
			sStyle.alpha = pOpacity;
			sStyle.color = pColor;
			sStyle.thickness = pWeight;
			var polyOptions:PolylineOptions = new PolylineOptions();
			polyOptions.strokeStyle = sStyle;
			
			return Polyline.fromEncoded(encodedPolyData,polyOptions);	
		}
		
		public function dpPolylineFromEncodedString(encodedPoints:String,encodedLevels:String,pColor:uint=0x800000, pWeight:int=3, pOpacity:Number= 0.9):Polyline
		{
			var encodedPolyData:EncodedPolylineData = new EncodedPolylineData(encodedPoints,32,encodedLevels,4);
			var sStyle:StrokeStyle = new StrokeStyle();
			sStyle.alpha = pOpacity;
			sStyle.color = pColor;
			sStyle.thickness = pWeight;
			var polyOptions:PolylineOptions = new PolylineOptions();
			polyOptions.strokeStyle = sStyle;
			
			return Polyline.fromEncoded(encodedPolyData,polyOptions);	
		}
		
//		public function dpEncodeToGPolygon (pointsArray:Array,boundaryColor:uint=0x000000, boundaryWeight:int= 3, boundaryOpacity:Number= 0.9,
//																fillColor:uint=0x000080, fillOpacity:Number= 0.3, fill:Boolean= true, outline:Boolean= true) {
//			var i, boundaries:Array = new Array(0);
//			var encodedPolyData:EncodedPolylineData;
//			var ecArray:Array;
//			var encodedPoints:String;
//			var encodedLevels:String;
//			
//			for(i=0; i<pointsArray.length; i++) {
//				//boundaries.push(this.dpEncodeToJSON(pointsArray[i],boundaryColor, boundaryWeight, boundaryOpacity));
//				
//				ecArray = dpEncode(pointsArray[i]); //encoded array or strings (points and levels)
//				encodedPoints = ecArray[0]; 
//				encodedLevels = ecArray[1];				
//				encodedPolyData = new EncodedPolylineData(encodedPoints,32,encodedLevels,4);
//				var sStyle:StrokeStyle = new StrokeStyle();
//				sStyle.alpha = pOpacity;
//				sStyle.color = pColor;
//				sStyle.thickness = pWeight;
//				var polyOptions:PolylineOptions = new PolylineOptions();
//				polyOptions.strokeStyle = sStyle;
//				boundaries.push(Polyline.fromEncoded(encodedPolyData,polyOptions));
//			}
//			return boundaries;
//		}		
		
	
		// distance(p0, p1, p2) computes the distance between the point p0
		// and the segment [p1,p2].  This could probably be replaced with
		// something that is a bit more numerically stable.
		public function distance (p0:Object, p1:Object, p2:Object, segLength:Number):Number 
		{
			var u:Number;
			var out:Number;
			
			if(p1.lat() === p2.lat() && p1.lng() === p2.lng()) {
				out = Math.sqrt(Math.pow(p2.lat()-p0.lat(),2) + Math.pow(p2.lng()-p0.lng(),2));
			}
			else {
				u = ((p0.lat()-p1.lat())*(p2.lat()-p1.lat())+(p0.lng()-p1.lng())*(p2.lng()-p1.lng()))/
					segLength;
				
				if(u <= 0) {
					out = Math.sqrt(Math.pow(p0.lat() - p1.lat(),2) + Math.pow(p0.lng() - p1.lng(),2));
				}
				if(u >= 1) {
					out = Math.sqrt(Math.pow(p0.lat() - p2.lat(),2) + Math.pow(p0.lng() - p2.lng(),2));
				}
				if(0 < u && u < 1) {
					out = Math.sqrt(Math.pow(p0.lat()-p1.lat()-u*(p2.lat()-p1.lat()),2) +
						Math.pow(p0.lng()-p1.lng()-u*(p2.lng()-p1.lng()),2));
				}
			}
			return out;
		}	
		
		// The createEncodings function is very similar to Google's
		// http://www.google.com/apis/maps/documentation/polyline.js
		// The key difference is that not all points are encoded, 
		// since some were eliminated by Douglas-Peucker.
		public function createEncodings (points:Array, dists:Array):String 
		{
			var dlat:Number;
			var dlng:Number;
			var plat:Number = 0;
			var plng:Number = 0;
			var encoded_points:String = "";
			
			for(var i:int = 0; i < points.length; i++) {
				if(dists[i] != null || i == 0 || i == points.length-1) {
					var point:LatLng = points[i];
					var lat:Number = point.lat();
					var lng:Number = point.lng();
					var late5:Number = Math.floor(lat * 1e5);
					var lnge5:Number = Math.floor(lng * 1e5);
					dlat = late5 - plat;
					dlng = lnge5 - plng;
					plat = late5;
					plng = lnge5;
					encoded_points += encodeSignedNumber(dlat) + encodeSignedNumber(dlng);
				}
			}
			return encoded_points;
		}	
		
		// This computes the appropriate zoom level of a point in terms of it's 
		// distance from the relevant segment in the DP algorithm.  Could be done
		// in terms of a logarithm, but this approach makes it a bit easier to
		// ensure that the level is not too large.
		private function computeLevel(dd:Number):int 
		{
			var lev:int=0;
			if(dd > verySmall) {
				lev=0;
				while(dd < zoomLevelBreaks[lev]) {
					lev++;
				}
			}
			return lev;
		}
		

		
		// Now we can use the previous function to march down the list
		// of points and encode the levels.  Like createEncodings, we
		// ignore points whose distance (in dists) is undefined.
		public function encodeLevels(points:Array, dists:Array, absMaxDist:Number):String 
		{
			var encoded_levels:String = "";
			if(this.forceEndpoints) {
				encoded_levels += encodeNumber(numLevels-1);
			} 
			else {
				encoded_levels += encodeNumber(numLevels-computeLevel(absMaxDist)-1);
			}
			for(var i:int=1; i < points.length-1; i++) {
				if(dists[i] != null) {
					encoded_levels += encodeNumber(numLevels-computeLevel(dists[i])-1);
				}
			}
			if(forceEndpoints) {
				encoded_levels += encodeNumber(numLevels-1)
			} 
			else {
				encoded_levels += encodeNumber(numLevels-computeLevel(absMaxDist)-1)
			}
			return encoded_levels;
		}
		
		
		// This function is very similar to Google's, but I added
		// some stuff to deal with the double slash issue.
		public function encodeNumber(num:Number):String 
		{
			var encodeString:String = "";
			var nextValue:Number;
			var finalValue:Number;
			while (num >= 0x20) {
				nextValue = (0x20 | (num & 0x1f)) + 63;
				//     if (nextValue == 92) {
				//       encodeString += (String.fromCharCode(nextValue));
				//     }
				encodeString += (String.fromCharCode(nextValue));
				num >>= 5;
			}
			finalValue = num + 63;
			//   if (finalValue == 92) {
			//     encodeString += (String.fromCharCode(finalValue));
			//   }
			encodeString += (String.fromCharCode(finalValue));
			return encodeString;
		}
		
		// This one is Google's verbatim.
		public function encodeSignedNumber(num:Number):String 
		{
			var sgn_num:Number = num << 1;
			
			if (num < 0) {
				sgn_num = ~(sgn_num);
			}
			return(encodeNumber(sgn_num));
		}
		
		
		// PolylineEncoder.latLng
		public function setLatLng(yVal:Number, xVal:Number):void
		{
			y = yVal;
			x = xVal;
		}			
			
		public function getLat():Number
		{
			return y;
		}	
		public function getLong():Number
		{
			return x;
		}	
		
		public function pointsToLatLngs(points:Array):Array
		{
			var latLngs:Array = [];
			for(var i:int=0; i < points.length; i++) {
				x = points[i][0];
				y = points[i][1];
				latLngs.push(points[i][0], points[i][1]);
			}
			return latLngs;
		}

		public function pointsToGLatLngs(points:Array):Array{
			var gLatLngs:Array = [];
			for(var i:int=0; i < points.length; i++) {
				gLatLngs.push(new LatLng(points[i][0], points[i][1]));
			}
			return gLatLngs;
		}
		
	}
}