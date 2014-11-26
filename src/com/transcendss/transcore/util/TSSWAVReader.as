package com.transcendss.transcore.util
{
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.IDataInput;

	/**
	 *	TSSWAVReader reads in a .WAV waveform file and 
	 *  parses it into raw bytes for use with the Flex Sound Class  
	 *  Currently, it only supports 11kHz WAV files with 16 bit samples.
	 *  @author nkorzekwa
	 *  @version 0.1
	 */
	public class TSSWAVReader extends EventDispatcher
	{
		private var _frequency:int;
		private var _channels:int;
		private var _bitrate:int;
		private var _compressionCode:int;
		private var _audioBytes:ByteArray;
		
		public function TSSWAVReader()
		{
			_audioBytes = new ByteArray();
		}
		
		/**
		 *	loadAudioFromFile takes a file object, reads it using FileMode.READ, and calls the loadAudio function <br />
		 *  with the resulting stream.
		 * @param file the WAV file to be read
		 * @return a ByteArray of raw audio data
		 */
//		public function loadAudioFromFile(file:File):ByteArray
//		{
//			if (!file.exists)
//				throw new Error("File or path specified in TSSWAVReader.read not valid!");
//			
//			var tStream:FileStream = new FileStream();
//			tStream.open(file, FileMode.READ);
//			
//			return loadAudio(tStream);
//		}
		
		/**
		 * loadAudio takes an IDataInput backed by an array of bytes from a WAV file, and it loads it to raw sound bytes
		 * readable by Flex's Sound object.
		 * @param stream the IDataInput type (FileStream, ByteArray, etc) with the WAV file data
		 * @return an array of raw audio floats
		 */
		public function loadAudio(stream:IDataInput):ByteArray
		{
			stream.endian = Endian.LITTLE_ENDIAN;
			parseHeader(stream);
			
			if (stream.readUTFBytes(4) !== "data")
				throw new Error("No data in WAV file!");
			
			var tSize:uint = stream.readUnsignedInt();
			
			var bitsize:Number = (Math.pow(2, _bitrate) / 2) - 1;
			
			while (stream.bytesAvailable > 0)
				_audioBytes.writeFloat((stream.readShort() * 1.0) / (bitsize as Number));
			
			
			return _audioBytes;
		}
		
		private function parseHeader(stream:IDataInput):void
		{
			if (stream.readUTFBytes(4) !== "RIFF")
				throw new Error("Invalid WAV file in TSSWAVReader");
			
			var tLength:uint = stream.readUnsignedInt();
			
			if (stream.readUTFBytes(4) !== "WAVE")
				throw new Error("Invalid WAV file in TSSWAVReader");
			
			if (stream.readUTFBytes(4) !== "fmt ")
				throw new Error("Invalid WAV file in TSSWAVReader");
			
			var headerChunk:uint = stream.readUnsignedInt();
			_compressionCode = stream.readShort();
			_channels = stream.readShort();
			_frequency = stream.readUnsignedInt();
			if (_frequency != 11025)
				throw new Error("TSSWAVReader does not support sample rates != 11025 for now.");
			
			stream.readUnsignedInt(); // Reading the byte rate. Not useful for now.
			stream.readShort(); // Block Alignment. Not needed.
			_bitrate = stream.readShort(); // bitrate AWWWW YEAH!!!! (Bitrate = sample size)
			if (_bitrate != 16)
				throw new Error("TSSWAVReader does not support bit rates != 16 for now.");
		}

		public function get audioBytes():ByteArray
		{
			return _audioBytes;
		}
	}
}