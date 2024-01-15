launcher=$(kubectl get pods | awk 'FNR == 2 {print $1}')
kubectl logs -f $launcher
