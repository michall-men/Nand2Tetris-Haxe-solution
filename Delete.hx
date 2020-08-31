 class Delete{
     //one method, delete all the xml files;
 static function main(){
    /*    trace("Enter path of a directory, please");
        var TokensFile:String = Sys.stdin().readLine();*/
      
      #if sys
        recursiveLoop();
      #end
  }
       static function recursiveLoop(nameOfDirectory:String = "./"):Void
   { 
    // go over the directory. start with the directory "nameOfDirectory"
    if (sys.FileSystem.exists(nameOfDirectory)) // check if the directory is exists
     {  
      for (file in sys.FileSystem.readDirectory(nameOfDirectory)) // each file in the directory
       {
        var path = haxe.io.Path.join([nameOfDirectory, file]); //make full-path to the file. "path" is the locate of the corrent file
        if (!sys.FileSystem.isDirectory(path)) // check if the path is a directory or a file. if file:
        {    
            if (new haxe.io.Path(path).ext=="xml") // if the type of the file is "vm
            {    
                    sys.FileSystem.deleteFile(path);
               // break;
            }
          } 
        else {
          var directory = haxe.io.Path.addTrailingSlash(path);   //if the corrent file is a directory
          recursiveLoop(directory);                            
        }
      } 
    } 
    else 
      trace('"$nameOfDirectory" does not exists');
    }     
 }