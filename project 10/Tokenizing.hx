  
//michal menaged and yekar reiner
//ids: 315473355 and 211729264
//group of nurit 150060.3.5780
 
import haxe.io.Eof;
import sys.io.File;
import sys.io.FileInput;
import sys.io.FileOutput;
import Std;
import String;
import StringTools;
 
//מחלקה: Tokenizing
class Tokenizing
{
  static var filePath:String;
  static var SymbolTabable=["<",">","{","}","*","~",";","(",")","[","]",".",",","+","-","/","&","|","="];
  static var KeyWordTabable=["let","if","constractor","var","method","function","class","field",
                                "static","int","char","boolean","void","true","false","null","this","do","else","while","return"];
  static var IdentifierTabable=[];
 
  static function main(){
               #if sys  //check if the file system is aviable
                
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
            if (new haxe.io.Path(path).ext=="jack") // if the type of the file is "vm
            {    
                translateFile(path);
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
    
  static function translateFile(filePath:String):Void
        {
          trace("welcome to translate-file function:)");
           var readFile=sys.io.File.read(filePath,false);  //open the file for reading
             
           var path= new haxe.io.Path(filePath);
           var XmlFile=path.dir+"/"+path.file+"T.xml"; 
           
           if (sys.FileSystem.exists(XmlFile))
               sys.FileSystem.deleteFile(XmlFile);
 
            var XmlFile = sys.io.File.append(XmlFile,false);  //open "XmlFile.xml" to write in the end of
            XmlFile.writeString("<tokens>\n") ;  
          
               var data =readFile.readAll().toString();
            
               var SplitByString=data.split(StringTools.htmlUnescape('&quot;'));
             
               for (item in 0...SplitByString.length)
               { 
                 if (!isEven(item)) XmlFile.writeString(Q5(SplitByString[item])); 
                 else
                {
                var SplitBySpace=SplitByString[item].split(" ");
                for (word in SplitBySpace)
                     XmlFile.writeString(trancelateWord(word));
                  } 
               }
             
               XmlFile.writeString("</tokens>") ;   //if cannot read anymore
               trace("End of file!"); 
              
               }
        

        static function isEven(num:Int):Bool {
          if(num%2==0) return true;
          return false;
        }
  static function MakeTag(table:String,word:String):String{
           return "<"+table+"> "+word+" </"+table+">\n";
        }
 
 static function trancelateWord(word:String):String{
      
       var correntChar="";
         correntChar= word.charAt(0);
        if (StringTools.isSpace(correntChar,0)) return trancelateWord(word.substr(1,word.length));
        if (StringTools.fastCodeAt(correntChar,0)>=97 &&StringTools.fastCodeAt(correntChar,0)<=122 ) //while its a little letter- code from 97 to 122
        
          return Q1(word,0); //keywords|ids
        
        if ((StringTools.fastCodeAt(correntChar,0)>=65 &&StringTools.fastCodeAt(correntChar,0)<=90 )||StringTools.fastCodeAt(correntChar,0)=="_".code )    //capital  from 65 to 90
        {
          return Q2(word); //defently ids
        }
        if (StringTools.fastCodeAt(correntChar,0)>=48 && StringTools.fastCodeAt(correntChar,0)<=57 )    //numbers- from 48 to 57
        {
          return Q3(word); //numbers
        }
    
       return Q4(word);
  }
 
static function Q1(word:String,i:Int):String{
    var string1 = "", string2 = "";
            while(i<word.length){
              if (StringTools.fastCodeAt(word,i)==null) break;
              var filteredList = [for (v in SymbolTabable ) if (v == word.charAt(i)) v];
              if (filteredList.length!=[].length) //its cat by symbol
                  {
                     var filteredList = [for (v in KeyWordTabable ) if (v == word.substr(0,i)) v];
                     if (filteredList.length==[].length) //its not key word
                              string1= Q2(word.substr(0,i)); //its of corse id
                             
                    else string1 = MakeTag("keyword",word.substr(0,i));
                    string2 = Q4(word.charAt(i));
                    return string1 + string2 + trancelateWord(word.substr(i+1,word.length));
                    }
 
              if (!(StringTools.fastCodeAt(word,i)>=97 && StringTools.fastCodeAt(word,i)<=122 )) //if its not a little letter
                return Q2(word);
              i=i+1;
            }
 
          var filteredList = [for (v in KeyWordTabable ) if (v == word) v];
          if(filteredList.length==[].length) //its not key word
            return Q2(word); //its of corse id
          return MakeTag("keyword",word);
      }
 
static function Q2(word:String):String{  
     
      var i:Int = 0;
     
      var string1 = "", string2 = "";
      while(i<word.length)
        {
            if (StringTools.fastCodeAt(word,i)==null) break;
            var filteredList = [for (v in SymbolTabable ) if (v == word.charAt(i)) v];
            if(filteredList.length!=[].length)
                {
                        var newWord = word.substr(0, i);
                        var filteredList1 = [for (v in IdentifierTabable ) if (v == newWord) v];
                        if(filteredList1.length==[].length) //its not familiar id
                            IdentifierTabable.insert(IdentifierTabable.length-1,newWord); //insert it to the end
                        
                        string1 = MakeTag("identifier",newWord);
                    
                    string2 = Q4(word.charAt(i));
                    return string1 + string2 + trancelateWord(word.substr(i+1,word.length));
                }
 
            i = i + 1;
        }
       var filteredList = [for (v in IdentifierTabable ) if (v == word) v];
        if(filteredList.length==[].length) //its not familiar id
           IdentifierTabable.insert(IdentifierTabable.length-1,word); //insert it to the end
        return MakeTag("identifier",word);    
}
static function Q3(word:String):String{
 
    var i:Int = 1;
      var string1 = "", string2 = "";
      while(i<word.length)
        {
            if (StringTools.fastCodeAt(word,i)==null) break;
            var filteredList = [for (v in SymbolTabable ) if (v == word.charAt(i)) v];
            if(filteredList.length!=[].length)
                {
                    var newWord = word.substr(0, i);
                    string1 = MakeTag("integerConstant"," "+newWord+" ");
                    
                    string2 = Q4(word.charAt(i));
                    return string1 + string2 + trancelateWord(word.substr(i+1,word.length));
                }
 
            i = i + 1;
            
        }
    return MakeTag("intigerConstant"," "+word+" ");
}
static function Q4(word:String):String{
   var filteredList = [for (v in SymbolTabable ) if (v == word.charAt(0)) v];
        if(filteredList.length==[].length) //its not familiar id
            return "" ; //syntaxt err
    return MakeTag("symbol",StringTools.htmlEscape(word.charAt(0),true))+trancelateWord(word.substr(1,word.length));    //+Q4(word, i++);
}
static function Q5(word:String):String
{return MakeTag("stringConstant",word);}
}
 
 

