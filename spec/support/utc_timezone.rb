# Specs must be run a fixed time zone because the models and the command-line client report times in local time

ENV['TZ'] = 'UTC'
