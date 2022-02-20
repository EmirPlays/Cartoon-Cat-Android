#if android
import extension.webview.WebView;
import android.*;
#end
import flixel.FlxBasic;
import flixel.FlxG;

class FlxVideo extends FlxBasic {
	public var finishCallback:Void->Void = null;

	public function new(name:String){
		super();

		#if android
		WebView.onClose=onClose;
		WebView.onURLChanging=onURLChanging;
		WebView.open(AndroidTools.getFileUrl(name), null, ['http://exitme(.*)']);
                #else//if is not android the game will continue anyway :3
                if (finishCallback != null){
			finishCallback();
		}
                #end
	}

	#if android
	function onClose() {
		if (finishCallback != null){
			finishCallback();
		}
	 }

	function onURLChanging(url:String){
		if (url == 'http://exitme/') 
                        onClose();
	}
	#end
}
