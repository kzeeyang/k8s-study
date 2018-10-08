#!/bin/bash  

SERVER='localhost:8001' # Proxy address for apiServer
while true;
do
    # Get all pods, and pod's properties
    for PODNAME in $(kubectl --server $SERVER get pods -o json | jq '.items[] | select(.spec.schedulerName == "my-scheduler") | select(.spec.nodeName == null) | .metadata.name' | tr -d '"');
    do
        # Get all nodes
        NODES=($(kubectl --server $SERVER get nodes -o json | jq '.items[].metadata.name' | tr -d '"'))
        NUMNODES=${#NODES[@]}
        
        # Choose a node randomly
        CHOSEN=${NODES[$[ $RANDOM % $NUMNODES ]]}
        
        # Bind a pod($PODNAME) to a node($CHOSEN)
        curl --header "Content-Type:application/json" --request POST --data '{"apiVersion":"v1","kind": "Binding","metadata": {"name": "'$PODNAME'"}, "target": {"apiVersion": "v1", "kind": "Node", "name": "'$CHOSEN'"}}'http://$SERVER/api/v1/namespaces/default/pods/$PODNAME/binding/        
        echo "Assigned $PODNAME to $CHOSEN"
    done
    sleep 1
done