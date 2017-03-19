ruleset trip_store {
  meta {
    name "Trip Store"
    description <<
Ruleset for Part 3 of pico lab
>>
    author "Daniel Hair"
    logging on
    shares __testing, long_trip, trips, long_trips, short_trips
    provides trips, long_trips, short_trips
  }
  
  global {
    __testing = {
        "queries": [ { "name": "__testing" } ],
        "events": [ { "domain": "echo", "type": "message", "attrs": [ "mileage" ] } ]
    }

    empty_trip = { "_0": { 
        "mileage": "0".as("Number"),
        "timestamp" : timestamp 
    } }

    long_trip = "200".as("Number")

    empty_long_trip = { "_0": {
        "mileage": "0".as("Number"),
        "timestamp" : timestamp
    } }

    empty_ids = { "_0": {
        "trip_id": "0".as("Number"),
        "long_trip_id" : "0".as("Number")
    } }

    trips = function() {
        ent:trips
    }

    long_trips = function() {
        ent:long_trips
    }

    short_trips = function() {
        trips = ent:trips.defaultsTo(empty_trip, "short_trips function -- trips re-initialized")
        only_short = trips.filter(function(trip){
            trip{["mileage"]} < long_trip
        })

        only_short
    }
  }
  
  rule collect_trips {
    select when explicit trip_processed
    pre {
        mileage = event:attr("mileage").klog("FROM collect_trips -- Mileage passed in: ")
    }
    always {
        ent:trips := ent:trip.defaultsTo(empty_trip, "Initialized trips to an empty trip")
        ent:trip_ids := ent:trip_ids.defaultsTo(empty_ids, "Initialized ids")
        ent:trip_ids{["_0", "long_trip_id"]} := ent:trip_ids{["_0", "long_trip_id"]} + 1
        ent:trips{[ent:trip_id{["_0", "trip_id"]}, "mileage"]} := mileage
        ent:trips{[ent:trip_id{["_0", "trip_id"]}, "timestamp"]} := time.now()
    }
  }

  rule collect_long_trips {
    select when explicit found_long_trip
    pre {
        mileage = event:attr("mileage").klog("FROM collect_long_trips -- Mileage passed in: ")
    }
    always {
        ent:long_trips := ent:long_trips.defaultsTo(empty_long_trip, "Initialized long_trips to an empty long_trip")
        ent:trip_ids := ent:trip_ids.defaultsTo(empty_ids, "Initialized ids")
        ent:trip_ids{["_0", "long_trip_id"]} := ent:trip_ids{["_0", "long_trip_id"]} + 1
        ent:long_trips{[ent:long_trip_id{["_0", "long_trip_id"]}, "mileage"]} := mileage
        ent:long_trips{[ent:long_trip_id{["_0", "long_trip_id"]}, "timestamp"]} := time.now()
    }
  }

  rule clear_trips {
      select when car trip_reset
      always {
        ent:trips.klog("Clearing the following logs: ")
        ent:trips := empty_trip
        ent:long_trips := empty_long_trip
        ent:trip_ids := empty_ids
      }
  }
}