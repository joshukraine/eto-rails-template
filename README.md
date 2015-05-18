# ETO Rails Template

This is a [Rails Application Template](http://guides.rubyonrails.org/rails_application_templates.html) which generates a new Rails app with the defaults we use in our organization.

## Usage

Clone this repo to the directory where you normally build new Rails apps.

```sh
cd ~/code
git clone https://github.com/joshukraine/eto-rails-template.git
```

To generate a new Rails app, issue the following command:

	rails new <your_app_name> -m eto-rails-template/template.rb

Once the generator is finished (and assuming you have Tmuxinator installed) simply run:

	mux start <your_app_name>

## What It Does

* Adds our default `Gemfile`
* Adds custom `.gitignore` file
* Configures app to use PostgreSQL instead of SQLite
* Installs and configures Rspec 3 for testing
* Installs Simple Form
* Installs and configures Bourbon, Neat, Bitters, and Refills
* Installs and configures Capistrano for deployment
* Installs and configures High Voltage for managing static pages
* Adds a basic `unicorn.rb` file
* Adds a tmuxinator project
* Initializes git repo with initial commit

## Tmuxinator

In order to use the included Tmuxinator project, you will need to first install the Tmuxinator gem:

	gem install tmuxinator

Complete instructions are available in the [Tmuxinator README][tmuxinator].

[tmuxinator]: (https://github.com/tmuxinator/tmuxinator/blob/master/README.md)

## Reference

The following resources were tremendously helpful in building this template:

* https://github.com/cookieshq/cookieshq-rails-template
* https://github.com/thoughtbot/suspenders
* http://guides.rubyonrails.org/rails_application_templates.html
* http://technology.stitchfix.com/blog/2014/01/06/rails-app-templates/
* http://www.rubydoc.info/github/wycats/thor/frames/Thor/Actions
