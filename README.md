# Showdates

Since I shut down this project I decided to open source the code. Do whatever you want with it. I don't have the time to get the sync-stuff up and running again.

It needs a mysql database. The structure of it I added to an open issue.

## Development

Run `script/server` to launch Showdates locally.

MySQL locally: `mysql.server start`

## Server

After a reboot, you might have to run `bundle exec thin restart -C /etc/thin/showdates.me.yml` to get everything back up.

## Running background jobs

* Launch redis `redis-server`
* Launch Sidekiq `bundle exec sidekiq -r ./workers.rb -e development`
