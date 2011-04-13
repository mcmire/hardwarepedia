TODO
====

* Write a script that hits the main entry points for motherboards, CPUs, graphics cards, and hard drives from Newegg and pulls the following data:
  - Product type
  X Name of manufacturer
  X Name of product
  X Picture
  X Price
  X Avg rating
  X URL
  X Specs (this will of course be dependent on each product type)
    - Still need to be converted to use Spec model
  - Date/time added
  - Date/time last updated
  - Chipset manufacturer / model
* Add links to reviews
  - Have to think about this one, but my gut is to look for key entrypoints on, say, Maximum PC, and then use Readability to isolate the content, and then use libots (libots.sf.net), which is what tldr.it uses, to summarize the content so we can stick it on the page (or just use the tldr.it API, but I'd rather do it myself :P)
  - As automatically finding reviews for products, well, it seems a naive solution would be to just go through the chipsets we already have in the system and then search for them... (Peter Cooper would know a thing or two about this)
* We will still be missing the following information which we will have to fill in manually:
  - Market release date
  - Benchmarks for video cards
  - Links to reviews and mentions