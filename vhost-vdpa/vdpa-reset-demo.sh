#!/usr/bin/env bash

#################################
# include the -=magic=-
# you can pass command line args
#
# example:
# to disable simulated typing
# . ../demo-magic.sh -d
#
# pass -h to see all options
#################################
. ./demo-magic.sh


########################
# Configure the options
########################

#
# speed at which to simulate typing. bigger num = faster
#
TYPE_SPEED=60

#
# custom prompt
#
# see http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/bash-prompt-escape-sequences.html for escape sequences
#
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

# text color
# DEMO_CMD_COLOR=$BLACK

# hide the evidence
clear

delay_1s () {
   PROMPT_TIMEOUT=1
   wait
}

pei "oc delete -f pod2.yaml"
pei "oc delete -f pod1.yaml"
pei "oc delete -f network-attach-2nd-if.yaml"
pei "oc delete -f policy.yaml"

PROMPT_TIMEOUT=600
wait

pei "oc delete -f sriov-pool-config.yaml"

PROMPT_TIMEOUT=600
wait

pei "oc label node virtlab711.virt.lab.eng.bos.redhat.com node-role.kubernetes.io/mcp-offloading-"
pei " oc label node virtlab711.virt.lab.eng.bos.redhat.com feature.node.kubernetes.io/network-sriov.capable-"

pei "oc delete -f mcp-offloading.yaml"
