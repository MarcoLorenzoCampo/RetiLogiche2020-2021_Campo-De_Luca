# PROVA FINALE PROGETTO DI RETI LOGICHE A.A. 2020/2021
Il progetto consiste nell'implementare un componenete hardware capace di aumentare il contrasto di un immagine secondo [l'equalizzazione dell'istogramma](https://it.wikipedia.org/wiki/Equalizzazione_dell%27istogramma)

# FUNZIONAMENTO 
Il numero di colonne e il numero di righe, ciascuna di dimensione 8 bit, sono salvati rispettivamente al byte 0 e 1.
I pixel dell'immagine, ciascuno di 8 bit, sono salvati in memoria con indirizzamento al byte a partire dal byte 2.
I pixel equalizzati, anch'essi di 8 bit, vengono salvati in memoria a partire dal byte in posizione __2+(N_COL * N_ROW)__.
L'equalizzazione viene eseguita da una macchina a stati finiti

# TEST BENCH
I test eseguiti sono stati volti a verificare il corretto funzionamento del componente nelle seguenti situazioni:
-Tutti i possibili valori di offset dell'equalizzazione
-Equalizzazione successiva di immagini
-Reset asincrono
-Dimensione degenere dell'immagine (0x0/nx0/0xn)

# CONTRIBUTORS
[Marco Lorenzo Campo](https://github.com/MarcoLorenzoCampo)
[Alessandro De Luca](https://github.com/AlessandroDL)
