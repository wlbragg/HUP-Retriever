##

#Calcul de positionnement du porte-avion ainsi que de ses catapultes respectives ====
#this is a nasal script scratch, anybody who want to improve it , can do it.
#Just REMEMBER, we need to know, on line,every catapults, which are available with the selected Carrier.
#That will be necessary for (coming soon) an automatic positionning (taxiing) of the Aircraft on a choosen catapult.

#2010-10-09 v 0.4
#Copyright (C) 2008-2010  Gerard Robin
#update  by GRTHTeam      2014-11-13  v4.3
#This file is licensed under the GPLV2 license       


var carrier_in_sight = [];
setsize(carrier_in_sight,100);

var NBCAT = 5;
var initialized = 0;
var enabled = 0;
var carrier_enabled = 0;
var first_contact = 0;

# distance limted to static-lod/ai-detailed , higher is irrelevant  =============
setprop("sim/carrier/global_in_sight_distance", getprop("sim/rendering/static-lod/ai-detailed"));
var global_in_sight_distance = props.globals.getNode ("sim/carrier/global_in_sight_distance");
var lod_ai_detailed = props.globals.getNode("sim/rendering/static-lod/ai-detailed");
#==============================================================

var cat_heading_deg = [] ;
var cat_heading_rad = [] ;
var cat_elevation = [];
var cat_X = [];
var cat_Y = [];
var cat_Z = [];
var cat_head = [];
var cat_head_to = [];
var cat_dist = [] ;
var cat_dist_to = [];
var cat_length = [];
setsize(cat_heading_deg,NBCAT);
setsize(cat_heading_rad,NBCAT);

setsize(cat_elevation,NBCAT);
setsize(cat_X,NBCAT);
setsize(cat_Y,NBCAT);
setsize(cat_Z,NBCAT);

setsize(cat_head,NBCAT);
setsize(cat_head_to,NBCAT);
setsize(cat_dist,NBCAT);
setsize(cat_dist_to,NBCAT);
setsize(cat_length,NBCAT);

var Cat_pos_lat = [];
var Cat_pos_lon = [];
var Cat_pos_lat_to = [];
var Cat_pos_lon_to = [];
setsize(Cat_pos_lat,NBCAT);
setsize(Cat_pos_lon,NBCAT);
setsize(Cat_pos_lat_to,NBCAT);
setsize(Cat_pos_lon_to,NBCAT);

var Cat_Dist = [];
var Cat_Course = [];
setsize(Cat_Dist,NBCAT);
setsize(Cat_Course,NBCAT);

var runway_heading = 0;
var deck_material = 0;

var s = 0;
var n = 0;
var nc =0;
var ms = 0;


#INIT <property>  REQUIRED WHEN  AIRCRAFT NEVER USE  CATAPULT, IE: HELICOPTER
setprop("fdm/jsbsim/systems/launchbar/launchbar-on",0);
setprop("fdm/jsbsim/launchbar/launch-bar-state",0);
setprop("fdm/jsbsim/launchbar_free/launch-bar-state",0);
setprop("fdm/jsbsim/systems/cat-onarea-memory",0);
setprop("sim/carrier/start-on-carrier",0);
setprop("sim/carrier/use-db",1);
setprop("fdm/jsbsim/systems/carrier/cat",0);
#######################################################

var contact = "none";
var mcontact = "none";
var carrier_nodename = string.lc(mcontact);
var carrier_sim_node = props.globals.getNode("sim/carrier");
var carrier_sim_nodename = carrier_sim_node.getNode(carrier_nodename);



cat_dist[0] = 999999;
var cat_distance=999999;
var delay = 0;
var dist = 999999;
var mdist = 999999999999;
var heading = 999;
var sim_starton_carrier = props.globals.getNode("sim/carrier/start-on-carrier");
var sim_loadcat_carrier = props.globals.getNode("sim/model/carrier-jsbsim");


var alt_k = 0.1;
var alt_m = 0.1;


var loopcf = 0;
var syscarrier = props.globals.getNode("fdm/jsbsim/systems/carrier");
var syscarrier_cat = syscarrier.getChildren("cat");
var m_carrier = 0;
var on_catapult = 1;

var lat_pos_s = nil;
var lon_pos_s = nil;
var roll = nil;
var speed_kts = nil;
var carrier_B_controls = 0;

