Brainstorming
=============

Goal
----

So what's the goal of the site? Primarily, it's to bring as much information to you (and then give you the power to do what you want with it) so you can make a well-informed decision about your purchase, so you can fulfill *your* goal of building a new computer or upgrading one you might already have.

Another goal is to house data about every piece of computer hardware that's ever existed, to place it in a context, and to intelligently be able to present data about it without overwhelming you.

User stories
------------

Alan wants to put together a complete gaming system for about $1000 that will run Crysis fairly comfortably, and fly through all other games. At the same time, he is hoping to get the best deal on each of the components he will buy. He is also hoping to purchase all of the items at Newegg, so he is only interested in items that are available on Newegg. He is also not against specials or combos if he can take advantage of them.

Andrew is like Alan -- he wants to purchase his items online, but he doesn't mind which vendors he gets them from (as long as they are reputable). So he isn't as concerned with availability.

Arthur is like Alan, but he wants to purchase his items from a local electronics superstore (e.g. Fry's). He knows our site is probably not going to be able to know which items are available at Fry's so he has to constantly go back and forth between Fry's web site and our site.

Brent is looking for a new 24" widescreen monitor to replace his aging 19" standard monitor. He doesn't mind where it comes from (as long as it's fairly reputable), he just wants to get the best deal.

Christian built a computer 6 months ago and wants to check up on what new stuff has come out since then (he might be interested in replacing something).

Cary started to put together a list of components but saved it away since he didn't have the money. Now he does but he's afraid that something newer may have come out since then, so he wants to see if there's anything better out there he can update on his list.

Features
--------

* friendly urls for everything - even searches - bookmarkability
* product database mined from various sources + user-editable - full specifications and everything
  - store chipsets and cards based on that chipsets
  - we can screenscrape, but really here we're depending on other people to keep the data up to date - people-powered
    ^ wiki-like: view previous revisions, rollback to a previous revision
    ^ anybody can edit information but allow people to sign up too?
  - "find products with same or better specification" (see hardware.info)
* autoupdated benchmarks pulled from various sources (maybe not user-editable)
  - store the testbed that was used in the benchmark so we have a point of reference
* autoupdated reviews pulled from various sources + user-editable
  - just want to get the main gist of the article, maybe the pros and cons and conclusion, and then you can read the full review if you want
  - also show rating next to summary, and date of review
  - each review creates connections between one or more products and sits at a specific point of time - building up reviews is like pinning a piece of paper to a wall to create a sort of timeline/tapestry
  - don't make it possible for people to add their own reviews on our site - this site is only for aggregation
* an autoupdated feed of "mentions" or "sightings" - pull from a list of sites + newegg comments + amazon comments + epinions? + twitter?
* search is everything
  - a power search with even more criteria than newegg, but not to the point of being overwhelming - maybe start out with the most important specs, and then if you want to add any other kinds of criteria you can
  - results and/or remaining search filters change as you select/change a filter
  - sort by rating, popularity (based on..?), price, performance (based on benchmarks) .. ability to combine sorts
  - search by availability, in stock, price, has benchmarks, has reviews
  - ability to save searches
* different graphs
  - show a product in context of other products in the same arena
  - plot avg price over some performance statistic (avg benchmark score, etc.) to easily determine value
  - project prices in 3mo, 6mo, 1yr, for those who like to wait
* brain-dead simple comparison
  - the system figures it out for you
  - intelligent sort by specification
  - show me the thing with the best value
  - give me a plot line of the clock speed of these products
  - when comparing a lot of products, layout is similar to logitech (horizontal scroll) - also stick the column headers on the left side of the screen when you scroll right
  - remove an item from the comparison table via ajax
  - remove specs you don't want to look at via ajax
  - save comparisons?
* autoupdated prices from vendors like best buy, newegg, amazon, directron, tigerdirect, frys.com, buy.com, zipzoomfly (some api, most screenscrape) - doesn't force you into anything
  - also show if the item is in stock or available or not
