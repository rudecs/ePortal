# Products


## Зависимость исполнения продуктов
### Одновременное создание трех продуктов: vdc, vm, backup
```plantuml

Frontend -> Products: buy products: vdc+vm+backup
Products -> Products: transaction:\n1.create vm product instance (vm pi)\n2.create vm pi job
BackgroundJobManager -> BackgroundJob: execute vm pi job
BackgroundJob -> BackgroundJob: transaction:\n1.create vdc product instance (vdc pi)\n2.create vdc pi job\n3.add cdv pi job as before_callback for vm pi job
BackgroundJobManager -> BackgroundJob: execute vdc pi job
BackgroundJobManager -> BackgroundJob: execute vm pi job
BackgroundJob -> BackgroundJob: transaction:\n1.create backup product instance (b pi)\n2.create b pi job\n3.add vm pi job as before_callback for b pi job
BackgroundJobManager -> BackgroundJob: execute b pi job
```
<!-- Timeline->Timeline:  -->
