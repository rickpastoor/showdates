# Showdates

Run `script/server` to launch Showdates locally.

MySQL locally: `mysql.server start`

## Server

After a reboot, you might have to run `bundle exec thin restart -C /etc/thin/showdates.me.yml` to get everything back up.

## Running background jobs

* Launch redis `redis-server`
* Launch Sidekiq `bundle exec sidekiq -r ./workers.rb -e development`