* smart about the data types - show X or check for boolean values, sliders for numeric values, etc.
* configurations
  - always store configuration in a temporary stash (kind of like a "cart" or "wishlist")
  - save and share configurations
  - when a configuration is saved it stores a "snapshot" of product data so that if prices change in the meantime it isn't shown if the user comes back and views the configuration later (or it does and we show the difference)
  - users can also enter benchmarks they've run on their configurations (3dmark, etc.)
  - automatic scoring of saved configurations?
  - I wonder if this should be a firefox extension? that way you could add a newegg product to your cart and a product from amazon or another vendor. store data locally in a cookie or sqlite database (firefox 3.5)
* photos of products - user-editable
  - when adding a new product, go out and find some images and give the user a selection
* calculate "experience index" or price/performance ratio for products (to help with sorting/valuing)
  - this is tough as this would be based on benchmarks which are variable
* "see motherboards that will support this socket"
* not a guided tour - you decide which component you're starting with
* release schedule of primary manufacturers - need to be updated manually
* guides - step-by-step on building a computer, what is ram timing? should i go intel or amd?
  - it's critical this doesn't appear like about.com or ehow.com or brighthub or anything like that. how do we make it look reputable? think github guides + wikipedia + a tom's hardware article or something
* should we also store pre-built pc's for recommendation purposes? (ibuypowerpc and stuff like that)
* how often is this product paired with this other product? how often are these three products paired?
* open information: api's for fetching all the product data, including prices and benchmarks - so people can use it in mashups

What's wrong with other sites?
------------------------------