#	print("=============================================");
#	print("=========NO CARRIERS DIALOG BOX==============");
#	print("YOU MAY WANT THE IMPROVED CARRIERS PROCESSING");
#	print ("ASK TO https://sites.google.com/site/grtuxhangar");
#	print("=============================================");

setprop("sim/carrier/mdist",mdist);
setprop("sim/model/carrier_id/target","Closest");
setprop("sim/carrier/at_sea_level",0);
print ("running Carrier_Contact => => =>" );
#==============================START===============================

var Start_Carrier = func{
if (getprop("fdm/jsbsim/simulation/sim-time-sec") != nil and getprop("fdm/jsbsim/simulation/sim-time-sec") > 4 ) updateCarrier();
else
settimer(Start_Carrier,0.1);
}
Start_Carrier();


#==============================MAIN==========================
 var  updateCarrier = func {
    global_in_sight_distance.setValue( lod_ai_detailed.getValue());
    if (initialized  != 1 ) {
    init_contact();}
    var AllCarrier = props.globals.getNode("ai/models").getChildren("carrier");
    var selectedCarrier = [];
    var carrier_enabled = getprop("sim/carrier/enabled");
      if ( enabled and carrier_enabled) {
        setprop("fdm/jsbsim/systems/carrier-found", 0);
        mdist = 9999999;
        foreach(m; AllCarrier) {
              var   id_node = m.getNode("id" , 1 );
              var  id = id_node.getValue();
                if ( id != nil ) {
                  var aircraft_pos = geo.aircraft_position();
                  var  contact_node = m.getNode("name");
                         contact = contact_node.getValue();
                  var lat_pos_node = m.getNode("position/latitude-deg");
                  var lat_pos = lat_pos_node.getValue();
                  var lon_pos_node = m.getNode("position/longitude-deg");
                  var lon_pos = lon_pos_node.getValue();
                  var heading_node = m.getNode("orientation/true-heading-deg");
                  var roll_node = m.getNode("orientation/roll-deg");
                  var speed_kts_node =  m.getNode("velocities/speed-kts");
                  var carrier_pos  = geo.Coord.new().set_latlon(lat_pos,lon_pos,alt_m);
                  dist = aircraft_pos.direct_distance_to(carrier_pos);
		m._setChildren("in_sight",0);
		  if (m.getNode("extended") == nil) 	m._setChildren("extended","false");
                  if (dist < getprop("sim/carrier/global_in_sight_distance") ){
			lat_pos = lat_pos_s;
			lon_pos = lon_pos_s;
			m.carrier_in_sight = contact;
			m._setChildren("in_sight",1);
			
#print(m.carrier_in_sight,"  ",dist);	
			
			if ( dist < mdist){
			    mdist  = dist;
			    setprop("sim/carrier/mdist",mdist);
			    mcontact = contact;
			     setprop("sim/carrier/name",mcontact);
			    m_carrier = m.getIndex();
			    #var text_welcome = "Ship" ~ mcontact;
			    #var window = screen.window.new(nil, -50, 1, 0.2);
			    #window.write(text_welcome);
			    carrier_nodename = string.lc(mcontact);
			    
#print("carrier_nodename",carrier_nodename);
			}
			if(m.getIndex() == m_carrier){
			    lat_pos_s = lat_pos_node.getValue();
			    lon_pos_s = lon_pos_node.getValue();
			    heading = heading_node.getValue();
			    roll = roll_node.getValue();
			    speed_kts = speed_kts_node.getValue();
			}
		    Carrier_Found();
                   } 
                  
                } #
		if (m.getNode("extended").getBoolValue() == 1 and m.getNode("in_sight").getValue() == 1) {
		carrier_B_controls = gui.Dialog.new("sim/gui/dialogs/carrier/menu/button/dialog", "AI/Carriers/Carrier-Common/Ship-button.xml");
			    carrier_B_controls.open();
		}
          } #
#=====================
#we guess sitting on the deck
#=====================

         #carrier_nodename = string.lc(mcontact);

#print("===   ",getprop("sim/carrier/mdist"),"===   ",carrier_nodename,"===    ",getprop("sim/carrier/"~carrier_nodename));


         if (getprop("gear/gear[1]/wow") and getprop("sim/carrier/mdist") < 200 and getprop("sim/carrier/"~carrier_nodename) != 999) {
#on carrier with db
           if (first_contact == 0) {
             first_contact = 1;
            sim_starton_carrier.setValue(1);
	    if (getprop("sim/model/carrier-jsbsim") )
            Load_Catapults_DB();
           }
           if (getprop("sim/model/carrier-jsbsim") )
            Calc_Pos_Catapult();
         }
        elsif (getprop("gear/gear[1]/wow") and getprop("sim/carrier/mdist") < 200 and getprop("sim/carrier/"~carrier_nodename) == 999) {
#on carrier no db
            if (first_contact == 0) {
            first_contact = 1;
            sim_starton_carrier.setValue(1);

            }
        }

else {
           first_contact = 0;
           sim_starton_carrier.setValue(0);
           cat_distance = 999999 ;
           }
           if (getprop("fdm/jsbsim/systems/carrier-found") == 1 ) {
            setprop ("sim/carrier/name_on",mcontact);
           }else{
             if (getprop("fdm/jsbsim/systems/carrier-id-found") == 0 ) {
              setprop ("sim/carrier/name_on","none");
              setprop ("sim/carrier/flols",0);
              }
             }
   }  #end enable
settimer(updateCarrier,0.2);


}  #end Main updateCarrier

