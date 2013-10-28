hERmes_viewer
=============

hERmes is an aggregation tool for disparate data for analytical purposes.  It takes various performance test information (e.g. Graphite, application server, logs, Nagios, custom counters) and wraps them in a single container.  That container can then be compared to other containers for trending analysis.  hERmes also provides a way to assert SLA metrics, reader's digest, and custom plugin architecture.

<h2>Installation</h2>
- Install ruby 2.0
- Install bundler
- Install application dependencies:
    <code>bundle install</code>
- Start application:
    <code>rackup</code>

<h2>Testing</h2>
hERmes has extensive testing with Cucumber (<code>cucumber tests/</code>) and unit test (<code>ruby tests/Models/test_helper.rb</code>).  The code coverage is compiled by simplecov.