* There's no site that lists which cards Nvidia and ATI have released - useful if you don't want the latest and greatest, but maybe the previous generation which may not be quite so expensive (maybe this wouldn't be as needed if we just highlighted the release date of products in benchmarks or score sheets)
* Benchmarks are spread out all over the place. You could go around and compare benchmarks manually for days. The best list is the one Tom's Hardware has, but it's useless because you can't sort the list or display the information in another format. Also, it doesn't list pricing information, which is actually more important than raw performance.
* The numbers in benchmarks begin to become meaningless after a while without some sort of basis. What about this chipset makes it score higher than this other chipset? What about this chipset that makes it score higher than the same chipset (but different card)? You need to be able to organize benchmarks based on how many cores this CPU has, or whether or not this card is in SLI, or maybe by year, or by even chipset or manufacturer.
* In fact you have all of these statistics floating around, but benchmarks (based on simulated scores) are really the only graph that's out there. What about a graph of clock speed? What about a graph of prices?
* Sites like Tom's Hardware or magazines like Maximum PC constantly throw around terms like stream processors, Shader Model 5.0, contrast ratio, and R700 chipset. But rarely do they stop and explain what the hell they're talking about. Sometimes it's just good to take a break and go to a place where all this stuff is explained.
* No one likes reading through a hundred reviews. You end up jumping to the very end and reading the conclusion before you dive into the benchmarks, and then you go back and figure out why certain benchmarks are higher. Is this product good or bad? Should I add it to my list or not? And why?
* Comparing products using Newegg sucks. This is probably the same for all the shopping sites out there. First, if you're looking at 25 products there's no way to select all of them at once. Second, when you're on the comparison page, Newegg lists the products you've selected side-by-side, with all the criteria those products have in a giant table that scrolls off the side of the screen. If you really want to compare these 25 products thoroughly, now you have to go through the first criterion and find out which one is the winner, and then repeat this for the other 99 criteria, and then tally up all the winners and pick the one that wins the most criteria (including price). Now this is assuming you care about all 100 criteria, but you probably don't because you've probably filtered down the list by some criteria already. And so you end up having to go back to power search and filter down the list further until you have a manageable list. So it's just a big giant mess, and it would help if you could manipulate the data any way you want to. And maybe save your searches.
* Maximum PC's reviews are useless because sif you're just scanning through a list of reviews for different products and you want to quickly know the rating of each product, well tough luck, you'll have to click on a review and scroll down to the bottom (this is because reviews are just basically blog posts).
* You can get a pretty good idea what people think about certain products from Newegg and Amazon reviews, but unless you know about a lot of sites and you go to them constantly you might not be able to get a full idea of what people are *recommending*. For instance, what are the reliable brands and things like that. You shouldn't take one person's word for it but this at least gives you more starting places.
* There's no place that lets you sort by rating or popularity *and* price at the same time. This is a no-brainer, people :P
* When you have multiple places you're going for information, you really need to write stuff down so that you have all the pieces of information in one place and you can make a good decision. You might need to write stuff down anyway but at least if all the information were in one place to begin with you wouldn't have to hop around as much.
* There's no site that recommends configurations that already exist. It may also be useful to know how often this component is paired with this other one just as another way of deciding based on popularity.
* Search sucks overall. Sites like Shopping.com, DealGrabber, Buy.com, or even Amazon don't really know how to do power search for computer components because that's not their specialty. Even online stores like Best Buy don't know how to do it either. The site that has the most useful power search is Newegg, but even it could be improved. For instance, some of of the search criteria may conflict with each other. Let's say [you're searching for video cards][newegg_vc_search]. If you scroll down, you'll notice pixel pipelines and stream processors are two of the criteria. However, it doesn't make sense to search by both, because pixel pipelines are present in DX9-supported chips and stream processors are present in newer, DX-10 supported chips. It also wouldn't make sense to search for DX7 and stream processors. So ideally, if you checked a box, it would look at all the matching search results and then remove any remaining boxes that do not apply to the results. Now the drawback to this approach is, it slows down your experience; the user would have to wait after picking each criterion, and unless we really speed up the application, you may have to show one criterion at a time to prevent the user from going too fast. But, it guarantees that you're getting the results you want and prevents you from having to come back to the power search page. The other thing is, some of the criteria might be better presented. For instance, the number of stream processors. Well, you could have a list of checkboxes, but most people aren't going to say, "I want a card with 16, 64, or 128 processors", they're going to say "I want a card with between 64-128 processors" (assuming they really care about that). So you could use a slider (with two endpoints) for that and that would be more compact. This would involve any criterion that feels like a number, so things like stream processors, resolution, number of USB ports, DDR type, etc.
* The other thing about search is that no place offers a way to save your search. Let's say you've done some complicated search, but you haven't made a decision yet. Well let's you come back a month later. You're not going to be able to remember your search; you'll have to start all over again, or I guess you could bookmark it, but that's stupid. So there should just be a way to give it a name and save it to your account (or save it to cookie if you don't want to register).
* TestFreaks is interesting, but I don't really know how they compute their "Freak Score" (alright, it's listed in the FAQ), they don't summarize their reviews, the user reviews are not pulled from enough sources, the merchants are too generic, there isn't enough data yet, and search is virtually non-existent. And the design isn't tight enough, there's no personality. But, some of the data is user-editable which is nice.
* Retrevo is very interesting, it has a unique way of presenting price over rating, search is very comprehensive and easy to filter down, it shows an average rating, its analysis of the products look kind of intelligent - it's able to determine whether a product has reached its prime or is antiquated, able to determine whether something really is a good value, it groups variants together into one product. It is in fact fairly easy to navigate. But, it isn't really tailored for computer builders. And it's not user editable, and I have no idea how they calculate some of their stuff.
* ConsumerSearch.com has a really nice design and is very easy to navigate. I like how there isn't a lot of magic going on, just well-written, plain-English copy for each of the products in their system and even some guides for each category that show you what to look for in the product you're looking for. They even have a "review" of each review that they looked at, which sounds confusing but is actually quite nice. So for things like computer mice, laptops, netbooks, etc., it's actually not a bad resource. But, it doesn't seem like they have a lot of products in their system (only the top ones), and there's no power search, and it seems like the information just isn't updated enough (for instance, the section on video cards hasn't been updated in 2 years). And of course the information isn't open.
* GPUReview.com is great if you just want to spot-check a product you already have in mind. You get the specs for a chipset in a nice, compact format, you can "overclock" a chipset and see how it would affect the specs, you can see all the cards that are based on that chipset with specs and prices, you have reviews, comments, it's easy, it's clean. But, I didn't end up using this site that much. There's no power search so if you don't know what you're looking for already it's kind of useless. Some of the reviews aren't reputable, it just seems to be from all over the place. In fact the list of reviews isn't very useful because you have to click on one to read it, so there's no way to tell how good of a card this is just by looking at it. You can only compare two chipsets at the same time so that's kind of stupid. The list of cards based on this chipset isn't very useful because I don't think that's how I did my search, I didn't start with a chipset and then look at all the cards under it. Well, you can sort by clock speed, that's nice. But even so I like starting with benchmarks because specs don't mean that much to me. But I think the thing that prevents it here is that the cards themselves aren't first-class things like the chipsets are, which is useless because the chipsets themselves aren't being sold. Maybe have to think about this one some more.
* wikio.com/shopping has a nice design but it doesn't have very many features. There's no way to filter by price, the merchants aren't reliable so the prices are completely skewed. Just no.
* techwiki.hardwarecanucks.com (I know, it's low-hanging fruit) looks like it needs a lot of love too. Search doesn't work right, the data that's on each page is simple but it's not very standardized, the reviews don't list the date next to them or any other information other than a summary. You can update all the information if you register, so that's nice, but it doesn't really look like anyone uses this or whoever maintains it isn't really around.
* hardware.info has actually got the right idea. They have a lot of products in their system. They have a lot of price information. A lot of their products are tested so they have benchmark information. You can take any benchmark and get a graph of surrounding products. Perfect. The test configuration is clearly listed with the date span it was used, awesome. Oh, they even have the i5 in there, nice, they've got their stuff updated. When you're looking at a benchmark graph you can instantly compare all of the products listed in the graph, wow. Let's see what happens if we compare 56 products at the same time. Oh nice, it highlights the winning specs, great. And it seems to be smart about the data types too (check or X for boolean values). And lets you remove a product from the comparison at will. Only thing I wish it did is not extend the comparison table past the edge of the screen. I also wish when you remove a product from the table it just does it via Ajax, that really slows things down. Oh and if you could remove a spec that you don't care about. Okay, wow, I guess there's just not any way to make comparing 56 products easy. Anyway, the search is kind of neat, it automatically updates the search results as you change a filter, and it provides a slider for numeric values. On the other hand... you go look at the product specifications, they have a lot of details, which is nice, but then it makes comparison a bitch. And then you go to search, and you only have like six things to search by. Ugh, that's just useless. Anyway, I see they've got a way for me as a user to add my own configurations -- and any benchmarks I've done too, that's neat. They also have guides, which seem like they're updated frequently (at least, they just were updated). One other cool thing it does too is if you're looking at a product it shows you user configurations with that product, that's kinda neat. Oh yeah, and they give a lot of reviews in a clear layout. But, they don't summarize any reviews. And a lot of the reviews are duplicates of each other, what the heck? Not much quality control.. that's not nice. Oh, and they don't incorporate Amazon or Newegg reviews, but maybe that's not so important until you get down to like 3 possibilities, and then you can just switch over to Newegg. I think the deal breaker for this though is that it's maintained by non-English speakers and some of the summaries and stuff aren't totally in English. It's not huge but it is kind of annoying. But, you can definitely get the sense who's maintaining the site and it looks like these guys know their stuff. And I really, really like this site. I think the fact they do tests themselves is really the kicker, that really gives them a lot of credibility and makes all their benchmarks consistent. Maybe we should screenscrape their site ;)

[newegg_vc_search]: http://www.newegg.com/Product/PowerSearch.aspx?N=2010380048&SubCategory=48&GASearch=3