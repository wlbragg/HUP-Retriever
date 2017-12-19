
var window_lhb = screen.window.new(nil, -180, 3, 16);
var window_lhbok = screen.window.new(nil, -180, 2, 10);

var fgexpended = getprop("/sim/version/flightgear");    print ("FGVER_EXPENDED ",fgexpended);

var fg =  substr(fgexpended,2,6);    print ("FGVER_REDUCED ",fg);
var model_min = getprop("/sim/model/fg-ver_min");    print ("MODELmin ",model_min);
var model_max = getprop("/sim/model/fg-ver_max");    print ("MODELmax ",model_max);
var fgnan = substr(fg,0,2);
var fgn1 = substr(fg,3,1);
var fgn2 = substr(fg,5,1);


#print ("FGNAN     ",fgnan);
#print ("FGN1     ",fgn1);
#print ("FGN2     ",fgn2);

var calcnfg = (fgnan*100 +(fgn1*10) + fgn2)/100;

var nfg = sprintf("%.2f", calcnfg);

print ("FGVER ",nfg) ;


if (nfg < model_min  or  nfg > model_max){
setprop("fdm/simulation/wrg-ver",1);

window_lhb.write("That AIRCRAFT has been  CHECKED running  AGAINST VERSION IN THE RANGE : ");
window_lhb.write ("MIN "~ model_min ~" MAX "~model_max);
window_lhb.write("You could get some issue, your Flightger version is out of that range " );


print("VERSIONS ARE WRONG");
}else{
setprop("fdm/simulation/wrg-ver",9);
print("SYSVER  ",getprop("fdm/simulation/wrg-ver"));
window_lhbok.write("CONSISTENCY CHECKING:  AIRCRAFT AGAINST  FLIGHTGEAR  ==>successful<==.... , ENJOY");
print("VERSION IS CONSISTENT");
}



