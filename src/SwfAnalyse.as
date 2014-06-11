package {

import flash.display.Sprite;
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.utils.Endian;

public class SwfAnalyse extends Sprite {
	public function SwfAnalyse() {
		var loader:URLLoader = new URLLoader();
		loader.dataFormat = URLLoaderDataFormat.BINARY;
		loader.addEventListener(Event.COMPLETE, function(event:Event):void{
			//doAnalyse(loader.data);
			//analyseSWF(loader.data);
			test2(loader.data);
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
		var needByteCount:int = Math.ceil((len * 4 - restLength) / 8);
		restBytes.readUTFBytes(needByteCount);

		var frameRate:uint = restBytes.readUnsignedShort();
		trace("frame rate:", frameRate);

		var frameCount:uint = restBytes.readUnsignedShort();
		trace("frameCount:", frameCount);

		var id:int;
		var head:int;
		var size:int;
		var i:int;
		var name:String;
		var lastPosition:int;
		var num:int;
		var type:int;
		while(bytes.bytesAvailable>0)//字节数组剩余可读数据长度大于2个字节
		{
			head = bytes.readUnsignedShort();//读取tag类型
			size = head&63;//判断低6位的值是否是63，如果是，这个tag的长度就是下面的32位整数，否则就是head的低6位
			if (size == 63)size=bytes.readInt();
			type = head>>6;
			if(type != 76)
			{
				bytes.position += size;
			}
			else
			{
				num = bytes.readShort();
				for(i=0; i<num; i++)
				{
					id = bytes.readShort();//读取tag ID
					lastPosition = bytes.position;
					while(bytes.readByte() != 0);//读到字符串的结束标志
					len = bytes.position - lastPosition;
					bytes.position = lastPosition;
					name = bytes.readUTFBytes(len).toString();
					trace("连接名："+name);
				}
			}
		}
	}

	private function analyseSWF(bytes:ByteArray):void
	{
		var id:int;
		var head:int;
		var size:int;
		var i:int;
		var name:String;
		var len:int;
		var lastPosition:int;
		var num:int;
		var type:int;
		bytes.endian = Endian.LITTLE_ENDIAN;
		bytes.position = Math.ceil(((bytes[8]>>1)+5)/8)+12;
		while(bytes.bytesAvailable>0)//字节数组剩余可读数据长度大于2个字节
		{
			head = bytes.readUnsignedShort();//读取tag类型
			size = head&63;//判断低6位的值是否是63，如果是，这个tag的长度就是下面的32位整数，否则就是head的低6位
			if (size == 63)size=bytes.readInt();
			type = head>>6;
			if(type != 76)
			{
				bytes.position += size;
			}
			else
			{
				num = bytes.readShort();
				for(i=0; i<num; i++)
				{
					id = bytes.readShort();//读取tag ID
					lastPosition = bytes.position;
					while(bytes.readByte() != 0);//读到字符串的结束标志
					len = bytes.position - lastPosition;
					bytes.position = lastPosition;
					name = bytes.readUTFBytes(len).toString();
					trace("连接名："+name);
				}
			}
		}
	}

	private function test2(bytes:ByteArray):void {
		bytes.endian=Endian.LITTLE_ENDIAN;
		bytes.writeBytes(bytes,8);
		bytes.uncompress();
		bytes.position=Math.ceil(((bytes[0]>>>3)*4+5)/8)+4;
		while(bytes.bytesAvailable>2){
			var head:int=bytes.readUnsignedShort();
			var size:int=head&63;
			if (size==63)size=bytes.readInt();
			if (head>>6!=76)bytes.position+=size;
			else {
				head=bytes.readShort();
				for(var i:int=0;i<head;i++){
					bytes.readShort();
					size=bytes.position;
					while(bytes.readByte()!=0);
					size=bytes.position-(bytes.position=size);
					trace(bytes.readUTFBytes(size));
				}
			}
		}
	}
}
}