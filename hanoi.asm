section .bss
    input resb 3                        ; Armazenar a entrada do usuário (máximo de 2 dígitos + null terminator)

section .data

    ; Armazena os caracteres das torres
    origem db "A"                       ; Torre A
    auxiliar db "B"                     ; Torre B
    destino db "C"                      ; Torre C
    len equ $ - destino                 ; Tamanho da string

    ; Armazena a quebra de linha
    quebra_de_linha db 0x0a

    ; Armazena a quantidade de discos. Isto será usado para converter o numero inteiro para string
    quantidade_discos db "00"           ; Buffer para armazenar a string
    len_quantidade_discos dd 0          ; Tamanho da string resultante

    ; Armazena textos
    texto1 db "Digite um numero entre 1 e 99: "
    len1 equ $ - texto1

    texto2 db "Mova o disco "
    len2 equ $ - texto2

    texto3 db " da Torre "
    len3 equ $ - texto3

    texto4 db " para a Torre "
    len4 equ $ - texto4

    texto5 db "Algoritmo da Torre de Hanoi com "
    len5 equ $ - texto5

    texto6 db " discos:"
    len6 equ $ - texto6

    texto7 db "Concluido"
    len7 equ $ - texto7
    
section .text

    global _start

_start:

    call mensagem_inicial               ; Imprime a mensagem inicial
    call ler_entrada                    ; Le a entrada do usuario
    call mensagem_quantidade_discos     ; Imprime a mensagem da quantidade de discos usados no algoritmo de hanoi
    call converte_string_para_int       ; Chama a funcao que converte a quantidade de discos, que esta como string, para inteiro

    ; Essa parte chama a funcao hanoi passando seus parametros na pilha: numero de discos, origem(A), auxiliar(B) e destino(C)
    push ecx                            ; ebp+20
    push origem                         ; ebp+16
    push auxiliar                       ; ebp+12
    push destino                        ; ebp+8
    call hanoi                          ; ebp+4

    call mensagem_final                 ; Imprime a mensagem final

    ; Finaliza o programa
    mov eax, 1
    int 0x80

mensagem_inicial:

    ; Essa estrutura sera um padrao para imprimir uma mensagem em que o texto é colocado na pilha. Os parametros da funcao sao: texto e tamanho do texto
    push texto1                         ; ebp+12
    push len1                           ; ebp+8
    call print                          ; ebp+4
    add esp, 8                          ; Limpa o conteudo restante
    
    ret

ler_entrada:

    ; Ler a entrada do usuário. sys_read(mov eax, 3) precisa de 3 parametros(ebx, ecx e edx)
    mov eax, 3                          ; Faz uma chamada de leitura
    mov ebx, 0                          ; Entrada padrao stdin
    mov ecx, input                      ; Armazena o endereco do buffer especificado em .bss
    mov edx, 3                          ; Tamanho do buffer
    int 0x80                            ; Chamada do sistema

    ret

mensagem_quantidade_discos:

    ; Imprime a seguinte mensagem, por exemplo: "Algoritmo da Torre de Hanoi com 3 discos:"

    ; quebra de linha: 0x0a
    push quebra_de_linha
    push len
    call print
    add esp, 8

    ; "Algoritmo da Torre de Hanoi com "
    push texto5
    push len5
    call print
    add esp, 8

    ; numero de discos. Exemplo: 3
    push input
    push len
    call print
    add esp, 8

    ; " discos:"
    push texto6
    push len6
    call print
    add esp, 8

    ; quebra de linha: 0x0a
    push quebra_de_linha
    push len
    call print
    add esp, 8

    ; quebra de linha: 0x0a
    push quebra_de_linha
    push len
    call print
    add esp, 8

    ret

converte_string_para_int:

    mov esi, input                      ; Armazena o endereço da string de entrada
    mov eax, 0                          ; Reseta EAX
    mov ecx, 0                          ; Reseta ECX
    mov cl, [esi]                       ; Armazena um byte da string apontada por ESI em CL(8 bits menos significativos de ECX)

    loop_string_para_int:
    
        sub ecx, '0'                    ; Converte o caractere ASCII para valor numérico
        imul eax, eax, 10               ; Multiplica EAX por 10 (shift à esquerda de um dígito decimal)
        add eax, ecx                    ; Adiciona o valor a EAX
        add esi, 1                      ; Move para o próximo caractere
        mov ecx, 0                      ; Reseta ECX
        mov cl, [esi]                   ; Armazena um byte da string apontada por ESI em CL(8 bits menos significativos de ECX)
        cmp ecx, 0x0a                   ; Verifica se é o caractere de quebra de linha
        jne loop_string_para_int        ; Repete o processo
        mov ecx, eax                    ; Armazenar o número convertido em ECX para posterior uso
        
        ret

