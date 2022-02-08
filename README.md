# reproduce kaniko hang

```sh
./reproduce.sh 2>&1 | tee build.log
```

Kill when hanging to get stack trace:
```sh
kubectl exec kaniko -- kill -ABRT 1
```