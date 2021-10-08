# PROVA FINALE PROGETTO DI RETI LOGICHE A.A. 2020/2021
Il progetto consiste nell'implementare un componenete hardware capace di aumentare il contrasto di un immagine secondo [l'equalizzazione dell'istogramma](https://it.wikipedia.org/wiki/Equalizzazione_dell%27istogramma)<br>
<br>
# FUNZIONAMENTO 
Il numero di colonne e il numero di righe, ciascuna di dimensione 8 bit, sono salvati rispettivamente al byte 0 e 1.<br>
I pixel dell'immagine, ciascuno di 8 bit, sono salvati in memoria con indirizzamento al byte a partire dal byte 2.<br>
I pixel equalizzati, anch'essi di 8 bit, vengono salvati in memoria a partire dal byte in posizione __2+(N_COL * N_ROW)__.<br>
L'equalizzazione viene eseguita da una macchina a stati finiti che trova il valore di offset come 8-FLOOR(Log2(MAX_pixel - min_pixel), e esegue lo shift logico a sinistra (Current_pixel - min_pixel) << offset e considera come pixel equalizzato il minimo tra il valore calcolato e 255 (massimo valore di ogni pixel)<br>
<br>
# TEST BENCH
I test eseguiti sono stati volti a verificare il corretto funzionamento del componente nelle seguenti situazioni:<br>
-Tutti i possibili valori di offset dell'equalizzazione<br>
-Equalizzazione successiva di immagini<br>
-Reset asincrono<br>
-Dimensione degenere dell'immagine (0x0/nx0/0xn)<br>
<br>
# CONTRIBUTORS
[Marco Lorenzo Campo](https://github.com/MarcoLorenzoCampo)<br>
[Alessandro De Luca](https://github.com/AlessandroDL)<br>
