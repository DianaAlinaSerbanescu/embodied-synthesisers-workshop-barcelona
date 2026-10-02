// Adapter for the supplied REAPER track-volume patch. Existing Max line objects
// provide its 50 ms ramps. Disabled channels retain their last level.
autowatch=1;inlets=1;outlets=3;
var last=[-60,-60],seen=[0,0],active=[false,false];
function list(){
 var a=arrayfromargs(arguments);if(a.length!==4)return;
 for(var i=0;i<4;i++)if(typeof a[i]!=='number'||!isFinite(a[i]))return;
 if(a[0]<0||a[0]>1||a[1]<0||a[1]>1)return;
 if((a[2]!==0&&a[2]!==1)||(a[3]!==0&&a[3]!==1))return;
 for(var i=0;i<2;i++){
  var enabled=a[i+2]===1;
  if(enabled){var db=-60+60*a[i];if(!seen[i]||!active[i]||db!==last[i])outlet(i,db);last[i]=db;seen[i]=1;}
  active[i]=enabled;
 }
 outlet(2,['/volume/status',last[0],last[1],seen[0],seen[1]]);
}
