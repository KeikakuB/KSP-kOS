DECLARE GLOBAL FUNCTION LAUNCH {
    PRINT "EXECUTING 'LAUNCH':".
    DECLARE PARAMETER DESIRED_RADIUS IS 90000.
    PRINT "    DESIRED_RADIUS: " + DESIRED_RADIUS.
    DECLARE PARAMETER CLEARANCE_DELAY_IN_SECONDS IS 1.
    PRINT "    CLEARANCE_DELAY_IN_SECONDS: " + CLEARANCE_DELAY_IN_SECONDS.
    DECLARE PARAMETER MAX_TURN_DEGREES IS 45.
    PRINT "    MAX_TURN_DEGREES: " + MAX_TURN_DEGREES.
    DECLARE PARAMETER MAX_TURN_ALTITUDE IS 10000.
    PRINT "    MAX_TURN_ALTITUDE: " + MAX_TURN_ALTITUDE.

    LOCK THROTTLE TO 1.0.

    //This is a trigger that constantly checks to see if our thrust is zero.
    //If it is, it will attempt to stage and then return to where the script
    //left off. The PRESERVE keyword keeps the trigger active even after it
    //has been triggered.
    WHEN STAGE:READY AND SHIP:MAXTHRUST = 0 THEN {
        PRINT "Staging: " + STAGE:NUMBER.
        STAGE.
        PRESERVE.
    }.

    //This will be our main control loop for the ascent. It will
    //cycle through continuously until our apoapsis is greater
    //than 100km. Each cycle, it will check each of the IF
    //statements inside and perform them if their conditions
    //are met

    // Wait for clearance of launch pad.
    WAIT CLEARANCE_DELAY_IN_SECONDS.

    LOCK STEERING TO HEADING(90,90). 
    UNTIL SHIP:OBT:APOAPSIS > DESIRED_RADIUS {

        LOCAL CURRENT_ANGLE IS 90 - ((SHIP:ALTITUDE / MAX_TURN_ALTITUDE) * MAX_TURN_DEGREES).
        IF CURRENT_ANGLE < 45 {
            SET CURRENT_ANGLE TO 45.
        }.
        LOCK STEERING TO HEADING(90, CURRENT_ANGLE).
    }.
    PRINT "Desired apoapsis (" + DESIRED_RADIUS +"m) reached, cutting throttle.".
    LOCK THROTTLE TO 0.
}.
