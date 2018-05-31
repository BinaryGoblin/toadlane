# Toadlane

## Required environment variables:

- `WELCOME_EMAIL`
- `WELCOME_EMAIL_PASSWORD`
- `BONSAI_URL`
- `ELASTICSEARCH_URL`
- `SECRET_KEY_BASE` - generate with `rake secret`
- `ARMOR_API_KEY`
- `ARMOR_API_SECRET`
- `ARMOR_PARTNER_ID`
- `DEVISE_SECRET_KEY`
- `ENVIRONMENT`
- `HOST`

## Heroku deployment notes

Make sure that the above variables are set and to follow the directions for SearchKick: https://github.com/ankane/searchkick#heroku

Also, set the Heroku worker to at least one in order to process background jobs:

`$ heroku ps:scale worker=1`

## Running the server

Make sure to use `$ foreman start` to run the server and process background jobs. You must also have elasticsearch running, which you can start with `$ elasticsearch`.

## Requirements/Dependencies

1. Ruby (check gemfile/.ruby-version for version)
1. Bundler
1. Rails
1. PostgreSQL
1. Foreman
1. Elasticsearch

## Getting Started

1. Read the Readme
1. Confirm Ruby version (.ruby-version)
1. Confirm Bundle installation and afterwards, bundle install
1. Confirm Postgresql is properly installed and configured
    - Copy `config/database.yml.example` to `config/database.yml`
    - Change authentication in `database.yml` to your PostgreSQL user authentication
    - Create the database `$ createdb`
    - `$ psql`
    - `>>> create database toad_development;` And quit psql
1. `$ rake db:migrate` to migrate schema to local empty database
1. `$ rake db:seed` to create Roles
1. `$ rake db:populate_db_category`
1. `$ rake db:populate_db_tax`
1. `$ rake db:populate_db_user`
1. `$ rake db:populate_db_product`
1. `$ foreman start`
1. `$ elasticsearch`

## Various Pages

1. Landing Page - \app\views\devise\registrations\new.html.erb