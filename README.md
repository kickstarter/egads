# egads!!!
# *Extensible Git-Archive Deploy Strategy*

egads is a set of commands for deploying applications without depending on a git
server.

[![Build
Status](https://travis-ci.org/kickstarter/egads.svg)](https://travis-ci.org/kickstarter/egads)
[![Code
Climate](https://d3s6mut3hikguw.cloudfront.net/github/kickstarter/egads.svg)](https://codeclimate.com/github/kickstarter/egads)

## Install

Put `egads` in your Gemfile:

    # In Gemfile
    gem 'egads', require: nil

On remote machines (to which you deploy), `egads` must be in your PATH.
So install `egads` as a system gem:

    sudo gem install egads

## Commands

See `egads -h` for the most robust & up-to-date info. Here's a whirlwind tour.

Egads has two types of commands. *Local* commands run on your development machine or continuous integration environment. *Remote* commands run on deployed servers.

Commands are either *porcelain* commands that you should call directly as part of a typical workflow; or *plumbing* commands that are invoked by porcelain commands, and rarely invoked directly.

### Local commands

* `egads check [SHA]` - checks if a deployable tarball of the current commit exists on S3.
* `egads build [SHA]` - makes a deployable tarball of the current commit and upload it to S3 (if missing).
* `egads upload SHA` - (plumbing, called by `build`) Uploads a pre-built tarball.

### Remote commands

* `egads stage SHA` - Prepares an extracted tarball for release: runs bundler, copies config files, etc.
* `egads release SHA` - Symlinks a staged release to current, restarts services
* `egads extract SHA` - (plumbing, called by `stage`) Downloads and untars a tarball from S3.
* `egads clean` - (plumbing, called by `release`) Deletes old releases to free space.

## Configuration

There are two config files:

* `egads.yml` ([example](example/egads.yml)) is in your git repo and tarballs. It has instructions for building, staging, and releasing tarballs.
* `/etc/egads.yml` ([example](example/egads_remote.yml)) on remote servers has some configuration for downloading and extracting tarballs from S3; and some environment variables that could vary across environments. This file is presumably provisioned by a tool like Chef or Puppet.

## Deploy process

The deploy process is:

* Run `egads build` from a server with a full git checkout (e.g. your local machine). This ensures there's a tarball for the remote servers to download.
* Run `egads stage SHA` on all the remote servers to download, extract, and configure the SHA for release.
* Run `egads release SHA` on all the remote servers to symlink the staged SHA to 'current', and restart services.

## License

Copyright (c) 2013 Kickstarter, Inc

Released under an [MIT License](http://opensource.org/licenses/MIT)
