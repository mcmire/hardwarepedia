Schema
======

* Category
  - name
  - timestamps
* Manufacturer
  - name
  - official url
  - timestamps
* Product
  - product id - if this is a chipset then it will be naturally linked to implementation products
  - category id (belongs_to :category)
  - chipset manufacturer id (belongs_to :chipset_manufacturer) - used for video cards and motherboards; for instance, a manufacturer could be Sapphire while the chipset manufacturer is Nvidia
  - manufacturer id (belongs_to :manufacturer)
  - product name - the model of the video card or whatever
  - full name (just for easier access) - this will be manufacturer name + chipset name + model name
  - official url - this is on the manufacturer's page
  - buy urls - urls to buy the product
  - mention urls - urls that have reviews, benchmarks, from online sites or e-zines...
  - quick summary of specs?
    - pros, cons, bottom line, that sort of thing
  - market release date 
  - total avg price range info (value calculated from embedded prices)
  - total avg rating info (value calculated from embedded ratings)
  - total avg benchmark index info (value calculated from embedded benchmarks)
  - score / "experience index" (value calculated from different factors)
  - is_chipset
  - embeds_many reviews
  - embeds_many specs
  - embeds_many ratings - this is not a log of ratings, simply the current ratings from different sites
  - has_many benchmarks
  - embeds_many prices - this is not a log of prices, it's simply the current prices from different sites
  - embeds_many photos - primary photo is just the first photo in the list
  - timestamps
* Benchmark
  - belongs_to product
  - belongs_to review - optional
  - name
  - date
  - description
  - score
  - units
  - timestamps
* ProductReview
  - product id
  - title
  - rating
  - pros
  - cons
  - bottom line
  - date
  - url
  - avg benchmark
  - has_many benchmarks
  - time retrieved
* ProductSpec
  - product id
  - name
  - value
  - type - it could be "string", "number", etc. or more like units, so "dpi" or "GHz"; basically this is used by the system for comparison with other values
* ProductSpecType - this isn't backed by a collection, it just holds the possible types and the comparison logic for them
* ProductPrice
  - product id
  - merchant_id (this doesn't relate to a collection, just a ActiveHash basically)
  - date
  - amount
  - time retrieved
* ProductPhoto
  - product id
  - url/filepath
  - caption
  - timestamps
* ProductRating
  - product id
  - url
  - raw_value (String) - as different sites store ratings in different ways; this is how they put it
  - value (Float) - this is the interpreted value, on a scale from 1 to 10
  - time retrieved
* User
  - email
  - password
  - (other fields)
* Configuration
  - user id
  - name
  - embeds_many products
  - timestamps
* ProductLog
  - url
  - product id - the log will be indexed by product id for fast retrieval
  - manufacturer id
  - price
  - rating
  - specs (Hash)
  - reviews (Array)
  - photos (Array)
  - ...
  - date of retrieval