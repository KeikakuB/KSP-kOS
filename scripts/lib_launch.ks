DECLARE GLOBAL FUNCTION LAUNCH {
    PRINT "EXEC 'LAUNCH'...".
    DECLARE PARAMETER DESIRED_RADIUS IS 90000.
    PRINT "    DESIRED_RADIUS: " + DESIRED_RADIUS.
    DECLARE PARAMETER CLEARANCE_DELAY_IN_SECONDS IS 1.
    PRINT "    CLEARANCE_DELAY_IN_SECONDS: " + CLEARANCE_DELAY_IN_SECONDS.
    DECLARE PARAMETER MAX_TURN_DEGREES IS 45.
    PRINT "    MAX_TURN_DEGREES: " + MAX_TURN_DEGREES.
    DECLARE PARAMETER MAX_TURN_ALTITUDE IS 10000.
    PRINT "    MAX_TURN_ALTITUDE: " + MAX_TURN_ALTITUDE.
    LOCK STEERING TO SSET.
    SET SSET TO HEADING(90,90). 
    LOCK THROTTLE TO 1.0.
    STAGE.
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
    WAIT CLEARANCE_DELAY_IN_SECONDS.
    UNTIL SHIP:OBT:APOAPSIS > DESIRED_RADIUS {
        LOCAL current_angle IS 90 - ((SHIP:ALTITUDE / MAX_TURN_ALTITUDE) * MAX_TURN_DEGREES).
        IF current_angle < 45 {
            BREAK.
        }.
        SET SSET TO HEADING(90, current_angle).
    }.
    PRINT "Locking to 45 degrees.".
    LOCK STEERING TO HEADING(90, 45).
    WAIT UNTIL SHIP:OBT:APOAPSIS > DESIRED_RADIUS.
    PRINT "Desired apoapsis (" + DESIRED_RADIUS +"m) reached, cutting throttle.".
    LOCK THROTTLE TO 0.
    PRINT "END 'LAUNCH'.".
}.
