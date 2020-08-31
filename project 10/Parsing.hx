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
import Tokenizing;
import sys.io.FileSeek;
 
 
class Parsing //get tokenise file and made pasered file
{
    static var OpTable = [ "+" , "-" , "*" , "/" , "&" , "|" , "<" , ">" , "=" , "&lt;" , "&gt;" , "&quet;" , "&amp;"];
    static var StatementTable = [ "let" , "if" , "while" , "do" , "return" ];
    static var index:Int = -1;
    static var statementFlag = false;
 
 static var TokensFile:String="ExpressionLessSquare/MainT.xml";      //xml file
    
 static var array:Array<String> =[];
 
 static var readFile:sys.io.FileInput;
 static var ParseFile:sys.io.FileOutput;
 
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
                if (path.charAt(path.length-5)=="T")  
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

 static function translateFile(TokensFile:String){
    readFile=sys.io.File.read(TokensFile,false);  //open the file for reading
    var path= new haxe.io.Path(TokensFile);
    var ParseFileString=TokensFile.substr(0,TokensFile.length-5)+".xml"; //get off the T
    trace(ParseFileString);
    if (sys.FileSystem.exists(ParseFileString))
        sys.FileSystem.deleteFile(ParseFileString);
    
    var EndOfFile = false;
 
    while(!EndOfFile)    
        {
         try {
             var line = readFile.readLine();
             if (line != "</tokens>")
                array.push (line);    //line is the current read line 
                           
         }
         
        catch(e:haxe.io.Eof){                                     //if cannot read anymore
            trace("End of file!"); 
            EndOfFile=true;                                       
            }
         }
 
 
    ParseFile = sys.io.File.append(ParseFileString,false);  //open "ParseFile.xml" to write in the end of
    ParseFile.writeString("");
    GetNext();
    ParseClass();
 }
     static function GetNext():String{ //read complite line
        index = index +1;
        if (index == array.length)
            return "muhaha";
        return array[index] + "\n";
    }
    static function ParseClass():Void {
        /*
        var root = Xml.parse('<class>').firstElement();
        // for loop
        var child1:Xml = Xml.createdElement('classVarDec');
        root.addChild(child1);
        var chils2:Xml = Xml.createdElement('subDec');
        root.addChild(child2);
        //getNext
*/
        ParseFile.writeString("<class>\n");
        for (i in 0...3) {
            ParseFile.writeString(GetNext());// "class", className, { // 
        }
 
        var v_s:String = array[index + 1];
        while (StringTools.contains(v_s , "static") || StringTools.contains(v_s , "field")) {
            index = index + 1;
            ParseFile.writeString("<classVarDec>\n");
            ParseFile.writeString(v_s + "\n");
            ParseClassVarDec();
            v_s = array[index + 1];
        }
 
        while (StringTools.contains(v_s ,"constructor") || StringTools.contains(v_s,"function") || StringTools.contains(v_s,"method")) {
            index = index + 1;
            ParseFile.writeString("<subroutineDec>\n");
            ParseFile.writeString(v_s + "\n");
            ParseSubDec();
            v_s = array[index + 1];
        }
 
        ParseFile.writeString(GetNext()); // } //
        ParseFile.writeString("</class>\n"); //enf of file
    }
 
    static function ParseClassVarDec():Void {
                for (i in 0...2)
                    ParseFile.writeString(GetNext()); // "static|field", type, Name
                var tmp:String = array[index + 1];
                while(StringTools.contains(tmp, ","))
                    {
                        index = index + 1;
                        ParseFile.writeString(tmp + "\n"); // "," //
                        ParseFile.writeString(GetNext()); //  nextID  //
                        tmp = array[index + 1];
                    }
            
        ParseFile.writeString(GetNext()); // ";" 
        ParseFile.writeString("</classVarDec>\n");
    }
 
    static function ParseSubDec():Void {
        for (i in 0...3)
            {
                ParseFile.writeString(GetNext());// "c|f|m", type, Name , "(" //
            }
            
        ParseParameterList();
        ParseFile.writeString(GetNext()); // ")" // 
        ParseSubBody();
        ParseFile.writeString("</subroutineDec>\n");
    }
 
