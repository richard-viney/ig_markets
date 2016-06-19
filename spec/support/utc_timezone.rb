# Specs must be run with a fixed time zone because the models and command-line client report times in local time

ENV['TZ'] = 'UTC'