#*********************FUNC**********************************

var init_contact = func {
        var  AI_Enabled = props.globals.getNode("sim/ai/enabled");
        enabled = AI_Enabled.getValue();
      initialized = 1;
settimer(init_contact,1);
} #end loop init


#*******************FUNC***********************************


var Carrier_Found = func{
        setprop("fdm/jsbsim/systems/carrier-found", 1);
        setprop ("sim/carrier/heading-deg",heading);
        setprop("sim/carrier/latitude-deg",lat_pos_s);
        setprop("sim/carrier/longitude-deg",lon_pos_s);
        setprop("sim/carrier/roll-deg",roll);
        setprop("sim/gui/dialogs/carrier/loop",1);

if (getprop("sim/carrier/"~carrier_nodename) == nil ){
	    print("WAITING FOR DB LOADING  cf_nil   ", carrier_nodename);    
	     carrier_sim_node._setChildren(carrier_nodename,"nodb_found");
	     
} 
if(getprop("sim/carrier/"~carrier_nodename) == "nodb_found"){
    
if (loopcf < 10)    
    loopcf+=1;
 else {   	    
	    setprop("sim/carrier/use-db", 0);
	    loopcf = 0;
}
}
     

elsif  (getprop("sim/carrier/"~carrier_nodename) != "nodb_found"){
carrier_sim_nodename = carrier_sim_node.getNode(carrier_nodename);
if(carrier_sim_nodename.getNode("loaded").getValue() == 0){
	    print("WAITING FOR DB LOADING  cf_00    ", carrier_nodename);
	    settimer(Carrier_Found, 1);
}
else{
            at_sea_level = carrier_sim_nodename.getNode("carrier_at_sea_level");
            setprop("sim/carrier/at_sea_level", at_sea_level.getValue());
            setprop("sim/carrier/use-db", 1);
	    runway_heading = carrier_sim_nodename.getNode("runway-heading-degs");
	    setprop("sim/carrier/runway-heading-degs",runway_heading.getValue());       

        }

}
}


