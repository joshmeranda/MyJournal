#!/usr/bin/env sh

# wait for the pod ($1) to be either Completed or Unknown
wait_for_pod()
{
	pod="$1"

	while :; do
		case "$(kubectl get pod --namespace cattle-logging-system "$pod" | tail --lines 1 | tr --squeeze-repeats ' ' | cut --delimiter ' ' --fields 3)" in
			Completed)
				echo "Completed:$pod"
				return 1
				;;
			Unkown)
				echo "Unknown:$pod"
				kubectl describe pod --namespace cattle-logging-system --output yaml "$pod" > "$pod.yaml"
				kubectl logs --namespace cattle-logging-system "$pod" > "$pod.logs"
				return 1
				;;
		esac
	done
}

# kubeconfig should be /etc/rancher/rke2/rke2.yaml be default in harvester
while [ ! -f "$KUBECONFIG" ]; do
	sleep 1
done

if ! sudo chmod a+r "$KUBECONFIG"; then
	echo "ERROR: could not make '$KUBECONFIG' readable"
	exit 2
fi

for pod in $(kubectl get pods --namespace cattle-logging-system --selector app.kubernetes.io/component=fluentd-configcheck --output name | cut -d / -f 2); do
	wait_for_pod "$pod"
done
