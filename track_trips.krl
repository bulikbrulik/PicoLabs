ruleset track_trips {
  meta {
    name "Track Trips"
    description << Track Trips ruleset for part 1 of the Single Pico CS 462 lab >>
    author "Austin Bolingbroke"
    logging on
    sharing on
  }

  rule process_trip {
    select when echo message mileage "(.*)" setting(mileage)
    send_directive("trip") with
      trip_length = mileage
  }
}