#
# IAC 2023/2024 k-means
# teste
# Grupo: 40
# Campus: Alameda
#
# Autores:
# 109493, Francisco Martins
# 110425, Margarida Paiva
# 109617, Hernâni Mourão
#
# Tecnico/ULisboa


# ALGUMA INFORMACAO ADICIONAL PARA CADA GRUPO:
# - A "LED matrix" deve ter um tamanho de 32 x 32
# - O input e' definido na seccao .data. 
# - Abaixo propomos alguns inputs possiveis. Para usar um dos inputs propostos, basta descomentar 
#   esse e comentar os restantes.
# - Encorajamos cada grupo a inventar e experimentar outros inputs.
# - Os vetores points e centroids estao na forma x0, y0, x1, y1, ...


# Variaveis em memoria
.data

#Input A - linha inclinada
#n_points:    .word 9
#points:      .word 0,0, 1,1, 2,2, 3,3, 4,4, 5,5, 6,6, 7,7 8,8

#Input B - Cruz
#n_points:    .word 5
#points:     .word 4,2, 5,1, 5,2, 5,3 6,2

#Input C
#n_points:    .word 23
#points: .word 0,0, 0,1, 0,2, 1,0, 1,1, 1,2, 1,3, 2,0, 2,1, 5,3, 6,2, 6,3, 6,4, 7,2, 7,3, 6,8, 6,9, 7,8, 8,7, 8,8, 8,9, 9,7, 9,8

#Input D
n_points:    .word 30
points:      .word 16, 1, 17, 2, 18, 6, 20, 3, 21, 1, 17, 4, 21, 7, 16, 4, 21, 6, 19, 6, 4, 24, 6, 24, 8, 23, 6, 26, 6, 26, 6, 23, 8, 25, 7, 26, 7, 20, 4, 21, 4, 10, 2, 10, 3, 11, 2, 12, 4, 13, 4, 9, 4, 9, 3, 8, 0, 10, 4, 10



# Valores de centroids e k a usar na 1a parte do projeto:
#centroids:   .word 0,0
#k:           .word 1

# Valores de centroids, k e L a usar na 2a parte do prejeto:
centroids:   .word 0,0, 10,0, 0,10
k:           .word 3
L:           .word 10

# Abaixo devem ser declarados o vetor clusters (2a parte) e outras estruturas de dados
# que o grupo considere necessarias para a solucao:
#clusters: .word 1,2,0,1,2,1,2,0,1,2,1,2,1,2,1,2,1,2,1,2,1,0,0,0,0,0,0,0,0,1    
clusters: .zero 120



#Definicoes de cores a usar no projeto 

colors:      .word 0xff0000, 0x00ff00, 0x0000ff  # Cores dos pontos do cluster 0, 1, 2, etc.

.equ         black      0
.equ         white      0xffffff



# Codigo
 
.text
    # Chama funcao principal da 1a parte do projeto
    #jal mainSingleCluster

    # Descomentar na 2a parte do projeto:
    jal mainKMeans
    
    #Termina o programa (chamando chamada sistema)
    li a7, 10
    ecall

#funcname_typename_descriptive

### printPoint
# Pinta o ponto (x,y) na LED matrix com a cor passada por argumento
# Nota: a implementacao desta funcao ja' e' fornecida pelos docentes
# E' uma funcao auxiliar que deve ser chamada pelas funcoes seguintes que pintam a LED matrix.
# Argumentos:
# a0: x
# a1: y
# a2: cor

printPoint:
    li a3, LED_MATRIX_0_HEIGHT
    sub a1, a3, a1
    addi a1, a1, -1
    li a3, LED_MATRIX_0_WIDTH
    mul a3, a3, a1
    add a3, a3, a0
    slli a3, a3, 2
    li a0, LED_MATRIX_0_BASE
    add a3, a3, a0   # addr
    sw a2, 0(a3)
    jr ra
    

### cleanScreen
# Limpa todos os pontos do ecra
# Argumentos: nenhum
# Retorno: nenhum

cleanScreen:
    li t0 0
    li t1 0
    li t2 32
    addi sp sp -4
    sw ra 0(sp)
    cleanScreen_loop_externo_beg:
       beq t1 t2 cleanScreen_loop_externo_end #no final de cada linha, volta a fazer a coluna
       li t0 0
        cleanScreen_loop_interno_beg:
            beq t0 t2 cleanScreen_loop_interno_end #percorre cada linha e coloca o ponto a branco
            mv a0 t0
            mv a1 t1
            li a2 white
            
            jal printPoint
            
            addi t0 t0 1
            j cleanScreen_loop_interno_beg   
        cleanScreen_loop_interno_end:
            addi t1 t1 1
            j cleanScreen_loop_externo_beg
    cleanScreen_loop_externo_end:
        lw ra 0(sp)
        addi sp sp 4
        jr ra

    
### printClusters
# Pinta os agrupamentos na LED matrix com a cor correspondente.
# Argumentos: nenhum
# Retorno: nenhum

