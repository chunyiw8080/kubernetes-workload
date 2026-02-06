#!/bin/bash
set -euo pipefail

JOB_NAME="benchmark-k6-job"
CONFIGMAP="benchmark-k6-config"
NAMESPACE="benchmark"
LABEL="app=benchmark-k6-job"

# 读取输出测试结果所必要的信息

# 测试目标URL (sitemap)
TARGET_URL=$(kubectl get configmap ${CONFIGMAP} -n ${NAMESPACE} -o jsonpath='{.data.SITEMAP_URL}')
# 并发用户数
VUS=$(kubectl get configmap ${CONFIGMAP} -n ${NAMESPACE} -o jsonpath='{.data.VUS}')
# 测试持续时间
DURATION=$(kubectl get configmap ${CONFIGMAP} -n ${NAMESPACE} -o jsonpath='{.data.DURATION}')
# 测试开始时间
START_TIME=$(kubectl get job -n ${NAMESPACE} ${JOB_NAME} -o jsonpath='{.status.startTime}')
# 测试结束时间
COMPLETION_TIME=$(kubectl get job -n ${NAMESPACE} ${JOB_NAME} -o jsonpath='{.status.completionTime}')


# 生成时间戳
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

# 日志文件名
REPORT_FILE="report-k6-${TIMESTAMP}.log"

echo "K6 Benchmark Report" | tee -a "${REPORT_FILE}"
echo "Target URL      : ${TARGET_URL}" | tee -a "${REPORT_FILE}"
echo "Namespace       : ${NAMESPACE}" | tee -a "${REPORT_FILE}"
echo "VUS             : ${VUS}" | tee -a "${REPORT_FILE}"
echo "Duration        : ${DURATION}" | tee -a "${REPORT_FILE}"
echo "Start Time      : ${START_TIME}" | tee -a "${REPORT_FILE}"
echo "Completion Time : ${COMPLETION_TIME}" | tee -a "${REPORT_FILE}"
echo "**************************************" | tee -a "${REPORT_FILE}"
echo "" | tee -a "${REPORT_FILE}"

# 拉取所有 Pod 日志并保存
for POD in $(kubectl get pods -n ${NAMESPACE} -l ${LABEL} -o jsonpath='{.items[*].metadata.name}'); do
  node_name=$(kubectl get pod "${POD}" -n ${NAMESPACE} -o jsonpath='{.spec.nodeName}')
  region=$(kubectl get node "${node_name}" -o jsonpath='{.metadata.labels.topology\.kubernetes\.io/region}')

  echo "===== Pod: ${POD} - Node: ${node_name} - Region: ${region:-null} =====" | tee -a "${REPORT_FILE}"

  kubectl logs -n ${NAMESPACE} "${POD}" | tee -a "${REPORT_FILE}"
  
  echo | tee -a "${REPORT_FILE}"
done