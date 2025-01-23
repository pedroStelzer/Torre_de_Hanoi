section .bss
    input resb 3 ; Armazenar a entrada do usuário (máximo de 2 dígitos + null terminator)

section .data
    
    buffer db "0000000000"  ; Buffer para armazenar a string, terminador nulo incluído.
    len_buffer dd 0                  ; Tamanho da string resultante.

    ; Armazena os caracteres das torres
    origem db "A"
    auxiliar db "B"
    destino db "C"
    len equ $ - destino

    quebra_de_linha db 0x0a

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

    call mensagem_inicial
    call ler_entrada
    call mensagem_qtd_discos

    ; Essa parte converte a string de entrada do usuario em um valor inteiro
    mov esi, input                  ; armazena o endereço da string de entrada
    xor eax, eax                    ; reseta EAX
    call converte_string_para_int   ; chama a funcao que converte o numero(string) para inteiro
    mov ecx, eax                    ; armazenar o número convertido em num_disks

    ; Essa parte chama a funcao hanoi passando seus parametros de: numero de discos, origem(A), auxiliar(B) e destino(C)
    push ecx        ; ebp+20
    push origem     ; ebp+16
    push auxiliar   ; ebp+12
    push destino    ; ebp+8
    call hanoi      ; ebp+4

    call mensagem_final

    ; Finaliza o programa
    mov eax, 1
    int 0x80

mensagem_inicial:

    ; Essa estrutura sera um padrao para imprimir uma mensagem em que coloco na pilha o texto, tamanho do texto, endereco de retorno e ebp nesta ordem
    push texto1     ; ebp+12
    push len1       ; ebp+8
    call print      ; ebp+4
    add esp, 8      ; limpa o conteudo restante
    
    ret

ler_entrada:

    ; Ler a entrada do usuário. sys_read(mov eax, 3) precisa de 3 parametros(ebx, ecx e edx)
    mov eax, 3          ; faz uma chamada de leitura
    mov ebx, 0          ; entrada padrao stdin
    mov ecx, input      ; armazena o endereco do buffer especificado em .bss
    mov edx, 3          ; tamanho do buffer
    int 0x80            ; chamada do sistema

    ret

mensagem_qtd_discos:

    ; Imprime a seguinte mensagem, por exemplo: "Algoritmo da Torre de Hanoi com 3 discos:"
    push quebra_de_linha
    push len
    call print
    add esp, 8

    push texto5
    push len5
    call print
    add esp, 8

    push input
    push len
    call print
    add esp, 8

    push texto6
    push len6
    call print
    add esp, 8

    push quebra_de_linha
    push len
    call print
    add esp, 8

    push quebra_de_linha
    push len
    call print
    add esp, 8

    ret

converte_string_para_int:

    movzx ecx, byte [esi]           ; armazena um byte da string apontada por ESI em ECX e preenche os restantes dos bits com 0
    cmp ecx, 0x0a                   ; verifica se é o caractere de quebra de linha
    je termina_convercao            ; se a compacao for verdade, pula para o rotolo termina_conversao
    sub ecx, '0'                    ; converte o caractere ASCII para valor numérico
    imul eax, eax, 10               ; multiplica EAX por 10 (shift à esquerda de um dígito decimal)
    add eax, ecx                    ; adiciona o valor a EAX
    add esi, 1                      ; move para o próximo caractere
    jmp converte_string_para_int    ; repete o processo

termina_convercao:
    ret                 ; retorna com o resultado do EAX

converte_int_para_string:

    ; Número a ser convertido
    mov eax, [ebp+20]            ; Número para conversão
    mov edi, buffer        ; Ponteiro para o buffer
    add edi, 10            ; Apontar para o final do buffer
    mov byte [edi], 0      ; Adicionar terminador nulo

    ; Conversão de inteiro para string
    converte_loop:
        xor edx, edx           ; Limpar o registrador de resto
        mov ebx, 10            ; Divisor (10)
        div ebx                ; Dividir EAX por 10 (resultado em EAX, resto em EDX)
        add dl, '0'            ; Converter resto para ASCII
        dec edi                ; Mover ponteiro do buffer para trás
        mov [edi], dl          ; Armazenar o caractere no buffer
        inc dword [len_buffer]        ; Incrementar o tamanho da string
        test eax, eax          ; Verificar se EAX é 0 (quociente)
        jnz converte_loop       ; Se não for zero, continuar
        
        ; Impressão da string
        mov eax, 4             ; Syscall número 4 (write)
        mov ebx, 1             ; File descriptor 1 (stdout)
        mov ecx, edi           ; Ponteiro para a string (buffer)
        mov edx, [len_buffer]         ; Comprimento da string
        int 0x80               ; Chamar o kernel

        ret

mensagem_final:

    ; Exemplo da mensagem final: "Concluido"
    push quebra_de_linha
    push len
    call print
    add esp, 8

    push texto7
    push len7
    call print
    add esp, 8

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