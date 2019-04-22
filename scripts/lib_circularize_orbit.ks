DECLARE GLOBAL FUNCTION CIRCULARIZE_ORBIT {
    LOCAL MIN_DIFF IS 1000.
    LOCAL FUZZ IS 100.
    DECLARE LOCAL FUNCTION HAS_CIRCULARIZED {
        LOCAL abs_diff IS ABS(SHIP:OBT:APOAPSIS - SHIP:OBT:PERIAPSIS).
        IF min_abs_diff < MIN_DIFF OR (abs_diff > min_abs_diff AND ABS(abs_diff - min_abs_diff) > FUZZ) {
            // If the diff is close to 0 than we're close to a circular orbit so let's stop.
            // If the diff is bigger than our minimum continuing to throttle will push us further from a circular orbit so let's stop.
            RETURN TRUE.
        }.
        SET min_abs_diff TO abs_diff.
        RETURN FALSE.
    }.
    PRINT "EXEC 'CIRCULARIZE_ORBIT'...".
    LOCAL is_going_forward IS ETA:APOAPSIS < ETA:PERIAPSIS.
    LOCAL degrees IS -90.
    IF is_going_forward {
        PRINT "Circularizing up/forward".
        SET degrees TO 90.
    }
    LOCK STEERING TO HEADING(degrees,0).
    LOCK THROTTLE TO 0.

    LOCK IS_ABOVE_ATMOSPHERE TO SHIP:ALTITUDE > SHIP:BODY:ATM:HEIGHT.

    IF SHIP:BODY:ATM:HEIGHT > 0.1 AND NOT IS_ABOVE_ATMOSPHERE {
        PRINT "Waiting to reach end of atmosphere at " + SHIP:BODY:ATM:HEIGHT + "m to compute burn duration.".
        WAIT UNTIL IS_ABOVE_ATMOSPHERE.
    }.

    // Compute needed burn duration to circularize the orbit using the equation for precise orbital speed.
    LOCAL mu IS SHIP:BODY:mu.
    LOCAL r IS SHIP:BODY:RADIUS + SHIP:OBT:APOAPSIS.
    LOCAL a_circular IS SHIP:BODY:RADIUS + SHIP:OBT:APOAPSIS.
    LOCAL a_vessel IS SHIP:BODY:RADIUS + (SHIP:OBT:APOAPSIS + SHIP:OBT:PERIAPSIS) / 2.
    LOCAL v_circular IS SQRT(mu * ((2 / r) - (1 / a_circular))).
    LOCAL v_vessel IS SQRT(mu * ((2 / r) - (1 / a_vessel))).
    LOCAL delta_v IS v_circular - v_vessel.
    PRINT "DELTA V: " + delta_v + "m/s".

    LOCAL max_acceleration IS SHIP:MAXTHRUST/SHIP:MASS.
    LOCAL burn_duration IS delta_v / max_acceleration.
    PRINT "Burn Duration: " + burn_duration + "s".

    LOCAL half_burn_duration IS (burn_duration / 2).
    WAIT UNTIL ((is_going_forward AND ETA:APOAPSIS - half_burn_duration < 0) OR (NOT is_going_forward AND ETA:PERIAPSIS - half_burn_duration < 0)).
    // Start burn
    LOCAL min_abs_diff IS ABS(SHIP:OBT:APOAPSIS - SHIP:OBT:PERIAPSIS).

    PRINT "Burn START: " + MISSIONTIME + "s".
    PRINT "Burn END: " + (MISSIONTIME + burn_duration)+ "s".

    LOCK STEERING TO HEADING(degrees, 0).
    LOCK THROTTLE TO 1.

    // Wait until the apoapsis and periapsis flip
    WAIT UNTIL HAS_CIRCULARIZED().

    PRINT "Orbit circularized".

    LOCK THROTTLE TO 0.
    PRINT "END 'CIRCULARIZE_ORBIT'.".
}.
