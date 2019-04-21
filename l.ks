// Launch from Kerbin and circularize the orbit.

SET DESIRED_RADIUS TO 90000.
SET MAX_TURN_DEGREES TO 45.
SET MAX_TURN_ALTITUDE TO 10000.
SET CLEARANCE_DELAY_IN_SECONDS TO 1.

//First, we'll clear the terminal screen to make it look nice
CLEARSCREEN.

//Next, we'll lock our throttle to 100%.
SET TSET TO 1.0.
LOCK THROTTLE TO TSET.   // 1.0 is the max, 0.0 is idle.

//This is a trigger that constantly checks to see if our thrust is zero.
//If it is, it will attempt to stage and then return to where the script
//left off. The PRESERVE keyword keeps the trigger active even after it
//has been triggered.
WHEN MAXTHRUST = 0 THEN {
    PRINT "Staging".
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

    SET CURRENT_ANGLE TO 90 - ((SHIP:ALTITUDE / MAX_TURN_ALTITUDE) * MAX_TURN_DEGREES).
    IF CURRENT_ANGLE < 45 {
        SET CURRENT_ANGLE TO 45.
    }.
    LOCK STEERING TO HEADING(90, CURRENT_ANGLE).
}.
PRINT "Desired apoapsis (" + DESIRED_RADIUS +"m) reached, cutting throttle.".

LOCK STEERING TO HEADING(90,0).
SET TSET TO 0.

PRINT "Waiting to reach end of atmosphere at " + SHIP:BODY:ATM:HEIGHT + "m to compute burn duration.".

WAIT UNTIL SHIP:ALTITUDE > SHIP:BODY:ATM:HEIGHT.

// Compute needed burn duration to circularize the orbit using the equation for precise orbital speed.
SET MU TO SHIP:BODY:MU.
SET R TO SHIP:BODY:RADIUS + SHIP:OBT:APOAPSIS.
SET A_CIRCULAR TO SHIP:BODY:RADIUS + SHIP:OBT:APOAPSIS.
SET A_VESSEL TO SHIP:BODY:RADIUS + (SHIP:OBT:APOAPSIS + SHIP:OBT:PERIAPSIS) / 2.
SET V_CIRCULAR TO SQRT(MU * ((2 / R) - (1 / A_CIRCULAR))).
SET V_VESSEL TO SQRT(MU * ((2 / R) - (1 / A_VESSEL))).
SET DELTA_V TO V_CIRCULAR - V_VESSEL.
PRINT "DELTA V: " + DELTA_V + "m/s".

SET MAX_ACCELERATION TO SHIP:MAXTHRUST/SHIP:MASS.
SET BURN_DURATION TO DELTA_V / MAX_ACCELERATION.
PRINT "Burn Duration: " + BURN_DURATION + "s".

WAIT UNTIL (ETA:APOAPSIS - (BURN_DURATION / 2) < 0).

LOCK STEERING TO HEADING(90,0).
SET TSET TO 1.

// Wait until the apoapsis and periapsis flip
WAIT UNTIL ABS(SHIP:OBT:APOAPSIS - SHIP:OBT:PERIAPSIS) < 2000.

PRINT "Orbit circularized".

SET TSET TO 0.

UNLOCK STEERING.
UNLOCK THROTTLE.

//This sets the user's throttle setting to zero to prevent the throttle
//from returning to the position it was at before the script was run.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
