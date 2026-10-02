// No audio processing: validate sensor targets and feed existing Max ramps.
autowatch=1;inlets=1;outlets=3;
var last=[0,0], seen=[0,0];
function list() {
 var a=arrayfromargs(arguments);
 if(a.length!==4) return;
 for(var i=0;i<4;i++) if(typeof a[i]!=="number" || !isFinite(a[i])) return;
 if(a[0]<0 || a[0]>1 || a[1]<0 || a[1]>1) return;
 if((a[2]!==0 && a[2]!==1) || (a[3]!==0 && a[3]!==1)) return;
 for(var i=0;i<2;i++) if(a[i+2]===1) {
   if(!seen[i] || a[i]!==last[i]) outlet(i,a[i]);
   last[i]=a[i];seen[i]=1;
 }
 outlet(2,["/ravebridge/status",last[0],last[1],seen[0],seen[1]]);
}
