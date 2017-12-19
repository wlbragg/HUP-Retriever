var init_Run = func {

  setprop("fdm/jsbsim/electrical/switch/battery", 1);
  setprop("fdm/jsbsim/propulsion/engine[0]/magnetos", 3);

  setprop("fdm/jsbsim/electrical/switch/master", 1);

  setprop("fdm/jsbsim/animation/master-switch-lock-cmd", 1);
  setprop("fdm/jsbsim/animation/master-switch-cmd", 1);

  setprop("fdm/jsbsim/animation/rotor_brake-switch-lock-cmd", 0);
  setprop("fdm/jsbsim/animation/rotor_brake-switch-cmd", 0);
  setprop("fdm/jsbsim/animation/rotor_brake-switch", 0);

	setprop("fdm/jsbsim/animation/rotor_clutch-switch", 0);

  setprop("fdm/jsbsim/fcs/wing-fold-cmd", 0);
  setprop("fdm/jsbsim/fcs/brake-parking-cmd-norm", 0);

  #starter appears to need a prime, first attempt primes the engine?
  setprop("fdm/jsbsim/propulsion/engine[0]/starter", 1);
	interpolate("fdm/jsbsim/propulsion/engine[0]/starter", 0, 6.0);
	interpolate("fdm/jsbsim/propulsion/engine[0]/starter", 1, 7.0);
	interpolate("fdm/jsbsim/propulsion/engine[0]/starter", 0, 12.0);
	interpolate("fdm/jsbsim/animation/rotor_clutch-switch", 1, 7.0);

  print("Startup sequence complete");
  var window_lhbon = screen.window.new(nil, -210, 1, 15);
  window_lhbon.write("Rotor ready, engine started, wait for rotor to spin up. ",0.5,1,0.9);
}