#*********************FUNC****************************************
#============Loading the Deck Geometry definition =========
var Load_Catapults_DB = func{

var window = screen.window.new(nil, -100, 4, 30);


carrier_nodename = string.lc(mcontact);
carrier_sim_nodename = carrier_sim_node.getNode(carrier_nodename);

if (getprop("sim/carrier/"~carrier_nodename) == nil){
print("WAITING FOR DB LOADING  catdb_nil   ", carrier_nodename);
settimer(Load_Catapults_DB, 0.5);
}
elsif (getprop("sim/carrier/"~carrier_nodename) == "nodb_found"){
print("DEFINTIVELY NO Data Base FOR      ", carrier_nodename);
setprop("sim/carrier/no-catapult-definition",1);
window.write("CARRIER WITHOUT GEOMETRY DEFINITION", 1, 1, 1);
window.write("THAT CARRIER DOES NOT SUPPORT JSBSIM", 1, 0.5, 0);
window.write("THOUGH   ==NOT==   REALISTIC", 1, 1, 1);
window.write("YOU CAN USE CATAPULT AT ANY PLACE ON THE DECK", 1, 1, 1)
#settimer(Load_Catapults_DB, 0.5);
}
elsif (carrier_sim_nodename.getNode("loaded").getValue() == 0){
print("WAITING FOR DB LOADING  catdb_00   ", carrier_nodename);
settimer(Load_Catapults_DB, 0.5);
}
else{
        print ("WELCOME ON BOARD, CARRIER: => ",mcontact," <=");
        var text_welcome = "Welcome on board  " ~ mcontact;
        window.write(text_welcome,1,1,1);
	var text_wait  = "WAIT, for operations, CARRIER must be at SEA_LEVEL";
	window.write(text_wait,1,1,1);
            setprop("sim/carrier/wrong-version", 0);
                var carrier_sim_geometry_node = carrier_sim_nodename.getNode("geometry");
		deck_material = carrier_sim_geometry_node.getNode("material").getValue();
#print ("deck_material  ",deck_material);
Terrain_onDeck();
                foreach (var n; carrier_sim_geometry_node.getChildren("cat") ) {
                    var index = n.getIndex();
                    if(index != 0){
                        cat_heading_deg[index] = n.getNode("heading-deg").getValue();
                        cat_heading_rad[index] = n.getNode("heading_rad").getValue();
                        cat_elevation[index] = n.getNode("z-pos").getValue();
                        cat_X[index] = n.getNode("x-pos").getValue();
                        cat_Y[index] = n.getNode("y-pos").getValue();
                        cat_Z[index] = n.getNode("z-pos").getValue();
                        cat_head[index] = n.getNode("coord_course").getValue();
                        cat_head_to[index] = n.getNode("coord_course_to").getValue();
                        cat_dist[index] = n.getNode("coord_dist").getValue();
                        cat_dist_to[index] = n.getNode("coord_dist_to").getValue();
                        cat_length[index] = n.getNode("length").getValue();
                        print("LOADING  DB");
#print("CAT  ",index,"   COURSE  ",cat_head[index],"  DISTANCE  ",cat_dist[index],"  ELEVATION ",cat_elevation[index]);
setprop("sim/carrier/no-catapult-definition",0);
                    }
                } #end foreach
        }

}

#*********************************FUNC***********************************************************
var Closest_Catapult = func {
                    var posCat=geo.Coord.set_latlon(Cat_pos_lat[nc],Cat_pos_lon[nc],alt_k);
                    var aircraft_pos = geo.aircraft_position();
                    Cat_Dist[nc] = aircraft_pos.distance_to(posCat);
                    Cat_Course[nc] = aircraft_pos.course_to(posCat);
                    if (cat_distance > Cat_Dist[nc] ) {
                        cat_distance = Cat_Dist[nc];
                        var cat_course = D2R*Cat_Course[nc];
                        setprop("sim/carrier/carrier-id",m_carrier);
                        setprop("sim/carrier/cat-distance",cat_distance);
                        setprop("sim/carrier/cat-course",cat_course);
                        setprop("sim/carrier/cat-closeto-id",nc);
                        setprop("sim/carrier/cat-length",cat_length[nc]);
                        setprop("sim/carrier/cat-heading-rad",cat_heading_rad[nc]);
                        setprop("sim/carrier/cat-heading-deg",cat_heading_deg[nc]);
                        on_catapult = nc;
#print (cat_distance);
                    }
}

#*********************************FUNC***********************************************************

Calc_Pos_Catapult = func{
            cat_distance = 999999;
            foreach (var inc; syscarrier_cat) {
              nc = inc.getIndex();
              if ( cat_head[nc]  != nil){
                 var catapult = geo.Coord.new().set_latlon(lat_pos_s,lon_pos_s,alt_k);
                 var Cat_pos  = catapult.apply_course_distance(cat_head[nc] + heading, cat_dist[nc]);
                 Cat_pos_lat[nc] = Cat_pos.lat();
                 Cat_pos_lon[nc] = Cat_pos.lon();
##usefull to Taxi
                inc._setChildren("lat-position",Cat_pos_lat[nc]);
                inc._setChildren("lon-position",Cat_pos_lon[nc]);
                inc._setChildren("heading-rad",cat_heading_rad[nc]);
Closest_Catapult();
                 }  # end if  Nil
           }  # end foreach

}


