ruleset manage_fleet {
	meta {
		name "Manage Fleet"
		description <<A ruleset for Multiple Picos Part 1>>
		author "Austin Bolingbroke"
		use module io.picolabs.pico alias wrangler
		use module Subscriptions
		logging on
		shares vehicles, get_all_vehicle_trips, last_five_reports, __testing
  	}
	
	global {
		__testing = {
			"queries": [
				{"name": "get_all_vehicle_trips"},
				{"name": "vehicles"},
				{"name": "last_five_reports"}
			],
			"events": [
           			{
					"domain": "car",
               				"type": "new_vehicle",
               				"attrs": ["vehicle_id"]
           			},
           			{
               				"domain": "car",
               				"type": "unneeded_vehicle",
               				"attrs": ["vehicle_id"]
           			},
           			{
                			"domain": "car",
                			"type": "start_report"
           			},
           			{
                			"domain": "car",
                			"type": "clear_reports"
           			}
       			]
    		}
		
		vehicles = function() {
      			ent:vehicles
    		}
	}

	rule create_vehicle {
    		select when car new_vehicle
    		pre {
      			vehicle_id = event:attr("vehicle_id")
      			exists = ent:vehicles >< vehicle_id
      			eci = meta:eci
    		}
    		if exists then
      			send_directive("vehicle_ready")
        		with vehicle_id = vehicle_id
    		fired {
    		} else {
      			raise pico event "new_child_request"
        		attributes { "dname": nameFromId(vehicle_id),
                     	"color": "#006400",
                     	"vehicle_id": vehicle_id }
    		}
  	}

	rule pico_child_initialized {
    		select when pico child_initialized
    		pre {
      			vehicle = event:attr("new_child")
      			vehicle_id = event:attr("rs_attrs"){"vehicle_id"}
      			eci = meta:eci
    		}
    		event:send({ "eci": vehicle.eci, "eid": "install-ruleset",
     			"domain": "pico", "type": "new_ruleset",
     			"attrs": { "rid": "Subscriptions", "vehicle_id": vehicle_id } } )
    		event:send({ "eci": vehicle.eci, "eid": "install-ruleset",
      			"domain": "pico", "type": "new_ruleset",
      			"attrs": { "rid": "extra_trips", "vehicle_id": vehicle_id } } )
    		event:send({ "eci": vehicle.eci, "eid": "install-ruleset",
      			"domain": "pico", "type": "new_ruleset",
      			"attrs": { "rid": "trip_store", "vehicle_id": vehicle_id } } )
    		event:send({ "eci": eci, "eid": "subscription",
      			"domain": "wrangler", "type": "subscription",
      			"attrs": { "name": subscriptionFromId(vehicle_id),
                 	"name_space": "car",
                 	"my_role": "fleet",
                 	"subscriber_role": "vehicle",
                 	"channel_type": "subscription",
                 	"subscriber_eci": vehicle.eci} } )
    		fired {
      			ent:vehicles := ent:vehicles.defaultsTo({});
      			ent:vehicles{vehicle_id} := vehicle
    		}
  	}


