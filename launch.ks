//hellolaunch

//First, we'll clear the terminal screen to make it look nice
CLEARSCREEN.

//Next, we'll lock our throttle to 100%.
LOCK THROTTLE TO 1.0.   // 1.0 is the max, 0.0 is idle.

//This is our countdown loop, which cycles from 10 to 0
PRINT "Counting down:".
FROM {local countdown is 3.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
    PRINT "..." + countdown.
    WAIT 1. // pauses the script here for 1 second.
}

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
SET DESIRED_APOAPSIS TO 90000.
SET MAX_TURN_DEGREES TO 45.
SET MAX_TURN_ALTITUDE TO 10000.
SET MYSTEER TO HEADING(90,90).
LOCK STEERING TO MYSTEER. // from now on we'll be able to change steering by just assigning a new value to MYSTEER
UNTIL SHIP:OBT:APOAPSIS > DESIRED_APOAPSIS {

    SET CURRENT_ANGLE TO 90 - ((SHIP:ALTITUDE / MAX_TURN_ALTITUDE) * MAX_TURN_DEGREES).
    IF CURRENT_ANGLE < 45 {
        SET CURRENT_ANGLE TO 45.
    }.
    SET MYSTEER TO HEADING(90,CURRENT_ANGLE).
}.
PRINT "90km apoapsis reached, cutting throttle".

//At this point, our apoapsis is above 100km and our main loop has ended. Next
//we'll make sure our throttle is zero and that we're pointed prograde
LOCK THROTTLE TO 0.

SET MYSTEER TO HEADING(90,0).

UNTIL SHIP:OBT:PERIAPSIS > SHIP:OBT:APOAPSIS {
    print SHIP:OBT:POSITION AT(0, 15).
    print SHIP:OBT:VELOCITY AT(0, 16).
    print SHIP:OBT:TRANSITION AT(0, 19).
    print SHIP:OBT:EPOCH AT(0, 20).
    print SHIP:OBT:TRUEANOMALY AT(0, 21).
    print SHIP:OBT:MEANANOMALYATEPOCH AT(0, 22).
    print SHIP:OBT:LAN AT(0, 23).
}.

//This sets the user's throttle setting to zero to prevent the throttle
//from returning to the position it was at before the script was run.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
