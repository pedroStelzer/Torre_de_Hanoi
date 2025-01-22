def hanoi(n, torre_inicial, torre_auxiliar, torre_destino):
    if(n == 1):
        print(f"mova disco 1 de {torre_inicial} para {torre_destino}")
        return 1
    
    hanoi(n-1, torre_inicial, torre_destino, torre_auxiliar)
    print(f"mova disco {n} de {torre_inicial} para {torre_destino}")
    hanoi(n-1, torre_auxiliar, torre_inicial, torre_destino)

hanoi(2, "A", "B", "C")