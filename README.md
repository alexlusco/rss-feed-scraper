# Google Alert RSS Feed Scraper

This repository contains two versions of a simple Google Alert RSS feed scraper written in R. The scrape will loop over a list of multiple Google Alert RSS feeds and append the unique results only into a Google Sheet. As written, the script relies on a Google spreadsheet with two sheets - one called IDs the other Alerts - using the titles of the articles as the unique IDs for duplication filtering. 

There are two versions: ```scrape_local.R``` and ```scrape_cloud.R```. The latter is intended to be run on a cloud machine (I use Heroku). If you are planning to set this up on Heroku or another cloud-based platform, you can deploy it as a container using the compatible Docker app I created [here](https://github.com/alexlusco/docker-r-scrape-tools).

![](https://github.com/alexlusco/rss-feed-scraper/blob/main/results_image.png)
