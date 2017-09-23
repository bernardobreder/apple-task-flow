# Introdução

O componente TaskFlow tem a responsabilidade de gerenciar as tarefas que serão executadas em segundo plano determinando um fluxo de execução e podendo ser revertida caso cancelado ou solicitado após a finalização.

# Arquitetura

##  TaskFlowManager

O componente é gerenciado pelo TaskFlowManager cujo papel é controlar o fluxo de execução de tarefas de leitura e de escritas, onde:

* Uma tarefa de escrita é executado em exclusividade, não havendo concorrência com nenhuma outro tarefa de leitura e escrita
* Uma tarefa de leitura pode ser executado concorrentemente com várias outras tarefas de leitura.
* Em uma tarefa de leitura, nenhuma mudança de estado de objeto pode ser aplicado. Para garantir que um código de terceiro não altere o estado de nenhum objeto, uma cópia dos objetos podem ser disponibilizados para o código de terceiro processar.

## Task Flow

O fluxo de execução é representado pelo TaskFlow cujo principal papel é criar uma linha de execução de várias tarefas em segundo e primeiro plano de tal forma que a execução de todas elas representam a conclusão do fluxo de tarefa. 

### Tarefas em Primeiro Plano

A fila de tarefas em primeiro plano possui as seguintes características:

* As tarefas em primeiro plano são operações executados na thread principal, através de uma única fila de tarefas, para atualizar a interface gráfica da aplicação, caso haja. 
* Esse tipo de tarefa não trabalha com concorrência entre si, por haver uma única fila de trabalho, mas pode concorrer com tarefas em segundo plano de leitura, não havendo a necessidade de um sincronismo nos recursos compartilhados por se tratar de operações de somente leitura.

### Tarefas em Segundo Plano

A fila de tarefas em segundo plano possui as seguintes características:

* As tarefas em segundo plano são operações que irão ser executados em uma thread separada
* As tarefas de leitura em segundo plano pode haver ou não concorrência com outras tarefas em segundo e primeiro plano, com o objetivo de coletar dados.
* As tarefas de escrita em segundo plano não há concorrência com outras tarefas de segundo e primeiro plano
* O objetivo desse tipo de tarefa é permitir executar longos procedimentos sem bloquear as tarefas de primeiro plano.
* Essa fila de tarefa permite criar pequenas tarefas em primeiro plano com o objetivo de atualizar a interface gráfica
* Essa fila permite criar tarefas em segundo plano para continuar a execução do fluxo de tarefa, criando assim uma linha de execução pertencente a um único fluxo de tarefa

### Cancelamento da tarefa

Durante a execução do fluxo de tarefas, pode ocorrer a necessidade de cancelar a sua execução. Para que o ambiente não fique sujo com as mudanças realizar e não concluídas, é recomendado durante a execução da tarefa fazer o cadastro da reversão de cada mudança que ocorrer. Para isso, deve ser levado em conta os seguintes tópicos:

* Para cada tarefa em execução no segundo plano, deve-se cadastrar tarefas de reversão do que já foi aplicado. Esse cadastro possibilita reverter todo o fluxo de execução quando for solicitado o cancelamento, limpando assim todas as operações já efetuadas.
* A ordem de execução da reversão quando for solicitado o cancelamento, é inversa ao cadastro para que as últimas mudanças sejam as primeiras a serem revertidas.
* Tantas as tarefas de segundo e de primeiro plano, devem cadastrar a sua reversão para que o ambiente volte ao estado original da inicialização da execução do fluxo de tarefa
* O fluxo de tarefas de leitura não precisam cadastrar a reversão por não alterar nenhum estado dos objetos processados 
* Como os fluxos de tarefa de escrita não são executados concorrentemente, a reversão também não será executada concorrentemente com outros fluxos de tarefa.
* Como o fluxo de tarefa é subdividido em várias sub-tarefas, onde o cancelamento de um fluxo espera terminar a execução da sub-tarefa atual para depois reverter as mudanças realizadas na ordem inversa. Assim, o tempo necessário para cancelar uma tarefa é o tempo do termino da tarefa atual subdividida mais o tempo da reversão de todas as tarefas já executadas.
* A etapa de cancelamento de um fluxo de tarefa faz com que seja executado todas as reversões cadastradas em cada sub-tarefas na ordem inversa. Como as sub-tarefas foram executadas em segundo plano, a sua reversão também será executada em segundo plano. Dessa forma, ao cancelar um fluxo, será criado a quantidade de tarefas em segundo plano igual a quantidade de tarefas processadas revertendo em cada tarefa o que foi aplicado. As tarefas em primeiro plano criado no segundo plano será também revertida na ordem inversa que foi criada na tarefa.

# Lock de Leitura e Escrita

# Exemplo

```swift
let taskFlowMng = TaskFlowManager()
let flow = taskFlowMng.execute(title: "Task Flow for Change ...") { flow in
    flow.main(apply: { /* (...) */ }, revert: { /* (...) */ })
    let params = flow.main(query: { /* (...) */ })
    let result1 = flow.task(title: "Changing ...", apply: { task in 
        /* (...) */
    }, revert: { task in
        /* (...) */
    })
    task.main(apply: { /* (...) */ }, revert: { /* (...) */ })
    let result2 = flow.task(title: "Applying ...", apply: { task in 
        /* (...) */
    }, revert: { 
        /* (...) */ 
    })
    flow.task(title: "Finishing ...", apply: { task in 
        /* (...) */
    }, revert: { 
        /* (...) */ 
    })
    flow.main(apply: { /* (...) */ }, revert: { /* (...) */ })
}
```

