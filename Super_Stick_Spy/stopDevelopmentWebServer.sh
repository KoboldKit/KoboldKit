#!/bin/sh

pid=$(ps ax | grep python | grep -v grep | awk '{ print $1 }')
kill -9 $pid
