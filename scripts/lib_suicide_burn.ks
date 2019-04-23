DECLARE FUNCTION SUICIDE_BURN {
    PRINT "EXEC 'SUICIDE_BURN'...".
    // Perform a suicide burn such that you stop thrusting as soon as you reach the ground.

    // 
    // 
    // 
    LOCAL _BODY IS SHIP:OBT:BODY.

    WHEN STAGE:READY THEN {
        LIST ENGINES IN elist.
        FOR e IN elist {
            IF e:FLAMEOUT {
                STAGE.
                PRINT "Staging: " + STAGE:NUMBER.
                BREAK.
            }.
        }.
        PRESERVE.
    }.

    // P-loop setup
    LOCK STEERING TO HEADING(90, 90).
    WAIT UNTIL VANG(HEADING(90, 90):VECTOR, SHIP:FACING:VECTOR) < 0.25.


    LOCAL tset IS 0.
    LOCK THROTTLE TO tset.
    // 
    LOCAL _BODY IS SHIP:OBT:BODY.
    LOCAL g IS _BODY:MU / _BODY:RADIUS^2.
    LOCAL v_speed IS SHIP:VERTICALSPEED.
    LOCAL alt_radar IS ALT:RADAR.

    LOCAL a IS -g.
    LOCAL b IS v_speed.
    LOCAL c IS alt_radar.
    LOCAL d IS (b*b) - (4*a*c).

    LOCAL sol1 IS (-b-SQRT(d))/(2*a).
    LOCAL sol2 IS (-b+SQRT(d))/(2*a).
    PRINT "FALL INFO: ".
    PRINT "d: " + d.
    PRINT "-g, a: " + a.
    PRINT "vspeed b: " + b.
    PRINT "alt radar c: " + c.
    PRINT sol1 + ", " + sol2.
    LOCAL fall_duration IS sol1.

    // TODO calculate this (use deltav?) TODO use Tsiolkovsky rocket equation?
    // TODO try to figure out how I can use a PID controller to do this?

    LOCAL burn_duration is 30.

    PRINT "Burn duration: " + burn_duration + "s".
    PRINT "Fall duration: " + fall_duration + "s".
    LOCAL WAIT_DURATION IS (fall_duration - burn_duration).
    PRINT "Waiting for: " + WAIT_DURATION + "s".

    //WAIT WAIT_DURATION.
    //SET tset TO 1.
    //LOCAL t IS TIME:SECONDS().
    //UNTIL ALT:RADAR < 50 OR SHIP:VERTICALSPEED > 0 {
        //SET burn_duration TO burn_duration - (TIME:SECONDS() - t).
        //SET fall_duration TO fall_duration - (TIME:SECONDS() - t).
        //PRINT "Burn duration: " + burn_duration + "s" at (0, 18).
        //PRINT "Fall duration: " + fall_duration + "s" at (0, 19).
        //SET t TO TIME:SECONDS().
    //}
    SET tset TO 0.
    PRINT "END 'SUICIDE_BURN'.".
}.
