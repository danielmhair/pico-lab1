ruleset track_trips {
  meta {
    name "Track Trips"
    description <<
A first ruleset for Part 2 of pico lab
>>
    author "Daniel Hair"
    logging on
    shares __testing
  }
  
  global {
    __testing = { "queries": [ { "name": "__testing" } ],
                  "events": [ { "domain": "echo", "type": "process_trip", "attrs": [ "mileage" ] } ]
                }
  }
  
  rule process_trip {
    select when echo message
    pre{
      mileage = event:attr("mileage").defaultsTo(ent:mileage,"use stored name")
    }
    send_directive("trip") with
      trip_length = mileage
  }
}