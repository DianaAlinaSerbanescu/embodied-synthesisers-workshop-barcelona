// RAVE HOME controller. OSC transport and the other Studio modes are unchanged.
// Track/FX and 1-based parameter indices verified in REAPER's generic AU: RAVE UI.
// bias [-3,3] -> normalized [0,1]; scale [0,5] -> normalized [0,1].
// Keep these exact preferred values; float32 OSC may round the last decimal.
autowatch=1;inlets=1;outlets=4;
var HOME_BIAS=[2.0286922,0.0,0.0,0.0,0.4376934,0.0,-0.4992319,0.0];
var HOME_SCALE=[1.0,1.0,1.0,1.5279988,1.0,1.0,1.0,1.0];
var TRACK=1, FX=1, FIRST_SCALE_PARAM=15, FIRST_BIAS_PARAM=16;
var EXCURSION=[0.75,0.75]; // Preserve A0 -> bias 0, A1 -> bias 1.
var RETURN_MS=300, MOVE_MS=120, FADE_IN_MS=80, FADE_OUT_MS=120;
var PLAY_LEVEL_DB=-16.3; // Track 1's observed working level, not unity gain.
var current=HOME_BIAS.slice(), target=HOME_BIAS.slice(), gate=0, gateTarget=0;
var initialized=false, running=false, lastTick=0, lastInput=0, lastRefresh=0;
var timer=new Task(tick,this);timer.interval=10;
function clamp(v,lo,hi){return Math.max(lo,Math.min(hi,v));}
function send(address,value){outlet(3,[address,value]);}
function param(index,value){send('/track/'+TRACK+'/fx/'+FX+'/fxparam/'+index+'/value',value);}
function biases(){for(var i=0;i<8;i++)param(FIRST_BIAS_PARAM+2*i,clamp((current[i]+3)/6,0,1));}
function scales(){for(var i=0;i<8;i++)param(FIRST_SCALE_PARAM+2*i,HOME_SCALE[i]/5);}
function volume(){
 // Use the existing REAPER dB route during the fade; normalized zero is true silence.
 if(gate<=0)send('/track/'+TRACK+'/volume',0);
 else send('/track/'+TRACK+'/volume/db',PLAY_LEVEL_DB+20*Math.log(gate)/Math.LN10);
}
function home(){target=HOME_BIAS.slice();gateTarget=0;}
function start(){if(!running){running=true;lastTick=Date.now();timer.repeat();}}
function list(){
 // x,y,track0,track1,gate: only RAVE's internal router payload grows by one field.
 var a=arrayfromargs(arguments);
 if(a.length!==5)return;
 for(var i=0;i<5;i++)if(typeof a[i]!=="number"||!isFinite(a[i]))return;
 if(a[0]<0||a[0]>1||a[1]<0||a[1]>1)return;
 for(var i=2;i<5;i++)if(a[i]!==0&&a[i]!==1)return;
 lastInput=Date.now();
 if(!initialized){
   initialized=true;volume();scales();biases();lastRefresh=lastInput;
 }
 gateTarget=a[4];
 if(!gateTarget)home();
 else for(var i=0;i<2;i++)if(a[i+2])target[i]=clamp(HOME_BIAS[i]+a[i]*EXCURSION[i],-3,3);
 start();
}
function tick(){
 var now=Date.now(),dt=clamp(now-lastTick,0,100);lastTick=now;
 // Independent fail-closed fallback if router/controller messages stop.
 if(now-lastInput>500)home();
 var moving=false;
 for(var i=0;i<8;i++){
   var tau=target[i]===HOME_BIAS[i]?RETURN_MS:MOVE_MS;
   current[i]+=(target[i]-current[i])*(1-Math.exp(-dt/tau));
   if(Math.abs(current[i]-target[i])<0.000001)current[i]=target[i];
   if(current[i]!==target[i])moving=true;
 }
 var previousGate=gate;
 gate=gateTarget?Math.min(1,gate+dt/FADE_IN_MS):Math.max(0,gate-dt/FADE_OUT_MS);
 if(gate!==previousGate)volume();
 biases();
 // Refresh HOME scale coordinates during active control to recover missed UDP packets.
 if(now-lastRefresh>=1000){scales();lastRefresh=now;}
 outlet(2,['/ravebridge/status',current[0],current[1],gate,gateTarget]);
 // Stop writes after a completed return, so a subsequent mode can own its output.
 if(!moving&&gate===0&&gateTarget===0){timer.cancel();running=false;}
}
function notifydeleted(){timer.cancel();}
