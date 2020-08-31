
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
    static var filePath="./PointerTest.vm"; 
    static var filename=new haxe.io.Path(filePath).file;
    static function main()
  {
    #if sys  //check if the file system is aviable
      trancelateFile();
    #end
  }
  static function trancelateFile():Void{
        var readFile=sys.io.File.read(filePath,false);  //open the file for reading
         var asmPath="./"+filename+".asm"; //creat new file- file.asm
        //הפקודות הבאות נועדו לוודא שהתרגום לא ישורשר בסוף התרגום מההרצה הקודמת. בכל הרצה יפתח קובץ מחדש
         if (sys.FileSystem.exists(asmPath))
              sys.FileSystem.deleteFile(asmPath);
        //עד כאן 
        var fileAsm = sys.io.File.append(asmPath,false);  //open "filename.asm" to write in the end of
       
        fileAsm.writeString(Bootstapping());
 
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
            fileAsm.close();
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
         case "label": return Label(command[1]);
         case "goto": return GotoL(command[1]);
         case "if": return IfGotoL(command[1]);
         case "if-goto": return IfGotoL(command[1]);
        default: return "";
         }
        }

 static function LoadSegment(segment:String="SP"):String{
     var asmSegment=segment.toUpperCase();
    switch (segment){
        case "local": asmSegment="LCL";
        case "argument": asmSegment="ARG";
    }
    return "@"+asmSegment+"\n";
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

static function Bootstapping():String{// Initialize the SP to 256. the vm code: sp=256;
    return "@256\nD=A\n@SP\nM=D\n"+ //sp
            "@300\nD=A\n@1\nM=D\n"+ //LCL
            "@400\nD=A\n@2\nM=D\n"+ //Argument
            "@3000\nD=A\n@3\nM=D\n"+ //THIS
            "@3010\nD=A\n@4\nM=D\n"; //THAT  
            
}
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
       
          return LoadSegment() + "A=M-1\nD=M\n@"+(Std.parseInt(index)+5)+"\nM=D\n@SP\nM=M-1\n";
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
    return LoadSegment()+"A=M-1\nD=M\nA=A-1\nD=D-M\n"+LoadSegment("IF_TRUE0")+"D;JEC\nD=0\n"+LoadSegment()+"A=M-1\nA=A-1\nM=D"+LoadSegment("IF_FALSE0")+"\n0;JMP\n(IF_TRUE0)\nD=-1\n"+LoadSegment()+"A=M-1\nA=A-1\nM=D\n(IF_FALSE0)\n"+LoadSegment()+"M=M-1\n";
}
static function Or():String{
    return LoadSegment()+"A=M-1\nD=M\nA=A-1\nD=M+D\nM=0\n@END\nD;JNE\nM=1\n(END)\n"+LoadSegment()+"M=M-1"+"\n";
}
static function Not():String{
    return LoadSegment()+"A=M-1\nD=M\nM=0\n@END\nD;JEQ\nM=1\n(END)\n"+LoadSegment()+"M=M-1"+"\n";
 
}
/// exerices 2
static function Label(label:String):String{
    return "("+label.toUpperCase()+")\n";
}
static function GotoL(label:String):String{
    return "@"+label+"\n0;JMP\n"; //go to label 
}
static function IfGotoL(label:String):String{
    return ""; //go to label if top!=0
}}
