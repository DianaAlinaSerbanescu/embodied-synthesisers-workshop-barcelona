// Unified protocol: session, sequence, mode, n0, n1, gain0, gain1,
// armed, gesture0, gesture1, fileID, waveACK, restart, track0, track1, noteStart0, noteStart1.
autowatch=1;inlets=1;outlets=10;
var session=-1,sequence=-1,mode=-1,latest=null,readyAt=0,enabled=false;
var retired=[],watchdog=new Task(lost,this);
function finite(v){return typeof v==='number'&&isFinite(v);}
function integer(v){return finite(v)&&v>=0&&v===Math.floor(v);}
function channel(m){return m<3?0:m-2;}
function emit(a,on){
 var m=a[2],x=a[3],y=a[4],g0=on?a[5]:0,g1=on?a[6]:0,e=on?1:0;
 if(m<3)outlet(0,[m,x,y,g0,g1,e,a[15],a[16]]);
 else if(m===3)outlet(1,[x,y,g0,g1,e,a[8],a[9]]);
 else if(m===4||m===5)outlet(channel(m),[x,y,g0,e,a[8]]);
 else if(m===6)outlet(4,['state',x,y,g0,e,a[10],a[11]]);
 else if(m===7)outlet(5,['state',x,y,g0,e,a[10],a[11],a[12]]);
 else if(m===8)outlet(6,[x,y,on?a[13]:0,on?a[14]:0]);
 else if(m===9)outlet(9,[x,y,on?a[13]:0,on?a[14]:0]);
}
function stop(){if(latest)emit(latest,false);enabled=false;}
function state(){
 var a=arrayfromargs(arguments);
 if(a.length!==17)return;
 for(var i=0;i<17;i++)if(!finite(a[i]))return;
 for(var j=0;j<17;j++)if(j!==3&&j!==4&&j!==5&&j!==6&&!integer(a[j]))return;
 if(a[2]>9||a[3]<0||a[3]>1||a[4]<0||a[4]>1||a[5]<0||a[5]>.15001||a[6]<0||a[6]>.15001)return;
 if(a[7]>1||a[13]>1||a[14]>1||a[15]>10||a[16]>10)return;
 if(a[0]!==session){
  if(retired.indexOf(a[0])>=0)return;
  stop();if(session>=0)retired.push(session);if(retired.length>16)retired.shift();
  session=a[0];sequence=-1;mode=-1;
 }
 if(a[1]<=sequence)return;
 sequence=a[1];
 if(a[2]!==mode){stop();mode=a[2];readyAt=Date.now()+180;}
 latest=a;
 var ready=Date.now()>=readyAt,on=ready&&a[7]===1;
 if(on&&!enabled&&mode<8)outlet(8,'start');
 // A disabled mode is already stopped; avoid repeatedly restarting fade ramps.
 if(on)emit(a,true);else if(enabled)emit(a,false);
 enabled=on;
 outlet(7,['/suite/status',session,sequence,mode,ready?1:0]);
 watchdog.cancel();watchdog.schedule(500);
}
function load(){
 var a=arrayfromargs(arguments);
 if(a.length!==4||a[0]!==session||!integer(a[1])||!integer(a[2])||a[2]===0||typeof a[3]!=='string'||!a[3].length)return;
 if(a[1]===6||a[1]===7)outlet(channel(a[1]),['load',a[2],a[3]]);
}
function lost(){stop();}
function notifydeleted(){watchdog.cancel();}
