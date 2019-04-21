DECLARE GLOBAL FUNCTION CIRCULARIZE_ORBIT {
    DECLARE LOCAL FUNCTION HAS_CIRCULARIZED {
        LOCAL ABSDIFF IS ABS(SHIP:OBT:APOAPSIS - SHIP:OBT:PERIAPSIS).
        IF ABSDIFF > MIN_ABSDIFF {
            // If the diff is bigger than our minimum continuing to throttle will push us further from a circular orbit so let's stop.
            RETURN TRUE.
        }.
        SET MIN_ABSDIFF TO ABSDIFF.
        RETURN FALSE.
    }.
    PRINT "EXECUTING 'CIRCULARIZE_ORBIT'.".
    LOCK STEERING TO HEADING(90,0).
    LOCK THROTTLE TO 0.

    IF SHIP:BODY:ATM:HEIGHT > 0.1 {
        PRINT "Waiting to reach end of atmosphere at " + SHIP:BODY:ATM:HEIGHT + "m to compute burn duration.".
        WAIT UNTIL SHIP:ALTITUDE > SHIP:BODY:ATM:HEIGHT.
    }.

    // Compute needed burn duration to circularize the orbit using the equation for precise orbital speed.
    LOCAL REACHED_APOAPSIS IS SHIP:OBT:APOAPSIS.
    LOCAL MU IS SHIP:BODY:MU.
    LOCAL R IS SHIP:BODY:RADIUS + SHIP:OBT:APOAPSIS.
    LOCAL A_CIRCULAR IS SHIP:BODY:RADIUS + SHIP:OBT:APOAPSIS.
    LOCAL A_VESSEL IS SHIP:BODY:RADIUS + (SHIP:OBT:APOAPSIS + SHIP:OBT:PERIAPSIS) / 2.
    LOCAL V_CIRCULAR IS SQRT(MU * ((2 / R) - (1 / A_CIRCULAR))).
    LOCAL V_VESSEL IS SQRT(MU * ((2 / R) - (1 / A_VESSEL))).
    LOCAL DELTA_V IS V_CIRCULAR - V_VESSEL.
    PRINT "DELTA V: " + DELTA_V + "m/s".

    LOCAL MAX_ACCELERATION IS SHIP:MAXTHRUST/SHIP:MASS.
    LOCAL BURN_DURATION IS DELTA_V / MAX_ACCELERATION.
    PRINT "Burn Duration: " + BURN_DURATION + "s".

    WAIT UNTIL (ETA:APOAPSIS - (BURN_DURATION / 2) < 0).
    // Start burn
    LOCAL MIN_ABSDIFF IS ABS(SHIP:OBT:APOAPSIS - SHIP:OBT:PERIAPSIS).

    PRINT "Burn START: " + MISSIONTIME + "s".
    PRINT "Burn END: " + (MISSIONTIME + BURN_DURATION)+ "s".

    LOCK STEERING TO HEADING(90,0).
    LOCK THROTTLE TO 1.

    // Wait until the apoapsis and periapsis flip
    WAIT UNTIL HAS_CIRCULARIZED().

    PRINT "Orbit circularized".

    LOCK THROTTLE TO 0.
}.
