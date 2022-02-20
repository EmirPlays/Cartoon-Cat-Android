package;

#if android
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import openfl.Lib;
import sys.FileSystem;
import sys.io.File;
import haxe.CallStack.StackItem;
import haxe.CallStack;
import haxe.io.Path;
import android.*;
#end

class SUtil
{
    #if android
    private static var aDir:String = null;
    private static var sPath:String = AndroidTools.getExternalStorageDirectory();  
    private static var grantedPermsList:Array<Permissions> = AndroidTools.getGrantedPermissions();  
    #end

    static public function getPath():String
    {
    	#if android
        if (aDir != null && aDir.length > 0) 
        {
            return aDir;
        } 
        else 
        {
            aDir = sPath + "/" + "." + Application.current.meta.get("file") + "/files/";         
        }
        return aDir;
        #else
        return "";
        #end
    }

    static public function doTheCheck()
    {
        #if android
        if (!grantedPermsList.contains(Permissions.READ_EXTERNAL_STORAGE) || !grantedPermsList.contains(Permissions.WRITE_EXTERNAL_STORAGE)) {
            if (AndroidTools.getSDKversion() > 23 || AndroidTools.getSDKversion() == 23) {
                    AndroidTools.requestPermissions([Permissions.READ_EXTERNAL_STORAGE, Permissions.WRITE_EXTERNAL_STORAGE]);
            }  
        }

        if (!grantedPermsList.contains(Permissions.READ_EXTERNAL_STORAGE) || !grantedPermsList.contains(Permissions.WRITE_EXTERNAL_STORAGE)) {
            if (AndroidTools.getSDKversion() > 23 || AndroidTools.getSDKversion() == 23) {
		        SUtil.applicationAlert("Permissions", "If you accepted the permisions for storage, good, you can continue, if you not the game can't run without storage permissions please grant them in app settings" + "\n" + "Press Ok To Close The App");
            } else {
                SUtil.applicationAlert("Permissions", "The Game can't run without storage permissions please grant them in app settings" + "\n" + "Press Ok To Close The App");
            }
        }

        if (!FileSystem.exists(sPath + "/" + "." + Application.current.meta.get("file"))){
            FileSystem.createDirectory(sPath + "/" + "." + Application.current.meta.get("file"));
        }

        if (!FileSystem.exists(sPath + "/" + "." + Application.current.meta.get("file") + "/files")){
            FileSystem.createDirectory(sPath + "/" + "." + Application.current.meta.get("file") + "/files");
        }

        if (!FileSystem.exists(SUtil.getPath() + "log")){
            FileSystem.createDirectory(SUtil.getPath() + "log");
        }

        if (!FileSystem.exists(SUtil.getPath() + "assets")){
		    SUtil.applicationAlert("Instructions:", "Try copying assets/assets from apk to your internal storage app directory " + "( here " + SUtil.getPath() + " )" + "if you hadn't have Zarhiver Downloaded, download it and enable the show hidden files option to have the folder visible" + "\n" + "Press Ok To Close The App");
            Sys.exit(0);
        }
        
        if (!FileSystem.exists(SUtil.getPath() + "mods")){
            SUtil.applicationAlert("Instructions:", "Try copying assets/mods from apk to your internal storage app directory " + "( here " + SUtil.getPath() + " )" + "if you hadn't have Zarhiver Downloaded, download it and enable the show hidden files option to have the folder visible" + "\n" + "Press Ok To Close The App");
            Sys.exit(1);
        }
        #end
    }

    //Thanks Forever Engine
    static public function gameCrashCheck(){
    	Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
    }
     
    static public function onCrash(e:UncaughtErrorEvent):Void {
        var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var errMsg:String = "";
		var dateNow:String = Date.now().toString();
		var path:String = "log/" + "crash-" + "(" + dateNow + ")" + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

        errMsg += e.error;

		File.saveContent(SUtil.getPath() + path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));
		Sys.println("Making a simple alert ...");
		
		SUtil.applicationAlert("Uncaught Error:", errMsg);

		Sys.exit(0);
	}
	
	public static function applicationAlert(title:String, description:String){
        Application.current.window.alert(description, title);
    }
}
