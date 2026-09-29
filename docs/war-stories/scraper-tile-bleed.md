# A −81 % "discount" that didn't exist

**Area:** web scraping · data quality

## Symptom
Right after the first nightly scrape of a pharmacy chain's catalogue (for the household deals site), its biggest offers included a 50 g tea at −81 %, and several unrelated products all with exactly the same "old price".

## Investigation
- Checking the product's own page showed a normal price and no crossed-out price at all.
- The products sharing that old price were each the **last product on a listing page**.
- The parser split the page into product tiles on the tile's opening tag; the last tile therefore ran on to the end of the page - where other products (a "recommended" strip) had their own old prices, and the first one found was taken.

## Root cause
Parsing by "from this tile's start to the next tile's start" silently assumes there *is* a next tile.

## Fix
Prices are read only from the tile's own price box, bounded to that block. The same class of bug was checked for in the other shops' parsers (theirs were already bounded), and a re-scrape with the fixed parser replaced the bad values.

## Lesson
Sanity-check the extremes, not the averages: the top discounts are where a parsing bug shows first. Spot-checking the biggest offers against the live site after every new scraper is now part of the routine.
