#!/usr/bin/env ruby

require 'rubygems'
require 'thor'
require 'thor/group'

module X
  def four
    puts 4
  end
end

module MyAwesomeGem
  class MyCounter < Thor::Group
    desc "Prints 1 2 3"
    argument :foo

    include X
    def one
      puts 1
      self.class.remove_command :two
    end

    def two
      puts 2
    end

    protected
    def three
      puts 3
    end
  end

  class MyCommand < Thor
    desc "foo", "Prints foo"
    def foo
      puts "foo"
    end

    # register(class_name, subcommand_alias, usage_list_string, description_string)
    register(MyAwesomeGem::MyCounter, "counter", "counter", "Prints some numbers in sequence")
  end
end

MyAwesomeGem::MyCommand.start
