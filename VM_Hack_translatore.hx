
//michal menaged and yekar reiner
//ids: 315473355 and 211729264
//group of nurit 150060.3.5780
//VM_Hack_translatore
 
import haxe.io.Eof;
import sys.io.File;
import sys.io.FileInput;
import sys.io.FileOutput;
import Std;

  class VM_Hack_translatore 
{
    static var filePath:String;
    static var filename:String; 
    static var CallCounter=0;
    static function main()
  {
    #if sys  //check if the file system is aviable
      recursiveLoop(); //"./FunctionCalls/FibonacciElement"
    #end
}

  static function recursiveLoop(nameOfDirectory:String = "./"):Void { 
     
  // go over the directory. start with the directory "nameOfDirectory"
  if (sys.FileSystem.exists(nameOfDirectory)) // check if the directory is exists
   { 
    for (file in sys.FileSystem.readDirectory(nameOfDirectory)) // each file in the directory
     {
      var path = haxe.io.Path.join([nameOfDirectory, file]); //make full-path to the file. "path" is the locate of the corrent file
      if (!sys.FileSystem.isDirectory(path)) // check if the path is a directory or a file. if file:
      {    
          if (new haxe.io.Path(path).ext=="vm") // if the type of the file is "vm
          {   
              trancelateDir(nameOfDirectory);
              break;
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
  static function trancelateDir(directory: String){

         var dirArr= directory.split("/"); 
         var fileAsm= directory+dirArr[dirArr.length-2]+".asm"; //creat new file- file.asm
           //הפקודות הבאות נועדו לוודא שהתרגום לא ישורשר בסוף התרגום מההרצה הקודמת. בכל הרצה יפתח קובץ מחדש
        if (sys.FileSystem.exists(fileAsm))
             sys.FileSystem.deleteFile(fileAsm);

        var fileAsm = sys.io.File.append(fileAsm,false);  //open "filename.asm" to write in the end of
       
        fileAsm.writeString(Bootstapping());
        for (file in sys.FileSystem.readDirectory(directory)) // each file in the directory
     {
      var path = haxe.io.Path.join([directory, file]); //make full-path to the file. "path" is the locate of the corrent file
      if (!sys.FileSystem.isDirectory(path)) // check if the path is a directory or a file. if file:
      {    
          if (new haxe.io.Path(path).ext=="vm") // if the type of the file is "vm
          {   
              filePath= path; 
              filename=new haxe.io.Path(filePath).file;
              trancelateFile(fileAsm);
           }
        } 
       }

        fileAsm.close();
  }
  static function trancelateFile(fileAsm:sys.io.FileOutput):Void{
        var readFile=sys.io.File.read(filePath,false);  //open the file for reading
        var line:String;  
        var EndOfFile=false;
          
            while(!EndOfFile)    
           {
            try {
            line = readFile.readLine();    //line is the current read line 
            fileAsm.writeString(trancelateLine(line));                    
            }
            
           catch(e:haxe.io.Eof){                                     //if cannot read anymore
               trace("End of file!"); 
               EndOfFile=true;                                       //we got the end
               }
            }
   }
 
static function trancelateLine(line:String=""):String{   
     var command=line.split(" ");   //part the line to words. return arrey of words
      switch command[0] {
         case "push": return Push(command);
         case "pop": return Pop(command);
         case "add": return Add();
         case "sub": return Sub();
         case "neg": return Neg();
         case "gt": return Gt();
         case "lt": return Lt();
         case "and": return And();
         case "eq": return Eq();
         case "or": return Or();
         case "not": return Not();
         /// exerices 2
         case "label": return Label(filename+"."+command[1]);
         case "goto": return GotoL(filename+"."+command[1]);
         case "if-goto": return IfGotoL(filename+"."+command[1]);
         case "function": return Function(command[1],command[2]);
         case "return": return Return();
         case "call": return Call(command[1],command[2]);

        default: return "";
         }
        }
static function Bootstapping():String{// Initialize the SP to 256. the vm code: sp=256;
    return "@256\nD=A\n@SP\nM=D\n"+ //sp
            "@300\nD=A\n@1\nM=D\n"+ //LCL
            "@400\nD=A\n@2\nM=D\n"+ //Argument
            "@3000\nD=A\n@3\nM=D\n"+ //THIS
            "@3010\nD=A\n@4\nM=D\n"+ //THAT 
             Call("Sys.init","0") ;  
}
 static function LoadSegment(segment:String="SP"):String{
     var asmSegment; //=segment; //.toUpperCase();
    switch (segment){
        case "local": asmSegment="LCL";
        case "argument": asmSegment="ARG";
        default: asmSegment=segment;
    }
    return "@"+asmSegment+"\n";
}
 // #region ex 1
static function Push(command:Array<String>):String{
    var segment=command[1];
    var index=command[2];
    if(segment == "pointer")
        return PointerPush(index);
    if(segment == "static")
        {
            segment = filename+"."+index;
        }
    if(segment == "constant") 
        return "@"+index+"\nD=A\n@SP\nA=M\nM=D\n@SP\nM=M+1\n";
    if(segment == "temp") //push the item (i+5) from temp to the in the Stack
        {
           return "@"+Std.parseInt(index)+5+"\nD=M\n"+LoadSegment()+"A=M\nM=D\n"+LoadSegment()+"M=M+1"+"\n";
          
        }
    return "@"+index+"\nD=A\n"+LoadSegment(segment)+"A=M+D\nD=M\n"+LoadSegment()+"A=M\nM=D\n"+LoadSegment()+"M=M+1"+"\n";
}
static function Pop(command:Array<String>):String{
    var segment=command[1];
    var index=command[2];
    
    if(segment == "pointer")
        return PointerPop(index);
     if(segment == "static")
        {
            segment = filename+"."+index;
        }
     if(segment == "temp") //pop the last element from the stack to temp (i+5)
        {
       
          return LoadSegment() + "AM=M-1\nD=M\n@"+(Std.parseInt(index)+5)+"\nM=D\n";
        }
    var str = LoadSegment() + "A=M-1\nD=M\n" + LoadSegment(segment) + "A=M\n";
    for(i in 0...Std.parseInt(index)) {
        str += "A=A+1\n"; 
    }
    return str + "M=D\n" + LoadSegment() + "M=M-1\n";
}
static function Add():String{
    return LoadSegment()+"A=M-1\nD=M\nA=A-1\nM=D+M\n"+LoadSegment()+"M=M-1"+"\n";
}
static function Sub():String{
    return LoadSegment()+"A=M-1\nD=M\nA=A-1\nM=M-D\n"+LoadSegment()+"M=M-1"+"\n";
}
static function Neg():String{
    return LoadSegment()+"A=M-1\nM=-M\n"+LoadSegment();
} 
static function Gt():String{
    return LoadSegment()+"A=M-1\nD=M\nA=A-1\nD=M-D\nM=0\n@END\nD;JLE\nM=1\n(END)\n"+LoadSegment()+"M=M-1"+"\n";
}
static function Lt():String{
    return LoadSegment()+"A=M-1\nD=M\nA=A-1\nD=M-D\nM=0\n@END\nD;JGE\nM=1\n(END)\n"+LoadSegment()+"M=M-1"+"\n";
}
static function And():String{
    return LoadSegment()+"A=M-1\nD=M\nA=A-1\nD=M+D\nD=D-1\nM=0\n@END\nD;JLE\nM=1\n(END)\n"+LoadSegment()+"M=M-1"+"\n";
}
static function Eq():String{
    return LoadSegment()+"A=M-1\nD=M\nA=A-1\nD=D-M\n"+LoadSegment("IF_TRUE")+"D;JEC\nD=0\n"+LoadSegment()+"A=M-1\nA=A-1\nM=D"+LoadSegment("IF_FALSE")+"0;JMP\n(IF_TRUE)\nD=-1\n"+LoadSegment()+"A=M-1\nA=A-1\nM=D\n(IF_FALSE)\n"+LoadSegment()+"M=M-1\n";
}
static function Or():String{
    return LoadSegment()+"A=M-1\nD=M\nA=A-1\nD=M+D\nM=0\n@END\nD;JNE\nM=1\n(END)\n"+LoadSegment()+"M=M-1"+"\n";
}
static function Not():String{
    return LoadSegment()+"A=M-1\nD=M\nM=0\n@END\nD;JEQ\nM=1\n(END)\n"+LoadSegment()+"M=M-1"+"\n";
}
// #endregion 

/// exerices 2

static function Label(label:String):String{
  return "("+label+")\n";
}
static function GotoL(label:String):String{
   // var label1=filename+"."+label;
    return "@"+label+"\n"+"0;JMP\n"; //go to label
}
static function IfGotoL(label:String):String{
    // var label1=filename+"."+label;
    return "@SP\nM=M-1\nA=M\nD=M\n@"+label+"\nD;JNE\n"; //go to label if top!=0
}
static function Function(g:String , k:String):String{ //g=name, k=local vars
   var s=Label(g);
   for( i in 1...Std.parseInt(k))
   { s+= "@SP\nA=M\nM=0\n@SP\nM=M+1\n"; }
   return s;
   /*
    return Label(g)+"@"+k+"\nD=A\n@"+g+".END\nD;JEQ\n"+Label(g+".LOOP")+
    "@SP\nA=M\nM=0\n@SP\nM=M+1\n@"+g+".LOOP\nD=D-1;JNE\n"+Label(g+".END");*/
}
static function Call(g:String , n:String):String{ // g=name , n=arguments
    var tmpN =Std.parseInt(n)+5; 
    CallCounter++;
    return LoadSegment(g+".ReturnAddress"+"_"+CallCounter)+"D=A\n@SP\nA=M\nM=D\n@SP\nM=M+1\n" +
     PushSegment("LCL") + PushSegment("ARG") + PushSegment("THIS") + PushSegment("THAT") + 
     "@SP\nD=M\n@" +tmpN+ "\nD=D-A\n@ARG\nM=D\n@SP\nD=M\n@LCL\nM=D\n" + Label(g+".ReturnAddress"+"_"+CallCounter);
}
     /*GotoL(g) +*/ 
static function Return(){
    return LoadSegment("LCL") + "D=M\n"+LoadSegment("FRAME")+"@5\nA=D-A\nD=M\n@13\nM=D\n" +Pop(["pop","ARG","0"]) + 
    "@ARG\nD=M\n@SP\nM=D+1\n" +
    HelpFrame("THAT") + HelpFrame("THIS") + HelpFrame("ARG") + HelpFrame("LCL") +
    "@13\nA=M\n0;JMP\n";
}
/// help functions
 static function PushSegment(segment:String):String{
    return LoadSegment(segment)+"D=M\n"+LoadSegment()+"A=M\nM=D\n@SP\nM=M+1\n";
 }
 static function HelpFrame(segment:String)
    {
      /* return LoadSegment("LCL")+"M=M-1\nA=M\nD=M\n"+LoadSegment(segment)+"M=D\n";// nurit*/
        return LoadSegment(segment)+"D=A\n"+LoadSegment("FRAME")+"A=M-D\nD=M\n"+LoadSegment(segment)+"M=D\n@SP\nM=M-1\n";
    }
static function PointerPush(index:String):String{
    var t:String;
    if(index == "0")
        t = "THIS";
    else
        t = "THAT";
    return LoadSegment(t)+"D=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n";
}
static function PointerPop(index:String):String{ //pop the last element from the stak and put in the regiter of "index" pointer
    var t:String;
    if(index == "0")
        t = "THIS";
    else
        t = "THAT";
  
    return LoadSegment() + "A=M-1\nD=M\n" + LoadSegment(t) + "M=D\n@SP\nM=M-1\n";
}
 
}