    static function ParseParameterList():Void {
        ParseFile.writeString("<parameterList>\n");
        var tmp:String  = array[index + 1];
        while (StringTools.contains(tmp, ")") == false)
            {
                index = index + 1;
                ParseFile.writeString(tmp + "\n");
                tmp  = array[index + 1];
            }
        ParseFile.writeString("</parameterList>\n");
    }
 
    static function ParseSubBody():Void {
        ParseFile.writeString("<subroutineBody>\n");
        ParseFile.writeString(GetNext()); // "{" //
        var tmp:String = array[index + 1];
        while (StringTools.contains(tmp, "var")) {
            index = index + 1;
            ParseFile.writeString("<varDec>\n");
            ParseFile.writeString(tmp + "\n"); // var //
            ParseVarDec();
            tmp = array[index + 1];
        }
        if (tmp != "}")
            ParseStatements();
 
        ParseFile.writeString(GetNext()); // "}" // 
        
        ParseFile.writeString("</subroutineBody>\n");
                
    }
 
    static function ParseVarDec():Void { // only if variables are sent
        for (i in 0...2) {
            ParseFile.writeString(GetNext());// "var", type, varName //
        }
            
        var tmp:String = array[index + 1];
        while (StringTools.contains(tmp, ","))
            {
                for (i in 0...2) {
                    ParseFile.writeString(GetNext());// "," , varName //
                }
                    
                tmp = array[index + 1];
            }
        ParseFile.writeString(GetNext()); // ";" //
        ParseFile.writeString("</varDec>\n");
    }
  
    static function ParseStatements():Void {
        ParseFile.writeString("<statements>\n");
        while (! StringTools.contains(GetNext(), "}")) {
                ParseStatement();  
        }
        index = index -1;
        ParseFile.writeString("</statements>\n");
    }
 
    static function ParseStatement():Void {
        index = index -1;
        if (StringTools.contains(GetNext() , "let"))
            ParseLetStatement();
        else {
            index = index-1;
            if (StringTools.contains(GetNext() , "do"))
                ParseDoStatement();
            else {
                index = index-1;
                if (StringTools.contains(GetNext() , "if"))
                    ParseIfStatement();
                else {
                    index = index-1;
                    if (StringTools.contains(GetNext() , "while"))
                        ParseWhileStatement();
                    else {
                        index = index-1;
                        if (StringTools.contains(GetNext() , "return"))
                            ParseReturnStatement();
                        else {trace(":)"); trace(index-1); trace(array[index-1]);} 
                    }
                }
            }
        }            
    }

    static function ParseLetStatement():Void {
        trace("let");
        ParseFile.writeString("<letStatement>\n");
        index = index -1;
        ParseFile.writeString(GetNext()); // let //
        ParseFile.writeString(GetNext()); // varName //
        var tmp:String = array[index + 1]; // = OR [ //
        if (StringTools.contains (tmp,'['))
            {
                ParseFile.writeString(GetNext()); // "[" //
                ParseExpression();
                ParseFile.writeString(GetNext()); // "]" //
                tmp = array[index + 1]; // = //
            }
        ParseFile.writeString(GetNext()); // "=" //
        ParseExpression();
        ParseFile.writeString(array[index + 1] + "\n"); // ";" //
        index = index + 1;
        ParseFile.writeString("</letStatement>\n");
    }
 
    static function ParseIfStatement():Void {
        trace("if");
        ParseFile.writeString("<ifStatement>\n");
        index = index -1;
        ParseFile.writeString(GetNext()); // if //
        ParseFile.writeString(GetNext()); // "(" //
        ParseExpression();
        for (i in 0...2)
            ParseFile.writeString(GetNext()); // ")", "{" //
        var tmp:String = array[index + 1];
        if (tmp != "}") 
            ParseStatements();
        
        ParseFile.writeString(GetNext()); // "}" //
 
        tmp = array[index+1];
        if (StringTools.contains(tmp, "else"))
            {
                index = index + 1;
                ParseFile.writeString(tmp + "\n"); // else //
                ParseFile.writeString(GetNext()); // "{" //
                var elseStatement:String = array[index + 1];
                if (elseStatement != "}")
                    ParseStatements();
                ParseFile.writeString(GetNext()); // "}" //
            }
        ParseFile.writeString("</ifStatement>\n");
    }
 
