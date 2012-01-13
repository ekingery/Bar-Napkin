from google.appengine.ext import db
from google.appengine.tools import bulkloader

import models

# loads data from the sample data csv, assigns geo point mojo, 
# stores in app engine python datastore
class VenueLoader(bulkloader.Loader):
	def __init__(self): 
		def lat_lon(s): 
			lat, lon = [float(v) for v in s.split('|')]
			return db.GeoPt(lat, lon)

		# want an accuracy of 8 (address level)
		bulkloader.Loader.__init__(self, 'Venue',
			[('name', str), ('location',lat_lon), ])

	def handle_entity(self, entity):
		entity.update_location()
		return entity

loaders = [VenueLoader]
