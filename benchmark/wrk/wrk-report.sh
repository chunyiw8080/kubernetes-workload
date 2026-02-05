#!/bin/bash

path="${1:-./report.log}"

kubectl logs -n benchmark -l app=benchmark-wrk-job > $path