Schema
======

* Category
  - name
  - timestamps
* Manufacturer
  - name
  - timestamps
* Product
  - category id (belongs_to :category)
  - manufacturer id (belongs_to :manufacturer)
  - chipset manufacturer id (belongs_to :chipset_manufacturer) - used for video
   cards
  - product name - the model of the video card or whatever
  - full name (just for easier access) - this will be manufacturer name + chipset name + model name
  - quick summary of specs?
  - pros, cons, bottom line
  - market release date 
  - total avg price range info
  - total avg rating info
  - total avg benchmark index info
  - score / "experience index"
  - is_prototype (maybe we can ascertain this automatically)
  - embeds_many products - if this is a prototype then it will be naturally linked to implementation products
  - embeds_many reviews
  - embeds_many specs (hash, variant)
  - has_many benchmarks
  - embeds_many prices
  - embeds_many photos
  - primary photo
  - timestamps
* Benchmark
  - belongs_to product
  - belongs_to review (optional)
  - name
  - date
  - description
  - score
  - units
  - timestamps
* ProductReview
  - title
  - rating
  - pros
  - cons
  - bottom line
  - date
  - url
  - avg benchmark
  - has_many benchmarks
  - timestamps
* ProductSpec
  - gpu
  - shader model
  - directx
  - (anything else, really)
* ProductPrice
  - merchant
  - prices over time (array)
    - date
    - amount
* ProductPhoto
  - url/filepath
  - caption
* User
  - email
  - password
  - (other fields)
* Configuration
  - user id
  - name
  - embeds_many products
  - timestamps