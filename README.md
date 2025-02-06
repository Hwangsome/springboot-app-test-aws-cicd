# 执行命令进入容器
```shell
aws ecs execute-command \
    --cluster ecs-test-cluster \
    --task da27351856094b288a2a9de443d8c5e2 \
    --container springboot-app \
    --interactive \
    --command "/bin/sh"
```
# test trigger cicd