converte_int_para_string:

    ; Número a ser convertido
    mov eax, [ebp+20]            ; Número para conversão
    mov edi, quantidade_discos        ; Ponteiro para o buffer quantidade_discos
    add edi, 2            ; Apontar para o final do buffer
    mov byte [edi], 0      ; Adicionar terminador nulo

    ; Conversão de inteiro para string
    loop_int_para_string:

        mov edx, 0           ; Limpar o registrador de resto
        mov ebx, 10            ; Divisor (10)
        div ebx                ; Dividir EAX por 10 (resultado em EAX, resto em EDX)
        add dl, '0'            ; Converter resto para ASCII
        sub edi, 1                ; Mover ponteiro do buffer para trás
        mov [edi], dl          ; Armazenar o caractere no buffer
        add dword [len_quantidade_discos], 1        ; Incrementar o tamanho da string
        cmp eax, 0          ; Verificar se EAX é 0 (quociente)
        jne loop_int_para_string       ; Se não for zero, continuar

        ret

mensagem_final:

    ; Exemplo da mensagem final: "Concluido"

    ; quebra de linha: 0x0a
    push quebra_de_linha
    push len
    call print
    add esp, 8

    ; "Concluido"
    push texto7
    push len7
    call print
    add esp, 8

    ; quebra de linha: 0x0a
    push quebra_de_linha
    push len
    call print
    add esp, 8

    ret

; A funcao recursiva hanoi passa 4 argumentos: numero de discos, origem, auxiliar e destino
hanoi:

    push ebp            ; Empurra EBP para o topo da pilha
    mov ebp, esp        ; Copia o valor de ESP para EBP e configura o novo quadro de pilha

    mov ecx, [ebp+20]   ; Atualiza o valor do contador ECX a partir do valor salvo na pilha
    cmp ecx, 1          ; Verifica se o contador tem o valor 1 (1 disco apenas)
    je um_disco         ; Se a verificacao anterior for verdade pula para um_disco

    sub ecx, 1          ; Decrementa o contador em 1
    push ecx            
    mov eax, [ebp+16]   ; Insere o novo valor para origem (origem)
    push eax
    mov eax, [ebp+8]    ; Insere o novo valor para auxiliar (destino)
    push eax
    mov eax, [ebp+12]   ; Insere o novo valor para destino (auxiliar)
    push eax
    call hanoi          ; Chama a funcao novamente com os novos valores de origem, auxiliar e destino
    add esp, 16         ; Limpa a pilha apos chamada

    call print_disco

    mov ecx, [ebp+20]   ; Atualiza o contador da pilha novamente
    sub ecx, 1          ; Decrementa o contador em 1
    push ecx
    mov eax, [ebp+12]   ; Insere o novo valor para origem (auxiliar)
    push eax
    mov eax, [ebp+16]   ; Insere o novo valor para auxiliar (origem)
    push eax
    mov eax, [ebp+8]    ; Insere o novo valor para destino (destino))
    push eax
    call hanoi          ; Chama a funcao novamente com os novos valores de origem, auxiliar e destino
    add esp, 16         ; Limpa a pilha apos chamada

    jmp desempilha      ; Quando chega a este ponto, restaura os valores de EBP e ESP para o valor inicial

um_disco:
    call print_disco

desempilha:

    mov esp, ebp        ; Restaura o valor original de ESP
    pop ebp             ; Remove EBP do topo da pilha e restaura o valor original de EBP
    ret                 

print_disco:

    ; Exemplo de mensagem impressa: "Mova o disco da Torre C para a Torre B"
    push texto2
    push len2
    call print
    add esp, 8

    ; Converter o numero do disco de inteiro para string
    
    call converte_int_para_string
    push edi
    push dword [len_quantidade_discos]
    call print
    add esp, 8

    push texto3
    push len3
    call print
    add esp, 8

    ; Imprime o caracter de origem
    mov eax, [ebp+16]
    push eax
    push len
    call print
    add esp, 8

    push texto4
    push len4
    call print
    add esp, 8

    ; Imprime o caracter de destino
    mov eax, [ebp+8]
    push eax
    push len
    call print
    add esp, 8

    push quebra_de_linha
    push len
    call print
    add esp, 8

    ret

; A funcao print passa 2 argumentos: texto e tamanho do texto
print:

    push ebp
    mov ebp, esp

    ; A chamada do sistema para escrita (sys_write)
    mov edx, [ebp+8]    ; Aponta pro tamanho do texto
    mov ecx, [ebp+12]   ; Aponta pro conteudo do texto
    mov ebx, 1          ; Configura o stdout
    mov eax, 4          ; Configura a chamada sys_write

    int 0x80
    pop ebp
    ret