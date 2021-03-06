ruleset track_trips2 {
  	meta {
    		name "Track Trips2"
    		description <<Track individual pico trips>>
    		author "Austin Bolingbroke"
    		logging on
    		shares __testing
  	}

  global {
    long_trip = 500
    __testing = { "events": [ {"domain": "car", "type": "new_trip", "attrs": ["mileage"]}]}
  }

  rule process_trip {
    select when car new_trip mileage re#(.*)# setting(mileage)
    send_directive("trip") with
        trip_length = mileage
    always {
      raise explicit event "trip_processed"
      attributes { "attributes": event:attrs(), "timestamp" : time:now(), "mileage" : mileage}
    }
  }

  rule find_long_trips {
    select when explicit trip_processed
    pre {
      mileage = event:attr("mileage")
      timestamp = event:attr("timestamp")
    }
    fired {
      raise explicit event "found_long_trip"
        attributes{"mileage": mileage, "timestamp": timestamp}
      if mileage.as("Number") >= long_trip
    }
  }
}