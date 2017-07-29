# Showdates

Run `script/server` to launch Showdates locally.

## Running background jobs

* Launch redis `redis-server`
* Launch Sidekiq `bundle exec sidekiq -r ./workers.rb -e development`
