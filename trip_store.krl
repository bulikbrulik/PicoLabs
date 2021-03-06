ruleset trip_store {
	meta {
    		name "Track Trips"
    		description <<A first ruleset for single pico part 3>>
    		author "Austin Bolingbroke"
    		logging on
    		shares trips, long_trips, short_trips, __testing
    		provides trips, long_trips, short_trips
  	}
	global {

		trips = function() {
			ent:tripArr
		}

		long_trips = function() {
			ent:long_tripArr
		}

		short_trips = function() {
			ent:tripArr.difference(ent:long_tripArr)
		}

		 __testing = { "queries": [ { "name": "trips" },
                               { "name": "long_trips" },
                               { "name": "short_trips" } ],
                               "events": [ { "domain": "car", "type":"trip_reset" }]                      
                             }
	}

	rule collect_trips {
		select when explicit trip_processed
		pre {
			mileage = event:attr("mileage")
 			timestamp = event:attr("timestamp")
			trip = {"mileage": mileage, "timestamp": timestamp}
			all_trips = ent:tripArr.append(trip)
		}
		always {
			ent:tripArr := all_trips
		}
	}

	rule collect_long_trips {
		select when explicit found_long_trip
		pre {
			mileage = event:attr("mileage")
			timestamp = event:attr("timestamp")
			trip = {"mileage": mileage, "timestamp": timestamp}
			all_long_trips = ent:long_tripArr.append(trip)
		}
		always {
 			ent:long_tripArr := all_long_trips
    		}
  	}

 	rule clear_trips {
    		select when car trip_reset
    		pre {
      			empty_trips = []
      			empty_long_trips = []
    		}
    		always {
      			ent:tripArr := empty_trips;
      			ent:long_tripArr := empty_long_trips
    		}
  	}
  	rule generate_report {
  	  	select when car generate_report
  	  	pre {
  	  	  	eci = event:attr("sender_eci")
  	  	  	rcn = event:attr("rcn")
  	  	  	vehicle_id = event:attr("vehicle_id")
  	  	  	attributes = {"rcn": rcn,
  	  	  	"vehicle_id": vehicle_id,
  	  	  	"trips": ent:tripArr}
  	  	}
  	  	event:send({ "eci": eci, "eid": "send_report", "domain": "car", "type": "send_report", "attrs": attributes})
  	}
} 
