[![Gem Version](https://badge.fury.io/rb/proc_matcher.png)](http://badge.fury.io/rb/proc_matcher)
[![Build Status](https://travis-ci.org/dwhelan/proc_matcher.png?branch=master)](https://travis-ci.org/dwhelan/proc_matcher)
[![Code Climate](https://codeclimate.com/github/dwhelan/proc_matcher/badges/gpa.svg)](https://codeclimate.com/github/dwhelan/proc_matcher)
[![Coverage Status](https://coveralls.io/repos/dwhelan/proc_matcher/badge.svg?branch=master&service=github)](https://coveralls.io/github/dwhelan/proc_matcher?branch=master)

# ProcMatcher

A matcher for testing proc and lambda equivalance.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'proc_matcher'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install proc_matcher

## Usage

Add this line to your `spec_helper.rb` file:

```ruby
include 'proc_matcher'
```

You will now have access to a matcher called `has_same_source_as` which
allows you to check that `procs's` have the source code.

```ruby
require 'spec_helper'

describe 'have_same_source_as' do
  let(:proc1) do
    proc {}
  end

  it 'the same procs should be equal' do
    expect(proc1).to have_same_source_as proc1
  end

  it 'lambdas should not have the same source as procs' do
    expect(proc1).to_not have_same_source_as -> {}
  end

  it 'procs with different parameters only should by default not have the same source' do
    proc1 = proc { |a| a.to_s }

    expect(proc1).to_not have_same_source_as proc { |b| b.to_s }
  end
end
```

The `ignoring_parameter_names` allows blocks to be considered to have the same
source if they only differ in their parameter names:

```ruby
require 'spec_helper'

describe 'ignoring_parameter_names' do
  it 'ignoring_parameter_names should allow procs with same effective source but different parameters to have the same source' do
    proc1 = proc { |a| a.to_s }

    expect(proc1).to have_same_source_as(proc { |b| b.to_s }).ignoring_parameter_names
  end
end
```

*Note* this matcher depends the `sourcify` gem to extact the source code.
This source extraction only works if:
 * the proc is the only proc declared on the same line
 * the proc was not created via an `eval`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dwhelan/proc_matcher. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
