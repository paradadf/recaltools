Script to facilitate the use of [sselph's scraper](https://github.com/sselph/scraper/releases).

Place fastscraper[.bat] on your rom's root directory. The script will automatically download/update the scraper if needed.  
Windows users need fastscraper.bat  
Linux, macOS or FreeBSD users need to set appropriate permissions: `chmod u+x ./fastscraper`

**Don't forget to set your [ScreenScraper](http://screenscraper.fr/) *username* and *password* to scrape faster!!!**

I used the following commands to mount recalbox's share partition and scrape over the network. Scraping directly from the Pi is very slow! (Tested on Ubuntu)

* First prepare the mount point (unless it already exists):  
`sudo mkdir /mnt/recalbox`

* Then mount the network share:  
```
sudo mount -t cifs //<RECALBOX IP>/share/ /mnt/recalbox -o username=root,password=recalboxroot,uid=1000,gid=1000
```

* To unmount the share just do:  
`sudo umount /mnt/recalbox`
