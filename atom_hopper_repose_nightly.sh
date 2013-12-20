#!/bin/bash

echo "start repose test"
ruby /root/viewer/hERmes_viewer/nightly_test.rb --app repose --sub-app atom_hopper --action start --test-type load --length 10 --release master --name "Sample Test" --runner "jmeter" --flavor-type performance --with-repose true
sleep 10m
echo "stop repose test"
ruby /root/viewer/hERmes_viewer/nightly_test.rb --app repose --sub-app atom_hopper --action stop --test-type load --length 10 --release master --name "Sample Test" --runner "jmeter" --flavor-type performance --with-repose true

echo "start origin test"
ruby /root/viewer/hERmes_viewer/nightly_test.rb --app repose --sub-app atom_hopper --action start --test-type load --length 10 --name "Sample Test" --runner "jmeter" --flavor-type performance
sleep 10m
echo "stop origin test"
ruby /root/viewer/hERmes_viewer/nightly_test.rb --app repose --sub-app atom_hopper --action stop --test-type load --length 10 --name "Sample Test" --runner "jmeter" --flavor-type performance
