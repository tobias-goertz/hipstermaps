web: env -u DYNO puma
worker: bundle exec sidekiq -c 1 -q default -q mailers
