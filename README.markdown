File Locker
===========

Provides a web-based file storage and sharing system.

Installation
------------

File Locker is a typical Ruby on Rails application.  We use Capistrano
to manage installation from the repository.  See config/deploy.rb for our
settings.  The only step we do by hand at the moment is changing the owner
of the public/stylesheets directory so that the Sass compiler can create
an updated styles.css file.

### Database Installation

To create the schema, run `rake db:setup`.
