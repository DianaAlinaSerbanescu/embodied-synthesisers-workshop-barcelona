autowatch=1;inlets=1;outlets=3;
var pool=[48,50,52,55,57,60,62,64,67,69,72,74,76,79,81];
var steps=[-1,-1],starts=[0,5],lastMode=-1,last=[[1,100,0],[1,180,0]];
var watchdog=new Task(lost,this);
function frequency(note){return 440*Math.pow(2,(note-69)/12);}
function list(){
 var a=arrayfromargs(arguments);if(a.length!==8)return;
 for(var i=0;i<8;i++)if(typeof a[i]!=='number'||!isFinite(a[i]))return;
 var m=a[0];if(m<0||m>2||m!==Math.floor(m))return;
 if(m!==lastMode){steps=[-1,-1];lastMode=m;}
 var f=[];
 for(var i=0;i<2;i++){
  var n=Math.max(0,Math.min(1,a[i+1]));
  if(m===0)f[i]=(i?180:100)*Math.pow(i?1100/180:7,n);
  else if(m===2)f[i]=40*Math.pow(200,n);
  else{
   var start=Math.max(0,Math.min(10,Math.floor(a[i+6])));
   if(starts[i]!==start){starts[i]=start;steps[i]=-1;}
   var position=n*4,step=steps[i];if(step<0)step=Math.round(position);
   while(step<4&&position>step+.6)step++;
   while(step>0&&position<step-.6)step--;
   steps[i]=step;f[i]=frequency(pool[start+step]);
  }
  last[i]=[m+1,f[i],a[5]===1?Math.max(0,Math.min(.15,a[i+3])):0];outlet(i,last[i]);
 }
 outlet(2,['/basic/feedback',m,f[0],f[1]]);watchdog.cancel();watchdog.schedule(500);
}
function lost(){for(var i=0;i<2;i++){last[i][2]=0;outlet(i,last[i]);}}
function loadbang(){lost();}
function notifydeleted(){watchdog.cancel();}
