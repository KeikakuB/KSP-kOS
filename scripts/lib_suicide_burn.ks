DECLARE FUNCTION SUICIDE_BURN {
    PRINT "EXEC 'SUICIDE_BURN'...".
    // Perform a suicide burn such that you stop thrusting as soon as you reach the ground.
    LOCK THROTTLE TO 0.
    LOCK STEERING TO HEADING(90, 90).

    LOCAL _BODY IS SHIP:OBT:BODY.
    LOCAL g IS _BODY:MU / _BODY:RADIUS^2.
    UNTIL FALSE {
        WAIT 0.01.
        LOCAL a IS (SHIP:MAXTHRUST/SHIP:MASS) - g.
        //TODO TIP: if I orbit as low as possible before doing the suicide burn, small errors in the math won't matter as much not to mention it should be more optimal.
        //TODO This works but does not take into account the fact that the acceleration increases as we burn due to loss of mass eg. Tsiolkovsky rocket equation? therefore we stop early
        LOCAL initial_speed IS SHIP:VERTICALSPEED.
        LOCAL t IS initial_speed/a.
        LOCAL avg_speed IS initial_speed/2.
        LOCAL burn_distance IS avg_speed * t.
        LOCAL altitude IS ALTITUDE - SHIP:GEOPOSITION:TERRAINHEIGHT.
        PRINT "burn_distance: " + burn_distance AT (0, 20).
        PRINT "RADAR: " + altitude AT (0, 21).
        IF burn_distance > altitude {
            BREAK.
        }
    }
    LOCK THROTTLE TO 1.
    PRINT "Burning...".
    WAIT UNTIL ALT:RADAR < 50 OR SHIP:VERTICALSPEED > 0.
    PRINT "Burn done.".
    LOCK THROTTLE TO 0.
    PRINT "END 'SUICIDE_BURN'.".
}.
