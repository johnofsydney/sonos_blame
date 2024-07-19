# README

This project is sufficiently stale, that it needs some significant updates before you could get it running again. Maybe one day, maybe not.

## Purpose
- A rails application that will use OAth to login a user into this app with their spotify login.
- At the time of logging in to spotify, a background worker will pull the user's listening data into the rails app.
- The user show page will display favourite artists; short, medium and long term as well as a summarised list.
- Search for an artist, and the rails app will determine which of the users is the biggest fan / most likely culprit. (this feature needs a few users to have accounts and spotify data to work)

## To build
```
$ git clone
$ bundle install
$ yarn install
```

## To configure this app on Spotify
- create an account on https://developer.spotify.com/
- register a new app, enter the client_id and client_secret into rails credentials:
```
# aws:
#   access_key_id: 123
#   secret_access_key: 345

spotify:
  client_id: 123
  client_secret: 123

# Used as the base secret for all MessageVerifiers in Rails, including the one protecting cookies.
secret_key_base: 123
```
- On spotify developer, set the follwing attributes for your app:
```
# Redirect URIs
http://localhost:3000/users/auth/spotify/callback
https://<your-deployed-host-url>/users/auth/spotify/callback
```


## To Run
`$ bundle exec rails server`

Redis is required
`$ redis-server`

Sidekiq
`$ sidekiq`