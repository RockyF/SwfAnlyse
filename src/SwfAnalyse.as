package {

import flash.display.Sprite;
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;

public class SwfAnalyse extends Sprite {
	public function SwfAnalyse() {
		var loader:URLLoader = new URLLoader();
		loader.dataFormat = URLLoaderDataFormat.BINARY;
		loader.addEventListener(Event.COMPLETE, function(event:Event):void{
			doAnalyse(loader.data);
		});
		loader.load(new URLRequest("swf/test.swf"));
	}

	private function doAnalyse(bytes:ByteArray):void{
		var compressMode:int = bytes.readByte();
		trace("compress mode:", String.fromCharCode(compressMode));
		var sign0:String = bytes.readUTFBytes(2);
		trace("sign0:", sign0);
		var version:int = bytes.readByte();
		trace("version:", version);
		var length:uint = bytes.readUnsignedInt();
		trace("length:", length);

		var restBytes:ByteArray = new ByteArray();
		bytes.readBytes(restBytes);

		switch(compressMode){
			case 0x46:  //F Mode non-compressed

				break;
			case 0x43:  //C Mode compressed
				restBytes.uncompress();
				break;
		}

		var b0:int = restBytes.readByte();
		var len:uint = b0 >> 3;
		var restLength:uint = 3;
		trace("rect length:", len);
		var bits:uint = b0 << restLength;
		for(var i:int = 0; i < 4; i++){
			var needBitCount:int = len - restLength;
			var needByteCount:int = Math.ceil(needBitCount / 2);
			for(var j:int = 0; j < needByteCount; j ++){
				b0 = restBytes.readByte();
				bits = bits << 8;
				bits += b0 >> 8;
			}
			if(restLength < 8){
				b0 = restBytes.readByte();
				restLength += 8;
			}
		}
	}
}
}