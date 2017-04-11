ruleset track_car_trips {

  global {
    long_trip_length = 500;
  }

  rule process_trip {
    select when car new_trip mileage "(\d*)" setting(mileage)
    pre {}
    {
      send_directive("trip") with
        trip_length = mileage
    }
    fired {
      raise explicit event "trip_processed"
        attributes event:attrs()
    }
  }

  rule find_long_trips {
    select when explicit trip_processed mileage "(\d*)" setting(mileage)
    always {
      raise explicit event "found_long_trip"
        attributes event:attrs()
      if (mileage > long_trip_length);
    }
  }
}