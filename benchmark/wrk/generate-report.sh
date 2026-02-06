#!/bin/bash
set -euo pipefail

JOB_NAME="benchmark-wrk-job"
CONFIGMAP="benchmark-wrk-config"
NAMESPACE="benchmark"
LABEL="app=benchmark-wrk-job"

# 读取输出测试结果所必要的信息

# 测试目标URL 
TARGET_URL=$(kubectl get configmap ${CONFIGMAP} -n ${NAMESPACE} -o jsonpath='{.data.TARGET_URL}')
# 线程数
THREADS=$(kubectl get configmap ${CONFIGMAP} -n ${NAMESPACE} -o jsonpath='{.data.THREADS}')
# 并发连接数
CONCURRENCY=$(kubectl get configmap ${CONFIGMAP} -n ${NAMESPACE} -o jsonpath='{.data.CONCURRENCY}')
# 测试持续时间
DURATION=$(kubectl get configmap ${CONFIGMAP} -n ${NAMESPACE} -o jsonpath='{.data.DURATION}')
# 测试开始时间
START_TIME=$(kubectl get job -n ${NAMESPACE} ${JOB_NAME} -o jsonpath='{.status.startTime}')
# 测试结束时间
COMPLETION_TIME=$(kubectl get job -n ${NAMESPACE} ${JOB_NAME} -o jsonpath='{.status.completionTime}')


# 生成时间戳
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

# 日志文件名
REPORT_FILE="report-wrk-${TIMESTAMP}.log"

echo "WRK Benchmark Report" | tee -a "${REPORT_FILE}"
echo "Target URL      : ${TARGET_URL}" | tee -a "${REPORT_FILE}"
echo "Namespace       : ${NAMESPACE}" | tee -a "${REPORT_FILE}"
echo "THREADS         : ${THREADS}" | tee -a "${REPORT_FILE}"
echo "Duration        : ${DURATION}" | tee -a "${REPORT_FILE}"
echo "CONCURRENCY     : ${CONCURRENCY}" | tee -a "${REPORT_FILE}"
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