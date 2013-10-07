#!/bin/bash
# TIPALDI GIUSEPPE- 12-2012


fm=`cpufreq-info -fm`
echo " Currenty CPU frequency = $fm"
echo " Set max frequency at 1150MHz"
cpufreq-set -u 1155M
echo " Set cpu operative mode : performance"
cpufreq-set -g performance
fm=`cpufreq-info -fm`
echo " Currenty CPU frequency = $fm"
