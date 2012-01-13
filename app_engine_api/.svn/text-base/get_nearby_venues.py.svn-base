from google.appengine.ext import db

from geo.geomodel import GeoModel

import os
import models

class Venue(GeoModel):
	name = db.StringProperty()

# parse_query_string(qs) - does what you think it does
# 	only accepts -nnn.nnnnnn|-nn.nnnnnn
# 	only need to accept up to 5 significant digits (~ 1 meter accuracy)
# 		http://en.wikipedia.org/wiki/Decimal_degrees
def parse_query_string(qs):
	if len(qs) > 25: # qs should never be more than 25 chars (actually 22)
		print "unacceptable query string(1)"
		raise SystemExit

	lat_lon = qs.split('&')

	if not 2 == len(lat_lon):
		print "unacceptable query string(2)"
		raise SystemExit

	try:
		lat = float(lat_lon[0])
		lon = float(lat_lon[1])
	except ValueError:
		print "unacceptable query string(3)"
		raise SystemExit

	if lat < -90 or lat > 90 or lon < -180 or lon > 180:
		print "unacceptable query string(4)"
		raise SystemExit

	return db.GeoPt(lat,lon)



#################
# start the show
print 'Content-type: text/plain'
print ''

users_geopt = parse_query_string(os.environ['QUERY_STRING'])
#[DEBUG] - my apt. ~ (41.901,-87.6796), sb courthouse (34.423453, -119.701771)

current_location = Venue(location=users_geopt, name='current1')

# This may be good to tune / accept input for
# depends on server performance vs. iphone implementation
max_dist = 1609 * 30  # geomodel accepts distance in meters (~1600 / mi)

# proximity query
results = current_location.proximity_fetch(
             current_location.all(),  #[ek] extensible - can still query here!
			 users_geopt,
             max_results=5,
             max_distance=max_dist)


if not results:
	print "no results within 30 miles"
	raise SystemExit


for venue in results:
	print "%f,%f,%s" % (venue.location.lat,venue.location.lon, venue.name)