#==================================================================
#==================================================================
var ON_CATAPULT_TIMER = 0.0001;
var ct_loop = 0;
var aircraft_course_ct = 0;
var aircraft_course = 0;
var cat_course_ct = 0;
var cat_course = 0;
var cat_distance_ct = 0;
var cat_distance = 0;
var AVERAGE_CT = 1;
var window_cat = screen.window.new(nil, -160, 1, 1);
var window_roll = screen.window.new(nil, -240, 1, 1);

var w_cat_y_pos = 0;
var w_cat_x_pos = 0;
var  w_cat_head = 0;
var w_cat_dist = 0;
var marker = [];

var err_corr_d = 0;
var err_corr_h = 0;
var err_corr_dist = 0;
var catapult = 0;


var On_Catapult = func {
 if(sim_starton_carrier.getValue() == 1 and sim_loadcat_carrier.getValue() == 1){
        if (getprop("sim/carrier/cat-closeto-id") != 0 and  m_carrier != nil) {
            var carrier_node = props.globals.getNode("ai/models").getNode("carrier["~m_carrier~"]");
            var latitude_node = carrier_node.getNode("position/latitude-deg");
            var longitude_node = carrier_node.getNode("position/longitude-deg");
            var altitude_node = carrier_node.getNode("position/altitude-ft");
            var latitude = latitude_node.getValue();
            var longitude = longitude_node.getValue();
            var nc = on_catapult;
#print (cat_elevation[nc]);
            var altitude = FT2M*altitude_node.getValue() + cat_elevation[nc] ;
            if(roll < 0.1 and roll > -0.1) {
        AVERAGE_CT = 4;
                w_cat_head = cat_head[nc];
                w_cat_dist = cat_dist[nc];
                w_cat_Y = cat_Y[nc];
                w_cat_heading_deg = cat_heading_deg[nc];
            }
            else {
                window_roll.write("CARRIER ROLL   "~ roll);
        AVERAGE_CT = 10;
#we compute the catapulte position according to the roll
                var cat_R_dtroll = math.sqrt((cat_Z[nc] * cat_Z[nc] ) + (cat_Y[nc] * cat_Y[nc]));
                var cat_A_dtroll = math.atan2(cat_Y[nc], cat_Z[nc]);
                var cat_An_dtroll = cat_A_dtroll + D2R * roll;
                var cat_Y_dtroll = math.sin(cat_An_dtroll) * cat_R_dtroll;
                w_cat_y_pos =  cat_Y_dtroll;
                w_cat_x_pos =  cat_X[nc];
                w_cat_head = R2D * (math.atan2(w_cat_y_pos , w_cat_x_pos));
                w_cat_dist = math.sqrt((w_cat_y_pos * w_cat_y_pos) + (w_cat_x_pos * w_cat_x_pos));
            }
#print("LAT   ",latitude," LON   ",longitude," ALT   ",altitude);

            var catapult_base = geo.Coord.new().set_latlon(latitude,longitude);

            err_corr_dist =((speed_kts/3600)*1852*0.1) ;
            catapult = catapult_base.apply_course_distance( heading , err_corr_dist);

            err_corr_h = 0;
            var coeff = 0.14;
            if (heading > 270 and heading < 360 )
            err_corr_h = coeff * (1 - math.abs(math.cos(D2R*(heading - 270)*2)));
             if (heading > 180 and heading < 270 )
            err_corr_h = - coeff * (1 - math.abs(math.cos(D2R*(heading - 180)*2)));
             if (heading > 90 and heading < 180 )
            err_corr_h = coeff * (1 - math.abs(math.cos(D2R*(heading - 90)*2)));
            if (heading > 0 and heading < 90 )
            err_corr_h = - coeff * (1 - math.abs(math.cos(D2R*(heading - 0)*2)));

            var Cat_pos  = catapult.apply_course_distance( w_cat_head + 360 + err_corr_h + heading, w_cat_dist);
            
            var aircraft_pos = geo.aircraft_position();
            var cat_distance_U = aircraft_pos.distance_to(Cat_pos);
            var Cat_Course = aircraft_pos.course_to(Cat_pos);
#print("Dist   ",cat_distance_U,"   Course     ",Cat_Course);
            var Aircraft_Course = Cat_Course + cat_heading_deg[nc] - heading ;
            var cat_head_U = D2R*w_cat_head;
            var heading_U = D2R*heading;
            var cat_course_U = D2R*Cat_Course;
            var aircraft_course_U = D2R*Aircraft_Course;
   
            if (ct_loop > (AVERAGE_CT -1)) {
                    ct_loop = 0;
                    aircraft_course = aircraft_course_ct/AVERAGE_CT;
                    cat_course = cat_course_ct/AVERAGE_CT;
                    cat_distance = cat_distance_ct/AVERAGE_CT;
                    setprop("sim/carrier/oncat-distance",cat_distance);
                    setprop("sim/carrier/oncat-course",cat_course);
                    setprop("sim/carrier/aircraft-course",aircraft_course);
                    window_cat.write("On Catapult  - DISTANCE:   " ~ cat_distance,1,1,0);
                    syscarrier.getNode("cat-head").setValue(cat_heading_rad[nc]);
                    aircraft_course_ct = 0;
                    cat_course_ct = 0;
                    cat_distance_ct = 0;
            }else{
                    aircraft_course_ct = aircraft_course_ct + aircraft_course_U;
                    cat_course_ct = cat_course_ct + cat_course_U;
                    cat_distance_ct = cat_distance_ct + cat_distance_U;
                    ct_loop = ct_loop + 1;
            }
#print ("CAT  ",nc," DISTANCE  ",cat_distance,"   COURSE   ",cat_course,"  AircraftCOURSE  ", aircraft_course);
        }else{
                        setprop("sim/carrier/oncat-distance",99);
                        setprop("sim/carrier/oncat-course",0);
                        setprop("sim/carrier/aircraft-course",0);
        }
#print("on cat_loop");

settimer(On_Catapult,ON_CATAPULT_TIMER);
}else{}
}
#On_Catapult();
setlistener(sim_starton_carrier,On_Catapult);


