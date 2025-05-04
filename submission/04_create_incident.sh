#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/00_init.sh"

source $PROJECT_DIR/scripts/payload.sh

kubectl $K get pods

kubectl $K logs moneropool > $SUBMISSION/moneropool_logs.txt
kubectl $K logs minergate > $SUBMISSION/minergate_logs.txt
kubectl $K logs cryptotonight $SUBMISSION/cryptotonight_logs.txt


line
# Create a mock incident response report based on your test results
echo "Creating mock incident response report..."
cat <<EOF > $SUBMISSION/incident_response_report.txt
1. Incident commander name: 
    Martina Wille
2. Executive Summary of what happened: 
    Unauthorized cryptocurrency mining pods (moneropool, minergate, cryptotonight) 
    were deployed in the cluster, utilizing system resources for mining Monero. 
    The pods were identified as potentially malicious and were running without 
    authorization.
3. Summary of what was affected: 
    The Kubernetes cluster's CPU and network resources were impacted by the mining 
    processes. This led to a potential degradation in performance and increased 
    resource consumption.
4. Summmry of the impact: 
    CPU Utilization: Increased due to the mining activities.
    Cluster Performance: Reduced performance due to resources being hijacked for mining.
    Security: Possible compromise of the Kubernetes cluster by unauthorized workloads.
    Compliance: Potential violations of organization security policies and resource usage rules.
5. Summary of the remediation steps: 
    kubectl $K delete pod moneropool
    kubectl $K delete pod minergate
    kubectl $K delete pod cryptotonight
    * Inspect logs to determine how these pods were deployed and whether they 
      were part of a larger attack.
    * Review the cluster’s security policies and network settings to prevent 
      future unauthorized deployments.
    * Investigate any potential security breaches related to credentials or 
      access control.
6. Summary of lessons learned: 
    Pod Deployment Control: 
        Ensure that only authorized workloads are deployed on the Kubernetes 
        cluster by enforcing strict RBAC policies.
    Monitoring: 
        Implement proactive monitoring using tools like Falco, which can detect 
        unauthorized workloads or suspicious behavior.
    Audit Trails: 
        Maintain logs and audit trails of all cluster activity to quickly 
        identify unauthorized actions.
    Network Segmentation: 
        Isolate sensitive resources to prevent exploitation by unauthorized workloads.




EOF
echo "Incident response report saved to $SUBMISSION/incident_response_report.txt"
