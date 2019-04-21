// Perform a suicide burn such that you stop thrusting as soon as you reach the ground.
// todo do the math
SET MYTHROTTLE TO 1.0.
LOCK THROTTLE TO MYTHROTTLE.   // 1.0 is the max, 0.0 is idle.

SET MYSTEER TO SHIP:SRFRETROGRADE.
LOCK STEERING TO MYSTEER. // from now on we'll be able to change steering by just assigning a new value to MYSTEER

WAIT UNTIL SHIP:ALTITUDE < 100 OR SHIP:VELOCITY:MAG < 10

SET MYTHROTTLE TO 0.0.
