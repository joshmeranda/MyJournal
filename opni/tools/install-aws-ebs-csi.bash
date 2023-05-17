#!/usr/bin/env bash
# script copied and modified from the example script here: https://github.com/rancher/opni/wiki/Install-AWS-EBS-CSI-driver#example-all-in-one-script
usage="Usage: $(basename $0) <cluster> <role prefix> [region]"
CLUSTER_NAME="$1"
ROLE_PREFIX="$2"
REGION="$3"

if [ -z "$CLUSTER_NAME" ]; then
  printf 'expected cluster name but found none\n%s' "$usage"
  exit 1
elif [ -z "$ROLE_PREFIX" ]; then
  printf 'expected csi driver role prefix but found none\n%s' "$usage"
  exit 1
fi

if [ -z "$REGION" ]; then
  REGION="$(aws configure get region)"
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

EBS_CSI_DRIVER_ROLE="${ROLE_PREFIX}_EBS_CSI_Driver_Role"

echo "Installing AWS EBS CSI Driver with values:
  CLUSTER: $CLUSTER_NAME
     ROLE: $EBS_CSI_DRIVER_ROLE
   REGION: $REGION
       ID: $AWS_ACCOUNT_ID"

eksctl utils associate-iam-oidc-provider --region=$REGION --cluster $CLUSTER_NAME --approve
sleep 1
export OIDC_ISSUER=$(aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")
sleep 1

TRUST_POLICY_FILE="$(mktemp --quiet)"

cat > "$TRUST_POLICY_FILE" << EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Principal":{
            "Federated":"arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/${OIDC_ISSUER}"
         },
         "Action":"sts:AssumeRoleWithWebIdentity",
         "Condition":{
            "StringEquals":{
               "${OIDC_ISSUER}:aud": "sts.amazonaws.com",
               "${OIDC_ISSUER}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
            }
         }
      }
   ]
}
EOF

aws iam create-role \
  --region $REGION \
  --role-name $EBS_CSI_DRIVER_ROLE \
  --assume-role-policy-document "file://$TRUST_POLICY_FILE"
sleep 1

aws iam attach-role-policy \
  --region $REGION \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --role-name $EBS_CSI_DRIVER_ROLE

sleep 1
aws eks create-addon --cluster-name $CLUSTER_NAME --addon-name aws-ebs-csi-driver  --region $REGION \
  --service-account-role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/${EBS_CSI_DRIVER_ROLE}
sleep 1
aws eks describe-addon --cluster-name $CLUSTER_NAME --region $REGION --addon-name aws-ebs-csi-driver

rm --force "$TRUST_POLICY_FILE"

echo "to clean up after yourself you can run:
	 aws iam detach-role-policy --region $REGION --role-name $EBS_CSI_DRIVER_ROLE --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy
	 aws iam delete-role --region $REGION --role-name $EBS_CSI_DRIVER_ROLE
"