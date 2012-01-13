Bar Napkin - iphone app prototype
=================================

API - http://bn.ztest.ekingery.com

### What?

This is a prototype put together as a learning experience in iOS development.

The mockups directory contains the project plan and design prototypes.

The iphone directory contains an iphone app which will detect the user's current geo coordinates, make a call to the API to pull the closest venues, and display them in list format. 

The app_engine_api directory contains the python source code for the app engine API (thank you, captain obvious). The API uses the [geomodel library](http://code.google.com/p/geomodel/) and the built in app engine python data store. The API will return the 10 closest venues to the parameter coordinates. [Samples](http://bn.ztest.ekingery.com/get_nearby_venues?41.887618&-87.634566) [here](http://bn.ztest.ekingery.com/get_nearby_venues?41.901&-87.6796).


### Todo
1. Launch Bar Napkin
2. ? 
3. Profit
