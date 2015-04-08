# Toadlane

## Required environment variables:

- `WELCOME_EMAIL`
- `WELCOME_EMAIL_PASSWORD`
- `BONSAI_URL`
- `ELASTICSEARCH_URL`
- `SECRET_KEY_BASE` - generate with `rake secret`
- `ARMOR_API_KEY`
- `ARMOR_API_SECRET`

## Heroku deployment notes

Make sure that the above variables are set and to follow the directions for SearchKick: https://github.com/ankane/searchkick#heroku

Also, set the Heroku worker to at least one in order to process background jobs:

`$ heroku ps:scale worker=1`

## Running the server

Make sure to use `$foreman start` to run the server and process background jobs. You must also have elasticsearch running, which you can start with `$ elasticsearch`.