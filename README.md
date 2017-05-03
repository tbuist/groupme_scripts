# scripts for groupme
* ```sudo gem install OptionParser httparty```
----
## Random avatar (./change.rb -r) - set group avatar to random url from config/urls.list
----
## Random groupname (./change.rb -g) - generate random groupname
* randomly grabs a line from config/names.list, config/adjectives.list, and config/bodyparts.list
* sets groupname to "{name} has [a/an] {adjective} {bodypart/s}"
* change format/add wordlists
----
## Specific avatar (./change.rb -s IMAGE_URL) - not implented
* reset group avatar to the given IMAGE_URL
----
## Upload images (./upload)
* uploads images from /config/pics/* to i.groupme and appends to config/urls.list
## format of config.txt:
```
token=exampleofaninvalidtoken
group_id=12345678
```
* Use dev.groupme.com to get your api token