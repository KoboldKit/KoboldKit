#!/bin/sh

# runs Python's SimpleHTTPServer module on port 31013 in the background
# the webserver serves the ./Resources folder
# http://localhost:31013
(cd "./Resources"; python -m SimpleHTTPServer 31013 &)