    static function ParseWhileStatement():Void {
        trace("while");
        ParseFile.writeString("<WhileStatement>\n");
        index = index -1;
        ParseFile.writeString(GetNext()); // while //
        ParseFile.writeString(GetNext()); // "(" //
        ParseExpression();
        for (i in 0...2)
            ParseFile.writeString(GetNext()); // ")", "{" //
        var tmp:String = array[index + 1];
        if (tmp != "}")
            ParseStatements();
        
        ParseFile.writeString(GetNext()); // "}" //
        ParseFile.writeString("</WhileStatement>\n");
    }
 
    static function ParseDoStatement():Void {
        trace("do");
        ParseFile.writeString("<doStatement>\n");
        index = index -1;
        ParseFile.writeString(GetNext()); // do //
        ParseFile.writeString(GetNext());
        ParseSubCall();
        ParseFile.writeString(GetNext()); // ; //
        ParseFile.writeString("</doStatement>\n");
    }
 
    static function ParseReturnStatement():Void {
        trace("return");
        ParseFile.writeString("<returnStatement>\n");
        index = index -1;
        ParseFile.writeString(GetNext()); // return //
        var tmp:String = array[index + 1];
        if(!StringTools.contains(tmp, ";"))
                ParseExpression();
        ParseFile.writeString(GetNext()); // ; //
        ParseFile.writeString("</returnStatement>\n");
    }
 
    static function ParseExpression():Void {
        ParseFile.writeString("<expression>\n");
        ParseTerm();
        var tmp:String = array[index + 1];
        var op:String = tmp.split(" ")[1];
        //trace(op);
        var check = OpTable.indexOf(op);
        //trace(check);
       // var op = [for (o in OpTable) if (StringTools.contains(tmp, o)) o];
        while (check != (-1)) {
            ParseFile.writeString(GetNext()); // op //
            ParseTerm();
            tmp = array[index + 1];
            op = tmp.split(" ")[1];
            //trace(op);
            check = OpTable.indexOf(op);
            //trace(check);
        }
        ParseFile.writeString("</expression>\n");
    }
    
    static function ParseTerm():Void {
        ParseFile.writeString("<term>\n");
        var next = array[index + 1];
        if (StringTools.contains(next, "-") || StringTools.contains(next, "~")) {
                ParseFile.writeString(GetNext()); // unary op //
                ParseTerm();
        }
        else if (StringTools.contains(next, "(")) {
            ParseFile.writeString(GetNext()); // "(" //
                ParseExpression();
            ParseFile.writeString(GetNext()); // ")" //
        }
        else {
            ParseFile.writeString(GetNext());
            HelpFunction();
        }
        ParseFile.writeString("</term>\n");
    }

    static function HelpFunction():Void {
        var next = array[index + 1];
        if (StringTools.contains(next, "(") || StringTools.contains(next, "."))
            ParseSubCall();
        else if(StringTools.contains(next, "["))
        {
            ParseFile.writeString(GetNext()); // "[" //
            ParseExpression();
            ParseFile.writeString(GetNext()); // "]" //
        }
    }

    static function ParseSubCall():Void {
        var tmp = array[index + 1];
        if (StringTools.contains(tmp , "(")) {
                ParseFile.writeString(GetNext()); // ( //
                ParseExpressionList();
                ParseFile.writeString(GetNext()); // ) //
        }
        else { // tmp = "."
            for (i in 0...3)
                ParseFile.writeString(GetNext());
            ParseExpressionList();
            ParseFile.writeString(GetNext());
        }
 
    }
 
    static function ParseExpressionList():Void {
        ParseFile.writeString("<expressionList>\n");
        if (! StringTools.contains (array[index+1] , ")")) {
            ParseExpression();
        var tmp:String = array[index+1];
        while (! StringTools.contains (tmp , ")"))
            {
                //index = index +1;
                ParseFile.writeString(GetNext()); // "," //
                ParseExpression();
                tmp = array[index+1];
            }
        }
        ParseFile.writeString("</expressionList>\n");
    }
}
 

