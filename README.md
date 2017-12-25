# Pluggy

Pluggy is meant to be a flexible framework for you to plug your ideas into. It is designed and written with code cleanliness and modularity in mind, even at the expense of usability. Typically, there are usability benefits to maintaining and clean and orderly code base in the long run.

Pluggy is designed to be scalable. It can begin as an application which looks like [sinatra](https://sinatrarb.com), but grow into something which looks more like [rails](https://rubyonrails.com). You can mix and match sinatra-style procs for processing requests and the full MVC model espoused by rails.

## Installation

Add `gem 'pluggy'` to your application's Gemfile and then `bundle install`, or do the normal `gem install pluggy`. If you are using bundler anyways, it's recommended that you use the gem from git:

```ruby
gem 'pluggy', git: 'https://github.com/izwick-schachter/pluggy', branch: 'master'
```

## Usage

Of course, we must begin with "Hello World!" (in a one liner)

```ruby
require('pluggy')&&get('/'){'Hello world!'}
```

which expands to:

```ruby
require 'pluggy'
get '/' do
  'Hello world!'
end
```

Hmm.... what does the syntax remind me of... Oh! The "Hello world!" example from [the sinatra docs](http://sinatrarb.com/intro.html)!

```ruby
require 'sinatra'
get '/' do
  'Hello world!'
end
```

> **Note:** The other HTTP verbs do not have a convenient helper (because reasons). You must use `route :post, '/' do end` for non-get routes for now.

The first dissimilarity between pluggy and sinatra comes in how `params` and `env` and exposed. In sinatra, they are methods defined in the global scope. Because we decided that was ugly, we passed them into the blocks. So, to use params:

```ruby
require 'pluggy'

get '/' do |params, env|
  params #=> {:keys => "values"}
end
```

But for params that are a part of the path, the syntax is the exact same, because they both use [mustermann](https://github.com/sinatra/mustermann) for route matching.

If you're feeling rails-ish, you can pick a rails-ish file structure and have it work just as well. For example, if this is your file structure:

```bash
.
├── assets
│   └── test.erb
├── controllers
│   └── bar_controller.rb
├── Gemfile
├── Gemfile.lock
├── app.rb
└── views
    └── bar
        ├── baz.txt.erb
        └── test.html.erb
```

in `app.rb` you can route, just like in rails!

```ruby
get '/users/:id', to: 'bar#baz'
```

Which will, just like rails, first run the code in the `#baz` action, then render the view:

```ruby
# controllers/bar_controller.rb
class BarController < Pluggy::Controller
  def baz
    @user_id = params[:user_id]
  end
end

# views/bar/baz.txt.erb
Login sucessful for <%= @user_id %>!
```

Which will return (in plain text) "Login sucessful for 1!" when you get '/users/1'.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pluggy. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Pluggy project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/pluggy/blob/master/CODE_OF_CONDUCT.md).