#=============Runway==================

var Runway = func{
}

#=============JBD and LAUNCH BAR ENGAGE==================



var lch_engage = screen.display.new(0,0);
lch_engage.format = "%.3g";
lch_engage.setfont("TIMES_24");
lch_engage.setcolor(0.5,1,0.9);

var LCHB_Message = func{
    var remain_time = getprop("fdm/jsbsim/systems/launchbar-remaining-sec");

    if(remain_time > 0 and launchbar_on.getValue()  == 1 and sim_starton_carrier.getValue() == 1){
        window_lhbon.write("LAUNCH BAR ENGAGED",0.5,1,0.9);
	 window_lhbon.write("BEFORE CATAPULT, DON'T FORGET TO PUSH THROTTLE AT MAX",0.5,1,0.9);
        #window_lhbon.write("REMAINING SEC :  "~ remain_time,0.5,1,0.9);
        lch_engage.add("fdm/jsbsim/systems/launchbar-remaining-sec");
        settimer(LCHB_Message, 0.5);
    }else {
        #done_new = 0;
        lch_engage.close();
        }
}

var launchbar_on = props.globals.getNode("fdm/jsbsim/systems/launchbar/launchbar-on");
var launch_bar_state = props.globals.getNode("fdm/jsbsim/launchbar/launch-bar-state");
var launch_barfree_state = props.globals.getNode("fdm/jsbsim/launchbar_free/launch-bar-state");
var engaged = "Engaged";
var window_lhb = screen.window.new(nil, -180, 2, 4);
var window_lhbr = screen.window.new(nil, -180, 2, 20);
var window_lhbon = screen.window.new(nil, -210, 1, 1);
var done_new = 0;

