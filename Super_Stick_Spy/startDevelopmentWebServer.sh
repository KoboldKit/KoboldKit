#!/bin/sh

# runs Python's SimpleHTTPServer module on port 32111 in the background
# the webserver serves the ./Resources folder
(cd "./Resources"; python -m SimpleHTTPServer 32111 &)

# Verify the server is running by visiting this URL: 
# http://localhost:32111