printClusters:
    # POR IMPLEMENTAR (2a parte)
    addi sp sp -12
    sw a0 0(sp)
    sw a1 4(sp)
    sw a2 8(sp)

    lw t0 n_points
    la t1 points
    li t6 4
    la t3 clusters
    #t2 fica com a cor atual, refreshed em cada ciclo com o início do vetor cores
    
    printClusters_loop_beg: #percorre o vetor de pontos e coloca-os no ecrã
        beq t0 x0 printClusters_loop_end #verifica se se chegou ao final do vetor
        la t2 colors
        lw a0 0(t1)
        lw a1 4(t1)
        lw t5 0(t3)
        mul t5 t5 t6 #vejo que cluster é, e faço correspondência com a sua cor
        add t2 t2 t5
        lw a2 0(t2)
        
        #tratar do call stack
        addi sp sp -4
        sw ra 0(sp)
        jal printPoint
        lw ra 0(sp)
        #destruir o call stack
        addi sp sp 4
        #incrementar o endereço dos pontos para passar ao seguinte
        addi t1 t1 8
        #incrementar o endereço do vetor clusters para passar ao seguinte
        addi t3 t3 4
        #decrementar o número de pontos que falta verificar
        addi t0 t0 -1
        j printClusters_loop_beg
    printClusters_loop_end:
        j printClusters_bigif_end
    printClusters_bigif_beg:
        
    printClusters_bigif_end:
    lw a0 0(sp)
    lw a1 4(sp)
    lw a2 8(sp)
    addi sp sp 12
    jr ra

### printCentroids
# Pinta os centroides na LED matrix
# Nota: deve ser usada a cor preta (black) para todos os centroides
# Argumentos: nenhum
# Retorno: nenhum

printCentroids:
    # POR IMPLEMENTAR (2a parte)
    li t0 0          
    li t1 8         
    #li t2 0          # Inicializar o vetor
    la t3 centroids  
    lw t4 k          
    li a2 black     
    
    printCentroids_loop:
        mul t6 t0 t1    # Deslocamento centroide 
        add t6 t6 t3    

        lw a0 0(t6)      #coordenada x 
        lw a1 4(t6)      # coordenada y 
        addi sp sp -4
        sw ra 0(sp)
        jal printPoint
        lw ra 0(sp)
        addi sp sp 4
        
        addi t0 t0 1    # proximo centroide
        bne t0 t4 printCentroids_loop
    jr ra
    

### calculateCentroids
# Calcula os k centroides, a partir da distribuicao atual de pontos associados a cada agrupamento (cluster)
# Argumentos: nenhum
# Retorno: nenhum

calculateCentroids:
    addi sp sp -32
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)
    sw s5 24(sp)
    sw s6 28(sp)
    
    lw s0 k
    #addi s0 s0 -1
    lw s1 n_points
    la s2 points
    la s3 centroids
    la s4 clusters
    li s5 0 #número de centroids percorrido
    li s6 0 #número de pontos a considerar para a média
    
    #t0 tem a média de x
    #t1 tem a média de y
    #t2 tem x do ponto atual
    #t3 tem o y do ponto atual
    #t4 tem o cluster do ponto atual
    calculateCentroids_outer_loop:
        beq s0 s5 calculateCentroids_outer_loop_end
        lw s1 n_points
        la s2 points
        la s4 clusters
        calculateCentroids_inner_loop:
            beq s1 x0 calculateCentroids_inner_loop_end
            lw t4 0(s4)
            beq t4 s5 calculateCentroids_if_point_in_centroid
            addi s4 s4 4
            addi s2 s2 8
            addi s1 s1 -1
            j calculateCentroids_inner_loop
        calculateCentroids_if_point_in_centroid:
            lw t2 0(s2)
            lw t3 4(s2)
            add t0 t0 t2
            add t1 t1 t3
            addi s4 s4 4
            addi s6 s6 1
            addi s2 s2 8
            addi s1 s1 -1
            j calculateCentroids_inner_loop
        calculateCentroids_inner_loop_end:
        div t0 t0 s6
        div t1 t1 s6
        sw t0 0(s3)
        sw t1 4(s3)
        addi s3 s3 8 
        addi s5 s5 1
        j calculateCentroids_outer_loop
    calculateCentroids_outer_loop_end:
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp)
    lw s5 24(sp)
    lw s6 28(sp)
    addi sp sp 32
    jr ra

### mainSingleCluster
# Funcao principal da 1a parte do projeto.
# Argumentos: nenhum
# Retorno: nenhum

mainSingleCluster:
    
    #1. Coloca k=1 (caso nao esteja a 1)
    lw t1 k
    li t2 1
    bne t1 t2 mainSingleCuster_bigif_bge
    
    #2. cleanScreen
    jal cleanScreen
    
    #3. printClusters
    jal printClusters
    
    #4. calculateCentroids
    jal calculateCentroids
    
    #5. printCentroids
    jal printCentroids
    
    #6. Termina
    mainSingleCuster_bigif_bge:
        #por implementar
    addi sp sp -4
    sw ra 0(sp)
    lw ra 0(sp)
    addi sp sp 4    
    jr ra