var lhb_on = 0;
var JBD_op=func{
    if(sim_starton_carrier.getValue() == 1){
#print("Launch Bar state");
        if(launch_bar_state.getValue() > 0 and  done_new == 0) {
            print("Launch Bar state  ON ");
            setprop("/gear/launchbar/state", engaged);
            LCHB_Message();
            done_new = 1;
            lhb_on = launchbar_on.getValue();
        }
        elsif (launch_barfree_state.getValue()  > 0 and done_new == 0){
            print("Launch BarFree state  ON ");
            setprop("/gear/launchbar/state", engaged);
            window_lhb.write("WORKING WITH ANY CATAPULT POSITION", 1, 1, 1);
            done_new = 1;
        }
        else {
            if (launchbar_on.getValue() == 1 and done_new == 0 and getprop("fdm/jsbsim/systems/cat-onarea")!= 0){
                window_lhb.write("LAUNCH-BAR BEING OPERATED", 1, 1, 1);
                window_lhb.write("PLEASE WAIT",0.5,1,0.9);
            }

            if(launchbar_on.getValue() == 0 and lhb_on == 1) {
                window_lhbr.write("MANUAL RELEASE OR TIME OUT !!!  OR TOO MUCH ROLL !!!  LAUNCH-BAR RELEASED", 1, 1, 1);
                window_lhbr.write("YOU MAY WANT TO ENGAGE IT AGAIN", 1, 1, 1);
                lhb_on = launchbar_on.getValue();
                setprop("/gear/launchbar/state", "   ");
                done_new = 0;
            }
        }
        settimer(JBD_op, 0.4);

    }else {
            lhb_on = 0;
            done_new = 0;
            setprop("/gear/launchbar/state", "   ");
              }
}
#JBD_op();


setlistener(sim_starton_carrier,JBD_op);


 var catapultVector=func{
      #if(getprop("fdm/jsbsim/systems/catapult/cat-pos-norm") != 0 and m_carrier != nil ) {
     if(getprop("fdm/jsbsim/launchbar/launch-bar-state") != 0 and m_carrier != nil ) {
        var carrier_node = props.globals.getNode("ai/models").getNode("carrier["~m_carrier~"]");
        var latitude_node = carrier_node.getNode("position/latitude-deg");
        var longitude_node = carrier_node.getNode("position/longitude-deg");
        var altitude_node = carrier_node.getNode("position/altitude-ft");
        var latitude = latitude_node.getValue();
        var longitude = longitude_node.getValue();
        var nc = getprop("fdm/jsbsim/systems/cat-onarea-memory");
#print("CAT  ",nc);
        if( nc!= 0){
                var altitude = FT2M*altitude_node.getValue() + cat_elevation[nc] ;
                var catapult_to = geo.Coord.new().set_latlon(latitude,longitude,altitude);
                var Cat_pos_to = catapult_to.apply_course_distance(cat_head_to[nc] + heading,cat_dist_to[nc],altitude);
                #var ac_latitude = getprop("/position/latitude-deg");
                #var ac_longitude = getprop("/position/longitude-deg");
                var ac_altitude = altitude;
                #var ac_pos_from = geo.Coord.new().set_latlon(ac_latitude,ac_longitude,ac_altitude);
                var ac_pos_from = geo.aircraft_position();
                var cat_Vector_to_course =  ac_pos_from.course_to(Cat_pos_to);
                var cat_Vector_to_distance = ac_pos_from.distance_to(Cat_pos_to);
                setprop( "fdm/jsbsim/systems/catapult/cat-to",cat_Vector_to_course);
                setprop( "fdm/jsbsim/systems/catapult/cat-dist-to",cat_Vector_to_distance);
                syscarrier._setChildren("cat-length",cat_length[nc]);
                syscarrier._setChildren("cat-head",cat_heading_rad[nc]);
#print("V_COURSE   ",cat_Vector_to_course," V_DISTANCE  ",cat_Vector_to_distance);
        }
      }

      if (getprop("fdm/jsbsim/launchbar/launch-bar-state") == 0){}
          else {
          settimer(catapultVector,0.001);
      }
}
setlistener("fdm/jsbsim/systems/catapult/cat-launch-cmd",catapultVector);


#=========================TAXI===================================
var tn = 9;

