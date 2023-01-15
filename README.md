# cisterna_slave
project_cisterna_slave_UART
### Criação de uma placa com PIC16 para recebimento de sinais digitais e transferencia de informações via comando UART
Este projeto tem objetivo de criar uma placa de comunicação slave para monitoramento de caixas d'agua e comando de abertura valvula da rua, caso haja pouca chuva e a caixa principal esteja vazia
O comando para abrir a valvula da agua da rua, pode ser executado de maneira automática ou manual
Em modo manual - só vai abrir se nao tiver agua na caixa principal e o usuario final clicar para isso na placa master
Em modo automático - abre caso não tenha agua na caixa principal da cisterna e caixas secundarias de alimentação de rede hidraulica da cisterna