### PseudoRandomNumberGen
# Argumentos: nenhum
# Retorno: a0 número
PseudoRandomNumberGen:
    li a7 31
    ecall
    mv t1 a0
    li a7 30
    ecall
    mv t2 a0
    li t3 32
    rem t1 t1 t3
    rem t2 t2 t3
    add t2 t1 t2
    rem t2 t2 t3
    bge t2 x0 PseudoRandomNumberGen_end_1stif
    sub t2 x0 t2
    PseudoRandomNumberGen_end_1stif:
        mv a0 t2
    jr ra
### initializeCentroids
#Este procedimento incializa os valores inciais do vetor centroides. 
#Cada um dos k centroids deve ser colocado num par de coordenadas
#escolhido de forma pseudo-aleatória
# Argumentos: nenhum
# Retorno: nenhum
initializeCentroids:
    lw t0 k
    la t6 centroids
    addi sp sp -4
    sw ra 0(sp)
    initializeCentroids_loop:
        jal PseudoRandomNumberGen
        mv t4 a0
        jal PseudoRandomNumberGen
        mv t5 a0
        sw t4 0(t6)
        sw t5 4(t6)
        addi t6 t6 8
        addi t0 t0 -1
        beq t0 x0 initializeCentroids_endloop
        j initializeCentroids_loop
    initializeCentroids_endloop:
    lw ra 0(sp)
    addi sp sp 4
    
    jr ra
    
### manhattanDistance
# Calcula a distancia de Manhattan entre (x0,y0) e (x1,y1)
# Argumentos:
# a0, a1: x0, y0
# a2, a3: x1, y1
# Retorno:
# a0: distance

manhattanDistance:
    # POR IMPLEMENTAR (2a parte)
    sub a0 a0 a2
    bge a0 x0 manhattanDistance_end_1stif
    sub a0 x0 a0
    manhattanDistance_end_1stif:
    sub a1 a1 a3
    bge a1 x0 manhattanDistance_end_2ndtif
    sub a1 x0 a1
    manhattanDistance_end_2ndtif:
    add a0 a0 a1
    jr ra


### nearestCluster
# Determina o centroide mais perto de um dado ponto (x,y).
# Argumentos:
# a0, a1: (x, y) point
# Retorno:
# a0: cluster index

nearestCluster:
    addi sp, sp , -32
    sw ra, 0(sp)
    sw s0 4(sp) 
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)
    sw s5 24(sp)
    sw s6 28(sp)
    lw s0, k
    la s1, centroids
    li s2, 0 #indice do centroid atual
    li s3, 0 #indice do centroid a retornar
    mv s4, a0 #preservar o valor do a0, uma vez que a funcao manhattanDistance returna a distancia em a0
    mv s5, a1
    li s6, 200 #menor distancia
    
    nearestCluster_loop:
        beq s2, s0, nearestCluster_loop_end
        lw a2, 0(s1) #carregar a cordenada x do centroid
        lw a3, 4(s1) #carregar a cordenada y do centroid
        jal manhattanDistance
        mv t4, a0 #mover a distancia para t4
        mv a0, s4 #restaurar o a0
        mv a1, s5
        addi s1, s1, 8 #andar para a frente no vetor centroids
        bgt s6, t4, nearestCluster_swapCluster #verifica se e necessario trocar o indice do cluster
        addi s2, s2, 1 #incrementar o indice do cluster atual
        j nearestCluster_loop
    nearestCluster_swapCluster:
        mv s6, t4 #troca a menor distancia
        mv s3, s2 #troca o indice do cluster a retornar
        addi s2, s2, 1 #incrementar o indice do cluster atual
        j nearestCluster_loop
    nearestCluster_loop_end:
        mv a0, s3 
        lw ra, 0(sp)
        lw s0 4(sp)
        lw s1 8(sp)
        lw s2 12(sp)
        lw s3 16(sp)
        lw s4 20(sp)
        lw s5 24(sp)
        lw s6 28(sp)
        addi sp, sp, 32 #retornar o callstack
                 
    jr ra

### setClusters
# Pega no vetor de pontos e associa ao cluster correspondente
# Argumentos: 
# None
# Retorno:
# None

setClusters:
    addi sp sp -16
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    lw s0 n_points
    la s1 points
    la s2 clusters
    setClusters_loop:
        lw a0 0(s1)
        lw a1 4(s1)
        jal nearestCluster
        sw a0 0(s2)
        addi s0 s0 -1
        addi s2 s2 4
        addi s1 s1 8
        beq x0 s0 setClusters_loop_end
        j setClusters_loop
    setClusters_loop_end:
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    addi sp sp 16
    jr ra


### mainKMeans
# Executa o algoritmo *k-means*.
# Argumentos: nenhum
# Retorno: nenhum
    

mainKMeans:  
    # POR IMPLEMENTAR (2a parte)
    jal cleanScreen
    
    jal initializeCentroids
    jal printCentroids
    jal printClusters
    
    jal setClusters
    jal calculateCentroids
    jal cleanScreen
    jal printClusters
    jal printCentroids
    jr ra