var taxi_op=func{
          var tn = getprop("sim/model/taxi/taxi_to");
           if (getprop("sim/model/taxi/linked") == 1 ){
           if (tn == 0){
            setprop("fdm/jsbsim/systems/taxi/distance",0);
            setprop("fdm/jsbsim/systems/taxi/course",0);
            setprop("fdm/jsbsim/systems/taxi/linked",0);
            setprop("fdm/jsbsim/systems/taxi/cat-wp-head",0);
            var text_oncat = "taxi canceled" ;
            var window = screen.window.new(nil, -100, 3, 7);
                        window.write("");
            window.write(text_oncat);
            }else{
           var dest_heading = getprop("fdm/jsbsim/systems/carrier/cat["~tn~"]/heading-rad");
           var dest_lat = getprop("fdm/jsbsim/systems/carrier/cat["~tn~"]/lat-position");
           var dest_lon = getprop("fdm/jsbsim/systems/carrier/cat["~tn~"]/lon-position");
           var pos = geo.Coord.set_latlon(dest_lat,dest_lon,alt_k);
           var ac_pos = geo.aircraft_position();
           var taxi_distance = ac_pos.distance_to(pos);
           var taxi_course = ac_pos.course_to(pos);
#print (taxi_to," ",taxi_distance, " ",taxi_course );
           setprop("fdm/jsbsim/systems/taxi/distance",taxi_distance);
           setprop("fdm/jsbsim/systems/taxi/course",taxi_course);
           setprop("fdm/jsbsim/systems/taxi/cat-wp-head", dest_heading);
           if (getprop("sim/model/oncat") and getprop("sim/carrier/name_on") != "none"){
               var oncat = getprop("fdm/jsbsim/systems/cat-onarea");
#print ("On catapult", oncat );
               var text_oncat = "Your are on catapult " ~ oncat;
               var window = screen.window.new(nil, -100, 3, 7);
               window.write("");
               window.write(text_oncat);
}
            }
settimer(taxi_op,1);
}
}
setlistener("sim/model/taxi/linked",taxi_op);

var taxi_message=func{
          if (getprop("sim/model/taxi/linked") and getprop("sim/carrier/name_on") != "none"){
          var taxi_to = getprop("sim/model/taxi/taxi_to");
          var text_taxi_to = "Your are going to Catapult number  " ~ taxi_to;
          var window = screen.window.new(nil, -100, 3, 10);
                      window.write("");
                      window.write("");
                      window.write(text_taxi_to);
          }
          #else{
          #var text_taxi_to = "Your request is not valid";
          #var window = screen.window.new(nil, -100, 3, 50);
          #            window.write("");
          #            window.write(text_taxi_to);
          #}
}
setlistener("sim/model/taxi/linked",taxi_message);


#ce qui suit ne marche pas proprement
var oncat_message=func{
          if (getprop("sim/model/oncat") and getprop("sim/carrier/name_on") != "none"){
          var oncat = getprop("fdm/jsbsim/systems/cat-onarea");
print ("On catapult", oncat );
          var text_oncat = "Your are on catapult " ~ oncat;
          var window = screen.window.new(nil, -100, 3, 20);
                      window.write("");
                      window.write(text_oncat);
          }
}
#setlistener("sim/model/oncat",oncat_message);

#===========TERRAIN on Carrier=========================
Terrain_onDeck = func {
print("Terrain_ondeck_material  ",deck_material);
               if (sim_starton_carrier.getValue() == 1) {
		if (deck_material == 0) {
                 setprop("fdm/jsbsim/environment/terrain-load-resistance",1e+30);
                 setprop("fdm/jsbsim/environment/terrain-friction-factor",1.05);
                 setprop("fdm/jsbsim/environment/terrain-bumpiness",0);
                 setprop("fdm/jsbsim/environment/terrain-rolling-friction",0.02);
               }elsif (deck_material == 1) {
		setprop("fdm/jsbsim/environment/terrain-load-resistance",1e+30);
                 setprop("fdm/jsbsim/environment/terrain-friction-factor",1.2);
                 setprop("fdm/jsbsim/environment/terrain-bumpiness",0);
                 setprop("fdm/jsbsim/environment/terrain-rolling-friction",0.05);
	      }elsif (deck_material == 2) {
		setprop("fdm/jsbsim/environment/terrain-load-resistance",1e+30);
                 setprop("fdm/jsbsim/environment/terrain-friction-factor",0.9);
                 setprop("fdm/jsbsim/environment/terrain-bumpiness",0.01);
                 setprop("fdm/jsbsim/environment/terrain-rolling-friction",0.04);
               }
	    }
}



#==============CATAPULTING  PROCESS================

Catapulting = func {
    print("Catapulting");
		    
}