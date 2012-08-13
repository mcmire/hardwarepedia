# TODO

* When Sidekiq is done processing a category there are 7 or so stragglers which
  take ~70s to complete -- I think they are just getting caught in the back of
  the queue -- maybe not something to worry about though

* Some prices are ending up as $99,999.00 ... why is that??
* Add a way to hit an endpoint to kick off a job
  * Need to keep delayed job going in the background
  * Which means the scraper needs to be a job

* Get product page working
* Calculate a score for each product based on price + ratings
* Sort by score
* Search by spec
  * Individual sort types for every spec

* Scrape benchmarks
* Add price graph
* Scrape individual Newegg reviews
* Scrape individual Amazon reviews
* Scrape other sites like GPUReview, etc.
